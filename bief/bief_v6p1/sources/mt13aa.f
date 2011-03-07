!                    *****************
                     SUBROUTINE MT13AA
!                    *****************
!
     &(  A11 , A12 , A13 ,
     &   A21 , A22 , A23 ,
     &   A31 , A32 , A33 ,
     &   XMUL,XEL,YEL,NELEM,NELMAX,ICOORD)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE COEFFICIENTS OF THE FOLLOWING MATRIX:
!code
!+                    /            D
!+    A(I,J)=   XMUL /  PSI2(I) *  --( PSI1(J) ) D(OMEGA)
!+                  /OMEGA         DX
!+
!+  ICOORD=2 WOULD GIVE A DERIVATIVE WRT Y
!+  ICOORD=3 WOULD GIVE A DERIVATIVE WRT Z
!+
!+  PSI1: LINEAR
!+  PSI2: LINEAR
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  SIGN CHANGED COMPARED TO 3.0
!warning  TRANSPOSITION COMPARED TO 3.0
!
!history  J-M HERVOUET (LNH)    ; C MOULIN (LNH)
!+        09/12/94
!+        V5P1
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
!| A11,A12        |<--| ELEMENTS DE LA MATRICE
!| A13            |---|
!| A21            |---|
!| A22            |---|
!| A23            |---|
!| A31            |---|
!| A32            |---|
!| A33            |---|
!| ICOORD         |-->| 1: DERIVEE SUIVANT X, 2:SUIVANT Y
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| XMUL           |-->| FACTEUR MULTIPLICATIF
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_MT13AA => MT13AA
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX,ICOORD
!
      DOUBLE PRECISION, INTENT(INOUT) :: A11(*),A12(*),A13(*)
      DOUBLE PRECISION, INTENT(INOUT) :: A21(*),A22(*),A23(*)
      DOUBLE PRECISION, INTENT(INOUT) :: A31(*),A32(*),A33(*)
!
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
      DOUBLE PRECISION, INTENT(IN) :: XEL(NELMAX,3),YEL(NELMAX,3)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM
      DOUBLE PRECISION XSUR6
!
!-----------------------------------------------------------------------
!
      XSUR6 = XMUL/6.D0
!
!================================
!  DERIVATIVE WRT X  =
!================================
!
      IF(ICOORD.EQ.1) THEN
!
!   LOOP ON THE ELEMENTS
!
      DO 1 IELEM = 1 , NELEM
!
!   DIAGONAL TERMS
!
      A22(IELEM) =    YEL(IELEM,3) * XSUR6
      A33(IELEM) = -  YEL(IELEM,2) * XSUR6
      A11(IELEM) = - A22(IELEM) - A33(IELEM)
!
!   EXTRADIAGONAL TERMS
!
      A21(IELEM) = A11(IELEM)
      A31(IELEM) = A11(IELEM)
      A32(IELEM) = A22(IELEM)
      A12(IELEM) = A22(IELEM)
      A13(IELEM) = A33(IELEM)
      A23(IELEM) = A33(IELEM)
!
1     CONTINUE
!
      ELSEIF(ICOORD.EQ.2) THEN
!
!================================
!  DERIVATIVE WRT Y  =
!================================
!
      DO 2 IELEM = 1 , NELEM
!
!   DIAGONAL TERMS
!
      A22(IELEM) = - XEL(IELEM,3) * XSUR6
      A33(IELEM) =   XEL(IELEM,2) * XSUR6
      A11(IELEM) = - A22(IELEM) - A33(IELEM)
!
!   EXTRADIAGONAL TERMS
!
      A21(IELEM) = A11(IELEM)
      A31(IELEM) = A11(IELEM)
      A32(IELEM) = A22(IELEM)
      A12(IELEM) = A22(IELEM)
      A13(IELEM) = A33(IELEM)
      A23(IELEM) = A33(IELEM)
!
2     CONTINUE
!
        ELSE
!
          IF (LNG.EQ.1) WRITE(LU,200) ICOORD
          IF (LNG.EQ.2) WRITE(LU,201) ICOORD
200       FORMAT(1X,'MT13AA (BIEF) : COMPOSANTE IMPOSSIBLE ',
     &              1I6,' VERIFIER ICOORD')
201       FORMAT(1X,'MT13AA (BIEF) : IMPOSSIBLE COMPONENT ',
     &              1I6,' CHECK ICOORD')
          CALL PLANTE(0)
          STOP
!
        ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END