Installation of WRF & WPS on chaman again (marzo-abril 2022)
# copies of the configure files used in
# /home/ivonne/Documents/Postdocs/CICESE_2021/notas/manuales/WRF_WPS_REinstallation_chaman
    configure.wrf 
    configure.wps
    namelist.wps
    namelist.input
    run_geogrid.pbs
    run_metgrid.pbs
    run_real.pbs
    run_wrf.pbs
    tweak_output_d01.txt
 

#--- 0) cp & extract WRF & WPS tar files here
cd /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF

#--- 1) Configure & compile WRF 
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load intel/MPI2018
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
module load jasper-1.900.1-intel-18.0.1-3sxqjot

    # --> be careful if need to configure again, better to use the same configure.wrf (without running ./configure)

# Compile (took ~45 hrs!)   # Favio did this
./compile -j 16 em_real >out1.log 2>out2.log  

ls -ls main/*.exe # should show 4 exe --> wrf, real, ndown, tc


#--- 2) Configure & compile WPS: 
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load intel/MPI2018
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi
module load jasper-1.900.1-intel-18.0.1-3sxqjot

    # same here --> be careful if need to configure again, better to use the same configure.wps (without running ./configure)

./compile >& log.compile # 1-2 min to compile

ls -lrt # should create 3 exe in 1-2 min --> geogrid, ungrib, metgrid


#--- 3) Run WPS exes:

# ----- Real time data
# Using 2-day ERA5 data as example

# * * * * ungrib * * * *    
# Link the GFS Vtable:
cd /LUSTRE/igarcia/models/WRF_4.1.3_withXIOS/WPS
ln -sf ungrib/Variable_Tables/Vtable.ERA-interim.pl Vtable
    
# Link-in the grib data
./link_grib.csh /LUSTRE/igarcia/data/ERA5/data/ERA5-20160801-20161130*.grib
        
# Edit namelist.wps (ungrib section)
vi namelist.wps
    
# Run ungrib to create the intermediate files:
./ungrib.exe # --> Will create FILE:YYYY-MM-DD_HH files

# To check data info:
#./util/rd_intermediate.exe FILE:YYYY-MM-DD_HH


# * * * * geogrid * * * *  
# Edit namelist.wps (geogrid section)
vi namelist.wps

# to check the domain:
#ncl util/plotgrids_new.ncl

# Run geogrid.exe
    # should create static file(s) geo_em.d01.nc (1 per domain)
#./geogrid.exe 
# OR
vi run_geogrid.pbs 
qsub run_geogrid.pbs 


# * * * * metgrid * * * *  
# Edit namelist.wps (metgrid section)
vi namelist.wps

# Run metgrid.exe
    # should create files met_em.d01.YYYY-MM-DD_00:00:00.nc (one per input file)
# ./metgrid.exe
# OR
vi run_metgrid.pbs 
qsub run_metgrid.pbs     

#--- 4) Run real & wrf:
cd /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF/test/em_real

# Link in the met_em files created with metgrid.exe
ln -sf ../../../WPS/met_em.d01.* .    

# Edit namelist.input
vi namelist.input

# Create .pbs file to submit real job to queue
vi run_real.pbs   

# Run real.exe
qsub run_real.pbs  # --> should create wrfinput_d01, wrflowinput_d01 and wrfbdy_d01 files. It also creates rsl.out 00xx and rsl.error.0xx where the errors (if any) are stored. We can either rm them when the script finalised running or leave them here.


# Create .pbs file to submit wrf job to queue
vi run_wrf.pbs

# Run real.exe
qsub run_wrf.pbs # --> wrfout_d01_YYYY-MM-DD_HH:MM:SS

# - - - - - - - - - R u n n i n g   o f   W R F   e n d s   h e r e - - - - - - - - - #






#  - - - - - - - - - S o m e   P o s t r o c e s s i n g - - - - - - - - - - - - - - #

# Mv outputs to another folder to avoid overwritting files
cd /LUSTRE/igarcia/outputs/
vi save_WRF_outputs_chaman.csh # modify name case and other relevant fields
./save_WRF_outputs_chaman.csh


# Extract some fields for preliminary plottings
cd /LUSTRE/igarcia/outputs/
vi extract_fields_every_12h.csh # modify as necessary
./cd /LUSTRE/igarcia/outputs/


# Cp data to lap (* example dirs)
from /home/ivonne/Documents/Postdocs/CICESE_2021/plots/${FF04_2016}
scp igarcia@chaman.cicese.mx:/LUSTRE/igarcia/outputs/${WRF_003_FF04_2016_withoutXIOS_4days_3km}/*_d01_*_12h.nc ./

# Preliminary plots
from /home/ivonne/Documents/Postdocs/CICESE_2021/plots/plot_scripts/
sfc_scalars.py # currently plots: T2, LH, HFX, QFX
sfc_vectors.py # currently plots (U10,V10)



#  - - - - - - - - - - - - - - - - - - - - - - - #
# These are the paths of the libs used for this compilations:

export HDF5_LIB=/share/apps/spack/opt/spack/linux-centos6-x86_64/intel-18.0.1/hdf5-1.12.1-7wq2s6wau62aftnbzmr5pv4tdonp62fm/lib 
export NETCDFC_LIB=/share/apps/spack/opt/spack/linux-centos6-x86_64/intel-18.0.1/netcdf-c-4.7.0-vtkbioo6h6u75eiuhjivrrrdhtkcgprd/lib
export NETCDFF_LIB=/share/apps/spack/opt/spack/linux-centos6-x86_64/intel-18.0.1/netcdf-fortran-4.4.4-zhe2pvio3m74qelvdtmgmrkmwb4p26mg/lib
export JASPER_LIB=/share/apps/spack/opt/spack/linux-centos6-x86_64/intel-18.0.1/jasper-1.900.1-3sxqjot6v3hcybwx4sfpgvd36mqjjtk2/lib
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HDF5_LIB}:${NETCDFC_LIB}:${NETCDFF_LIB}:${JASPER_LIB}  
