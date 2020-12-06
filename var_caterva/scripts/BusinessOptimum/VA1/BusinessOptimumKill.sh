#!/bin/bash
### BEGIN INFO
# Provides: Kill for Process BusinessOptimum
# Siegfried Quinger - 2020-11-26_22:00
### END INFO

p=$(pidof -x BusinessOptimum.sh)
sudo kill -15 $p
# removes file noPVBuffering, -> charging/discharging possible for normal operation w/o BusinessOptimum
rm -f /home/admin/registry/noPVBuffering