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

source ./common/util.in

instdep() {
	local plist="
	cowsay
	libnotify-bin
	swig
	m4
	mercurial
	scons
	python
	python-dev
	python-pydot
	python-protobuf
	libpython-dbg
	libpython2.7-dbg
	gcc
	g++
	libgoogle-perftools-dev
	protobuf-compiler
	libprotobuf-dev
	gcc-arm-linux-gnueabihf
	gcc-aarch64-linux-gnu
	device-tree-compiler
	libzstd-dev
	python-pthreading
	python-posix-ipc
	parted
	"

	echo -e -n "This is a list of known dependencies:" && echo ""
	for p in $plist; do
		echo $p
	done
	echo ""

	checkprivledges

	msg="I'm going to try to install the dependencies using the apt-get\
	command commonly found in debian like distros. If you're using\
	another distribution, please install them manually."
	echo -e -n $msg && echo ""
	echo ""

	for p in $plist; do
		local cmd="apt-get install -y $p"
		rctest $cmd
	done
}

greetings
# Check distro. This script supports Debian/Ubuntu
distro=`lsb_release -is`
if [ "$distro" != "Debian" ] && [ "$distro" != "Ubuntu" ]; then
	echo -e "Error unsupported distribution (${distro}). This script supports Debian/Ubuntu." 1>&2
	exit 1
fi
instdep
