# Fronius-Datalogger-2-Domoticz
Reads data from the Fronius Datalgger API and sends it to Domoticz

If you have an older Fronius Converter like I have (IG/TL4.0) you could buy a datalogger unit. It is possible to read this info into a variable.

Create 3 virtual devices in Domoiticz, 1x Energy, 2x custom percentage
Note their indexes and set them in datalogger.sh
idxE_PAC="268"   # this is the Energy device, records the energy that is send to the grid
idxE_DAY="269"   # Custom percentage, records the dail energy send to the grid
idxE_YEAR="270"  # Custom percentage, recotrds the yearly energy send to the grid
dataloggerip="192.168.2.12" # The IP address of your datalogger

Basicly thats all Folks

Since my python knowledge is not to good and made the scrip in simple bash, this is wat is does:
# read the datalogger
- RESULT="`wget -qO- http://$dataloggerip/solar_api/GetInverterRealtimeData.cgi?Scope=System`"

# Split the data until keyword PAC and read the 12th element
- E_PAC=`echo ${RESULT#*PAC} | awk '{print $12}'`
# at night no energy is generated, the value you read wil be :, so E_PAC is 0

This repeats itself 3 times until the yearly energy is measured

# Send data to Domoticz
- curl --data "type=command&param=udevice&idx=$idxE_PAC&nvalue=0&svalue=$E_PAC" http://$domoticzserverip/json.htm

I personally put the script in crontab to run every minute:
crontab -e

# send it to the null device otherwise you mail system might get an email every minute
*/1 * * * * /home/pi/datalogger.sh > /dev/null 2>&1

