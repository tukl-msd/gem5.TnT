## gem5 Tips & Tricks
### **Tips and tricks for the ARM architecture**

Here you will find tips and tricks for the ARM architecture.

Before running the scripts below make sure everything else is setup! You're all done if you followed [**the steps described here**](../../README.md).

* [**boot_android.sh**](boot_android.sh): boots android.
* [**boot_linaro.sh**](boot_linaro.sh): boots linaro.
* [**boot_linaro_big_little.sh**](boot_linaro_big_little.sh): boots linaro with fs_bigLITTLE.py. Note that SimpleMemory is used, so you may want to change the example script fs_bigLITTLE.py.
* [**boot_ubuntu.sh**](boot_ubuntu.sh): boots ubuntu (*experimental*). It is necessary to change */etc/fstab* inside the disk, check [boot-ubuntu-fstab](boot-ubuntu-fstab) to get ideas. You may also want to change the kernel command line and/or Ubuntu initialization files.
* [**build_llvm_test_suite_apps.sh**](build_llvm_test_suite_apps.sh): builds some apps from LLVM test-suite.
* [**build-parsec.sh**](build-parsec.sh): builds some apps from parsec-3.0 benchmark suite.
* [**build_stream_app.sh**](build_stream_app.sh): builds stream app.
* [**build_stride_apps.sh**](build_stride_apps.sh): builds stride v1.1 apps.
* [**create_images.sh**](create_images.sh): builds disk images containing the benchmark programs. It uses **sudo**.
* [**parsec.sh**](parsec.sh): Full-system mode executing parsec-3.0 apps.
* [**run_arm_fs_stream.sh**](run_arm_fs_stream.sh): Full-system mode executing stream app.
* [**run_arm_fs_stride.sh**](run_arm_fs_stride.sh): Full-system mode executing stride v1.1 apps.
* [**run_arm_fs_test_suite.sh**](run_arm_fs_test_suite.sh): Full-system mode executing some apps from LLVM test-suite.
* [**run_arm_se_stream.sh**](run_arm_se_stream.sh): SE mode modified version of stream
* [**run_arm_se_8_cores_with_different_workloads.sh**](run_arm_se_8_cores_with_different_workloads.sh): System call emulation mode, 8 cores with different workloads.
* [**run_arm_se_benchmarks.sh**](run_arm_se_benchmarks.sh): System call emulation mode executing some apps.
* [**run_arm_se_hbm_eltrace.sh**](run_arm_se_hbm_eltrace.sh): System call emulation mode HBM as main memory using elastic traces as stimuli.
* [**run_arm_se_hmc.sh**](run_arm_se_hmc.sh): System call emulation mode HMC as main memory.
* [**Bare Metal**](https://github.com/tukl-msd/gem5.bare-metal) here you will find the steps to run an example gem5 ARM bare-metal implementation. 
* [**Elastic Trace + HBM Main Memory**](../../patches/gem5/HBM_elastic_traces/README.md) steps to run elastic traces on gem5 using HBM as main memory.
* **[compile-kernel-aarch64.sh]**: convenience script for compiling and testing a kernel
* **[compile-kernel-aarch32.sh]**: convenience script for compiling and testing a kernel
* **[boot-linux-aarch64.sh]**: convenience script for booting Linux.
* **[boot-linux-aarch32.sh]**: convenience script for booting Linux.
* **[wa-setup.sh]**: creates disk images with applications inside (bw_mem, dhrystone, hackbench, lat_mem_rd, memcpy, rt-app, stress-ng, sysbench).

#### **Run the scripts.**

A suggestion on how to run the scripts follows:

Build some benchmark programs:
```bash
$ ./build_llvm_test_suite_apps.sh
$ ./build-parsec.sh
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

### SE Mode

SE mode hello using [se.py].

```bash
$ cd $HOME/gem5_tnt/gem5
$ ./build/ARM/gem5.opt configs/example/se.py \
		-c ./tests/test-progs/hello/bin/arm/linux/hello
```

SE mode stream with [se.py].
```bash
$ cd $HOME/gem5_tnt/gem5
$ ./build/ARM/gem5.opt configs/example/se.py \
		--cpu-type="TimingSimpleCPU" \
		-c $HOME/gem5_tnt/benchmarks/stream/stream_c.exe 
```

SE mode hello in 8 cores using [starter_se.py].

```bash
$ cd $HOME/gem5_tnt/gem5
$ ./build/ARM/gem5.opt \
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

### Android FS Mode

```bash
$ ./boot_android.sh
```

Connect with *m5term*.

```bash
$ cd $HOME/gem5_tnt/gem5
$ cd util/term
$ make
$ ./m5term localhost 3456
```

Connect with *telnet*.

```bash
$ telnet localhost 3456
```

Connect with *vncviewer*.

```bash
$ vncviewer localhost:5901
```

### Kernel

Loading default configuration *gem5_defconfig*:

```bash
$ cd $HOME/gem5_tnt/kernel/arm/linux
$ make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- gem5_defconfig
```

The default configuration will be written to *.config*.

Open interface to edit/view configuration:

```bash
$ make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
```

or

```bash
$ make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- xconfig
```

After saving changes, to compile:

```bash
$ make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j `nproc`
```

See also: [gen_arm_fs_files.py]

### Bootloader

```bash
$ cd $HOME/gem5_tnt/gem5
```

```bash
$ make -C system/arm/simple_bootloader
```

```bash
$ make -C system/arm/aarch64_bootloader
```

See also: [gen_arm_fs_files.py]

### DTB

```bash
$ cd $HOME/gem5_tnt/gem5
```

```bash
$ make -C system/arm/dt
```

See also: [gen_arm_fs_files.py]

### More Resources, Useful Links

[Arm Research Starter Kit](https://github.com/arm-university/arm-gem5-rsk)

[WA-gem5](http://www.gem5.org/WA-gem5)

[https://github.com/ARM-software/workload-automation](https://github.com/ARM-software/workload-automation)

[https://bitbucket.org/yongbing_huang/asimbench](https://bitbucket.org/yongbing_huang/asimbench)

[http://www.gem5.org/BBench-gem5](http://www.gem5.org/BBench-gem5)

[http://www.gem5.org/dist/current/arm/](http://www.gem5.org/dist/current/arm/)


[se.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/configs/example/se.py
[starter_se.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/configs/example/arm/starter_se.py
[compile-kernel-aarch32.sh]: compile-kernel-aarch32.sh
[compile-kernel-aarch64.sh]: compile-kernel-aarch64.sh
[gen_arm_fs_files.py]: https://gem5.googlesource.com/public/gem5/+/refs/heads/master/util/gen_arm_fs_files.py
