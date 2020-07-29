---
layout: post
title: Work on netcdf files using Python
date: 25-05-2020
---

In python, it is very convenient to use the Xarray module. 

If you use Anaconda, you can install it as follows:
```shell
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
