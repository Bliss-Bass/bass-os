# Bass OS - Android 12L

[![License](https://img.shields.io/badge/license-GPL-blue)](https://opensource.org/licenses/gpl-3-0/)

This repository contains platform patches and manifest for Bass OS on top of [Bliss OS](https://github.com/BlissRoms-x86).

Please refer to https://bliss-bass.blisscolabs.dev for release notes, hardware requirements and demos of the various options.

## Licensing

Much of Bass OS is published under the General Public License 3.0. All generic patches are regularly submitted to [Bliss OS](https://github.com/BlissRoms-x86) where they can be obtained under the Apache License.

Bass OS does have a number of options, features, applications, etc. that can be accessed through purchasing licensing for the private addons, features and tools. [See our licensing page](https://bliss-bass.blisscolabs.dev/licensing.html) for full details

## Warning!

Bass OS is an open-source initiative maintained by Bliss Co-Labs. It is provided "as is" without any warranties or guarantees.

## Building from sources

Before building, ensure your system has at least 16 CPU cores, 32GB of RAM, a swap file is at least 16GB, and 500GB-700GB of free disk space available.

### Install system packages
(Ubuntu 22.04 LTS is only supported. Building on other distributions can be done using docker)
<br/>

- [Install AOSP required packages](https://source.android.com/setup/build/initializing).
```bash
sudo apt-get install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip squashfs-tools python3-mako libssl-dev ninja-build lunzip syslinux syslinux-utils gettext genisoimage gettext bc xorriso xmlstarlet meson glslang-tools git-lfs libncurses5 libncurses5:i386 libelf-dev aapt zstd rdfind nasm rustc bindgen
```

<br/>

- Install additional packages
```bash
sudo apt-get install -y swig device-tree-compiler mtools libgmp-dev libmpc-dev cpio rsync dosfstools kmod gdisk lz4 cmake libglib2.0-dev
```

<br/>

- Install additional packages (for building mesa3d, libcamera, and other meson-based components)
```bash
sudo apt-get install -y python3-pip pkg-config python3-dev ninja-build
sudo pip3 install mako jinja2 ply pyyaml pyelftools
```

- Install the `repo` tool
```bash
sudo apt-get install -y python-is-python3 wget
wget -P ~/bin http://commondatastorage.googleapis.com/git-repo-downloads/repo
chmod a+x ~/bin/repo
```

### Fetching the sources and building the project

```bash
git clone --recurse-submodules https://github.com/Bliss-Bass/bass-os.git bass-os-12.1
cd bass-os-12.1
```

### Setting up Bass OS Source

#####!!NOTICE FOR LICENSED ADDONS/FEATURES!!
If you hold an active license for any of the private addons and features for Bass OS, you will need to add the files that you were sent or given acces to, into the `private/addons` or `private/manifests` folder. If your project requires any vendor patches, those are placed in the `patches-vendor/` folder. Once all items are placed properly, you can continue onto the unfolding steps. Please also check your organizations Bass-OS project folder to make sure it didn't come with those additions already added. 

#### Unfolding the source

Bass source uses an unfolding sequence to grab the latest stable point in development for the source, then applies any required changes on top, along with any customizations, licensed addons, modules, etc. 

To start the unfolding process, we use the unfold_bliss.sh script:

```bash
bash unfold_bliss.sh
```

This will sync the source, and patch it with the latest available updates for Bass OS. Once complete and all patches, and addons are applied successfully, you can move onto the next step.

### Building Bass OS

#### Build Options:

##### Target Specific build scripts:

(**!!NOTICE FOR LICENSED CUSTOMERS!!**) If you have been supplied with the source, then chances are your source comes with a separate build script specific to your devices needs. Please check the project folder for a script with your product name or invoice number in it. Examples: `build_ABC01.0.1.sh` or `build_Intel-AC013.sh`. These will include the specific set of arguments passed to the build_bass script, so all you will need to do is run your targeted script to build. 

```
bash build_ABC01.0.1.sh
```

##### General Build Script Usage:

We offer a number of options to configure your builds with. You can use the `-h` argument to see the latest integrations available. 
We also symlink the build-x86 command with `build_bass.sh` and `build-x86.sh`, so the commands both act the same when building Bass OS

Example:

```bash
bash build_bass.sh -h
Usage: build-x86.sh [options]
Options:
-h, --help             Display this help dialog
-c, --clean            Clean the project
-d, --dirty            Run in dirty mode
-t, --title (title)    Set the release title
-b, --blissbuildvariant (variant)   Set the Bliss build variant
-i, --isgo             Enable isgo version
-v, --specialvariant (variant)      Set the special variant
--grubcmdline "option1=1 option2=1" Set the grub cmdline options
--production           Disable Test Build watermark and sign builds (requires release/product signature keys)

Launcher Options:
--clearhotseat         Enable clear hotseat favorites for Launcher3 Quickstep
--disablesearch        Disable device search
-s, --smartdock        Enable smartdock
--smartdockb           Enable smartdock with Bliss customizations
-k, --kiosk            Enable kiosk launcher **requires private git access**
--restrictedlauncher   Enable restricted launcher
--restrictedlauncherpro   Enable restricted launcher pro **requires private git access**
--garliclauncher       Enable garlic launcher
--gamemodelauncher     Enable game mode launcher
--crosslauncher        Enable cross launcher
--tvlauncher           Enable tv launcher
--titaniuslauncher     Enable titanius launcher
--desktoponsecondary   Enable desktop on secondary displays

Navigation Options:
-t, --tabletnav        Enable tablet navigation
--taskbarnav           Enable taskbar navigation
--gesturenav    Enable gesture navigation
--externalnav          Enable navigation on external displays
--rightmouseasback     Enable right mouse button as back

Package Options:
--noksu                Disable KernelSU
-f, --fossapps         Enable fossapps
--minfossapps          Enable minimal fossapps
-e, --supervanilla     Enable supervanilla
-m, --minimal          Enable minimal packages
-r, --removeusertools  Enable removeusertools
--viabrowser           Enable viabrowser
-w, --wiz              Enable Bliss setupwizard
--ethernetmanager      Enable EthernetManager
--powermanager         Enable power manager
--buildextra           Build extra packages
--updatefossapps       Update fossapps
--usepos               Enable TabShop pos terminal app

Input Options:
--showkeyboard         Enable show keyboard
--perdisplayfocus      Enable per display focus
--gboard               Enable Google GBoard IME
--gboardlite           Enable Google GBoard Lite IME
--perdisplayfocusime      Enable per display focus with experiment IME
--perdisplayfocuszqyime   Enable per display focus with ZQY IME

Firmware & Driver Options:
--sof                  Include SOF firmware
--silead               Include Silead firmware

Other Options:
-a, --atom             Include Intel Atom specific configurations
-l, --lockdown         Enable secure lockdown build
--adblockdown          Enable lockdown ADB defaults
-m, --manifest         Generate manifest
--alwaysonsettings     Enable always on settings
--nolarge              Disable large screen settings
 
```

### Features:

 - Supports various navigation & UI switches
 - Supports various use-case launcher options (requires recent changes to vendor/agp-apps)
 - Automatically updates Grub menus and other build configs for launcher and mode options (requires recent changes to vendor/agp-apps)

Please note that some of the build options may require licensed access to the feature/addon/application in order to use it. In some cases, the build will continue with just a warning when these options are used. In other cases, the build will exit. To remedy this, use a different option or remove the offending option from the build command. 

### Examples

Here are a few examples to help in understanding:

**Bass Desktop**: Desktop mode demo of Bass featuring SmartDock

	bash build_bass.sh --clean --title "Bass" --blissbuildvariant vanilla --specialvariant "-Desktop" --ethernetmanager --tabletnav --smartdock --wiz --clearhotseat --perdisplayfocus --externalnav --externalstatusbar --nolarge --sof --silead --alwaysonsettings --minfossapps
	
**Bass Restricted**: Restricted mode demo of Bass featuring Bliss Restricted Launcher
	
	bash build_bass.sh --clean --title "Bass" --blissbuildvariant foss --specialvariant "-Restricted" --restrictedlauncher --ethernetmanager --fossapps --gesturenav --clearhotseat --externalnav --noksu --showkeyboard --nolarge --alwaysonsettings --sof --silead
	
**Bass POS**: Point-Of-Sale version of Bass featuring TabShop
	
	bash build_bass.sh --clean --title "Bass" --blissbuildvariant foss --specialvariant "-POS" --restrictedlauncher --usepos --ethernetmanager --fossapps --gesturenav --clearhotseat --externalnav --noksu --showkeyboard --nolarge --alwaysonsettings --supervanilla --minimal
	
**Bass Tablet Go**: Android Go based Tablet version of Bass OS
	
	bash build_bass.sh --clean --title "Bass" --blissbuildvariant foss --specialvariant "-TabletGo" --isgo --ethernetmanager --fossapps --tabletnav --wiz --clearhotseat --perdisplayfocus --externalnav --externalstatusbar --noksu --showkeyboard --perdisplayfocus --nolarge
	

### Notes

- Depending on your hardware and internet connection, downloading and building may take 8h or more.  
- After the successful build, find the images at `iso/` under the folder name based on your build name generated by the build system and can also be found in `aosptree/out/target/product/x86_64/`.
 
## Addons

The [Addon README](private/README.md) has a basic rundown of what you need for Addons & private manifest additions for Bass. 
	
### Vendor Customization Layer

If you have licensed access to the vendor customization layer for Bass OS, it comes with an easy to use menu driven interface for rebranding the OS. 
Below are a few combinations of the various command options put together in the form of Collections. 

#### Features available

- Menu driven interface for updating assets and branding:
	![Bass - Customization menu](assets/bass-customization.png)
 - Generates default wallpaper overlays
 - Generates branded bootanimation based on a single loop of frames
 - Generates branded grub background

## Booting into the builds:

Please checkout the [documentation site](https://docs.blisscolabs.dev) for up to date booting and installation steps. 

## Contributions

We do have a [contributing doc](CONTRIBUTING.md) that will cover things like expanding on the BASS scripts, manifest process, addons, etc. Feel free to check that out if interested. 


