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
domain="automotive"
bdir="$basedir/${domain}"
refbasedir="$BENCHMARKSDIR/MiBench/outputs/${domain}"

# compile the programs
pushd $bdir
bmdirs="
basicmath
bitcount
qsort
susan
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

outdir="se_mibench_automotive_$currtime"

# step 1: simulate
# step 2: compare output with reference provided

# basicmath small
od="$outdir/basicmath/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/basicmath/basicmath_small 2>&1 | tee $od/output_small.txt
diff $od/output_small.txt $refbasedir/basicmath/output_small.txt > $od/output_small.txt.diff

# basicmath large
od="$outdir/basicmath/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/basicmath/basicmath_large 2>&1 | tee $od/output_large.txt
diff $od/output_large.txt $refbasedir/basicmath/output_large.txt > $od/output_large.txt.diff

# bitcnts small
od="$outdir/bitcount/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/bitcount/bitcnts -o 75000 2>&1 | tee $od/output_small.txt
diff $od/output_small.txt $refbasedir/bitcount/output_small.txt > $od/output_small.txt.diff

# bitcnts large
od="$outdir/bitcount/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/bitcount/bitcnts -o 1125000 2>&1 | tee $od/output_large.txt
diff $od/output_large.txt $refbasedir/bitcount/output_large.txt > $od/output_large.txt.diff

# qsort small
od="$outdir/qsort/small"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/qsort/qsort_small -o $bdir/qsort/input_small.dat 2>&1 | tee $od/output_small.txt
diff $od/output_small.txt $refbasedir/qsort/output_small.txt > $od/output_small.txt.diff

# qsort large
od="$outdir/qsort/large"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/qsort/qsort_large -o $bdir/qsort/input_large.dat 2>&1 | tee $od/output_large.txt
diff $od/output_large.txt $refbasedir/qsort/output_large.txt > $od/output_large.txt.diff

# susan small smoothing
od="$outdir/susan/small/smoothing"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_small.pgm $od/output_small.smoothing.pgm -s"
diff $od/output_small.smoothing.pgm $refbasedir/susan/output_small.smoothing.pgm > $od/output_small.smoothing.pgm.diff

# susan small edges
od="$outdir/susan/small/edges"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_small.pgm $od/output_small.edges.pgm -e"
diff $od/output_small.edges.pgm $refbasedir/susan/output_small.edges.pgm > $od/output_small.edges.pgm.diff

# susan small corners
od="$outdir/susan/small/corners"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_small.pgm $od/output_small.corners.pgm -c"
diff $od/output_small.corners.pgm $refbasedir/susan/output_small.corners.pgm > $od/output_small.corners.pgm.diff

# susan large smoothing
od="$outdir/susan/large/smoothing"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_large.pgm $od/output_large.smoothing.pgm -s"
diff $od/output_large.smoothing.pgm $refbasedir/susan/output_large.smoothing.pgm > $od/output_large.smoothing.pgm.diff

# susan large edges
od="$outdir/susan/large/edges"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_large.pgm $od/output_large.edges.pgm -e"
diff $od/output_large.edges.pgm $refbasedir/susan/output_large.edges.pgm > $od/output_large.edges.pgm.diff

# susan large corners
od="$outdir/susan/large/corners"
mkdir -p $od
$gem5_elf -d $od $script $script_opts -c $bdir/susan/susan -o "$bdir/susan/input_large.pgm $od/output_large.corners.pgm -c"
diff $od/output_large.corners.pgm $refbasedir/susan/output_large.corners.pgm > $od/output_large.corners.pgm.diff

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
