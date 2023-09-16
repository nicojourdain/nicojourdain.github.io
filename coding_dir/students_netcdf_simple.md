---
layout: post
title: Quickly visualise a netcdf file
date: 25-05-2020
---

The netcdf files include metadata that describe their content. To list the metadata of a netcdf file (dimensions, variable names, attributes), you can use the ncdump command that comes with the netcdf library :
```shell
ncdump -h file.nc
```

To list the metadata and the values of variable var1 :
```shell
ncdump -v var1 file.nc | more
```

A number of people use ncview to have a quick look at variables in a netcdf file:
```shell
ncview file.nc &
```

Ferret is also a convenient software to have a quick look at netcdf files, e.g. :
```shell
ferret
  yes? use "/home/bob/DATA/bathy_meter.nc"
  yes? show data
  yes? shade BATHYMETRY
  yes? go land
  yes? plot BATHYMETRY[i=200]
  yes? plot/over BATHYMETRY[i=215]
  yes? quit
```

Ferret is also useful for more complicated things, like regridding, see [Ferret Documentation](http://ferret.pmel.noaa.gov/Ferret/documentation/users-guide) to explore possibilities.

It is also possible to use [PyFerret](https://ferret.pmel.noaa.gov/Ferret/documentation/pyferret), which works as the standard Ferret but is encapsulated in Python. This can be installed through anaconda as:
```shell
conda create -n FERRET -c conda-forge pyferret ferret_datasets --yes
```
Then, to use it:
```shell
conda activate FERRET
ferret
```
When exiting, you'll need to leave the environment:
```shell
conda deactivate
```

See [this page]({{site.url}}students_dir/students_install_Ferret) to install Ferret on your computer.

