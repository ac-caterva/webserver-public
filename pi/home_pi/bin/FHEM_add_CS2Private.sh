#!/bin/bash
 
if [ ! -f /opt/fhem/FHEM/00_Private.cfg ]; then
    sudo touch /opt/fhem/FHEM/00_Private.cfg
    sudo chown fhem:dialout /opt/fhem/FHEM/00_Private.cfg
    sudo chmod 664 /opt/fhem/FHEM/00_Private.cfg
fi

CS_Steuerung_Zeile_FHEM="include ./FHEM/00_CS_Steuerung.cfg"

CS_InPrivtateCfg=`grep ./FHEM/00_CS_Steuerung.cfg /opt/fhem/FHEM/00_Private.cfg | wc -l`


if [ ${CS_InPrivtateCfg} = 1 ]; then
    echo "CS_Steuerung war bereits in FHEM integriert. Es gibt nichts zu tun."
else  
    sudo chmod 664 /opt/fhem/FHEM/00_Private.cfg
    echo $CS_Steuerung_Zeile_FHEM >> /opt/fhem/FHEM/00_Private.cfg

    CS_InPrivtateCfg=`grep ./FHEM/00_CS_Steuerung.cfg /opt/fhem/FHEM/00_Private.cfg | wc -l`
    if [ ${CS_InPrivtateCfg} = 1 ]; then
        echo "Restarte FHEM..."
        sudo systemctl restart fhem
        echo "CS_Steuerung wurde erfolgreich in FHEM integriert"
    else
        echo "Es gab ein Problem. Bitte wende dich an das Technik Team."  
    fi      
fi