#!/bin/bash

# Truncate sent sms gateway tables.

DB_CONF=/usr/local/scripts/conf/mysql/site_db.cnf
DB_CMD="/bin/mysql \
        --defaults-extra-file="$DB_CONF" \
        --skip-column-names"
DB=gateway
SQL_TRUNCATE='truncate table '
SQL_RECORD_COUNT='select table_rows from information_schema.tables where table_schema = '\'${DB}\'' and table_name = '\'#TABLE\'
LOG='/var/log/scripts/database/clear_sent_sms.log'
tmp_file=/tmp/$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 6)
declare -a TABLES=('sent_sms' 'sent_sms_retries')

touch $tmp_file

log_msg(){
    local msg=
    msg="$(date +'%Y-%m-%d %H:%I:%S') -- ${@}"
    echo "$msg" >> $tmp_file
}

flush_msgs_to_log(){
    cat $tmp_file >> $LOG
    [ -f $tmp_file ] && \
        rm -f $tmp_file
}

# Main
for table in ${TABLES[@]}; do
    SQL=$(echo "$SQL_RECORD_COUNT" | sed 's/#TABLE/'$table'/')
    RUN_CMD="echo \"$SQL\" | $DB_CMD"
    record_count=$(eval "$RUN_CMD")
    log_msg Truncating ${record_count} records found from table: $table
    SQL="$SQL_TRUNCATE$table"
    RUN_CMD="echo \"$SQL\" | $DB_CMD $DB"
    err=$(eval $RUN_CMD 2>&1)
    [ $? -eq 0 ] && \
        log_msg Truncation performed successfully. || \
        log_msg Truncation failed: $err
done

flush_msgs_to_log
# [-_-]
