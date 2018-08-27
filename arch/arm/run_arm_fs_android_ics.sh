#!/usr/bin/env bash

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

source ../../common/defaults.in
source ../../common/util.in

basedir="$PWD/../.."
currtime=$(date "+%Y.%m.%d-%H.%M.%S")

arch="ARM"
mode="opt"
gem5="build/$arch/gem5.$mode"

outdir="--outdir=android_asimbench_output_$currtime"
fsscript="configs/example/fs.py"
cpuopt="--cpu-type=TimingSimpleCPU --num-cpu=4"
memopt="--mem-size=256MB --mem-type=DDR3_1600_8x8 --mem-channels=2 --caches --l2cache"
machine="--machine-type=RealView_PBX"
ostype="--os-type=android-ics"
miscopt="--frame-capture"
sp="$FSDIRARM/asimbench/asimbench_boot_scripts"
benchmarkopt="--script=$sp/bbench.rcS"
kp="$FSDIRARM/asimbench/asimbench_android_arm_kernel"
kernel="--kernel=$kp/vmlinux.smp.ics.arm.asimbench.2.6.35"
disk="--disk=ARMv7a-ICS-Android.SMP.Asimbench-v3.img"

cd $ROOTDIR/gem5
pfile="$basedir/patches/gem5/asimbench/gem5_ARMv7a-ICS-Android.SMP.Asimbench-v3.patch"
patch -fs -p1 < $pfile &>/dev/null
getnumprocs np
nj=`expr $np - 1`
scons $gem5 -j$nj

mkdir -p $FSDIRARM/asimbench/disks
tar -xaf $FSDIRARM/asimbench/asimbench_disk_image/sdcard-1g.tar.gz -C $FSDIRARM/asimbench/disks
tar -xaf $FSDIRARM/asimbench/asimbench_disk_image/ARMv7a-ICS-Android.SMP.Asimbench.tar.gz -C $FSDIRARM/asimbench/disks

export M5_PATH=${M5_PATH}:"$FSDIRARM/aarch-system-20170616"
export M5_PATH=${M5_PATH}:"$FSDIRARM/asimbench"
$gem5 $outdir $fsscript $cpuopt $memopt $benchmarkopt $machine $kernel $disk $ostype $miscopt
