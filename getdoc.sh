#! /bin/bash

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

function getdoc {
	local dirtree="
	$ROOTDIR
	$DOCDIR
	$TUTURIALSDIR
	$TUTURIALSDIR1
	$TUTURIALSDIR2
	"
	for n in $dirtree; do
		local c="mkdir -p $n"
		rctest $c
	done

	wgethis=(
	# Documentation
	"$DOCDIR:http://gem5.org/wiki/images/5/53/2015_ws_04_ISCA_2015_NoMali.pdf"
	"$DOCDIR:http://gem5.org/wiki/images/f/f7/2015_ws_02_hansson_gem5_workshop_2015.pdf"
	"$DOCDIR:http://gem5.org/wiki/images/4/4c/2015_ws_09_2015-06-14_Gem5_ISCA.pptx"
	# Tutorials
	"$TUTURIALSDIR:http://www.gem5.org/dist/tutorials/isca_pres_2011.pdf"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/asplos_pres.pdf"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/asplos_hand.pdf"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/isca_pres.pdf"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/isca_hand.pdf"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/tutorial.ppt"
	"$TUTURIALSDIR:http://www.m5sim.org/dist/tutorials/tutorial.pdf"
	# HiPEAC - European Network on High Performance and Embedded Architecture and Compilation
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/gem5_hipeac.pdf"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/01.overview.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/02.introduction.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/03.basics.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/04.running_experiment.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/05.debugging.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/06.memory.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/07.cpu_models.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/08.common_tasks.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/09.configuration.m4v"
	"$TUTURIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/10.conclusions.m4v"
	# Videos
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/introduction.mov"
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/running.mov"
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/fullsystem.mov"
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/objects.mov"
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/extending.mov"
	"$TUTURIALSDIR2:http://www.m5sim.org/dist/tutorials/debugging.mov"
	)
	cmdtest wget
	for g in "${wgethis[@]}"; do
		cd ${g%%:*}
		wget -nc ${g#*:}
		printf "%s downloaded into %s.\n\n" "${g#*:}" "${g%%:*}"
	done
}

greetings
getdoc
