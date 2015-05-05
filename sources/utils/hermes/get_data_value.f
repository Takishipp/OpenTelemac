!                    *************************
                     SUBROUTINE GET_DATA_VALUE
!                    *************************
!
     &(FFORMAT,FID,RECORD,VAR_NAME,RES_VALUE,N,IERR)
!
!***********************************************************************
! HERMES   V7P0                                               01/05/2014
!***********************************************************************
!
!brief    Returns The value for each point of a given variable 
!+        for a given time step
!
!history  Y AUDOUIN (LNHE)
!+        24/03/2014
!+        V7P0
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| FFORMAT        |-->| FORMAT OF THE FILE
!| FILE_ID        |-->| FILE DESCRIPTOR
!| RECORD         |-->| TIME STEP TO READ IN THE FILE
!| VAR_NAME       |-->| VARIABLE FOR WHICH WE NEED THE VALUE
!| RES_VALUE      |<->| VALUE FOR EACH POINT AT TIME STEP RECORD 
!|                |   | FOR THE VARIABLE VAR_NAME
!| N              |-->| SIZE OF RES_VALUE
!| IERR           |<--| 0 IF NO ERROR DURING THE EXECUTION
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE UTILS_SERAFIN
      USE UTILS_MED
      IMPLICIT NONE
      INTEGER     LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CHARACTER(LEN=8),  INTENT(IN)    :: FFORMAT
      INTEGER,           INTENT(IN)    :: FID
      INTEGER,           INTENT(IN)    :: RECORD
      CHARACTER(LEN=16), INTENT(IN)    :: VAR_NAME
      INTEGER,           INTENT(IN)    :: N
      DOUBLE PRECISION,  INTENT(INOUT) :: RES_VALUE(N)
      INTEGER,           INTENT(OUT)   :: IERR
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      SELECT CASE (FFORMAT)
        CASE ('SERAFIN ','SERAFIND')
          CALL GET_DATA_VALUE_SRF(FID,RECORD,VAR_NAME,
     &                                RES_VALUE,N,IERR)
        CASE ('MED     ')
          CALL GET_DATA_VALUE_MED(FID,RECORD,VAR_NAME,
     &      RES_VALUE,N,IERR)
        CASE DEFAULT
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'GET_DATA_VALUE : MAUVAIS FORMAT : ',FFORMAT
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'GET_DATA_VALUE: BAD FILE FORMAT: ',FFORMAT
          ENDIF
          CALL PLANTE(1)
          STOP
      END SELECT
!
!-----------------------------------------------------------------------
!
      RETURN
      END
