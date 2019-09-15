#!/bin/bash

output=
cd /root/gw_admin
. gw

box_send_signal bearerbox HUP
