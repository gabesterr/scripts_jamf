#!/bin/sh
#/usr/bin/mdfind .numbers | grep -v "CocoaAppCD.storedata\|com.apple.\|iWork.mdimporter\|\/Library\/"

appFound=""
expectedFiles="DS_Store\|ds_store\|localized\|Aircall.app\|Callbar.app\|GarageBand.app\|Google\ Chrome.app\|Install\ macOS\|Keynote.app\|Numbers.app\|Pages.app\|Safari.app\|Shift\ Apps.app\|Slack.app\|Sophos\|TextExpander.app\|Utilities\|Wallpaper\|iMovie.app\|zoom.us.app"

#-1 (number 1 forces ls to print single line per entry, tr converts line breaks to comma)
foundFiles=$(ls -1 /Applications/ | grep -v "$expectedFiles" | tr "\n" ",")
#set internal field seperator to comma
IFS=',' read -r -a arrayFiles <<< "$foundFiles"
for thisApp in "${arrayFiles[@]}"; do 
	if [[ "$thisApp" != "" ]]; then
		if [[ "$appFound" = "" ]]; then
    		appFound="$thisApp"
		else
        	appFound="$appFound\\n$thisApp"
        fi
	fi
done

if [[ "$appFound" = "Microsoft Excel.app\\nMicrosoft PowerPoint.app\\nMicrosoft Word.app" ]]; then
	appFound="MSONLY"
fi
if [[ "$appFound" = ".DS_Store\\nMicrosoft Excel.app\\nMicrosoft PowerPoint.app\\nMicrosoft Word.app" ]]; then
	appFound="MSONLY"
fi


if [ "$appFound" != "" ]; then
	echo "<result>$appFound</result>"	
else
	echo "<result>ONLY EXPECTED APPS</result>"
fi

