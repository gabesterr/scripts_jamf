#!/bin/sh

CRASHCOUNT=$(ls -1 /Library/Logs/DiagnosticReports | grep crash | wc | awk -F ' ' '{print $1}')

if [ $CRASHCOUNT ]; then
	echo "<result>$CRASHCOUNT</result>"	
else
	echo "<result>NO CRASHES RECORDED</result>"
fi
