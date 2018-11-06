## gem5 Tips & Tricks
### **Tips and tricks for the ARM architecture**

Here you'll find tips and tricks for the ARM architecture.

Before running the scripts below make sure everything else is setup! You're all done if you followed [**the steps described here**](../../README.md).

* [**build_llvm_test_suite_apps.sh**](build_llvm_test_suite_apps.sh): builds some benchmark programs from the LLVM test-suite for arm.
* [**build_parsec_apps.sh**](build_parsec_apps.sh): builds some benchmark programs from the parsec-3.0 benchmark suite for arm.
* [**run_arm_fs_parsec.sh**](run_arm_fs_parsec.sh): builds gem5 and runs some benchmarks in full-system mode.
* [**run_arm_fs_android_ics.sh**](run_arm_fs_android_ics.sh): builds gem5 and runs android ics (full-system simulation).
* [**run_arm_se_hmc.sh**](run_arm_se_hmc.sh): builds gem5 and runs it using HMC as main memory (syscall emulation).
* [**run_arm_se_benchmarks.sh**](run_arm_se_benchmarks.sh): builds gem5 and runs some of the above-mentioned benchmarks (system call emulation).

#### **Run the scripts.**

A suggestion on how to run the scripts follows:

Build some benchmark programs:
```bash
bash get_arm_se_benchmarks.sh
```

Execute benchmarks:
```bash
bash run_arm_se_benchmarks.sh
```

Build some full-system benchmark programs:
```bash
bash get_arm_fs_benchmarks.sh
```

Execute some full-system benchmarks (note that this one requires **sudo** to
perform some actions):
```bash
sudo bash run_arm_fs_benchmarks.sh
```

### **The Arm Research Starter Kit: System Modeling using gem5**

The [**Arm Research Starter Kit**](https://github.com/arm-university/arm-gem5-rsk) will guide you through Arm-based system modeling using the gem5 simulator.

