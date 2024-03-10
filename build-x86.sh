#!/bin/bash -e

trap 'echo -e "\nbuild-x86.sh interrupted"; exit 1' SIGINT

echo -e "\033[1;34mBuilding Bass OS\033[0m"
pushd aosptree
. build/envsetup.sh
build-x86 $@
popd

