
        SUBROUTINE SUSPENSION_EROSION  !
     &(TAUP,HN,FDM,AVA,NPOIN,CHARR,XMVE,XMVS,VCE,GRAV,HMIN,XWC,
     & ZERO,ZREF,AC,FLUER,CSTAEQ,QSC,ICQ,DEBUG)
***********************************************************************
! SISYPHE   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FLUX OF DEPOSITION AND EROSION.
!
!history  J-M HERVOUET + C VILLARET
!+        17/09/2009
!+
!+
!
!history  CV
!+        04/05/2010
!+        V6P0
!+   MODIFICATION FOR FREDSOE: EQUILIBRIUM CONCENTRATIONS
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        13/07/2010
!+        V6P0
!+   Translation of French comments within the FORTRAN sources into
!+   English comments
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        21/08/2010
!+        V6P0
!+   Creation of DOXYGEN tags for automated documentation and
!+   cross-referencing of the FORTRAN sources
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AC             |---|
!| ACLADM         |---|
!| AVA            |---|
!| CHARR          |---|
!| CSTAEQ         |---|
!| DEBUG          |---|
!| FLUER          |---|
!| GRAV           |---|
!| HMIN           |---|
!| HN             |-->| HAUTEUR D'EAU
!| ICQ            |---|
!| NPOIN          |---|
!| QSC            |---|
!| TAUP           |---|
!| VCE            |---|
!| XMVE           |---|
!| XMVS           |---|
!| XWC            |---|
!| ZERO           |---|
!| ZREF           |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
C
      USE INTERFACE_SISYPHE, EX_SUSPENSION_EROSION=>SUSPENSION_EROSION
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU

      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE (BIEF_OBJ),  INTENT(IN)    :: TAUP,HN,ZREF,QSC
      INTEGER,          INTENT(IN)    :: NPOIN,DEBUG,ICQ
      LOGICAL,          INTENT(IN)    :: CHARR
      DOUBLE PRECISION, INTENT(IN)    :: XMVE,XMVS,GRAV,HMIN,XWC,VCE
      DOUBLE PRECISION, INTENT(IN)    :: AVA(NPOIN),ZERO,FDM
      TYPE (BIEF_OBJ),  INTENT(INOUT) :: FLUER,CSTAEQ
      DOUBLE PRECISION, INTENT(INOUT) :: AC

      ! 3/ LOCAL VARIABLES
      ! -------------------

      INTEGER I
!
!======================================================================!
!======================================================================!
C                               PROGRAM                                !
!======================================================================!
!======================================================================!
!
!
C  COMPUTES THE NEAR BED EQUILIBRIUM CONCENTRATION --> CSTAEQ (MEAN DIAMETER)
!
      IF(ICQ.EQ.1) THEN
C
        IF(DEBUG > 0) WRITE(LU,*) 'SUSPENSION_FREDSOE'
        CALL SUSPENSION_FREDSOE(FDM,TAUP,NPOIN,
     &                          GRAV,XMVE,XMVS,ZERO,AC,CSTAEQ)
        IF(DEBUG > 0) WRITE(LU,*) 'END SUSPENSION_FREDSOE'
C
C       CALL OS('X=CYZ   ', X=FLUER, Y=CSTAEQ, Z=AVA, C=XWC)
C 04/05/2010
C START OF CV MODIFICATIONS ...
CV        DO I=1,NPOIN
CV          FLUER%R(I)=XWC*CSTAEQ%R(I)*AVA(I)
CV        ENDDO
          DO I=1,NPOIN
            CSTAEQ%R(I)=CSTAEQ%R(I)*AVA(I)
          ENDDO
          CALL OS('X=CY    ', X=FLUER, Y=CSTAEQ, C=XWC)
C ... END OF CV MODIFICATIONS
C
      ELSEIF(ICQ.EQ.2) THEN
C
        IF(DEBUG > 0) WRITE(LU,*) 'SUSPENSION_BIJKER'
        CALL SUSPENSION_BIJKER(TAUP,HN,NPOIN,CHARR,QSC,ZREF,
     &                         ZERO,HMIN,CSTAEQ,XMVE)
        IF(DEBUG > 0) WRITE(LU,*) 'END SUSPENSION_BIJKER'
C       NO MULTIPLICATION BY AVA BECAUSE AVA HAS ALREADY BEEN TAKEN
C       INTO ACCOUNT IN THE BEDLOAD TRANSPORT RATE
        CALL OS('X=CY    ', X=FLUER, Y=CSTAEQ, C=XWC)
C
C Modified by Nicolas Huybrechts
C oct 2010
      ELSEIF(ICQ.EQ.3) THEN
         IF(DEBUG > 0) WRITE(LU,*) 'SUSPENSION_VANRIJN'
 
         CALL SUSPENSION_VANRIJN(FDM,TAUP,NPOIN,
     &                     GRAV,XMVE,XMVS,VCE,ZERO,AC,CSTAEQ,ZREF)
         IF(DEBUG > 0) WRITE(LU,*) 'END SUSPENSION_VANRIJN'
          DO I=1,NPOIN
            CSTAEQ%R(I)=CSTAEQ%R(I)*AVA(I)
          ENDDO
          CALL OS('X=CY    ', X=FLUER, Y=CSTAEQ, C=XWC) 
C        fin modif nh
         ENDIF 
!======================================================================!
!======================================================================!
!
      RETURN
      END
C
C#######################################################################
C
