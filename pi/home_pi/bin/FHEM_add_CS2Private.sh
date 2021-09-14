#!/bin/bash

CS_Steuerung_Zeile_FHEM="include ./FHEM/00_CS_Steuerung.cfg"

CS_InPrivtateCfg=`grep ./FHEM/00_CS_Steuerung.cfg /opt/fhem/FHEM/00_Private.cfg | wc -l`

if [ ${CS_InPrivtateCfg} = 1 ]; then
    echo "CS_Steuerung war bereits in FHEM integriert. Es gibt nichts zu tun."
else
    echo $CS_Steuerung_Zeile_FHEM >> /opt/fhem/FHEM/00_Private.cfg
    echo "CS_Steuerung wurde erfolgreich in FHEM integriert"
fi