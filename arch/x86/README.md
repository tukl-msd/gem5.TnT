## gem5 Tips & Tricks
### **Tips and tricks for X86**

Here you will find tips and tricks for X86.

Before running the scripts below make sure everything else is setup! You're
all done if you followed [**the steps described here**](../../README.md).

### Boot Linux (minimal, old, provided as example in [gem5.org])

```bash
$ ./boot-linux.sh
```

Open a new terminal and connect to gem5.

```bash
$ telnet localhost 3456
```

After booting, in the guest system, you may want to mount some filesystems.

```
# mount -t proc proc proc/
# mount -t sysfs sys sys/
# mount -o bind /dev dev/
```

Now more commands will work, for example:

```
# free
             total       used       free     shared    buffers     cached
Mem:       1026016      12148    1013868          0        320       3592
-/+ buffers/cache:       8236    1017780
Swap:            0          0          0
```

```
# ifconfig -a
lo        Link encap:Local Loopback  
          LOOPBACK  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

sit0      Link encap:IPv6-in-IPv4  
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
```

```
# cat /proc/cmdline
earlyprintk=ttyS0 console=ttyS0 lpj=7999923 root=/dev/hda1
```

You can also mount the disk image with [mount-img.sh] and
edit the *etc/fstab*.


### Boot Linux (minimal, old, provided as example in [gem5.org]) using [KVM]

This example uses a fork of the main gem5 repository. The patch necessary to
run this example was created by the *UC Davis Computer Architecture Research
Group* in [https://github.com/darchr/gem5](https://github.com/darchr/gem5).

```bash
$ ./boot-linux-kvm.sh
```

Use m5term to connect to gem5. Example:

```bash
$ cd $HOME/gem5_tnt/forks_gem5/gem5-1
$ cd util/term
$ make
$ m5term localhost 3456
```

Note that in this example *m5 operations*, e.g. dumpstat, exit, readfile,
fail.

### PARSEC

Tweak the script [parsec.sh] to fit your purpose.

To choose an application to be executed by the guest system simulated by
[gem5] set the variable *cmd*. Many commands are provided, but only the one to
be executed shall be uncommented.

```
cmd="./canneal ${ncpus} 5 100 /parsec/install/inputs/canneal/10.nets 1"
...
#cmd="./ferret /parsec/install/inputs/ferret/corelt lsh /parsec/install/inputs/ferret/queriest 1 1 ${ncpus} /parsec/install/inputs/ferret/output.txt"
...
#cmd="./x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads ${ncpus} -o /parsec/install/inputs/x264/eledream.264 /parsec/install/inputs/x264/eledream_32x18_1.y4m"
```

Similarly, to choose the number of CPUs, memory size, CPU type, assign the
desired values to the respective variables.

```
# ncpus: 1, 2, 4, 8, 16
ncpus="2"
mem_size="1GB"
cpu_type="TimingSimpleCPU"
#cpu_type="AtomicSimpleCPU"
#cpu_type="NonCachingSimpleCPU"
```

To execute the script type the following command:

```bash
$ ./parsec.sh
```

To connect to [gem5] use *telnet* or *m5term*.

```bash
$ telnet localhost 3456
```

If you decide to use this script in a publication, please cite [gem5.TnT], but
most important please check
[https://parsec.cs.princeton.edu/](https://parsec.cs.princeton.edu/)
and
[Running PARSEC v2.1 in the M5 Simulator](http://www.cs.utexas.edu/~cart/parsec_m5/)
for information on how to proper cite the tools provided by them.

### **Resources**

[running fs.py with X86KvmCPU failed](https://gem5-users.gem5.narkive.com/8DBihuUx/running-fs-py-with-x86kvmcpu-failed)

[https://github.com/darchr/gem5/tree/master](https://github.com/darchr/gem5/tree/master)

[Creating disk images for gem5](http://www.lowepower.com/jason/creating-disk-images-for-gem5.html)

[learning_gem5](http://www.lowepower.com/jason/learning_gem5/)

[gem5]: http://www.gem5.org/
[gem5.org]: http://www.gem5.org/Download
[KVM]: https://www.linux-kvm.org/page/Main_Page
[boot-linux-kvm.sh]: boot-linux-kvm.sh
[boot-linux.sh]: boot-linux.sh
[mount-img.sh]: ../../disk-util/mount-img.sh
[parsec.sh]: parsec.sh
[gem5.TnT]: https://github.com/tukl-msd/gem5.TnT
