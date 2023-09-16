---
layout: post
title: Work on netcdf files using Fortran
date: 25-05-2020
---

It can be convenient to read netcdf files in your fortran scripts, or to create fortran scripts to treat large netcdf files. For this, you can use the netcdf-fortran library.

Here is an example of very basic fortran program that can be used to read a netcdf file, create or modify a variable and create a new netcdf file that is similar to the first one: [example.f90]({{site.url}}coding_dir/example.f90). And here is the corresponding netcdf file: [test.nc]({{site.url}}coding_dir/test.nc)

A way to compile and execute it (e.g. with the ifort compiler) is :
```shell
NC_INC="-I /apps/netcdf/4.2.1.1/include"  ## to adapt
NC_LIB="-L /apps/netcdf/4.2.1.1/lib -lnetcdf -lnetcdff" ## to adapt
ifort -c $NC_INC example.f90
ifort -o run_example example.o $NC_LIB
./run_example
```

To find the netcdf path, you can do: 
```shell
nc-config --libs
nc-configs --includedir
```

To install the netcdf and netcdf-fortran libraries yourself, check [this page]({{site.url}}coding_dir/coding_nclib).

