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
TOPDIR="$DIR/.."
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

usage="Usage: $(basename "$0") {-h | FILE }
Mount a disk image.
	-h    display this help and exit
	FILE  disk image file"

if [ "$#" != "1" ]; then
	echo "$usage"
	exit 1
fi

if [ $1 = "-h" ]; then
	echo "$usage"
	exit 0
fi

img="$1"

if [ ! -e $img ]; then
	printf "\n${Red}Error. File \"$img\" not found.${NC}\n\n"
	echo "$usage"
	exit 1
fi

printf "${Yellow}Salutation! You are using gem5.TnT!${NC}\n"
echo "file: $img"
dev=`sudo fdisk -l $img | tail -1 | awk '{ print $1 }'`
startsector=`sudo fdisk -l $img | grep $dev | awk '{ print $2 }'`
echo "start sector: $startsector"
sectorsize=`sudo fdisk -l $img | grep ^Units | awk '{ print $8 }'`
echo "sector size: $sectorsize"
ldev=`sudo losetup -f`
echo "loop device: $ldev"
offset=$(($startsector*$sectorsize))
echo "offset: $offset"
sudo losetup -o $offset $ldev $img
tdir=`mktemp -d`
sudo mount $ldev $tdir
printf "${Yellow}Mounted at ${Green}$tdir${NC}\n"
umcmd="sudo umount $tdir && sudo losetup --detach $ldev"
printf "${Yellow}Command to unmount: ${Green}$umcmd${NC}\n"
