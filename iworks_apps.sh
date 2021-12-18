#!/bin/sh
#/usr/bin/mdfind .numbers | grep -v "CocoaAppCD.storedata\|com.apple.\|iWork.mdimporter\|\/Library\/"

everLaunched=""
foundFiles=""
totalFiles=""

#note if modifying parameters of this script will need to properly quote or escape spaces in names e.g. Disk\ Utility.app

#echo "$thisApp was opened looking for $fileType "
for fileType in {".keynote",".numbers",".pages"}; do		
		foundFiles=$(/usr/bin/mdfind "$fileType" | grep "$fileType" | grep -v "CocoaAppCD.storedata\|com.apple.\|.swift\|.js\|node_modules\|\/git\|iWork.mdimporter\|\/pods\/\|\/Library\/\|Creative\ Cloud")
        if [ "$foundFiles" != "" ]; then
        	if [[ "$totalFiles" != "" ]]; then
        		totalFiles="$totalFiles\\n$fileType: $foundFiles"
            else
            	totalFiles="$fileType: $foundFiles"
            fi
        fi
done

for thisApp in {"Keynote.app","Numbers.app","Pages.app"}; do 
	if [ -e "/Applications/$thisApp" ]; then
		result=$(mdls "/Applications/$thisApp" | grep kMDItemLastUsedDate | grep -v _Ranking | cut -d= -f2) 
	    if [ "$result" != "" ]; then 
	    	everLaunched="$everLaunched\\n\\n$thisApp : $result"
        else
# case $thisApp in 
#	"Keynote.app" )
#	fileType=".keynote"
#	;;
#	"Numbers.app" )
#	fileType=".numbers"
#	;;
#	"Pages.app" )
#	fileType=".pages"
#	;;
# esac 

			if [ -e "/Applications/$thisApp" ] && [ "$totalFiles" = "" ]; then
    			/bin/chmod ugo-rwx /Applications/$thisApp
       			/usr/bin/chflags hidden /Applications/$thisApp
    		fi
	    fi
    fi
done

if [[ "$totalFiles" != "" ]]; then
	everLaunched="$everLaunched\\n$totalFiles"
fi


if [ "$everLaunched" != "" ]; then
	echo "<result>$everLaunched</result>"	
else
	echo "<result>NEVER</result>"
fi