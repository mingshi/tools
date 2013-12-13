#!/bin/sh

mem=`free -m | awk 'NR==2{print $2}'`
#ps -aux 2>&1 | sort -k 4 -r | awk '$4~/^[0-9]/&&$4>0 {print $4,$11}' | awk -v mem=$mem '{print $1/100*mem"   "$2}' | sort -k 2 | awk -v mem=$mem '
top -b -n1 2>&1 | sort -k 10 -r | awk '$1~/^[0-9]+$/&&$10~/^[0-9]/&&$10>0 {print $10,$NF}' | awk -v mem=$mem '{printf "%.3f  %s\n",$1/100*mem,$2}' | sort -k 2 | awk -v mem=$mem '
{
   a[$2] += $1;
   b[$2]++;
   total += $1;
   total++;
}
END{
  for(i in a){
    t=i;
    gsub(/:|.*\//, "", t);
    printf "%10s   %s\n" ,a[i]"MB", t"["b[i]"]";
    #printf "%10.3fMB   %s[%d]\n",a[i],t,b[i];
  }
print "Memory Total: "mem"MB, used: "total"MB, free: "mem-total"MB."
}' | sort -rn
