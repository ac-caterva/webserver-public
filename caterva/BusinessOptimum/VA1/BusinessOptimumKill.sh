#!/bin/bash 
### BEGIN INFO
# Provides: Kill for Process BusinessOptimum
# Siegfried Quinger - 2021-01-17_19:00
### END INFO

p=$(pidof -x BusinessOptimum.sh)
kill -9 $p

# removes file noPVBuffering, -> charging/discharging possible for normal operation w/o BusinessOptimum
rm -f /home/admin/registry/noPVBuffering

# Remove status files of different functions of BusinessOptimum
rm -f /tmp/ChargedFlag
rm -f /tmp/BusinessOptimumStop
rm -f /tmp/BusinessOptimumActive
rm -f /tmp/ModuleBalancingActive
rm -f /tmp/CellBalancing
rm -f /tmp/CellBalancingActive
rm -f /tmp/ForcedChargingActive
# Remove request files of ModuleBalancing of BusinessOptimum
rm -f /var/log/ModuleBalancing

# set back to normal operations, - needed when interrupted during forced charging, module balancing or grid operation
swarmBcSend "CPOL1.Wchrg.setMag.f=0" > /dev/null
swarmBcSend "CPOL1.OffsetDuration.setVal=1422692866" > /dev/null
swarmBcSend "CPOL1.OffsetStart.setVal=0" > /dev/null



#######################################################################################################
# will be deleted end of February when all those files - if once used - have been deleted
sudo rm -f /var/log/BusinessOptimumStop
sudo rm -f /var/log/BusinessOptimumActive
sudo rm -f /var/log/ModuleBalancingActive
sudo rm -f /var/log/CellBalancing
sudo rm -f /var/log/CellBalancingActive
sudo rm -f /var/log/ForcedChargingActive
sudo rm -f /tmp/BusinessOptimum.tmp
sudo rm -f /tmp/balanceBatteryModules.tmp
sudo rm -f /tmp/swarm-battery-cmd.tmp
sudo rm -f /tmp/swarm-battery-cmd_tail.tmp
sudo rm -f /tmp/BusinessOptimum_config.tmp
sudo rm -f /tmp/BusinessOptimum_config_tail.tmp
sudo rm -f /tmp/BusinessOptimum.config
sudo rm -f /var/log/ModuleBalancing		
sudo rm -f /var/log/CellBalancing
