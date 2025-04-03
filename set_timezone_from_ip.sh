#!/bin/zsh
# Do these work anymore to allow users to change time zone:

# security authorizationdb write system.preferences allow
# security authorizationdb write system.preferences.datetime allow
# I use this is as a Self Service script in my Jamf Pro environment (not my original script, adapted):

SS=/usr/sbin/systemsetup
CL=/usr/bin/curl
EG=/usr/bin/egrep

IPURL="http://checkip.dyndns.org"
TZURL="http://ip-api.com/line/"

myIP=$(${CL} -L -s --max-time 10 ${IPURL} | ${EG} -o -m 1 '([[:digit:]]{1,3}.){3}[[:digit:]]{1,3}')

timeZone=$(${CL} -L -s --max-time 10 "${TZURL}${myIP}?fields=timezone")

echo "running ${SS} -settimezone ${timeZone} for ${myIP}"
${SS} -settimezone $timeZone
