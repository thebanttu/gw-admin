#!/bin/bash

# Monitor sqlbox db queues.

# Deploy by:
#    Running crontab -e
#    Appending the line below then saving and exiting.
#    Tweak the /2 as needed, it dictates how often the check shall run.
#    */2 * * * * bash /usr/local/scripts/gateway/admin/watchers/watch_sqlbox_queues.sh || systemctl restart sqlbox

# Please change:
#    - The database on the db variable
#    - The db config file contents to reflect the correct credentials
#    - The table names in the section named ---- Fetch Stats ----

tmp_file=/var/tmp/watcher/queues/sqlbox/q_counts
log_file=/var/log/scripts/watchers/sqlbox_queue.log

# DB Things
db=sms_gateway
db_conf=/usr/local/scripts/conf/mysql/site_db.cnf
db_options="--defaults-extra-file=$db_conf"
db_exec="mysql $db_options"
dbchk="mysqladmin $db_options ping"

check_log_dir()
{
    [ ! -d ${log_file%/*} ] && {
        mkdir -p ${log_file%/*}
        [ $? -ne 0 ] && {
            echo Something nasty happened >&2
            return 2
        }
        return
    }
}

check_tmp_dir()
{
    [ ! -d ${tmp_file%/*} ] && {
        mkdir -p ${tmp_file%/*}
        [ $? -ne 0 ] && {
            echo Something nasty happened >&2
            return 2
        }
        return
    }
}

check_tmp_dir
check_log_dir

# -------------------------------------------   Fetch Stats   -------------------------------------------
eval "$dbchk" >& /dev/null
[ $? -eq 0 ] && {
    awk 'END{print strftime("%Y-%m-%d %H:%M:%S"), "-- Mysql check OK." >> '\"$log_file\"'}' /dev/null
    output=$(echo '
        select 
            concat(
              (select ifnull(min(sql_id),0) from '$db'.send_sms), ":",
              (select count(*) from '$db'.send_sms)
            ) as send_sms,
            concat(
              (select ifnull(min(sql_id),0) from '$db'.resend_sms), ":",
              (select count(*) from '$db'.resend_sms)
            ) as resend_sms
        \G' | $db_exec | sed 1d | tr -d '[\t ]' 2>&1
	)
    ext=0
} || {
	echo DB Access denied. >&2
	awk 'END{print strftime("%Y-%m-%d %H:%M:%S"), "-- Mysql check NOK." >> '\"$log_file\"'}' /dev/null
	ext=2
}

# -------------------------------------------------------------------------------------------------------

# Debug.
# echo "$output" >&2

# -------------------------------------------   Perform Checks   -------------------------------------------
[ $ext -eq 0 ] && [ -e $tmp_file ] && {
    awk 'END{print strftime("%Y-%m-%d %H:%M:%S"), "-- tmp file check OK." >> '\"$log_file\"'}' /dev/null
    awk '
    BEGIN {
        # Load lines from last run for comparison.
        while ( (getline < '\"$tmp_file\"') > 0 ) {
            ++array_size
            saved_output[array_size] = $0
        }
        # Flag to use to test id.
        shida_flag = 0
        shida_box = ""
    }
    {
        current_output[1] = $0
        for (i=2; i<=array_size; i++) {
            getline
            current_output[i] = $0
        }
    }
    END {
        for (i=1; i <= array_size; i++) {
            split(saved_output[i], box_line, ":")
            split(current_output[i], box_line_curr, ":")
            if (box_line[2] == box_line_curr[2] && (box_line[2] + box_line_curr[2]) != 0) {
                shida_flag = 1
                shida_box = box_line[1]
                break
            }
        }
        if (shida_flag == 0) {
            print strftime("%Y-%m-%d %H:%M:%S"), "-- OK" >> '\"$log_file\"'
            exit 0
        }
        else {
            print strftime("%Y-%m-%d %H:%M:%S"), "-- NOK", shida_box, "Q:" box_line_curr[3] >> '\"$log_file\"'
            exit 1
        }
    } ' <<< "$output"
    ext=$?
    truncate -s 0 "$tmp_file"
} || {
    awk 'END{print strftime("%Y-%m-%d %H:%M:%S"), "-- tmp file check NOK." >> '\"$log_file\"'}' /dev/null
    echo "$tmp_file" does not exist, yet. >&2
    ext=3
}
# ----------------------------------------------------------------------------------------------------------

# Dump current run's output into the file.
echo "$output" > "$tmp_file"
exit $ext
