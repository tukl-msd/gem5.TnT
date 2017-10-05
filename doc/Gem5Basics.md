## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

Here you'll find some gem5 basics just to warmup. Remember, though, to take a look at [**gem5's website**](http://www.gem5.org/Main_Page).

You can also watch these awesome video tutorials: [**Learning gem5 HPCA tutorial**](https://www.youtube.com/watch?v=5UT41VsGTsg).

### **Compiling gem5**

```bash
scons build/<arch>/gem5.<binary> -j<jobs>
```

Where:

* **\<arch\>**: architecture e.g., **ALPHA**, **ARM**, **X86**, **RISCV**. For more options, try the command below inside gem5's root directory:

```bash
ls build_opts/
```

* **\<binary\>**:
	* gem5.**debug** - A binary used for debugging without any optimizations. *_Fast compilation + slow execution_*.
	* gem5.**opt** - A binary with debugging and optimization. _*Faster execution + slower compilation*_.
	* gem5.**prof** - Same as opt target + profiling support suitable for use with gprof.
	* gem5.**perf** - Similar to prof, this target is aimed for CPU and heap profiling using the google perftools.
	* gem5.**fast** - _*Fastest execution + Debug removed*_.

* **\<jobs\>**: number of jobs to run simultaneously. If you're not sure, try the command below to get a reasonable number:

```bash
cat /proc/cpuinfo | grep processor | wc -l
```


#### Running gem5
**Modes**

* **Full System Simulation (FS)**: Model execution of both user-level and kernel-level intructions as well as complete system internal behaviors including OS and devices.

* **System Call Emulation (SE)**: Model external system calls, passing those to the host operating system. No modeling of devices and OS.

#### Running pre-provided Full-System Simulation config script

Export the environment variable **M5_PATH** poiting to full system files (disk images & binaries). Put your disk images in a folder named **disks** and the binaries in folder named **binaries**.

```bash
export M5_PATH=$M5_PATH:/path/to/full_system_files_directory:/path/to/other_full_system_files_directory
```

Prepare running script **\*.rcS** (optional)

If you want some commands to be executed by the shell after system boot then prepare a script as follows:

```bash
#!/bin/sh
# Script for running the blackscholes benchmark
cd /parsec/install/bin
/sbin/m5 dumpresetstats
./blackscholes 64 /parsec/install/inputs/blackscholes/in_64K.txt /parsec/install/inputs/blackscholes/prices.txt
echo "Finally done! :D"
/sbin/m5 exit
```

Invoke commands

```bash
build/<arch>/gem5.<binary> config/example/fs.py --kernel=<kernel_file> --disk-image=<disk_image.img> --script=</path/to/script.rcS>
```

**NOTE**:

If you get errors stating that some files cannot be found check at least *config/common/FSConfig.py* or *config/common/Benchmarks.py* for hardcoded values.

Connect to gem5 via telnet (3456 is the port indicated in the console output):

```bash
telnet localhost 3456
```

#### Add files to disk images used in Gem5 Full-System Simulation
On the host machine:

```bash
mkdir -p tempdir
sudo mount -o loop,offset=32256 /path/to/disk_image.img /path/to/temdir/
```

Inside tempdir is the content of the disk_image.img

```bash
cd tempdir
sudo cp /path/to/file/to/add.file root
```

Verify

```bash
sudo ls root
```

Finish by unmout the disk image

```bash
sudo umount /path/to/temdir/
```

Now the disk_image.img contains the file we want at the root directory.

Reference: https://www.youtube.com/watch?v=OXH1oxQbuHA&t=132s

#### Install packages/benchmarks into disk images using qemu [TOBE CONTINUED]

Later we can run gem5 full system simulation with this disk image containing our installed packages/benchmarks.

1. Chrooting into target file systems

To be able to chroot into a target file system, the qemu emulator for the target CPU needs to be accessible from inside the chroot jail. For this to work, you need first to install the qemu-user-static package:

```bash
apt-get install qemu qemu-user-static qemu-user qemu-system
```

You cannot use the dynamically linked qemu because the host libraries will not be accessible from inside the chroot.

Next, copy the emulator for the target architecture to the path registered by binfmt-support. For example, for an ARM target file system, you need to do the following:

```bash
cp /usr/bin/qemu-arm-static /target_fs/usr/bin
```

You should now be able to chroot into the file system:

```bash
chroot /target_fs/
```

References:

https://wiki.debian.org/QemuUserEmulation

https://www.youtube.com/watch?v=Oh3NK12fnbg&t=101s

https://wiki.ubuntu.com/ARM/BuildEABIChroot

https://unix.stackexchange.com/questions/41889/how-can-i-chroot-into-a-filesystem-with-a-different-architechture
