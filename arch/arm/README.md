## gem5 Tips & Tricks
### **Tips and tricks for the ARM architecture**

Here you'll find tips and tricks for the ARM architecture.

Before running the scripts below make sure everything else is setup! You're all done if you followed [**the steps described here**](../../README.md).

* [**boot_android.sh**](boot_android.sh): boots android.
* [**boot_linaro.sh**](boot_linaro.sh): boots linaro.
* [**boot_ubuntu.sh**](boot_ubuntu.sh): boots ubuntu.
* [**build_llvm_test_suite_apps.sh**](build_llvm_test_suite_apps.sh): builds some apps from LLVM test-suite.
* [**build_parsec_apps.sh**](build_parsec_apps.sh): builds some apps from parsec-3.0 benchmark suite.
* [**build_stream_app.sh**](build_stream_app.sh): builds stream app.
* [**build_stride_apps.sh**](build_stride_apps.sh): builds stride v1.1 apps.
* [**create_images.sh**](create_images.sh): builds disk images containing the benchmark programs. It uses **sudo**.
* [**run_arm_fs_android_ics.sh**](run_arm_fs_android_ics.sh): Full-system mode executing android ics.
* [**run_arm_fs_parsec.sh**](run_arm_fs_parsec.sh): Full-system mode executing parsec-3.0 apps.
* [**run_arm_fs_stream.sh**](run_arm_fs_stream.sh): Full-system mode executing stream app.
* [**run_arm_fs_stride.sh**](run_arm_fs_stride.sh): Full-system mode executing stride v1.1 apps.
* [**run_arm_fs_test_suite.sh**](run_arm_fs_test_suite.sh): Full-system mode executing some apps from LLVM test-suite.
* [**run_arm_se_8_cores_with_different_workloads.sh**](run_arm_se_8_cores_with_different_workloads.sh): System call emulation mode, 8 cores with different workloads (experimental).
* [**run_arm_se_benchmarks.sh**](run_arm_se_benchmarks.sh): System call emulation mode executing some apps.
* [**run_arm_se_hbm_eltrace.sh**](run_arm_se_hbm_eltrace.sh): System call emulation mode HBM as main memory using elastic traces as stimuli.
* [**run_arm_se_hmc.sh**](run_arm_se_hmc.sh): System call emulation mode HMC as main memory.

#### **Run the scripts.**

A suggestion on how to run the scripts follows:

Build some benchmark programs:
```bash
$ ./build_llvm_test_suite_apps.sh
$ ./build_parsec_apps.sh
$ ./build_stream_app.sh
$ ./build_stride_apps.sh
```

Create disk images with the benchmark programs inside (this script uses
**sudo**):
```bash
$ ./create_images.sh
```

Execute benchmarks:
```bash
$ ./run_arm_fs_test_suite.sh
$ ./run_arm_se_benchmarks.sh
```

### Notes

SE mode hello using [se.py].

```bash
~/gem5_tnt/gem5$ build/ARM/gem5.opt configs/example/se.py -c ./tests/test-progs/hello/bin/arm/linux/hello
```

SE mode hello in 8 cores using [starter_se.py].

```bash
~/gem5_tnt/gem5$ build/ARM/gem5.opt \
	configs/example/arm/starter_se.py \
	--cpu=hpi --num-cores=8 --mem-channels=1 \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello \
	./tests/test-progs/hello/bin/arm/linux/hello
```

### **The Arm Research Starter Kit: System Modeling using gem5**

The [**Arm Research Starter Kit**](https://github.com/arm-university/arm-gem5-rsk) will guide you through Arm-based system modeling using the gem5 simulator.

[se.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/configs/example/se.py
[starter_se.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/configs/example/arm/starter_se.py
