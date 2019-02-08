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
# Author: Éder F. Zulian

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

# Specify a commit hash (in long or short form), a branch or a tag to checkout
# before building gem5. Otherwise the top of the master branch will be used.
# Note: the build folder will be removed when 'gitbuildrev' and the HEAD
# (current commit) differ.
#gitbuildrev="a470ef51456fe05e8d8ae6a95493e1da5a088a0d"
gitbuildrev="a470ef5"

# Architectures to build
archs="
ARM
X86
"

# Gem5 Modes
modes="
opt
"

cd $ROOTDIR/gem5

# Check whether the 'gitbuildrev' variable is set or not
if [ -z ${gitbuildrev+x} ]; then
	# Variable 'gitbuildrev' is unset, use top of the master branch
	# Remove the build folder if the top of the master branch moved
	phead=$(git rev-parse HEAD)
	git checkout --quiet master > /dev/null 2>&1
	git pull --quiet
	chead=$(git rev-parse HEAD)
	if [[ "$chead" != "$phead" ]]; then
		rm -rf build
	fi
else
	# Variable 'gitbuildrev' is set, use commit specified
	chead=$(git rev-parse HEAD)
	cheadshort=$(git rev-parse --short HEAD)
	buildrev=$(git rev-parse $gitbuildrev)
	buildrevshort=$(git rev-parse --short $gitbuildrev)
	if [[ "$chead" != "$buildrev" && "$cheadshort" != "$buildrevshort" ]]; then
		# Delete the build folder if the desired and the current commit differ
		rm -rf build
		# Swtich to the target commit
		git checkout --quiet $gitbuildrev > /dev/null 2>&1
	fi
fi

for arch in $archs; do
	for mode in $modes; do
		# Build gem5
                build_gem5 $arch $mode
		# Build gem5 as a library
                build_libgem5 $arch $mode
	done
done
echo -e "Done."
