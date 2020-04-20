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

See [this page]({{site.url}}students_dir/students_install_Ferret) to install Ferret on your computer.

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
To create variables x and y corresponding to dimensions x and y knowing that xmin=-10000.0 and ymax=20000.0 with a grid spacing of 500.0 along both x and y:
```shell
ncap2 -O -s 'x=array(-10000.0,500.0,$x)' -s 'y=array(20000.0-($y.size-1)*500.0,500.0,$y)'
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

To sum variables over several files :
```shell
cdo enssum file1.nc file2.nc file3.nc file_out.nc
```

To concatenate two consecutive files:
```shell
cdo mergetime JUN1979.nc JUL1979.nc AUG1979.nc SEP1979.nc JJAS_1979.nc
```

To check whether two netcdf files are identical, or to find where differences are :
```shell
cdo diffn file_in.nc file_out.nc
```

To regrid a lon/lat field to another lon/lat grid:
```shell
cat > mygrid << EOF
gridtype = lonlat
xsize    = 192
ysize    = 41
xfirst   = -178.125
xinc     = 1.875
yfirst   = -90
yinc     = 1.25
EOF

cdo remapbil,mygrid file_in.nc file_out.nc  # bi-linear interpolation
cdo remapbic,mygrid file_in.nc file_out.nc  # bi-cubic interpolation
```

It is also possible to define non-structured grids, e.g.:
```shell
cat > mygrid << EOF
gridtype = unstructured
gridsize = 42
nvertex = 1  # nb of vertices (1 for NEMO's bdy, 3 for triangular meshes, 6 for hexagonal meshes)
xvals =   -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85
    -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  
    -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85  -85
yvals = -76.43644  -76.41688  -76.39729  -76.37768  -76.35804  -76.33837  
    -76.31867  -76.29895  -76.2792  -76.25942  -76.23962  -76.21978  
    -76.19991  -76.18002  -76.1601  -76.14015  -76.12018  -76.10017  
    -76.08014  -76.06007  -76.03999  -76.01987  -75.99973  -75.97955  
    -75.95934  -75.93911  -75.91885  -75.89857  -75.87824  -75.85789  
    -75.83752  -75.81712  -75.79669  -75.77623  -75.75574  -75.73522  
    -75.71467  -75.69409  -75.67348  -75.65285  -75.63219  -75.6115  
EOF
```

To perform conservative interpolation, it is require to define bounds, e.g.:
```shell
cat > mygrid << EOF
gridtype = curvilinear
gridsize = 6
xsize = 3
ysize = 2

# Longitudes :
xvals = 301.0  303.0  305.0
        301.0  303.0  305.0

# Longitudes of cell corners :
xbounds =
302.0  302.0  300.0  300.0
304.0  304.0  302.0  302.0
306.0  306.0  304.0  304.0
302.0  302.0  300.0  300.0
304.0  304.0  302.0  302.0
306.0  306.0  304.0  304.0

# Latitudes :
yvals = 61.0  61.0  61.0
        64.0  64.0  64.0

# Latitudes of cell corners :
ybounds =
60.0  63.0  63.0  60.0
60.0  63.0  63.0  60.0
60.0  63.0  63.0  60.0
63.0  65.0  65.0  63.0
63.0  65.0  65.0  63.0
63.0  65.0  65.0  63.0
EOF

cdo remapcon,mygrid file_in.nc file_out.nc  # conservative 1st order interpolation
```

It is also possible to specify which variables to interpolate, and to define the input grid in a file (input_grid) rather than interpretting it from the input netcdf file:
```shell
cdo remapcon,mygrid -selname,var1,var2 -setgrid,input_grid file_in.nc file_out.nc
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
```matlab
ncload('file.nc')                % to load all variables in file.nc
ncload('file.nc','var1','var2')  % to only load var1 and var2
```

To write a netcdf file, use nccreate and ncwrite, e.g.:
```matlab
mlon=length(lon);
mlat=length(lat);

nccreate('file.nc','lon',...
         'Dimensions', {'lon',mlon},...
         'FillValue','disable');

nccreate('file.nc','lat',...
         'Dimensions', {'lat',mlat},...
         'FillValue','disable');

nccreate('file.nc','var1',...
         'Dimensions', {'lon',mlon,'lat',mlat},...
         'FillValue','disable');

ncwrite('file.nc','lon',lon);
ncwrite('file.nc','lat',lat);
ncwrite('file.nc','var1',var1);
```

---

# Read/Modify/Create netcdf files in Python

A possibility is to use the Xarray module. If you use Anaconda, this can be done through the following commands:
```shell
conda install netcdf4
conda install xarray
```

Then, your script to open a netcdf file should look like this:
```python
import numpy as np
import xarray as xr

# Open netcdf file:
file_in = 'Ocean.nc'
print 'Reading ', file_in
nc1 = xr.open_dataset(file_in)

# Get variable 'sst' and print its attributes and shape
rvar=nc1['sst'].values[:,:]
mx=nc1.sizes['longitude']
namvar=nc1['sst'].attrs.get('long_name')
unitvar=nc1['sst'].attrs.get('units')
print 'Processing ', nc1['sst'].attrs.get('long_name')
print 'Size is ', nc1['sst'].shape
```

*NB:* If your netcdf does not follow the CF conventions, you need to open the file as follows:
```python
nc1 = xr.open_dataset(file_in,decode_cf=False)
```

A list of useful tools and tutorials is provided on the [MEOM groups's page](https://github.com/meom-group/tutos/blob/master/software.md).
