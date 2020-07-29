---
layout: post
title: Installing Ferret
date: 19-11-2018
---

You can either install a pre-compiled version (example below for linux), or re-compile it yourself (example below for mac OSX).

# Install a pre-compiled Ferret on linux

Here is an example for Ferret v6.93, which works on GRICAD's **luke**:

```shell
mkdir /home/bob/ferret_v6.93
cd /home/bob/ferret_v6.93
wget ftp://ftp.pmel.noaa.gov/ferret/pub/rhel6_64/fer_executables.tar.gz
wget ftp://ftp.pmel.noaa.gov/ferret/pub/rhel6_64/fer_environment.tar.gz
tar xvzf fer_executables.tar.gz
tar xvzf fer_environment.tar.gz
./bin/Finstall
     #
     # (1, 2, 3, q, x) --> 1
     #
     # FER_DIR --> /home/bob/ferret_v6.93
     #
     # 'fer_executables.tar.gz' location --> /home/bob/ferret_v6.93
     #
```

```shell
mkdir fer_dsets
cd fer_dsets
wget wget ftp://ftp.pmel.noaa.gov/ferret/pub/data/fer_dsets.tar.gz
tar xvzf fer_dsets.tar.gz
cd ..
./bin/Finstall
     #
     # (1, 2, 3, q, x) --> 2
     #
     # FER_DIR --> /home/bob/ferret_v6.93
     #
     # FER_DSETS --> /home/bob/ferret_v6.93/fer_dsets
     #
     # desired ferret_paths location --> /home/bob/ferret_v6.93
     #
     # ferret_paths link to create? (c/s/n) [n] --> s
     #
echo '                                                     ' >> ~/.bashrc
echo '# Ferret                                             ' >> ~/.bashrc
echo 'export PATH="/home/bob/ferret_v6.93/bin:$PATH" ' >> ~/.bashrc
echo 'source /home/bob/ferret_v6.93/ferret_paths     ' >> ~/.bashrc
rm -f *gz fer_dsets/*gz
```

# Install Ferret on mac OS-X

See latest documentation on [https://github.com/NOAA-PMEL/Ferret/blob/master/README_ferret_mac_homebrew.md](https://github.com/NOAA-PMEL/Ferret/blob/master/README_ferret_mac_homebrew.md)

Assuming that you have installed [homebrew](https://brew.sh), you can follow these steps to compile Ferret on you mac OSX.

```shell
xcode-select --install
```

Then, install (brew install) or upgrade (brew upgrade) gcc, readline, hdf5 and netcdf :
```shell
brew install gcc
brew install readline
brew install hdf5
brew install netcdf
```

Get Ferret:
```shell
mkdir git
git clone https://github.com/NOAA-PMEL/Ferret.git ~/git/Ferret
```

If you don't want the latest release, check the available tagged versions [here](https://github.com/NOAA-PMEL/Ferret/releases). For example, to get the 7.4.4 version, do:
```shell
git clone https://github.com/NOAA-PMEL/Ferret.git ~/git/Ferret --branch 7.4.4
```

Before installing Ferret, the people using anaconda may need to comment the lines that export PATH to include anaconda pathways in your .bashrc or .bash\_profile (because this messes up the automatic config commands, e.g. nc-config) then to source your .bashrc or .bash\_profile. Then, install Ferret:
```shell
cd ~/git/Ferret
cp -p site_specific.mk.in site_specific.mk
vi site_specific.mk ## E.g. of choices (check on your system) :
# DIR_PREFIX = $(HOME)/git/Ferret
# BUILDTYPE = intel-mac
# INSTALL_FER_DIR = $(HOME)/Ferret-7.4.4
# HDF5_LIBDIR =
# SZ_LIBDIR =
# NETCDF_LIBDIR = /usr/local/Cellar/netcdf/4.6.3_1/lib
# READLINE_LIBDIR = /usr/local/Cellar/readline/8.0.0_1/lib
cp -p external_functions/ef_utility/site_specific.mk.in external_functions/ef_utility/site_specific.mk
vi external_functions/ef_utility/site_specific.mk ## put BUILDTYPE = intel-mac
make # takes a few minutes
make install
``` 

Then, get some datasets used by ferret:
```shell
cd ~/Ferret-7.4.4
mkdir fer_dsets
cd fer_dsets
wget ftp://ftp.pmel.noaa.gov/ferret/pub/data/fer_dsets_smaller.tar.gz
gunzip fer_dsets_smaller.tar.gz
tar xvf fer_dsets_smaller.tar 
rm -f fer_dsets_smaller.tar
```

Run Finstall to create the pathways:
```shell
cd ~/Ferret-7.4.4/bin
sudo ./Finstall
# Enter your choice:
# (1) Install executables, (2) Customize ferret_paths files, (3,q,x) Exit
# (1, 2, 3, q, x) --> 2
# 
# Customize ferret_paths files...
# 
# Enter the name of the directory where the 'fer_environment.tar.gz' 
# file was installed/extracted (FER_DIR).  The location recommended 
# in the Ferret installation guide was '/usr/local/ferret'. 
# 
# FER_DIR --> /Users/jourdain/Ferret-7.4.4
# 
# Enter the name of the directory where the 'fer_dsets.tar.gz' 
# file was installed/extracted (FER_DSETS).
# 
# FER_DSETS --> /Users/jourdain/Ferret-7.4.4/fer_dsets
# 
# Enter the name of the directory where you want to place 
# the newly created 'ferret_paths.csh' and 'ferret_path.sh' 
# files; for example, '/usr/local'.
# 
# desired ferret_paths location --> /usr/local
# 
# To duplicate behavior found in older version of Ferret, you can 
# create a link (shortcut) 'ferret_paths' that refers to either 
# 'ferret_paths.csh' or 'ferret_paths.sh'.  This is simply a 
# convenience for users and should only be done on systems where 
# all Ferret users work under the same shell (such as tcsh or bash). 
# The files 'ferret_path.csh' and 'ferret_paths.sh' can always be 
# used regardless of the answer to this question. 
# 
# ferret_paths link options: 
#    c - link to ferret_paths.csh (all users work under tcsh, csh) 
#    s - link to ferret_paths.sh (all users work under bash, dash, ksh, sh) 
#    n - do not create the link (use ferret_paths.csh or ferret_paths.sh)
# ferret_paths link to create? (c/s/n) [n] --> s
```

Then, run these two lines or add them to your .bashrc file or equivalent:
```shell
export PATH="/Users/jourdain/Ferret-7.4.4/bin:$PATH"
source /usr/local/ferret_paths
```
