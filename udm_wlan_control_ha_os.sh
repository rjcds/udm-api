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
 ${curl_cmd} $unifi_controller/logout > /dev/null
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
 response=$(${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$wifi_id" -H "${csrf}" --compressed) > /dev/null
 status=$(echo $response | jq ".data[0].enabled")
 if [ "$status" == "true" ]; then
 echo ENABLED
 unifi_logout
 exit 0
 elif [ "$status" == "false" ]; then
 echo DISABLED
 unifi_logout
 exit 1
 else
 unifi_logout
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
 unifi_logout
 exit -1
fi
unifi_logout
