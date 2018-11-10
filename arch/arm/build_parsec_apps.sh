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
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

toolchain=gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu
toolchaintarball=$toolchain.tar.xz
wgethis=(
"$TOOLCHAINSDIR_ARM:https://releases.linaro.org/components/toolchain/binaries/5.4-2017.05/aarch64-linux-gnu/$toolchaintarball"
)

greetings
wgetintodir wgethis[@]

toolchaindir=$TOOLCHAINSDIR_ARM/$toolchain
if [[ ! -d $toolchaindir ]]; then
	tar -xaf $TOOLCHAINSDIR_ARM/$toolchaintarball -C $TOOLCHAINSDIR_ARM
fi

parsecdir="$BENCHMARKSDIR/parsec-3.0"
parsectarball="parsec-3.0.tar.gz"
if [[ ! -d $parsecdir ]]; then
	tarball=$BENCHMARKSDIR/$parsectarball
	echo -ne "Uncompressing $tarball. Please wait.\n"
	tar -xaf $tarball -C $BENCHMARKSDIR
	cd $parsecdir
	git init
	git add .
	git commit -m "Adding files to repository"
	cd -
else
	cd $parsecdir
	git checkout .
	git clean -fdx
	cd -
fi

patchfile="$TOPDIR/patches/parsec/x86_host_cross_aarch64-linux-gnu.patch"
patch -fs -d $parsecdir -p1 < $patchfile &>/dev/null

tempdir=`mktemp -d`
wget -O $tempdir/config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
wget -O $tempdir/config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
replacefiles="
config.guess
config.sub
"
for f in $replacefiles; do
	find $parsecdir -name $f -type f -print0 -execdir cp {} $f.backup \;
	find $parsecdir -name $f -type f -print0 -execdir cp $tempdir/$f {} \;
done

sedfile="$parsecdir/config/gcc.bldconf"
cchome="$toolchaindir"
binutilhome="$toolchaindir/aarch64-linux-gnu"
crossprefix="aarch64-linux-gnu-"
cc="$cchome/bin/${crossprefix}gcc"
cxx="$cchome/bin/${crossprefix}g++"
cpp="$cchome/bin/${crossprefix}cpp"
sed -i "s@CC_HOME=\"/usr\"@CC_HOME=\"$cchome\"@g" $sedfile
sed -i "s@BINUTIL_HOME=\"/usr\"@BINUTIL_HOME=\"$binutilhome\"@g" $sedfile
sed -i "s@CC=\"\${CC_HOME}/bin/gcc\"@CC=\"$cc\"@g" $sedfile
sed -i "s@CXX=\"\${CC_HOME}/bin/g++\"@CXX=\"$cxx\"@g" $sedfile
sed -i "s@CPP=\"\${CC_HOME}/bin/cpp\"@CPP=\"$cpp\"@g" $sedfile

cd $parsecdir
source env.sh
export PARSECPLAT="aarch64-linux"

apps="
blackscholes
bodytrack
facesim
ferret
fluidanimate
freqmine
swaptions
"
#raytrace
#vips
#x264

kernels="
streamcluster
"
#canneal
#dedup

for a in $apps; do
	parsecmgmt -a build -c gcc-hooks -p $a
done

for k in $kernels; do
	parsecmgmt -a build -c gcc-hooks -p $k
done

basepath="$parsecdir/pkgs/apps"
for a in $apps; do
	elf=$basepath/$a/inst/aarch64-linux.gcc-hooks/bin/$a
	echo "------------------------------" 
	file $elf
done

basepath="$parsecdir/pkgs/kernels"
for k in $kernels; do
	elf=$basepath/$k/inst/aarch64-linux.gcc-hooks/bin/$k
	echo "------------------------------" 
	file $elf
done
echo "------------------------------" 
echo "Done."
