#!/bin/ksh
#PBS -N GOLFO36-E02
#PBS -q memsup
##PBS -l nodes=10:ppn=28
#PBS -l nodes=2:ppn=28
#PBS -o golfo36E02.log
#PBS -e golfo36E02.error
###PBS -v NB_NPROC=200

set -u
set +x
date


. /usr/share/Modules/init/ksh
#module load intel/MPI2017
#module load intel/cdf-bundle2017

module load intel/MPI2018
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi

P_CTL_DIR=/LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/EXP00
cd $P_CTL_DIR

# Check correct environment in compute nodes
sort -u $PBS_NODEFILE > nodes.file
while read nline; do
  VAL=`ssh -q $nline "if grep -qs '/LUSTRE' /proc/mounts; then echo 'Mounted' ; else  echo 'FAIL' ; fi" < /dev/null`
  if [ $VAL == 'FAIL' ] ; then
    echo "Aborting : LUSTRE not mounted in $nline"
    exit 1
  else 
    echo "$nline LUSTRE: OK "
  fi
done < nodes.file
echo "/LUSTRE mounted in compute nodes - OK"
rm nodes.file
# End verification


#####export FORT_BUFFERED=false

#----------------------------------------------------------------------#
#       1. PATHNAME   AND  VARIABLES INITIALISATION                    #
#----------------------------------------------------------------------#

. ./includefile.ksh

#----------------------------------------------------------------------#
#       2. Some functions                                              #
#----------------------------------------------------------------------#

# remove old restart files from the working directory
clean_res() { \rm  $P_R_DIR/*.$1.tar.* ; }

rapatrie() { echo ${1:-none} | grep -iv none && { ln -sf  $2/$1 $3  || \
{ echo $1 not found anywhere ; exit ; } ; } ; }

rapatrie_res() { echo ${1:-none} | grep -iv none && { cp -f $2/$1 $3 || \
{ echo $1 not found anywhere ; exit ; } ; } ; }

# expatrie doas a mfput of file $1 on the directory $2, with filename $3
expatrie() { mv -f $1 $2/$3 ; }

# expatrie_res doas a mfput of file $1 on the directory $2, with filename $3; 
#copy $1 on local disk $4
expatrie_res() { eval mv $2/$1 $4/$3 ; }

# check existence and eventually create directory
chkdir() { if [ ! -d $1 ] ; then mkdir -p $1 ; fi ; }

# LookInNamelist returns the value of a variable in the namelist
#         example: aht0=$(LookInNamelist aht0 )
LookInNamelist()    { eval grep -e $1 namelist_cfg | tr -d \' | tr -d \"  | sed -e 's/=/  = /' | awk ' {if ( $1 == str ) print $3 }' str=$1 ; }

# Give the number of file containing $1 in its name
number_of_file() { ls -1 *$1* 2> /dev/null | wc -l  ; }


#----------------------------------------------------------------------#
#       2.Create appfile XIOS                                          #
#----------------------------------------------------------------------#

#runcode_mpmd() {

# build a task file in the local directory, according to input parameters.
# in the main script, prog1 is nemo, prog2 is xios. Using -m cyclic,
#force a bind by node, so it is  more clever to put xios first in the file in order to place XIOS on
#the first socket of various nodes.
#n1=$1
#n2=$3
#prog1=$2
#prog2=$4


#rm -f ./ztask_file.conf
#echo 0-$(( n2 - 1 )) " " $prog2 > ./ztask_file.conf
#echo ${n2}-$(( n1 + n2 -1 )) " " $prog1 >> ./ztask_file.conf
#task_file_name=./ztask_file.conf

#if [[ -x $task_file_name ]]
#then
#    echo "File '$task_file_name' is executable"
#else
#    echo "File '$task_file_name' is not executable"
#    chmod uog+rwx $task_file_name
#fi

#srun --mpi=pmi2 -m cyclic \
#srun --mpi=pmi2 -m cyclic \
#--cpu_bind=map_cpu:0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 \
#--multi-prog ./ztask_file.conf
#}

#rm -f app.conf
#for nn in $( seq 1 ${NXIOS} )
#  do
#    echo "1 ./xios_server.exe" >> app.conf
#    echo "15 ./opa" >> app.conf
#  done
#echo "$(( $NOCEAN - 15 * ${NXIOS} )) ./opa" >> app.conf

#----------------------------------------------------------------------#
#       3.Run                                                          #
#----------------------------------------------------------------------#
set -x 
echo Running on $( hostname )

## (1) get all the working tools on the TDIR directory
## -----------------------------------------------------

## CREATE TMP DIR associated to the run
  no=$( tail -1 $P_CTL_DIR/$CONFIG_CASE.db | awk '{print $1}' )
  TMPDIR=${TDIR}_${no}
  chkdir $TMPDIR
  cd $TMPDIR

## clean eventual (?) old files
  \rm -f OK
  \rm -f damping*

## copy the xml files
  #\cp -f ${P_CTL_DIR}/xmlio_server.def .
  \cp -f ${XIOS_DIR}/bin/xios_server.exe .
  \cp -f ${P_CTL_DIR}/context_nemo.xml .
  \cp -f ${P_CTL_DIR}/domain_def_nemo.xml .
  \cp -f ${P_CTL_DIR}/field_def_nemo-oce.xml .
  \cp -f ${P_CTL_DIR}/file_def_nemo-oce.xml .
  \cp -f ${P_CTL_DIR}/grid_def_nemo.xml .
  \cp -f ${P_CTL_DIR}/iodef.xml .

## copy the executable OPA
  \cp -f ${P_CTL_DIR}/nemo ./nemo.exe
#  \cp -f ${P_CTL_DIR}/appfile ./appfile
#  \cp -f ${P_CTL_DIR}/app.conf ./app.conf

## copy the AGRIF_FIXED_GRID file
 \cp $P_CTL_DIR/${AGRIF_FIXED_GRID} ./${OPA_AGRIF_FIXED_GRID}
 # number of zoom level (up to 3 levels)
 nzoom1=$( cat ${OPA_AGRIF_FIXED_GRID} | head -1 )
 nzoom2=$( cat ${OPA_AGRIF_FIXED_GRID} | head -3 | tail -1 )
 nzoom3=$( cat ${OPA_AGRIF_FIXED_GRID} | head -5 | tail -1 )
 nzoom4=$( cat ${OPA_AGRIF_FIXED_GRID} | head -7 | tail -1 )

  if [ $nzoom4 != 0 ] ; then 
    echo 'too many zoom level for this script !'
    exit 1
  fi 

 nzoom=$(( nzoom1 + nzoom2 + nzoom3  ))
 echo  Working with $nzoom level of zoom
  nref1=0 ; nref2=0; nref3=0 
  if [ $nzoom1 = 1 ] ; then nref1=$( cat ${OPA_AGRIF_FIXED_GRID} | head -2 | tail -1 | awk '{print $7}' ) ; fi
  if [ $nzoom2 = 1 ] ; then nref2=$( cat ${OPA_AGRIF_FIXED_GRID} | head -4 | tail -1 | awk '{print $7}' ) ; fi
  if [ $nzoom3 = 1 ] ; then ref3=$( cat ${OPA_AGRIF_FIXED_GRID} | head -6 | tail -1 | awk '{print $7}' ) ; fi

## copy of the control files ( .db and template namelist )
  \cp $P_CTL_DIR/$CONFIG_CASE.db .
  \cp $P_CTL_DIR/namelist_ref namelist_ref
  \cp $P_CTL_DIR/namelist_cfg namelist_cfg
  #\cp $P_CTL_DIR/namelist_top_ref namelist_top_ref
  #\cp $P_CTL_DIR/namelist_top_cfg namelist_top_cfg
  #\cp $P_CTL_DIR/namelist_ice_lim2.${CONFIG_CASE} namelist_ice
  n=1
  while [ n -le nzoom ] ; do 
   \cp $P_CTL_DIR/${n}_namelist_ref ${n}_namelist_ref
   \cp $P_CTL_DIR/${n}_namelist_cfg ${n}_namelist_cfg
   #\cp $P_CTL_DIR/${n}_namelist_top_ref ${n}_namelist_top_ref
   #\cp $P_CTL_DIR/${n}_namelist_top_cfg ${n}_namelist_top_cfg
   #\cp $P_CTL_DIR/${n}_namelist_ice_lim2.${CONFIG_CASE} ${n}_namelist_ice
   n=$(( n + 1 ))
  done


## (2) Set up the namelist for this run
## -------------------------------------
## exchange wildcards with the correc info from db
      no=$( tail -1 $CONFIG_CASE.db | awk '{print $1}' )
  nit000=$( tail -1 $CONFIG_CASE.db | awk '{print $2}' )
  nitend=$( tail -1 $CONFIG_CASE.db | awk '{print $3}' )

  sed -e "s/NUMERO_DE_RUN/$no/" \
    -e "s/CEXPER/$CONFIG_CASE/" \
    -e "s/NIT000/$nit000/" \
    -e "s/NITEND/$nitend/"  namelist_cfg > namelist1
  \cp namelist1 namelist_cfg

## check restart case
  if [ $no != 1 ] ; then
   sed -e "s/RESTART/true/" namelist_cfg > namelist1
  else
   sed -e "s/RESTART/false/" namelist_cfg > namelist1
  fi
  \cp namelist1 namelist_cfg

   nit01=$(( (nit000 -1 )*nref1 + 1 ))
   nite1=$(( nit01 -1  + ( nitend - nit000 +1 ) * nref1 ))

   nit02=$(( (nit01 -1 )*nref2 + 1 ))
   nite2=$(( nit02 -1 + ( nite1 - nit01 +1 ) * nref2 ))

   nit03=$(( (nit02 -1 )*nref3 + 1 ))
   nite3=$(( nit03 -1 + ( nite2 - nit02 +1 ) * nref3 ))

  if [ $nzoom1 = 1 ] ; then
     sed -e "s/NUMERO_DE_RUN/$no/" \
      -e "s/CEXPER/$CONFIG_CASE/" \
    -e "s/NIT000/$nit01/" \
    -e "s/NITEND/$nite1/"  1_namelist_cfg > namelist1
   \cp namelist1 1_namelist_cfg
  fi

  if [ $nzoom2 = 1 ] ; then
     sed -e "s/NUMERO_DE_RUN/$no/" \
      -e "s/CEXPER/$CONFIG_CASE/" \
    -e "s/NIT000/$nit02/" \
    -e "s/NITEND/$nite2/"  2_namelist_cfg > namelist1
   \cp namelist1 2_namelist_cfg
  fi

  n=1
  while [ n -le nzoom ] ; do
    if [ $no != 1 ] ; then
      sed -e "s/RESTART/true/" ${n}_namelist_cfg > namelist1
    else
      sed -e "s/RESTART/false/" ${n}_namelist_cfg > namelist1
    fi
    \cp namelist1  ${n}_namelist_cfg
    n=$(( n + 1 ))
  done

## restart tracer 
if [ $TRACER = 1 ];then
  if [ $no != 1 ] ; then
   sed -e "s/RESTART/true/" namelist_top_cfg > namelisttop1
  else
   sed -e "s/RESTART/false/" namelist_top_cfg > namelisttop1
  fi
  \cp namelisttop1 namelist_top_cfg
fi

## check that the run period is a multiple of the dump period 
  rdt=$(LookInNamelist rn_rdt)
  nwri=$(LookInNamelist nn_write)

  var=` echo 1 | awk "{ a=$nitend ; b=$nit000 ; c=$nwri ; nenr=(a-b+1)/c ; print nenr}"`
  vernenr=` echo 1 | awk "{ a=$var; c=int(a); print c}"`

  if [ $vernenr -ne  $var ] ; then
    echo 'WARNING: the run length is not a multiple of the dump period ...'
  fi

## place holder for time manager (eventually)
  if [ $no != 1 ] ; then
    ndastpdeb=`tail -2 $CONFIG_CASE.db | head -1 | awk '{print $4}' `
  else
    ndastpdeb=$(LookInNamelist nn_date0)
    echo $ndastpdeb
  fi

 year=$(( ndastpdeb / 10000 ))
 mmdd=$(( ndastpdeb - year * 10000 ))

if [ $mmdd = 1231 ] ; then
 year=$(( year + 1 ))
fi
year=$( printf "%04d" $year)

  rdt=$(LookInNamelist rn_rdt)
  rdt=`echo 1 | awk "{ rdt=int($rdt); print rdt}" `
  echo $rdt

  ndays=` echo 1 | awk "{ a=int( ($nitend - $nit000 +1)*$rdt /86400.) ; print a }" `


## (3) Look for input files
## ------------------------
prev_step=$(( $nit000 - 1 ))      # last time step of previous run 

## coordinates
  if [ $gr = 1 ] ; then
     rapatrie $DOMAIN $F_DTA_DIR $OPA_DOMAIN
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$COORDINATES $F_DTA_DIR ${n}_$OPA_COORDINATES
       n=$(( n + 1 ))
     done
  fi

## relaxation coefficient file # no relax on zoom
  if [ $REL = 1 ] ; then  rapatrie $RELAX $F_I_DIR $OPA_RELAX ; fi

## bottom friction file
  if [ $bfr = 1 ] ; then
    rapatrie $BFR $F_DTA_DIR $OPA_BFR
  fi

## geothermal heating
  if [ $geo = 1 ] ; then
    rapatrie $GEO  $F_DTA_DIR $OPA_GEO
  fi

## coeff 2d for ldfdyn
  if [ $COEF2D  = 1 ] ; then
    rapatrie $AHM2D   $F_DTA_DIR $OPA_AHM2D
  fi

## [3.2] : Initial conditions
## ============================

## temperature
  if [ $TEMP = 1 ] ; then 
     rapatrie $TEMPDTA  $F_DTA_DIR $OPA_TEMPDTA
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$TEMPDTA  $F_DTA_DIR ${n}_$OPA_TEMPDTA
       n=$(( n + 1 ))
     done
  fi

## salinity
  if [ $SAL = 1 ] ; then
     rapatrie $SALDTA  $F_DTA_DIR  $OPA_SALDTA
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$SALDTA  $F_DTA_DIR ${n}_$OPA_SALDTA
       n=$(( n + 1 ))
     done
  fi

## Ice initial condition only if no = 1
  if [ $ICE_INI = 1 -a $no -eq 1 ] ; then
    rapatrie $ICEINI   $F_DTA_DIR $OPA_ICEINI
  fi

## Ice damping 
  if [ $ICE = 1 ] ; then
     rapatrie $ICEDMP  $F_DTA_DIR  $OPA_ICEDMP
  fi

## [3.3] : Forcing fields
#  ======================

##  wind stress taux, tauy
  if [ $TAU = 1 ] ; then
     rapatrie $TAUX  $F_DTA_DIR $OPA_TAUX
     rapatrie $TAUY  $F_DTA_DIR $OPA_TAUY
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$TAUX  $F_DTA_DIR ${n}_$OPA_TAUX
       rapatrie ${n}_$TAUY  $F_DTA_DIR ${n}_$OPA_TAUY
       n=$(( n + 1 ))
     done
  fi

## fluxes or parameters for bulks formulae
  if [ $FLX = 1 ] ; then
     rapatrie "$EMP"  $F_DTA_DIR $OPA_EMP
     rapatrie "$QNET"  $F_DTA_DIR $OPA_QNET
     rapatrie "$QSR"  $F_DTA_DIR $OPA_QSR
     rapatrie "$RUNOFF"  $F_DTA_DIR $OPA_RUNOFF
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie "${n}_$EMP"  $F_DTA_DIR ${n}_$OPA_EMP
       rapatrie "${n}_$QNET"  $F_DTA_DIR ${n}_$OPA_QNET
       rapatrie "${n}_$QSR"  $F_DTA_DIR ${n}_$OPA_QSR
       n=$(( n + 1 ))
     done
  fi
## fluxes or parameters for CORE bulks formulae
if [ $FLXCORE = 1 ] ; then
  if [ $IOF = 1 ] ; then
   n=0
   while [ n -le 3 ] ; do
   yy=$(( year -1 + n ))
   if [ $yy -le 1978 ] ; then
   rapatrie ${PRECIP}_y1958-1978.nc $F_FOR_DIR/extension_1958-1978/precip/ ${PRECIP}_y${yy}.nc
   rapatrie ${SNOW}_y1958-1978.nc $F_FOR_DIR/extension_1958-1978/snow/ ${SNOW}_y${yy}.nc
   rapatrie ${SHORT_WAVE}_y1958-1978.nc $F_FOR_DIR/extension_1958-1978/radsw/ ${SHORT_WAVE}_y${yy}.nc
   rapatrie ${LONG_WAVE}_y1958-1978.nc $F_FOR_DIR/extension_1958-1978/radlw/ ${LONG_WAVE}_y${yy}.nc
   rapatrie ${U10}_y${yy}.nc $F_FOR_DIR/extension_1958-1978/u10/ ${U10}_y${yy}.nc
   rapatrie ${V10}_y${yy}.nc $F_FOR_DIR/extension_1958-1978/v10/ ${V10}_y${yy}.nc
   rapatrie ${HUMIDITY}_y${yy}.nc $F_FOR_DIR/extension_1958-1978/q2/ ${HUMIDITY}_y${yy}.nc
   rapatrie ${TAIR}_y${yy}.nc $F_FOR_DIR/extension_1958-1978/t2/ ${TAIR}_y${yy}.nc
   #rapatrie ${TCC}_y${yy}.nc $F_FOR_DIR/extension_1958-1978/${yy} ${TCC}_y${yy}.nc
   rapatrie ${SLP}_y1958-1978.nc $F_FOR_DIR/extension_1958-1978/slp/ ${SLP}_y${yy}.nc
   else
   rapatrie ${PRECIP}_y${yy}.nc $F_FOR_DIR/precip/ ${PRECIP}_y${yy}.nc
   rapatrie ${SNOW}_y${yy}.nc $F_FOR_DIR/snow/ ${SNOW}_y${yy}.nc
   rapatrie ${SHORT_WAVE}_y${yy}.nc $F_FOR_DIR/radsw/ ${SHORT_WAVE}_y${yy}.nc
   rapatrie ${LONG_WAVE}_y${yy}.nc $F_FOR_DIR/radlw/ ${LONG_WAVE}_y${yy}.nc
   rapatrie ${U10}_y${yy}.nc $F_FOR_DIR/u10/ ${U10}_y${yy}.nc
   rapatrie ${V10}_y${yy}.nc $F_FOR_DIR/v10/ ${V10}_y${yy}.nc
   rapatrie ${HUMIDITY}_y${yy}.nc $F_FOR_DIR/q2/ ${HUMIDITY}_y${yy}.nc
   rapatrie ${TAIR}_y${yy}.nc $F_FOR_DIR/t2/ ${TAIR}_y${yy}.nc
   rapatrie ${SLP}_y${yy}.nc $F_FOR_DIR/msl/ ${OPA_SLP}_y${yy}.nc
   #rapatrie msl_ERAinterim_y1980.nc /LUSTRE/FORCING/msl/ ${OPA_SLP}_y${yy}.nc
   #rapatrie ${RUNOFF}_${yy}.nc $RIV_DIR/ ${OPA_RUNOFF}_y${yy}.nc
   #rapatrie ${TCC}_y${yy}.nc $F_FOR_DIR/${yy} ${TCC}_y${yy}.nc
   fi
   #
   if [ $CYCLONES = 1 ] ; then
     rapatrie ${U10}_y${yy}.nc $F_FOR_DIR_CYCLONES/u10/ ${U10}_y${yy}.nc
     rapatrie ${V10}_y${yy}.nc $F_FOR_DIR_CYCLONES/v10/ ${V10}_y${yy}.nc
     rapatrie tc_track_y${yy}.nc $TC_TRACKS_DIR/ tc_track_y${yy}.nc
   fi
   #
   n=$(( n + 1 ))
   done #while

   # Weights 
   rapatrie $W_BC_ERA  $F_DTA_DIR $OPA_W_BC_ERA
   rapatrie $W_BL_ERA  $F_DTA_DIR $OPA_W_BL_ERA
   n=1
   while [ n -le nzoom ] ; do 
   rapatrie "${n}_$W_BC_ERA"  $F_DTA_DIR ${n}_$OPA_W_BC_ERA
   rapatrie "${n}_$W_BL_ERA"  $F_DTA_DIR ${n}_$OPA_W_BL_ERA
   n=$(( n + 1 ))
   done
  fi
fi

## SSS files
  if [ $SSS = 1 ] ; then
    # nom can be computed to fit the year we need ...
   rapatrie $SSSDTA  $F_DTA_DIR $OPA_SSSDTA
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$SSSDTA  $F_DTA_DIR ${n}_$OPA_SSSDTA
       n=$(( n + 1 ))
     done
  fi


if [ $ROFF = 1 ] ; then
 # climatological
  ### TRICK BECAUSE REQUIRE CLIM FILE WEHN USING INTERANNUAL RUNOFF
    rapatrie ${RUNOFF}_${year}.nc   $RIV_DIR $OPA_RUNOFF.nc
    rapatrie ${RODEPTH}   $RIV_DIR $OPA_RODEPTH
 # interannual runoff
 n=0
    while [ n -le 3 ] ; do
     yy=$(( year -1 + n ))
     rapatrie ${RUNOFF}_${yy}.nc $RIV_DIR/ ${OPA_RUNOFF}_y${yy}.nc
     n=$(( n + 1 ))
    done #while
 fi

## SST files
  if [ $SST = 1 ] ; then
     # nom can be computed to fit the year we need ...
    rapatrie $SSTDTA  $F_DTA_DIR $OPA_SSTDTA
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$SSTDTA  $F_DTA_DIR ${n}_$OPA_SSTDTA
       n=$(( n + 1 ))
     done
  fi

## Feedback term file (fbt)
  if [ $FBT = 1 ] ; then
     rapatrie $FBTDTA  $F_DTA_DIR $OPA_FBTDTA
     n=1
     while [ n -le nzoom ] ; do 
       rapatrie ${n}_$FBTDTA  $F_DTA_DIR ${n}_$OPA_FBTDTA
       n=$(( n + 1 ))
     done
  fi

## Open boundaries files
  if [ $OBC = 1 ] ;  then
    n=0
    while [ n -le 1 ] ; do
    yy=$((year  + n))
     rapatrie ${OBC_NORTH}_TS_y${yy}m00.nc $F_OBC_DIR ${OPA_OBC_NORTH}_TS_y${yy}m00.nc
     rapatrie ${OBC_NORTH}_U_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_NORTH}_U_y${yy}m00.nc
     rapatrie ${OBC_NORTH}_V_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_NORTH}_V_y${yy}m00.nc
     rapatrie ${OBC_SOUTH}_TS_y${yy}m00.nc $F_OBC_DIR ${OPA_OBC_SOUTH}_TS_y${yy}m00.nc
     rapatrie ${OBC_SOUTH}_U_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_SOUTH}_U_y${yy}m00.nc
     rapatrie ${OBC_SOUTH}_V_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_SOUTH}_V_y${yy}m00.nc
     #rapatrie ${OBC_WEST}_TS_y${yy}m00.nc $F_OBC_DIR ${OPA_OBC_WEST}_TS_y${yy}m00.nc
     #rapatrie ${OBC_WEST}_U_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_WEST}_U_y${yy}m00.nc
     #rapatrie ${OBC_WEST}_V_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_WEST}_V_y${yy}m00.nc
     #rapatrie ${OBC_EAST}_TS_y${yy}m00.nc $F_OBC_DIR ${OPA_OBC_EAST}_TS_y${yy}m00.nc
     #rapatrie ${OBC_EAST}_U_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_EAST}_U_y${yy}m00.nc
     #rapatrie ${OBC_EAST}_V_y${yy}m00.nc  $F_OBC_DIR ${OPA_OBC_EAST}_V_y${yy}m00.nc
    n=$(( n + 1 ))
    done
  fi

## Open boundaries files
  if [ $OBC_CLIM = 1 ] ;  then
     rapatrie ${OBC_NORTH}_TS_y1980-2004.nc $F_OBC_DIR obcnorth_TS.nc
     rapatrie ${OBC_NORTH}_U_y1980-2004.nc  $F_OBC_DIR obcnorth_U.nc
     rapatrie ${OBC_NORTH}_V_y1980-2004.nc  $F_OBC_DIR obcnorth_V.nc
     rapatrie ${OBC_SOUTH}_TS_y1980-2004.nc $F_OBC_DIR obcsouth_TS.nc
     rapatrie ${OBC_SOUTH}_U_y1980-2004.nc  $F_OBC_DIR obcsouth_U.nc
     rapatrie ${OBC_SOUTH}_V_y1980-2004.nc  $F_OBC_DIR obcsouth_V.nc
  fi

## BDY files
  if [ $BDY = 1 ] ;  then
    n=0
    while [ n -le 2 ] ; do
    yy=$((year -1  + n))
    if [ $yy -le 1992 ] ; then   
     rapatrie ${BDY_COORD}  $F_BDY_DIR ${OPA_BDY_COORD}
     rapatrie ${BDY_TRA}_mean.nc $F_BDY_DIR ${OPA_BDY_TRA}_y${yy}.nc
     rapatrie ${BDY_TU2D}_mean.nc $F_BDY_DIR ${OPA_BDY_TU2D}_y${yy}.nc
     rapatrie ${BDY_UU2D}_mean.nc $F_BDY_DIR ${OPA_BDY_UU2D}_y${yy}.nc
     rapatrie ${BDY_VU2D}_mean.nc $F_BDY_DIR ${OPA_BDY_VU2D}_y${yy}.nc
     rapatrie ${BDY_UU3D}_mean.nc $F_BDY_DIR ${OPA_BDY_UU3D}_y${yy}.nc
     rapatrie ${BDY_VU3D}_mean.nc $F_BDY_DIR ${OPA_BDY_VU3D}_y${yy}.nc
    else
     rapatrie ${BDY_COORD}  $F_BDY_DIR ${OPA_BDY_COORD}
     rapatrie ${BDY_TRA}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_TRA}_y${yy}.nc
     rapatrie ${BDY_TU2D}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_TU2D}_y${yy}.nc
     rapatrie ${BDY_UU2D}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_UU2D}_y${yy}.nc
     rapatrie ${BDY_VU2D}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_VU2D}_y${yy}.nc
     rapatrie ${BDY_UU3D}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_UU3D}_y${yy}.nc
     rapatrie ${BDY_VU3D}_y${yy}.nc $F_BDY_DIR ${OPA_BDY_VU3D}_y${yy}.nc
    fi
    n=$(( n + 1 ))
   done
  fi

  if [ $BDYTIDE = 1 ] ;  then
     ln -sf $F_BDY_DIR/*bdytide*nc .    
  fi

## [3.4] : restart files
#  ======================
prev_ext=$(( $no - 1 ))      # file extension of previous run
## model restarts
#  if [ $no -eq  1 ] ; then
 #   # clear olds files in case on a brand new run ..
 #   rm -f $P_R_DIR/islands.nc
 #   rm -f islands.nc
 # else
 #   for rest in  `ls $F_R_DIR/RESTART_OCE_${prev_ext} ` ; do 
 #     rapatrie_res $rest  ${F_R_DIR}/RESTART_OCE_${prev_ext}  $rest
 #   done
 #   # remove the prev_ext from the name file
 #   for rest in *restart_????.dimg.$prev_ext ; do
 #     mv $rest ${rest%.$prev_ext}
 #   done
 #  fi

## model restarts
  if [ $no -eq  1 ] ; then
    # clear olds files in case on a brand new run ..
    #rm -f $P_R_DIR/islands.nc
    rm -f islands.nc
  else
    #
    # General restarts
    #
    f=$(ls $F_R_DIR/${CONFIG_CASE}*${prev_step}*restart.nc)
    rest=$(basename $f)
    rapatrie_res $rest  ${F_R_DIR}/ restart.nc 
    n=1
    while [ n -le nzoom ] ; do
      if [ $n = 1 ] ; then
        tmp_prev_step=$(( $nit01 - 1 ))
      fi
      if [ $n = 2 ] ; then
        tmp_prev_step=$(( $nit02 - 1 ))
      fi
      f=$F_R_DIR/${CONFIG_CASE}*${tmp_prev_step}*restart.nc       
      rest=$(basename $f)
      rapatrie ${n}_$rest  $F_R_DIR/ ${n}_restart.nc
      n=$(( n + 1 ))
    done
    #
    if [ $ICE = 1 ]; then
     f=$(ls $F_R_DIR/*${CONFIG_CASE}*${prev_step}*restart_ice.nc)
     rest=$(basename $f)
     rapatrie_res $rest  ${F_R_DIR}/ restart_ice_in.nc
    fi
    if [ $TRACER = 1 ];then
      f=$(ls $F_R_DIR/*${CONFIG_CASE}*${prev_step}*restart_trc.nc)
      rest=$(basename $f)
      rapatrie_res $rest  ${F_R_DIR}/ restart_trc.nc
    fi
    #
    # remove the prev_ext from the name file
    #for rest in $CONFIG_CASE*restart_????.* ; do
    #nrestfile=$( echo $rest | sed -e 's/_/ /g' |awk '{print $4}' )
    #mv $rest restart_$nrestfile
    #done   
    #n=1
    #while [ n -le nzoom ] ; do
    #for rest in ${n}_$CONFIG_CASE*restart_????.* ; do
    #nrestfile=$( echo $rest | sed -e 's/_/ /g' | awk '{print $5}' )
    #mv $rest 1_restart_$nrestfile
    #done
    #n=$(( n + 1 ))
    #done
    #
    #
    if [ $OBC_CLIM = 1 ] ; then
     rapatrie_res restart.obc.output.${prev_ext}  ${F_R_DIR}/ restart.obc
    fi

fi




pwd
## (4) Run the code
## ----------------
  date
  pwd

#%%%%%%%%%%%%%%%%%%%%   INTEL 2013 %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
#  NP=$(cat $PBS_NODEFILE | wc -l)
#  sort -u $PBS_NODEFILE > nodes.file
#  NN=$(cat nodes.file | wc -l)

#  echo "NUMERO DE CORES" $NP
#  mpdboot -n $NN -r ssh -f nodes.file

#  # xios process per node
#  NPPNXIOS=1      
#  # opa process per node  
#  NPPNOCEAN=19
#
#  xiosexecparam=
#
#  while read line
#  do
#    if [ "$xiosexecparam" == "" ]; then
#      xiosexecparam=" -n $NPPNXIOS -host $line -env I_MPI_DEVICE rdssm -env I_MPI_EXTRA_FILESYSTEM on -env I_MPI_EXTRA_FILESYSTEM_LIST lustre ./xios_server.exe "
#      oceanexecparam=" -n $NPPNOCEAN -host $line -env I_MPI_DEVICE rdssm  ./opa "
#    else
#      xiosexecparam="$xiosexecparam: -n $NPPNXIOS -host $line -env I_MPI_DEVICE rdssm -env I_MPI_EXTRA_FILESYSTEM on -env I_MPI_EXTRA_FILESYSTEM_LIST lustre ./xios_server.exe "
#      oceanexecparam="$oceanexecparam: -n $NPPNOCEAN -host $line -env I_MPI_DEVICE rdssm ./opa "
#    fi
#  done < "nodes.file"
#
#  mpiexec $oceanexecparam : $xiosexecparam
#  
#  mpdallexit  

  #mpirun ./opa -ppn 19 -n $NOCEAN : ./xios_server.exe -ppn 1 -n $NXIOS 
  #mpirun -np 190 ./opa : -np 10  ./xios_server.exe
  #mpirun -np 190 ./opa 
  #mpirun ./opa -ppn 20 -n 200 

  # export I_MPI_DEBUG=100 



  #xios process per node
  NPPNXIOS=1      
  NPPNOCEAN=27


  #NPPNXIOS=1      
  #NPPNOCEAN=19

  NP=$(cat $PBS_NODEFILE | wc -l)
  sort -u $PBS_NODEFILE > nodes.file
  NN=$(cat nodes.file | wc -l)
  echo "NUMERO DE CORES" $NP

  xiosexecparam=

  while read line
  do
    if [ "$xiosexecparam" == "" ]; then
      xiosexecparam=" -n $NPPNXIOS -host $line ./xios_server.exe "
      oceanexecparam=" -n $NPPNOCEAN -host $line  ./nemo.exe "
    else
      xiosexecparam="$xiosexecparam: -n $NPPNXIOS -host $line  ./xios_server.exe "
      oceanexecparam="$oceanexecparam: -n $NPPNOCEAN -host $line  ./nemo.exe "
    fi
  done < "nodes.file"

  mpirun $oceanexecparam : $xiosexecparam
 

#----------------------------------------------------------------------#
#       5. Post processing of the run                                  #
#----------------------------------------------------------------------#

## [5.1] check the status of the run
## ---------------------------------

# touch OK file if the run finished OK
if [ "$(tail -30 ocean.output | egrep AAAA )" = 'AAAAAAAA' ] ; then touch OK ; fi

## [5.2] Update the CONFIG_CASE.db file, if the run is OK
## ------------------------------------------------------
  if [ -f OK ]  ; then
     DIR=``
     echo "Run OK"
     no=$(( $no + 1 ))

     # add last date at the current line
     nline=$(wc $CONFIG_CASE.db | awk '{print $1}')

     # aammdd is the ndastp of the last day of the run ...
     # where can we get it ???? : in the ocean.output for sure !!
    aammdd=$( tail -10 ocean.output | grep 'run stop' | awk '{print $NF}'  )

    ncol=0
    while [ $ncol -eq 0 ] ; do
      last=$( tail -1 $CONFIG_CASE.db )
      ncol=$( echo $last | wc | awk '{ print $2 }' )
      nline=$(( $nline - 1 ))
    done

    if [ $ncol -eq  3 ] ; then
      sed -e "s/$last/$last\ $aammdd/" $CONFIG_CASE.db > tmpdb
      mv -f tmpdb $CONFIG_CASE.db
    else
      echo fichier db deja a jour de la date $ncol
    fi

    # add a new last line for the next run
    nstep_per_day=$(( 86400 / $rdt ))
   
   # Monthly increment with leap years 
   aa=$(( aammdd / 10000 ))
   mm=$(( (aammdd - aa * 10000)/100 ))
   dif=$(cal $(date -d "${aa}-${mm}-01 1 month" +"%m %Y")  | awk 'NF {DAYS = $NF}; END {print DAYS}') 
   dif=$((  $dif * $nstep_per_day ))

   # Regualr increment 
   # dif=$((  $nitend - $nit000  + 1  ))

    nit000=$(( nitend + 1 ))
    nitend=$(( nitend + dif ))

    if [ -f newdb ] ; then
      line=$( cat newdb )
      echo $line >> $CONFIG_CASE.db
    else
      echo $no $nit000 $nitend >> $CONFIG_CASE.db
    fi
   fi

    cat $CONFIG_CASE.db
    \cp $CONFIG_CASE.db $P_CTL_DIR/

  if [ -f OK ] ;  then
     ext=$(( $no - 1 ))
  fi

## [5.3] Write number of domains (used in rebuild script) 
## ------------------------------------------------------
#echo ${BRIDGE_MPRUN_NPROC} >> nproc.out


## [5.4] Submit the rebuild script 
## ------------------------------------------------------
date
if [ -f OK ] ; then
 ssh -T chaman " cd $P_CTL_DIR ;  qsub save_nemo.ksh; "
fi

exit
