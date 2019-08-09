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

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

sysver="20180409"
syspath="$FSDIRARM/aarch-system-${sysver}"
imgdir="${syspath}/disks"

usage="Usage: $(basename "$0") {-h | [DISK NUM_CPUS MEM_SIZE_GB]}
Boot Linux aarch64. Optionally the DISK image and the number of CPUs and the memory
size in GiB can be specified.
	-h    display this help and exit
	DISK  raw disk image file (.img)
	NUM_CPUS  number of CPUS
	MEM_SIZE_GB memory size in GiB"

if [ "$#" = "0" ]; then
	img="$imgdir/linaro-minimal-aarch64.img"
	ncpus="2"
	mem_size="4GB"
elif [ "$#" = "1" ] && [ "$1" = "-h" ]; then
	echo "$usage"
	exit 0
elif [ "$#" = "3" ]; then
	img="$1"
	ncpus="$2"
	mem_size="${3}GB"
else
	echo "$usage"
	exit 1
fi

if [ ! -e "$img" ]; then
	printf "\n${Red}Error. File \"$img\" not found.${NC}\n\n"
	echo "$usage"
	exit 1
fi

disk_opts="--disk-image=$img"

target="boot-linux-aarch64"
config_script="configs/example/fs.py"
cpu_clk="4GHz"
machine_opts="--machine-type=VExpress_GEM5_V1"
cpu_type="TimingSimpleCPU"
#cpu_type="AtomicSimpleCPU"
cpu_opts="--cpu-type=${cpu_type} --num-cpu=$ncpus --cpu-clock=${cpu_clk}"
mem_opts="--mem-size=${mem_size}"
cache_opts="--caches --l2cache"
#kernel="$ROOTDIR/gem5/vmlinux_aarch64"
kernel="${syspath}/binaries/vmlinux.vexpress_gem5_v1_64"
kernel_opts="--kernel=${kernel}"
dtb_opts="--dtb=${syspath}/binaries/armv8_gem5_v1_${ncpus}cpu.dtb"
gem5_opts="--remote-gdb-port=0"
#tlm_opts="--tlm-memory=transactor"

sim_name="${target}-${cpu_type}-${ncpus}c-${mem_size}-${currtime}"

pushd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi

bootscript="${sim_name}.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf '/sbin/m5 -h\n' >> $bootscript
printf '/bin/bash\n' >> $bootscript
script_opt="--script=$ROOTDIR/gem5/$bootscript"

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

export M5_PATH="${syspath}":${M5_PATH}

# Start simulation
time $gem5_elf $gem5_opts \
	-d $output_dir \
	$config_script \
	$machine_opts \
	$cpu_opts \
	$mem_opts \
	$tlm_opts \
	$cache_opts \
	$kernel_opts \
	$dtb_opts \
	$disk_opts \
	$script_opt 2>&1 | tee $logfile

popd
