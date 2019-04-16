## gem5 Tips & Tricks
### **Tips and tricks for the ALPHA ISA**

Here you'll find tips and tricks for the ALPHA ISA.

Before running the scripts below make sure everything else is setup! You're
all done if you followed [**the steps described here**](../../README.md).

* [boot-linux.sh]: boots Linux (old, provided as example in
  [gem5.org](http://www.gem5.org/Download)).

### Boot Linux

A suggestion on how to use the script follows.

```bash
$ ./boot-linux.sh
```

Optionally, uncomment the variable **script_opt** in [boot-linux.sh] to use
the initialization script [boot-linux.rcS](boot-linux.rcS)

```
#script_opt="--script=$DIR/boot-linux.rcS"
```

Optionally, open a new terminal and connect to gem5.

```bash
$ telnet localhost 3456
```

### Full System Benchmarks

```bash
cd $HOME/gem5_tnt/gem5
```

```bash
$ export M5_PATH=$HOME/gem5_tnt/full_system/alpha/m5_system_2.0b3
```

```bash
$ ./build/ALPHA/gem5.opt configs/example/fs.py -b NetperfMaerts 
```

```bash
$ ./build/ALPHA/gem5.opt configs/example/fs.py -help

...
-b BENCHMARK, --benchmark=BENCHMARK
                        Specify the benchmark to run. Available benchmarks:
                        ArmAndroid-GB, ArmAndroid-ICS, IScsiInitiator,
                        IScsiTarget, MutexTest, NetperfMaerts, NetperfStream,
                        NetperfStreamNT, NetperfStreamUdp, NetperfUdpLocal,
                        Nfs, NfsTcp, Nhfsstone, Ping, PovrayAutumn,
                        PovrayBench, SurgeSpecweb, SurgeStandard, ValAccDelay,
                        ValAccDelay2, ValCtxLat, ValMemLat, ValMemLat2MB,
                        ValMemLat8MB, ValStream, ValStreamCopy,
                        ValStreamScale, ValSysLat, ValTlbLat, Validation,
                        bbench-gb, bbench-ics

...

```

Boot scripts available in:

```bash
$ cd $HOME/gem5_tnt/gem5
$ ls configs/boot
```

See also:

[Benchmarks.py]

[Running_gem5]

The disk image can be mounted with [mount-img.sh] as follows.

```bash
$ mount-img.sh $HOME/gem5_tnt/full_system/alpha/m5_system_2.0b3/disks/linux-latest.img
```

Example:

```bash
$ mount-img.sh $HOME/gem5_tnt/full_system/alpha/m5_system_2.0b3/disks/linux-latest.img
Salutations! You are using gem5.TnT!
file: ./linux-latest.img
start sector: 63
sector size: 512
loop device: /dev/loop0
offset: 32256
Mounted at /tmp/tmp.Zmt0BMnE3p
Command to unmount: sudo umount /tmp/tmp.Zmt0BMnE3p && sudo losetup --detach /dev/loop0
```

```bash
$ cd /tmp/tmp.Zmt0BMnE3p
```

```bash
$ ls
benchmarks  bin  dev  etc  iscsi  lib  linuxrc  lost+found  mnt  modules  proc  sbin  sys  tmp  usr  var
```

```bash
$ ls benchmarks/*
benchmarks/aio-bench  benchmarks/pthread_mutex_test

benchmarks/micros:
lmbench  simstream  simstreamcopy  simstreamscale

benchmarks/netperf-bin:
netperf  netserver

benchmarks/surge:
cnt.txt  mout.txt  name.txt  objout.txt  off.txt  spec-m5  Surge
```

```bash
$ cd -
$ sudo umount /tmp/tmp.Zmt0BMnE3p && sudo losetup --detach /dev/loop0
```

[boot-linux.sh]: boot-linux.sh
[Running_gem5]: http://www.gem5.org/Running_gem5
[Benchmarks.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/configs/common/Benchmarks.py
[mount-img.sh]: ../../disk-util/mount-img.sh
