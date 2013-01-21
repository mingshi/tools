<?php

define('API_URL', 'https://maps.googleapis.com/maps/api/geocode/');
define('DATA_TYPE', 'json');

$ch = curl_init();

$addr = @$argv[1];
$bounds = @$argv[2];

if (empty($addr)) {
    echo "specify address please. \n";
}

$params = array(
    "address" => $addr,
    "language" => "zh-CN",
    "sensor" => "false"
);

if ($bounds) {
    $params['bounds'] = $bounds;
}

curl_setopt($ch, CURLOPT_URL, API_URL . DATA_TYPE . "?" . http_build_query($params));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

$ret = curl_exec($ch);
echo $addr . "\t";
echo $ret;
$ret = json_decode($ret, 1);
if ($ret) {
    if ($ret['status'] == 'OK') {
        foreach ($ret['results'] as $item) {
            echo $item['formatted_address'] , "\t";
            $ne = $item['geometry']['bounds']['northeast'];
            $sw = $item['geometry']['bounds']['southwest'];

            echo $ne['lat'] . "\t" . $ne['lng'] . "\t";
            echo $sw['lat'] . "\t" . $sw['lng'] . "\n";
            break;
        }
    }
}
