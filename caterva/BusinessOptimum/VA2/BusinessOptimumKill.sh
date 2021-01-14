#!/bin/bash 
### BEGIN INFO
# Provides: Kill for Process BusinessOptimum
# Siegfried Quinger - 2021-01-03_19:00
### END INFO

p=$(pidof -x BusinessOptimum.sh)
sudo kill -15 $p
# removes file noPVBuffering, -> charging/discharging possible for normal operation w/o BusinessOptimum
rm -f /home/admin/registry/noPVBuffering

# set back to normal operations, - needed when interrupted during forced charging, module balancing or grid operation
swarmBcSend "CPOL1.Wchrg.setMag.f=0" > /dev/null
swarmBcSend "CPOL1.OffsetDuration.setVal=1422692866" > /dev/null
swarmBcSend "CPOL1.OffsetStart.setVal=0" > /dev/null


# special remove sequence when switsching from one to the other BusinessOptimum version (w/o sudo)
sudo rm -f /tmp/BusinessOptimum.tmp
sudo rm -f /tmp/balanceBatteryModules.tmp
sudo rm -f /tmp/swarm-battery-cmd.tmp
sudo rm -f /tmp/swarm-battery-cmd_tail.tmp
sudo rm -f /tmp/BusinessOptimum_config.tmp
sudo rm -f /tmp/BusinessOptimum_config_tail.tmp
sudo rm -f /tmp/BusinessOptimum.config
sudo rm -f /var/log/ModuleBalancing		
sudo rm -f /var/log/CellBalancing
sudo rm -f /var/log/ChargedFlag


