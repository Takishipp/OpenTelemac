!                    ********************** 
                     SUBROUTINE MUDSTRESS3D 
!                    ********************** 
! 
     &(NGEO,FFORMAT,LAYTOCE,NCOUCH,MESH,LISTIN) 
! 
!*********************************************************************** 
! SISYPHE   V7P0                                   21/08/2010 
!*********************************************************************** 
! 
!brief    LOOKS IN GEOMETRY FILE FOR EROSION STRESSES (FOR MUD)  
!         FOR EACH BED LAYER AND READS THEM IF THEY ARE PRESENT.   
!         VALUES ARE READ IN AS STRESSES (N/M2) AND OUTPUTTED AS STRESSES 
!+ 
! 
!history  C. VILLARET & T. BENSON & D. KELLY (HR-WALLINGFORD)
!+        27/02/2014
!+        V7P0
!+   New developments in sediment merged on 25/02/2014.
! 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
! 
      USE BIEF 
!
      IMPLICIT NONE 
      INTEGER LNG,LU 
      COMMON/INFO/LNG,LU 
! 
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
! 
      TYPE(BIEF_MESH), INTENT(IN)   :: MESH       
      TYPE(BIEF_OBJ), INTENT(INOUT) :: LAYTOCE 
      INTEGER, INTENT(IN)           :: NGEO 
      INTEGER, INTENT(IN)           :: NCOUCH 
      LOGICAL, INTENT(IN)           :: LISTIN 
      CHARACTER(LEN=8), INTENT(IN)  :: FFORMAT 
! 
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
! 
      INTEGER :: ERR 
      DOUBLE PRECISION :: BID 
      CHARACTER(LEN=16) :: VARNAME 
      INTEGER :: I, IERR
! 
!----------------------------------------------------------------------- 
! 
!     LOOKS FOR 1. CRITICAL SHEAR STRESS FOR EROSION PER LAYER 
!     IN THE GEOMETRY FILE: 
!     VARIABLE NAMES ARE ERO SHEAR1, ERO SHEAR2, etc....FOR EACH LAYER 
!     UP TO NCOUCH 
! 
      DO I=1,NCOUCH 
! 
!       MAKE THE NUMBERED NAME STRING 
! 
        WRITE(VARNAME,'(A9,I0)')  'ERO SHEAR',I  
!           
        CALL READ_DATA(FFORMAT, NGEO, LAYTOCE%ADR(I)%P%R, 
     &                   VARNAME,MESH%NPOIN,IERR,1,TIME=BID) 
!       
        IF (IERR.EQ.0) THEN
          WRITE(LU,*)  
     &    'EROSION SHEAR (LAYER', I, ') FOUND IN GEOMETRY FILE' 
        ELSE
          WRITE(LU,*)  
     &    'EROSION SHEAR (LAYER', I, ') NOT FOUND IN GEOMETRY FILE' 
        ENDIF
! 
      ENDDO 
! 
!----------------------------------------------------------------------- 
! 
      RETURN 
      END
