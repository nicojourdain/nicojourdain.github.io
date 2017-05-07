---
layout: post
title: How to deal with netcdf files?
date: 28-03-2017
---

This page is organised as follows:

1. Read metadata and quickly visualise netcdf files
2. Modify netcdf files using the NCO operators
3. Using cdo operators
4. Read/Modify/Create netcdf files in fortran90
5. Read/Modify/Create netcdf files in Matlab
6. Read/Modify/Create netcdf files in Python

---

# Read metadata and quickly visualise netcdf files

To list the metadata of a netcdf file (dimensions, variable names, attributes) :
```shell
ncdump -h file.nc
```

To list the metadata and the values of variable var1 :
```shell
ncdump -v var1 file.nc | more
```

To have a quick look at the fields (i.e. the variables) in the netcdf file, use ncview:
```shell
ncview file.nc &
```

Ferret is also a convenient software to have a quick look at netcdf files, e.g. :
```shell
ferret
  yes? use "/home/bob/DATA/bathy_meter.nc"
  yes? show data
  yes? shade BATHYMETRY
  yes? plot BATHYMETRY[i=200]
  yes? plot/over BATHYMETRY[i=215]
  yes? quit
```

See Ferret documentation [here](http://ferret.pmel.noaa.gov/Ferret/documentation/users-guide) for more complex plots and diagnostics.

---

# Modify netcdf files using the NCO operators

NCO tools consist of several powerful commands to read/modify/create netcdf files. The full documentation can be found [here]. Some simple basic command lines are shown here as an example.

To rename variable var1 as "newvar" or dimension x as "lon" :
```shell
ncrename -O -v var1,newvar filein.nc fileout.nc
ncrename -O -d x,lon filein.nc fileout.nc
```

To **crop a netcdf file**, i.e. to reduce the domain size (with option -F indices start from 1):
```shell
ncks -F -d time,1,10 filein.nc fileout.nc
ncks -F -d x,92,111 filein.nc fileout.nc
```

Similarly, if you have a well written netcdf file (with appropriate attributes) and a lon-lat grid, you may be able to use (don't forget the dots in the numbers):
```shell
ncks -d lat,-30.0,30.0 filein.nc fileout.nc
```

To **only keep variables var1 and var2** in a netcdf file (option -O is to overwritte):
```shell
ncks -O -v var1,var2 filein.nc fileout.nc
```

To **remove variables** var1 and var2 from a netcdf file:
```shell
ncks -O -x -v var1,var2 filein.nc fileout.nc
```

To **merge two files** of same dimension (name and size), e.g. file1.nc containing the variable var(x,y) and file2.nc containing the variables nav_lon(x,y), nav_lat(x,y) and Bathymetry(x,y), you can do as follows:
```shell
ncks -A file1.nc file2.nc
```
The variable var(x,y) will then be included into file2.nc 

To **concatenate files** with the same variables and consecutive time steps (e.g. there is one file per month [whatever the output frequency within this file] and you want a file containing the JJAS months):
```shell
ncrcat JUN1979.nc JUL1979.nc AUG1979.nc SEP1979.nc JJAS_1979.nc  
```

To calculate **time-averages**, e.g. to calculate a monthly mean from a file containing daily outputs:
```shell
ncra -F -d time,1,31 file_January_daily.nc file_January_monthly.nc
```
This can also be used to calculate mean Jan/Feb/March/... over a multi-year file:
```shell
ncra -F -d time,1,1872,12 tos_monthly_1850-2005.nc tos_mean_JAN.nc
ncra -F -d time,2,1872,12 tos_monthly_1850-2005.nc tos_mean_FEB.nc
ncra -F -d time,3,1872,12 tos_monthly_1850-2005.nc tos_mean_MAR.nc
```

To remove a degenerated dimension (e.g. z):
```shell
ncwa -F -a z,1 filein.nc fileout.nc
```

Here are a few examples showing how to modify **netcdf attributes** (see NCO user guide for further information). 
To delete attribute "standard_name" for variable "var1":
```shell
ncatted -a standard_name,var1,d,, filein.nc fileout.nc
```

To modify existing attribute "long_name" of character type for variable var1:
```shell
ncatted -a long_name,var1,m,c,'temperature' filein.nc fileout.nc
```
To create non-existing attribute "units" of character type for variable var1:
```shell
ncatted -a units,var1,c,c,'K' filein.nc fileout.nc
```

Finally, a very powerful command is ncap2. Again, there is a large number of possibilities, see NCO user guide for further information. A few examples are given here: 
To calculate new variable called KE from existing uu and vv variables:
```shell
ncap2 -F -s "KE=0.5*(uu*uu+vv*vv)" file_in.nc file_out.nc
```
To create a land mask variable (sftlf) based on SST (tos) values : 
```shell
ncap2 -F -s "sftlf=tos(1,:,:)*0.0 ; \\
sftlf = sftlf.delete_miss() ; \\
sftlf(:,:) = 100.0 ; \\
where( tos(1,:,:) > 260.0 || tos(1,:,:) < 310.0 ) sftlf=0.0" \\
filein.nc fileout.nc
```
To use a loop to fill existing variable X from index 1 to index 482:
```shell
ncap2 -F -s \\
"idx=1 ; while(idx<482){X(idx) = 20.0+0.75*idx; idx++;}" \\
filein.nc fileout.nc
```

---

# Using cdo operators

Many things (running means, EOF, conversions, etc) can now be done using the cdo operators. For a list of available operators and options, see:
[this PDF](https://code.zmaw.de/projects/cdo/embedded/cdo_refcard.pdf)

A few very simple examples are shown below.

To create a variable from the sum (var_sum) of two existing variables (var1 & var2) :
```shell
cdo expr,'var_sum=var1+var2' file_in.nc file_out.nc
```

To check whether two netcdf files are identical, or to find where differences are :
```shell
cdo diffn file_in.nc file_out.nc
```

To convert grib to netcdf :
```shell
cdo -f nc copy file_in.grib file_out.nc
```
As variable names are not stored in grib files, you may need to contact the institute that built the grib file to identify variables (e.g. check ungrib/Variable_Tables for WRF/WPS files).

---

# Read/Modify/Create netcdf files in fortran90

It can be convenient to read netcdf files in your fortran scripts, or to create fortran scripts to treat large netcdf files. For this, you can use the netcdf-fortran library.

Here is an example of very basic fortran program that can be used to read a netcdf file, create or modify a variable and create a new netcdf file that is similar to the first one: [example.f90]({{site.url}}students_dir/example.f90).

A way to compile and execute it (e.g. with the ifort compiler) is :
```shell
NC_INC="-I /apps/netcdf/4.2.1.1/include"  ## to adapt
NC_LIB="-L /apps/netcdf/4.2.1.1/lib -lnetcdf -lnetcdff" ## to adapt
ifort -c $NC_INC example.f90
ifort -o run_example example.o $NC_LIB
./run_example
```

NB1: to find the netcdf path, you can do: 
```shell
nc-config --libs
nc-configs --includedir
```

NB2: if you want to install the libraries yourself, check [this page]({{site.url}}students_dir/students_nclib).

---

# Read/Modify/Create netcdf files in Matlab

To read a netcdf file, you can use [ncload.m](http://github.com/nicojourdain/matlab_scripts/blob/master/ncload.m)

To be completed...

---

# Read/Modify/Create netcdf files in Python

To be written...



