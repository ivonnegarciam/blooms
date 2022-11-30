Create a new experiment from a previos one. Say, for instance, that we want to run another simulation using the same configuration but with different dates.

## Copy EXP00 to EXP01:
```
 cd /LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/
 ```

## 0) Make sure that all input files (corresponding to the sim period) are ready to be read by NEMO, that includes:    
```
    - initial conditions (it seems this includes these and other similar OPA files):
        F_DTA_DIR=/LUSTRE/igarcia/stock/NEMO_4.0/GOLFO36-I      
            init_GOLFO36_y2006m01d01_glorys12_S.nc  # Salinity & SSH
            init_GOLFO36_y2006m01d01_glorys12_T.nc  # Temperature 
            weights_DFS5.2_golfo36_bicub.nc # not sure they are IC
            weights_DFS5.2_golfo36_bilin.nc 
            
    - boundary conditions:
        F_BDY_DIR=/LUSTRE/igarcia/stock/NEMO_4.0/GOLFO36-I/BDY_GLORYS12_RIM1
            BDY_COORD=coordinates.bdy_GOLFO36.nc  ; OPA_BDY_COORD=bdy_coordinates.nc
            BDY_TRA=bdyT_tra_GOLFO36              ; OPA_BDY_TRA=bdyT_tra 
            BDY_TU2D=bdyT_u2d_GOLFO36              ; OPA_BDY_TU2D=bdyT_u2d 
            BDY_UU2D=bdyU_u2d_GOLFO36              ; OPA_BDY_UU2D=bdyU_u2d 
            BDY_VU2D=bdyV_u2d_GOLFO36              ; OPA_BDY_VU2D=bdyV_u2d 
            BDY_UU3D=bdyU_u3d_GOLFO36              ; OPA_BDY_UU3D=bdyU_u3d 
            BDY_VU3D=bdyV_u3d_GOLFO36              ; OPA_BDY_VU3D=bdyV_u3d
    
    - forcings:
        F_FOR_DIR=/LUSTRE/FORCING/DFS5.2/
            PRECIP=drowned_precip_DFS5.2               ; OPA_PRECIP=precip
            SNOW=drowned_snow_DFS5.2                   ; OPA_SNOW=snow
            SHORT_WAVE=drowned_radsw_DFS5.2            ; OPA_SHORT_WAVE=radsw
            LONG_WAVE=drowned_radlw_DFS5.2             ; OPA_LONG_WAVE=radlw
            U10=drowned_u10_DFS5.2                     ; OPA_U10=u10
            V10=drowned_v10_DFS5.2                     ; OPA_V10=v10
            TAUX=sozotaux_TROP04E18                    ; OPA_TAUX=sozotaux_1m
            TAUY=sometauy_TROP04E18                    ; OPA_TAUY=sometauy_1m
            HUMIDITY=drowned_q2_DFS5.2                 ; OPA_HUMIDITY=q2
            TAIR=drowned_t2_DFS5.2                     ; OPA_TAIR=t2
            TCC=drowned_tcc_DFS5.2                     ; OPA_TCC=tcc
            SLP=msl_ERAinterim                         ; OPA_SLP=drowned_msl_DFS5.2
        RIV_DIR=$F_I_DIR/runoff_ISBA
            GOLFO36_runoffISBA
        

    - static & other fields:     
        F_DTA_DIR=/LUSTRE/igarcia/stock/NEMO_4.0/GOLFO36-I
            GOLFO36_domain_cfg.nc
            #GOLFO36_rodepth.nc # I don't have it but it seems to run ok without it.
```            
    
## 1) Cp the whole EXP00 folder
```
cp -r ./EXP00 ./EXP01
```
    
## 2) Modify date (& other desired change) in namelist in /EXP01/:
```
cd EXP01
vi namelist_cfg 
```
--> nndate0 =  20161001 (l27)
--> rn_vfac = 0. # 0 for abs wind, 1 for rel wind, 0.5 for half the rel wind. (l118)
        
## 3) Modify run_nemo.ksh
 ```
 vi run_nemo.ksh 
 ```
 --> replace EXP00 with EXP01 in P_CTL_DIR = /LUSTRE...  
 --> PBS -l nodes=10:ppn=28   # This number should match the one in the includefile.ksh
    
## 4) Modify includefile.ksh    
```
vi includefile.ksh
```
--> replace EXP00 with EXP01 in P_CTL_DIR = /LUSTRE...  (l48)
--> mv 3 filenames from old to new date (eg: 2006m01d01 --> 2016m10d01)
--> NOCEAN=270, NXIOS=10 # l 42&43 has to match the num of nodes in run_nemo.ksh
        
## 5) Modify save_nemo.ksh
```
vi save_nemo.ksh
```
--> replace EXP00 with EXP01 in P_CTL_DIR = /LUSTRE...  (l09)
        
## 6) mkdir R & S (Restart & Salidas) dirs. 
As of now, I have to rename the previos folder with the same cfg name to include the EXP00 bit. *This should no loger be necessary when the folder name includes the EXP number.
```
mv /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E03-R /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E03-R-EXP01
mv /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E03-S /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E03-S-EXP01
mkdir /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E02-R # EXP01-R 
mkdir /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/GOLFO36-E02-S # EXP01-S
```
Note 1: I haven't yet manage to succesfully include the "EXP01" part in the folder name (it also has to be changed in other files, but it seems worth trying as I'll probaby be running various simulations from the same config file)
Note 2: Restart files are not moved to the /LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled/$config_name-R folder. Check why.
```
mv /LUSTRE/igarcia/tmp/GOLFO36-E03_1 /LUSTRE/igarcia/tmp/GOLFO36-E03_1_EXP01
mv /LUSTRE/igarcia/tmp/GOLFO36-E03_2 /LUSTRE/igarcia/tmp/GOLFO36-E03_2_EXP01
```

## 7) Check the GOLFO36-E01.db
For 1mon-cold start sim it should only contain 3 columns (1 1 17856):
```
more GOLFO36-E01.db 
```

## 8) Run NEMO
```
qsub run_nemo.ksh  
```
    
