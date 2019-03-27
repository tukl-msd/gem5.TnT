## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather
and share useful hints about gem5, so that the learning process is
accelerated.

* [**dep_install.sh**](dep_install.sh): installs known dependencies for building gem5 and running the example scripts contained in this repository.
* [**get_essential_repos.sh**](get_essential_repos.sh): clones gem5 essential repositories for running the examples.
* [**get_extra_repos.sh**](get_extra_repos.sh): clones other gem5 related repositories.
* [**get_essential_fs.sh**](get_essential_fs.sh): downloads essential full system files for running the examples.
* [**get_extra_fs.sh**](get_extra_fs.sh): downloads full system files.
* [**get_doc.sh**](get_doc.sh): downloads documentation and tutorials.
* [**get_benchmarks.sh**](get_benchmarks.sh): downloads some benchmarks.
* [**build_gem5.sh**](build_gem5.sh): can be used for building gem5.
* [**Boot Linux**](arch/alpha/README.md) here you'll find scripts and information for the ALPHA ISA.
* [**Boot Linux**](arch/x86/README.md) here you'll find scripts and information for the x86 ISA.
* [**Boot Linux, Create Disk images, Run Benchmarks**](arch/arm/README.md) here you'll find some useful scripts and information for running benchmarks on gem5 for the arm architecture.
* [**Basics**](doc/Gem5Basics.md) here you'll find some gem5 basics just to warmup. Remember, though, to take a look at [**gem5's website**](http://www.gem5.org/Main_Page).
* [**Hints to Execute Android**](patches/gem5/asimbench/README.md) here you'll find how you can run android on your gem5.
* [**Elastic Trace and HBM as Main Memory**](patches/gem5/HBM_elastic_traces/README.md) here you'll find the steps to run elastic traces on gem5 using HBM as the main memory.
* [**Bare Metal**](https://github.com/tukl-msd/gem5.bare-metal) here you'll find the steps to run an example gem5 ARM bare-metal implementation. 

### **Using gem5.TnT**

#### **Clone the repository and change to its directory:**

```bash
$ cd $HOME
$ git clone https://github.com/tukl-msd/gem5.TnT.git
$ cd gem5.TnT
```

#### **Run the scripts.**

A suggestion on how to do that follows:

Install known dependencies (note that this one has to be run with sudo or as
root):
```bash
$ sudo ./dep_install.sh
```

Get repositories:
```bash
$ ./get_essential_repos.sh
```

Get some full system simulation files:
```bash
$ ./get_essential_fs.sh
```

Get some benchmark suites:
```bash
$ ./get_benchmarks.sh
```

#### **Download documentation**

Optionally, download some documentation with:
```bash
$ ./get_doc.sh
```

The default directory for downloads is **$HOME/gem5_tnt**. That means a new
directory called **gem5_tnt** will be created in your home folder and
populated with relevant files, documentation and repositories. In case you want to
change the default paths edit the [defaults.in](common/defaults.in) file in your
local repository before running the scripts.

A convenient script [**do_it_for_me.sh**](do_it_for_me.sh) is provided.

```bash
$ ./do_it_for_me.sh
```

### **Quick Hints**

#### GEM5 Scons Build Options:

```bash
$ cd $HOME/gem5_tnt/gem5
$ scons --ignore-style -h
```

#### Default python version is not python2.7:

```bash
$ python2.7 `which scons` build/<arch>/gem5.<mode> -j<num jobs>
```

Example:

```bash
$ python2.7 `which scons` build/ARM/gem5.opt -j$(cat /proc/cpuinfo | grep processor | wc -l)
```

#### Memory allocation error on Linux.

```bash
$ sudo su
$ echo 1 > /proc/sys/vm/overcommit_memory
```

### Using [KVM]:

```bash
$ scons --ignore-style -h | grep KVM
USE_KVM: Enable hardware virtualized (KVM) CPU models (yes|no)

$ echo "USE_KVM = 'yes'" >> build_opts/X86
$ cat build_opts/X86

$ scons --ignore-style build/X86/gem5.opt -j`nproc`
```

Some features may require you to have access to special files or devices, e.g.
*/dev/kvm*.

```bash
$ groups
$ grep kvm /etc/group
$ sudo adduser $USER kvm
```

Restart for the permissions to take effect.

Now you may need this:

```bash
$ sudo su
# echo 1 > /proc/sys/kernel/perf_event_paranoid
# exit
$ cat /proc/sys/kernel/perf_event_paranoid
```

Still it may fail. See also:

[https://gem5-users.gem5.narkive.com/8DBihuUx/running-fs-py-with-x86kvmcpu-failed](https://gem5-users.gem5.narkive.com/8DBihuUx/running-fs-py-with-x86kvmcpu-failed)

[https://github.com/darchr/gem5/tree/master](https://github.com/darchr/gem5/tree/master)


### M5 Term

Build **m5term**.

```bash
$ cd $HOME/gem5_tnt/gem5
$ cd util/term
$ make
```

Start your gem5 simulation. The gem5 simulator generates a message with a port
number for connection with m5term or telnet.

Example of use follows.

```bash
$ ./m5term localhost 3456
```

Note: the port number may vary.

### The M5 Binary

Commands to build the **m5** for the x86 ISA follow.

```bash
$ cd $HOME/gem5_tnt/gem5
$ cd util/m5
$ make -f Makefile.x86
```

See also:

In [m5.c] there is a table that associates functionalities provided by **m5**
with actual functions that implement them. Each entry in the table has a
string which corresponds to the name of a functionality, a function that
implements it and another string showing the usage.

The *m5_mem* is created using *mmap()* in [m5_mmap.c]. Now it may be a good
time to read mmap's manpage.

```bash
$ man mmap
```

The value of the first argument *addr* is NULL. Then the kernel chooses the
address at which the mapping is created.

The size used is 0x10000 (65 KiB).

Pages of this mapping may be read and written (PROT_READ | PROT_WRITE).

The *MAP_SHARE* flag makes updates to the mapping visible to other processes
that map the same file or other object referred to by the file descriptor *fd*
(in this case **/dev/mem**).

*M5OP_ADDR* is defined in [Makefile.x86] (-DM5OP_ADDR=0xFFFF0000). The
combination of  address and size generates the range 0xFFFF0000-0xFFFFFFFF.

*M5OP_PIC* can also be defined there (depending on the target). It indicates
that *Position Independent Code* must be generated by using the code
generation option *-fPIC*. Note that the default target is in [Makefile.x86]
is *m5*, but there are others e.g. *m5op_x86.opic*. The code generation option
*-fPIC* is useful for creating code that can be dynamically linked, e.g.
object files that compose dynamic libraries (**.so**).

Both *M5OP_ADDR* and *M5OP_PIC* affect how the macro *TWO_BYTE_OP(name,
number)* is defined in [m5op_x86.S]. Such macro is used to define *m5*
operations. The respective numbers can be found in [m5ops.h].

Example:

```
/* Use the memory mapped m5op interface */
#define TWO_BYTE_OP(name, number)         \
        .globl name;                      \
        .func name;                       \
name:                                     \
        mov m5_mem, %r11;                 \
        mov $number, %rax;                \
        shl $8, %rax;                     \
        mov 0(%r11, %rax, 1), %rax;       \
        ret;                              \
        .endfunc;
```

*.global* makes the symbol (name of a function) visible to *ld* (the linker)

```
TWO_BYTE_OP(m5_dump_stats, M5OP_DUMP_STATS)
TWO_BYTE_OP(m5_checkpoint, M5OP_CHECKPOINT)
```

### Syscall Emulation SE

Emulation functions that are generic enough that they don't need to be
recompiled for different emulated OS's are defined in [syscall_emul.cc]. See
also [syscall_emul.hh].

The *class SyscallDesc* provides the wrapper interface for the system call
implementations.

Note the tables with syscalls for x86 in [src/arch/x86/linux/process.cc].
There you can check if the syscalls needed by an application are implemented.

```
static SyscallDesc syscallDescs64[] {
    /*   0 */ SyscallDesc("read", readFunc),
    /*   1 */ SyscallDesc("write", writeFunc),
    /*   2 */ SyscallDesc("open", openFunc<X86Linux64>),
    /*   3 */ SyscallDesc("close", closeFunc),
    ...
    /*  57 */ SyscallDesc("fork", unimplementedFunc),
    ...
}

static SyscallDesc syscallDescs32[] = {
    /*   0 */ SyscallDesc("restart_syscall", unimplementedFunc),
    /*   1 */ SyscallDesc("exit", exitFunc),
    /*   2 */ SyscallDesc("fork", unimplementedFunc),
    /*   3 */ SyscallDesc("read", readFunc),
    ...
}
```

Also in [src/arch/x86/linux/process.cc] you can find the implementation of
**uname** that is a system call (a function provided by the kernel) to get
name and information about the kernel, for example the **kernel version**. See
also uname(2).

```
$ man 2 uname
```

In
[src/arch/riscv/linux/process.cc](https://gem5.googlesource.com/public/gem5/+/refs/heads/master/src/arch/riscv/linux/process.cc)
you can find information for RISC-V, in
[src/arch/arm/linux/process.cc](https://gem5.googlesource.com/public/gem5/+/refs/heads/master/src/arch/arm/linux/process.cc)
you can find information for ARM, and so on.

### More Resources, Useful Links

Here some links you may consider useful. Many thanks to the respective authors for
throwing some light on this.

[Learning gem5](http://www.lowepower.com/jason/learning_gem5/)

[Tutorials gem5 wiki](http://www.m5sim.org/Tutorials)

[When to use full system FS vs syscall emulation SE with userland programs in gem5?](https://stackoverflow.com/questions/48986597/when-to-use-full-system-fs-vs-syscall-emulation-se-with-userland-programs-in-gem)

[How to solve “FATAL: kernel too old” when running gem5 in syscall emulation SE mode?](https://stackoverflow.com/questions/48959349/how-to-solve-fatal-kernel-too-old-when-running-gem5-in-syscall-emulation-se-m/50542301#50542301)

This is a good one:
[gem5 vs QEMU](https://github.com/cirosantilli/linux-kernel-module-cheat/tree/00d282d912173b72c63c0a2cc893a97d45498da5#gem5-vs-qemu)


### More Resources, Useless Links

```
The Ultimate Computer
Stardate: 4729.4

...
KIRK: I'm curious, Doctor. Why is it called M-5 and not M-1?
DAYSTROM: Well, you see, the multitronic units one through four were not entirely successful. This one is. M-5 is ready to take control of the ship.
...
MCCOY: Jim, he's on the edge of a nervous breakdown, if not insanity.
KIRK: The M-5 must be destroyed.
...
SPOCK: The force field is gone, Captain. M-5 is neutralised.
SCOTT: System's coming back.
...
```
[Source](http://chakoteya.net/StarTrek/53.htm)


[m5.c]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/util/m5/m5.c
[m5_mmap.c]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/util/m5/m5_mmap.c
[Makefile.x86]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/util/m5/Makefile.x86
[m5op_x86.S]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/util/m5/m5op_x86.S
[m5ops.h]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/include/gem5/asm/generic/m5ops.h
[syscall_emul.cc]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/src/sim/syscall_emul.cc
[syscall_emul.hh]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/src/sim/syscall_emul.hh
[src/arch/x86/linux/process.cc]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/src/arch/x86/linux/process.cc
[KVM]: https://www.linux-kvm.org/page/Main_Page
