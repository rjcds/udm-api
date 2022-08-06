#!/bin/bash

unifi_username=$2
unifi_password=$3
unifi_controller=$4
id=$5
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
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$id" -X PUT -d '{"_id":"'"$id"'","enabled":true}' -H "${csrf}" --compressed > /dev/null
}

disable_wifi() {
 # disables guest wifi network
 # Mute response by adding > /dev/null
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$id" -X PUT -d '{"_id":"'"$id"'","enabled":false}' -H "${csrf}" --compressed > /dev/null
}

check_status_wifi() {
 # checks wifi network status
 # Mute response by adding > /dev/null
 response=$(${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/wlanconf/'"$id" -H "${csrf}" --compressed) > /dev/null
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
   exit -1
 fi
}

enable_fwrule() {
 # enables a firewall rule
 # Mute response by adding > /dev/null
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/firewallrule/'"$id" -X PUT -d '{"_id":"'"$id"'","enabled":true}' -H "${csrf}" --compressed > /dev/null
}

disable_fwrule() {
 # disables a firewall rule
 # Mute response by adding > /dev/null
 ${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/firewallrule/'"$id" -X PUT -d '{"_id":"'"$id"'","enabled":false}' -H "${csrf}" --compressed > /dev/null
}

check_status_fwrule() {
 # checks firewall rule status
 # Mute response by adding > /dev/null
 response=$(${curl_cmd} "$unifi_controller"'/proxy/network/api/s/default/rest/firewallrule/'"$id" -H "${csrf}" --compressed) > /dev/null
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
   exit -1
 fi
}


if [[ $# < 6 ]]; then
    echo "Must include command line parameters [wifi or fwrule] [username] [password] [UDM address eg https://10.0.0.1] [WIFI_ID or FWRULE_ID] [enable|disable|status]."
    exit -1
fi

unifi_login

case $1 in
  wifi)
    case $6 in
      "enable") 
        echo "Enabling WiFi"
        enable_wifi ;;
      "disable") 
        echo "Disabling WiFi"
        disable_wifi ;;
      "status") 
        echo "Checking WiFi status"
        check_status_wifi ;;
      *) 
        echo $1 "; last parameter must be enable, disable or status"
        unifi_logout
        exit -1 ;;
    esac ;;
  fwrule)
    case $6 in
      "enable") 
        echo "Enabling firewall rule"
        enable_fwrule ;;
      "disable") 
        echo "Disabling firewall rule"
        disable_fwrule ;;
      "status") 
        echo "Checking firewall rule status"
        check_status_fwrule ;;
      *) 
        echo $1 "; last parameter must be enable, disable or status"
        unifi_logout
        exit -1 ;;
    esac ;;
esac

unifi_logout