#!/bin/ksh

MAXSUB=120
TRDTRA=0
TRDDYN=0
BATHY=1
BAT=1
TEMP=1
SAL=1
SSS=0
SST=0
ROFF=1
TAU=0
REL=0
BDY=1
BDYTIDE=1
OBC=0
OBC_CLIM=0
MOOR=1
FBT=0
FLX=0
FLXCORE=1
ICE=0
ICE_INI=0
IA=0
MESH=0
gr=1
bfr=0
geo=0
COEF2D=0
TRACER=0
IOF=1     # interpolation on the fly 
MLD=0     # mixed layer diags
TRD=0     # temp trends diags
SPECIALWINDS=0
RESCDF=1
TRDVOR=0
CYCLONES=0

#NOCEAN=135
#NXIOS=5
NOCEAN=52
NXIOS=4

CONFIG=GOLFO36
CASE=E02
SDIR=/LUSTRE/igarcia/outputs/NEMO_4.0_uncoupled
P_CTL_DIR=/LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/EXP00

CONFIG_CASE=${CONFIG}-${CASE}
TDIR=/LUSTRE/igarcia/tmp/$CONFIG_CASE
F_S_DIR=${SDIR}/${CONFIG_CASE}-S
F_R_DIR=${SDIR}/${CONFIG_CASE}-R
F_I_DIR=/LUSTRE/fandrade/STOCK/NEMO4/GOLFO36-I
TOOLS_DIR=/LUSTRE/igarcia/models/NEMO_4.0_uncoupled/tools/
XIOS_DIR=/LUSTRE/igarcia/models/XIOS_2.5_withoutOASIS/
RIV_DIR=$F_I_DIR/runoff_ISBA

F_DTA_DIR=/LUSTRE/fandrade/STOCK/NEMO4/GOLFO36-I
F_BDY_DIR=/LUSTRE/fandrade/STOCK/NEMO4/GOLFO36-I/BDY_GLORYS12_RIM1/
F_FOR_DIR=/LUSTRE/FORCING/DFS5.2/

# Cyclones
F_FOR_DIR_CYCLONES=LUSTRE/jouanno/FORCING/DFS5.2_WIND_TC_RMEAN11DAYS/
TC_TRACKS_DIR=/LUSTRE/jouanno/FORCING/tc_tracks_1958-2012/

# set specific file names (data )                     ;   and their name in OPA9       
#----------------------------------------------------------------------------------

AGRIF_FIXED_GRID=AGRIF_FixedGrids.in      ; OPA_AGRIF_FIXED_GRID=AGRIF_FixedGrids.in

DOMAIN=GOLFO36_domain_cfg.nc ; OPA_DOMAIN=domain_cfg.nc
TEMPDTA=init_GOLFO36_y2006m01d01_glorys12_T.nc ; OPA_TEMPDTA=data_1m_potential_temperature_nomask.nc
SALDTA=init_GOLFO36_y2006m01d01_glorys12_S.nc; OPA_SALDTA=data_1m_salinity_nomask.nc
SSSDTA=init_GOLFO36_y2006m01d01_glorys12_S.nc        ; OPA_SSSDTA=sss_data.nc
RUNOFF=GOLFO36_runoffISBA         ; OPA_RUNOFF=runoff_1m_nomask
RODEPTH=GOLFO36_rodepth.nc   ; OPA_RODEPTH=rodepth.nc

if [ $IOF = 1 ] ; then
W_BC_ERA=weights_DFS5.2_golfo36_bicub.nc         ; OPA_W_BC_ERA=weights_bicubic.nc
W_BL_ERA=weights_DFS5.2_golfo36_bilin.nc           ; OPA_W_BL_ERA=weights_bilin.nc

1_W_BC_ERA=1_weights_DFS5.2_golfo36_bicub.nc         ; 1_OPA_W_BC_ERA=1_weight_bicubic.nc
1_W_BL_ERA=1_weights_DFS5.2_golfo36_bilin.nc           ; 1_OPA_W_BL_ERA=1_weight_bilin.nc

2_W_BC_ERA=2_weights_DFS5.2_golfo36_bicub.nc         ; 2_OPA_W_BC_ERA=2_weight_bicubic.nc
2_W_BL_ERA=2_weights_DFS5.2_golfo36_bilin.nc           ; 2_OPA_W_BL_ERA=2_weight_bilin.nc

PRECIP=drowned_precip_DFS5.2                   ; OPA_PRECIP=precip
SNOW=drowned_snow_DFS5.2                   ; OPA_SNOW=snow
SHORT_WAVE=drowned_radsw_DFS5.2                   ; OPA_SHORT_WAVE=radsw
LONG_WAVE=drowned_radlw_DFS5.2                       ; OPA_LONG_WAVE=radlw
U10=drowned_u10_DFS5.2                        ; OPA_U10=u10
V10=drowned_v10_DFS5.2                             ; OPA_V10=v10
TAUX=sozotaux_TROP04E18                                       ; OPA_TAUX=sozotaux_1m
TAUY=sometauy_TROP04E18                                       ; OPA_TAUY=sometauy_1m
HUMIDITY=drowned_q2_DFS5.2                        ; OPA_HUMIDITY=q2
TAIR=drowned_t2_DFS5.2                            ; OPA_TAIR=t2
TCC=drowned_tcc_DFS5.2                            ; OPA_TCC=tcc
SLP=msl_ERAinterim                        ; OPA_SLP=drowned_msl_DFS5.2
fi

if [ $BDY = 1 ] ; then
   BDY_COORD=coordinates.bdy_GOLFO36.nc  ; OPA_BDY_COORD=bdy_coordinates.nc
   BDY_TRA=bdyT_tra_GOLFO36              ; OPA_BDY_TRA=bdyT_tra 
   BDY_TU2D=bdyT_u2d_GOLFO36              ; OPA_BDY_TU2D=bdyT_u2d 
   BDY_UU2D=bdyU_u2d_GOLFO36              ; OPA_BDY_UU2D=bdyU_u2d 
   BDY_VU2D=bdyV_u2d_GOLFO36              ; OPA_BDY_VU2D=bdyV_u2d 
   BDY_UU3D=bdyU_u3d_GOLFO36              ; OPA_BDY_UU3D=bdyU_u3d 
   BDY_VU3D=bdyV_u3d_GOLFO36              ; OPA_BDY_VU3D=bdyV_u3d 
fi


