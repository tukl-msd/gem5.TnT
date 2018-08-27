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

source common/defaults.in
source common/util.in

archs="
ARM
X86
"

modes="
fast
opt
"

cd $ROOTDIR/gem5

getnumprocs np
njobs=`expr $np - 1`
for arch in $archs; do
	for mode in $modes; do
		# Build gem5
		target="build/$arch/gem5.$mode"
		scons $target -j$njobs
		# Build gem5 as a library
		target="build/$arch/libgem5_$mode.so"
		buildopts="--with-cxx-config --without-python --without-tcmalloc"
		scons $buildopts $target -j$njobs
	done
done

echo -e -n "\nDone.\n"

echo -e -n "\nThe following targets were successfully built:\n\n"
for arch in $archs; do
	for mode in $modes; do
		target="build/$arch/gem5.$mode"
		if [[ -e $target ]]; then
			file $target
			echo ""
		fi
		target="build/$arch/libgem5_$mode.so"
		if [[ -e $target ]]; then
			file $target
			echo ""
		fi
	done
done
