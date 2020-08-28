---
layout: post
title: Working on the GRICAD infrastructure
date: 25-05-2020
---

# Create an account (do it once)

Register on [https://perseus.univ-grenoble-alpes.fr](https://perseus.univ-grenoble-alpes.fr) using your institutional email address. When your account is activated, you will receive an email.

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

# Check connections

```bash
export MYLOGIN='munkw'  ## replace munkw with your GRICAD login
ssh ${MYLOGIN}@access-rr-ciment.imag.fr
```

This will connect you on one of the gateways (either rotule or trinity), from which you should be able to connect to luke or dahu:
```bash
ssh luke
exit
```

# Set up an SSH tunel to directly connect to luke or dahu (do it once)

See full documentation [here](https://gricad-doc.univ-grenoble-alpes.fr/hpc/connexion/).

Do this on your computer (provide a relatively complex pass phrase):
```bash
ssh-keygen
export MYLOGIN='munkw'  ## replace munkw your GRICAD login
cat ~/.ssh/id_rsa.pub | ssh ${MYLOGIN}@access-ciment.imag.fr 'cat >> .ssh/authorized_keys'
cat ~/.ssh/id_rsa.pub | ssh ${MYLOGIN}@access-ciment.ujf-grenoble.fr 'cat >> .ssh/authorized_keys'
```

If you want to enter the pass phrase only once per session on your computer:
```bash
cat << EOF >> ~/.bashrc

if [ $? -eq 2 ]
then
  echo launch ssh-agent
  eval $(ssh-agent)
  ssh-add
fi
EOF
source ~/.bashrc
```

Now, to set up a tunel connection:
```bash
cat << EOF >> ~/.ssh/config
Host luke*
  User ${MYLOGIN}
  ProxyCommand ssh -X ${MYLOGIN}@access-rr-ciment.imag.fr exec netcat -w 2- %h %p
  GatewayPorts yes

Host dahu*
  User ${MYLOGIN}
  ProxyCommand ssh -X ${MYLOGIN}@access-rr-ciment.imag.fr exec netcat -w 2- %h %p
  GatewayPorts yes

Host *
  ServerAliveInterval 60
  TCPKeepAlive yes
  ForwardX11Trusted yes
EOF
```

You should now be able to connect directly from your computer to luke or dahu, entering your pass phrase for the first connection but no password:
```bash
ssh -X luke
```

NB: For Windows10 users, it is possible that permissions are not set correctly by default, so you may need to change them once .ssh/config is created:
```bash
chmod ugo-rwx ~/.ssh/config
chmod u+rw ~/.ssh/config
```

# Prepare a workable environment (do it once)

To activatre the module environment on luke or dahu:
```bash
cat << EOF >> ~/.bashrc

# to access module commands : 
source /applis/ciment/v2/env.bash
EOF
source ~/.bashrc
```

To check that it works:
```bash
module avail
module load nco
which ncks
```

You can also define some aliases:
```bash
cat << EOF >> ~/.bashrc

# Aliases:
alias ll='ls -l'
alias lr='ls -lrt'
alias h='history'
alias whereami='echo `whoami`@luke:`pwd`'
alias qs='oarstat -u `whoami` --format 2'
alias bet='cd /bettik/`whoami`'
alias gfortran='/usr/bin/gfortran -ffixed-line-length-none -ffree-line-length-none'
EOF
source ~/.bashrc
```

# Set up a conda environment (do it once)

```bash
ssh -X luke

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh
. ~/.bashrc
conda info
conda create --name py37  python=3.7
conda activate py37
conda install numpy ipython netcdf4 xarray matplotlib scipy pandas pillow
```

Other possibly useful libraries include:
```bash
conda install dask 
conda install zarr
pip install watermark # load with '%load_ext watermark' # print versions with '%watermark -v -iv'
conda install cartopy
conda install -c conda-forge cmocean # nice colors for ocean plots
```

If you use Jupyter (inspired by the [MEOM page](https://github.com/meom-group/tutos/blob/master/gricad/jupyter-notebooks-on-gricad.md):
```bash
conda install jupyter jupyterlab numba ipykernel nodejs
conda install -c conda-forge papermill # to run notebooks like scripts
python -m ipykernel install --user --name py37 --display-name py37
```

For dask dashboard in jupyter lab:
```bash
pip install dask_labextension
jupyter labextension install dask-labextension
jupyter serverextension enable --py --sys-prefix dask_labextension
```

To enable running notebooks on the cluster:
```bash
jupyter notebook --generate-config
echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py
exit
```

# Run Jupyter Notebook in conda environment (do every time)

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

