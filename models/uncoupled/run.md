Run real.exe and wrf.exe

# real
```
cd /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF/test/em_real
```

Link in the met_em files created with metgrid.exe
```
ln -sf ../../../WPS/met_em.d01.* .    
```

Edit [namelist.input](namelist.input)
```
vi namelist.input
```

Create [run_real.pbs](run_real.pbs) file to submit real job to queue (done from /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF/test/em_real)
```
vi run_real.pbs
```

Run real.exe
```
qsub run_real.pbs
```
should create wrfinput_d01 and wrfbdy_d01 files. It also creates rsl.out 00xx and rsl.error.0xx where the errors (if any) are stored. We can either remove them once the script ran or leave them there.


# WRF
Create [run_wrf.pbs](run_wrf.pbs) file to submit wrf job to queue (done from /LUSTRE/igarcia/models/WRF_4.1.3_withoutXIOS/WRF/test/em_real)
```
vi run_wrf.pbs
```

Run real.exe
```
qsub run_wrf.pbs 
```
Creates files: wrfout_d01_YYYY-MM-DD_HH:MM:SS
