#!/bin/bash
if [[ ! -z $1 ]] ; then
    RACEDATE=$1
fi

if [[ -z $RACEDATE ]] ; then
    echo 'Provide a race date, such as 2016-02-01'
    exit 1
fi

if [[ -z "$AP_API_KEY" ]] ; then
    echo "Missing environmental variable AP_API_KEY. Try 'export AP_API_KEY=MY_API_KEY_GOES_HERE'."
    exit 1
fi

date "+STARTED: %H:%M:%S"
echo "------------------------------"

echo "Drop elex_$1 if it exists"
dropdb -h $ELEX_DB_HOST -U elex elex_$RACEDATE --if-exists

echo "Create elex_$RACEDATE"
psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE -l | grep -q elex_$RACEDATE || createdb -h $ELEX_DB_HOST -U elex elex_$RACEDATE

echo "Initialize races"
cat fields/races.txt | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE
elex races $RACEDATE -t | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE -c "COPY races FROM stdin DELIMITER ',' CSV HEADER;"

echo "Initialize reporting units"
cat fields/reporting_units.txt | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE
elex reporting-units $RACEDATE -t | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE -c "COPY reporting_units FROM stdin DELIMITER ',' CSV HEADER;"

echo "Initialize candidates"
cat fields/candidates.txt | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE
elex candidates $RACEDATE -t | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE -c "COPY candidates FROM stdin DELIMITER ',' CSV HEADER;"

echo "Initialize ballot measures"
cat fields/ballot_measures.txt | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE
elex ballot-measures $RACEDATE -t | psql -h $ELEX_DB_HOST -U elex -d elex_$RACEDATE -c "COPY ballot_positions FROM stdin DELIMITER ',' CSV HEADER;"

echo "------------------------------"
date "+ENDED: %H:%M:%S"