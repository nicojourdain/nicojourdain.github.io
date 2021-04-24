---
layout: post
title: Running NEMO4 on occigen
date: 20-04-2021
---

If you are new to occigen, see [this page](https://nicojourdain.github.io/students_dir/students_python_occigen/) for information on how to get an account and connect.

The official documentation on downloading and installing the NEMO code can be found [on the NEMO website](https://forge.ipsl.jussieu.fr/nemo/chrome/site/doc/NEMO/guide/html/install.html).

# Module environment

The steps below can work with several modules, but here is the recommended list:
```bash
module purge
module load gcc/8.3.0
module load intel/19.4
module load intelmpi/5.1.3.258
module load netcdf-fortran/4.4.4-intel-19.0.4-intelmpi-2019.4.243
module load netcdf/4.6.3-intel-19.0.4-intelmpi-2019.4.243
module load hdf5/1.10.5-intel-19.0.4-intelmpi-2019.4.243
```

# Get the NEMO and xios sources

```bash
cd $SCRATCHDIR
mkdir models
cd models
svn co https://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/r4.0/r4.0.6 nemo_r4.0.6
svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5
```

To get the trunk (version under development) instead of a specific revision:
```bash
svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/trunk nemo_v4_trunk
```

# Compile xios

```bash
cd xios-2.5
```

We create three files in the ```arch``` directory to set up the pathways, compilation options and environment:

```bash
cat << EOF > arch/arch-X64_OCCIGENbis.env
#!/bin/bash
module unload netcdf hdf5 intel
module load gcc/8.3.0
module load intel/19.4
module load intelmpi/5.1.3.258
module load netcdf-fortran/4.4.4-intel-19.0.4-intelmpi-2019.4.243
module load netcdf/4.6.3-intel-19.0.4-intelmpi-2019.4.243
module load hdf5/1.10.5-intel-19.0.4-intelmpi-2019.4.243

export HDF5_INC_DIR=/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/hdf5-1.10.5-nnfz/include
export HDF5_LIB_DIR=/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/hdf5-1.10.5-nnfz/lib
EOF
```

```bash
cat << EOF > arch/arch-X64_OCCIGENbis.fcm
%CCOMPILER      mpiicc
%FCOMPILER      mpiifort
%LINKER         mpiifort    -nofor-main

%BASE_CFLAGS    -diag-disable 1125 -diag-disable 279 -std=gnu++98
%PROD_CFLAGS    -O3 -D BOOST_DISABLE_ASSERTS
%DEV_CFLAGS     -g -traceback
%DEBUG_CFLAGS   -DBZ_DEBUG -g -traceback -fno-inline

%BASE_FFLAGS    -D__NONE__
%PROD_FFLAGS    -O3
%DEV_FFLAGS     -g -O2 -traceback
%DEBUG_FFLAGS   -g -traceback

%BASE_INC       -D__NONE__
%BASE_LD        -lstdc++

%CPP            mpiicc -EP
%FPP            cpp -P
%MAKE           gmake
EOF
```

```bash
cat << EOF > arch/arch-X64_OCCIGENbis.path
NETCDF_INCDIR="-I/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-fortran-4.4.4-hnmh/include -I/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-4.6.3-ilty/include"
NETCDF_LIBDIR="-L/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-fortran-4.4.4-hnmh/lib -L/opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-4.6.3-ilty/lib"
NETCDF_LIB="-lnetcdff -lnetcdf"

MPI_INCDIR=""
MPI_LIBDIR=""
MPI_LIB=""

HDF5_INCDIR="-I$HDF5_INC_DIR"
HDF5_LIBDIR="-L$HDF5_LIB_DIR"
HDF5_LIB="-lhdf5_hl -lhdf5 -lhdf5 -lz"

OASIS_INCDIR="-I$PWD/../../oasis3-mct/BLD/build/lib/psmile.MPI1"
OASIS_LIBDIR="-L$PWD/../../oasis3-mct/BLD/lib"
OASIS_LIB="-lpsmile.MPI1 -lscrip -lmct -lmpeu"
EOF
```

Then compile xios:
```bash
./make_xios --prod --full --arch X64_OCCIGENbis --job 8
```
