---
layout: post
title: How to install hdf5/netcdf libraries?
date: 01-01-2015
---

This page is to help installing Netcdf, Hdf, and Fortran-netcdf libraries on your platform if they are not already installed. 

For NEMO users: these libraries are often installed with standard options that do not fit with the needs of NEMO or the IO server, so you probably need to recompile them even if they are already available through modules (e.g. on raijin). 

Here is the way to do it on raijin, but it will be very similar for other platforms (e.g. you can probably change the -xAVX option to another one on other platforms):

```shell

export USER=`whoami`
echo "PROJECT=$PROJECT"  ## check that it is ok, if not, define it
#
PREFIX=/short/${PROJECT}/${USER}/util/
mkdir $PREFIX
cd $PREFIX
#
export CFLAGS='-O3 -xAVX -fp-model precise'
export PPFLAGS='-DpgiFortran -O3 -xAVX -fp-model precise'
export XXFLAGS='-O3 -xAVX -fp-model precise'

######################################################
# HDF5: get the most recent, or previous release in  #
# http://www.hdfgroup.org/ftp/HDF5/prev-releases/    #
######################################################
wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.11.tar.gz
tar xvfz hdf5-1.8.11.tar.gz
cd hdf5-1.8.11
#
export CC=icc 
export CXX=icc
export FC=ifort
export H5_CFLAGS='-std=c99 -O3 -xAVX -fp-model precise'
#
./configure --disable-shared --enable-production --enable-parallel -prefix=$PREFIX
#
make  
make install
cd ..
rm -rf hdf5-1.8.11


#################################################
#  NETCDF                                       #
#################################################
wget http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.3.0.tar.gz
tar xvfz netcdf-4.3.0.tar.gz
cd netcdf-4.3.0
#
export CPPFLAGS="-I$PREFIX/include -DpgiFortran"
export LDFLAGS=-L$PREFIX/lib
export LIBS=-lmpi 
export CC=icc 
export FC=ifort 
export F77=ifort 
./configure --prefix=$PREFIX --disable-shared --enable-parallel-tests
#
make
make install
cd ..
rm -rf netcdf-4.3.0
#

#################################################
#  NETCDF-fortran                               #
#################################################
# NB: possible to do it through the web browser if it does not work with wget:
wget http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz
tar xvfz netcdf-fortran-4.2.tar.gz
cd netcdf-fortran-4.2
#
export CPPFLAGS="-I$PREFIX/include -DpgiFortran"
export LDFLAGS="-L$PREFIX/lib -lnetcdf -lhdf5_hl -lhdf5 -lz -lcurl" 
export LIBS=-lmpi
export CC=icc 
export FC=ifort 
export F77=ifort 
./configure --prefix=$PREFIX --disable-shared --enable-parallel-tests
#
make 
make install
cd ..
rm -rf netcdf-fortran-4.2
#

```
