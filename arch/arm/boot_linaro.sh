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
currtime=$(date "+%Y.%m.%d-%H.%M.%S")

arch="ARM"
mode="fast"
gem5_elf="build/$arch/gem5.$mode"

pushd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi
popd

sysver="20180409"
sysdir="$FSDIRARM/aarch-system-${sysver}"
imgdir="${sysdir}/disks"
img="$imgdir/linaro-minimal-aarch64.img"

if [[ ! -e $img ]]; then
	$TOPDIR/get_essential_fs.sh
fi

target="boot_linaro"
config_script="configs/example/arm/starter_fs.py"
ncores="2"
#cpu_type="hpi"
#cpu_type="atomic"
cpu_type="minor"
cpu_opts="--cpu=${cpu_type} --num-cores=$ncores"
mem_size="8GB"
mem_opts="--mem-size=${mem_size}"
#tlm_opts="--tlm-memory=transactor"
disk_opts="--disk-image=$img"
kernel="--kernel=${sysdir}/binaries/vmlinux.vexpress_gem5_v1_64"
dtb="--dtb=${sysdir}/binaries/armv8_gem5_v1_${ncores}cpu.dtb"
# remote gdb port (0: disable listening)
gem5_opts="--remote-gdb-port=0"

sim_name="${target}_${cpu_type}_${ncores}c_${mem_size}_${currtime}"

pushd $ROOTDIR/gem5
bootscript="${sim_name}.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf '/sbin/m5 -h\n' >> $bootscript
printf '/bin/bash\n' >> $bootscript
bootscript_opts="--script=$ROOTDIR/gem5/$bootscript"

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log
export M5_PATH="$FSDIRARM/aarch-system-${sysver}":${M5_PATH}
$gem5_elf $gem5_opts \
	-d $output_dir \
	$config_script \
	$cpu_opts \
	$mem_opts \
	$tlm_opts \
	$kernel $dtb \
	$disk_opts \
	$bootscript_opts 2>&1 | tee $logfile

popd
