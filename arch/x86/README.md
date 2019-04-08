## gem5 Tips & Tricks
### **Tips and tricks for X86**

Here you'll find tips and tricks for the X86 ISA.

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
edit the *etc/fstab* to mount automatically during initialization.


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

### **Resources**

[running fs.py with X86KvmCPU failed](https://gem5-users.gem5.narkive.com/8DBihuUx/running-fs-py-with-x86kvmcpu-failed)

[https://github.com/darchr/gem5/tree/master](https://github.com/darchr/gem5/tree/master)

[Creating disk images for gem5](http://www.lowepower.com/jason/creating-disk-images-for-gem5.html).

[learning_gem5](http://www.lowepower.com/jason/learning_gem5/).

[gem5.org]: http://www.gem5.org/Download
[KVM]: https://www.linux-kvm.org/page/Main_Page
[boot-linux-kvm.sh]: boot-linux-kvm.sh
[boot-linux.sh]: boot-linux.sh
[mount-img.sh]: ../../disk-util/mount-img.sh
