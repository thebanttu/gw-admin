#!/bin/bash

. /root/gw_admin/gw

output= pidfiles=

process_return()
{
	local ret= intv= output=
	help="Usage: ${FUNCNAME[0]} return_status sleep_interval \"output\""
	[[ $# -ne 3 ]] && {
		echo $help >&2
		exit 2
	} || {
		ret=$1
		intv=$2
		output="$3"
	}
	if [[ $ret -eq 0 ]]
	then
		sleep $intv
        pidfiles="${pidfiles}${output} "
	else
		echo "$output" >&2
		exit 2
	fi
}

output=$(startsqlbox sendsms 2>&1 | sed 1d)
process_return $? 0.2 "$output"
output=$(startsqlbox inbound 2>&1 | sed 1d)
process_return $? 0 "$output"

pidfiles=$(sed 's/.$//' <<< "$pidfiles")

while true
do
    for pid in "$pidfiles"
    do
        kill -0 $(cat $pid 2>/dev/null) 2>/dev/null
        [ $? -ne 0 ] && break 2
    done
    sleep 10
done

exit 11
