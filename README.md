## gem5 Tips & Tricks
### **Tips and tricks to make your life easier when dealing with gem5**

This repository contains tips and tricks about gem5. It is intended to gather and share useful hints about gem5, so that the learning process is accelerated.

* [**depinstall.sh**](depinstall.sh): installs known dependencies.
* [**getrepos.sh**](getrepos.sh): clones gem5 related repositories.
* [**getfs.sh**](getfs.sh): downloads full system files.
* [**getdoc.sh**](getdoc.sh): downloads documentation and tutorials.
* [**getbenchmarks.sh**](getbenchmarks.sh): downloads some benchmarks.
* [**Here**](arch/arm/README.md) you'll find some useful scripts and information for running benchmarks on gem5 for the arm architecture.
* [**Here**](patches/gem5/asimbench/README.md) you'll find how you can run android on your gem5!
* [**Here**](doc/Gem5Basics.md) you'll find some gem5 basics just to warmup. Remember, though, to take a look at [**gem5's website**](http://www.gem5.org/Main_Page).
* [**Here**](doc/ToolchainBasics.md) you'll find some basics about toolchains. This is useful when exploring different architectures.

### **Using gem5.TnT**

For optimal experience install the programms that follow as root or use sudo:

```bash
apt-get install cowsay
apt-get install libnotify-bin
```

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
sudo bash depinstall.sh
```

Get documentation:
```bash
bash getdoc.sh
```

Get repositories:
```bash
bash getrepos.sh
```

Get some full system simulation files:
```bash
bash getfs.sh
```

Get some benchmark suites:
```bash
bash getbenchmarks.sh
```

The default directory for downloads is **$HOME/gem5_tnt**. That means a new
directory called **gem5_tnt** will be created in your home folder and
populated with relevant documentation, repositories, etc. In case you want to
change the default paths edit the [defaults.in](common/defaults.in) file in your
local repository before running the scripts.
