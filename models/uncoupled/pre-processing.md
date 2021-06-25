# Static Geography data
First we need to get the static data (topography, vegetation and other fields)
```
cd /LUSTRE/igarcia/models/WRF_4.1.3/Build_WRF/WPS_GEOG
wget http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz ./
gunzip geog_high_res_mandatory.tar.gz
tar -xf geog_high_res_mandatory.tar
```    
The directory infomation is given to the geogrid program in the namelist.wps (/LUSTRE/igarcia/models/WRF_4.1.3/WPS) file in the &geogrid section:
```
geog_data_path = '/LUSTRE/igarcia/models/WRF_4.1.3/Build_WRF/WPS_GEOG'
```
  
  
    
# Real time data
Using Hurricane Matthew data as example

## ungrib 
Link the GFS Vtable:
```
cd WPS
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
```
    
Link-in the grib data
```
./link_grib.csh /LUSTRE/igarcia/data/GFS_test/matthew/fnl
```

Edit namelist.wps (ungrib section)
```
vi namelist.wps
```

Run ungrib to create the intermediate files:
```
./ungrib.exe # --> Will create FILE:YYYY-MM-DD_HH files
```

To check data info:
```
./util/rd_intermediate.exe FILE:YYYY-MM-DD_HH
```

## geogrid
Edit namelist.wps (geogrid section)
```
vi namelist.wps
```

to check the domain:
```
module load intel/ncl-6.3.0
ncl util/plotgrids_new.ncl
```
> the ncl script is not currently showing the map

Run geogrid.exe
```
./geogrid.exe # should create static file(s) geo_em.d01.nc
```

##  metgrid
Edit namelist.wps (metgrid section)
```
vi namelist.wps
```

Run metgrid.exe
```
./metgrid.exe 
```
should create files met_em.d01.YYYY-MM-DD_00:00:00.nc (one per input file)
