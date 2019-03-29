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
TOPDIR=$DIR
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

wgethis=(
"$TUTORIALSDIR:http://gem5.org/wiki/images/0/0e/ASPLOS2017_gem5_tutorial.pdf"
"$TUTORIALSDIR:http://gem5.org/wiki/images/5/53/2015_ws_04_ISCA_2015_NoMali.pdf"
"$TUTORIALSDIR:http://gem5.org/wiki/images/f/f7/2015_ws_02_hansson_gem5_workshop_2015.pdf"
"$TUTORIALSDIR:http://gem5.org/wiki/images/4/4c/2015_ws_09_2015-06-14_Gem5_ISCA.pptx"
# Tutorials
"$TUTORIALSDIR:http://www.gem5.org/dist/tutorials/isca_pres_2011.pdf"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/asplos_pres.pdf"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/asplos_hand.pdf"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/isca_pres.pdf"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/isca_hand.pdf"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/tutorial.ppt"
"$TUTORIALSDIR:http://www.m5sim.org/dist/tutorials/tutorial.pdf"
# HiPEAC - European Network on High Performance and Embedded Architecture and Compilation
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/gem5_hipeac.pdf"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/01.overview.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/02.introduction.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/03.basics.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/04.running_experiment.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/05.debugging.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/06.memory.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/07.cpu_models.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/08.common_tasks.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/09.configuration.m4v"
"$TUTORIALSDIR1:http://gem5.org/dist/tutorials/hipeac2012/10.conclusions.m4v"
# Videos
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/introduction.mov"
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/running.mov"
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/fullsystem.mov"
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/objects.mov"
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/extending.mov"
"$TUTORIALSDIR2:http://www.m5sim.org/dist/tutorials/debugging.mov"
)

# git repositories
gitrepos=(
"$DOCDIR:git@github.com:powerjg/learning_gem5.git"
)

greetings
wget_into_dir wgethis[@]
git_clone_into_dir gitrepos[@]
