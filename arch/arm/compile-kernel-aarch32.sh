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

# Set the full path to a kernel configuration file here
#kernel_config="<path>/<file>"

$TOPDIR/get_extra_repos.sh

# Compiling the new kernel

pushd $KERNELARM/linux
if [ ! -z ${kernel_config+x} ]; then
	# use specified config
	cp $kernel_config .config
else
	# use default config
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- gem5_defconfig
fi
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j `nproc`

k="vmlinux"
kernel="$ROOTDIR/gem5/${k}_aarch32_${currtime}"
if [ -e "$k" ]; then
	printf "\n${Yellow}$k was successfully built.${NC}\n"
	printf "${Green}Copying $KERNELARM/linux/$k to $kernel.${NC}\n"
	cp $k $kernel
else
	printf "\n${Red}Error. $k not found.${NC}\n\n"
	exit 1
fi
popd


# Testing the new kernel

printf "\n${Yellow}Testing $kernel...${NC}\n"
arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

sysver="20180409"
sysdir="$FSDIRARM/aarch-system-${sysver}"

target="test_kernel"
config_script="configs/example/fs.py"
ncpus="1"
machine_opts="--machine-type=VExpress_GEM5_V1"
#cpu_type="TimingSimpleCPU"
cpu_type="AtomicSimpleCPU"
cpu_opts="--cpu-type=${cpu_type} --num-cpu=$ncpus"
cache_opts="--caches --l2cache"
kernel_opts="--kernel=${kernel}"
dtb_opts="--dtb=${sysdir}/binaries/armv7_gem5_v1_${ncpus}cpu.dtb"
gem5_opts="--remote-gdb-port=0"

sim_name="${target}_${cpu_type}_${ncores}c_${currtime}"

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
bootscript_opts="--script=$ROOTDIR/gem5/$bootscript"

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

export M5_PATH="${sysdir}":${M5_PATH}

# Start simulation
$gem5_elf $gem5_opts \
	-d $output_dir \
	$config_script \
	$machine_opts \
	$cpu_opts \
	$cache_opts \
	$kernel_opts \
	$dtb_opts \
	$bootscript_opts 2>&1 | tee $logfile

popd
