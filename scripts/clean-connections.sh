#!/bin/bash

if [ -z ${DB_NAMES} ] && [ -z ${DB_USER} ] && [ -z ${DB_HOST} ] && [ -z ${DB_PORT} ] && [ -z ${DB_PASSWORD} ];
then
    echo "Environment variables 'DB_NAMES', 'DB_USER', 'DB_HOST', 'DB_PORT' and 'DB_PASSWORD' must be set"
    exit 1
fi

IDLE_TIMEOUT_INTERVAL_MINUTES=${IDLE_TIMEOUT_INTERVAL_MINUTES:-"15"}

function cleanQuery() {
    echo "psql -h ${DB_HOST} -u ${DB_USER} -p ${DB_PORT} -P ${DB_PASSWORD} \
     SELECT pg_terminate_backend(pid) \
     FROM pg_stat_activity \
     WHERE datname = '$1' \
	 AND pid <> pg_backend_pid() \
	 AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') \
	 AND state_change < current_timestamp - INTERVAL '${IDLE_TIMEOUT_INTERVAL_MINUTES}' MINUTE;"
}

IFS=',' read -r -a DB_NAME_LIST <<< "${DB_NAMES}"

for db_name in "${DB_NAME_LIST[@]}";
do
    # Trim whitespace
    db_name=$(echo $db_name | sed -e 's/  *$//' )
    cleanQuery $db_name
done


