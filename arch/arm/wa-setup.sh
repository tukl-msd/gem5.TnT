#!/usr/bin/env bash

# Copyright (c) 2019, University of Kaiserslautern
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Author: Éder F. Zulian

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

wa_branch="master"
ver="20180409"

gitrepos=(
"$ROOTDIR:https://github.com/ARM-software/workload-automation.git"
)
greetings
git_clone_into_dir gitrepos[@]

pushd $ROOTDIR/workload-automation > /dev/null 2>&1
git checkout ${wa_branch} > /dev/null 2>&1
sudo -H python setup.py install > /dev/null 2>&1
wa -h > /dev/null 2>&1
popd > /dev/null 2>&1

dir="$ROOTDIR/workload-automation/build/lib.linux-x86_64-2.7/wa/workloads"
bins="
lmbench
dhrystone
hackbench
stress_ng
rt_app
sysbench
memcpy
"
archs="
arm64
armeabi
"

tdir=`mktemp -d`
img64="$FSDIRARM/aarch-system-${ver}/disks/linaro-minimal-aarch64-arm64-inside.img"
img32="$FSDIRARM/aarch-system-${ver}/disks/linux-aarch32-ael-armeabi-inside.img"
if [ ! -e $img64 ] || [ ! -e $img32 ]; then
	for bin in $bins; do
		for arch in $archs; do
			sudo cp -R $dir/$bin/bin/$arch $tdir
		done
	done
	for arch in $archs; do
		sudo chown -R $USER:$USER $tdir/$arch
		chmod u+x $tdir/$arch/*
	done
fi

pushd $tdir > /dev/null 2>&1
if [ ! -e $img64 ]; then
	$TOPDIR/disk-util/copy-into-img.sh $FSDIRARM/aarch-system-${ver}/disks/linaro-minimal-aarch64.img arm64
fi
if [ ! -e $img32 ]; then
	$TOPDIR/disk-util/copy-into-img.sh $FSDIRARM/aarch-system-${ver}/disks/linux-aarch32-ael.img armeabi
fi
popd > /dev/null 2>&1
if [ ! -e $img64 ]; then
	mv $tdir/linaro-minimal-aarch64-arm64-inside.img $FSDIRARM/aarch-system-${ver}/disks
fi
if [ ! -e $img32 ]; then
	mv $tdir/linux-aarch32-ael-armeabi-inside.img $FSDIRARM/aarch-system-${ver}/disks
fi
rm -rf $tdir && echo "Done."
printf "Disk images in ${Yellow}$FSDIRARM/aarch-system-${ver}/disks${NC}\n"

printf "\nInstructions:\n\n"
printf "${Yellow}./boot-linux-aarch32.sh ${img32}${NC}\n\n"
printf "1. Connect to gem5 using telnet.\n"
printf "2. Login as root (no password required).\n"
printf "3. Go to the \'/armeabi\' folder.\n"
printf "4. Choose an application and execute it.\n"
printf "\n"
printf "${Yellow}./boot-linux-aarch64.sh ${img64}${NC}\n\n"
printf "1. Connect to gem5 using telnet.\n"
printf "2. Login as root (no password required).\n"
printf "3. Go to the \'/arm64\' folder.\n"
printf "4. Choose an application and execute it.\n"
printf "\n"

