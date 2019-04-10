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

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"
cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	build_gem5 $arch $mode
fi

currtime=$(date "+%Y.%m.%d-%H.%M.%S")
outdir="stream_se_$currtime"
script="configs/example/se.py"
ncpus="1"
cpu_type="TimingSimpleCPU"
mem_size="512MB"
mem_ch="1"
workload="$BENCHMARKSDIR/stream/stream_c.exe"
#tlm_options="--tlm-memory=transactor"

pushd $ROOTDIR/gem5 

# Check if 'tlm_options' variable is set
if [ ! -z ${tlm_options+x} ]; then
	# Variable 'tlm_options' is set, apply patch
	printf "${Yellow}Stashing local changes...${NC}\n"
	git stash > /dev/null 2>&1
	printf "${Green}Applying TLM related patch...${NC}\n"
	git apply $DIR/stream-se-tlm.patch  > /dev/null 2>&1
fi

mkdir -p ${outdir}
logfile="${outdir}/gem5.log"

$gem5_elf -d $outdir \
	$script \
	--cpu-type=${cpu_type} \
	--num-cpu=$ncpus \
	--mem-size=${mem_size} \
	--mem-channels=${mem_ch} \
	--caches \
	--l2cache \
	$tlm_options \
	-c $workload 2>&1 | tee $logfile
popd
