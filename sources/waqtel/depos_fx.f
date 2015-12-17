!                   ***********************
                     SUBROUTINE DEPOS_FX
!                    **********************
!
     &(SEDP,TAUB,TAUS,VITCHU,NPOIN)
!
!***********************************************************************
! TELEMAC2D   V7P1
!***********************************************************************
!
!brief    COMPUTES DEPOSITION FLUX 
!
!                              
!
!history  R. ATA (LNHE)
!+        02/09/2015
!+        V7P1
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| NPOIN          |-->| TOTAL NUMBER OF MESH NODES
!| SEDP           |<--| DEPOSITION FLUX
!| TAUB           |-->| BED SHEAR STRESS
!| TAUS           |-->| SEDIMENTATION CRITICAL STRESS
!| VITCHU         |-->| SEDIMENT SETTLING VELOCITY
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE INTERFACE_WAQTEL, EX_DEPOS_FX => DEPOS_FX
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER         , INTENT(IN)     :: NPOIN
      DOUBLE PRECISION, INTENT(IN)     :: TAUS,VITCHU
      TYPE(BIEF_OBJ)   , INTENT(IN   ) :: TAUB
      TYPE(BIEF_OBJ)   , INTENT(INOUT) :: SEDP
      INTRINSIC MAX
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!
!     LOCAL VARIABLES
      INTEGER I
!     
!
      IF (ABS(TAUS).LT.1.E-10)THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'DESPOS_FX: CISAILLEMENT CRITIQUE DE RESUSPENSION'
          WRITE(LU,*) '           TAUS TROP PETIT - VERIFIER VALEUR !!!'
          WRITE(LU,*) '           TAUS = ',TAUS
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'DEPOS_FX: CRITICAL STRESS OF RESUSPENSION    '
          WRITE(LU,*) '          TAUS VERY SMALL OR NIL - VERIFY !!!'
          WRITE(LU,*) '          TAUS = ',TAUS
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF
!      
      DO I=1,NPOIN
        SEDP%R(I)=VITCHU*MAX(1.D0-TAUB%R(I)/TAUS,0.D0)
      ENDDO 
!      
      RETURN
      END
!
!-----------------------------------------------------------------------
!