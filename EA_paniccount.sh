#!/bin/sh

PANICCOUNT=$(ls -1 /Library/Logs/DiagnosticReports | grep panic | wc | awk -F ' ' '{print $1}')

if [ $PANICCOUNT ]; then
	echo "<result>$PANICCOUNT</result>"	
else
	echo "<result>NO PANICS RECORDED</result>"
fi
