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
domain="telecomm"
bdir="$basedir/${domain}"
refbasedir="$BENCHMARKSDIR/MiBench/outputs/${domain}"

# compile the programs
pushd $bdir
bmdirs="
gsm
FFT
CRC32
adpcm/src
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
--mem-size=4GB --cacheline_size=64 \
--caches \
"

outdir="se_mibench_${domain}_$currtime"

# simulate

# gsm encode small
od="$outdir/gsm/encode/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/gsm/bin/toast -o "-fps -c $bdir/gsm/data/small.au" > $od/output_small.encode.gsm

# gsm encode large
od="$outdir/gsm/encode/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/gsm/bin/toast -o "-fps -c $bdir/gsm/data/large.au" > $od/output_large.encode.gsm

# gsm decode small
od="$outdir/gsm/decode/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/gsm/bin/untoast -o "-fps -c $bdir/gsm/data/small.au.run.gsm" > $od/output_small.decode.run

# gsm decode large
od="$outdir/gsm/decode/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/gsm/bin/untoast -o "-fps -c $bdir/gsm/data/large.au.run.gsm" > $od/output_large.decode.run



printf "${Yellow}Done.${NC}\n"
printf "${Yellow}The outputs can be found in $outdir ${NC}\n"

# search for unimplemented functionalities
pushd $outdir
printf "${Yellow}Searching for ${Red}\"unimplemented\"...${NC}\n"
grep "unimplemented" * -nrI > gem5-unimplemented-problems-found.txt
printf "${Yellow}Result saved in ${Green}$outdir/gem5-unimplemented-problems-found.txt${NC}\n"
popd

popd
