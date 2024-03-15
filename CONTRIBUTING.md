# Contributing to Bass OS

We are not going to require any elitist rules for you to contribute to the project. That's just silly. So this doc will cover the various parts of the project and explain how to do things. 

## General Development

This project contains many scripts and tools that help aid the support, feature selection, and option customization for Bass OS. Most of those scripts use bash and can also interface with the easy-menu-system we include. 

## Addon Development

We can start with addon development as that will give you a good concept of how things are put together. 

Let's say that you have a change that you want to add to Bass OS, but that change can be used on many devices, so you don't want to keep it as a private change that is never shared outside this single devices source. This is where Addons come into play. 

Addons can consist of one or more of the following:

* Patchsets - Single or multiple sets of patches that are to be applied on-top of the source when unfolding the OS. 
* Prebuilt APK's - An example of this is the Restricted Launcher Pro. We offer the free version of the prebuilt for all to include, but it contains branding that cannot be changed. But we offer the Pro version that can be rebranded and further customized as an addon.
* Package/External Sources - An example of this is our Kiosk Launcher, as that requires the private source to be included in the OS in order to use it. 
* Script Addon - An automation script that does something or helps automate any point in the build process. 

### Patchset Addon Development

The first example we will go over is for a patchsett based addon. For this, you will use a patches folder with a name following the addon_name. Along with a manifest .xml that links your addon as a .git. This will allow you to have a private repo as an addon and control access to it if needed. 

#### Example patchset addon

We have an example patchset addon for a change that can be found in `/bigblissdrive03/bass-wg01/assets/examples/addon_templates/patchsets-network_options`. Take a look at the README.md for that to get a good idea of the info we include as a starting point. 

#### Where things go

When syncing the Bass OS project, you will want to place the patchset addon folder (`patchsets-addon_name`) in the `private/addons/` folder. This location will be searched when the project is unfolded, and any manifest file found will be synced in the unfolding process. After sync is complete, any patches that are required for the addon will be automatically applied. 

##### Manifest 

The manifest file should point to the path: `vendor/bass/patches/patchsets-addon_name`. You should also name the manifest file the unique name of your addon. The remote name defined within the manifest .xml should also be unique to your addon. 

##### Patchset

The patchset should be organized in multiple folders within the `addon_name` folder of your addon. 

Example:
- patchsets_addon_name
- README.md
	- manifest
		- private-addon_name.xml
	- addon_name
		- device
			- generic
				- common
					- 0001-change_name-1-of-3.patch
		- bootable
			- newinstaller
				- 0001-change_name-2-of-3.patch
			- recovery
				- 0001-change_name-3-of-3.patch


