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

printf "${Yellow}Salutations! You are using gem5.TnT!${NC}\n"

tb="ubuntu-base-16.04-core-amd64.tar.gz"
url="http://cdimage.ubuntu.com/ubuntu-base/releases/16.04/release/"

printf "Downloading $tb..."
pulse on
wget -N "$url/$tb" > /dev/null 2>&1
pulse off

disk="ubu.img"
chroot_script="inside-chroot.sh"

# This give us a file with size 'nblocks * blocksize'
blocksize='1M'
nblocks='8192'

# Each sector is 512 B in size, the first 2048 sectors are reserved for
# the partition table (aka disk label). The file system follows, so the
# offset is 1048576 (2048 sectors of 512 B).
# Q: Is there other ways to find out the offset?
# A: Yes. For example:
# $ parted disk.img -> unit -> B -> print
offset='1048576'

if [[ ! -e ${disk} ]]; then
	# create a zeroed file
	sudo dd if=/dev/zero of=${disk} bs=${blocksize} count=${nblocks}
	# create a new partition table (aka disklable) of msdos type
	sudo parted ${disk} mklabel msdos
	# find the first unused loop device
	loopdev=`sudo losetup -f`
	# associtate loop device with file
	sudo losetup ${loopdev} ${disk}
	# BASH(1)
	# Here Documents
	# If the redirection operator is <<-, then all leading tab characters
	# are stripped from input lines and the line containing delimiter.
	#
	# SED(1)
	# \s* matches any number of spaces
	# [\+0-9a-zA-Z]* matches a sequence of alphanumeric characters
	# The escaped parenthesis are used to capture characters. \1 refers to
	# the characters captured.
	# .* matches any number of characters including new line
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<- END | sudo fdisk ${loopdev}
  		o # clear partition table
  		n # new partition
  		p # primary
  		1 # partition number 1
  		  # use default start
  		  # extend partition to end of disk
  		p # print partition table
  		w # save/write partition table
  		q # quit
	END
	# detach loop device
	sudo losetup -d ${loopdev}

	# find the first unused loop device
	loopdev=`sudo losetup -f`
	# associtate loop device with file using an offset
	sudo losetup -o ${offset} ${loopdev} ${disk}
	# create a filesystem in the file
	sudo mke2fs ${loopdev}
	# detach loop device
	sudo losetup -d ${loopdev}
fi

# find the first unused loop device
loopdev=`sudo losetup -f`
# associate loop device with file using an offset
sudo losetup -o $offset $loopdev $disk
# create a temporary directory to server as mount point
mpoint=`mktemp -d`
# mount the filesystem
sudo mount $loopdev $mpoint
# copy files
sudo tar -xaf ${tb} -C ${mpoint}
# copy /etc/resolv.conf from your PC to etc/resolv.conf
sudo cp /etc/resolv.conf ${mpoint}/etc/
# etc/hosts
sudo cp hosts ${mpoint}/etc/
# etc/fstab
sudo cp fstab ${mpoint}/etc/
# M5 binary.
m5="$ROOTDIR/gem5/util/m5/m5"
if [[ -e $m5 ]]; then
	sudo cp ${m5} ${mpoint}/sbin/
else
	printf "\n${Red}$m5 not found.${NC}\n"
	printf "${Red}You should make sure the proper m5 exists.${NC}\n\n"
fi
# copy script to be executed inside chroot
sudo cp ${chroot_script} ${mpoint}
# prepare for chroot
# /proc and /sys are both virtual file systems
# file system can be mounted as many times and in as many places as you like,
# thus it's not a problem that these file systems are already mounted on your
# host system
# see also: http://tldp.org/LDP/lfs/5.0/html/chapter06/proc.html
sudo mount -o bind /proc ${mpoint}/proc
sudo mount -o bind /sys ${mpoint}/sys
# /dev is tmpfs managed by udev
# use the same as the host
sudo mount -o bind /dev ${mpoint}/dev
# chroot - run command or interactive shell with special root directory
sudo chroot ${mpoint} ./${chroot_script}
# unmount /proc, /sys and /dev
sudo umount ${mpoint}/sys
sudo umount ${mpoint}/proc
sudo umount ${mpoint}/dev
# unmount
sudo umount ${loopdev} 
# detach loop device
sudo losetup -d ${loopdev}
