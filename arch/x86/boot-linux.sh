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
currtime=$(date "+%Y.%m.%d-%H.%M.%S")

arch="X86"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

$TOPDIR/get_essential_fs.sh

pushd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi
popd

sys='x86-system'
syspath="$FSDIRX86/${sys}"
diskpath="${syspath}/disks"
disk="${diskpath}/linux-x86.img"
kernel="${syspath}/binaries/x86_64-vmlinux-2.6.22.9"
cfgscript="configs/example/fs.py"
disk_opt="--disk-image=${disk}"
kernel_opt="--kernel=${kernel}"
ncpus="2"
cpu_type="AtomicSimpleCPU"
#cpu_type="TimingSimpleCPU"
#cpu_type="NonCachingSimpleCPU"
cpu_opt="--cpu-type=${cpu_type} --num-cpus=${ncpus}"
mem_size="1GB"
mem_opt="--mem-size=${mem_size}"
cache_opt="--caches --l2cache"
l1_cache_opt="--l1d_size=64kB --l1i_size=64kB --l1d_assoc=4 --l1i_assoc=4"
l2_cache_opt="--l2_size=1024kB --l2_assoc=8"

target="x86_linux"
sim_name="${target}_${cpu_type}_${ncpus}c_${mem_size}_${currtime}"


pushd $ROOTDIR/gem5

bootscript="${sim_name}.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf '/sbin/m5 -h\n' >> $bootscript
printf '/bin/bash\n' >> $bootscript
script_opt="--script=$ROOTDIR/gem5/$bootscript"
#script_opt="--script=$DIR/boot-linux.rcS"

git checkout configs/common/FSConfig.py
git apply $DIR/boot-linux.patch

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

export M5_PATH="${syspath}":${M5_PATH}

$gem5_elf -d $output_dir \
	$cfgscript \
	$cpu_opt \
	$cache_opt \
	$l1_cache_opt \
	$l2_cache_opt \
	$mem_opt \
	$tlm_options \
	$kernel_opt \
	$disk_opt \
	$script_opt 2>&1 | tee $logfile
popd

