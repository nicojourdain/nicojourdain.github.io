program modif
!==============================================================
! Example showing how to read/write a netcdf file in fortran90
!==============================================================

USE netcdf

IMPLICIT NONE

INTEGER :: fidA, status, dimID_TIME, dimID_DEPTH, dimID_LAT, dimID_LON, &
&          mTIME, mDEPTH, mLAT, mLON, TIME_ID, DEPTH_ID, LAT_ID, LON_ID,&
&          TEMP_ID, fidM

CHARACTER(LEN=100) :: file_in, file_out

REAL*8,ALLOCATABLE,DIMENSION(:) :: TIME, DEPTH, LAT, LON

REAL*4,ALLOCATABLE,DIMENSION(:,:,:,:) :: TEMP

!---------------------------------------
! input and output file names

file_in  = 'PAPIER_IOD_ENSO/SODA_TEMP_v2.2.4_01.nc'
file_out = 'new_file.nc'

!---------------------------------------
! Read netcdf input file :

!- open file_in and set its ID value in fidA :
status = NF90_OPEN(TRIM(file_in),0,fidA)
call erreur(status,.TRUE.,"read_A")

!- read ID of dimensions of interest and save them in
!  dimID_TIME, dimID_DEPTH, dimID_LAT, dimID_LON
status = NF90_INQ_DIMID(fidA,"TIME",dimID_TIME)
call erreur(status,.TRUE.,"inq_dimID_TIME")
status = NF90_INQ_DIMID(fidA,"DEPTH",dimID_DEPTH)
call erreur(status,.TRUE.,"inq_dimID_DEPTH")
status = NF90_INQ_DIMID(fidA,"LAT",dimID_LAT)
call erreur(status,.TRUE.,"inq_dimID_LAT")
status = NF90_INQ_DIMID(fidA,"LON",dimID_LON)
call erreur(status,.TRUE.,"inq_dimID_LON")

!- read values of dimensions and store in mTIME, mDEPTH, mLAT, mLON :
status = NF90_INQUIRE_DIMENSION(fidA,dimID_TIME,len=mTIME)
call erreur(status,.TRUE.,"inq_dim_TIME")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_DEPTH,len=mDEPTH)
call erreur(status,.TRUE.,"inq_dim_DEPTH")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_LAT,len=mLAT)
call erreur(status,.TRUE.,"inq_dim_LAT")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_LON,len=mLON)
call erreur(status,.TRUE.,"inq_dim_LON")

!- Allocation of arrays :
ALLOCATE(  TIME(mTIME)  )
ALLOCATE(  DEPTH(mDEPTH)  )
ALLOCATE(  LAT(mLAT)  )
ALLOCATE(  LON(mLON)  )
ALLOCATE(  TEMP(mLON,mLAT,mDEPTH,mTIME)  )

!- read ID of variables of interest and store them in xxxx_ID :
status = NF90_INQ_VARID(fidA,"TIME",TIME_ID)
call erreur(status,.TRUE.,"inq_TIME_ID")
status = NF90_INQ_VARID(fidA,"DEPTH",DEPTH_ID)
call erreur(status,.TRUE.,"inq_DEPTH_ID")
status = NF90_INQ_VARID(fidA,"LAT",LAT_ID)
call erreur(status,.TRUE.,"inq_LAT_ID")
status = NF90_INQ_VARID(fidA,"LON",LON_ID)
call erreur(status,.TRUE.,"inq_LON_ID")
status = NF90_INQ_VARID(fidA,"TEMP",TEMP_ID)
call erreur(status,.TRUE.,"inq_TEMP_ID")

!- read and store values of each variable :
status = NF90_GET_VAR(fidA,TIME_ID,TIME)
call erreur(status,.TRUE.,"getvar_TIME")
status = NF90_GET_VAR(fidA,DEPTH_ID,DEPTH)
call erreur(status,.TRUE.,"getvar_DEPTH")
status = NF90_GET_VAR(fidA,LAT_ID,LAT)
call erreur(status,.TRUE.,"getvar_LAT")
status = NF90_GET_VAR(fidA,LON_ID,LON)
call erreur(status,.TRUE.,"getvar_LON")
status = NF90_GET_VAR(fidA,TEMP_ID,TEMP)
call erreur(status,.TRUE.,"getvar_TEMP")

!- close netcdf file :
status = NF90_CLOSE(fidA)
call erreur(status,.TRUE.,"close_A")

!---------------------------------------
! Modification/Creation of variables :

! here calculate what you need and create new lines below
! for new variables...

!---------------------------------------
! Writing new netcdf file :

!- create netcdf file with ID value fidM :
status = NF90_CREATE(TRIM(file_out),NF90_NOCLOBBER,fidM)
!! !NB: for large files, you may need to use this line instead :
!! status = NF90_CREATE(TRIM(file_out),or(NF90_NOCLOBBER,NF90_64BIT_OFFSET),fidM)
call erreur(status,.TRUE.,'create_M')

!- Define file dimensions names and size (with unlimited time axis):
status = NF90_DEF_DIM(fidM,"time",NF90_UNLIMITED,dimID_TIME)
call erreur(status,.TRUE.,"def_dimID_time")
status = NF90_DEF_DIM(fidM,"z",mDEPTH,dimID_DEPTH)
call erreur(status,.TRUE.,"def_dimID_z")
status = NF90_DEF_DIM(fidM,"latitude",mLAT,dimID_LAT)
call erreur(status,.TRUE.,"def_dimID_latitude")
status = NF90_DEF_DIM(fidM,"longitude",mLON,dimID_LON)
call erreur(status,.TRUE.,"def_dimID_longitude")

!- define variable names and dimensions :
status = NF90_DEF_VAR(fidM,"time",NF90_DOUBLE,(/dimID_TIME/),TIME_ID)
call erreur(status,.TRUE.,"def_var_time_ID")
status = NF90_DEF_VAR(fidM,"z",NF90_DOUBLE,(/dimID_DEPTH/),DEPTH_ID)
call erreur(status,.TRUE.,"def_var_z_ID")
status = NF90_DEF_VAR(fidM,"latitude",NF90_DOUBLE,(/dimID_LAT/),LAT_ID)
call erreur(status,.TRUE.,"def_var_lat_ID")
status = NF90_DEF_VAR(fidM,"longitude",NF90_DOUBLE,(/dimID_LON/),LON_ID)
call erreur(status,.TRUE.,"def_var_lon_ID")
status = NF90_DEF_VAR(fidM,"thetao",NF90_FLOAT,(/dimID_LON,dimID_LAT,dimID_DEPTH,dimID_TIME/),TEMP_ID)
call erreur(status,.TRUE.,"def_var_thetao_ID")

!- Attributes of each variable :
status = NF90_PUT_ATT(fidM,TEMP_ID,"history","From CARTON-GIESE/.SODA/.v2p2p4/.temp/dods")
call erreur(status,.TRUE.,"put_att_TEMP_ID")
status = NF90_PUT_ATT(fidM,TEMP_ID,"units","Celsius_scale")
call erreur(status,.TRUE.,"put_att_TEMP_ID")
status = NF90_PUT_ATT(fidM,TEMP_ID,"long_name","TEMPERATURE")
call erreur(status,.TRUE.,"put_att_TEMP_ID")
status = NF90_PUT_ATT(fidM,TEMP_ID,"_FillValue",-9.99e+33)
call erreur(status,.TRUE.,"put_att_TEMP_ID")
status = NF90_PUT_ATT(fidM,TEMP_ID,"missing_value",-9.99e+33)
call erreur(status,.TRUE.,"put_att_TEMP_ID")
status = NF90_PUT_ATT(fidM,TIME_ID,"axis","T")
call erreur(status,.TRUE.,"put_att_TIME_ID")
status = NF90_PUT_ATT(fidM,TIME_ID,"units","months since 1960-01-01 00:00:00")
call erreur(status,.TRUE.,"put_att_TIME_ID")
status = NF90_PUT_ATT(fidM,TIME_ID,"calendar","360")
call erreur(status,.TRUE.,"put_att_TIME_ID")
status = NF90_PUT_ATT(fidM,DEPTH_ID,"axis","Z")
call erreur(status,.TRUE.,"put_att_DEPTH_ID")
status = NF90_PUT_ATT(fidM,DEPTH_ID,"point_spacing","even")
call erreur(status,.TRUE.,"put_att_DEPTH_ID")
status = NF90_PUT_ATT(fidM,DEPTH_ID,"units","meters")
call erreur(status,.TRUE.,"put_att_DEPTH_ID")
status = NF90_PUT_ATT(fidM,LAT_ID,"axis","Y")
call erreur(status,.TRUE.,"put_att_LAT_ID")
status = NF90_PUT_ATT(fidM,LAT_ID,"point_spacing","even")
call erreur(status,.TRUE.,"put_att_LAT_ID")
status = NF90_PUT_ATT(fidM,LAT_ID,"units","degree_north")
call erreur(status,.TRUE.,"put_att_LAT_ID")
status = NF90_PUT_ATT(fidM,LON_ID,"axis","X")
call erreur(status,.TRUE.,"put_att_LON_ID")
status = NF90_PUT_ATT(fidM,LON_ID,"point_spacing","even")
call erreur(status,.TRUE.,"put_att_LON_ID")
status = NF90_PUT_ATT(fidM,LON_ID,"modulo",360.)
call erreur(status,.TRUE.,"put_att_LON_ID")
status = NF90_PUT_ATT(fidM,LON_ID,"units","degree_east")
call erreur(status,.TRUE.,"put_att_LON_ID")

!- Global attribute :
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"history","Created by Bob using example.f90")
call erreur(status,.TRUE.,"put_att_GLOBAL_ID")

!- End of definitions :
status = NF90_ENDDEF(fidM)
call erreur(status,.TRUE.,"end_definition")

!- Values taken by the variables defined above :
status = NF90_PUT_VAR(fidM,TIME_ID,TIME)
call erreur(status,.TRUE.,"var_TIME_ID")
status = NF90_PUT_VAR(fidM,DEPTH_ID,DEPTH)
call erreur(status,.TRUE.,"var_DEPTH_ID")
status = NF90_PUT_VAR(fidM,LAT_ID,LAT)
call erreur(status,.TRUE.,"var_LAT_ID")
status = NF90_PUT_VAR(fidM,LON_ID,LON)
call erreur(status,.TRUE.,"var_LON_ID")
status = NF90_PUT_VAR(fidM,TEMP_ID,TEMP)
call erreur(status,.TRUE.,"var_TEMP_ID")

!- End Writing :
status = NF90_CLOSE(fidM)
call erreur(status,.TRUE.,"close_M")

end program modif

!=================================================

SUBROUTINE erreur(iret, lstop, chaine)
! used to provide clear error messages :
USE netcdf
INTEGER, INTENT(in)                     :: iret
LOGICAL, INTENT(in)                     :: lstop
CHARACTER(LEN=*), INTENT(in)            :: chaine
!
CHARACTER(LEN=80)                       :: message
!
IF ( iret .NE. 0 ) THEN
  WRITE(*,*) 'ROUTINE: ', TRIM(chaine)
  WRITE(*,*) 'ERROR: ', iret
  message=NF90_STRERROR(iret)
  WRITE(*,*) 'WHICH MEANS:',TRIM(message)
  IF ( lstop ) STOP
ENDIF
!
END SUBROUTINE erreur
