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

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

# Set to "yes" or "no" in order to enable a spinner or not.
spinner="yes"

# gem5 configuration script to be used. se.py, starter_se.py, etc.
script="se.py"

ncores="1"
currtime=$(date "+%Y.%m.%d-%H.%M.%S")
output_rootdir="se_output_$currtime"
#tlm_options="--tlm-memory=transactor"

if [ "$script" == "starter_se.py" ]; then
	config_script="configs/example/arm/starter_se.py"
	cpu_options="--cpu=hpi --num-cores=$ncores"
	mem_options="--mem-channels=1"
elif [ "$script" == "se.py" ]; then
	config_script="configs/example/se.py"
	cpu_options="--cpu-type=TimingSimpleCPU --num-cpu=$ncores"
	mem_options="--mem-size=512MB --mem-channels=1 --caches --l2cache --mem-type=SimpleMemory"
else
	echo && echo "Please define options for $script" && echo && exit
fi

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"
cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	build_gem5 $arch $mode
fi

apps=(
"test-suite/SingleSource/Benchmarks/Stanford:Bubblesort"
"test-suite/SingleSource/Benchmarks/Stanford:FloatMM"
"test-suite/SingleSource/Benchmarks/Stanford:IntMM"
"test-suite/SingleSource/Benchmarks/Stanford:Oscar"
"test-suite/SingleSource/Benchmarks/Stanford:Perm"
"test-suite/SingleSource/Benchmarks/Stanford:Puzzle"
"test-suite/SingleSource/Benchmarks/Stanford:Queens"
"test-suite/SingleSource/Benchmarks/Stanford:Quicksort"
"test-suite/SingleSource/Benchmarks/Stanford:RealMM"
"test-suite/SingleSource/Benchmarks/Stanford:Towers"
"test-suite/SingleSource/Benchmarks/Stanford:Treesort"
"test-suite/SingleSource/Benchmarks/McGill:chomp"
"test-suite/SingleSource/Benchmarks/McGill:exptree"
"test-suite/SingleSource/Benchmarks/McGill:misr"
"test-suite/SingleSource/Benchmarks/McGill:queens"
)

# start spinner
if [ "$spinner" = "yes" ]; then
	pulse &
	pupid=$!
fi
declare -a pids
for e in "${apps[@]}"; do
	b=${e#*:}
	path=${e%%:*}
	output_dir="$output_rootdir/$b"
	mkdir -p ${output_dir}
	logfile=${output_dir}/${b}.log
	workload=""
	wl="$BENCHMARKSDIR/$path/$b"
	for ((c = 0; c < ncores; c++)); do
		workload+="$wl "
	done
	if [ "$script" == "starter_se.py" ]; then
		cmd="$gem5_elf -d $output_dir $config_script $cpu_options $mem_options $tlm_options $workload"
	elif [ "$script" == "se.py" ]; then
		cmd="$gem5_elf -d $output_dir $config_script -c $workload $mem_options $cpu_options $tlm_options"
	else
		echo && echo "Please define the command line for $script" && echo && exit
	fi
	$cmd > $logfile 2>&1 & pids+=($!)
done
wait "${pids[@]}"
unset pids
# stop spinner
if [ "$spinner" = "yes" ]; then
	kill $pupid &>/dev/null
fi
