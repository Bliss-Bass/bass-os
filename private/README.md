# Private Addons and Manifests

This folder is where you will place your licensed addons & manifests. Then when unfolding the OS, all manifests required will be included by default. 

You will still need to apply any addon patchsets manually after unfolding

#### Applying Licensed Addons:

If you license any addon patchsets, you will want to apply those changes before you build. To do so, make sure you have the patchsets properly synced from your private-addon-addon_name.xml and check the bass/branding/patches/ folder for your addons folder. 
Then cd into the aosptree folder, and run the following command for each addon you license, where `*addon_name*` is the name of your target addon (example: addon_hosts uses a folder name of patches-addon_hosts):
```
cd aosptree
. build/envsetup.sh
apply_addon_patches addon_name
```
In the event that any addon patchets fail, the conflict will need to be fixed before moving forward with the build. 
