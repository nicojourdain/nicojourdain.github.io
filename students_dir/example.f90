program modif
 
USE netcdf
 
IMPLICIT NONE
 
INTEGER :: fidA, status, dimID_axis_nbounds, dimID_time_counter, dimID_x, dimID_y, maxis_nbounds, mtime_counter, mx, my, time_counter_bounds_ID, time_counter_ID, time_centered_bounds_ID, time_centered_ID, qsr_oce_ID, precip_ID, nav_lon_ID, nav_lat_ID, fidM
 
CHARACTER(LEN=100) :: file_in, file_out
 
REAL*8,ALLOCATABLE,DIMENSION(:) :: time_counter, time_centered
 
REAL*4,ALLOCATABLE,DIMENSION(:,:) :: nav_lon, nav_lat
 
REAL*8,ALLOCATABLE,DIMENSION(:,:) :: time_counter_bounds, time_centered_bounds
 
REAL*4,ALLOCATABLE,DIMENSION(:,:,:) :: qsr_oce, precip
 
file_in  = 'test.nc'
file_out = 'test_new.nc'
 
!---------------------------------------
! Read netcdf input file :
 
write(*,*) 'Reading ', TRIM(file_in)
 
status = NF90_OPEN(TRIM(file_in),0,fidA); call erreur(status,.TRUE.,"read")
 
! Read dimension IDs
status = NF90_INQ_DIMID(fidA,"axis_nbounds",dimID_axis_nbounds); call erreur(status,.TRUE.,"inq_dimID_axis_nbounds")
status = NF90_INQ_DIMID(fidA,"time_counter",dimID_time_counter); call erreur(status,.TRUE.,"inq_dimID_time_counter")
status = NF90_INQ_DIMID(fidA,"x",dimID_x); call erreur(status,.TRUE.,"inq_dimID_x")
status = NF90_INQ_DIMID(fidA,"y",dimID_y); call erreur(status,.TRUE.,"inq_dimID_y")
 
! Read values dimension values
status = NF90_INQUIRE_DIMENSION(fidA,dimID_axis_nbounds,len=maxis_nbounds); call erreur(status,.TRUE.,"inq_dim_axis_nbounds")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_time_counter,len=mtime_counter); call erreur(status,.TRUE.,"inq_dim_time_counter")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_x,len=mx); call erreur(status,.TRUE.,"inq_dim_x")
status = NF90_INQUIRE_DIMENSION(fidA,dimID_y,len=my); call erreur(status,.TRUE.,"inq_dim_y")
  
! Allocation of arrays : 
ALLOCATE(  time_counter_bounds(maxis_nbounds,mtime_counter)  ) 
ALLOCATE(  time_counter(mtime_counter)  ) 
ALLOCATE(  time_centered_bounds(maxis_nbounds,mtime_counter)  ) 
ALLOCATE(  time_centered(mtime_counter)  ) 
ALLOCATE(  qsr_oce(mx,my,mtime_counter)  ) 
ALLOCATE(  precip(mx,my,mtime_counter)  ) 
ALLOCATE(  nav_lon(mx,my)  ) 
ALLOCATE(  nav_lat(mx,my)  ) 
 
! Read variable IDs
status = NF90_INQ_VARID(fidA,"time_counter_bounds",time_counter_bounds_ID); call erreur(status,.TRUE.,"inq_time_counter_bounds_ID")
status = NF90_INQ_VARID(fidA,"time_counter",time_counter_ID); call erreur(status,.TRUE.,"inq_time_counter_ID")
status = NF90_INQ_VARID(fidA,"time_centered_bounds",time_centered_bounds_ID); call erreur(status,.TRUE.,"inq_time_centered_bounds_ID")
status = NF90_INQ_VARID(fidA,"time_centered",time_centered_ID); call erreur(status,.TRUE.,"inq_time_centered_ID")
status = NF90_INQ_VARID(fidA,"qsr_oce",qsr_oce_ID); call erreur(status,.TRUE.,"inq_qsr_oce_ID")
status = NF90_INQ_VARID(fidA,"precip",precip_ID); call erreur(status,.TRUE.,"inq_precip_ID")
status = NF90_INQ_VARID(fidA,"nav_lon",nav_lon_ID); call erreur(status,.TRUE.,"inq_nav_lon_ID")
status = NF90_INQ_VARID(fidA,"nav_lat",nav_lat_ID); call erreur(status,.TRUE.,"inq_nav_lat_ID")
 
! Read variable values
status = NF90_GET_VAR(fidA,time_counter_bounds_ID,time_counter_bounds); call erreur(status,.TRUE.,"getvar_time_counter_bounds")
status = NF90_GET_VAR(fidA,time_counter_ID,time_counter); call erreur(status,.TRUE.,"getvar_time_counter")
status = NF90_GET_VAR(fidA,time_centered_bounds_ID,time_centered_bounds); call erreur(status,.TRUE.,"getvar_time_centered_bounds")
status = NF90_GET_VAR(fidA,time_centered_ID,time_centered); call erreur(status,.TRUE.,"getvar_time_centered")
status = NF90_GET_VAR(fidA,qsr_oce_ID,qsr_oce); call erreur(status,.TRUE.,"getvar_qsr_oce")
status = NF90_GET_VAR(fidA,precip_ID,precip); call erreur(status,.TRUE.,"getvar_precip")
status = NF90_GET_VAR(fidA,nav_lon_ID,nav_lon); call erreur(status,.TRUE.,"getvar_nav_lon")
status = NF90_GET_VAR(fidA,nav_lat_ID,nav_lat); call erreur(status,.TRUE.,"getvar_nav_lat")
 
! Close file
status = NF90_CLOSE(fidA); call erreur(status,.TRUE.,"close_file")
 
!---------------------------------------
! Modification of the variables :

! HERE MODIFY VARIABLES AS YOU WANT 
 
!---------------------------------------
! Writing new netcdf file :
 
write(*,*) 'Creating ', TRIM(file_out)
 
status = NF90_CREATE(TRIM(file_out),NF90_NOCLOBBER,fidM); call erreur(status,.TRUE.,'create')
 
! Definition des dimensions du fichiers                  
status = NF90_DEF_DIM(fidM,"axis_nbounds",maxis_nbounds,dimID_axis_nbounds); call erreur(status,.TRUE.,"def_dimID_axis_nbounds")
status = NF90_DEF_DIM(fidM,"time_counter",NF90_UNLIMITED,dimID_time_counter); call erreur(status,.TRUE.,"def_dimID_time_counter")
status = NF90_DEF_DIM(fidM,"x",mx,dimID_x); call erreur(status,.TRUE.,"def_dimID_x")
status = NF90_DEF_DIM(fidM,"y",my,dimID_y); call erreur(status,.TRUE.,"def_dimID_y")
  
! Variable definitions
status = NF90_DEF_VAR(fidM,"time_counter_bounds",NF90_DOUBLE,(/dimID_axis_nbounds,dimID_time_counter/),time_counter_bounds_ID); call erreur(status,.TRUE.,"def_var_time_counter_bounds_ID")
status = NF90_DEF_VAR(fidM,"time_counter",NF90_DOUBLE,(/dimID_time_counter/),time_counter_ID); call erreur(status,.TRUE.,"def_var_time_counter_ID")
status = NF90_DEF_VAR(fidM,"time_centered_bounds",NF90_DOUBLE,(/dimID_axis_nbounds,dimID_time_counter/),time_centered_bounds_ID); call erreur(status,.TRUE.,"def_var_time_centered_bounds_ID")
status = NF90_DEF_VAR(fidM,"time_centered",NF90_DOUBLE,(/dimID_time_counter/),time_centered_ID); call erreur(status,.TRUE.,"def_var_time_centered_ID")
status = NF90_DEF_VAR(fidM,"qsr_oce",NF90_FLOAT,(/dimID_x,dimID_y,dimID_time_counter/),qsr_oce_ID); call erreur(status,.TRUE.,"def_var_qsr_oce_ID")
status = NF90_DEF_VAR(fidM,"precip",NF90_FLOAT,(/dimID_x,dimID_y,dimID_time_counter/),precip_ID); call erreur(status,.TRUE.,"def_var_precip_ID")
status = NF90_DEF_VAR(fidM,"nav_lon",NF90_FLOAT,(/dimID_x,dimID_y/),nav_lon_ID); call erreur(status,.TRUE.,"def_var_nav_lon_ID")
status = NF90_DEF_VAR(fidM,"nav_lat",NF90_FLOAT,(/dimID_x,dimID_y/),nav_lat_ID); call erreur(status,.TRUE.,"def_var_nav_lat_ID")
 
! Attributes :
status = NF90_PUT_ATT(fidM,time_counter_ID,"bounds","time_counter_bounds"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"time_origin","1900-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"units","seconds since 1900-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"calendar","gregorian"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"long_name","Time axis"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_counter_ID")
status = NF90_PUT_ATT(fidM,time_counter_ID,"axis","T"); call erreur(status,.TRUE.,"put_att_time_counter_ID")

status = NF90_PUT_ATT(fidM,time_centered_ID,"bounds","time_centered_bounds"); call erreur(status,.TRUE.,"put_att_time_centered_ID")
status = NF90_PUT_ATT(fidM,time_centered_ID,"time_origin","1900-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_centered_ID")
status = NF90_PUT_ATT(fidM,time_centered_ID,"units","seconds since 1900-01-01 00:00:00"); call erreur(status,.TRUE.,"put_att_time_centered_ID")
status = NF90_PUT_ATT(fidM,time_centered_ID,"calendar","gregorian"); call erreur(status,.TRUE.,"put_att_time_centered_ID")
status = NF90_PUT_ATT(fidM,time_centered_ID,"long_name","Time axis"); call erreur(status,.TRUE.,"put_att_time_centered_ID")
status = NF90_PUT_ATT(fidM,time_centered_ID,"standard_name","time"); call erreur(status,.TRUE.,"put_att_time_centered_ID")

status = NF90_PUT_ATT(fidM,qsr_oce_ID,"coordinates","time_centered nav_lat nav_lon"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"missing_value",1.e+20); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"_FillValue",1.e+20); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"cell_methods","time: mean (interval: 450 s)"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"interval_write","1 month"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"interval_operation","450 s"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"online_operation","average"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"units","W/m2"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"long_name","solar heat flux at ocean surface"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")
status = NF90_PUT_ATT(fidM,qsr_oce_ID,"standard_name","net_downward_shortwave_flux_at_sea_water_surface"); call erreur(status,.TRUE.,"put_att_qsr_oce_ID")

status = NF90_PUT_ATT(fidM,precip_ID,"coordinates","time_centered nav_lat nav_lon"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"missing_value",1.e+20); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"_FillValue",1.e+20); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"cell_methods","time: mean (interval: 450 s)"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"interval_write","1 month"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"interval_operation","450 s"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"online_operation","average"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"units","kg/m2/s"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"long_name","Total precipitation"); call erreur(status,.TRUE.,"put_att_precip_ID")
status = NF90_PUT_ATT(fidM,precip_ID,"standard_name","precipitation_flux"); call erreur(status,.TRUE.,"put_att_precip_ID")

status = NF90_PUT_ATT(fidM,nav_lon_ID,"units","degrees_east"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"long_name","Longitude"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lon_ID,"standard_name","longitude"); call erreur(status,.TRUE.,"put_att_nav_lon_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"units","degrees_north"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"long_name","Latitude"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
status = NF90_PUT_ATT(fidM,nav_lat_ID,"standard_name","latitude"); call erreur(status,.TRUE.,"put_att_nav_lat_ID")
 
! Global attributes :
status = NF90_PUT_ATT(fidM,NF90_GLOBAL,"history","Created on mer. mai  4 13:30:05 CEST 2022"); call erreur(status,.TRUE.,"put_att_GLOBAL_ID")
 
! End of definitions
status = NF90_ENDDEF(fidM); call erreur(status,.TRUE.,"fin_definition") 
 
! Variable values :
status = NF90_PUT_VAR(fidM,time_counter_bounds_ID,time_counter_bounds); call erreur(status,.TRUE.,"var_time_counter_bounds_ID")
status = NF90_PUT_VAR(fidM,time_counter_ID,time_counter); call erreur(status,.TRUE.,"var_time_counter_ID")
status = NF90_PUT_VAR(fidM,time_centered_bounds_ID,time_centered_bounds); call erreur(status,.TRUE.,"var_time_centered_bounds_ID")
status = NF90_PUT_VAR(fidM,time_centered_ID,time_centered); call erreur(status,.TRUE.,"var_time_centered_ID")
status = NF90_PUT_VAR(fidM,qsr_oce_ID,qsr_oce); call erreur(status,.TRUE.,"var_qsr_oce_ID")
status = NF90_PUT_VAR(fidM,precip_ID,precip); call erreur(status,.TRUE.,"var_precip_ID")
status = NF90_PUT_VAR(fidM,nav_lon_ID,nav_lon); call erreur(status,.TRUE.,"var_nav_lon_ID")
status = NF90_PUT_VAR(fidM,nav_lat_ID,nav_lat); call erreur(status,.TRUE.,"var_nav_lat_ID")
 
! Close file
status = NF90_CLOSE(fidM); call erreur(status,.TRUE.,"final")

end program modif



SUBROUTINE erreur(iret, lstop, chaine)
  ! pour les messages d'erreur
  USE netcdf
  INTEGER, INTENT(in)                     :: iret
  LOGICAL, INTENT(in)                     :: lstop
  CHARACTER(LEN=*), INTENT(in)            :: chaine
  !
  CHARACTER(LEN=80)                       :: message
  !
  IF ( iret .NE. 0 ) THEN
    WRITE(*,*) 'ROUTINE: ', TRIM(chaine)
    WRITE(*,*) 'ERREUR: ', iret
    message=NF90_STRERROR(iret)
    WRITE(*,*) 'CA VEUT DIRE:',TRIM(message)
    IF ( lstop ) STOP
  ENDIF
  !
END SUBROUTINE erreur
