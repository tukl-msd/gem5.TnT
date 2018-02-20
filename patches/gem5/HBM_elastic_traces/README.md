## gem5 Tips & Tricks
### **Running elastic traces using HBM as the main memory**

Here you'll find an example to run simple elastic traces using HBM as the memory.

To understand what elastic traces are, please refer to the documentation here: [**TraceCPU at gem5.org**](http://gem5.org/TraceCPU).

Make sure everything is setup! You're all done if you followed [**the steps described here**](../../../README.md).

Now we perform some steps to get the required setup for the simulation.

Firstly, since the source code changes required for HBM are still not incorporated into the official gem5 release, we need to patch the existing repository with certain additions.

Apply the patch to your gem5 source code using the below command. Make sure you are in the gem5 directory while executing this command.

```bash
patch -p1 -f < <path_to_gem5.TnT_repo>/patches/gem5/HBM_elastic_traces/hbm.patch
```

After applying the patch you have to build gem5 again. But don't worry, this time the build process will finish much faster than the first build.

Run gem5.

```bash
build/ARM/gem5.opt configs/example/hbm_hello.py -d hbm_etrace --mem-size=1GB --data-trace-file=<path_to_gem5.TnT_repo>/elastic_traces/system.cpu.traceListener.random.data.gz --inst-trace-file=<path_to_gem5.TnT_repo>/elastic_traces/system.cpu.traceListener.random.inst.gz
```

The outputs are generated in the hbm_etrace directory. The config.dot.pdf file gives a nice pictorial representation of the system we created for the simulation and the stats.txt file gives the tabulated results of the simulation.

Now that the system is setup, different trace files could be used based on requirements.
