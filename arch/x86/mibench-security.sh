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

arch="X86"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

# get the source code
$TOPDIR/get_benchmarks.sh

basedir="$BENCHMARKSDIR/MiBench/benchmarks"
domain="security"
bdir="$basedir/${domain}"
refbasedir="$BENCHMARKSDIR/MiBench/outputs/${domain}"

# compile the programs
pushd $bdir
bmdirs="
sha
blowfish
rijndael
"

for b in $bmdirs; do
	make -C $b > /dev/null 2>&1
done
popd

# build gem5
pushd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi

script="configs/example/se.py"
script_opts=" \
--cpu-type=TimingSimpleCPU \
--mem-type=DDR4_2400_8x8 \
--mem-size=4GB \
--caches \
--cacheline_size=64 \
"

#script_opts=" \
#--cpu-type=TimingSimpleCPU \
#--caches \
#--cacheline_size=64 \
#--mem-type=SimpleMemory \
#--mem-channels=1 \
#--tlm-memory=transactor
#"

outdir="se_mibench_${domain}_$currtime"

# simulate

# blowfish encode small
ode="$outdir/blowfish/encode/small"
mkdir -p $ode
$gem5_elf -d $ode $script $script_opts -c $bdir/blowfish/bf -o "e $bdir/blowfish/input_small.asc $ode/output_small.enc 1234567890abcdeffedcba0987654321"

# blowfish decode small
odd="$outdir/blowfish/decode/small"
mkdir -p $odd
$gem5_elf -d $odd $script $script_opts -c $bdir/blowfish/bf -o "d $ode/output_small.enc $odd/output_small.asc 1234567890abcdeffedcba0987654321"

# blowfish encode large
ode="$outdir/blowfish/encode/large"
mkdir -p $ode
$gem5_elf -d $ode $script $script_opts -c $bdir/blowfish/bf -o "e $bdir/blowfish/input_large.asc $ode/output_large.enc 1234567890abcdeffedcba0987654321"

# blowfish decode small
odd="$outdir/blowfish/decode/large"
mkdir -p $odd
$gem5_elf -d $odd $script $script_opts -c $bdir/blowfish/bf -o "d $ode/output_large.enc $odd/output_large.asc 1234567890abcdeffedcba0987654321"

# rijndael encode small
#ode="$outdir/rijndael/encode/small"
#mkdir -p $ode
#$gem5_elf -d $ode $script $script_opts -c $bdir/rijndael/rijndael -o "$bdir/rijndael/input_small.asc $ode/output_small.enc e 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321"

# rijndael decode small
#odd="$outdir/rijndael/decode/small"
#mkdir -p $odd
#$gem5_elf -d $odd $script $script_opts -c $bdir/rijndael/rijndael -o "$ode/output_small.enc $odd/output_small.asc d 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321"

# rijndael encode large
#ode="$outdir/rijndael/encode/large"
#mkdir -p $ode
#$gem5_elf -d $ode $script $script_opts -c $bdir/rijndael/rijndael -o "e $bdir/rijndael/input_large.asc $ode/output_large.enc e 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321"

# rijndael decode small
#odd="$outdir/rijndael/decode/large"
#mkdir -p $odd
#$gem5_elf -d $odd $script $script_opts -c $bdir/rijndael/rijndael -o "d $ode/output_large.enc $odd/output_large.asc d 1234567890abcdeffedcba09876543211234567890abcdeffedcba0987654321"

# sha small
od="$outdir/sha/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/sha/sha -o "$bdir/sha/input_small.asc" > $od/output_small.txt

# sha large
od="$outdir/sha/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/sha/sha -o "$bdir/sha/input_large.asc" > $od/output_large.txt

printf "${Yellow}Done.${NC}\n"
printf "${Yellow}The outputs can be found in $outdir ${NC}\n"

pushd $outdir
pattern="warn:"
printf "${Yellow}Searching for ${Red}\"$pattern\"...${NC}\n"
report="Attention-Read-This.txt"
grep "$pattern" * -nrI > $report
printf "${Yellow}Results saved in ${Green}$outdir/${report}${NC}\n"
popd

popd
