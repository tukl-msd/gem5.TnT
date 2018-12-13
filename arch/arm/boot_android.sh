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
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	pfile="$TOPDIR/patches/gem5/asimbench/gem5_ARMv7a-ICS-Android.SMP.Asimbench-v3.patch"
	patch -fs -p1 < $pfile &>/dev/null
	build_gem5 $arch $mode
fi

imgdir="$FSDIRARM/asimbench/disks"
mkdir -p $imgdir

if [[ ! -e $imgdir/sdcard-1g-mxplayer.img ]]; then
	tar -xaf $FSDIRARM/asimbench/asimbench_disk_image/sdcard-1g.tar.gz -C $imgdir
fi

if [[ ! -e $imgdir/ARMv7a-ICS-Android.SMP.Asimbench-v3.img ]]; then
	tar -xaf $FSDIRARM/asimbench/asimbench_disk_image/ARMv7a-ICS-Android.SMP.Asimbench.tar.gz -C $imgdir
fi

target="boot_android"
config_script="configs/example/fs.py"
ncores="4"
cpu_options="--cpu-type=TimingSimpleCPU --num-cpu=$ncores"
mem_options="--mem-size=256MB --mem-type=DDR3_1600_8x8 --mem-channels=1 --caches --l2cache"
#tlm_options="--tlm-memory=transactor"
machine_options="--machine-type=RealView_PBX"
os_options="--os-type=android-ics"
#misc_options="--frame-capture"
disk_options="--disk=ARMv7a-ICS-Android.SMP.Asimbench-v3.img"
kernel="--kernel=$FSDIRARM/asimbench/asimbench_android_arm_kernel/vmlinux.smp.ics.arm.asimbench.2.6.35"

bootscript="${target}_${ncores}c.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf 'echo "Android is already running."\n' >> $bootscript
printf 'echo "Calling m5 exit in 1 second from now..."\n' >> $bootscript
printf 'sleep 1\n' >> $bootscript
printf 'm5 exit\n' >> $bootscript

bootscript_options="--script=$ROOTDIR/gem5/$bootscript"
output_dir="${target}_${ncores}c_$currtime"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

export M5_PATH=${M5_PATH}:"$FSDIRARM/aarch-system-20170616"
export M5_PATH=${M5_PATH}:"$FSDIRARM/asimbench":
$gem5_elf -d $output_dir $config_script $cpu_options $mem_options $tlm_options $kernel $disk_options $machine_options $os_options $misc_options $bootscript_options 2>&1 | tee $logfile
