#!/bin/bash


cd /var/caterva/caterva-reporting/
OUTPUT=$(pip3 install -r requirements.txt)
    
if [ $? -eq 0 ] ; then
    chmod u+x /var/caterva/caterva-reporting/collector.py
    echo "SUCCESS"
else
    echo "NO_SUCCESS"
fi
