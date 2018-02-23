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
# Author: Shama Bhosale 

source ../../common/defaults.in
source ../../common/util.in


##Gem5.TnT repository
basedir="$PWD/../.."

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

cd $ROOTDIR/gem5

currtime=$(date "+%Y.%m.%d-%H.%M.%S")
outdir="hbm_se_output_$currtime"

R='\033[0;31m'
NC='\033[0m'

cd $ROOTDIR/gem5

printf "\n----------------------------------------------------------------------\n"
printf "${R}Patching the required gem5 files for running the current example"
printf "\n----------------------------------------------------------------------\n"

patch -p1 -f < $basedir/patches/gem5/HBM_elastic_traces/hbm.patch

printf "\n----------------------------------------------------------------------\n"
printf "${R}Building gem5 after patching"
printf "\n----------------------------------------------------------------------\n"


getnumprocs np
nj=`expr $np - 1`
scons $gem5_elf -j$nj

printf "\n----------------------------------------------------------------------\n"
printf "${R}Running basic Elastic trace HBM example"
printf "\n----------------------------------------------------------------------\n"
hbmscript="configs/example/hbm_hello.py"

hbmopts="--mem-size=1GB --data-trace-file=$basedir/elastic_traces/system.cpu.traceListener.random.data.gz --inst-trace-file=$basedir/elastic_traces/system.cpu.traceListener.random.inst.gz"
od="$outdir"
$gem5_elf -d $od $hbmscript $hbmopts

printf "\n----------------------------------------------------------------------\n"
printf "${R}Check each of the subfolders inside $outdir.${NC}\n"
printf "${R}Take a look at the generated config.dot.pdf and stats.txt files inside $outdir.${NC}"
printf "\n----------------------------------------------------------------------\n"
