## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

Here you'll find some examamples on how to run gem5 (syscall emulation mode) using a Hybrid Memory Cube (HMC) as main memory.

Make sure everything is setup! You're all done if you followed [**the steps described here**](../../../README.md).

Oh, one last thing, if you haven't yet built gem5 check [**this**](../../../doc/Gem5Basics.md).

Apply the patch to your gem5 source code.

```bash
patch -p1 < hmc_se.patch
```

After applying the patch you have to build gem5 again. But don't worry, this time the build process will finish much faster than the first build.

Basic usage examples:

```bash
./build/ARM/gem5.opt -d hmc_se_output/test1 configs/example/hmctest.py
```
```bash
./build/ARM/gem5.opt -d hmc_se_output/test2 configs/example/hmctest.py --enable-global-monitor --enable-link-monitor --arch=same
```
```bash
./build/ARM/gem5.opt -d hmc_se_output/test3 configs/example/hmctest.py --enable-global-monitor --enable-link-monitor --arch=mixed
```

Simple hello world script using HMC:

```bash
./build/ARM/gem5.opt -d hmc_se_output/hello1 configs/example/hmc_hello.py
```
```bash
./build/ARM/gem5.opt -d hmc_se_output/hello2 configs/example/hmc_hello.py --enable-global-monitor --enable-link-monitor
```

After running the examples above check each of the output folders inside **hmc_se_output/**. Use a PDF viewer to open the generated **config.dot.pdf** file and a text editor to open **stats.txt**.

The script [**runarmsehmc.sh**](../../../arch/arm/runarmsehmc.sh) can be used to build gem5 and execute the steps described above.
