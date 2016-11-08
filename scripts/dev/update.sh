#!/bin/bash
. scripts/dev/_post.sh
. scripts/dev/_pre.sh
. scripts/dev/_results.sh
. scripts/dev/_views.sh

if [[ ! -z $1 ]] ; then 
    RACEDATE=$1 
fi

if [[ -z $AP_API_BASE_URL ]] ; then
    AP_API_BASE_URL="http://api.ap.org/v2/"
fi

TIMESTAMP=$(date +"%s")

pre
set_temp_tables

export ELEX_LOADER_ERROR=false

local_results & PIDLOCAL=$!
national_results & PIDNATIONAL=$!
districts & PIDDISTRICTS=$!
wait $PIDDISTRICTS
wait $PIDLOCAL
wait $PIDNATIONAL

if [ ! $ELEX_LOADER_ERROR ] ; then
    copy_results
    views

    echo "Results time elapsed:" $SECONDS"s"

    echo "Total time elapsed:" $SECONDS"s"
fi

export ERROR=false