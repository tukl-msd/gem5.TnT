#! /bin/bash

# Copyright (c) 2016, University of Kaiserslautern
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

source ./util.sh

function getrepos {
	local rootdir=$HOME/gem5_simulator
	local dirtree="
	$rootdir
	"
	for n in $dirtree; do
		local c="mkdir -p $n"
		rctest $c
	done

	# Mercurial repositories
	hgrepos=(
	"$rootdir,http://repo.gem5.org/linux-patches"
	"$rootdir,http://repo.gem5.org/tutorial"
	"$rootdir,http://repo.gem5.org/m5threads"
	)
	cmdtest hg
	for repo in "${hgrepos[@]}"; do
		cd ${repo%%,*}
		hg clone ${repo#*,}
		printf "%s cloned into %s.\n\n" "${repo#*,}" "${repo%%,*}"
	done

	# git repositories
	gitrepos=(
	"$rootdir:https://github.com/gem5/linux-arm-gem5.git"
	"$rootdir:https://gem5.googlesource.com/public/gem5"
	"$rootdir:git@github.com:powerjg/learning_gem5.git"
	)
	cmdtest git
	for repo in "${gitrepos[@]}"; do
		cd ${repo%%:*}
		git clone --recursive ${repo#*:}
		printf "%s cloned into %s.\n\n" "${repo#*,}" "${repo%%,*}"
	done
}

greetings
getrepos
