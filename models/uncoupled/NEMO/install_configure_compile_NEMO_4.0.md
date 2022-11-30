# Installing, configuring and compiling NEMO 4.0 on chaman

## Get source code
### a) From within chaman
For this project, we will be using NEMO v4.0, which is already installed on chaman so we just need to cp the source files to the current working directory. We will have to modify the arch & other files.
### b) Direct download 
If a different version is required, download directly from:
[https://forge.nemo-ocean.eu/nemo/nemo/-/releases/](https://forge.nemo-ocean.eu/nemo/nemo/-/releases/)

## Previous steps to model compilation

### Load modules
```
module load spack
module load intel/MPI2018
```

### Copy source code
```
cp -r /LUSTRE/jouanno/INTERCAMBIO/Nemo_4.0_release/* /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/
cd /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/  
```

### Compile tools
Before compiling NEMO, we need to compile some (pre/post)processing tools (for grids, weights, boundary file formating, among others). 
```
./maketools -n BDY_TOOLS -m X64_CHAMAN2018 -j4
./maketools -n DMP_TOOLS -m X64_CHAMAN2018 -j4
./maketools -n DOMAINcfg -m X64_CHAMAN2018 -j4
./maketools -n GRIDGEN -m X64_CHAMAN2018 -j4
./maketools -n MISCELLANEOUS -m X64_CHAMAN2018 -j4
./maketools -n MPP_PREP -m X64_CHAMAN2018 -j4 
./maketools -n NESTING -m X64_CHAMAN2018 -j4
./maketools -n OBSTOOLS -m X64_CHAMAN2018 -j4
./maketools -n REBUILD -m X64_CHAMAN2018 -j4
./maketools -n REBUILD_NEMO -m X64_CHAMAN2018 -j4
./maketools -n SCOORD_GEN -m X64_CHAMAN2018 -j4
./maketools -n SECTIONS_DIADCT -m X64_CHAMAN2018 -j4
./maketools -n SIREN -m X64_CHAMAN2018 -j4
./maketools -n WEIGHTS -m X64_CHAMAN2018 -j4
```

## Duplicate configuration
Modify the architecture file if necessary (./arch/). It contains the paths to the compiler, the libraries MPI, netcdf & dependencies:
```
cd ./arch
vi arch-X64_CHAMAN2018.fcm  (uses intel2018 & dependencies from spack)
```

Copy the cfgs to be used, for instance:
```
cp -r /LUSTRE/fandrade/MODELOS/NEMO4/cfgs/GOLFO36-R01 /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs
```
Check that all namelists and other files are copied (except the nemo exe, they are ~14). Regularly they are not, if so copy them manually:
```
rsync -rv --exclude=nemo /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-R01/EXP00/* /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/EXP00/
```

Modify [namelist_cfg](namelist_cfg), if necessary (I think this should be done here/now):
```
cd /EXP00/
vi namelist_cfg
```

Add the configuration name to the list in work_cfgs.txt
```
vi /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/work_cfgs.txt
```


## Compile 
Currently, it takes about 3 min
```
./makenemo -r GOLFO36-R01 -n GOLFO36-E02 -m X64_CHAMAN2018 -j4 
```

If successful, the compilation creates a new folder (named as the config case) with the binary nemo.exe: 
```
/LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/BLD/bin/nemo.exe   
```
At the end of the configuration compilation, GOLFO36-E02 directory will have the following structure:
```
BLD    --> BuiLD folder: target executable, headers, libs, preprocessed routines, …
EXP00  --> Run folder: link to executable, namelists, *.xml and IOs
EXPREF --> Files under version control only for official configurations
MY_SRC --> New routines or modified copies of NEMO sources
WORK   --> Links to all raw routines from ./src considered
```
