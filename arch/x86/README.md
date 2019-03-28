## gem5 Tips & Tricks
### **Tips and tricks for the X86 ISA**

Here you'll find tips and tricks for the X86 ISA.

Before running the scripts below make sure everything else is setup! You're
all done if you followed [**the steps described here**](../../README.md).

* [boot-linux.sh]: boots Linux (minimal, old, provided as
  example in [gem5.org](http://www.gem5.org/Download)).

#### **Run the script.**

A suggestion on how to run the scripts follows.

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

* [boot-linux-kvm.sh]: boots Linux (minimal, old, provided as
  example in [gem5.org](http://www.gem5.org/Download)) using [KVM]. This example
  uses a fork of the main gem5 repository. The patch necessary to run this
  example was created by the *UC Davis Computer Architecture Research Group*
  in [https://github.com/darchr/gem5](https://github.com/darchr/gem5).

#### **Run the script.**

A suggestion on how to run the scripts follows.

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

[**Creating disk images for gem5**](http://www.lowepower.com/jason/creating-disk-images-for-gem5.html).

[**learning_gem5**](http://www.lowepower.com/jason/learning_gem5/).

[KVM]: https://www.linux-kvm.org/page/Main_Page
[boot-linux-kvm.sh]: boot-linux-kvm.sh
[boot-linux.sh]: boot-linux.sh
