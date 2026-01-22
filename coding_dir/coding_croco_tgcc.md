---
layout: post
title: Preparing and running CROCO simulations on Irene-Rome (TGCC)
date: 04-12-2025
---

The official documentation on downloading and installing the CROCO code can be found [on the CROCO website](https://croco-ocean.gitlabpages.inria.fr/croco_doc/index.html)

If you are new to TGCC, see [this page](http://www-hpc.cea.fr/en/complexe/tgcc.htm) for information on how to get an account.

Some parts of the preprocessing are complicated to execute on Irene-Rome due to access restrictions, and they are therefore run on [the CLIMERI server spirit](https://climeri-france.fr/les-activites/acces-a-la-plateforme).

## 1. Module and Python environments

To access to all the project directories of your group, you need to do this (replace gen6035 by your project ID):
```bash
export PROJECT='gen6035' ## adapt project
module switch dfldatadir/$PROJECT
TMP="${PROJECT^^}_CCCSCRATCHDIR";     export SCRATCHDIR=${!TMP}
TMP="${PROJECT^^}_CCCWORKDIR";        export WORKDIR=${!TMP}
TMP="${PROJECT^^}_CCCSTOREDIR";       export STOREDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCHOME";       export SHAREDHOME=${!TMP}
TMP="${PROJECT^^}_ALL_CCCSCRATCHDIR"; export SHAREDSCRATCHDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCWORKDIR";    export SHAREDWORKDIR=${!TMP}
TMP="${PROJECT^^}_ALL_CCCSTOREDIR";   export SHAREDSTOREDIR=${!TMP}
```

To install a good python environment on TGCC, see [this page](https://nicojourdain.github.io/coding_dir/coding_python_tgcc/), then define the alias to activate it:
```bash
alias py='source /ccc/workflash/cont003/gen6035/jourdain/py37/bin/activate'
```

All the commands above can typically be included in ~/.bashrc.

## 2. Get the sources

If not already done, create the a models repository on Irene-rome:
```bash
mkdir -pv ${WORKDIR}/models
``` 

Then, **on spirit:**
```bash
git clone --branch v2.1.0 https://gitlab.inria.fr/croco-ocean/croco.git croco-v2.1.0
git clone --branch v2.1.0 https://gitlab.inria.fr/croco-ocean/croco_tools.git croco_tools-v2.1.0
git clone https://gitlab.inria.fr/croco-ocean/croco_pytools.git croco_pytools-v1.0.3
# change paths and project name in the following lines:
rsync -av --chmod=Dg+s --chown=:gen6035 croco-v2.1.0 jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/models/.
rsync -av --chmod=Dg+s --chown=:gen6035 croco_tools-v2.1.0 jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/models/.
rsync -av --chmod=Dg+s --chown=:gen6035 croco_pytools-v1.0.3 jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/models/.
```

## 3. Prepare the running directory for a new configuration

Define the name of your new configuration:
```bash
export CONFIG='Saigon_02'
mkdir -pv ${SCRATCHDIR}/run_croco  # where the simulations will be run
cd ${WORKDIR}/models/croco-v2.1.0
vi create_config.bash # change to MY_CONFIG_NAME=Run_${CONFIG}
./create_config.bash
```

Then, if this is the first time you create a configuration on Irene-rome, download [Run_croco_save.tar]({{site.url}}coding_dir/Run_croco_save.tar) on your local computer and copy it to Irene-rome in the WORKDIR. Then:
```bash
cd $WORKDIR
ls -al Run_croco_save.tar
tar xvf Run_croco_save.tar
```

## 4. Preprocessing: preparing the grid and forcing data

**On spirit**, get the datasets required for the preprocessing:
```bash
cd /scratchu/njourdain
wget https://data-croco.ifremer.fr/DATASETS/DATASETS_CROCOTOOLS.tar.gz
tar xzf DATASETS_CROCOTOOLS.tar.gz
rsync -av --chmod=Dg+s --chown=:gen6035  DATASETS_CROCOTOOLS jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/.
# new topography to be downloaded on https://cloud.univ-grenoble-alpes.fr/s/aTgTskfCaFd3nHf
rsync -av --chmod=Dg+s --chown=:gen6035 Topo_Mekong_Saigon_merged_3sec_2025_v0.nc jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/DATASETS_CROCOTOOLS/Topo/.
# new tide data to be downloaded on https://cloud.univ-grenoble-alpes.fr/s/PBaq8xjTCAGXtFp
rsync -av --chmod=Dg+s --chown=:gen6035 TPXO9v5_Mekong.nc jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/DATASETS_CROCOTOOLS/TPXO9/.
```

Then, on Irene-rome:
```bash
cd $SCRATCHDIR/run_croco/Run_${CONFIG}
cp -p $WORKDIR/Run_croco_save/crocotools_param.m
vi crocotools_param.m
```

### 4a- Create the grid(s)

To create the grid of the parent domain:
```bash
module load matlab
matlab -nodesktop
        >> start
        >> make_grid
                % Do you want to link the GSHHS data coastlines (+ borders and rivers) ? y
                % Do you want to use interactive grid maker ? y
                        # Updated values for Saigon_LR (2km resolution):
                        # xsize = 320
                        # ysize = 344
                        # Rotation = 20
                        # Longitu = 106.75
                        # Latitude = 10.2
                % Do you want to use editmask ? y
                        # turn the part of the Gulf of Thailand into land
        >> exit
ls -al CROCO_FILES/croco_grid.nc
```

To create the grid of the child domain(s), check [this page](https://croco-ocean.gitlabpages.inria.fr/croco_doc/tutos/tutos.12.nesting.html), then:
```bash
module load matlab
matlab -nodesktop
        >> start
        >> nestgui
```

### 4b- Create the atmospheric forcing

To extract the surface conditions from ERA5, start doing this **on spirit** :
```bash
cd /scratchu/njourdain/croco_tools-v2.1.0/Aforc_ERA5
vi era5_crocotools_param.py # adapt everything (for direct ERA5 download on some pre-defined lon-lat domain which can be larger than the grid)
submit_python.sh ERA5_request.py 24 32
cd ../DATA
ls -al ERA5_native_Vietnam # or other name
rsync -av --chmod=Dg+s --chown=:gen6035 ERA5_native_Vietnam jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/DATASETS_CROCOTOOLS/.
```
Then, on Irene-rome:
```bash
cd ${SCRATCHDIR}/run_croco/Run_${CONFIG}
vi crocotools_param.m # adapt My_ERA5_dir
cd ${WORKDIR}/models/croco_tools-v2.1.0/Aforc_ERA5
vi era5_crocotools_param.py #adapt everything (put month_start=1 and month_end=12) 
py
python ERA5_convert.py
ls ${SCRATCHDIR}/run_croco/Run_${CONFIG}/DATA/ERA5_Saigon_LR/
```

### 4c- Create the ocean lateral boundary conditions

To extract the lateral boundary consitions from GLORYS12, start doing this **on spirit** :
```bash
cd /scratchu/njourdain/croco_tools-v2.1.0/Oforc_OGCM
```

Then, at first use of this script, use the following command lines to put the right header in the existing bash script (**still on spirit**):
```bash
cat << EOF > tmp1.tmp
#SBATCH --ntasks=1
#SBATCH --mem=16000
#SBATCH --threads-per-core=1
#SBATCH -J glorys
#SBATCH -e glorys.e%j
#SBATCH -o glorys.o%j
#SBATCH --time=47:59:00
EOF
awk 'NR==2{while(getline line < "tmp1.tmp"){print line}}1' download_glorys_data.sh > tmp2.tmp
mv tmp2.tmp download_glorys_data.sh
rm -f tmp1.tmp
```

Then, **still on spirit**, adjust dates, area, frequency and run the script. Note that you need to create a login to access these data:
```bash
vi download_glorys_data.sh # edit dates, area, frequency, ...
sbatch ./download_glorys_data.sh
rsync -av --chmod=Dg+s --chown=:gen6035 raw_mercator_Y*M*.nc  XXXXXXX
```

Then, back to Irene-rome, create this script to format the GLORYS outputs:
```bash
cd ${WORKDIR}/models/croco_tools-v2.1.0/Oforc_OGCM
cat << EOF > convert_raw2crocotools.m
clear all;
close all;
crocotools_param;
GLORYS_dir = ['/ccc/work/cont003/gen6035/jourdain/DATASETS_CROCOTOOLS/GLORYS12_Vietnam/']
vars = {'zos' ...
        'uo' ...
        'vo' ...
        'thetao' ...
        'so'};
disp(['Making output data directory ',OGCM_dir])
eval(['!mkdir ',OGCM_dir, ' 2> /dev/null'])
%-----
for Y=Ymin:Ymax
    if Y==Ymin
        mo_min=Mmin;
    else
        mo_min=1;
    end
    if Y==Ymax
        mo_max=Mmax;
    else
        mo_max=12;
    end
    for M=mo_min:mo_max
        thedatemonth=['Y',num2str(Y),'M',num2str(M)];
        time1=datenum(Y,M,01);
        time2=datenum(Y,M+1,01) - 1;
        time=cat(2,time1,time2);
        raw_mercator_name=[GLORYS_dir,'raw_',OGCM_prefix,thedatemonth,'.nc'];
        disp(['Processing ',raw_mercator_name])
        if mercator_type==1
            write_mercator(OGCM_dir,OGCM_prefix,raw_mercator_name, ...
                           mercator_type,vars,time,thedatemonth,Yorig); % write data
        end                
    end
end
EOF
```

```bash
cd ${SCRATCHDIR}/run_croco/Run_${CONFIG}
vi crocotools_param.m  # OGCM = 'mercator';
vi ${WORKDIR}/models/croco_tools-v2.1.0/Oforc_OGCM/make_OGCM_mercator.m  
module load matlab
matlab -nodesktop
        >> start
        >> convert_raw2crocotools
        >> make_OGCM_mercator
# check mercator files in CROCO format (generated by convert_raw2crocotools.m):
ls -al ${SCRATCHDIR}/run_croco/Run_${CONFIG}/DATA/mercator_Saigon_LR/.
# check initial file(s) (generated by make_OGCM_mercator.m):
ls -al ${SCRATCHDIR}/run_croco/Run_${CONFIG}/CROCO_FILES/croco_ini_mercator_*.nc
# check bdy files (generated by make_OGCM_mercator.m):
ls -al ${SCRATCHDIR}/run_croco/Run_${CONFIG}/CROCO_FILES/croco_bry_mercator_*.nc
```

### 4d- Create the tides lateral boundary conditions

```bash
cd ${SCRATCHDIR}/run_croco/Run_${CONFIG}
vi crocotools_param.m  # check that tidename and salname point to the right dataset
vi ${WORKDIR}/models/croco_tools-v2.1.0/Tides/make_tides
module load matlab
matlab -nodesktop
        >> start
        >> make_tides_interannual
# check that files have been generated:
ls -al CROCO_FILES/croco_frc_*.nc 
```

### 4e- Create boundary conditions for passive tracers (optional)

TBC

## 5. Compile and run the regional model

### 5a- Compilation

The compilation has to be redone for any change in the grid size or model options.

```bash
cd ${SCRATCHDIR}/run_croco/Run_${CONFIG}
cp -p $WORKDIR/Run_croco_save/jobcomp .         # adapted for Irene-rome
cp -p $WORKDIR/Run_croco_save/myenv_mypath.sh . # adapted for Irene-rome
cp -rp $WORKDIR/Run_croco_save/MY_SRC .
vi MY_SRC/cppdefs.h # Change configuration name # define SAIGON_LR
                    # under "if defined REGIONAL" :
                    # ----- define whether an AGRIF nest is used -----
                    # undef  AGRIF
                    # undef  AGRIF_2WAY
                    # ----- define whether tides and OBCs are used -----
                    # define TIDES
                    # define OBC_EAST
                    # define OBC_WEST
                    # undef  OBC_NORTH
                    # define OBC_SOUTH
                    # ----- passive tracers -----
                    # define PASSIVE_TRACER
                    # ----- define point river sources as mass fluxes -----
                    # undef PSOURCE
                    # define PSOURCE_MASS (check double S: MASS !!)
vi MY_SRC/param.h   # Change LLm0 and MMm0. They correspond to the number of interior points 
                    # (domain without boundaries). It means xi_rho -2 and eta_rho - 2, in e.g. :
                    #       #  elif defined SAIGON_LR
                    #             parameter (LLm0=172, MMm0=185,  N=10)
```    

Then, compile the code:
```bash
./jobcomp # should end with "CROCO is OK"
ls -al croco
```

### 5b- Running CROCO

**At first use** of run\_croco\_inter.bash, use the following command lines to put the right header in the existing bash script:
```bash
cp -p run_croco_inter.bash run_croco_inter.bash_save
cat << EOF > tmp1.tmp
#MSUB -r run_croco
#MSUB -o run_croco.o%j
#MSUB -e run_croco.e%j
#MSUB -n 8
#MSUB -x
#MSUB -T 86000 
#MSUB -A gen6035
#MSUB -q rome
#MSUB -m store,work,scratch
EOF
awk 'NR==2{while(getline line < "tmp1.tmp"){print line}}1' run_croco_inter.bash > tmp2.tmp
mv tmp2.tmp run_croco_inter.bash
rm -f tmp1.tmp
```

Then, adapt this script further:
```bash
vi run_croco_inter.bash  # RUNCMD="ccc_mprun ./"
                         # NBPROCS=54
                         # BULK_FILES=1
                         # FORCING_FILES=1
                         # BOUNDARY_FILES=1
                         # ATMOS_BULK=ERA5
                         # ATMOS_FRC=TIDETPXO
                         # OGCM=mercator
                         # DT=120
                         #
                         # Set the output frequency and averaged period (in nb of days): ND_AVG = 1 (for 1-day outputs).
                         # If you want sub-daily outputs, e.g. 20 outputs per day, replace ND_AVG with ND_AVG_H (in hours), then
                         # replace NUMAVG=$((ND_AVG * 86400 / DT )) with NUMAVG=$((ND_AVG_H * 3600 / DT ))
                         # (check that you have a finite number of outputs per day)
```

Then adapt this script:
```bash
vi croco_inter.in        # Put the number of runoff points in the "psource:" section 
                         #   with Nsrc the number of source points and
                         #   one line per source point with grid location, discharge (m3/s), temperature (degC) and salinity (psu)
                         #     Isrc and Jsrc are interior indices (in other words, python indexing convention on croco_grid.nc)
                         #     Dsrc not used if PSOURCE_MASS rather than PSOURCE is defined.
                         #
                         # Adapt dates on 2nd last line (nb of time step per day in ERA5, last year, last month)
                         #   and change last line to something like: 
                         #   /ccc/scratch/cont003/gen6035/jourdain/run_croco/Run_Saigon_02/DATA/ERA5_Saigon_LR/
```

Then launch the simulation:
```bash
source myenv_mypath.sh
ccc_msub ./run_croco_inter.bash
ccc_mpp -u `whoami`
```

Once completed, you can look at the outptuts:
```bash
ls -al croco_Y*M*.out          # CROCO's standard output
ncdump -h SCRATCH/croco_avg.nc # time-averaged (e.g. 3-day) gridded outputs
ncdump -h SCRATCH/croco_his.nc # instantaneous gridded output (after first time step?)
```

