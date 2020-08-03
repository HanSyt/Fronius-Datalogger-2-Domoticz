#!/bin/bash
# v.0.0.2
# Jul 28, 2020 Han Sytsma
# reads fronius datalogger info and sends it to domoticz
# runs from crontab */5 * * * * /pathto/test > /dev/null 2>&1
#
# Definitions, adapt for your system
domoticzserverip="192.168.2.8:8080"
# indexes domoticz devices (1x energy, 2x custom percentage)
idxE_PAC="268"
idxE_DAY="269"
idxE_YEAR="270"
dataloggerip="192.168.2.12"

# Split and calculate values
# =============================================================================================================
# Retrieve data from Fronius Datalogger (IG/TL 4.0)
RESULT="`wget -qO- http://$dataloggerip/solar_api/GetInverterRealtimeData.cgi?Scope=System`"
#
# Split data into results by cutting the beginning of the string until the keyword and read the 12th element
# Current energy to the grid (W)
E_PAC=`echo ${RESULT#*PAC} | awk '{print $12}'`
# E_PAC can be empty if no delivery, reads wrong element (:), so E_PAC needs to be zero
if [ "$E_PAC" = ":" ];then
   E_PAC="0"
fi
#
# Day Cumulative energy (Wh)
E_DAY=`echo ${RESULT#*DAY_ENERGY} | awk '{print $12}'`
# E_DAY can be empty if no delivery, reads wrong element (:), so E_DAY needs to be zero
if [ "$E_DAY" = ":" ];then
   E_DAY="0"
fi
#
# Yearly Cumulative energy (Wh)
E_YEAR=`echo ${RESULT#*YEAR_ENERGY} | awk '{print $12}'`
# Total energy of the Fronius system
E_TOTAL=`echo ${RESULT#*TOTAL_ENERGY} | awk '{print $12}'`

#echo $E_DAY # Debug info
# ==============================================================================================================
# Sent data to Domoticz
curl --data "type=command&param=udevice&idx=$idxE_PAC&nvalue=0&svalue=$E_PAC" http://$domoticzserverip/json.htm
curl --data "type=command&param=udevice&idx=$idxE_DAY&nvalue=0&svalue=$E_DAY" http://$domoticzserverip/json.htm
curl --data "type=command&param=udevice&idx=$idxE_YEAR&nvalue=0&svalue=$E_YEAR" http://$domoticzserverip/json.htm
