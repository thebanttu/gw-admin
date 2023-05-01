#!/bin/bash

. /root/gw_admin/gw

output=

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

equitel_proxy=${GW_CONF%/*}/smppboxes/smppbox.conf

output=$(startsmppbox $equitel_proxy 2>&1)
process_return $? 0 "$output"

