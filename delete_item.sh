#!/usr/bin/env bash
# scriptversion: 1.2
AGENT1="YOURAGENTHERE"
AGENT2="YOURAGENTHERE"
exclusionList="jamf\|$AGENT1\|$AGENT2"

if [ -z "${5}" ]; then			#4 Name 
	ACTION="deleted"
else
	ACTION="${5}"
fi

userName=$(/usr/bin/stat -f%Su /dev/console)
brandingFile="/Users/$userName/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"
dialogContent="get text returned of (display dialog \"Drag and drop item to be deleted into the text field below until it is highlighted in blue. Or two-finger click on the item then hold the option key to select Copy ITEM NAME HERE as Pathname.\" default answer \"\" with icon POSIX file \"$brandingFile\" buttons {\"Cancel\", \"Delete\"} default button \"Delete\")"

if [ "$userName" == "$3" ]; then
	echo "username match $userName"
else
	echo "username mismatch, using $userName"
fi

if [ -z "${4}" ]; then			#4 Name 
# 	 APPTODELETE="/Applications/zoom.us.app"    
	# get, log, and determine target content OK
    set -o pipefail -e
	TARGETCONTENT=$(/usr/bin/osascript -e "${dialogContent}")
    echo "user $userName attempting to delete $TARGETCONTENT" 
    if [ ! $(echo "${TARGETCONTENT}" | tr '[:upper:]' '[:lower:]' | grep -v "${exclusionList}") ]; then 
    	echo "DETECTED PROHIBITED PATH!! Will not delete ${TARGETCONTENT}"
        exit 1
    else 
    	# if target OK set to be deleted
        if [[ "${TARGETCONTENT}" == *"/"* ]]; then 
			ITEMTODELETE="${TARGETCONTENT}" 
        else
        	echo "${TARGETCONTENT} does not contain a path, trying /Applications"
			ITEMTODELETE="/Applications/${TARGETCONTENT}" 
	        if [ -e "${ITEMTODELETE}" ]; then 
	        	echo "${ITEMTODELETE} exists"
			else
	        	echo "${ITEMTODELETE} does not exist... checking app"
				if [[ "${ITEMTODELETE}" == *".app" ]]; then
		        	echo "${ITEMTODELETE} already has .app in path... giving up"                
                else
                	ITEMTODELETE="${ITEMTODELETE}.app"
                fi
			fi
		fi
    fi
else
	# get here if parameter defined in jamf policy script payload
    ITEMTODELETE="${4}"
fi

# test and delete folder
#[ -d "${ITEMTODELETE}" ] && rm -rf "${ITEMTODELETE}"

if [ -e "${ITEMTODELETE}" ]; then 
	rm -rf "${ITEMTODELETE}"
    echo "Deleted ${ITEMTODELETE} with result $?"
else
	echo "NOT FOUND: ${ITEMTODELETE}"
fi
