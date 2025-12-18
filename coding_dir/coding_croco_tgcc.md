---
layout: post
title: Preparing and running CROCO simulations on Irene-Rome (TGCC)
date: 04-12-2025
---

The official documentation on downloading and installing the CROCO code can be found [on the CROCO website](https://croco-ocean.gitlabpages.inria.fr/croco_doc/index.html)

If you are new to TGCC, see [this page](http://www-hpc.cea.fr/en/complexe/tgcc.htm) for information on how to get an account.

Some parts of the preprocessing are complicated to execute on Irene-Rome due to access restrictions, and they are therefore run on [the CLIMERI server spirit](https://climeri-france.fr/les-activites/acces-a-la-plateforme).

## 1. Module environment

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

This can typically be included in ~/.bashrc.

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

Then, for every new configuration:
```bash
cd ${SCRATCHDIR}/run_croco/Run_${CONFIG}
cp -p $WORKDIR/Run_croco_save/jobcomp .         # adapted for Irene-rome
cp -p $WORKDIR/Run_croco_save/myenv_mypath.sh . # adapted for Irene-rome
cp -rp $WORKDIR/Run_croco_save/MY_SRC .
vi MY_SRC/cppdefs.h # change configuration name # define SAIGON_LR
                    # undef  AGRIF
                    # undef  AGRIF_2WAY
                    # def or undef OBCs
```

## 4. Preprocessing

**On spirit**, get the datasets required for the preprocessing:
```bash
cd /scratchu/njourdain
wget https://data-croco.ifremer.fr/DATASETS/DATASETS_CROCOTOOLS.tar.gz
tar xzf DATASETS_CROCOTOOLS.tar.gz
rsync -av --chmod=Dg+s --chown=:gen6035  DATASETS_CROCOTOOLS jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/.
# new topography:
wget 
rsync -av --chmod=Dg+s --chown=:gen6035 Topo_Mekong_Saigon_merged_3sec_2025_v0.nc jourdain@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/gen6035/jourdain/DATASETS_CROCOTOOLS/Topo/.
# new tide data:
wget
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
cd ${SCRATCHDIR}/run_croco/Run_Saigon_01
vi crocotools_param.m # adapt My_ERA5_dir
vi ${WORKDIR}/models/croco_tools-v2.1.0/Aforc_ERA5/era5_crocotools_param.py #adapt everything 
cd ${WORKDIR}/models/croco_tools-v2.1.0/Aforc_ERA5
python ERA5_convert.py
ls /ccc/scratch/cont003/gen6035/jourdain/run_croco/Run_Saigon_01/DATA/ERA5_Saigon_LR/
```

### 4c- Create the lateral boundary conditions

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

## 5. Run the regional model


