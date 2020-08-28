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
Alternatively, you can just set ```decode_coords=False``` or ```decode_times=False```.

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
mean_sst=nc1.toce.mean(axis=0).values
meanT=nc1.toce.mean().values
meanT=nc1.toce.min().values
heat_content=(nc1.toce*nc1.e3t).sum(axis=1)
```

A list of useful tools and tutorials is provided on the [MEOM groups's page](https://github.com/meom-group/tutos/blob/master/software.md).
