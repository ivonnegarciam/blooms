### Get source code in the desired path:
```
svn co http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5/
```

### Go to XIOS directory:
```
cd /LUSTRE/igarcia/models/XIOS_2.5_withoutOASIS
```

### Load modules 
Follow this order:
(Double check that all these modules are neccessary)
```
load module spack
load module netcdf-c-4.7.0-intel-18.0.1-vtkbioo
load module intel/MPI2018
load module netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
load module jasper-1.900.1-intel-18.0.1-3sxqjot
```  

### Create/modify arch files: 
arch-X64_CHAMAN2018_spack.env, arch-X64_CHAMAN2018_spack.fcm, and arch-X64_CHAMAN2018_spack.path to include the current dependency versions from spack
``` 
cd /LUSTRE/igarcia/models/XIOS_2.5_withOASIS/arch
vi arch-X64_CHAMAN2018_spack.env  # --> same as in withOASIS
vi arch-X64_CHAMAN2018_spack.fcm  # --> same as in withOASIS
vi arch-X64_CHAMAN2018_spack.path # --> no OASIS path needed here
``` 

The *.env file specifies where HDF5 and NetCDF4 libraries live. The *.fcm file specifies which compilers and options to use. The *.path file specifies which paths and options to include. 

### Compile
```
./make_xios --arch X64_CHAMAN2018_spack >& log.compile.chaman   
```
It takes about 30 min. When succesful, several executables (including xios_server.exe) and symbolic links to the three arch files are created in /bin/
