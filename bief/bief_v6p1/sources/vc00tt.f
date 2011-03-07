!                    *****************
                     SUBROUTINE VC00TT
!                    *****************
!
     &( XMUL,X,Y,Z,SURFAC,IKLE1,IKLE2,IKLE3,IKLE4,
     &  NELEM,NELMAX,W1,W2,W3,W4)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!code
!+                    /
!+    VEC(I) = XMUL  /    PSI(I)  D(OMEGA)
!+                  /OMEGA
!+
!+    PSI(I) IS A BASE OF TYPE P1 TETRAHEDRON
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM
!
!history  J-M HERVOUET (LNH)
!+        22/03/02
!+        V5P3
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
!| IKLE2          |---|
!| IKLE3          |---|
!| IKLE4          |---|
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| SURFAC         |-->| SURFACE DES ELEMENTS.
!| W2             |---|
!| W3             |---|
!| W4             |---|
!| X              |---|
!| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
!| Y              |---|
!| Z              |-->| COORDONNEES DES POINTS DANS L'ELEMENT
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX)
      INTEGER, INTENT(IN) :: IKLE3(NELMAX),IKLE4(NELMAX)
!
      DOUBLE PRECISION, INTENT(IN) :: X(*),Y(*),Z(*)
      DOUBLE PRECISION, INTENT(INOUT) :: W1(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: W2(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: W3(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: W4(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: SURFAC(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION XSUR24,X2,X3,X4,Y2,Y3,Y4,Z2,Z3,Z4
      INTEGER I1,I2,I3,I4,IELEM
!
!-----------------------------------------------------------------------
!
      XSUR24  = XMUL/24.D0
!
!   LOOP ON THE ELEMENTS
!
      DO 3 IELEM = 1 , NELEM
!
         I1 = IKLE1(IELEM)
         I2 = IKLE2(IELEM)
         I3 = IKLE3(IELEM)
         I4 = IKLE4(IELEM)
!
         X2 = X(I2)-X(I1)
         X3 = X(I3)-X(I1)
         X4 = X(I4)-X(I1)
!
         Y2 = Y(I2)-Y(I1)
         Y3 = Y(I3)-Y(I1)
         Y4 = Y(I4)-Y(I1)
!
         Z2 = Z(I2)-Z(I1)
         Z3 = Z(I3)-Z(I1)
         Z4 = Z(I4)-Z(I1)
!
         W1(IELEM) =
     &    (X2*Y3*Z4-X2*Y4*Z3-Y2*X3*Z4+Y2*X4*Z3+Z2*X3*Y4-Z2*X4*Y3)*XSUR24
         W2(IELEM) = W1(IELEM)
         W3(IELEM) = W1(IELEM)
         W4(IELEM) = W1(IELEM)
!
3     CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END