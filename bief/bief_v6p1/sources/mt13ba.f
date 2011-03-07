!                    *****************
                     SUBROUTINE MT13BA
!                    *****************
!
     &(  A11 , A12 , A13 ,
     &   A21 , A22 , A23 ,
     &   A31 , A32 , A33 ,
     &   A41 , A42 , A43 ,
     &   XMUL,XEL,YEL,NELEM,NELMAX,ICOORD)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE COEFFICIENTS OF THE FOLLOWING MATRIX:
!code
!+  EXAMPLE WITH ICOORD = 1
!+
!+                  /           D
!+ A(I,J)= XMUL *  /  PSI1(I) * --( PSI2(J) ) D(OMEGA)
!+                /OMEGA        DX
!+
!+  ICOORD=2 WOULD GIVE A DERIVATIVE WRT Y
!+
!+  PSI1: BASES OF TYPE QUASI-BUBBLE TRIANGLE
!+  PSI2: BASES OF TYPE IELM2
!
!note     THE EXPRESSION OF THIS MATRIX IS THE TRANSPOSE
!+         OF THAT IN MT13BB.
!
!warning  THE JACOBIAN MUST BE POSITIVE
!
!history  J-M HERVOUET (LNH)    ; C MOULIN (LNH)
!+        06/02/95
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
!| A41            |---|
!| A42            |---|
!| A43            |---|
!| ICOORD         |-->| 1: DERIVEE SUIVANT X, 2:SUIVANT Y
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| XMUL           |-->| FACTEUR MULTIPLICATIF
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_MT13BA => MT13BA
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
      DOUBLE PRECISION, INTENT(INOUT) :: A41(*),A42(*),A43(*)
!
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
      DOUBLE PRECISION, INTENT(IN) :: XEL(NELMAX,3),YEL(NELMAX,3)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM
      DOUBLE PRECISION X2,X3,Y2,Y3
      DOUBLE PRECISION XSUR9,XSUR6
!
!-----------------------------------------------------------------------
!
      XSUR6 = XMUL/6.D0
      XSUR9 = XMUL/9.D0
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
!   INITIALISES THE GEOMETRICAL VARIABLES
!
        Y2 = YEL(IELEM,2)
        Y3 = YEL(IELEM,3)
!
!   EXTRADIAGONAL TERMS
!
        A12(IELEM) =  Y3*XSUR9
        A13(IELEM) = -Y2*XSUR9
        A21(IELEM) = -(Y3-Y2)*XSUR9
        A23(IELEM) = -Y2*XSUR9
        A31(IELEM) = -(Y3-Y2)*XSUR9
        A32(IELEM) =  Y3*XSUR9
        A41(IELEM) = -(Y3-Y2)*XSUR6
        A42(IELEM) =  Y3*XSUR6
        A43(IELEM) = -Y2*XSUR6
!
!   DIAGONAL TERMS
!   THE SUM OF THE MATRIX COLUMNS IS 0 (VECTOR)
!
        A11(IELEM) = - A12(IELEM) - A13(IELEM)
        A22(IELEM) = - A21(IELEM) - A23(IELEM)
        A33(IELEM) = - A31(IELEM) - A32(IELEM)
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
!   INITIALISES THE GEOMETRICAL VARIABLES
!
        X2  =  XEL(IELEM,2)
        X3  =  XEL(IELEM,3)
!
!   EXTRADIAGONAL TERMS
!
        A12(IELEM) = -X3*XSUR9
        A13(IELEM) =  X2*XSUR9
        A21(IELEM) = -(X2-X3)*XSUR9
        A23(IELEM) =  X2*XSUR9
        A31(IELEM) = -(X2-X3)*XSUR9
        A32(IELEM) = -X3*XSUR9
        A41(IELEM) = -(X2-X3)*XSUR6
        A42(IELEM) = -X3*XSUR6
        A43(IELEM) =  X2*XSUR6
!
!   DIAGONAL TERMS
!   THE SUM OF THE MATRIX COLUMNS IS 0 (VECTOR)
!
        A11(IELEM) = - A12(IELEM) - A13(IELEM)
        A22(IELEM) = - A21(IELEM) - A23(IELEM)
        A33(IELEM) = - A31(IELEM) - A32(IELEM)
!
2       CONTINUE
!
        ELSE
!
          IF (LNG.EQ.1) WRITE(LU,200) ICOORD
          IF (LNG.EQ.2) WRITE(LU,201) ICOORD
          CALL PLANTE(0)
!
        ENDIF
!
200       FORMAT(1X,'MT13BA (BIEF) : COMPOSANTE IMPOSSIBLE ',
     &              1I6,' VERIFIER ICOORD')
201       FORMAT(1X,'MT13BA (BIEF) : IMPOSSIBLE COMPONENT ',
     &              1I6,' CHECK ICOORD')
!
!-----------------------------------------------------------------------
!
      RETURN
      END