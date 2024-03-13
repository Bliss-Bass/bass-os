# Bass Addon

This is an addon for Bass OS, and must be used with the private manifest found in the manifest folder. 

Please copy the .xml files found in the manifest/ folder to you Bass project folders manifests/ folder (`bass_os/manifests/`) before unpacking the source, otherwise you will need to do a manual sync of this repo into the folder it needs to be in to properly apply the changes (`bass_os/bass/patches/patchsets-addon_name`).

## Change Information:

### Addon: network_options

#### Add Default Network Options

This will let us add known internal network defaults to the OS that can be configured through kernel cmdline.

How-To:
Use the following from kernel cmdline options:
* `FORCE_WIFI_AUTO_CONNECT=*`: Force WiFi autoconnect (true|false)
* `FORCE_ADD_NETWORK=*`: Add wireless network SSID and password to system. Replace network_name with the name of your Wi-Fi network and password with its password. Once you have entered these commands, your Android device will automatically connect to the specified Wi-Fi network when it reboots (SSID=network_name,password=password)
* `FORCE_DEFAULT_SSID=*`: Set the default network SSID
* `FORCE_DEFAULT_SSID_PASSWORD=*`: Set the default network SSID Password
