# Installing, configuring and compiling WPS on chaman
## Download source code to /LUSTRE/igarcia/models/WRF_4.1.3
For uncoupled version get: [WPS 4.1](https://github.com/wrf-model/WPS/archive/v4.1.tar.gz)
```
wget https://github.com/wrf-model/WPS/archive/v4.1.tar.gz 
tar xfv WPS-4.1.tar.gz 
```
> I changed the dirname (mv WPS-4.1 WPS)

Note: following steps from both [UCAR](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php) and [Pratiman](https://pratiman-91.github.io/2020/09/01/Installing-WRF-from-scratch-in-an-HPC-using-Intel-Compilers.html)

## Load modules 
```
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load intel/MPI2018
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
module load jasper-1.900.1-intel-18.0.1-3sxqjot
```

## Configure
 ```
 ./configure
 ```
 Select option 17  Linux x86_64, Intel compiler    (serial) 
 *Important*: it is recommended to compile WPS in serial mode, regardless of whether you compiled WRF in parallel.
 
 ## Compile
 ```
./compile >& log.compile    
```
Check that 3 executables are created (geogrid, ungrib, metgrid)
```
ls -l main/*.exe
``` 



## Otherwise, if neccesary, download and install missing libraries on chaman
```
export DIR=/LUSTRE/igarcia/models/WRF_4.1.3/Build_WRF/LIBRARIES   
```
### zlib (compression library necessary for compiling WPS (ungrib) with GRIB2 capability)  
```
tar xvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$DIR/grib2
make
make install
cd ..
```

### libpng (compression library necessary for compiling WPS (ungrib) with GRIB2 capability)  
```
tar xzvf libpng-1.2.50.tar.gz     
cd libpng-1.2.50
./configure --prefix=$DIR/grib2
make
make install
cd ..
``` 

### JasPer (compression library necessary for compiling WPS (ungrib) with GRIB2 capability)
```
wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.29.tar.gz  
tar xzvf jasper-1.900.29.tar.gz
cd jasper-1.900.1
./configure --prefix=$DIR/grib2
make
make install 
cd ..
```

Install WPS (with my jasper lib). First do all exports previously used in WRF:
```
cd WPS
export WRF_DIR=/LUSTRE/igarcia/models/WRF_4.1.3/WRF
export JASPERLIB=/LUSTRE/igarcia/models/WRF_4.1.3/Build_WRF/LIBRARIES/grib2/lib
export JASPERINC=/LUSTRE/igarcia/models/WRF_4.1.3/Build_WRF/LIBRARIES/grib2/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${JASPERLIB} 
```
  
