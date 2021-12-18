#!/bin/bash

#credit where due adapted from Merlin's script at https://community.jamf.com/t5/jamf-pro/how-to-deploy-app/td-p/253561
#define parameters and defaults

#4 Package Name	#5 Destination (default /Applications)	#6 App Name (default PkgName.app)
#7 Followon Action	#8 Mounted Volume Name (default PackageName)	#9 Package Checksum (optional)
#10 Custom Source Path

if [ -z "${4}" ]; then			#4 Package Name 
	SRC_FILE="AppName.dmg"    
else
    SRC_FILE="${4}"
fi
# Deriving Source Name and File Type for additional actions and refining.
SRC_NAME="${SRC_FILE%.*}"
SRC_TYPE="${SRC_FILE##*.}"

if [ -z "${5}" ]; then			#5 Destination (default /Applications)
	DEST_PATH="/Applications/"
else
	DEST_PATH="${5}"
fi

if [ -z "${6}" ]; then			#6 App Name (default PkgName.app)
	APP_NAME="$SRC_NAME.app"
else
	APP_NAME="${6}.app"
fi

if [ -z "${7}" ]; then			#7 Followon Action
	EXTRA_ACTION=""
    echo "EXTRA_ACTION: none indicated"
else
	EXTRA_ACTION="${7}"
fi

if [ -z "${8}" ]; then			#8 Mounted Volume Name (default PackageName)
	VOLUME_PATH="/Volumes/$SRC_NAME"
else
	VOLUME_PATH="/Volumes/${8}"
fi

if [ -z "${9}" ]; then			#9 Package Checksum (optional)
	CHMSUM=""
else
	CHKSUM="${9}"
fi

if [ -z "${10}" ]; then			#10 Custom Source Path 
	SRC_PATH="/Library/Application Support/JAMF/Waiting Room/"
else
	SRC_PATH="${10}"
fi

# SRC_FILE="${4}"		SRC_FILE="AppName.dmg"
# DEST_PATH="${5}"		DEST_PATH="/Applications/"
# APP_NAME="${6}"		APP_NAME="$SRC_FILE"
# EXTRA_ACTION="${7}"	EXTRA_ACTION=""
# VOLUME_PATH="${8}"	VOLUME_PATH="/Volumes/$SRC_FILE"
# CHKSUM="${9}"			CHMSUM=""
# SRC_PATH="${10}"		SRC_PATH="/Library/Application Support/JAMF/Waiting Room/"

# functions

install_app() {
	echo "mounting $1"
	/usr/bin/hdiutil attach "$1" -nobrowse
    mounterr=$?
    if [[ ${mounterr} -eq 0 ]]; then
    	if [[ -e "$DEST_PATH$APP_NAME" ]]; then 
			/bin/rm -Rf "$DEST_PATH$APP_NAME"
		fi
	    /bin/cp -pPR "$VOLUME_PATH/$APP_NAME" "$DEST_PATH"
        copyerr=$?
        if [[ ${copyerr} -eq 0 ]]; then
            /bin/chmod -R 755 "$DEST_PATH/$APP_NAME"
            /usr/bin/xattr -d com.apple.quarantine "$DEST_PATH/$APP_NAME"
        else
            echo "[✗] ERROR: App failed to install. 0_o" >&2
            cleanupfiles $1
            exit 1
        fi
    else
        echo "[✗] ERROR: Volume not mounted correctly. 0_o" >&2
        cleanupfiles $1
        exit 1
    fi
    cleanupfiles $1
    echo "  [✓] App installed - All Good =o)"
}

cleanupfiles() {
	if [ -e "$VOLUME_PATH" ]; then
		/usr/bin/hdiutil detach "$VOLUME_PATH"
        unmounterr=$?
    	if [[ ${unmounterr} != 0 ]]; then
			echo "Error ${unmounterr} detaching $VOLUME_PATH"
		fi
    else
    	echo "$VOLUME_PATH does not exist"
    fi
    if [ -e "$DMG_PATH" ]; then
        echo "this is where we would clean up / delete $DMG_PATH"
	    #/bin/rm -f "$DMG_PATH"
        if [ "$SRC_PATH" == "/Library/Application Support/JAMF/Waiting Room/" ]; then 
 	        echo "this is where we would clean up / delete $DMG_PATH.cache.xml"
            #remove additional cache item in Waiting Room
            /bin/rm -f "$DMG_PATH.cache.xml"
        fi
    else
    	echo "$DMG_PATH does not exist"
    fi
}

perform_action() {	
#	CPU_MAKE=$(/usr/bin/sysctl -n machdep.cpu.brand_string | cut -d" " -f1)
#	FILE_BIN=$(/usr/bin/file "${1}" | awk -F" " '{print $NF}')
#	case "$CPU_MAKE" in
#    	Intel)	echo "/usr/bin/arch -x86_64 /bin/sh -c ${1}"
#			    action_performed=$(/usr/bin/arch -x86_64 /bin/sh -c "${1}")
#        ;;
#        Apple)  echo "/usr/bin/arch -x86_64 /bin/sh -c ${1}"
# 				 action_performed=$(/usr/bin/arch -x86_64 /bin/sh -c "${1}")
#        ;;

#    case "$FILE_BIN" in
#    	x86_64)	echo "/usr/bin/arch -x86_64 /bin/sh -c ${1}"
#			    action_performed=$(/usr/bin/arch -x86_64 /bin/sh -c "${1}")
#        ;;
#        arm64)  echo "/usr/bin/arch -x86_64 /bin/sh -c ${1}"
#			    action_performed=$(/usr/bin/arch -x86_64 /bin/sh -c "${1}")
#        ;;


	#need to add exta bits for cpu type
    #if cputype=x86
	#action_performed=$(/bin/sh -c "${1}")
    #if cputype=m1
    echo "/usr/bin/arch -x86_64 /bin/sh -c ${1}"
    action_performed=$(/usr/bin/arch -x86_64 /bin/sh -c "${1}")
}

# main

# derived variables
DMG_PATH="$SRC_PATH$SRC_FILE"
install_app "$DMG_PATH"

if [ "$EXTRA_ACTION" ]; then
	echo "performing $EXTRA_ACTION"
    perform_action "$EXTRA_ACTION"
    echo "Results of $EXTRA_ACTION = $action_performed"
fi

exit 0

# logging


