#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: ${0##*/} <process name>"
    exit 1
fi

proc=$1
MAX_PROCESS_LIVE_TIME_IN_SECONDS=3600

pids=`ps aux | grep $proc | grep -v grep | awk '{print $2}'`

for p in $pids; do
    read etime pid prog <<<$(ps -eo etime,pid,args | grep $p | grep $proc | grep -v grep)
    etimeToSeconds=`echo $etime | awk -F $':' -f <(cat - <<-'EOF'
  {
    if (NF == 2) {
      print $1*60 + $2
    } else if (NF == 3) {
      split($1, a, "-");
      if (a[2] > 0) {
        print ((a[1]*24+a[2])*60 + $2) * 60 + $3;
      } else {
        print ($1*60 + $2) * 60 + $3;
      }
    }
  }
EOF
)`
    if test -n "$etimeToSeconds";then
	if [ $etimeToSeconds -gt $MAX_PROCESS_LIVE_TIME_IN_SECONDS ];then
	    echo `date "+DATE: %m/%d/%y TIME: %H:%M:%S"` "PID:$pid PROGRAM:$prog running process more than ${MAX_PROCESS_LIVE_TIME_IN_SECONDS} seconds, killing process..." 
            kill -9 $pid
        fi
    fi
done
