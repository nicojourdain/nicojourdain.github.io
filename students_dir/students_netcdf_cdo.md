---
layout: post
title: Work on netcdf files using the cdo operators
date: 25-05-2020
---

Many things (running means, EOF, conversions, etc) can now be done using the cdo operators. For a list of available operators, see [this PDF list](https://code.zmaw.de/projects/cdo/embedded/cdo_refcard.pdf), or [here for the full documentation](https://code.mpimet.mpg.de/projects/cdo/embedded/index.html). 

A few examples are shown below.

To create a variable from the **sum** (var_sum) of two existing variables (var1 & var2) :
```shell
cdo expr,'var_sum=var1+var2' file_in.nc file_out.nc
```

To sum variables over several files :
```shell
cdo enssum file1.nc file2.nc file3.nc file_out.nc
```

To **concatenate** two consecutive files:
```shell
cdo mergetime JUN1979.nc JUL1979.nc AUG1979.nc SEP1979.nc JJAS_1979.nc
```

To check whether **two netcdf files are identical**, or to find where differences are :
```shell
cdo diffn file_in.nc file_out.nc
```

To convert **grib to netcdf** :
```shell
cdo -f nc copy file_in.grib file_out.nc
```
As variable names are not stored in grib files, you may need to contact the institute that built the grib file to identify variables (e.g. check ungrib/Variable_Tables for WRF/WPS files).

To **regrid** a lon/lat field to another lon/lat grid:
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
cdo remapnn,mygrid file_in.nc file_out.nc   # nearest neighbour interpolation
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

To perform conservative interpolation, it is required to define bounds, e.g.:
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
In this example, the curvilinear grid type means that this is a 2d grid, which is not necessarily regular in longitude, latitude.

It is also possible to specify which variables to interpolate, and to define the input grid in a file (input_grid) rather than interpretting it from the input netcdf file:
```shell
cdo remapcon,mygrid -selname,var1,var2 -setgrid,input_grid file_in.nc file_out.nc
```

See [this example](https://forge.ipsl.jussieu.fr/nemo/wiki/Users/SetupNewConfiguration/cdo-interpolation) for interpolation onto a NEMO grid.
