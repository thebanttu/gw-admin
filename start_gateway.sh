#!/bin/bash

output=
cd /root/gw_admin
. gw

output=$(startbbox 2>&1)
process_return $? 3 "$output"
output=$(startsmsbox 2>&1)
process_return $? 1 "$output"
output=$(startsqlbox 2>&1)
process_return $? 1 "$output"
output=$(startsqlbox resend 2>&1)

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
	else
		echo "$output" >&2
		exit 2
	fi
}
