#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tango.pl
#
#        USAGE: ./tango.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Baboo (8boo.net), baboo.wg@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2013/07/29 15时45分11秒
#     REVISION: ---
#===============================================================================

use Mojo::UserAgent;
use Mojo::Util qw/encode decode/;
use JSON::XS;
use File::Basename qw/dirname/;
use lib dirname(__FILE__) . '/../../../lib';
use MY::Utils;
use Modern::Perl;
use utf8;

binmode(STDOUT, ':utf8');

my $alarm_type = 'qq';
my $alarm_receiver = {
    qq => [ '258047659' ],
};

my @sessions = (
    { 
        user => 'zhhl-0702',
        passwd => 'xxxxx',
        session_id => '147bf3a6b608e670337f93959b3a1164',
        user_id => '12862',
    },
    {
        user => 'shpfs-715', 
        passwd => 'xxxxx',
        session_id => 'f27469a57db6f97547da7faf489630a8',
        user_id => '12926',
    },
    {
        user => 'at109-082', 
        passwd => 'xxxxx',
        session_id => '192ad1d8b1ae114bf71fface89b25eff',
        user_id => '13016',
    },
    {
        user => 'a109-087', 
        passwd => 'xxxxx',
        session_id => 'eed18a35668421a14484517e442eeb98',
        user_id => '13034',
    },
    {
        user => 'Zlhh-0814', 
        passwd => 'xxxxx',
        session_id => '71a32826db6bf36c2b09695bcea6f28d',
        user_id => '13058',
    }
);

sub get_ua {
    my $session = shift;

    my $ua = Mojo::UserAgent->new({
        name => 'Mozilla/5.0',
        inactivity_timeout => 0,
    });

    $ua->cookie_jar->add(
        Mojo::Cookie::Response->new({
            domain => '.tango.qq.com',
            name => 'user_id',
            value => $session->{user_id},
            path => '/',
        }),
        Mojo::Cookie::Response->new({
            domain => 'tango.qq.com',
            name => 'PHPSESSID',
            value => $session->{session_id},
            path => '/',
        }),
    );

    return $ua;
}

my $date = strftime('%F');

if ($ARGV[0]) {
    $date = $ARGV[0];
}

my %data = ();
my $err_msg;
my $default_product = 'mc';
my %product_plan_map = (
    '白发' => 'hnh',
);
my %product_data = ();

for my $session (@sessions) {
    my $ua = get_ua($session);
    
    my %products = ();
    my $plan_list_url = 'http://tango.qq.com/tangoreport/autocomplete?words=&act=campaign';
    my $plan_tx = $ua->get($plan_list_url, {
        Referer => 'http://tango.qq.com/tangoreport/style',
        'X-Requested-With' => 'XMLHttpRequest',
    });

    if (my $resp = $plan_tx->success) {
        for my $plan (@{$resp->json('/ret_msg')}) {
            my $plan_text = $plan->{text};
            next unless $plan_text;
            for my $keyword (keys %product_plan_map) {
                if ($plan_text ~~ /$keyword/) {
                    $products{$plan->{value}} = $product_plan_map{$keyword};
                }
            }
        }
    } else {
        my ($err, $code) = $plan_tx->error;
        $err_msg = "Get plan list error: $err. code:$code";
        last;
    }

    my $url = "http://tango.qq.com/tangoreport/stylereport?begin_date=$date&end_date=$date&sort_field=Fcost&sort_asc=DESC&adplan_list=&ad_list=";

    my $tx = $ua->get($url, {
        Referer => 'http://tango.qq.com/tangoreport/style',
        'X-Requested-With' => 'XMLHttpRequest',
    });

    if (my $resp = $tx->success) {
        if ($resp->json('/ret_code') eq '0') {
            for my $row (@{$resp->json('/ret_msg/records')}) {
                my $size = $row->{Fcreative_style};
                next if $size eq '汇总';
                $data{$size}{cost} += $row->{Fcost};
                $data{$size}{pv} += $row->{Fview};
                $data{$size}{click} += $row->{Fclick};
            }
        } else {
            $err_msg = "Tango spider resposne[$session->{user}] error:" . $resp->json('/ret_msg');           
            last;
        }
    } else {
        my ($err, $code) = $tx->error;
        $err_msg = "Get report error: $err. code:$code";
        last;
    }

    for my $plan_id (keys %products) {
        my $product_name = $products{$plan_id};
        my $url = "http://tango.qq.com/tangoreport/stylereport?begin_date=$date&end_date=$date&sort_field=Fcost&sort_asc=DESC&adplan_list=$plan_id&ad_list=";

        my $tx = $ua->get($url, {
            Referer => 'http://tango.qq.com/tangoreport/style',
            'X-Requested-With' => 'XMLHttpRequest',
        });

        if (my $resp = $tx->success) {
            if ($resp->json('/ret_code') eq '0') {
                for my $row (@{$resp->json('/ret_msg/records')}) {
                    my $size = $row->{Fcreative_style};
                    next if $size eq '汇总';
                    $product_data{$product_name}{$size}{cost} += $row->{Fcost};
                    $product_data{$product_name}{$size}{pv} += $row->{Fview};
                    $product_data{$product_name}{$size}{click} += $row->{Fclick};
                }
            } else {
                $err_msg = "Tango spider resposne[$session->{user}] error:" . $resp->json('/ret_msg');           
                last;
            }
        } else {
            my ($err, $code) = $tx->error;
            $err_msg = "Get plan report error: $err. code:$code";
            last;
        }
    }
}

if ($err_msg) {
    M('alarm_queue', 'ad_report')->insert({
        send_type => $alarm_type,
        send_to => encode_json($alarm_receiver),
        msg => $err_msg,
    });

    die $err_msg;
}

for my $product_name (keys %product_data) {
    for my $size (keys %{$product_data{$product_name}}) {
        my $p_data = $product_data{$product_name}{$size};
        for my $key (keys %$p_data) {
            $data{$size}{$key} -= $p_data->{$key};
        }
    }
}

$product_data{$default_product} = \%data;
my $m = M('tango_data', 'ad_report');
for my $product_name (keys %product_data) {
    my $p_data = $product_data{$product_name};

    for my $size (keys %$p_data) {
        my $key = {
            date => $date,
            slot_size => $size,
            product => $product_name,
        };

        my $ins = {
            cost => $p_data->{$size}{cost},
            pv => $p_data->{$size}{pv},
            click => $p_data->{$size}{click},
        };
        $m->insert_replace($key, $ins, $ins);
    }
}
