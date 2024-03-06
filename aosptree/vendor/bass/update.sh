#!/bin/bash
# set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LT_BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Device type selection	
if [ "$1" == "" ]; then
PS3='Which device type do you plan on building?: '
echo -e ${YELLOW}"(default is 'ABI:x86_64 & ABI2:x86')"
TMOUT=10
options=("ABI:x86_64 & ABI2:x86"
		 "ABI:arm64-v8a & ABI2:armeabi-v7a"
		 "ABI:x86")
echo -e "Timeout in $TMOUT sec."${NC}
select opt in "${options[@]}"
do
	case $opt in
		"ABI:x86_64 & ABI2:x86")
			echo "you chose choice $REPLY which is $opt"
			MAIN_ARCH="x86_64"
			SUB_ARCH="x86"	
			break
			;;
		"ABI:arm64-v8a & ABI2:armeabi-v7a")
			echo "you chose choice $REPLY which is $opt"
			MAIN_ARCH="arm64-v8a"
			SUB_ARCH="armeabi-v7a"
			break
			;;
		"ABI:x86")
			echo "you chose choice $REPLY which is $opt"
			MAIN_ARCH="x86"
			break
			;;
		"ABI:armeabi-v7a")
			echo "you chose choice $REPLY which is $opt"
			MAIN_ARCH="armeabi-v7a"
			break
			;;
		*) echo "invalid option $REPLY";;
	esac
done
if [ "$opt" == "" ]; then
	MAIN_ARCH="x86_64"
	SUB_ARCH="x86"	
fi
fi

if [ "$1" == "1" ]; then
	echo "ABI:x86_64 & ABI2:x86 was preselected"
	MAIN_ARCH="x86_64"
	SUB_ARCH="x86"	
fi
if [ "$1" == "2" ]; then
	echo "ABI:arm64-v8a & ABI2:armeabi-v7a was preselected"
	MAIN_ARCH="arm64-v8a"
	SUB_ARCH="armeabi-v7a"
fi
if [ "$1" == "3" ]; then
	echo "ABI:x86 & ABI2:x86 was preselected"
	MAIN_ARCH="x86"
fi
if [ "$1" == "4" ]; then
	echo "ABI:armeabi-v7a was preselected"
	MAIN_ARCH="armeabi-v7a"
fi
rm -rf tmp
rm -rf lib

addCopy() {
	mkdir -p tmp
	mkdir -p tmp/lib
	# mkdir -p lib
	addition=""
	unzip -o $1 "lib/*"
	if [ -d lib/"$MAIN_ARCH" ];then
		addition="
LOCAL_PREBUILT_JNI_LIBS := \\
$(unzip -olv $1 |grep -v Stored |sed -nE 's;.*(lib/'"$MAIN_ARCH"'/.*);\t\1 \\;p')
			"
		cp -r lib/"$MAIN_ARCH" tmp/lib/
	elif [ -d lib/"$SUB_ARCH" ];then
		addition="
LOCAL_MULTILIB := 32
LOCAL_PREBUILT_JNI_LIBS := \\
$(unzip -olv $1 |grep -v Stored |sed -nE 's;.*(lib/'"$SUB_ARCH"'/.*);\t\1 \\;p')
			"
		cp -r lib/"$SUB_ARCH" tmp/lib/
	fi
# rm -rf tmp/lib/*
cat >> Android.mk <<EOF
include \$(CLEAR_VARS)
LOCAL_MODULE := $2
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $1
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_OVERRIDES_PACKAGES := $3
$addition
include \$(BUILD_PREBUILT)

EOF
echo -e "\t$2 \\" >> apps.mk
}

addPrivCopy() {
	mkdir -p tmp
	mkdir -p tmp/lib
	# mkdir -p lib
	addition=""
	unzip -o $1 "lib/*"
	if [ -d lib/"$MAIN_ARCH" ];then
		addition="
LOCAL_PREBUILT_JNI_LIBS := \\
$(unzip -olv $1 |grep -v Stored |sed -nE 's;.*(lib/'"$MAIN_ARCH"'/.*);\t\1 \\;p')
			"
		cp -r lib/"$MAIN_ARCH" tmp/lib/
	elif [ -d tmp/lib/"$SUB_ARCH" ];then
		addition="
LOCAL_MULTILIB := 32
LOCAL_PREBUILT_JNI_LIBS := \\
$(unzip -olv $1 |grep -v Stored |sed -nE 's;.*(lib/'"$SUB_ARCH"'/.*);\t\1 \\;p')
			"
		cp -r lib/"$SUB_ARCH" tmp/lib/
	fi
rm -rf lib/*
cat >> Android.mk <<EOF
include \$(CLEAR_VARS)
LOCAL_MODULE := $2
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $1
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_OVERRIDES_PACKAGES := $3
LOCAL_PRIVILEGED_MODULE := true
$addition
include \$(BUILD_PREBUILT)

EOF
echo -e "\t$2 \\" >> apps.mk
}

echo -e "${LT_BLUE}# Setting Up${NC}"
rm -Rf apps.mk lib bin 
cat > Android.mk <<EOF
LOCAL_PATH := \$(my-dir)

EOF
echo -e 'PRODUCT_PACKAGES += \\' > apps.mk

mkdir -p bin


copyFromPrebuiltAppsFolders(){
	echo -e "${YELLOW}# copying from prebuilt apps folder ${NC}"
	prebuilt_apps_folder="prebuilts/apps"
	prebuilt_priv_apps_folder="prebuilts/priv-apps"
	for apk in $(find $prebuilt_apps_folder -type f -name '*.apk'); do
		apkexists=true
		package=$(basename $apk)
		# packageName=`echo "$package" | cut -d'.' -f1`
		packageName="${package%.*}"
		echo -e "Package name: $packageName"
		echo -e "${YELLOW}# copying: $apk ${NC}"
		cp $apk bin/
		addCopy $apk $packageName ""
	done
	for apk in $(find $prebuilt_priv_apps_folder -type f -name '*.apk'); do
		apkexists=true
		package=$(basename $apk)
		# packageName=`echo "$package" | cut -d'.' -f1`
		packageName="${package%.*}"
		echo -e "Package name: $packageName"
		echo -e "${YELLOW}# copying private-app: $apk ${NC}"
		cp $apk bin/
		addPrivCopy $apk $packageName ""
	done
}

copyFromPrebuiltAppsFolders

echo -e "${LT_BLUE}# finishing up apps.mk${NC}"
echo >> apps.mk

echo -e "${YELLOW}# Cleaning up${NC}"
# rm -Rf tmp
if [ "$apkexists" == "true" ]; then
	mv tmp/* .
	bash generate_perms.sh
else
	echo -e "There were no apk files found in the prebuils folders"
	rm -rf Android.mk
	rm -rf bin
fi

echo -e "${GREEN}# DONE${NC}"
