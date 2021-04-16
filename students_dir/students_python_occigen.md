---
layout: post
title: Working on occigen
date: 04-01-2021
---

# Create an account (do it once)

TBC

# Preliminary steps for Windows10 users (last updated May 2020)

If you use Linux of Mac OSX, skip this section. For Windows10, you will need to activate OpenSSH ("Settings", then "Apps and features", then "Manage optional features", then "Add a feature" and look for "OpenSSH Client", then install it). Then, install Ubuntu20 from the Windows Store ([see this page](https://www.zebulon.fr/astuces/divers/executer-linux-sous-windows-10.html)). Then, launch the Ubuntu app in Windows. 

You can enable copy/paste through Ctrl+Maj+C/v somewhere in the menu.

Then, to enable remote display, do:
```bash
echo "export DISPLAY=localhost:0.0" >> ~/.bashrc
source ~/.bashrc
sudo apt-get update
sudo apt-get install xterm
```

# SSH connection

From the machine that has been declared to CINES:
```bash
export MYLOGIN='munkw'
ssh -Y ${MYLOGIN}@occigen.cines.fr
```

On mac OSX, if you want your SSH connection to remain active for a long time, you can do this:
```bash
cat << EOF >> ~/.ssh/config

Host *
    ServerAliveInterval 60
    TCPKeepAlive yes
    ForwardX11Trusted yes
EOF
```

# occigen's module environment

To activate the module environment:
```bash
cat << EOF >> ~/.bashrc

# modules:
export MODULEPATH=$MODULEPATH:/opt/software/modulefiles
export MODULEPATH=$MODULEPATH:$HOME/modules
module purge
module load ncview # for example
EOF
source ~/.bashrc
```

Loading the firefox module will be needed to run jupyter notebook.

Add any other modules you need in ~/.bashrc. Check available and loaded modules with:
```bash
module avail
module list
```

# Use the conda environment on occigen (from a provided module):

This is one way to use python and install the modules you need on occigen (the standard way to use anaconda is not permitted). Another method is described in the following section. 

Do not load any of the existing python modules, but instead, follow this:

```bash
module load /opt/software/alfred/spack-dev/modules/tools/linux-rhel7-x86_64/miniconda3/4.7.12.1-gcc-4.8.5
mkdir ${SCRATCHDIR}/MY_CONDA
conda install ipython xarray netcdf4 -p ${SCRATCHDIR}/MY_CONDA
conda install scipy dask pyproj -p ${SCRATCHDIR}/MY_CONDA
conda install -c conda-forge gsw -p ${SCRATCHDIR}/MY_CONDA
```

Then, add the following lines to your ~/.bashrc:
```bash
export PATH="${SCRATCHDIR}/MY_CONDA/bin:$PATH"
```

Then re-source the .bashrc and check that the python path is correct:
```bash
. ~/.bashrc
which python
```

# Pack a complete conda environment from another linux system:

This alternative method consists of copying the conda environment from another linux system, for example, GRICAD's luke. See [this page](https://nicojourdain.github.io/students_dir/students_python_gricad/) to install a working conda environment on luke. Then, on luke:
```bash
conda activate py38 # if you have defined an environment, here 'py38'
conda list # check that you have all you need
pip install conda-pack
conda update -n py38 --force-reinstall --update-all # may be needed to avoid errors due to pip overwritting conda stuff
conda pack -n py38 -o condapack_luke_py38.tar.gz
scp -p condapack_luke_py38.tar.gz ${MYLOGIN}@occigen.cines.fr:/scratch/xxxx/${MYLOGIN} # directly to occigen's $SCRATCHDIR or through a third machine if no permission
```

You will also need to install anaconda/miniconda on occigen, which you can do by using the same bash script that you used to install python on luke, e.g. from luke:
```bash
scp -p Miniconda3-latest-Linux-x86_64.sh ${MYLOGIN}@occigen.cines.fr:/scratch/xxxx/${MYLOGIN} # directly to occigen's $SCRATCHDIR or through a third machine if no permission
```

Then, log onto occigen and unpack:
```bash
cd /scratch/xxxx/${MYLOGIN} # where the 2 aforementionned files have been copied
bash Miniconda3-latest-Linux-x86_64.sh # or whatever anaconda/miniconda installation file you got
source ~/.bashrc # to activate conda initialization
mkdir py38
tar -xzf condapack_luke_py38.tar.gz -C py38
source py38/bin/activate
chmod -R a+wrx py38 # to avoid error messages on permissions
conda-unpack
ipython --version # for example, to check that it works
which python # check this gives the correct path
```

To make it work for every future session (don't do it if you use jupyter notebook through the vizualization nodes, see below):
```bash
cat << EOF >> ~/.bashrc

#unpacked conda environment from luke:
source /scratch/xxxx/${MYLOGIN}/py38/bin/activate
EOF
```

# Run Jupyter Notebook directly on occigen (simple but slow)

Enable mozilla on occigen:
```bash
echo "module load firefox" >> ~/.bashrc
source ~/.bashrc
```

To enable running notebooks on the cluster (to do only once):
```bash
jupyter notebook --generate-config
echo "c.NotebookApp.open_browser = True" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.browser = 'firefox'" >> ~/.jupyter/jupyter_notebook_config.py
exit
```

At this stage, you should be able to run ``` jupyter notebook```on occigen and work in the mozilla X-window.

# Run Jupyter Notebook on the vizualization machine (DOES NOT SEEM TO WORK...)

The following was inspired by [this CINES page](https://www.cines.fr/calcul/materiels/visualisation/sessions-interactives-vnc/) and [this tuto by the MEOM team](https://github.com/meom-group/tutos/blob/master/occigen/jupyter-notebook-on-occigen.md).

If you have an occigen account, you should be able to access the vizualization machine:
```bash
ssh ${MYLOGIN}@visu.cines.fr
vizalloc -m vnc -t 60 # here for 60 minutes (max allowed=360)
```
Note that you should not source the path of you unpacked conda envoronment in your .bashrc, as it could prevent vizalloc to work properly.

It should show something like this if a ressource is available:
```bash
Visualisation JOB : 11435727 submitted, waiting for resources...
Service started on server: visu1.cines.fr:1
Begintime:2020-12-27T15:50:25
End  time:2020-12-27T16:50:25
```

Check the status with this command:
```bash
vizqueue
```

Note the server on which the service started (```visu1.cines.fr``` in the previous example), and open a 2nd terminal to do:
```bash
ssh ${MYLOGIN}@visuX.cines.fr  # adapt X
```

```bash
cat << EOF >> ~/.bashrc

alias jup="export PATH="/scratch/xxxx/${MYLOGIN}/py38/bin:$PATH"; jupyter-notebook"
alias ipyt="export PATH="/scratch/xxxx/${MYLOGIN}/py38/bin:$PATH"; ipython"
alias pyt="export PATH="/scratch/xxxx/${MYLOGIN}/py38/bin:$PATH"; python"
EOF
```

To set-up jupyter on the first use, do this or edit the file manually:
```bash
jupyter notebook --generate-config
echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py
exit
```
NB: check ~/.jupyter/jupyter_notebook_config.py and comment lines that were previously uncommented or added (e.g. if you ran jupyter directly on occigen). Or just launch ``` jupyter notebook --no-browser```.

On you local machine, download and install [TurboVNC](https://sourceforge.net/projects/turbovnc/).

Launch TurboVNC and indicate 'localhost:5901' as VNC server.

######

In a first terminal, do (here assuming that you belong to group ice\_speed and have access to node luke62):
```bash
ssh -X luke
oarsub -I -l nodes=1/core=1,walltime=00:29:00 --project ice_speed -p "network_address='luke62'"
conda activate py37
jupyter notebook
```
It should give you a web address http://127.0.0.1:...

NB: the oarsub command allocates a number of cores for a certain amount of time. If you work on large files, you will need to increase the core number in the oarsub command (e.g. ```core=4```). You can increase the walltime to e.g. 24:00:00, although you may have to wait some time in the queue before obtaining access.

In a second terminal:
```bash
ssh -fNL 8888:luke62:8888 luke
```
NB: if port 8888 is already being used, the ```jupyter notebook```command will give you another port number (e.g. 8889).

Then, in a web browser (e.g. Firefox, Chrome...), copy/paste the aforementioned address starting as http://127.0.0.1. This should open Jupyter notebook.

Once you are done, you need to free the port (here 8888):
```bash
lsof -ti:8888   # indicates a number
kill -9 <number>
```

