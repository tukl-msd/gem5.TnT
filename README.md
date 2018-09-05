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
* [**Here**](doc/Gem5Basics.md) you'll find some gem5 basics just to warmup. Remember, though, to take a look at [**gem5's website**](http://www.gem5.org/Main_Page).
* [**Here**](arch/arm/README.md) you'll find some useful scripts and information for running benchmarks on gem5 for the arm architecture.
* [**Here**](patches/gem5/asimbench/README.md) you'll find how you can run android on your gem5.
* [**Here**](patches/gem5/HBM_elastic_traces/README.md) you'll find the steps to run elastic traces on gem5 using HBM as the main memory.
* [**Here**](https://github.com/tukl-msd/gem5.bare-metal) you'll find the steps to run an example gem5 ARM bare-metal implementation. 

### **Using gem5.TnT**

#### **Clone the repository and change to its directory:**

```bash
git clone https://github.com/tukl-msd/gem5.TnT.git
cd gem5.TnT
```

#### **Run the scripts.**

A suggestion on how to do that follows:

Install known dependencies (note that this one has to be run with sudo or as
root):
```bash
sudo bash dep_install.sh
```

Get repositories:
```bash
bash get_essential_repos.sh
```

Get some full system simulation files:
```bash
bash get_essential_fs.sh
```

Get some benchmark suites:
```bash
bash get_benchmarks.sh
```

#### **Download documentation**

Optionally, download some documentation with:
```bash
bash get_doc.sh
```

The default directory for downloads is **$HOME/gem5_tnt**. That means a new
directory called **gem5_tnt** will be created in your home folder and
populated with relevant files, documentation and repositories. In case you want to
change the default paths edit the [defaults.in](common/defaults.in) file in your
local repository before running the scripts.

A convenient script (**do_it_for_me.sh**)[do_it_for_me.sh] is provided.

### **Quick Hints**

#### Default python version is not python2.7:

```bash
python2.7 `which scons` build/<arch>/gem5.<mode> -j<num jobs>
```

Example:

```bash
python2.7 `which scons` build/ARM/gem5.opt -j$(cat /proc/cpuinfo | grep processor | wc -l)
```

#### Memory allocation error on Linux.

```bash
sudo su
echo 1 > /proc/sys/vm/overcommit_memory
```

