# Installing, configuring and compiling WRF with OASIS and XIOS on chaman

## Download source code 
For both uncoupled and coupled versions get: [WRF 4.1.3](https://github.com/massonseb/WRF) and [WPS 4.1](https://github.com/wrf-model/WPS/tags/)

[comment]: <Some useful tips here: https://www.cerfacs.fr/site-oasis/forum/oa_main.php?c=46>
 
Note: following steps from both [UCAR](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php) and [Pratiman](https://pratiman-91.github.io/2020/09/01/Installing-WRF-from-scratch-in-an-HPC-using-Intel-Compilers.html)

## Hands on
Working directory
```
cd /LUSTRE/igarcia/models/WRF_4.1.3_coupled/WRF
```
Load modules (in this order)
```
module load spack
module load intel/MPI2018
```
    
## Install 
Copy source code to /LUSTRE/igarcia/models/WRF_4.1.3_coupled/
```
wget https://github.com/wrf-model/WRF/archive/v4.1.3.tar.gz
```
 
## Configure
Previous to the configuration, we need to make some changes to the configure.wrf file and take into the account the following:
- OASIS3-MCT should already be compiled
- Add  ```-Dkey_cpp_xios & ``` in ARCH_LOCAL within the configure.wrf file
- Add the links to OASIS3-MCT: ```OA3MCT_ROOT_DIR  =      // ```
- Add these lines to INCLUDE_MODULES:
```
-I$(OA3MCT_ROOT_DIR)/BLD/build/lib/mct \
-I$(OA3MCT_ROOT_DIR)/BLD/build/lib/psmile.MPI1 \
```
- Add these lines to LIB_EXTERNAL (before -L$(NETCDFPATH)/lib -lnetcdff -lnetcdf) : 
```
-L$(XIOS_ROOT_DIR)/lib -lxios -L$(OA3MCT_ROOT_DIR)/BLD/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip
```
 
 Configure
 ```
 mv configure.wrf configure.wrf.save
 ./clean -a
 ./clean a
 mv configure.wrf.save configure.wrf  
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
