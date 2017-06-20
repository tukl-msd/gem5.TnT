## Dependencies
* hg or git: 
	* ```sudo apt-get install mercurial```
	* ```sudo apt-get install git```

* gcc 4.6+:
	* ```sudo apt-get install build-essential```
	* export PATH & LD\_LIBRARY_PATH
	
	```bash
	export PATH=/s/gcc-4.7.3/bin:$PATH
	export LD_LIBRARY_PATH=/s/gcc-4.7.3/lib64:$LD_LIBRARY_PATH
	```
	
* scons: ```sudo apt-get install scons```

* Python 2.6-2.7: 
	* ```sudo apt-get install python-dev```
	* export PATH & LD\_LIBRARY_PATH
	
	```bash
	export PATH=/s/python-2.7.3/bin:$PATH
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/s/python-2.7.3/lib
	export LIBRARY_PATH=/s/python-2.7.3/lib:$LIBRARY_PATH
	```
* Protobuf 2.1+: ```sudo apt-get install libprotobuf-dev python-protobuf protobuf-compiler libgoogle-perftools-dev```
* zlib: ```sudo apt-get install zlibc zlib1g zlib1g-dev```
* m4: ```sudo apt-get install m4```

## Getting Source Codes
```
hg clone http://repo.gem5.org/gem5
```
OR

```
git clone https://gem5.googlesource.com/public/gem5
```

## Compiling
```
scons build/<arch>/gem5.<binary>
```
Where:

* **arch**: The currently available architectures are **ALPHA**, **ARM**, **MIPS**, **POWER**, **SPARC**, and **X86**. In addition there is a **NULL** architecture.

* **binary**:
	* gem5.**debug** - A binary used for debugging without any optimizations. *_Fast compilation + slow execution_*
	* gem5.**opt** - A binary with debugging and optimization. _*Faster execution + slower compilation*_. Contains enough debug information to be able to debug most problem. However when debugging source code it can be more difficult to use that the debug target.
	* gem5.**prof** - same as opt target + profiling support suitable for use with gprof.
	* gem5.**perf** - Similar to prof, this target is aimed for CPU and heap profiling using the google perftools.
	* gem5.**fast** - _*Fastest execution + Debug removed*_. By default it also uses Link Time Optimization

**NOTES**: successful compilation but failed execution:

```
Traceback (most recent call last):
  File "........../gem5-stable/src/python/importer.py", line 93, in <module>
    sys.meta_path.append(importer)
TypeError: 'dict' object is not callable
```
Recompile with:

```
python `which scons` build/<arch>/gem5.<binary>
```
Refer: http://www.gem5.org/Using_a_non-default_Python_installation

## Running
**Modes**

* **Full System Simulation (FS)**: Model execution of both user-level and kernel level intructions as well as complete system's internal behaviors including OS and devices - "white box" simulation

* **System Call Emulation (SE)**: Model external system calls, passing those to the host operating system. No modeling of devices and OS - "black box" emulation

### Running pre-provided Full-System Simulation config script

1. Download full system files for appropriate architectures

* ARM

```bash
wget http://www.gem5.org/dist/current/arm/aarch-system-2014-10.tar.xz
``` 
* ALPHA

```bash
wget http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
```
* X86

```bash
wget http://www.m5sim.org/dist/current/x86/x86-system.tar.bz2
```
**NOTE**:
To run X86 FS, gem5 need additional files hardcoded in ```config/common/FSConfig.py```, you need to symlink those file from ALPHA file system folder

2. export M5_PATH poiting to full system files (disk images & binaries)

```bash
export M5_PATH=/path/to/arm_full_system_files/:/path/to/other_full_system_files:$M5_PATH
```
4. Prepare running script *.rcS (optional)
If you wish to execute some commands after system boot by the shell then prepare one, example:

```bash
#!/bin/sh
# File to run the blackscholes benchmark
cd /parsec/install/bin
/sbin/m5 dumpresetstats
./blackscholes 64 /parsec/install/inputs/blackscholes/in_64K.txt /parsec/install/inputs/blackscholes/prices.txt
echo "Done :D"
/sbin/m5 exit
```
3. Invoke commands

```bash
build/<arch>/gem5.<binary> config/example/fs.py --kernel=kernal_file --disk-image=image_file.img --script=/path/to/script.rcS
```

**NOTE**:

If you do not want to specify kernel & disk image files in the commands OR you got error stating that some files cannot be found in the path, you can create symlinks poiting to your desired files with the name harded code in ```config/common/FSConfig.py``` and ```config/common/Benchmarks.py```. Browse in to that files and find functions named make\<arch>System and check for harded code file name.

### Running pre-provided System-Call Emulation config script
TODO

## Add files to disk images used in Gem5 Full-System Simulation
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
Now inside the disk_image.img contains the file we want at the root directory

Refer: https://www.youtube.com/watch?v=OXH1oxQbuHA&t=132s

## Install packages/benchmarks into disk images using qemu [TOBE CONTINUED]
Later we can run gem5 full system simulation with this disk image containing our installed packages/benchmarks

1. Chrooting into target file systems
To be able to chroot into a target file system, the qemu emulator for the target CPU needs to be accessible from inside the chroot jail. For this to work, you need first to install the qemu-user-static package:

```
apt-get install qemu qemu-user-static qemu-user qemu-system
```
You cannot use the dynamically linked qemu because the host libraries will not be accessible from inside the chroot.

Next, copy the emulator for the target architecture to the path registered by binfmt-support. For example, for an ARM target file system, you need to do the following:

```
cp /usr/bin/qemu-arm-static /target_fs/usr/bin
```
You should now be able to chroot into the file system:

```
chroot /target_fs/
```

Refer: 	https://wiki.debian.org/QemuUserEmulation
		https://www.youtube.com/watch?v=Oh3NK12fnbg&t=101s
		https://wiki.ubuntu.com/ARM/BuildEABIChroot
		https://unix.stackexchange.com/questions/41889/how-can-i-chroot-into-a-filesystem-with-a-different-architechture