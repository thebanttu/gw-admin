#!/bin/bash

. /root/gw_admin/box_admin

__infect_bashrc
[ $? -eq 0 ] && echo 'Success! .bashrc infected.' || echo 'No joy, .bashrc was immune :('
