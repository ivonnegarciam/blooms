# Installing, configuring and compiling WRF on chaman
## Download source code 
For uncoupled version get: [WRF 4.1.3](https://github.com/massonseb/WRF) and [WPS 4.1](https://github.com/wrf-model/WPS/tags/)

For coupled version get: [WRF & WPS 3.7](https://www2.mmm.ucar.edu/wrf/users/download/get_sources.html)
 
Note: following steps from both [UCAR](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php) and [Pratiman](https://pratiman-91.github.io/2020/09/01/Installing-WRF-from-scratch-in-an-HPC-using-Intel-Compilers.html)

## Hands on
Working directory
```
cd /LUSTRE/igarcia/models/WRF_4.1.3/WRF
./clean
```
Load intel
```
module load intel/MPI2017
module load intel/cdf-bundle2017
```

Setting up the environment for intel compilers
```
export CC=icc
export CXX=icpc
export F77=ifort
export FC=ifort
export F90=ifort

export NETCDF=/share/apps/netcdf4.2-paralelo
export NETCDF_LIB_DIR=/share/apps/netcdf4.2-paralelo/lib
export NETCDF_INC_DIR=/share/apps/netcdf4.2-paralelo/include

export HDF5=/share/apps/hdf5-paralelo
export HDF5_LIB_DIR=/share/apps/hdf5-paralelo/lib
export HDF5_INC_DIR=/share/apps/hdf5-paralelo/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_LIB_DIR}:${HDF5_LIB_DIR}
```
    
## Install 
Copy source code to /LUSTRE/igarcia/models/WRF_4.1.3
```
 wget https://github.com/wrf-model/WRF/archive/v4.1.3.tar.gz
 ```
 
 ## Configure
 ```
 ./configure
 ```
 Select option 15 (dmpar) INTEL (ifort/icc)
 
 nesting 1 = basic
 
 *Important*: edit these two lines in configure.wrf
 ```
 DM_FC           =       mpiifort
 DM_CC           =       mpiicc
 ```    
 
 ## Compile
 Can take a couple of hours
 ```
./compile em_real >& log.compile    
```
Check that 4 executables are created (wrf, real, ndown, tc)
```
ls -ls main/*.exe
``` 
