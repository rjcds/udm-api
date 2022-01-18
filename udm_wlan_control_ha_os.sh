# script to enable/disable/get status of WLAN for UDM/PRO
# for a Home Assistant OS switch (where importing py libs for scripts is a lot of work)
# 
# https://gist.github.com/alexlmiller/586f74bbef395e1a34b2dfd06541102b
# https://gist.github.com/jcconnell/0ee6c9d5b25c572863e8ffa0a144e54b
# https://github.com/JonGilmore/ha-personal/blob/3bcd666ce778ba53b46df894462e852453a5fc72/scripts/unifi.sh
#
# UnifiOS requires a CSRF token for PUT/POST (but not GET); returns 404 'Not Found' without the CSRF token
#
# https://ubntwiki.com/products/software/unifi-controller/api


#!/bin/bash

unifi_username=$1
unifi_password=$2
unifi_controller=$3
wifi_id=$4
cookie=$(mktemp)
headers=$(mktemp)


curl_cmd="curl -s -S --cookie ${cookie} --cookie-jar ${cookie} --insecure "

unifi_login() {
 # authenticate against unifi controller
 # Mute response by adding > /dev/null
 ${curl_cmd} -H "Content-Type: application/json" -D ${headers} -d "{\"password\":\"$unifi_password\",\"username\":\"$unifi_username\"}" $unifi_controller/api/auth/login > /dev/null
 # UDM/P ?v1.11.0 - header returns 'x-csrf-token', which requires a case-insensitive awk
 csrf="$(awk -v IGNORECASE=1 -v FS=': ' '/^X-CSRF-Token/' "${headers}" | tr -d '\r')"
}

unifi_logout() {
 # logout
 ${curl_cmd} $unifi_controller/logout
}

enable_wifi() {
 # enables guest wifi network
 # Mute response by adding > /dev/null
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$wifi_id" -X PUT -d '{"_id":"'"$wifi_id"'","enabled":true}' -H "${csrf}" --compressed > /dev/null
}

disable_wifi() {
 # enables guest wifi network
 # Mute response by adding > /dev/null
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$wifi_id" -X PUT -d '{"_id":"'"$wifi_id"'","enabled":false}' -H "${csrf}" --compressed > /dev/null
}

check_status() {
 # checks wifi network status
 # Mute response by adding > /dev/null
 response=$(${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$wifi_id" -H "${csrf}" --compressed)
 status=$(echo $response | jq ".data[0].enabled")
 if [ "$status" == "true" ]; then
 echo ENABLED
 exit 0
 elif [ "$status" == "false" ]; then
 echo DISABLED
 exit 1
 else
 echo exit -1
 fi
}


if [[ $# < 5 ]]; then
    echo "Must include command line parameters [username] [password] [UDM address https://10.0.0.1] [WLAN_ID] [enable|disable|status]."
    exit -1
fi

unifi_login
if [ "$5" == "enable" ]; then
 echo "Enabling WiFi."
 enable_wifi
elif [ "$5" == "disable" ]; then
 echo "Disabling WiFi."
 disable_wifi
elif [ "$5" == "status" ]; then
 check_status
else
 echo "Must include command line parameters [username] [password] [UDM address https://10.0.0.1] [WLAN_ID] [enable|disable|status]."
 exit -1
fi
unifi_logout
