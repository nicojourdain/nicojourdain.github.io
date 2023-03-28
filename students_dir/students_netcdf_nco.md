---
layout: post
title: Work on netcdf files using the NCO operators
date: 25-05-2020
---

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

To make dimension _time_ the record dimension (_UNLIMITED_):
```shell
ncks -O --mk_rec_dmn time filein.nc fileout.nc
``` 

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
which can also be used over several months or a year with the --mro option:
```shell
ncra -F --mro -d time,,,12,3 tos_monthly_1850-2005.nc tos_mean_JFM.nc
ncra -F --mro -d time,,,12,12 tos_monthly_1850-2005.nc tos_mean_yearly.nc
``` 

To average over an ensemble of files of same structure, e.g. to calculate the monthly-mean diurnal cycle from hourly outputs in daily files:
```shell
nces wrfhrly_y1999m01d??.nc diurnal_y1999m01.nc
```
NB: nces was previously known as ncea.

To remove a degenerated dimension (e.g. z):
```shell
ncwa -F -a z,1 filein.nc fileout.nc
```

**NB: The aforementioned arythmetic operators interpret the _FillValue attribute**

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

Finally, a very powerful command is **ncap2**. Again, there is a large number of possibilities, see NCO user guide for further information. A few examples are given here: 
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
To create variables x and y corresponding to dimensions x and y knowing that xmin=-10000.0 and ymax=20000.0 with a grid spacing of 500.0 along both x and y:
```shell
ncap2 -O -s 'x=array(-10000.0,500.0,$x)' -s 'y=array(20000.0-($y.size-1)*500.0,500.0,$y)'
```

To print the **minimum or maximum** of a variable called 'radlw':
```shell
ncap2 -O -C -v -s "tmp=radlw.min();print(tmp)" filein.nc tmp.nc | cut -f 3- -d ' '
ncap2 -O -C -v -s "tmp=radlw.max();print(tmp)" filein.nc tmp.nc | cut -f 3- -d ' '
```
