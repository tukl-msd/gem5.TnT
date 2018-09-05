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

source ../../common/defaults.in
source ../../common/util.in

basedir="$PWD/../.."

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

cd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	build_gem5 $arch $mode
fi

currtime=$(date "+%Y.%m.%d-%H.%M.%S")
outdir="hmc_se_output_$currtime"

printf "\n----------------------------------------------------------------------\n"
printf "${Red}Running basic HMC examples${NC}"
printf "\n----------------------------------------------------------------------\n"
hmcscript="configs/example/hmctest.py"

hmcopts=""
od="$outdir/test1"
$gem5_elf -d $od $hmcscript $hmcopts

printf "\n----------------------------------------------------------------------\n"

hmcopts="--enable-global-monitor --enable-link-monitor --arch=same"
od="$outdir/test2"
$gem5_elf -d $od $hmcscript $hmcopts

printf "\n----------------------------------------------------------------------\n"

hmcopts="--enable-global-monitor --enable-link-monitor --arch=mixed"
od="$outdir/test3"
$gem5_elf -d $od $hmcscript $hmcopts

printf "\n----------------------------------------------------------------------\n"
printf "${Red}Running simple hello world script using HMC${NC}"
printf "\n----------------------------------------------------------------------\n"
hmcscript="configs/example/hmc_hello.py"

hmcopts=""
od="$outdir/hello1"
$gem5_elf -d $od $hmcscript $hmcopts

printf "\n----------------------------------------------------------------------\n"

hmcopts="--enable-global-monitor --enable-link-monitor"
od="$outdir/hello2"
$gem5_elf -d $od $hmcscript $hmcopts

printf "\n----------------------------------------------------------------------\n"
printf "${Red}Check each of the subfolders inside $outdir.${NC}\n"
printf "${Red}Take a look at the generated config.dot.pdf and stats.txt files.${NC}"
printf "\n----------------------------------------------------------------------\n"
