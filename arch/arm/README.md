## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

This folder contains tips and tricks for the arm architecture.

Before running the scripts below make sure everything else is setup! You're all done if you followed [**the steps described here**](../../README.md).

* [**getarmsebenchmarks.sh**](getarmsebenchmarks.sh): builds SE benchmark programs from the LLVM test-suite for arm.
* [**runarmsebenchmarks.sh**](runarmsebenchmarks.sh): builds gem5 and runs some of the above-mentioned benchmarks (system call emulation).
* [**getarmfsbenchmarks.sh**](getarmfsbenchmarks.sh): builds FS benchmark programs from the parsec suite for arm.
* [**runarmfsbenchmarks.sh**](runarmfsbenchmarks.sh): builds gem5 and runs some of the above-mentioned benchmarks (full-system simulation).
* [**runarmsehmc.sh**](runarmsehmc.sh): builds gem5 and runs it using HMC as main memory (syscall emulation).

### **The Arm Research Starter Kit: System Modeling using gem5**

The amazing [**Arm Research Starter Kit**](https://github.com/arm-university/arm-gem5-rsk) will guide you through Arm-based system modeling using the gem5 simulator.

