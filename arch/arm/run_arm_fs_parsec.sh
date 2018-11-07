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

source ../../common/defaults.in
source ../../common/util.in

sysver=20180409
imgdir="$FSDIRARM/aarch-system-${sysver}/disks"
bmsuite="parsec-3.0"
img="$imgdir/linaro-minimal-aarch64-${bmsuite}-inside.img"
bmsuiteroot="home"

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"
cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	build_gem5 $arch $mode
fi

benchmark_progs="
blackscholes
ferret
fluidanimate
"

currtime=$(date "+%Y.%m.%d-%H.%M.%S")
output_rootdir="fs_output_${bmsuite}_$currtime"
config_script="configs/example/arm/starter_fs.py"
ncores="2"
cpu_options="--cpu=hpi --num-cores=$ncores"
mem_options="--mem-size=1GB"
#tlm_options="--tlm-memory"
disk_options="--disk-image=$img"
kernel="--kernel=$FSDIRARM/aarch-system-${sysver}/binaries/vmlinux.vexpress_gem5_v1_64"
dtb="--dtb=$FSDIRARM/aarch-system-${sysver}/binaries/armv8_gem5_v1_${ncores}cpu.dtb"

bmsuitedir="/$bmsuiteroot/$bmsuite"
parsec_input="simsmall"
#parsec_input="simmedium"
#parsec_input="simlarge"
parsec_nthreads="$ncores"

for b in $benchmark_progs; do
	bootscript=${b}_${parsec_input}_${parsec_nthreads}.rcS
	cat > $bootscript <<- EOM
	#!/bin/bash
	cd $bmsuitedir
	source ./env.sh
	echo "Running parsec $b input $parsec_input threads $parsec_nthreads"
	parsecmgmt -a run -p $b -c gcc-hooks -i $parsec_input -n $parsec_nthreads
	echo "Benchmark finished."
	sleep 1
	m5 exit
	EOM
	bootscript_options="--script=$ROOTDIR/gem5/$bootscript"
	output_dir="$output_rootdir/$b"
	export M5_PATH="$FSDIRARM/aarch-system-${sysver}":${M5_PATH}
	$gem5_elf -d $output_dir $config_script $cpu_options $mem_options $tlm_options $kernel $dtb $disk_options $bootscript_options &
done
wait
