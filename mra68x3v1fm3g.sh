#! /bin/bash

#
# Copyright (c) 2016, Éder F. Zulian
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
#

function abort {
	echo -e -n "\n\033[31mAborting.\n"; exit
}

function rctest {
	"$@"
	local status=$?
	if [ $status -ne 0 ]; then
		echo -e -n "\n\033[31mError executing \"$@\".\n" >&2; echo -en "\e[0m"; abort;
	fi
	return $status
}

function cmdtest {
	hash $@ 2>/dev/null || { echo >&2 "\"$@\" could not be found."; abort; }
}

function archdetect {
	local arch=$(uname -m)
	if [ "$arch" = "i686" ]; then
		notify-send "Architecture is 32-bit"
	fi
	if [ "$arch" = "x86_64" ]; then
		notify-send "Architecture is 64-bit"
	fi
}

function chessit {
	echo ""
	for (( r = 0; r < 28; r++ ))
	do
		for (( c = 0 ; c < 80; c++ ))
		do
			local sqrs=`expr $r + $c`
			local odd=`expr $sqrs % 2`
			if [ $odd -eq 0 ]; then
				echo -e -n "\033[47m "
			else
				echo -e -n "\033[40m "
			fi
		done
		echo -e -n "\033[40m" && echo ""
	done
	echo ""
}

function greetings {
	echo ""
	echo -e -n "Greetings $USER!" && echo ""
	echo -e -n "You're currently on $HOSTNAME. Your home folder is $HOME." && echo ""
	echo -e -n "This will take some time. It's a good opportunity to get some coffee." && echo ""
	echo ""
}

function instdep {
	local plist="
	swig
	m4
	mercurial
	scons
	python
	python-dev
	gcc
	g++
	libgoogle-perftools-dev
	protobuf-compiler
	gcc-arm-linux-gnueabihf
	gcc-aarch64-linux-gnu
	device-tree-compiler
	"
	echo -e -n "I need this:" && echo ""
	for p in $plist; do
		echo $p
	done
	echo ""
	echo -e -n "I'm gonna try to install now." && echo ""
	sleep 3

	cmdtest apt-get
	for p in $plist; do
		local cmd="sudo apt-get install $p"
		rctest $cmd
	done
}

function getgem5stuff {
	cmdtest hg
	cmdtest git
	cmdtest wget
	cmdtest tar

	local rootdir=$HOME/gem5_simulator
	local docdir=$rootdir/doc
	local tutorialsdir=$rootdir/doc/tutorials
	local tutorialsdir1=$tutorialsdir/hipeac2012
	local tutorialsdir2=$tutorialsdir/video
	local fsstuffdir=$rootdir/full_system_stuff
	local fsstuffdirarm=$fsstuffdir/arm
	local fsstuffdirx86=$fsstuffdir/x86
	local benchmarksdir=$rootdir/benchmarks

	local dirtree="
	$rootdir
	$docdir
	$tutorialsdir
	$tutorialsdir1
	$tutorialsdir2
	$fsstuffdir
	$fsstuffdirarm
	$fsstuffdirx86
	$benchmarksdir
	"
	for n in $dirtree; do
		local c="mkdir $n"
		rctest $c
	done

	# Clone repos
	hgrepos=(
	#"$rootdir,http://repo.gem5.org/gem5"
	"$rootdir,http://repo.gem5.org/linux-patches"
	"$rootdir,http://repo.gem5.org/tutorial"
	"$rootdir,http://repo.gem5.org/m5threads"
	"$benchmarksdir,ssh://hg@bitbucket.org/yongbing_huang/asimbench"
	)

	for repo in "${hgrepos[@]}"; do
		cd ${repo%%,*}
		hg clone ${repo#*,}
		printf "%s cloned into %s.\n" "${repo#*,}" "${repo%%,*}"
	done

	gitrepos=(
	"$rootdir:git@github.com:gem5/gem5.git"
	"$rootdir:git@github.com:gem5/linux-arm-gem5.git"
	)

	for repo in "${gitrepos[@]}"; do
		cd ${repo%%:*}
		git clone --recursive ${repo#*:}
		printf "%s cloned into %s.\n" "${repo#*,}" "${repo%%,*}"
	done

	wgethis=(
	# Benchmarks
	"$benchmarksdir:http://www.gem5.org/dist/m5_benchmarks/v1-splash-alpha.tgz"
	"$benchmarksdir:http://downloads.sourceforge.net/project/dacapobench/9.12-bach/dacapo-9.12-bach.jar"
	# Documentation
	"$docdir:http://gem5.org/wiki/images/5/53/2015_ws_04_ISCA_2015_NoMali.pdf"
	"$docdir:http://gem5.org/wiki/images/f/f7/2015_ws_02_hansson_gem5_workshop_2015.pdf"
	"$docdir:http://gem5.org/wiki/images/4/4c/2015_ws_09_2015-06-14_Gem5_ISCA.pptx"
	# Tutorials
	"$tutorialsdir:http://www.gem5.org/dist/tutorials/isca_pres_2011.pdf"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/asplos_pres.pdf"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/asplos_hand.pdf"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/isca_pres.pdf"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/isca_hand.pdf"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/tutorial.ppt"
	"$tutorialsdir:http://www.m5sim.org/dist/tutorials/tutorial.pdf"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/gem5_hipeac.pdf"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/01.overview.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/02.introduction.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/03.basics.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/04.running_experiment.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/05.debugging.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/06.memory.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/07.cpu_models.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/08.common_tasks.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/09.configuration.m4v"
	"$tutorialsdir1:http://gem5.org/dist/tutorials/hipeac2012/10.conclusions.m4v"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/introduction.mov"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/running.mov"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/fullsystem.mov"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/objects.mov"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/extending.mov"
	"$tutorialsdir2:http://www.m5sim.org/dist/tutorials/debugging.mov"
	)
	for g in "${wgethis[@]}"; do
		cd ${g%%:*}
		wget ${g#*:}
		printf "%s wget into %s.\n" "${g#*:}" "${g%%:*}"
	done

	# Full system stuff
	# ARM
	cd $fsstuffdirarm && mkdir 20141001 && cd 20141001
	wget http://www.gem5.org/dist/current/arm/aarch-system-2014-10.tar.xz && tar -xvJf aarch-system-2014-10.tar.xz
	cd $fsstuffdirarm && mkdir legacy && cd legacy
	# ARMv8 Full-System Files -- Pre-compiled kernel and disk image for the 64 bit ARMv8 ISA.
	wget http://www.gem5.org/dist/current/arm/arm64-system-02-2014.tgz && tar -xvzf arm64-system-02-2014.tgz
	# VExpress_EMM kernel w/PCI support and config - Pre-compiled Linux 3.3 VExpress_EMM kernel that includes support for PCIe devices, a patch to add gem5 PCIe support to the revision of the vexpress kernel tree and a config file. This kernel is needed if you want to simulated more than 256MB of RAM or networking. Pass kernel=/path/to/vmlinux-3.3-arm-vexpress-emm-pcie machine-type=VExpress_EMM on the command line. You'll still need the file systems below. This kernel supports a maximum of 2047MB (one MB less than 2GB) of memory.
	wget http://www.gem5.org/dist/current/arm/vmlinux-emm-pcie-3.3.tar.bz2 && tar xvjf vmlinux-emm-pcie-3.3.tar.bz2
	# New Full System Files -- Pre-compiled Linux kernel, and file systems, and kernel config files. This includes both a cut-down linux and a full ubuntu linux.
	wget http://www.gem5.org/dist/current/arm/arm-system-2011-08.tar.bz2 && tar -xvjf arm-system-2011-08.tar.bz2
	# Old Full System Files -- Older pre-compiled Linux kernel, and file system.
	wget http://www.m5sim.org/dist/current/arm/arm-system.tar.bz2 && tar -xvjf arm-system.tar.bz2
	# X86
	cd $fsstuffdirx86
	# The kernel used for regressions, an SMP version of it, and a disk image
	wget http://www.m5sim.org/dist/current/x86/x86-system.tar.bz2 && tar -xvjf x86-system.tar.bz2
	# Config files for both of the above kernels, 2.6.25.1 and 2.6.28.4
	wget http://www.m5sim.org/dist/current/x86/config-x86.tar.bz2 && tar -xvjf config-x86.tar.bz2

	cd $fsstuffdirarm && mkdir 20170421 && cd 20170421
	wget http://www.gem5.org/dist/current/arm/aarch-system-20170421.tar.xz && tar -xvJf aarch-system-20170421.tar.xz
}

archdetect
chessit
greetings
instdep
getgem5stuff

