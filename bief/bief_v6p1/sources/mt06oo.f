!                    *****************
                     SUBROUTINE MT06OO
!                    *****************
!
     &(A11,A12,A22,XMUL,SF,F,LGSEG,IKLE1,IKLE2,NBOR,NELEM,NELMAX)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE COEFFICIENTS OF THE FOLLOWING MATRIX:
!code
!+                              /
!+                    A    =   /  F (P *P )*J(X,Y) DX
!+                     I J    /L      I  J
!+
!+     BY ELEMENTARY CELL; THE ELEMENT IS THE P1 SEGMENT
!+
!+     J(X,Y): JACOBIAN OF THE ISOPARAMETRIC TRANSFORMATION
!
!warning  THE JACOBIAN MUST BE POSITIVE
!
!history  F  LEPEINTRE (LNH)
!+        04/09/92
!+
!+
!
!history  J-M HERVOUET (LNHE)
!+        20/03/08
!+        V5P9
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
!| A22            |---|
!| IKLE1          |-->| PASSAGE DE LA NUMEROTATION LOCALE A GLOBALE
!| IKLE2          |---|
!| LGSEG          |---|
!| NBOR           |---|
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| XMUL           |-->| FACTEUR MULTIPLICATIF
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_MT06OO => MT06OO
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: IKLE1(*),IKLE2(*),NBOR(*)
!
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
      DOUBLE PRECISION, INTENT(IN) :: F(*)
!
!     STRUCTURE OF F
      TYPE(BIEF_OBJ), INTENT(IN) :: SF
!
      DOUBLE PRECISION, INTENT(IN)    :: LGSEG(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: A11(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: A12(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT) :: A22(NELMAX)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF
      DOUBLE PRECISION SUR12,DET1,F1,F2,F12
!
!-----------------------------------------------------------------------
!
      SUR12  = XMUL/12.D0
!
!-----------------------------------------------------------------------
!
      IELMF = SF%ELM
!
!     F CONSTANT BY SEGMENT, IN A BOUNDARY ARRAY
!
      IF(IELMF.EQ.0) THEN
!
      DO 1 IELEM = 1 , NELEM
!  TO BE OPTIMISED
      F1 = F(IELEM)
      F2 = F(IELEM)
!
      F12 = F1 + F2
!
      DET1 = LGSEG(IELEM) * SUR12
!
      A11(IELEM) = DET1 * (F12+2*F1)
      A12(IELEM) = DET1 * F12
      A22(IELEM) = DET1 * (F12+2*F2)
!
1     CONTINUE
!
!     F LINEAR BY SEGMENT, IN A BOUNDARY ARRAY
!     NOTE: IKLE IS HERE A BOUNDARY IKLE
!
      ELSEIF(IELMF.EQ.1) THEN
!
      DO 2 IELEM = 1 , NELEM
!
      F1 = F(IKLE1(IELEM))
      F2 = F(IKLE2(IELEM))
      F12 = F1 + F2
      DET1 = LGSEG(IELEM) * SUR12
      A11(IELEM) = DET1 * (F12+2*F1)
      A12(IELEM) = DET1 * F12
      A22(IELEM) = DET1 * (F12+2*F2)
!
2     CONTINUE
!
!     F LINEAR, IN AN ARRAY DEFINED ON THE DOMAIN
!
      ELSEIF(IELMF.EQ.11.OR.IELMF.EQ.21) THEN
!
      DO 3 IELEM = 1 , NELEM
!
      F1 = F(NBOR(IKLE1(IELEM)))
      F2 = F(NBOR(IKLE2(IELEM)))
      F12 = F1 + F2
      DET1 = LGSEG(IELEM) * SUR12
      A11(IELEM) = DET1 * (F12+2*F1)
      A12(IELEM) = DET1 * F12
      A22(IELEM) = DET1 * (F12+2*F2)
!
3     CONTINUE
!
!     OTHER TYPES OF DISCRETISATION OF F
!
      ELSE
!
       IF (LNG.EQ.1) WRITE(LU,100) IELMF,SF%NAME
       IF (LNG.EQ.2) WRITE(LU,101) IELMF,SF%NAME
100    FORMAT(1X,'MT0600 (BIEF) :',/,
     &        1X,'DISCRETISATION DE F NON PREVUE : ',1I6,
     &        1X,'NOM REEL : ',A6)
101    FORMAT(1X,'MT0600 (BIEF) :',/,
     &        1X,'DISCRETIZATION OF F NOT AVAILABLE:',1I6,
     &        1X,'REAL NAME: ',A6)
       CALL PLANTE(1)
       STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END