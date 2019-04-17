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
TOPDIR=$DIR/..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

usage="Usage: $(basename "$0") {-h | DISK DIR}
Creates a copy of a disk image containing a folder.
	-h    display this help and exit
	DISK  raw disk image file (.img)
	DIR   folder to be copied into DISK"

if [ "$#" != "2" ] && [ "$1" != "-h" ]; then
	echo "$usage"
	exit 1
fi

if [ $1 = "-h" ]; then
	echo "$usage"
	exit 0
fi

img="$1"
dir="$2"

if [ ! -e "$img" ]; then
	printf "\n${Red}Error. File \"$img\" not found.${NC}\n\n"
	echo "$usage"
	exit 1
fi

if [ ! -d "$dir" ]; then
	printf "\n${Red}Error. Folder \"$dir\" not found.${NC}\n\n"
	echo "$usage"
	exit 1
fi

printf "${Yellow}Salutations! You are using gem5.TnT!${NC}\n"
imgbn=$(basename "$img")
imgn=${imgbn%.*}
imge=${imgbn##*.}
dirbn=$(basename "$dir")
disk="${imgn}-${dirbn}-inside.${imge}"

if [[ -e $disk ]]; then
	printf "${Yellow}Image $disk already exists.${NC}\n"
else
	printf "${Yellow}Creating $disk...${NC}\n"
	cp $img $disk
	cnt=`du -ms ${dir} | awk '{print $1}'`
	bsize="1M"
	dd if=/dev/zero bs=$bsize count=$cnt >> $disk
	sudo parted $disk resizepart 1 100%

	dev=`sudo fdisk -l $disk | tail -1 | awk '{ print $1 }'`
	startsector=`sudo fdisk -l $disk | grep $dev | awk '{ print $2 }'`
	sectorsize=`sudo fdisk -l $disk | grep ^Units | awk '{ print $8 }'`
	loopdev=`sudo losetup -f`
	offset=$(($startsector*$sectorsize))
	sudo losetup -o $offset $loopdev $disk
	tempdir=`mktemp -d`
	sudo mount $loopdev $tempdir

	sudo resize2fs $loopdev
	sudo rsync -au $dir $tempdir
	sudo umount $tempdir
	sudo sync
	sudo losetup --detach $loopdev
fi

printf "${Yellow}Created disk: ${Green}${disk}${NC}\n"
