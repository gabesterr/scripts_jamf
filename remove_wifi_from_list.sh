#!/bin/bash

userName=$(/usr/bin/stat -f%Su /dev/console)
donotremoveList="corpwifi\|hotspotwifi"		#prevent users from deleting certain SSID names

if [ "$userName" == "$3" ]; then
	echo "username match $userName"
else
	echo "username mismatch, using $userName"
fi

if [ -z "${4}" ]; then			#4 Name can be supplied as parameter to Jamf Pro policy script payload
	ssid_text=$(/usr/sbin/networksetup -listpreferredwirelessnetworks en0 | /usr/bin/grep -v "Preferred networks on" | /usr/bin/tr  -d "\t")
	#echo "$ssid_text
	theResult=$(/usr/bin/osascript <<EOF
set {dlm, my text item delimiters} to {my text item delimiters, linefeed}
set wifi_list to text items of "$ssid_text"
set my text item delimiters to dlm
set deleteSSID to choose from list wifi_list with prompt "Select the SSID to remove:"
EOF
)
else
	# get here if parameter defined in jamf policy script payload
    theResult="${4}"
fi

if [ ! $(echo $theResult | tr '[:upper:]' '[:lower:]' | grep -v "${donotremoveList}") ]; then 
  echo "DETECTED REQUIRED WIFI!! Will not remove ${theResult}"
  exit 1
else        
  echo "removing SSID $theResult"
  deleteOutcome=$(/usr/sbin/networksetup -removepreferredwirelessnetwork en0 "$theResult")
  ssid_text=$(/usr/sbin/networksetup -listpreferredwirelessnetworks en0 | /usr/bin/grep -v "Preferred networks on" | /usr/bin/tr  -d "\t")
  if [ ! $(echo $theResult | tr '[:upper:]' '[:lower:]' | grep "${theResult}") ]; then 
    echo "removed SSID $theResult"
  else
    echo "error removing $theResult still in $ssid_text"
  fi
fi
