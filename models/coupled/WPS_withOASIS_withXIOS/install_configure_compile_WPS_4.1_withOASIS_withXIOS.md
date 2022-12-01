# Installing, configuring and compiling WPS with OASIS and XIOS on chaman

## Download source code 
Working dir: /LUSTRE/igarcia/models/WRF_4.1.3_withXIOS

For coupled version get: [WPS 4.1](https://github.com/wrf-model/WPS/archive/v4.1.tar.gz)
```
wget https://github.com/wrf-model/WPS/archive/v4.1.tar.gz 
tar xfv WPS-4.1.tar.gz 
```
> I changed the dirname (mv WPS-4.1 WPS)

Note: following steps from both [UCAR](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php) and [Pratiman](https://pratiman-91.github.io/2020/09/01/Installing-WRF-from-scratch-in-an-HPC-using-Intel-Compilers.html)

## Load modules 
```
module load spack
module load intel/MPI2018
```

## Configure
If we want to use the current configure.wrf file, only do:
```
mv configure.wrf configure.wrf.save
./clean -a
./clean a
mv configure.wrf.save configure.wrf  
``` 
 
 ## Compile
 ```
./compile >& log.compile    
```
Takes about 2 min. Check that 3 executables are created (geogrid, ungrib, metgrid)
```
ls -l main/*.exe
```
  
