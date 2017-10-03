## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

This folder contains tips and tricks for the arm archtecture.

* **getarmsebenchmarks.sh**: generates SE benchmark programs for arm (the ones used by arm-gem5-rsk with a toolchain that is compatible with the current kernel emulated/syscalls implementation).
* **runarmsebenchmarks.sh**: builds gem5 and runs some of the above-mentioned benchmarks.
* **getarmfsbenchmarks.sh**: generates FS benchmark programs from the parsec suite for arm.
* **runarmfsbenchmarks.sh**: builds gem5 and runs some of the above-mentioned benchmarks (full-system simulation).

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

