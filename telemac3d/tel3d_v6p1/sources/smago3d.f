!                    ******************
                     SUBROUTINE SMAGO3D
!                    ******************
!
     &(U,V,W,TRAV1,TRAV2,TRAV3,TRAV4,TRAV5,TRAV6,
     & SVIDE,MESH3,IELM3,MSK,MASKEL)
!
!***********************************************************************
! TELEMAC3D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES TURBULENT VISCOSITY USING
!+                3D SMAGORINSKI MODEL:
!code
!+                                            (1/2)
!+    NUSMAGO    =   CS2 * ( 2.0 * SIJ * SIJ )      * (MESH SIZE)**2
!
!history  OLIVER GOETHEL - UNI HANNOVER
!+        17/02/04
!+        V5P5
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
!| IELM3          |---|
!| MASKEL         |---|
!| MESH3          |---|
!| MSK            |---|
!| SVIDE          |---|
!| TRAV1          |---|
!| TRAV2          |---|
!| TRAV3          |---|
!| TRAV4          |---|
!| TRAV5          |---|
!| TRAV6          |---|
!| U              |---|
!| V              |---|
!| W              |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE DECLARATIONS_TELEMAC
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)            :: IELM3
      LOGICAL, INTENT(IN)            :: MSK
      TYPE (BIEF_OBJ), INTENT(IN)    :: U, V, W
      TYPE (BIEF_OBJ), INTENT(INOUT) :: TRAV1, TRAV2, TRAV3, TRAV4,TRAV6
      TYPE (BIEF_OBJ), INTENT(INOUT) :: TRAV5
      TYPE (BIEF_OBJ), INTENT(IN)    :: MASKEL
      TYPE (BIEF_OBJ), INTENT(INOUT) :: SVIDE
      TYPE (BIEF_MESH)               :: MESH3
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I
!
      INTRINSIC SQRT
!
!-----------------------------------------------------------------------
!
      DOUBLE PRECISION CS,CS2
      CS = 0.1D0
      CS2 = CS**2
!
!-----------------------------------------------------------------------
!
!     COMPUTES GRADIENTS (IN FACT AVERAGED GRADIENT MULTIPLIED BY
!     A SURFACE WHICH IS THE INTEGRAL OF TEST FUNCTIONS ON THE DOMAIN,
!     THIS SURFACE IS CONSIDERED TO BE (MESH SIZE)**2) )
!
      CALL VECTOR(TRAV1,'=','GRADF          X',IELM3,
     &            1.D0,U,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV2,'=','GRADF          Y',IELM3,
     &            1.D0,U,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV3,'=','GRADF          Z',IELM3,
     &            1.D0,U,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
!
      CALL VECTOR(TRAV2,'+','GRADF          X',IELM3,
     &            1.D0,V,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV5,'=','GRADF          Y',IELM3,
     &            1.D0,V,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV6,'=','GRADF          Z',IELM3,
     &            1.D0,V,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
!
      CALL VECTOR(TRAV3,'+','GRADF          X',IELM3,
     &            1.D0,W,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV6,'+','GRADF          Y',IELM3,
     &            1.D0,W,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
      CALL VECTOR(TRAV4,'=','GRADF          Z',IELM3,
     &            1.D0,W,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,
     &            MESH3,MSK,MASKEL)
!
      IF(NCSIZE.GT.1) THEN
        CALL PARCOM(TRAV1,2,MESH3)
        CALL PARCOM(TRAV2,2,MESH3)
        CALL PARCOM(TRAV3,2,MESH3)
        CALL PARCOM(TRAV4,2,MESH3)
        CALL PARCOM(TRAV5,2,MESH3)
        CALL PARCOM(TRAV6,2,MESH3)
      ENDIF
!
      DO I=1,U%DIM1
!
      TRAV5%R(I) = CS2 * SQRT(  2.D0*(TRAV1%R(I)**2
     &                               +TRAV5%R(I)**2
     &                               +TRAV4%R(I)**2)
     &                               +TRAV2%R(I)**2
     &                               +TRAV3%R(I)**2
     &                               +TRAV6%R(I)**2  )
!
      ENDDO
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE SMAGO3D