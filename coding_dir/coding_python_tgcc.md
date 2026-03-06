---
layout: post
title: Using python on Irene-Rome (TGCC)
date: 01-03-2026
---

It is currently not possible to use conda to install modules. You could use the provided python modules (see ``` module avail ```), but without any possibility to add python modules. Here is described a way to build your conda environment on another linux machine and import it onn TGCC.

# Pack python environment from another machine (here dahu)

Log onto dahu, e.g.:
```bash
ssh -X wmunk@dahu
```

Find the install script on [the miniconda page](https://docs.conda.io/en/latest/miniconda.html) and download it, e.g.:
```bash
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh # accept to initialize Miniconda3
. ~/.bashrc
```

Then create a python environment (here "py313") with all the potentially useful modules, e.g.:
```bash
conda create --name py313  python=3.13
conda activate py313
conda install numpy ipython netcdf4 xarray matplotlib scipy pandas pillow
conda install dask 
conda install zarr
conda install oce utide # for tidal analysis
conda install esmf # for interpolation
conda install fftw # fast fourrier transform
pip install watermark # load with '%load_ext watermark' # print versions with '%watermark -v -iv'
conda install cartopy
conda install -c conda-forge cmocean # nice colors for ocean plots
conda install -c conda-forge papermill # to run notebooks like scripts
conda install -c conda-forge gsw # Gibbs sea water equation of state
conda install -c conda-forge xmovie # to create movies from xarray objects
conda install pytorch torchvision -c pytorch # Machine Learning
pip install tensorflow # Machine Learning
conda install -c conda-forge vtk # For Elmer/Ice's outputs
pip install conda-pack
conda update -n py313 --force-reinstall --update-all # may be needed to avoid errors due to pip overwritting conda stuff
```

Then, check that you have everythng and pack:
```bash
conda list
conda pack -n py313 -o condapack_dahu_py37.tar.gz --ignore-missing-files
```

Then, copy condapack_dahu_py313.tar.gz and the miniconda installation bash script onto Iren-Rome (in the WORKDIR):
```bash
scp -p condapack_dahu_py313.tar.gz <MYLOGIN>@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/<MYPROJECT>/<MYLOGIN>
scp -p Miniconda3-latest-Linux-x86_64.sh <MYLOGIN>@irene-amd-fr.ccc.cea.fr:/ccc/work/cont003/<MYPROJECT>/<MYLOGIN>
```


# Unpack the conda environment onn Irene-Rome (TGCC):

Then, log onto Irene-Rome and unpack:
```bash
ssh ${MYLOGIN}@irene-amd-fr.ccc.cea.fr
module switch dfldatadir/<MYPROJECT>
cd /ccc/work/cont003/<MYPROJECT>/<MYLOGIN> # where the 2 aforementionned files have been copied
bash Miniconda3-latest-Linux-x86_64.sh # choose to install in /ccc/work/cont003/<MYPROJECT>/<MYLOGIN>/miniconda3
                                       # accept that the installer initializes Miniconda3 to get the needed lines in ~/.bashrc
source ~/.bashrc # to activate conda initialization
mkdir py313
tar -xzf condapack_dahu_py313.tar.gz -C py313
source py313/bin/activate
chmod -R a+wrx py313 # to avoid error messages on permissions
conda-unpack
ipython --version # for example, to check that it works
which python # check this gives the correct path
```

Then, each time you want to use the py313 environment, just do (or put this in your .bashrc):
```bash
source /ccc/work/cont003/<MYPROJECT>/<MYLOGIN>/py313/bin/activate
```

