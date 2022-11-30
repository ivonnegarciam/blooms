#!/bin/ksh
#PBS -N GOLFO36-E02-save
#PBS -l nodes=1:ppn=1
#PBS -o golfo36E02-save.log
#PBS -e golfo36E02-save.error
#PBS -v NB_NPROC=1
set -x 

P_CTL_DIR=/LUSTRE/igarcia/models/NEMO_4.0_uncoupled/cfgs/GOLFO36-E02/EXP00
cd $P_CTL_DIR


module load intel/MPI2018
module load spack
module load netcdf-c-4.7.0-intel-18.0.1-vtkbioo
module load netcdf-fortran-4.4.4-intel-18.0.1-zhe2pvi



#----------------------------------------------------------------------#
#       1. Path and variable initialization                            #
#----------------------------------------------------------------------#

. ./includefile.ksh

#----------------------------------------------------------------------#
#       2. Some functions                                              #
#----------------------------------------------------------------------#

# remove old restart files from the working directory
clean_res() { \rm  $P_R_DIR/*.$1.tar.* ; }

rapatrie() { echo ${1:-none} | grep -iv none && { ln -sf  $2/$1 $3 || \
{ echo $1 not found anywhere ; exit ; } ; } ; }

rapatrie_res() { echo ${1:-none} | grep -iv none && { cp -sf $2/$1 $3 || \
{ echo $1 not found anywhere ; exit ; } ; } ; }

# expatrie doas a mfput of file $1 on the directory $2, with filename $3
expatrie() { mv -f $1 $2/$3 ; }

# expatrie_res doas a mfput of file $1 on the directory $2, with filename $3; copy $1 on local disk $4
expatrie_res() { eval mv $2/$1 $4/$3 ; }

# check existence and eventually create directory
chkdir() { if [ ! -d $1 ] ; then mkdir -p $1 ; fi ; }

# LookInNamelist returns the value of a variable in the namelist
#         example: aht0=$(LookInNamelist aht0 )
LookInNamelist()    { eval grep -e $1 namelist_cfg | tr -d \' | tr -d \"  | sed -e 's/=/  = /' | awk ' {if ( $1 == str ) print $3 }' str=$1 ; }

# Give the number of file containing $1 in its name
number_of_file() { ls -1 *$1* 2> /dev/null | wc -l  ; }

#----------------------------------------------------------------------#
#       3. Rebuild                                                     #
#----------------------------------------------------------------------#

## 3.1 retrieve no and extension and go to TDIR ## --------------------------------------------

no=$( tail -1 $CONFIG_CASE.db | awk '{print $1}' )
ext=$(( $no - 1 ))
TMPDIR=${TDIR}_${ext}
cd ${TMPDIR}

#nproc=$( tail -2 appfile | head -1 | awk '{print $1}')
nproc=$NOCEAN

## 3.2 Rebuild restart files 
# ---------------------------------------  
if [ -f OK ] ; then
 echo Rebuild the files
 
  cp ${TOOLS_DIR}/REBUILD_NEMO/rebuild_nemo* .

  FILES_REB="*restart*_0000.nc"
  for file in ${FILES_REB}; do
     #time ./rebuild_nemo  ${file%_*} ${BRIDGE_MPRUN_NPROC} 
     ./rebuild_nemo  ${file%_*} $nproc 
  done
fi

## 3.3 Send the restart files
# -----------------------------  
chkdir ${F_R_DIR}

#\rm restart.nc restart_tra1.nc restart_tra2.nc

for f in *${CONFIG_CASE}*restart.nc ; do
   expatrie_res $f ${TMPDIR} $f ${F_R_DIR}/
done

if [ $ICE = 1 ];then
 for f in *${CONFIG_CASE}*restart_ice.nc ; do
   expatrie_res $f ${TMPDIR} $f ${F_R_DIR}/
done
fi

if [ $TRACER = 1 ];then
 for f in *${CONFIG_CASE}*restart_trc.nc ; do
   expatrie_res $f ${TMPDIR} $f ${F_R_DIR}/
done
fi



if [ $OBC_CLIM = 1 ] ;then
 expatrie_res restart.obc.output  ${TMPDIR}  restart.obc.output.${ext} ${F_R_DIR}/
fi


#if [ $TRDTRA = 1 ] ; then
#   for f in *${CONFIG_CASE}*restart_tra?.nc ; do
#    expatrie_res $f ${TMPDIR} $f ${F_R_DIR}/
#   done
#fi

# 3.4 Resubmit the job now
#-------------------------
cd $P_CTL_DIR
TESTSUB=$( wc $CONFIG_CASE.db | awk '{print $1}' )
if [ $TESTSUB -le  $MAXSUB ] ; then
      ssh -T chaman " cd $P_CTL_DIR ;  qsub run_nemo.ksh; "
else
     echo Maximum auto re-submit reached.
     ssh -T chaman " cd NEW_CTL_DIR ;  qsub run_nemo.ksh; "
fi
cd $TMPDIR

## 3.5 Rebuild the output files 
# ----------------------------
if [ -f OK ] ; then
  echo Rebuild the files
#  FILES_REB="*${CONFIG_CASE}_*_0000.nc"
#  for file in ${FILES_REB}; do
     #time ./rebuild_nemo  ${file%_*} ${BRIDGE_MPRUN_NPROC} 
#     ./rebuild_nemo  ${file%_*} $nproc
#  done
  if [ -f mesh_mask_0000.nc ] ; then
    ./rebuild_nemo  mesh_mask $nproc
  fi
fi

## 3.6 Send the output files 
# ----------------------------
chkdir $F_S_DIR

for f in *${CONFIG_CASE}_*_grid_*.nc   ; do
    #ncks -O -4 -L 3 $f $f 
    mv $f $F_S_DIR/
done
#

if [ $TRDDYN = 1 ] ; then
  for f in *${CONFIG_CASE}_*_DYN?.nc   ; do
    #ncks -O -4 -L 3 $f $f 
    mv $f $F_S_DIR/
  done
fi

if [ -f *_YUC.nc      ] ; then 
  for f in *_YUC.nc   ; do
    #ncks -O -4 -L 3 $f $f 
    mv $f $F_S_DIR/
  done
fi

if [ $MOOR = 1 ] ; then
 # for f in *${CONFIG_CASE}_?h_*.nc   ; do
 #   mv $f $F_S_DIR/
 # done
 tar cvf mooring.${CONFIG_CASE}.$ext  *${CONFIG_CASE}_*MOORING*.nc
 mv  mooring.${CONFIG_CASE}.$ext $F_S_DIR/
fi




if [ -f mesh_mask.nc ] ; then  mv mesh_mask.nc $F_S_DIR/  ; fi
if [ -f output.init.nc ] ; then  mv output.init.nc $F_S_DIR/output.init_${prev_step}.nc ; fi

## 3.7 Put annex files in tarfile 
# ---------------------------------- 
if [ -f barotropic.stat ] ; then  mv barotropic.stat barotropic.stat.$ext ; fi
if [ -f islands.stat    ] ; then  mv islands.stat    islands.stat.$ext    ; fi
if [ -f ice.evolu       ] ; then mv ice.evolu ice.evolu.$ext ; fi
if [ -f *diaptr.nc      ] ; then   mv  *diaptr.nc diaptr.$ext.nc ; fi
if [ -f *diagap.nc      ] ; then   mv  *diagap.nc diagap.$ext.nc ; fi
mv solver.stat solver.stat.$ext
mv ocean.output ocean.output.$ext
mv time.step time.step.$ext
mv namelist_cfg namelist_cfg.$ext

tar cvf tarfile.${CONFIG_CASE}_annex.$ext   \
         *ocean.output.$ext *namelist_cfg.$ext  \
        *solver.stat.$ext

chmod ugo+r  tarfile.${CONFIG_CASE}_annex.$ext
expatrie  tarfile.${CONFIG_CASE}_annex.$ext $F_S_DIR tarfile.${CONFIG_CASE}_annex.$ext

