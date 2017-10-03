#!/bin/bash

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

source ./defaults.in
source ./util.in

gem5_elf="build/ARM/gem5.opt"
cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	getnumprocs np
	scons $gem5_elf -j$np
fi

benchmark_progs_path="$BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/Stanford"
benchmark_progs="
Bubblesort
IntMM
Oscar
Perm
Puzzle
Queens
Quicksort
RealMM
Towers
Treesort
"
config_script="configs/example/arm/starter_se.py"
cpu_options="--cpu=hpi"
currtime=$(date "+%Y.%m.%d-%H.%M.%S")
output_rootdir="se_output_$currtime"
for b in $benchmark_progs; do
	output_dir="$output_rootdir/$b"
	$gem5_elf -d $output_dir $config_script $cpu_options $benchmark_progs_path/$b
done
