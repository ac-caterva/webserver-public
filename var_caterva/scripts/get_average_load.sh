#!/bin/sh
#
# get last minute average load from caterva
#
(rsh admin@caterva uptime) | awk -F": " '{print $2}'|awk -F"," '{print $1}'
