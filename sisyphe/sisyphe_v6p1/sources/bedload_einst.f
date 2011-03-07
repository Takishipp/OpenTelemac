!                    *********************************
                     SUBROUTINE BEDLOAD_EINST ! (_IMP)
!                    *********************************
!
     &  (TETAP, NPOIN, DENS, GRAV, DM, DSTAR, QSC)
!
!***********************************************************************
! SISYPHE   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    EINSTEIN-BROWN BEDLOAD TRANSPORT FORMULATION.
!
!history  E. PELTIER; C. LENORMANT; J.-M. HERVOUET
!+        11/09/1995
!+        V5P1
!+
!
!history  C.VILLARET
!+        **/10/2003
!+        V5P4
!+
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
!| DENS           |---|
!| DM             |---|
!| DSTAR          |---|
!| GRAV           |---|
!| NPOIN          |---|
!| QSC            |---|
!| TETAP          |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE INTERFACE_SISYPHE,
     &    EX_BEDLOAD_EINST => BEDLOAD_EINST
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE(BIEF_OBJ),   INTENT(IN)    :: TETAP
      INTEGER,          INTENT(IN)    :: NPOIN
      DOUBLE PRECISION, INTENT(IN)    :: DENS, GRAV, DM, DSTAR
      TYPE(BIEF_OBJ),   INTENT(INOUT)   :: QSC
!
      ! 3/ LOCAL VARIABLES
      ! ------------------
      INTEGER          :: I
      DOUBLE PRECISION :: CEINST
!
!======================================================================!
!======================================================================!
!                               PROGRAM                                !
!======================================================================!
!======================================================================!
!
      ! **************************** !
      ! II - BEDLOAD TRANSPORT       ! (_IMP_)
      ! **************************** !
      CEINST = 36.D0/(DSTAR**3)
      CEINST = SQRT(2.D0/3.D0+CEINST) -  SQRT(CEINST)
      CEINST = CEINST * SQRT(DENS*GRAV*(DM**3))
      DO I = 1, NPOIN
         IF (TETAP%R(I) < 2.5D-3) THEN
            QSC%R(I) = 0.D0
         ELSE IF (TETAP%R(I) < 0.2D0) THEN
            QSC%R(I) = 2.15D0* CEINST * EXP(-0.391D0/TETAP%R(I))
         ELSE
            QSC%R(I) = 40.D0 * CEINST * (TETAP%R(I)**3.D0)
         ENDIF
      ENDDO
!======================================================================!
!======================================================================!
      RETURN
      END SUBROUTINE BEDLOAD_EINST