---
layout: post
title: Running NEMO4 on occigen
date: 20-04-2021
---

**Contributors:** Nicolas Jourdain, Pierre Mathiot.

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
```

To know the options of makenemo (the NEMO compiler):
```bash
makenemo -h
```

You can try to compile one of the provided configuration to check that everything is well set up, e.g.:
```bash
makenemo -r WED025 -m X64_OCCIGENbis -j 8
ls cfgs/WED025/BLD/bin/nemo.exe # to check that compilation worked
```

To create and compile a new configuration (e.g. "AMU", including ocean and sea-ice), do as follows:
```bash
export CONFEXE='AMU'
echo "$CONFEXE  OCE ICE" >> cfgs/ref_cfgs.txt
mkdir cfgs/$CONFEXE
echo " bld::tool::fppkeys key_xios key_si3" > cfgs/${CONFEXE}/cpp_${CONFEXE}.fcm
makenemo -r ${CONFEXE} -m X64_OCCIGENbis -j 8
ls cfgs/${CONFEXE}/BLD/bin/nemo.exe
```
To modify some routines, copy them from ```cfgs/${CONFEXE}/WORK``` to ```cfgs/${CONFEXE}/MY_SRC```, modify them and recompile (the files in ```MY_SRC``` will be compiled instead of those in ```WORK```).

# Create inputs for the new NEMO configuration

Choose a configuration name (typically <region><horizontal\_resolution>.L<vertical_resolution>) and create the input directory:
```bash
export CONFIG='AMUXL025.L75' # adapt
mkdir -pv ${SCRATCHDIR}/input
mkdir -pv ${SCRATCHDIR}/input/${CONFIG}
``` 

Now we are going to use Nico's pre-processing toolbox to create new NEMO regional configurations (child domain) from parent configurations (global or regional). The following steps are to be done only once (not each time you create a configuration). 
```bash
cd ${SCRATCHDIR}/input
git clone https://github.com/nicojourdain/BUILD_CONFIG_NEMO.git
# or git clone git@github.com:nicojourdain/BUILD_CONFIG_NEMO.git
cd BUILD_CONFIG_NEMO/GSW-Fortran/test
vi makefile # check FC and NETCDF_INCDIR
make
./gsw_check  ## to check (some have to pass, maybe not all of them)
cd ../..
vi compile_ALL.sh # check FC
./compile_ALL.sh
```

The following steps rely on a preprocessing namelist. You can either use an existing one adapt one of the provided ones:
```bash
vi namelist_${CONFIG}
ln -s -v namelist_${CONFIG} namelist_pre
```
```namelist_pre``` is the one read by the processing tools.

NB: The file ```submit.sh``` is used to submit jobs with headers on clusters, so you may need to adapt it if you use a new machine.

Then, create the bathymetry (possibly including ice-shelf draft) and coordinate files:
```bash
./submit.sh extract_bathy_coord 01
ls ../nemo_${CONFIG}/bathy_meter_${CONFIG}.nc
ls ../nemo_${CONFIG}/coordinates_${CONFIG}.nc
```

If your are happy with the newly created bathymetry (which is from the parent grid), go directly to the next step. Otherwise, if you want to replace the bathymetry (and maybe ice draft) with an interpolation from a dataset, fill the ```&bathy_special``` section of the namelist, then remove the previous bathymetry file, e.g. :
```bash
rm -f ../nemo_${CONFIG}/bathy_meter_${CONFIG}.nc
```
Then, if the dataset is on a lon/lat grid :
```bash
./submit.sh extract_bathy_special_lonlat 03 30
```      
or if the dataset is on a stereographic grid (use 60Gb instead of 30 for BedMachine):
```bash
./submit.sh extract_bathy_special_stereo 03 30
```

To make the following description qui general, we define ```$MY_NEMO``` as:
```bash
export MY_NEMO='nemo_v4_trunk' # adapt to the one you compiled
cd ${SCRATCHDIR}/models/${MY_NEMO}
```

Then, compile the NEMO tools called DOMAINcfg and REBUILD_NEMO (do not forget to re-load modules if necessary):
```bash
cd tools
./maketools -m X64_OCCIGENbis -n DOMAINcfg
ls -al DOMAINcfg/BLD/bin/make_domain_cfg.exe
ls -al DOMAINcfg/BLD/bin/dom_doc.exe
./maketools -m X64_OCCIGENbis -n REBUILD_NEMO
ls -al REBUILD_NEMO/BLD/bin/rebuild_nemo.exe
```

Then, create mesh_mask_${CONFIG}.nc and domain_cfg_${CONFIG}.nc as follows:
```bash
cd ${SCRATCHDIR}/input/nemo_${CONFIG}
mkdir DOMAINcfg
cd DOMAINcfg
ln -s -v ${SCRATCHDIR}/models/${MY_NEMO}/tools/DOMAINcfg/BLD/bin/make_domain_cfg.exe
ln -s -v ${SCRATCHDIR}/models/${MY_NEMO}/tools/DOMAINcfg/BLD/bin/dom_doc.exe
cp -p ${SCRATCHDIR}/models/${MY_NEMO}/tools/DOMAINcfg/namelist_ref .
cp -p ${SCRATCHDIR}/models/${MY_NEMO}/tools/DOMAINcfg/namelist_cfg .
vi namelist_ref # default values for all namelist parameters (keep unchanged)
vi namelist_cfg # set values that should differ from namelist_ref
                # set nn_msh=1 to obtain a mesh_mask file
                # and put the seeds in the oceanic part of the domain (namzgr_isf and namclo)

cat <<EOF > run.sh
#!/bin/bash
#SBATCH -C HSW24
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --threads-per-core=1
#SBATCH -J run_DOMAINcfg
#SBATCH -e run_DOMAINcfg.e%j
#SBATCH -o run_DOMAINcfg.o%j
#SBATCH --time=00:09:00
mpirun -np 8 ./make_domain_cfg.exe
EOF

chmod +x run.sh
sbatch ./run.sh
ls -al mesh_mask_00??.nc
ls -al domain_cfg_00??.nc
ln -s -v ${SCRATCHDIR}/models/${MY_NEMO}/tools/REBUILD_NEMO/BLD/bin/rebuild_nemo.exe
ln -s -v ${SCRATCHDIR}/models/${MY_NEMO}/tools/REBUILD_NEMO/rebuild_nemo
rebuild_nemo -d 1 -x 200 -y 200 -z 1 -t 1 mesh_mask 8 
rebuild_nemo -d 1 -x 200 -y 200 -z 1 -t 1 domain_cfg 8 
dom_doc.exe -n namelist_cfg -d domain_cfg.nc # to save namelist in domain_cfg.nc
mv mesh_mask.nc ../mesh_mask_${CONFIG}.nc
mv domain_cfg.nc ../domain_cfg_${CONFIG}.nc
rm -f mesh_mask_00??.nc domain_cfg_00??.nc
```
Note that the namelist_cfg can be re-extracted from domain_cfg_${CONFIG}.nc as follows:
```bash
ln -s -v ${SCRATCHDIR}/models/${MY_NEMO}/tools/REBUILD_NEMO/xtrac_namelist.bash
./xtrac_namelist.bash domain_cfg_${CONFIG}.nc restored_namelist_cfg
```

