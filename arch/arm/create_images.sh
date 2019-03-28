#!/usr/bin/env bash

# Copyright (c) 2018, University of Kaiserslautern
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

sysver="20180409"
system="aarch-system-${sysver}"
tarball="$FSDIRARM/${system}.tar.xz"
dir=`expr ${tarball} : '\(.*\).tar.*'`
if [[ ! -d ${dir} ]]; then
	mkdir -p ${dir}
	echo -ne "Uncompressing ${tarball} into ${dir}. Please wait..."
	pulse on
	tar -xaf ${tarball} -C ${dir}
	pulse off
fi

imgdir="$FSDIRARM/${system}/disks"
baseimg="$imgdir/linaro-minimal-aarch64.img"

bmsuites="
STRIDE_v1.1
parsec-3.0
stream
test-suite
"

bmsuiteroot="home"

for bs in $bmsuites; do
	img="$imgdir/linaro-minimal-aarch64-${bs}-inside.img"
	if [[ -e $img ]]; then
		echo -ne "Image $img already exists. Please remove it if you want to create it again.\n"
	else
		echo -ne "Creating $img. Please wait.\n"
		cp $baseimg $img
		bm="$BENCHMARKSDIR/$bs"
		cnt=`du -ms $bm | awk '{print $1}'`
		bsize="1M"
		dd if=/dev/zero bs=$bsize count=$cnt >> $img
		sudo parted $img resizepart 1 100%
		dev=`sudo fdisk -l $img | tail -1 | awk '{ print $1 }'`
		startsector=`sudo fdisk -l $img | grep $dev | awk '{ print $2 }'`
		sectorsize=`sudo fdisk -l $img | grep ^Units | awk '{ print $8 }'`
		loopdev=`sudo losetup -f`
		offset=$(($startsector*$sectorsize))
		sudo losetup -o $offset $loopdev $img
		tempdir=`mktemp -d`
		sudo mount $loopdev $tempdir
		sudo resize2fs $loopdev
		sudo rsync -au $bm $tempdir/$bmsuiteroot
		sudo umount $tempdir
		sudo sync
		sudo losetup --detach $loopdev
	fi
done
echo "Done."
