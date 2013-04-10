<?php
class Location {

    public static  function getDistance($lat1,$lng1,$lat2,$lng2) {

        if (is_numeric($lat1)
                && is_numeric($lng1) 
                && is_numeric($lat2) 
                && is_numeric($lng2)
                && $lat1 != ""
                && $lng1 != ""
                && $lat2 != ""
                && $lng2 != ""
                ) { 
            $r = 6378.137; // 地球半径
            $lat2 = floatval($lat2);
            $lat1 = floatval($lat1);
            $lng2 = floatval($lng2);
            $lng1 = floatval($lng1);
            $dlat = deg2rad($lat2 - $lat1);
            $dlng = deg2rad($lng2 - $lng1);
            $a = pow(sin($dlat / 2), 2) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * pow(sin($dlng / 2), 2); 
            $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
            return $r * $c; 
        } else {
            return false;
        }   
    }   

    public static function getMinDistance($max_lat,$max_lng,$min_lat,$min_lng){
        $lng = (floatval($max_lng) + floatval($min_lng)) / 2;  
        $lat = (floatval($max_lat) + floatval($min_lat)) / 2;
        $distance_a = self::getDistance($lng,$lat,$lng,$max_lat);
        $distacne_b = self::getDistance($lng,$lat,$min_lng,$lat);
        return $distance_a > $distacne_b ? $distacne_b : $distance_a; 
    }
}

$L = new Location();

$d = $L->getMinDistance(31.27,121.41,31.239,121.382);

echo $d;
