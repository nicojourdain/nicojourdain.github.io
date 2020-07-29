---
layout: post
title: Work on netcdf files using Matlab
date: 24-04-2017
---

**WARNING: this page has not been updated for several years, and its content may be obsolete.**

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
