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
	$TOPDIR/build_gem5.sh
fi

sysver="20180409"
sf="$FSDIRARM/aarch-system-${sysver}"
imgdir="$sf/disks"
if [[ ! -d $sf ]]; then
	$TOPDIR/get_essential_fs.sh
fi

target="boot_ubuntu"
ncores="2"
cpu_clk_freq="4GHz"
mem_size="2GB"

#script="fs.py"
script="starter_fs.py"

#tlm_options="--tlm-memory=transactor"

if [ "${script}" == "starter_fs.py" ]; then
	img="$imgdir/aarch64-ubuntu-trusty-headless.img"
	config_script="configs/example/arm/${script}"
	cpu_options="--cpu=hpi --num-cores=${ncores} --cpu-freq=${cpu_clk_freq}"
	mem_options="--mem-size=${mem_size}"
	disk_options="--disk-image=$img"
	kernel="--kernel=$FSDIRARM/aarch-system-${sysver}/binaries/vmlinux.vexpress_gem5_v1_64"
	dtb="--dtb=$FSDIRARM/aarch-system-${sysver}/binaries/armv8_gem5_v1_${ncores}cpu.dtb"
elif [ "${script}" == "fs.py" ]; then
	img="$imgdir/aarch32-ubuntu-natty-headless.img"
	config_script="configs/example/${script}"
	cpu_options="--cpu-type=TimingSimpleCPU --num-cpu=${ncores} --cpu-clock=${cpu_clk_freq}"
	other_options="--machine-type=VExpress_GEM5_V1 --root-device=/dev/vda1"
	mem_options="--mem-size=${mem_size} --mem-type=DDR3_1600_8x8 --mem-channels=1 --caches --l2cache"
	disk_options="--disk=$img"
	dtb="--dtb-filename=$FSDIRARM/aarch-system-${sysver}/binaries/armv7_gem5_v1_${ncores}cpu.dtb"
	kernel="--kernel=$FSDIRARM/aarch-system-${sysver}/binaries/vmlinux.vexpress_gem5_v1"
else
	printf "\nPlease define options for ${script}\n"
	exit
fi


call_m5_exit="no"
sleep_before_exit="0"

restore_from_checkpoint="no"
checkpoint_dir_timestamp=""
checkpoint_tick_number=""
checkpoint_dir="${target}_${ncores}c_${checkpoint_dir_timestamp}"

if [ "$call_m5_exit" == "yes" ]; then
	bootscript="${target}_${ncores}c.rcS"
	printf '#!/bin/bash\n' > $bootscript
	printf "echo \"Executing $bootscript now\"\n" >> $bootscript
	printf 'echo "Linux is already running."\n' >> $bootscript
	printf "echo \"Calling m5 exit in $sleep_before_exit seconds from now...\"\n" >> $bootscript
	printf "sleep ${sleep_before_exit}\n" >> $bootscript
	printf 'm5 exit\n' >> $bootscript
	bootscript_options="--script=$ROOTDIR/gem5/$bootscript"
elif [ "$restore_from_checkpoint" == "yes" ]; then
	restore_checkpoint_options="--restore=${checkpoint_dir}/cpt.${checkpoint_tick_number}/"
fi

output_dir="${target}_${ncores}c_$currtime"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log
export M5_PATH="$FSDIRARM/aarch-system-${sysver}":${M5_PATH}
$gem5_elf -d $output_dir $config_script $restore_checkpoint_options $cpu_options $mem_options $tlm_options $kernel $dtb $disk_options $bootscript_options $other_options 2>&1 | tee $logfile
