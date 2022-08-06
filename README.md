Script to enable/disable/get status of WLAN or firewall rule on UDM/PRO via API

For a Home Assistant OS switch (where importing py libs for scripts is a lot of work)

<br><br>
Adapted from:

https://gist.github.com/alexlmiller/586f74bbef395e1a34b2dfd06541102b
https://gist.github.com/jcconnell/0ee6c9d5b25c572863e8ffa0a144e54b
https://github.com/JonGilmore/ha-personal/blob/3bcd666ce778ba53b46df894462e852453a5fc72/scripts/unifi.sh

UnifiOS requires a CSRF token for PUT/POST (but not GET); returns 404 'Not Found' without the CSRF token

https://ubntwiki.com/products/software/unifi-controller/api

<br><br>
## udm_wlan_control_ha_os
Original script - toggle wlan only

Parameters are [username] [password] [UDM address] [WLAN_ID] [enable|disable|status]

```
$ ./udm_wlan_fw_control_ha_os.sh username password https://10.0.0.1 698f5f3d05f6198705fc4v42g status
Checking WiFi status
DISABLED
```

Returns 0 <a href="https://www.home-assistant.io/integrations/switch.command_line#command_state">if enabled</a>

<br><br>
## udm_wlan_fw_control_ha_os
Updated script - toggles either wlan or a firewall rule

Using a firewall rule to block a specific network avoids the hassle of WLAN reprovisioning (transiently drops all WLANs when a specific WLAN is disabled/enabled)

Parameters are [wifi or fwrule] [username] [password] [UDM address] [WIFI_ID or FWRULE_ID] [enable|disable|status]

```
$ ./udm_wlan_fw_control_ha_os.sh fwrule username password https://10.0.0.1 56198742g098f5f3d05f5fc4v enable
Enabling firewall rule
$ ./udm_wlan_fw_control_ha_os.sh wifi username password https://10.0.0.1 698f5f3d05f6198705fc4v42g enable
Enabling WiFi
```
