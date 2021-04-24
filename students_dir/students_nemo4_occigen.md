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

Note that if you change these modules, the netcdf paths can be found from:
```bash
nc-config --libs
```

# Get the NEMO (ocean/sea-ice model) and XIOS (IO server) sources

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

# Compile XIOS

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

Once completed, check that you have the executable:
```bash
ls bin/xios_server.exe
```

# Compile NEMO

```bash
cd $SCRATCHDIR/models/nemo_v4_trunk # or any other release
```

```bash
cat << EOF > arch/arch-X64_OCCIGENbis.fcm
# NCDF_HOME   root directory containing lib and include subdirectories for netcdf4
# HDF5_HOME   root directory containing lib and include subdirectories for HDF5
# XIOS_HOME   root directory containing lib for XIOS
# OASIS_HOME  root directory containing lib for OASIS
#
# NCDF_INC    netcdf4 include file
# NCDF_LIB    netcdf4 library
# XIOS_INC    xios include file    (taken into accound only if key_iomput is activated)
# XIOS_LIB    xios library         (taken into accound only if key_iomput is activated)
# OASIS_INC   oasis include file   (taken into accound only if key_oasis3 is activated)
# OASIS_LIB   oasis library        (taken into accound only if key_oasis3 is activated)
#
# FC          Fortran compiler command
# FCFLAGS     Fortran compiler flags
# FFLAGS      Fortran 77 compiler flags
# LD          linker
# LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries
# FPPFLAGS    pre-processing flags
# AR          assembler
# ARFLAGS     assembler flags
# MK          make
# USER_INC    complete list of include files
# USER_LIB    complete list of libraries to pass to the linker
# CC          C compiler used to compile conv for AGRIF
# CFLAGS      compiler flags used with CC
#
# Note that:
#  - unix variables "$..." are accpeted and will be evaluated before calling fcm.
#  - fcm variables are starting with a % (and not a $)
#
%NCDF_HOME           /opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-4.6.3-ilty/
%NCDF_HOME_FORTRAN   /opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-fortran-4.4.4-hnmh/
%HDF5_HOME           /opt/software/occigen/spack/linux-rhel7-x86_64/intel-19.0.4/netcdf-fortran-4.4.4-hnmh/
%XIOS_HOME           $SCRATCHDIR/models/xios-2.5
%OASIS_HOME          $SCRATCHDIR/models/oa3mct

%NCDF_INC            -I%NCDF_HOME/inc -I%NCDF_HOME_FORTRAN/inc
%NCDF_LIB            -L%NCDF_HOME/lib -lnetcdf -L%NCDF_HOME_FORTRAN/lib -lnetcdff
%XIOS_INC            -I%XIOS_HOME/inc
%XIOS_LIB            -L%XIOS_HOME/lib -lxios -lstdc++
%OASIS_INC           -I%OASIS_HOME/build/lib/mct -I%OASIS_HOME/build/lib/psmile.MPI1
%OASIS_LIB           -L%OASIS_HOME/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip

%CPP                 cpp
%FC                  mpif90 -c -cpp
%FCFLAGS             -i4 -r8 -O3 -fp-model precise -xAVX -fno-alias -traceback
%FFLAGS              %FCFLAGS
%LD                  mpif90
%FPPFLAGS            -P  -traditional
%LDFLAGS             -lstdc++
%AR                  ar
%ARFLAGS             rs
%MK                  gmake
%USER_INC            %XIOS_INC %OASIS_INC %NCDF_INC
%USER_LIB            %XIOS_LIB %OASIS_LIB %NCDF_LIB

%CC                  cc
%CFLAGS              -O0
EOF

To know the options of makenemo (the NEMO compiler):
```bash
makenemo -h
```

You can try to compile one of the provided configuration to check that everything is well set up, e.g.:
```bash
makenemo -r WED025 -m X64_OCCIGENbis -j 8
ls cfgs/WED025/BLD/bin/nemo.exe # to check that compilation worked
```



