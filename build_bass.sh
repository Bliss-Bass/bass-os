#!/bin/bash -e

trap 'echo -e "\nbuild.sh interrupted"; exit 1' SIGINT

echo Building the Android
pushd aosptree
. build/envsetup.sh
build-x86 $@
popd

