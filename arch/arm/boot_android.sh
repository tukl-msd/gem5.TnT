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
# build gem5
if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi
# apply patch
patchdir="$TOPDIR/patches/gem5/asimbench"
p="gem5_ARMv7a-ICS-Android.SMP.Asimbench-v3.patch"
pp="${patchdir}/${p}"
printf "${Red}Stashing local changes...${NC}\n"
git stash > /dev/null 2>&1
printf "${Yellow}Applying a patch...${NC}\n"
patch -fs -p1 < $pp &>/dev/null
popd

# make it sure all essential files are ready to use
syspath="$FSDIRARM/asimbench"
diskpath="${syspath}/disks"
scriptspath="${syspath}/asimbench_boot_scripts"
if [[ ! -d $syspath ]]; then
	$TOPDIR/get_essential_fs.sh
fi

# gem5 related configurations.
target="android"
config_script="configs/example/fs.py"
ncpus="2"
cpu_clk="4GHz"
#cpu_type="TimingSimpleCPU"
cpu_type="AtomicSimpleCPU"
cpu_opts="--cpu-type=${cpu_type} --num-cpu=$ncpus --cpu-clock=${cpu_clk}"
mem_size="256MB"
mem_opts="--mem-size=${mem_size} --mem-type=DDR3_1600_8x8 --mem-channels=1"
cache_opts="--caches --l2cache"
#tlm_opts="--tlm-memory=transactor"
machine_opts="--machine-type=RealView_PBX"
os_opts="--os-type=android-ics"
#misc_opts="--frame-capture"
disk_opts="--disk=${diskpath}/ARMv7a-ICS-Android.SMP.Asimbench-v3.img"
kernelpath="${syspath}/asimbench_android_arm_kernel"
kernel="--kernel=${kernelpath}/vmlinux.smp.ics.arm.asimbench.2.6.35"

sim_name="${target}_${cpu_type}_${ncores}c_${mem_size}_${currtime}"

pushd $ROOTDIR/gem5

bootscript="${sim_name}.rcS"
printf '#!/system/bin/sh\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf '/sbin/m5 -h\n' >> $bootscript
printf '/system/bin/sh\n' >> $bootscript
script_opts="--script=$ROOTDIR/gem5/$bootscript"

#script_opts="${scriptspath}/360buy.rcS"
#script_opts="${scriptspath}/adobe.rcS"
#script_opts="${scriptspath}/arm_ckpt_asim.rcS"
#script_opts="${scriptspath}/baidumap.rcS"
#script_opts="${scriptspath}/bbench.rcS"
#script_opts="${scriptspath}/frozenbubble.rcS"
#script_opts="${scriptspath}/k9mail.rcS"
#script_opts="${scriptspath}/kingsoftoffice.rcS"
#script_opts="${scriptspath}/mxplayer.rcS"
#script_opts="${scriptspath}/netease.rcS"
#script_opts="${scriptspath}/sinaweibo.rcS"
#script_opts="${scriptspath}/ttpod.rcS"

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log
export M5_PATH=${M5_PATH}:"${syspath}"
# start simulation
$gem5_elf -d $output_dir \
	$config_script \
	$restore_checkpoint_opts \
	$cpu_opts \
	$mem_opts \
	$cache_opts \
	$tlm_opts \
	$kernel \
	$disk_opts \
	$machine_opts \
	$os_opts \
	$misc_opts \
	$script_opts 2>&1 | tee $logfile
popd
