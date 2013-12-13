#!/bin/bash
mem=`free -m |awk 'NR==2{print $2}'`
ps -aux 2>&1 | sort -k 4 -r |awk '$4 ~ /^[0-9]/ && $4>0 {print $4,$11}'|awk '{print $1/100*mem"      "$2}' mem=$mem |sort -k 2|awk '
{
        a[$2] += $1;
        b[$2]++;
}
END{
        for(i in a){
                printf "%10s   %-10s\n" ,a[i]"MB", i"["b[i]"]";
        }
}'|sort -rn|head -10
