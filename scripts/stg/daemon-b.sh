#!/bin/bash

. /etc/environment

if [[ ! -z $1 ]] ; then 
    RACEDATE=$1 
fi

if [ -f /tmp/elex_loader_timeout.sh ]; then
    . /tmp/elex_loader_timeout.sh
fi

if [[ -z $ELEX_LOADER_TIMEOUT ]] ; then
    ELEX_LOADER_TIMEOUT=30
fi

for (( i=1; i<100000; i+=1 )); do

    if [ -f /tmp/elex_loader_timeout.sh ]; then
        . /tmp/elex_loader_timeout.sh
    fi

    echo "Timeout:" $ELEX_LOADER_TIMEOUT"s"

    SECONDS=0

    cd /home/ubuntu/election-2016/LATEST/ && NODE_PROCESS=B npm run post-update-b "$RACEDATE"

    echo "Total time elapsed (B):" $SECONDS"s"

    sleep $ELEX_LOADER_TIMEOUT

done