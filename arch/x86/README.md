## gem5 Tips & Tricks
### **Tips and tricks for the X86 ISA**

Here you'll find tips and tricks for the X86 ISA.

Before running the scripts below make sure everything else is setup! You're
all done if you followed [**the steps described here**](../../README.md).

* [boot-linux.sh]: boots Linux (minimal, old, provided as
  example in [gem5.org](http://www.gem5.org/Download)).

#### **Run the scripts.**

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

### **Resources**

[**Creating disk images for gem5**](http://www.lowepower.com/jason/creating-disk-images-for-gem5.html).

[**learning_gem5**](http://www.lowepower.com/jason/learning_gem5/).

[boot-linux.sh]: boot-linux.sh
