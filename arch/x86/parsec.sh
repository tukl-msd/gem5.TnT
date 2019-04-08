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

sys='x86-system'

arch="X86"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

$TOPDIR/get_essential_fs.sh

pushd ${FSDIRX86}
tarball="${sys}.tar.bz2"
if [[ ! -e $tarball ]]; then
	wgethis=("$FSDIRX86:http://www.m5sim.org/dist/current/x86/$tarball")
	wget_into_dir wgethis[@]
fi
if [[ ! -d ${sys} ]]; then
	mkdir -p ${sys}
	tar -xaf ${tarball} -C ${sys}
fi
# download kernel
kernel="x86_64-vmlinux-2.6.28.4-smp"
kurl="http://www.cs.utexas.edu/~parsec_m5/$kernel"
wget -N $kurl -P ${sys}/binaries
# download disk tarball
disk="x86root-parsec.img"
disktb="${disk}.bz2"
disktburl="http://www.cs.utexas.edu/~parsec_m5/$disktb"
if [[ ! -e "${sys}/disks/${disk}" ]]; then
	wget -N $disktburl
	bunzip2 $disktb
	mv $disk ${sys}/disks
fi
# copy swap disk from ALPHA
swapd="linux-bigswap2.img"
if [[ ! -e "${sys}/disks/${swapd}" ]]; then
	cp $FSDIRALPHA/m5_system_2.0b3/disks/${swapd} ${sys}/disks
fi
popd

# apply patch, build gem5
pushd $ROOTDIR/gem5
printf "${Red}Stashing local changes...${NC}\n"
git stash > /dev/null 2>&1
printf "${Yellow}Applying a patch...${NC}\n"
git apply $DIR/parsec.patch
printf "${Green}Building...${NC}\n"
build_gem5 $arch $mode
popd

syspath="$FSDIRX86/${sys}"
diskpath="${syspath}/disks"
cfgscript="configs/example/fs.py"
disk_opt="--disk-image=${diskpath}/${disk}"
kernel_opt="--kernel=${kernel}"

# ncpus: 1, 2, 4, 8, 16
ncpus="2"
mem_size="1GB"
cpu_type="TimingSimpleCPU"
#cpu_type="AtomicSimpleCPU"
#cpu_type="NonCachingSimpleCPU"
cpu_opt="--cpu-type=${cpu_type} --num-cpus=${ncpus}"
mem_opt="--mem-size=${mem_size}"

cache_opt="--caches --l2cache"
l1_cache_opt="--l1d_size=64kB --l1i_size=64kB --l1d_assoc=4 --l1i_assoc=4"
l2_cache_opt="--l2_size=1024kB --l2_assoc=8"

target="x86_parsec"
sim_name="${target}_${cpu_type}_${ncpus}c_${mem_size}_${currtime}"

cmd="./canneal ${ncpus} 5 100 /parsec/install/inputs/canneal/10.nets 1"
#cmd="./canneal ${ncpus} 100 300 /parsec/install/inputs/canneal/100.nets 2"
#cmd="./canneal ${ncpus} 10000 2000 /parsec/install/inputs/canneal/100000.nets 32"
#cmd="./canneal ${ncpus} 15000 2000 /parsec/install/inputs/canneal/200000.nets 64"
#cmd="./canneal ${ncpus} 15000 2000 /parsec/install/inputs/canneal/400000.nets 128"
# facesim
#cmd="./facesim -timing -threads ${ncpus}"
# ferret
#cmd="./ferret /parsec/install/inputs/ferret/corelt lsh /parsec/install/inputs/ferret/queriest 1 1 ${ncpus} /parsec/install/inputs/ferret/output.txt"
#cmd="./ferret /parsec/install/inputs/ferret/coreld lsh /parsec/install/inputs/ferret/queriesd 5 5 ${ncpus} /parsec/install/inputs/ferret/output.txt"
#cmd="./ferret /parsec/install/inputs/ferret/corels lsh /parsec/install/inputs/ferret/queriess 10 20 ${ncpus} /parsec/install/inputs/ferret/output.txt"
#cmd="./ferret /parsec/install/inputs/ferret/corelm lsh /parsec/install/inputs/ferret/queriesm 10 20 ${ncpus} /parsec/install/inputs/ferret/output.txt"
#cmd="./ferret /parsec/install/inputs/ferret/corell lsh /parsec/install/inputs/ferret/queriesl 10 20 ${ncpus} /parsec/install/inputs/ferret/output.txt"
# vips
#cmd="export IM_CONCURRENCY=${ncpus} && ./vips im_benchmark /parsec/install/inputs/vips/barbados_256x288.v /parsec/install/inputs/vips/output.v"
#cmd="export IM_CONCURRENCY=${ncpus} && ./vips im_benchmark /parsec/install/inputs/vips/barbados_256x288.v /parsec/install/inputs/vips/output.v"
#cmd="export IM_CONCURRENCY=${ncpus} && ./vips im_benchmark /parsec/install/inputs/vips/pomegranate_1600x1200.v /parsec/install/inputs/vips/output.v"
#cmd="export IM_CONCURRENCY=${ncpus} && ./vips im_benchmark /parsec/install/inputs/vips/vulture_2336x2336.v /parsec/install/inputs/vips/output.v"
#cmd="export IM_CONCURRENCY=${ncpus} && ./vips im_benchmark /parsec/install/inputs/vips/bigben_2662x5500.v /parsec/install/inputs/vips/output.v"
# x264
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_32x18_1.y4m"
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_64x36_3.y4m"
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_640x360_8.y4m"
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_640x360_32.y4m"
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_640x360_128.y4m"
# swaptions
#cmd="./swaptions -ns 1 -sm 5 -nt ${ncpus}"
#cmd="./swaptions -ns 3 -sm 50 -nt ${ncpus}"
#cmd="./swaptions -ns 16 -sm 5000 -nt ${ncpus}"
#cmd="./swaptions -ns 32 -sm 10000 -nt ${ncpus}"
#cmd="./swaptions -ns 64 -sm 20000 -nt ${ncpus}"
# freqmine
#cmd="./freqmine /parsec/install/inputs/freqmine/T10I4D100K_3.dat 1"
#cmd="./freqmine /parsec/install/inputs/freqmine/T10I4D100K_1k.dat 3"
#cmd="./freqmine /parsec/install/inputs/freqmine/kosarak_250k.dat 220"
#cmd="./freqmine /parsec/install/inputs/freqmine/kosarak_500k.dat 410"
#cmd="./freqmine /parsec/install/inputs/freqmine/kosarak_990k.dat 790"
# fluidanimate
#cmd="./fluidanimate ${ncpus} 1 /parsec/install/inputs/fluidanimate/in_5K.fluid /parsec/install/inputs/fluidanimate/out.fluid"
#cmd="./fluidanimate ${ncpus} 3 /parsec/install/inputs/fluidanimate/in_15K.fluid /parsec/install/inputs/fluidanimate/out.fluid"
#cmd="./fluidanimate ${ncpus} 5 /parsec/install/inputs/fluidanimate/in_35K.fluid /parsec/install/inputs/fluidanimate/out.fluid"
#cmd="./fluidanimate ${ncpus} 5 /parsec/install/inputs/fluidanimate/in_100K.fluid /parsec/install/inputs/fluidanimate/out.fluid"
#cmd="./fluidanimate ${ncpus} 5 /parsec/install/inputs/fluidanimate/in_300K.fluid /parsec/install/inputs/fluidanimate/out.fluid"
# dedup
#cmd="./dedup -c -p -f -t ${ncpus} -i /parsec/install/inputs/dedup/test.dat -o /parsec/install/inputs/dedup/output.dat.ddp"
#cmd="./dedup -c -p -f -t ${ncpus} -i /parsec/install/inputs/dedup/hamlet.dat -o /parsec/install/inputs/dedup/output.dat.ddp"
#cmd="./dedup -c -p -f -t ${ncpus} -i /parsec/install/inputs/dedup/medias.dat -o /parsec/install/inputs/dedup/output.dat.ddp"
#cmd="./dedup -c -p -f -t ${ncpus} -i /parsec/install/inputs/dedup/mediam.dat -o /parsec/install/inputs/dedup/output.dat.ddp"
#cmd="./dedup -c -p -f -t ${ncpus} -i /parsec/install/inputs/dedup/medial.dat -o /parsec/install/inputs/dedup/output.dat.ddp"
# bodytrack
#cmd="./bodytrack /parsec/install/inputs/bodytrack/sequenceB_1 4 1 5 1 0 ${ncpus}"
#cmd="./bodytrack /parsec/install/inputs/bodytrack/sequenceB_1 4 1 100 3 0 ${ncpus}"
#cmd="./bodytrack /parsec/install/inputs/bodytrack/sequenceB_1 4 1 1000 5 0 ${ncpus}"
#cmd="./bodytrack /parsec/install/inputs/bodytrack/sequenceB_2 4 2 2000 5 0 ${ncpus}"
#cmd="./bodytrack /parsec/install/inputs/bodytrack/sequenceB_4 4 4 4000 5 0 ${ncpus}"
# blackscholes
#cmd="./blackscholes ${ncpus} /parsec/install/inputs/blackscholes/in_4.txt /parsec/install/inputs/blackscholes/prices.txt"
#cmd="./blackscholes ${ncpus} /parsec/install/inputs/blackscholes/in_16.txt /parsec/install/inputs/blackscholes/prices.txt"
#cmd="./blackscholes ${ncpus} /parsec/install/inputs/blackscholes/in_4K.txt /parsec/install/inputs/blackscholes/prices.txt"
#cmd="./blackscholes ${ncpus} /parsec/install/inputs/blackscholes/in_16K.txt /parsec/install/inputs/blackscholes/prices.txt"
#cmd="./blackscholes ${ncpus} /parsec/install/inputs/blackscholes/in_64K.txt /parsec/install/inputs/blackscholes/prices.txt"

create_checkpoint="no"
restore_checkpoint="no"
#tlm_options="--tlm-memory=transactor"

pushd $ROOTDIR/gem5

bootscript="${sim_name}.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf 'cd /parsec/install/bin\n' >> $bootscript
if [[ ${create_checkpoint} == "yes" ]]; then
	printf 'echo \"Creating checkpoint\"\n' >> $bootscript
	printf '/sbin/m5 checkpoint\n' >> $bootscript
	printf '/bin/bash\n' >> $bootscript
else
	printf 'echo \"Dumping and reseting stats\"\n' >> $bootscript
	printf '/sbin/m5 dumpresetstats\n' >> $bootscript
	printf "echo \"Command: $cmd\"\n" >> $bootscript
	printf "${cmd}\n" >> $bootscript
	printf 'echo \"Dumping and reseting stats\"\n' >> $bootscript
	printf '/sbin/m5 dumpresetstats\n' >> $bootscript
fi
script_opt="--script=$bootscript"

export M5_PATH="${syspath}":${M5_PATH}

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

if [[ ${restore_checkpoint} == "yes" ]]; then

	checkpoint_opts="--checkpoint-restore=1 --restore-with-cpu ${cpu_type}"
	timestamp="2019.04.04-20.24.11"
	checkpoint_dir="--checkpoint-dir=${target}_${cpu_type}_${ncpus}c_${mem_size}_${timestamp}"
	$gem5_elf -d $output_dir \
		$cfgscript \
		${checkpoint_opts} \
		${checkpoint_dir} \
		$cpu_opt \
		$cache_opt \
		$l1_cache_opt \
		$l2_cache_opt \
		$mem_opt 2>&1 | tee $logfile
else
	$gem5_elf -d $output_dir \
		$cfgscript \
		$cpu_opt \
		$cache_opt \
		$l1_cache_opt \
		$l2_cache_opt \
		$mem_opt \
		$tlm_options \
		$kernel_opt \
		$disk_opt \
		$script_opt 2>&1 | tee $logfile
fi
popd
