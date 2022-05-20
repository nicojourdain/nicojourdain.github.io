---
layout: post
title: Preparing and running NEMO4.2 on Irene-Rome (TGCC)
date: 11-05-2022
---

**Contributors:** Nicolas Jourdain, Pierre Mathiot.

**NB:** the content of this page has been tested with NEMO-4.2.0 and XIOS's trunk at revision 2326.

**Content:**
1. Module environment
3. Get and compile XIOS
3. Get and compile NEMO
4. Create inputs for the new NEMO configuration
   1. Create coordinate and bathymetry files
   2. Create the DOMAINcfg and mesh\_mask files
   3. Create initial state file
   4. Create files for lateral boundary conditions
   5. Create files for runoff and sea surface salinity restoring
   6. Create weights for on-the-fly interpolation of atmospheric forcing
5. Running NEMO

If you are new to TGCC, see [this page](http://www-hpc.cea.fr/en/complexe/tgcc.htm) for information on how to get an account.

The official documentation on downloading and installing the NEMO code can be found [on the NEMO website](https://sites.nemo-ocean.io/user-guide/install.html)


## 1. Module environment

Load the apropriate environment:
```bash
module unload netcdf-c netcdf-fortran hdf5 flavor perl hdf5 boost blitz mpi
module load mpi/openmpi/4.0.2
module load flavor/hdf5/parallel
module load netcdf-fortran/4.4.4
module load hdf5/1.8.20
module load boost
module load blitz
module load feature/bridge/heterogenous_mpmd
module load gnu
```

To access to all the project directories of your group, you need to do this (replace gen6035 by your project ID):
```bash
export PROJECT='gen6035'
module switch dfldatadir/$PROJECT
TMP="${PROJECT^^}_CCCSCRATCHDIR";     export SCRATCHDIR=${!TMP}
TMP="${PROJECT^^}_CCCWORKDIR";        export WORKDIR=${!TMP}
TMP="${PROJECT^^}_CCCSTOREDIR";       export STOREDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCHOME";       export SHAREDHOME=${!TMP}
TMP="${PROJECT^^}_ALL_CCCSCRATCHDIR"; export SHAREDSCRATCHDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCWORKDIR";    export SHAREDWORKDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCSTOREDIR";   export SHAREDSTOREDIR=${!TMP}
```

Note that all this can be included in ~/.bashrc.


## 2. Get XIOS (Input/Output Server) and compile it

```bash
cd $WORKDIR
mkdir -pv models
cd models
svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/trunk xios_trunk
cd xios_trunk
```

```bash
cat << EOF > arch/arch-X64_IRENEige.env
#!/bin/bash
module unload netcdf-c netcdf-fortran hdf5 flavor perl hdf5 boost blitz mpi
module load mpi/openmpi/4.0.2
module load flavor/hdf5/parallel
module load netcdf-fortran/4.4.4
module load hdf5/1.8.20
module load boost
module load blitz
module load feature/bridge/heterogenous_mpmd
module load gnu
EOF
```

```bash
cat << EOF > arch/arch-X64_IRENEige.path
NETCDF_INCDIR="-I \$NETCDFC_INCDIR -I \$NETCDFFORTRAN_INCDIR"
NETCDF_LIBDIR="-L \$NETCDFC_LIBDIR -L \$NETCDFFORTRAN_LIBDIR"
NETCDF_LIB="-lnetcdf -lnetcdff"

MPI_INCDIR=""
MPI_LIBDIR=""
MPI_LIB=""

HDF5_INCDIR="-I\$HDF5_INCDIR"
HDF5_LIBDIR="-L\$HDF5_LIBDIR"
HDF5_LIB="-lhdf5_hl -lhdf5 -lz -lcurl"

BOOST_INCDIR="-I \$BOOST_INCDIR"
BOOST_LIBDIR="-L \$BOOST_LIBDIR"
BOOST_LIB=""

BLITZ_INCDIR="-I \$BLITZ_INCDIR"
BLITZ_LIBDIR="-L \$BLITZ_LIBDIR"
BLITZ_LIB=""

OASIS_INCDIR="-I\$PWD/../../oasis3-mct/BLD/build/lib/psmile.MPI1"
OASIS_LIBDIR="-L\$PWD/../../oasis3-mct/BLD/lib"
OASIS_LIB="-lpsmile.MPI1 -lscrip -lmct -lmpeu"


#only for MEMTRACK debuging : developper only
ADDR2LINE_LIBDIR="-L\${WORKDIR}/ADDR2LINE_LIB"
ADDR2LINE_LIB="-laddr2line"
EOF
```

```bash
cat << EOF > arch/arch-X64_IRENEige.fcm
%CCOMPILER      mpicc
%FCOMPILER      mpif90
%LINKER         mpif90  -nofor-main

%BASE_CFLAGS    -std=c++11 -diag-disable 1125 -diag-disable 279 -D__XIOS_EXCEPTION
%PROD_CFLAGS    -O3 -D BOOST_DISABLE_ASSERTS
%DEV_CFLAGS     -g
%DEBUG_CFLAGS   -DBZ_DEBUG -g -traceback -fno-inline

%BASE_FFLAGS    -D__NONE__
%PROD_FFLAGS    -O3 -mavx2 -axCORE-AVX2,CORE-AVX512
%DEV_FFLAGS     -g
%DEBUG_FFLAGS   -g -traceback

%BASE_INC       -D__NONE__
%BASE_LD        -lstdc++

%CPP            mpicc -EP
%FPP            cpp -P
%MAKE           gmake
EOF
```


Once completed, check that you have the executable:
```bash
./make_xios --prod --full --arch X64_IRENEige --job 8
ls bin/xios_server.exe
```


## 3. Get NEMO and compile it

To get NEMO, you first need to register to [NEMO's Gitlab](https://forge.nemo-ocean.eu/users/sign_in) (you will need to download a mobile app like *Duo Mobile* to get access). Then you will need to put the Irene SSH public key (created using ``` ssh-keygen -t rsa -b 4096 ```) onto Gitlab (go to *Preferences* in the menu of the upper right corner). You may also need to modify ~/.ssh/config to enable the access to Gitlab.

Then:
```bash
cd $WORKDIR/models
git clone --branch 4.2.0 https://forge.nemo-ocean.eu/nemo/nemo.git nemo_4.2.0
# or git clone --branch 4.2.0 git@forge.nemo-ocean.eu:nemo/nemo.git nemo_4.2.0
cd nemo_4.2.0
```

```bash
cat << EOF > arch/arch-X64_IRENEige.fcm
%XIOS_HOME           $WORKDIR/models/xios_trunk
%OASIS_HOME          $WORKDIR/models/oa3mct

%NCDF_INC            -I\$NETCDFFORTRAN_INCDIR -I\$NETCDF_INCDIR
%NCDF_LIB            -L\$NETCDFFORTRAN_LIBDIR -lnetcdff -L\$NETCDF_LIBDIR -lnetcdf -L\$HDF5_LIBDIR -lhdf5_hl -lhdf5 -lz -lcurl

%XIOS_INC            -I%XIOS_HOME/inc 
%XIOS_LIB            -L%XIOS_HOME/lib -lxios -lstdc++
%OASIS_INC           -I%OASIS_HOME/build/lib/mct -I%OASIS_HOME/build/lib/psmile.MPI1
%OASIS_LIB           -L%OASIS_HOME/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip

%CPP	             cpp
%FC                  mpif90 -c -cpp
%FCFLAGS             -i4 -r8 -O3 -fp-model strict -fno-alias -mavx2
#-axCORE-AVX2,CORE-AVX512 #fpe0
%FFLAGS              %FCFLAGS
%LD                  mpif90
%LDFLAGS             
%FPPFLAGS            -P -traditional
%AR                  ar
%ARFLAGS             rs
%MK                  gmake
%USER_INC            %XIOS_INC %OASIS_INC %NCDF_INC
%USER_LIB            %XIOS_LIB %OASIS_LIB %NCDF_LIB

%CC                  cc
%CFLAGS              -O0
EOF
```

```bash
./makenemo -h
./makenemo -m X64_IRENEige -r WED025 -j 8
ls cfgs/WED025/BLD/bin/nemo.exe # to check that compilation worked
```

To create and compile a new configuration (e.g. "AMU", including ocean and sea-ice), do as follows:
```bash
export CONFEXE='AMU'
echo "$CONFEXE  OCE ICE" >> cfgs/ref_cfgs.txt
mkdir cfgs/$CONFEXE
echo " bld::tool::fppkeys key_xios key_si3" > cfgs/${CONFEXE}/cpp_${CONFEXE}.fcm
makenemo -r ${CONFEXE} -m X64_IRENEige -j 8
ls cfgs/${CONFEXE}/BLD/bin/nemo.exe
```
To modify some routines, copy them from ```cfgs/${CONFEXE}/WORK``` to ```cfgs/${CONFEXE}/MY_SRC```, modify them and recompile (the files in ```MY_SRC``` will be compiled instead of those in ```WORK```).

While we are here, let's also compile some useful NEMO tools:
```bash
cd tools
# tools to rebuild mpi domains into a single netcdf:
./maketools -m X64_IRENEige -n REBUILD_NEMO
ls -al REBUILD_NEMO/BLD/bin/rebuild_nemo.exe  # check
# tools to prepare the DOMAINcfg netcdf file:
./maketools -m X64_IRENEige -n DOMAINcfg
ls -al DOMAINcfg/BLD/bin/make_domain_cfg.exe  # check
# tools to prepare the WEIGHT netcdf files (for NEMO online interpolations):
./maketools -m X64_IRENEige -n WEIGHTS
ls -al WEIGHTS/BLD/bin/scrip.exe  # check
# tools to prepare NESTING tools (may be used for AGRIF):
./maketools -m X64_IRENEige -n NESTING
ls -al NESTING/BLD/bin/agrif_create_bathy.exe  # check
```


## 4. Create inputs for the new NEMO configuration

Choose a configuration name (typically <region><horizontal\_resolution>.L<vertical_resolution>) and create the input directory:
```bash
export CONFIG='AMUXL025.L75' # adapt
mkdir -pv ${SCRATCHDIR}/input
mkdir -pv ${SCRATCHDIR}/input/${CONFIG}
``` 


# 4.1. Create coordinate and bathymetry files

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

The following steps rely on a preprocessing namelist. You can either use an existing one or create a new one:
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
or if the dataset is on a stereographic grid (you may need to use 60Gb instead of 30 for BedMachine):
```bash
./submit.sh extract_bathy_special_stereo 03 30
```


# 4.2. Create the DOMAINcfg and mesh\_mask files

To make the following description qui general, we define ```$MY_NEMO``` as:
```bash
export MY_NEMO="${SCRATCHDIR}/models/nemo_v4_trunk" # adapt to the one you compiled
cd ${MY_NEMO}
```

Then, compile the NEMO tools called DOMAINcfg and REBUILD_NEMO (do not forget to re-load modules if necessary):
```bash
cd tools
./maketools -m X64_IRENEige -n DOMAINcfg
ls -al DOMAINcfg/BLD/bin/make_domain_cfg.exe
ls -al DOMAINcfg/BLD/bin/dom_doc.exe
./maketools -m X64_IRENEige -n REBUILD_NEMO
ls -al REBUILD_NEMO/BLD/bin/rebuild_nemo.exe
```

Then, create mesh_mask_${CONFIG}.nc and domain_cfg_${CONFIG}.nc as follows:
```bash
cd ${SCRATCHDIR}/input/nemo_${CONFIG}
mkdir DOMAINcfg
cd DOMAINcfg
ln -s -v ${MY_NEMO}/tools/DOMAINcfg/BLD/bin/make_domain_cfg.exe
ln -s -v ${MY_NEMO}/tools/DOMAINcfg/BLD/bin/dom_doc.exe
cp -p ${MY_NEMO}/tools/DOMAINcfg/namelist_ref .
cp -p ${MY_NEMO}/tools/DOMAINcfg/namelist_cfg .
vi namelist_ref # Look at default values for all namelist parameters (keep unchanged!).
vi namelist_cfg # Set values that should differ from namelist_ref.
                # Fill &namdom : very important to keep ln_read_cfg = .false. and set nn_msh = 1
                #                fill cn_fcoord, cn_topo, cn_fisfd, cn_bath, cn_visfd, ... (see variables in namelist_ref)
                #                and put same value as BDY conditions for ppsur, ppa0, ppa1, ppkth, ...
                # Fill &namcfg : set domain size in 3 dimensions, config name, etc.
                # Fill entire &namzgr_isf section when using ice shelves (see namelist_ref).
                # Set nn_msh=1 in &namdom section to obtain a mesh_mask file
                # and put the seeds in the oceanic part of the domain (namzgr_isf and namclo)

cat <<EOF > run.sh
#!/bin/bash
#MSUB -r run_DOMAINcfg
#MSUB -o run.o%j
#MSUB -e run.e%j
#MSUB -n 24
#MSUB -x
#MSUB -T 600 
#MSUB -A gen6035
#MSUB -q rome
#MSUB -m work,scratch
ulimit -s
mpirun -np 24 ./make_domain_cfg.exe
EOF

chmod +x run.sh
sbatch ./run.sh # then wait for the job completion
ls -al mesh_mask_00??.nc
ls -al domain_cfg_00??.nc
ln -s -v ${MY_NEMO}/tools/REBUILD_NEMO/BLD/bin/rebuild_nemo.exe
ln -s -v ${MY_NEMO}/tools/REBUILD_NEMO/rebuild_nemo
# change the 24 in the two lines below if you did not use 24 tasks in run.sh :
./rebuild_nemo -d 1 -x 200 -y 200 -z 1 -t 1 mesh_mask 24 
./rebuild_nemo -d 1 -x 200 -y 200 -z 1 -t 1 domain_cfg 24 
./dom_doc.exe -n namelist_cfg -d domain_cfg.nc # to save namelist in domain_cfg.nc
mv mesh_mask.nc ../mesh_mask_${CONFIG}.nc
mv domain_cfg.nc ../domain_cfg_${CONFIG}.nc
rm -f mesh_mask_00??.nc domain_cfg_00??.nc nam_rebuild_?????
```
Note that the namelist\_cfg can be re-extracted from domain\_cfg\_${CONFIG}.nc as follows:
```bash
ln -s -v ${MY_NEMO}/tools/REBUILD_NEMO/xtrac_namelist.bash
./xtrac_namelist.bash domain_cfg_${CONFIG}.nc restored_namelist_cfg
```


# 4.3. Create initial state file

To exctract the CHILD initial state (temperature and salinity) from the PARENT simulation, fill the ```&init``` section of the namelist:
```bash
./submit.sh extract_istate_TS 01 16
ls -al ../nemo_${CONFIG}/istate_TS_${CONFIG}.nc  # check after completion of extract_istate_TS
```

If you also need an initial state for sea ice (concentration, ice thickness, snow thickness):
```bash
./submit.sh extract_istate_sea_ice 01 8
ls -al ../nemo_${CONFIG}/istate_sea_ice_${CONFIG}.nc  # check after completion of extract_istate_sea_ice
```

You can control smoothing and nearest-neighbour interpolation through the namelist options.


# 4.4. Create files for lateral boundary conditions

First, create the file containing the coordinates of boundaries:
```bash
vi namelist_pre # check domain (x,y) size in ../nemo_${CONFIG}/mesh_mask_${CONFIG}.nc
                # and fill &bdy, &bdy_east, &bdy_west, &bdy_north, &bdy_south (mind the fortran indexing).
./submit.sh build_coordinates_bdy 01
ls ../nemo_${CONFIG}/coordinates_bdy_${CONFIG}.nc
```
Note that you can define several segments for each boundary (staircases, see, e.g., namelist\_WED12).

Then put data on these points to create the boundary conditions:
```bash
vi namelist_pre # fill &bdy_data section 
./submit.sh extract_bdy_gridT 04 15 # adapt duration and memory requirements (typ. 5 min./yr for AMUXL025.L75 from ORCA025)
./submit.sh extract_bdy_gridU 05 15 # adapt duration and memory requirements (typ. 6 min./yr for AMUXL025.L75 from ORCA025)
./submit.sh extract_bdy_gridV 05 15 # adapt duration and memory requirements (typ. 7 min./yr for AMUXL025.L75 from ORCA025)
./submit.sh extract_bdy_icemod 01 8
./submit.sh extract_bdy_ssh 01 8
ls -lrt ../nemo_${CONFIG}/BDY
squeue
# once all these jobs have completed:
vi concatenate_yearly_BDY.sh  # adapt CONFIG, BDY_DIR, YEARi, YEARf
./concatenate_yearly_BDY.sh # to get yearly files
ls ../nemo_${CONFIG}/BDY
```

If you want to prescribe barotropic tides at the boundaries:
```bash
vi namelist_pre # fill &bdy_tide section
./submit.sh extract_bdy_tides 01 8
ls ../nemo_${CONFIG}/BDY
```


# 4.5. Create files for runoff, SSS restoring, chlorophyll, tidal mixing

If you want to use sea surface salinity restoring:
```bash
vi namelist_pre # fill &sss_resto section
./submit.sh extract_SSS_restoring 03 15 # adapt duration and memory requirements
ls -lrt ../nemo_${CONFIG}/SSS
squeue
# once the job has completed:
vi concatenate_yearly_SSS.sh # adapt CONFIG, SSS_DIR, YEARi, YEARf
./concatenate_yearly_SSS.sh
ls ../nemo_${CONFIG}/SSS
```

If you want to prescribe runoff (from rivers and/or iceberg):
```bash
vi namelist_pre # fill &runoff section
# if you only have liquid runoff:
./submit.sh extract_runoff 03 8 # adapt duration (and memory) requirements
# if instead, you have iceberg runoff (possibly also liquid runoff):
./submit.sh extract_runoff_icb 03 8 # adapt duration (and memory) requirements
#
ls -lrt ../nemo_${CONFIG}/RNF
squeue
# once the job has completed:
vi concatenate_yearly_runoff.sh # adapt CONFIG, RNF_DIR, YEARi, YEARf
./concatenate_yearly_runoff.sh
ls ../nemo_${CONFIG}/RNF
```

If you need a chlorophyll file (for solar absorption), you can either extract it from the parent grid or from a regular lon-lat grid:
```bash
vi namelist_pre # fill &chloro
# to extract from parent grid:
./submit.sh extract_chloro 01 8
# to extract from a regular lon-lat grid:
./submit.sh extract_chloro_from_lonlat 01 8
ls ../nemo_${CONFIG}/chlorophyll_${CONFIG}.nc
```

If you use the internal wave mixing parameterisation (De Lavergne et al.), you can extract it from the parent grid as follows:
```bash
vi namelist_pre # fill &zdfiwm
./submit.sh extract_zdfiwm 01 8
ls ../nemo_${CONFIG}/zdfiwm_${CONFIG}.nc
```


# 4.6. Create weights for on-the-fly interpolation of atmospheric forcing

First compile the WEIGHTS tool:
```bash
cd ${MY_NEMO}/tools
./maketools -m X64_IRENEige -n WEIGHTS
ls -al WEIGHTS/BLD/bin/*.exe
cd ${SCRATCHDIR}/input/nemo_${CONFIG}
mkdir WEIGHTS
cd WEIGHTS
for file in ${MY_NEMO}/tools/WEIGHTS/BLD/bin/*.exe ; do ln -s -v $file ; done
```

Then, prepare the namelist for the bilinear interpolation:
```bash
export REANALYSIS="JRA55" # or any other one, e.g. ERA5
cp -p ${MY_NEMO}/tools/WEIGHTS/namelist_bilin namelist_bilin_${REANALYSIS}_${CONFIG}
# link one of your forcing files, e.g.:
ln -s -v $[SCRATCHDIR}/FORCING_SETS/${REANALYSIS}/drowned_tas_${REANALYSIS}_y2005.nc
ncdump -h t2m_${REANALYSIS}_drowned_y2010.nc # check longitude & latitude names
vi namelist_bilin_${REANALYSIS}_${CONFIG} # fill the 3 sections as in the example below
#&grid_inputs
#    input_file = "drowned_tas_${REANALYSIS}_y2005.nc"
#    nemo_file = "../coordinates_${CONFIG}.nc"
#    datagrid_file = "remap_${REANALYSIS}_grid.nc"
#    nemogrid_file = "remap_${CONFIG}_grid.nc"
#    method = 'regular'
#    input_lon = 'lon'
#    input_lat = 'lat'
#    nemo_lon = 'glamt'
#    nemo_lat = 'gphit'
#    nemo_mask = 'none'
#    nemo_mask_value = 10
#    input_mask = 'none'
#    input_mask_value = 10
#/
#&remap_inputs
#    num_maps = 1
#    grid1_file = "remap_${REANALYSIS}_grid.nc"
#    grid2_file = "remap_${CONFIG}_grid.nc"
#    interp_file1 = "${REANALYSIS}_${CONFIG}_bilin.nc"
#    interp_file2 = "${CONFIG}_${REANALYSIS}_bilin.nc"
#    map1_name = "${REANALYSIS} to ${CONFIG} bilin Mapping"
#    map2_name = "${CONFIG} to ${REANALYSIS} bilin Mapping"
#    map_method = 'bilinear'
#    normalize_opt = 'frac'
#    output_opt = 'scrip'
#    restrict_type = 'latitude'
#    num_srch_bins = 90
#    luse_grid1_area = .false.
#    luse_grid2_area = .false.
#/
#&shape_inputs
#    interp_file = "${REANALYSIS}_${CONFIG}_bilin.nc"
#    output_file = "weights_bilin_${REANALYSIS}_${CONFIG}.nc"
#    ew_wrap     = 0
#/
```

Then:
```bash
cat <<EOF > run_bilin.sh
#!/bin/bash
#SBATCH -C BDW28
#SBATCH --ntasks=1
#SBATCH --mem=55000
#SBATCH --threads-per-core=1
#SBATCH -J run_WEIGHT
#SBATCH -e run_WEIGHT.e%j
#SBATCH -o run_WEIGHT.o%j
#SBATCH --time=00:09:00
ulimit -s unlimited
./scripgrid.exe namelist_bilin_${REANALYSIS}_${CONFIG}
./scrip.exe namelist_bilin_${REANALYSIS}_${CONFIG}
./scripshape.exe namelist_bilin_${REANALYSIS}_${CONFIG}
EOF

chmod +x run_bilin.sh
sbatch run_bilin.sh
# when job has completed:
ls -al weights_bilin_${REANALYSIS}_${CONFIG}.nc
```

Then you can procede similarly with namelist\_bicub instead of namelist\_bilin:
```bash
sed -e "s/bilin/bicub/g ; s/bicubear/bicubic/g" namelist_bilin_${REANALYSIS}_${CONFIG} > namelist_bicub_${REANALYSIS}_${CONFIG}
sed -e "s/bilin/bicub/g" run_bilin.sh > run_bicub.sh
chmod +x run_bicub.sh
sbatch run_bicub.sh
# when job has completed:
ls -al weights_bicub_${REANALYSIS}_${CONFIG}.nc
```

Then to prepare the next steps:
```bash
cd ..
ln -s -v WEIGHTS/weights_bilin_${REANALYSIS}_${CONFIG}.nc 
ln -s -v WEIGHTS/weights_bicub_${REANALYSIS}_${CONFIG}.nc 
```

## 5. Running NEMO

Note that examples of namelists and xml files are provided with NEMO and can be found here:
```bash
ls -al ${MY_NEMO}/cfgs/WED025/EXP00/*.xml
ls -al ${MY_NEMO}/cfgs/WED025/EXP00/namelist*
```
To run long jobs, you can use Nico's toolbox, which you can get as follows:

```bash
cd ~
# if you work with NEMO4:
git clone git@github.com:nicojourdain/run_nemo.git # if you use github with SSH key
git clone https://github.com/nicojourdain/run_nemo.git # otherwise
# or if you work with NEMO3.6:
git clone --depth 1 --branch r3.6 git@github.com:nicojourdain/run_nemo.git
```
Then, follow indications on [https://github.com/nicojourdain/run_nemo](https://github.com/nicojourdain/run_nemo).
