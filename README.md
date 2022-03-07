Script to enable/disable/get status of WLAN for UDM/PRO

For a Home Assistant OS switch (where importing py libs for scripts is a lot of work)


Adapted from:

https://gist.github.com/alexlmiller/586f74bbef395e1a34b2dfd06541102b
https://gist.github.com/jcconnell/0ee6c9d5b25c572863e8ffa0a144e54b
https://github.com/JonGilmore/ha-personal/blob/3bcd666ce778ba53b46df894462e852453a5fc72/scripts/unifi.sh

UnifiOS requires a CSRF token for PUT/POST (but not GET); returns 404 'Not Found' without the CSRF token

https://ubntwiki.com/products/software/unifi-controller/api
