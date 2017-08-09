#! /bin/bash

# Copyright (c) 2017, University of Kaiserslautern
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

source ./util.sh

function getfsfiles {
	local rootdir=$HOME/gem5_simulator
	local fsdir=$rootdir/full_system_files
	local fsdirarm=$fsdir/arm
	local fsdirarmlegacy=$fsdirarm/legacy
	local fsdirx86=$fsdir/x86
	local fsdirxalpha=$fsdir/alpha

	local dirtree="
	$fsdirarm
	$fsdirarmlegacy
	$fsdirx86
	$fsdirxalpha
	"
	for n in $dirtree; do
		local c="mkdir -p $n"
		rctest $c
	done

	wgethis=(
	# ARM full system files
	"$fsdirarm:http://www.gem5.org/dist/current/arm/aarch-system-2014-10.tar.xz"
	"$fsdirarm:http://www.gem5.org/dist/current/arm/aarch-system-20170421.tar.xz"
	# ARM legacy files
	# ARMv8 Full-System Files -- Pre-compiled kernel and disk image for the 64 bit ARMv8 ISA.
	"$fsdirarmlegacy:http://www.gem5.org/dist/current/arm/arm64-system-02-2014.tgz"
	# VExpress_EMM kernel w/PCI support and config - Pre-compiled Linux 3.3 VExpress_EMM kernel that includes support for PCIe devices, a patch to add gem5 PCIe support to the revision of the vexpress kernel tree and a config file. This kernel is needed if you want to simulated more than 256MB of RAM or networking. Pass kernel=/path/to/vmlinux-3.3-arm-vexpress-emm-pcie machine-type=VExpress_EMM on the command line. You'll still need the file systems below. This kernel supports a maximum of 2047MB (one MB less than 2GB) of memory.
	"$fsdirarmlegacy:http://www.gem5.org/dist/current/arm/vmlinux-emm-pcie-3.3.tar.bz2"
	# New Full System Files -- Pre-compiled Linux kernel, and file systems, and kernel config files. This includes both a cut-down linux and a full ubuntu linux.
	"$fsdirarmlegacy:http://www.gem5.org/dist/current/arm/arm-system-2011-08.tar.bz2"
	# Old Full System Files -- Older pre-compiled Linux kernel, and file system.
	"$fsdirarmlegacy:http://www.m5sim.org/dist/current/arm/arm-system.tar.bz2"
	# X86 full system files
	$fsdirx86
	# The kernel used for regressions, an SMP version of it, and a disk image
	"$fsdirx86:http://www.m5sim.org/dist/current/x86/x86-system.tar.bz2"
	# Config files for both of the above kernels, 2.6.25.1 and 2.6.28.4
	"$fsdirx86:http://www.m5sim.org/dist/current/x86/config-x86.tar.bz2"
	# ALPHA full system files
	cd $fsdirxalpha
	# Pre-compiled Linux kernels, PALcode/Console code, and a filesystem
	"$fsdirxalpha:http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2"
	# Everything you need to create your own disk image and compile everything in it from scratch
	"$fsdirxalpha:http://www.m5sim.org/dist/current/linux-dist.tgz"
	)
	cmdtest wget
	for g in "${wgethis[@]}"; do
		cd ${g%%:*}
		wget -nc ${g#*:}
		printf "%s downloaded into %s.\n\n" "${g#*:}" "${g%%:*}"
	done
}

greetings
getfsfiles
