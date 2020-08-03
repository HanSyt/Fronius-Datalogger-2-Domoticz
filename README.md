# Fronius-Datalogger-2-Domoticz
<i>Reads data from the Fronius Datalgger API and sends it to Domoticz</i>

If you have an older Fronius Converter like I have (IG/TL4.0) you could buy a datalogger unit. It is possible to read this info into a variable.

Create 3 virtual devices in Domoiticz, 1x Energy, 2x custom percentage</br>
Note their indexes and set them in datalogger.sh</br>
idxE_PAC="268"   # this is the Energy device, records the energy that is send to the grid</br>
idxE_DAY="269"   # Custom percentage, records the dail energy send to the grid</br>
idxE_YEAR="270"  # Custom percentage, records the yearly energy send to the grid</br>
dataloggerip="192.168.2.12" # The IP address of your datalogger</br>

Basicly thats all Folks</br>

Since my python knowledge is not to good and made the script in simple bash, this is wat is does:

read the datalogger</br>
```RESULT="`wget -qO- http://$dataloggerip/solar_api/GetInverterRealtimeData.cgi?Scope=System`"```

Split the data until keyword PAC and read the 12th element</br>
```E_PAC=`echo ${RESULT#*PAC} | awk '{print $12}'```
</br>
At night no energy is generated, the value you read wil be :, so E_PAC is 0, see the main script</br>
This repeats itself 3 times until the yearly energy is measured</r>
</br>
Send data to Domoticz</br>
```curl --data "type=command&param=udevice&idx=$idxE_PAC&nvalue=0&svalue=$E_PAC" http://$domoticzserverip/json.htm```

I personally like to run the script from crontab to run every minute:</br>
```crontab -e```

send it to the null device otherwise you mail system might get an email every minute</br>
```*/1 * * * * /home/pi/datalogger.sh > /dev/null 2>&1```

