## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

* **depinstall.sh**: installs known dependencies.
* **getrepos.sh**: clones gem5 related repositories.
* **getfs.sh**: downloads full system files.
* **getdoc.sh**: downloads documentation and tutorials.
* **getbenchmarks.sh**: downloads some benchmarks.
* **getarmsebenchmarks.sh**: generates SE benchmark programs for arm (the ones used by arm-gem5-rsk with a toolchain that is compatible with the current kernel emulated/syscalls implementation).
* **runarmsebenchmarks.sh**: builds gem5 and runs some of the above-mentioned benchmarks.
* **getarmfsbenchmarks.sh**: generates FS benchmark programs from the parsec suite for arm.
* **runarmfsbenchmarks.sh**: builds gem5 and runs some of the above-mentioned benchmarks (full-system simulation).

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
export M5_PATH=$M5_PATH:/path/to/arm_full_system_files_directory:/path/to/other_full_system_files_directory
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


### **Toolchains**

#### GNU assembler toolchains

* **as** is the assembler and it converts human-readable assembly language programs into binary machine language code. It typically takes as input .s assembly files and outputs .o object files.

* **ld** is the linker and it is used to combine multiple object files by resolving their external symbol references and relocating their data sections, and outputting a single executable file. It typically takes as input .o object files and .ld linker scripts and outputs .out executable files.

* **objcopy** is a translation utility that copies and converts the contents of an object file from one format (e.g. .out) another (e.g. .bin).

* **objdump** is a disassembler but it can also display various other information about object files. It is often used to disassemble binary files (e.g. .out) into a canonical assembly language listing (e.g. .lst).

#### GNU binutils collection:

* **ar** is a utility for creating, modifying and extracting from archives.

* **nlmconv** converts object code into an NLM.

* **nm** lists symbols from object files.

* **ranlib** generates an index to the contents of an archive.

* **readelf** displays information from ELF-format object file.

* **size** displays the sections of an object or archive, and their sizes. 

* **strip** Discards symbols embedded in object files

#### Cross-compiler toolchain naming convention

A convention of the form **arch[-vendor][-os]-abi**

* The **arch** refers to the target architecture 

* The **vendor** nominally refers to the toolchain supplier

* The **os** refers to the target operating system, if any, and is used to decide which libraries (e.g. newlib, glibc, crt0, etc.) to link and which syscall conventions to employ

* The **abi** specifies which application binary interface convention is being employed, which ensures that binaries generated by different tools can interoperate

Examples:

* **arm-none-eabi** - targets ARM architecture, has no vendor, is for “bare metal” system, and complies with the ARM EABI - **bare metal ARM EABI**

* **i686-apple-darwin10-gcc-4.2.1** - gcc compiler targets the Intel i686 architecture, the vendor is Apple, and the OS is Darwin version 10.

* **arm-none-linux-gnueabi** targets the ARM architecture, has no vendor, is for the Linux operating system, and uses the GNU EABI. It is used to target **ARM-based Linux systems**.

* **arm-eabi** - Android ARM toolchains

Reference:

https://web.eecs.umich.edu/~prabal/teaching/eecs373-f12/notes/notes-toolchain.pdf

An **embedded-application binary interface (EABI)** specifies standard conventions for file formats, data types, register usage, stack frame organization, and function parameter passing of an embedded software program, for use with an embedded operating system.

Reference:

https://en.wikipedia.org/wiki/Application_binary_interface#Embedded_ABIs

#### ARM architecture names

**armel**

It's ARM running in little-endian mode.

**armhf**

In Debian Linux, and derivatives such as Ubuntu, **armhf** (ARM hard float) refers to the ARMv7 architecture including the additional VFP3-D16 floating-point hardware extension (and Thumb-2). Software packages and cross-compiler tools use the **armhf** vs. **arm**/**armel** suffixes to differentiate.

Reference:

https://en.wikipedia.org/wiki/ARM_architecture

The table below recaps which port names Debian/dpkg we saw so far.

| name  | endianess    | status                                                                                                              |
|-------|--------------|---------------------------------------------------------------------------------------------------------------------|
| arm   | little-edian | original Debian arm port using original ABI ('OABI'), last release in Debian lenny; being retired in favor of armel |
| armel | little-edian | introduced in Debian lenny; EABI, actively maintained; targets armv4t; doesn't require an Floating Point Unit       |
| armeb | big-edian    | unofficial OABI port; inactive and dead                                                                             |
| armhf | either       | new ARM port using the hard-float ABI is 'armhf' (for 'hard-float')                                                 |

In practice **armel** will be used for older CPUs (armv4t, armv5, armv6), and **armhf** for newer CPUs (armv7+FPU).

GCC when built to target the GNU e.g. **arm-linux-gnueabi** triplet will support both the hard-float and soft-float calling conventions.

Reference:

https://wiki.debian.org/ArmHardFloatPort

### **The Arm Research Starter Kit: System Modeling using gem5**

The amazing [**Arm Research Starter Kit**](https://github.com/arm-university/arm-gem5-rsk) will guide you through Arm-based system modeling using the gem5 simulator.

