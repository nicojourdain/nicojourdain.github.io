---
layout: post
title: Work on netcdf files using Python
date: 25-05-2020
---

In python, it is very convenient to use the Xarray module. If you use conda, you can install it as follows:
```shell
conda install xarray
```

# Open a netcdf file and scan its content

your script to open a netcdf file should look like this:
```python
import xarray as xr

# Open netcdf file:
file_in = 'Ocean.nc'
nc1 = xr.open_dataset(file_in)
print(nc1)
```

If several files are used with the same grid but different dimension names (e.g. 'z' and 'deptht'), it can be convenient to rename dimensions:
```python
nc1=nc1.rename_dims({'z':'deptht'})
```

If your netcdf does not follow the CF conventions, you need to open the file as follows:
```python
nc1 = xr.open_dataset(file_in,decode_cf=False)
```
You can also set ```decode_coords=False``` or ```decode_times=False``` if you don't want to interpret coordinates or the time axis but still want to interpret other attributes (e.g. _FillValue).

To open multiple files as a single dataset, e.g.:
```python
files1 = ['seaice_conc_monthly_20050'+month.astype('str')+'_v02r00.nc' for month in np.arange(1,10)]
files2 = ['seaice_conc_monthly_2005'+month.astype('str')+'_v02r00.nc' for month in np.arange(10,13)]       
files = files1+files2
nc1 = xr.open_mfdataset(files)
```

# Basic operations on variables

To get the 'longitude' dimension:
```python
print(nc1.longitude.size)
mx=nc1.longitude.size
```

To get the shape or attributes of a variable named 'toce':
```python
print(nc1.toce.shape)
print(nc1.toce.attrs.get('long_name'))
```

To get the values of a variable and run simple operations:
```python
toce=nc1.toce.values
sst=nc1.toce.values[:,0,:,:]
```

To run simple operations, e.g. on multi-dimensional 'toce' variable:
```python
tID=nc1.toce.get_axis_num('time') # gives integer corresponding to the 'time' axis
mean_sst=nc1.toce.mean(axis=tID)  # equivalent to nc1.toce.mean(axis=0)
meanT=nc1.toce.mean()
minT=nc1.toce.min()
heat_content=(nc1.toce*nc1.e3t).sum(axis=1)
```

To select specific dimension values or slices, e.g. for a variable var of dimensions (time, ygrid, xgrid):
```python
var0=nc1.var.isel(time=0)
var0=nc1.var.isel(xgrid=slice(0,10),ygrid=(5,15))
var2=nc1.var.sel(time="2005-02-01")
var3=nc1.var.sel(xgrid=slice(-5.e6,-1.e6),ygrid=slice(0,1.e6))
```
If variables 'longitude' and 'latitude' are defined on the (ygrid, xgrid) grid, i.e. are not the dimensions, you can select a specific area as follows:
```python
var4=nc1.var.where((nc1.latitude<-60)&(nc1.latitude>-80)&(nc1.longitude<-90)&(nc1.longitude>-130))
```

A list of useful tools and tutorials is provided on the [MEOM groups's page](https://github.com/meom-group/tutos/blob/master/software.md).
