# Run NEMO
```
cd /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/EXP00
```

Once the cfg is succesfully duplicated, edit: [run_nemo.ksh](run_nemo.ksh), [includefile.ksh](includefile.ksh), [namelist_cfg](namelist_cfg), [save_nemo.ksh](save_nemo.ksh) and [GOLFO36-E01.db](GOLFO36-E01.db)  
```
vi run_nemo.ksh
vi includefile.ksh
vi namelist_cfg
vi save_nemo.ksh
mv GOLFO36-E01.db GOLFO36-E02.db 
vi GOLFO36-E02.db
```

Note: if the number of cores is changed, the new value must coincide with the one set on run_nemo.ksh (line 06) and the one in includefile.ksh (lines 42 & 43).

Run [run_nemo.ksh](run_nemo.ksh):
```
qsub run_nemo.ksh 
```
