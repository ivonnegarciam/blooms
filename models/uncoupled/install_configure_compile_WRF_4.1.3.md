# Installing, configuring and compiling WRF on chaman
## Download source code 
For uncoupled version get: [WRF 4.1.3](https://github.com/massonseb/WRF) and [WPS 4.1](https://github.com/wrf-model/WPS/tags/)

For coupled version get: [WRF & WPS 3.7](https://www2.mmm.ucar.edu/wrf/users/download/get_sources.html)
 
Note: following steps from both [UCAR](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php) and [Pratiman](https://pratiman-91.github.io/2020/09/01/Installing-WRF-from-scratch-in-an-HPC-using-Intel-Compilers.html)

## Hands on
Working directory
```
cd /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF
./clean
```
Load modules (in this order)
```
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load intel/MPI2018
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
module load jasper-1.900.1-intel-18.0.1-3sxqjot
```
    
## Install 
Copy source code to /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS
```
 wget https://github.com/wrf-model/WRF/archive/v4.1.3.tar.gz
 ```
 
 ## Configure
 ```
 ./configure
 ```
 Select option 15 (dmpar) INTEL (ifort/icc)
 
 nesting 1 = basic
 
 *Important*: edit these two lines in [configure.wrf](configure.wrf)
 ```
 DM_FC           =       mpiifort
 DM_CC           =       mpiicc
 ```    
 
 ## Compile
 Can take ~45 mins
 ```
 ./compile -j 16 em_real >out1.log 2>out2.log    
 ```
 Check that 4 executables are created (wrf, real, ndown, tc)
 ```
 ls -ls main/*.exe
 ``` 
