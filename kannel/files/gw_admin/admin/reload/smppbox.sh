#!/bin/bash

output=
cd /root/gw_admin
. gw

box_send_signal_all smppbox HUP

