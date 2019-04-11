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
TOPDIR=$DIR
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

pushd $BENCHMARKSDIR

mkdir -p MiBench
pushd MiBench

benchmarks="
automotive.tar.gz
consumer.tar.gz
network.tar.gz
office.tar.gz
security.tar.gz
telecomm.tar.gz
"

url=http://vhosts.eecs.umich.edu/mibench//

bmdir="benchmarks"
mkdir -p $bmdir
for b in $benchmarks; do
	wget -N $url/$b
	tar -xaf $b -C $bmdir
done

outputs="
automotive_output.tar.gz
consumer_output.tar.gz
network_output.tar.gz
office_output.tar.gz
security_output.tar.gz
telecomm_output.tar.gz
"

outdir="outputs"
mkdir -p $outdir
for o in $outputs; do
	wget -N $url/$o
	tar -xaf $o -C $outdir
done

wget -N http://vhosts.eecs.umich.edu/mibench//Publications/MiBench.pdf

git init
git add .
git commit -m "Initial commit. Files from http://vhosts.eecs.umich.edu/mibench"

git apply $DIR/mibench.patch

popd
popd
