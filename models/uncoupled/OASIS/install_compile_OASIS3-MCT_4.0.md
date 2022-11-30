## About OASIS3-MCT
- Newest version available at the moment is 4.0 (as of Aug 2022)
- OASIS
- MCT: Model Coupling Toolkit (Argonne National Laboratory)
- OASIS3-MCT is a coupling library that needs to be linked to the component models, with the main function of interpolating and exchanging the coupling fields between these components
- All coupling exchanges are now executed in parallel directly between the components via Message Passing Interface (MPI)
- OASIS3-MCT also supports file I/O using NetCDF (though non-parallel)
- To communicate with another model, or to perform I/O actions, a component model needs to include a few specific calls to the OASIS3-MCT coupling library, using the AP
- More info: [https://oasis.cerfacs.fr/en/](https://oasis.cerfacs.fr/en/)

## Get the source code

### Register 
[https://oasis.cerfacs.fr/en/download-oasis3-mct-sources/](https://oasis.cerfacs.fr/en/download-oasis3-mct-sources/)

### Download OASIS to CHAMAN:
From /LUSTRE/igarcia/models/compressed:
```    
wget https://www.cerfacs.fr/oa4web/oasis3-mct_4.0/OASIS3-MCT_4.0.tgz
tar -zxf OASIS3-MCT_4.0.tgz --directory /LUSTRE/igarcia/models/OASIS3_MCT/ 
```    
Note: I had to move everything one level up and rm folder oasis3mct

## Compile    
Compilation is done from:
```
cd /LUSTRE/igarcia/models/OASIS3_MCT/util/make_dir
```

### 1) Load modules (in this order):
```
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo    
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
module load intel/MPI2018
```    
    
### 2) Create & modify make_X64_CHAMAN
Important notes: 
- modify paths to direct to current libraries used by the models we are using
- Root of OASIS tree must be defined by variable COUPLE
- use mpiifort (not mpif90) fOr compiling
- use make (not gmake)
    
### 3) Modify make.inc to include this line:
include /LUSTRE/igarcia/models/OASIS3_MCT/util/make_dir/make_X64_CHAMAN
    
### 4) Compile
To remove all OASIS3-MCT compiled sources and libraries:
```
make realclean -f TopMakefileOasis3
```
Compile:
```
make -f TopMakefileOasis3
```
The libraries "libmct.a", "libmpeu.a", "libpsmile.MPI1.a" and "libscrip.a" that need to be linked to the models are available in the directory: /LUSTRE/igarcia/models/OASIS3_MCT/BLD/lib 
Note 1: The compilation creates 2 dirs: /OASIS3_MCT/BLD & /OASIS3_MCT/lib         
      
