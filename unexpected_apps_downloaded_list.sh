#!/bin/sh
# freely re-use and adapt so long as you give credit due here to https://github.com/gabesterr
# this script is basis for extension attribute detecting unexpected apps in /Applications

expectedFiles=/tmp/expected_apps.csv
listFiles=/tmp/applist.txt
appFound=""

# remove previous expected list if present
if [ -f ${expectedFiles} ]; then 
	/bin/rm ${expectedFiles};
fi

# get expected list 
tmpExpectedAppsFile=$(curl -L -C - "https://docs.google.com/spreadsheets/d/1uJuK_PWNaSB0fKtexE472goEwIf7W_EsCFkcBbqBM2g/export?exportFormat=csv" -o $expectedFiles)
parseFile=$(/usr/bin/sed -i '' 's'/$(printf "\x0d\x0a")'/'$(printf "\x0a")'/g' $expectedFiles)
# then remove the line endings (was getting x0dx0a vs x0a on ls -1 output below)
# xxd $expectedFiles # checking to ensure the downloaded line endings match ls -1 line endings
tmpAppList=$(/bin/ls -1 /Applications > ${listFiles})

# clever filter for unique items from $listFiles
appFound=$(cat ${listFiles} ${expectedFiles} ${expectedFiles} | sort | uniq -u | grep -v "localized") 

RESULT=$(echo "${appFound}")

if [ "$appFound" != "" ]; then
	printf "<result>${RESULT}</result>"	
else
	echo "<result>ONLY EXPECTED APPS</result>"
fi
