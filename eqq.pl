#!/usr/bin/env perl
#===============================================================================
#
#         FILE: eqq.pl
#
#        USAGE: ./eqq.pl
#
#  DESCRIPTION: 广点通数据采集
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Baboo (8boo.net), baboo.wg@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 2013/08/23 11时46分32秒
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
use Digest::MD5 qw(md5 md5_hex);
use Data::Dumper;

binmode(STDOUT, ':utf8');

my $alarm_type = 'qq';
my $alarm_receiver = {
    qq => [ 'xxxxxxxxx', 'xxxxxxxxx' ],
};

my @sessions = (
    {
        user => '2194866839',
        passwd => 'xxxxxxxxx',
        session_id => '147bf3a6b608e670337f93959b3a1164',
        skey => '@WBbxgwawo',
    },
);

my $err_msg;

sub login
{
    my $ua = Mojo::UserAgent->new();
    my $firstUrl = "http://ui.ptlogin2.qq.com/cgi-bin/login?hide_title_bar=1&no_verifyimg=1&link_target=blank&appid=15000103&target=parent&f_url=http%3A%2F%2Fimgcache.qq.com%2Fqzone%2Fvas%2Flogin%2Fjump.html%3Fret%3D1&s_url=http%3A%2F%2Fimgcache.qq.com%2Fqzone%2Fvas%2Flogin%2Fjump.html%3Fret%3D0";
    my $res1 = $ua->get($firstUrl);

    if (my ($login_sig) = $res1->res->body =~ "var g_login_sig=\"(.*?)\";") {
        for my $session (@sessions) {
            my $secondUrl = "http://check.ptlogin2.qq.com/check?uin=".$session->{user}."&appid=15000103&js_ver=10042&js_type=0&login_sig=".$login_sig."&u1=http%3A%2F%2Fimgcache.qq.com%2Fqzone%2Fvas%2Flogin%2Fjump.html%3Fret%3D0&r=0.061516034688708254";
            my $res2 = $ua->get($secondUrl);

            my ($is_need_verify, $code1, $code2) = split(',', $res2->res->body);
            $is_need_verify = ($is_need_verify =~ m/'(.+)'/)[0];
            
            if (my (@tmpArr) = split('\'', $res2->res->body)) {
                my $verifycode = $tmpArr[3];
                if ($is_need_verify) {
                    print "Get verify code and save it to /var/tmp/image.jpg \n";
                    _get_verify_code($ua, $session->{user}, $verifycode);
                    
                    my $r = `scp /var/tmp/image.jpg wukong:/var/tmp/qqImage.jpg`;
                    
                    my $qq = join(',', @{$alarm_receiver->{qq}});

                    my $tmpUrl = "http://2.2.2.2:9888/?qq=".$qq."&content=Robot登录需要验证码:\n [image:/var/tmp/qqImage.jpg]";
                    
                    my $imageRes = $ua->get($tmpUrl);

                    for (my $i = 0; $i < 120; $i++) {
                        sleep(1);
                        next unless (-f "/tmp/qqCode");
                    
                        open my $fh, '<:utf8', '/tmp/qqCode';
                        my $code = do { local $/ = <$fh> };
                        close $fh;
                        $verifycode = uc($code);
                        $verifycode =~ s/\n//g;
                        unlink "/tmp/qqCode";
                        last;
                    }

                    unless ($verifycode =~  /^[A-Z0-9]{4}$/) {
                        $err_msg = "验证码获取失败";
                    }
                }

                my $code2 = $tmpArr[5];

                my $password = _jspassword($session->{passwd}, $code2, $verifycode);

                my $thirdUrl = "http://ptlogin2.qq.com/login?u=2194866839&p=".$password."&verifycode=".$verifycode."&aid=15000103&u1=http%3A%2F%2Fimgcache.qq.com%2Fqzone%2Fvas%2Flogin%2Fjump.html%3Fret%3D0&h=1&ptredirect=2&ptlang=2052&from_ui=1&dumy=&fp=loginerroralert&action=5-6-48975&mibao_css=&t=1&g=1&js_type=0&js_ver=10042&login_sig=".$login_sig;

                my $res3 = $ua->get($thirdUrl);

                my @tmp = split('\'', $res3->res->body);
                print(decode('UTF-8', $res3->res->body));
                if ($tmp[1] != 0) {
                    $err_msg = "Spider qq login error when login in at EQQ";
                } else {
                    my $jar = $ua->cookie_jar;
                    my %result;
                    for my $r ($jar->all) {
                        $result{$r->name} = $r->value;
                    }
                    $session->{skey} = $result{skey};
                }
            } else {
                $err_msg = "Spider qq login error when get verifycode at EQQ";
            }
        }
    } else {
        $err_msg = "Spider qq login error at EQQ";
    }
}

login();

sub _get_verify_code {
    my ($ua, $username, $vc) = @_;
    my $uin = $username;
    my $res = $ua->get("http://captcha.qq.com/getimage?aid=15000103&0.5957159416021285&uin=$uin")->res;
    open(MYFILE, '>:raw', "/var/tmp/image.jpg");
    print MYFILE $res->body;
    close(MYFILE);
}




sub _jspassword
{
    my ($p, $pt, $vc) = @_;
    $p = uc(md5_hex($p));
    my $len = length($p);
    my $temp = '';
    for (my $i=0; $i < $len ; $i = $i + 2)
    {
        $temp .= '\x'.substr($p, $i,2);
    }
    return uc(md5_hex(uc(md5_hex(_hex2asc($temp)._hex2asc($pt))).$vc));
}

sub _hex2asc
{
    my $str = shift;
    $str = join('', split(/\\x/, $str));
    my $len = length($str);
    my $data = '';
    for (my $i=0; $i < $len; $i+=2)
    {
        $data.=chr(hex(substr($str, $i, 2)));
    }
    return $data;
}



sub get_gtk {
    my $str = shift;
    my $hash=5381;
    for my $char (split //, $str) {
        $hash += ($hash << 5) + ord($char);
    }
    return $hash&0x7fffffff;
}

sub get_ua {
    my $session = shift;

    my $ua = Mojo::UserAgent->new({
        name => 'Mozilla/5.0',
        inactivity_timeout => 0,
    });

    $ua->cookie_jar->add(
        Mojo::Cookie::Response->new({
            domain => '.qq.com',
            name => 'uin',
            value => 'o' . $session->{user},
            path => '/',
        }),
        Mojo::Cookie::Response->new({
            domain => '.qq.com',
            name => 'o_cookie',
            value => $session->{user},
            path => '/',
        }),
        Mojo::Cookie::Response->new({
            domain => '.qq.com',
            name => 'skey',
            value => $session->{skey},
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
my $default_product = 'g_mc';
my %product_plan_map = (
    '白发' => 'g_hnh',
);
my %product_data = ();

for my $session (@sessions) {
    my $ua = get_ua($session);

    my %products = ();
    my $gtk = get_gtk($session->{skey});
    my $report_url = "http://e.qq.com/ec/api.php?mod=report&act=campaign&g_tk=$gtk&d_p=0.8263149736449122&datetype=1&format=json&page=1&pagesize=10&sdate=$date&edate=$date&searchcname=&=&callback=_Callback";
    my $tx = $ua->get($report_url, {
        Referer => 'http://e.qq.com/ec/',
        'X-Requested-With' => 'XMLHttpRequest',
    });

    if (my $resp = $tx->success) {
        my ($json) = $resp->body =~ m/(\{.+\})/;
        $json = decode_json(encode('UTF-8', $json));
        if ($json->{ret} eq '0') {
            for my $row (@{$json->{data}{list}}) {
                my $size = $row->{campaignname};
                $data{$size}{cost} += ($row->{cost} eq '-' ? 0 : $row->{cost}) / 100;
                $data{$size}{pv} += ($row->{viewcount} eq '-' ? 0 : $row->{viewcount});
                $data{$size}{click} += $row->{validclickcount} eq '-' ? 0 : $row->{validclickcount};
            }
        } else {
            $err_msg = "EQQ spider resposne[$session->{user}] error.";
            last;
        }
    } else {
        my ($err, $code) = $tx->error;
        $err_msg = "Get eqq report error: $err. code:$code";
        last;
    }
}

if ($err_msg) {
    #M('alarm_queue', 'ad_report')->insert({
    #    send_type => $alarm_type,
    #    send_to => encode_json($alarm_receiver),
    #    msg => $err_msg,
    #});

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
