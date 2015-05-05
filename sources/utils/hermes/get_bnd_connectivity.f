!                    ***********************
                     SUBROUTINE GET_BND_CONNECTIVITY
!                    ***********************
!
     &(FFORMAT,FID,TYP_BND_ELEM,NELEBD,NDP,IKLE_BND,IERR)
!
!***********************************************************************
! HERMES   V7P0                                               01/05/2014
!***********************************************************************
!
!brief    Reads the connectivity of the boundary elements
!
!history  Y AUDOUIN (LNHE)
!+        24/03/2014
!+        V7P0
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| FFORMAT        |-->| FORMAT OF THE FILE
!| FID            |-->| FILE DESCRIPTOR
!| TYP_BND_ELEM   |-->| TYPE OF THE BOUNDARY ELEMENTS
!| NELEBD         |-->| NUMBER OF BOUNDARY ELEMENTS
!| NDP            |-->| NUMBER OF POINTS PER ELEMENT
!| IKLE_BND       |<->| THE CONNECTIVITY OF THE BOUNDARY ELEMENTS
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
      CHARACTER(LEN=8), INTENT(IN) :: FFORMAT
      INTEGER, INTENT(IN) :: FID,TYP_BND_ELEM,NELEBD,NDP
      INTEGER, INTENT(INOUT) :: IKLE_BND(NDP*NELEBD)
      INTEGER, INTENT(OUT) :: IERR
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      IF((TYP_BND_ELEM.EQ.TYPE_NULL).OR.(NELEBD.EQ.0)) RETURN
!
      SELECT CASE (FFORMAT)
        CASE ('SERAFIN ','SERAFIND')
          CALL GET_BND_CONNECTIVITY_SRF(FID, TYP_BND_ELEM,NELEBD,NDP,
     &                          IKLE_BND,IERR)
        CASE ('MED     ')
          CALL GET_BND_CONNECTIVITY_MED(FID, TYP_BND_ELEM,NELEBD,NDP,
     &                          IKLE_BND,IERR)
        CASE DEFAULT
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'GET_BND_CONNECTIVITY : MAUVAIS FORMAT : ',
     &                   FFORMAT
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'GET_BND_CONNECTIVITY: BAD FILE FORMAT: ',
     &                   FFORMAT
          ENDIF
          CALL PLANTE(1)
          STOP
      END SELECT
!
!-----------------------------------------------------------------------
!
      RETURN
      END