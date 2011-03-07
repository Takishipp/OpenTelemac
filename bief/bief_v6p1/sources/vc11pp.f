!                    *****************
                     SUBROUTINE VC11PP
!                    *****************
!
     &( XMUL,SF,SG,F,G,X,Y,Z,
     &  IKLE1,IKLE2,IKLE3,IKLE4,IKLE5,IKLE6,NELEM,NELMAX,
     &  W1,W2,W3,W4,W5,W6 , ICOORD )
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!code
!+   (EXAMPLE OF THE X COMPONENT, WHICH CORRESPONDS TO ICOORD=1)
!+
!+                       /            DF
!+    VEC(I)  =  XMUL   /  ( G  P  *( --  )) D(OMEGA)
!+                     /OMEGA    I    DX
!+
!+
!+    P   IS A LINEAR BASE
!+     I
!+
!+    F IS A VECTOR OF TYPE P1 OR OTHER
!
!note     IMPORTANT : IF F IS OF TYPE P0, THE RESULT IS 0.
!+
!+               HERE, IF F IS P0, IT REALLY MEANS THAT F IS
!+                     P1, BUT GIVEN BY ELEMENTS.
!+
!+               THE SIZE OF F SHOULD THEN BE : F(NELMAX,3).
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM - REAL MESH
!
!history  J-M HERVOUET (LNH)    ; F LEPEINTRE (LNH)
!+        09/12/94
!+        V5P1
!+
!
!history  ARNAUD DESITTER - UNIVERSITY OF BRISTOL
!+        **/04/98
!+
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
!| ICOORD         |-->| COORDONNEE SUIVANT LAQUELLE ON DERIVE.
!| IKLE2          |---|
!| IKLE3          |---|
!| IKLE4          |---|
!| IKLE5          |---|
!| IKLE6          |---|
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| W2             |---|
!| W3             |---|
!| W4             |---|
!| W5             |---|
!| W6             |---|
!| X              |---|
!| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
!| Y              |---|
!| Z              |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF   !, EX_VC11PP => VC11PP
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX,ICOORD
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX),IKLE3(NELMAX)
      INTEGER, INTENT(IN) :: IKLE4(NELMAX),IKLE5(NELMAX),IKLE6(NELMAX)
!
      DOUBLE PRECISION, INTENT(IN)   ::X(*),Y(*),Z(*),XMUL
      DOUBLE PRECISION, INTENT(INOUT)::W1(NELMAX),W2(NELMAX),W3(NELMAX)
      DOUBLE PRECISION, INTENT(INOUT)::W4(NELMAX),W5(NELMAX),W6(NELMAX)
!
!     STRUCTURES OF F, G, H, U, V, W AND REAL DATA
!
      TYPE(BIEF_OBJ) :: SF,SG
      DOUBLE PRECISION F(*),G(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF,IELMG
      DOUBLE PRECISION F1,F2,F3,F4,F5,F6,G1,G2,G3,G4,G5,G6
      DOUBLE PRECISION S3,S4,S5,S6,X2,X3,Y2,Y3,Z1,Z2,Z3,Z4,Z5,Z6
      INTEGER I1,I2,I3,I4,I5,I6
!
      DOUBLE PRECISION XS1440,XS720,XMU
!
!-----------------------------------------------------------------------
!
!     INITIALISES
!
      XS1440 = XMUL/1440.D0
      XS720  = XMUL/720.D0
!
      IELMF = SF%ELM
      IELMG = SG%ELM
!
!-----------------------------------------------------------------------
!
!     F AND G ARE LINEAR
!
      IF (IELMF.EQ.41.AND.IELMG.EQ.41) THEN
!
      IF (ICOORD.EQ.1) THEN
!
!-----------------------------------------------------------------------
!  DERIVATIVE WRT X
!
      DO 3, IELEM = 1 , NELEM
!
         I1 = IKLE1(IELEM)
         I2 = IKLE2(IELEM)
         I3 = IKLE3(IELEM)
         I4 = IKLE4(IELEM)
         I5 = IKLE5(IELEM)
         I6 = IKLE6(IELEM)
!
         F1 = F(I1)
         F2 = F(I2)
         F3 = F(I3)
         F4 = F(I4)
         F5 = F(I5)
         F6 = F(I6)
!
         G1 = G(I1)
         G2 = G(I2)
         G3 = G(I3)
         G4 = G(I4)
         G5 = G(I5)
         G6 = G(I6)
!
!  REAL COORDINATES OF THE POINTS OF THE ELEMENT (ORIGIN IN 1)
!
         Y2  =  Y(I2) - Y(I1)
         Y3  =  Y(I3) - Y(I1)
         Z1  =  Z(I1)
         Z2  =  Z(I2)
         Z3  =  Z(I3)
         Z4  =  Z(I4)
         Z5  =  Z(I5)
         Z6  =  Z(I6)
!
!     VC11PP_X (FROM MAPLE)
!
      S3 = ((-24*G1-12*G2-9*G3-8*G4-4*G5-3*G6)*F2+(-6*G1-3*G2-6*G3-2*G4-
     &G5-2*G6)*F3+(24*G1+8*G2+8*G3+12*G4+4*G5+4*G6)*F4+(4*G2+G3-4*G4-G6)
     &*F5+(6*G1+3*G2+6*G3+2*G4+G5+2*G6)*F6)*Z1+((24*G1+12*G2+9*G3+8*G4+4
     &*G5+3*G6)*F1+(6*G1+3*G2+6*G3+2*G4+G5+2*G6)*F3+(-16*G1-4*G2-5*G3-4*
     &G4-G6)*F4+(-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F5+(-6*G1-3*G2-6*G3-2*G
     &4-G5-2*G6)*F6)*Z2+((6*G1+3*G2+6*G3+2*G4+G5+2*G6)*F1+(-6*G1-3*G2-6*
     &G3-2*G4-G5-2*G6)*F2+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F4+(-2*G1-G2-2*G3-
     &2*G4-G5-2*G6)*F5)*Z3
      S4 = ((-24*G1-8*G2-8*G3-12*G4-4*G5-4*G6)*F1+(16*G1+4*G2+5*G3+4*
     &G4+G6)*F2+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F3+(8*G1+4*G2+3*G3+8*G4+4*G
     &5+3*G6)*F5+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F6)*Z4+((-4*G2-G3+4*G4+G6)*
     &F1+(8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F2+(2*G1+G2+2*G3+2*G4+G5+2*G6)*
     &F3+(-8*G1-4*G2-3*G3-8*G4-4*G5-3*G6)*F4+(-2*G1-G2-2*G3-2*G4-G5-2*G6
     &)*F6)*Z5+((-6*G1-3*G2-6*G3-2*G4-G5-2*G6)*F1+(6*G1+3*G2+6*G3+2*G4+G
     &5+2*G6)*F2+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F4+(2*G1+G2+2*G3+2*G4+G5+2
     &*G6)*F5)*Z6
      S6 = ((6*G1+6*G2+3*G3+2*G4+2*G5+G6)*F2+(24*G1+9*G2+12*G3+8*G4+3*G5
     &+4*G6)*F3+(-24*G1-8*G2-8*G3-12*G4-4*G5-4*G6)*F4+(-6*G1-6*G2-3*G3-2
     &*G4-2*G5-G6)*F5+(-G2-4*G3+4*G4+G5)*F6)*Z1+((-6*G1-6*G2-3*G3-2*G4-2
     &*G5-G6)*F1+(6*G1+6*G2+3*G3+2*G4+2*G5+G6)*F3+(-2*G1-2*G2-G3-2*G4-2*
     &G5-G6)*F4+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F6)*Z2+((-24*G1-9*G2-12*G3-8
     &*G4-3*G5-4*G6)*F1+(-6*G1-6*G2-3*G3-2*G4-2*G5-G6)*F2+(16*G1+5*G2+4*
     &G3+4*G4+G5)*F4+(6*G1+6*G2+3*G3+2*G4+2*G5+G6)*F5+(8*G1+4*G2+8*G3+4*
     &G4+2*G5+4*G6)*F6)*Z3
      S5 = ((24*G1+8*G2+8*G3+12*G4+4*G5+4*G6)*F1+(2*G1+2*G2+G3+2*G4+2
     &*G5+G6)*F2+(-16*G1-5*G2-4*G3-4*G4-G5)*F3+(-2*G1-2*G2-G3-2*G4-2*G5-
     &G6)*F5+(-8*G1-3*G2-4*G3-8*G4-3*G5-4*G6)*F6)*Z4+((6*G1+6*G2+3*G3+2*
     &G4+2*G5+G6)*F1+(-6*G1-6*G2-3*G3-2*G4-2*G5-G6)*F3+(2*G1+2*G2+G3+2*G
     &4+2*G5+G6)*F4+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F6)*Z5+((G2+4*G3-4*G4-G
     &5)*F1+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F2+(-8*G1-4*G2-8*G3-4*G4-2*G5-4
     &*G6)*F3+(8*G1+3*G2+4*G3+8*G4+3*G5+4*G6)*F4+(2*G1+2*G2+G3+2*G4+2*G5
     &+G6)*F5)*Z6
      W1(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
      S3 = ((-12*G1-24*G2-9*G3-4*G4-8*G5-3*G6)*F2+(-3*G1-6*G2-6*G3-G4-2*
     &G5-2*G6)*F3+(8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F4+(4*G1+16*G2+5*G3+4*
     &G5+G6)*F5+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F6)*Z1+((12*G1+24*G2+9*G3+
     &4*G4+8*G5+3*G6)*F1+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F3+(-4*G1-G3+4*G5
     &+G6)*F4+(-8*G1-24*G2-8*G3-4*G4-12*G5-4*G6)*F5+(-3*G1-6*G2-6*G3-G4-
     &2*G5-2*G6)*F6)*Z2+((3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F1+(-3*G1-6*G2-6*
     &G3-G4-2*G5-2*G6)*F2+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F4+(-G1-2*G2-2*G3-
     &G4-2*G5-2*G6)*F5)*Z3
      S4 = ((-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F1+(4*G1+G3-4*G5-G6)*F2+
     &(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F3+(4*G1+8*G2+3*G3+4*G4+8*G5+3*G6)*F5
     &+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F6)*Z4+((-4*G1-16*G2-5*G3-4*G5-G6)*F1
     &+(8*G1+24*G2+8*G3+4*G4+12*G5+4*G6)*F2+(G1+2*G2+2*G3+G4+2*G5+2*G6)*
     &F3+(-4*G1-8*G2-3*G3-4*G4-8*G5-3*G6)*F4+(-G1-2*G2-2*G3-G4-2*G5-2*G6
     &)*F6)*Z5+((-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F1+(3*G1+6*G2+6*G3+G4+2*G
     &5+2*G6)*F2+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F4+(G1+2*G2+2*G3+G4+2*G5+2
     &*G6)*F5)*Z6
      S6 = ((6*G1+18*G2+6*G3+2*G4+6*G5+2*G6)*F2+(9*G1+12*G2+9*G3+3*G4+4*
     &G5+3*G6)*F3+(-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F4+(-6*G1-18*G2-6*G3-
     &2*G4-6*G5-2*G6)*F5+(-G1-4*G2-5*G3+G4-G6)*F6)*Z1+((-6*G1-18*G2-6*G3
     &-2*G4-6*G5-2*G6)*F1+(6*G1+18*G2+6*G3+2*G4+6*G5+2*G6)*F3+(-2*G1-6*G
     &2-2*G3-2*G4-6*G5-2*G6)*F4+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F6)*Z2+(
     &(-9*G1-12*G2-9*G3-3*G4-4*G5-3*G6)*F1+(-6*G1-18*G2-6*G3-2*G4-6*G5-2
     &*G6)*F2+(5*G1+4*G2+G3+G4-G6)*F4+(6*G1+18*G2+6*G3+2*G4+6*G5+2*G6)*F
     &5+(4*G1+8*G2+8*G3+2*G4+4*G5+4*G6)*F6)*Z3
      S5 = ((8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F1+(2*G1+6*G2+2*G3+2*G4+6
     &*G5+2*G6)*F2+(-5*G1-4*G2-G3-G4+G6)*F3+(-2*G1-6*G2-2*G3-2*G4-6*G5-2
     &*G6)*F5+(-3*G1-4*G2-3*G3-3*G4-4*G5-3*G6)*F6)*Z4+((6*G1+18*G2+6*G3+
     &2*G4+6*G5+2*G6)*F1+(-6*G1-18*G2-6*G3-2*G4-6*G5-2*G6)*F3+(2*G1+6*G2
     &+2*G3+2*G4+6*G5+2*G6)*F4+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F6)*Z5+(
     &(G1+4*G2+5*G3-G4+G6)*F1+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F2+(-4*G1
     &-8*G2-8*G3-2*G4-4*G5-4*G6)*F3+(3*G1+4*G2+3*G3+3*G4+4*G5+3*G6)*F4+(
     &2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F5)*Z6
      W2(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
      S3 = ((-9*G1-9*G2-12*G3-3*G4-3*G5-4*G6)*F2+(-6*G1-6*G2-18*G3-2*G4-
     &2*G5-6*G6)*F3+(8*G1+4*G2+8*G3+4*G4+2*G5+4*G6)*F4+(G1+5*G2+4*G3-G4+
     &G5)*F5+(6*G1+6*G2+18*G3+2*G4+2*G5+6*G6)*F6)*Z1+((9*G1+9*G2+12*G3+3
     &*G4+3*G5+4*G6)*F1+(6*G1+6*G2+18*G3+2*G4+2*G5+6*G6)*F3+(-5*G1-G2-4*
     &G3-G4+G5)*F4+(-4*G1-8*G2-8*G3-2*G4-4*G5-4*G6)*F5+(-6*G1-6*G2-18*G3
     &-2*G4-2*G5-6*G6)*F6)*Z2+((6*G1+6*G2+18*G3+2*G4+2*G5+6*G6)*F1+(-6*G
     &1-6*G2-18*G3-2*G4-2*G5-6*G6)*F2+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F4
     &+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F5)*Z3
      S4 = ((-8*G1-4*G2-8*G3-4*G4-2*G5-4*G6)*F1+(5*G1+G2+4*G3+G4-G5)*
     &F2+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F3+(3*G1+3*G2+4*G3+3*G4+3*G5+4
     &*G6)*F5+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F6)*Z4+((-G1-5*G2-4*G3+G4-
     &G5)*F1+(4*G1+8*G2+8*G3+2*G4+4*G5+4*G6)*F2+(2*G1+2*G2+6*G3+2*G4+2*G
     &5+6*G6)*F3+(-3*G1-3*G2-4*G3-3*G4-3*G5-4*G6)*F4+(-2*G1-2*G2-6*G3-2*
     &G4-2*G5-6*G6)*F6)*Z5+((-6*G1-6*G2-18*G3-2*G4-2*G5-6*G6)*F1+(6*G1+6
     &*G2+18*G3+2*G4+2*G5+6*G6)*F2+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F4+(
     &2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F5)*Z6
      S6 = ((3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F2+(12*G1+9*G2+24*G3+4*G4+3*G5
     &+8*G6)*F3+(-8*G1-4*G2-8*G3-4*G4-2*G5-4*G6)*F4+(-3*G1-6*G2-6*G3-G4-
     &2*G5-2*G6)*F5+(-4*G1-5*G2-16*G3-G5-4*G6)*F6)*Z1+((-3*G1-6*G2-6*G3-
     &G4-2*G5-2*G6)*F1+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F3+(-G1-2*G2-2*G3-G
     &4-2*G5-2*G6)*F4+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F6)*Z2+((-12*G1-9*G2-2
     &4*G3-4*G4-3*G5-8*G6)*F1+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F2+(4*G1+G2
     &-G5-4*G6)*F4+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F5+(8*G1+8*G2+24*G3+4*G
     &4+4*G5+12*G6)*F6)*Z3
      S5 = ((8*G1+4*G2+8*G3+4*G4+2*G5+4*G6)*F1+(G1+2*G2+2*G3+G4+2*G5+
     &2*G6)*F2+(-4*G1-G2+G5+4*G6)*F3+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F5+(-4
     &*G1-3*G2-8*G3-4*G4-3*G5-8*G6)*F6)*Z4+((3*G1+6*G2+6*G3+G4+2*G5+2*G6
     &)*F1+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F3+(G1+2*G2+2*G3+G4+2*G5+2*G6)
     &*F4+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F6)*Z5+((4*G1+5*G2+16*G3+G5+4*G6)
     &*F1+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F2+(-8*G1-8*G2-24*G3-4*G4-4*G5-12
     &*G6)*F3+(4*G1+3*G2+8*G3+4*G4+3*G5+8*G6)*F4+(G1+2*G2+2*G3+G4+2*G5+2
     &*G6)*F5)*Z6
      W3(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
      S3 = ((-8*G1-4*G2-3*G3-8*G4-4*G5-3*G6)*F2+(-2*G1-G2-2*G3-2*G4-G5-2
     &*G6)*F3+(12*G1+4*G2+4*G3+24*G4+8*G5+8*G6)*F4+(-4*G1-G3-16*G4-4*G5-
     &5*G6)*F5+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F6)*Z1+((8*G1+4*G2+3*G3+8*G4+
     &4*G5+3*G6)*F1+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F3+(-4*G1-G3+4*G5+G6)*F4
     &+(-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F5+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*
     &F6)*Z2+((2*G1+G2+2*G3+2*G4+G5+2*G6)*F1+(-2*G1-G2-2*G3-2*G4-G5-2*G6
     &)*F2+(2*G1+G2+2*G3+6*G4+3*G5+6*G6)*F4+(-2*G1-G2-2*G3-6*G4-3*G5-6*G
     &6)*F5)*Z3
      S4 = ((-12*G1-4*G2-4*G3-24*G4-8*G5-8*G6)*F1+(4*G1+G3-4*G5-G6)*F
     &2+(-2*G1-G2-2*G3-6*G4-3*G5-6*G6)*F3+(8*G1+4*G2+3*G3+24*G4+12*G5+9*
     &G6)*F5+(2*G1+G2+2*G3+6*G4+3*G5+6*G6)*F6)*Z4+((4*G1+G3+16*G4+4*G5+5
     &*G6)*F1+(4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F2+(2*G1+G2+2*G3+6*G4+3*G5
     &+6*G6)*F3+(-8*G1-4*G2-3*G3-24*G4-12*G5-9*G6)*F4+(-2*G1-G2-2*G3-6*G
     &4-3*G5-6*G6)*F6)*Z5+((-2*G1-G2-2*G3-2*G4-G5-2*G6)*F1+(2*G1+G2+2*G3
     &+2*G4+G5+2*G6)*F2+(-2*G1-G2-2*G3-6*G4-3*G5-6*G6)*F4+(2*G1+G2+2*G3+
     &6*G4+3*G5+6*G6)*F5)*Z6
      S6 = ((2*G1+2*G2+G3+2*G4+2*G5+G6)*F2+(8*G1+3*G2+4*G3+8*G4+3*G5+4*G
     &6)*F3+(-12*G1-4*G2-4*G3-24*G4-8*G5-8*G6)*F4+(-2*G1-2*G2-G3-2*G4-2*
     &G5-G6)*F5+(4*G1+G2+16*G4+5*G5+4*G6)*F6)*Z1+((-2*G1-2*G2-G3-2*G4-2*
     &G5-G6)*F1+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F3+(-2*G1-2*G2-G3-6*G4-6*G5-
     &3*G6)*F4+(2*G1+2*G2+G3+6*G4+6*G5+3*G6)*F6)*Z2+((-8*G1-3*G2-4*G3-8*
     &G4-3*G5-4*G6)*F1+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F2+(4*G1+G2-G5-4*G6)
     &*F4+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F5+(4*G1+2*G2+4*G3+8*G4+4*G5+8*G6)
     &*F6)*Z3
      S5 = ((12*G1+4*G2+4*G3+24*G4+8*G5+8*G6)*F1+(2*G1+2*G2+G3+6*G4+6
     &*G5+3*G6)*F2+(-4*G1-G2+G5+4*G6)*F3+(-2*G1-2*G2-G3-6*G4-6*G5-3*G6)*
     &F5+(-8*G1-3*G2-4*G3-24*G4-9*G5-12*G6)*F6)*Z4+((2*G1+2*G2+G3+2*G4+2
     &*G5+G6)*F1+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F3+(2*G1+2*G2+G3+6*G4+6*G5
     &+3*G6)*F4+(-2*G1-2*G2-G3-6*G4-6*G5-3*G6)*F6)*Z5+((-4*G1-G2-16*G4-5
     &*G5-4*G6)*F1+(-2*G1-2*G2-G3-6*G4-6*G5-3*G6)*F2+(-4*G1-2*G2-4*G3-8*
     &G4-4*G5-8*G6)*F3+(8*G1+3*G2+4*G3+24*G4+9*G5+12*G6)*F4+(2*G1+2*G2+G
     &3+6*G4+6*G5+3*G6)*F5)*Z6
      W4(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
      S3 = ((-4*G1-8*G2-3*G3-4*G4-8*G5-3*G6)*F2+(-G1-2*G2-2*G3-G4-2*G5-2
     &*G6)*F3+(4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F4+(4*G2+G3-4*G4-G6)*F5+(G
     &1+2*G2+2*G3+G4+2*G5+2*G6)*F6)*Z1+((4*G1+8*G2+3*G3+4*G4+8*G5+3*G6)*
     &F1+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F3+(4*G2+G3+4*G4+16*G5+5*G6)*F4+(-4
     &*G1-12*G2-4*G3-8*G4-24*G5-8*G6)*F5+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F6
     &)*Z2+((G1+2*G2+2*G3+G4+2*G5+2*G6)*F1+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*
     &F2+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F4+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)
     &*F5)*Z3
      S4 = ((-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F1+(-4*G2-G3-4*G4-16*G5-
     &5*G6)*F2+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F3+(4*G1+8*G2+3*G3+12*G4+2
     &4*G5+9*G6)*F5+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F6)*Z4+((-4*G2-G3+4*G4
     &+G6)*F1+(4*G1+12*G2+4*G3+8*G4+24*G5+8*G6)*F2+(G1+2*G2+2*G3+3*G4+6*
     &G5+6*G6)*F3+(-4*G1-8*G2-3*G3-12*G4-24*G5-9*G6)*F4+(-G1-2*G2-2*G3-3
     &*G4-6*G5-6*G6)*F6)*Z5+((-G1-2*G2-2*G3-G4-2*G5-2*G6)*F1+(G1+2*G2+2*
     &G3+G4+2*G5+2*G6)*F2+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F4+(G1+2*G2+2*G
     &3+3*G4+6*G5+6*G6)*F5)*Z6
      S6 = ((2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F2+(3*G1+4*G2+3*G3+3*G4+4*G5
     &+3*G6)*F3+(-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F4+(-2*G1-6*G2-2*G3-2*G
     &4-6*G5-2*G6)*F5+(G1-G3+5*G4+4*G5+G6)*F6)*Z1+((-2*G1-6*G2-2*G3-2*G4
     &-6*G5-2*G6)*F1+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F3+(-2*G1-6*G2-2*G3
     &-6*G4-18*G5-6*G6)*F4+(2*G1+6*G2+2*G3+6*G4+18*G5+6*G6)*F6)*Z2+((-3*
     &G1-4*G2-3*G3-3*G4-4*G5-3*G6)*F1+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F
     &2+(G1-G3-G4-4*G5-5*G6)*F4+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F5+(2*G1
     &+4*G2+4*G3+4*G4+8*G5+8*G6)*F6)*Z3
      S5 = ((4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F1+(2*G1+6*G2+2*G3+6*G4+1
     &8*G5+6*G6)*F2+(-G1+G3+G4+4*G5+5*G6)*F3+(-2*G1-6*G2-2*G3-6*G4-18*G5
     &-6*G6)*F5+(-3*G1-4*G2-3*G3-9*G4-12*G5-9*G6)*F6)*Z4+((2*G1+6*G2+2*G
     &3+2*G4+6*G5+2*G6)*F1+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F3+(2*G1+6*G
     &2+2*G3+6*G4+18*G5+6*G6)*F4+(-2*G1-6*G2-2*G3-6*G4-18*G5-6*G6)*F6)*Z
     &5+((-G1+G3-5*G4-4*G5-G6)*F1+(-2*G1-6*G2-2*G3-6*G4-18*G5-6*G6)*F2+(
     &-2*G1-4*G2-4*G3-4*G4-8*G5-8*G6)*F3+(3*G1+4*G2+3*G3+9*G4+12*G5+9*G6
     &)*F4+(2*G1+6*G2+2*G3+6*G4+18*G5+6*G6)*F5)*Z6
      W5(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
      S3 = ((-3*G1-3*G2-4*G3-3*G4-3*G5-4*G6)*F2+(-2*G1-2*G2-6*G3-2*G4-2*
     &G5-6*G6)*F3+(4*G1+2*G2+4*G3+8*G4+4*G5+8*G6)*F4+(-G1+G2-5*G4-G5-4*G
     &6)*F5+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F6)*Z1+((3*G1+3*G2+4*G3+3*G4
     &+3*G5+4*G6)*F1+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F3+(-G1+G2+G4+5*G5+
     &4*G6)*F4+(-2*G1-4*G2-4*G3-4*G4-8*G5-8*G6)*F5+(-2*G1-2*G2-6*G3-2*G4
     &-2*G5-6*G6)*F6)*Z2+((2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F1+(-2*G1-2*G2
     &-6*G3-2*G4-2*G5-6*G6)*F2+(2*G1+2*G2+6*G3+6*G4+6*G5+18*G6)*F4+(-2*G
     &1-2*G2-6*G3-6*G4-6*G5-18*G6)*F5)*Z3
      S4 = ((-4*G1-2*G2-4*G3-8*G4-4*G5-8*G6)*F1+(G1-G2-G4-5*G5-4*G6)*
     &F2+(-2*G1-2*G2-6*G3-6*G4-6*G5-18*G6)*F3+(3*G1+3*G2+4*G3+9*G4+9*G5+
     &12*G6)*F5+(2*G1+2*G2+6*G3+6*G4+6*G5+18*G6)*F6)*Z4+((G1-G2+5*G4+G5+
     &4*G6)*F1+(2*G1+4*G2+4*G3+4*G4+8*G5+8*G6)*F2+(2*G1+2*G2+6*G3+6*G4+6
     &*G5+18*G6)*F3+(-3*G1-3*G2-4*G3-9*G4-9*G5-12*G6)*F4+(-2*G1-2*G2-6*G
     &3-6*G4-6*G5-18*G6)*F6)*Z5+((-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F1+(2*
     &G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F2+(-2*G1-2*G2-6*G3-6*G4-6*G5-18*G6)*
     &F4+(2*G1+2*G2+6*G3+6*G4+6*G5+18*G6)*F5)*Z6
      S6 = ((G1+2*G2+2*G3+G4+2*G5+2*G6)*F2+(4*G1+3*G2+8*G3+4*G4+3*G5+8*G
     &6)*F3+(-4*G1-2*G2-4*G3-8*G4-4*G5-8*G6)*F4+(-G1-2*G2-2*G3-G4-2*G5-2
     &*G6)*F5+(-G2-4*G3+4*G4+G5)*F6)*Z1+((-G1-2*G2-2*G3-G4-2*G5-2*G6)*F1
     &+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F3+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F4+
     &(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F6)*Z2+((-4*G1-3*G2-8*G3-4*G4-3*G5-8
     &*G6)*F1+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F2+(-G2-4*G3-4*G4-5*G5-16*G6)
     &*F4+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F5+(4*G1+4*G2+12*G3+8*G4+8*G5+24*G
     &6)*F6)*Z3
      S5 = ((4*G1+2*G2+4*G3+8*G4+4*G5+8*G6)*F1+(G1+2*G2+2*G3+3*G4+6*G
     &5+6*G6)*F2+(G2+4*G3+4*G4+5*G5+16*G6)*F3+(-G1-2*G2-2*G3-3*G4-6*G5-6
     &*G6)*F5+(-4*G1-3*G2-8*G3-12*G4-9*G5-24*G6)*F6)*Z4+((G1+2*G2+2*G3+G
     &4+2*G5+2*G6)*F1+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F3+(G1+2*G2+2*G3+3*G4
     &+6*G5+6*G6)*F4+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F6)*Z5+((G2+4*G3-4*G
     &4-G5)*F1+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F2+(-4*G1-4*G2-12*G3-8*G4-
     &8*G5-24*G6)*F3+(4*G1+3*G2+8*G3+12*G4+9*G5+24*G6)*F4+(G1+2*G2+2*G3+
     &3*G4+6*G5+6*G6)*F5)*Z6
      W6(IELEM) = ((S3+S4)*Y3+(S6+S5)*Y2)*XS1440
!
 3    ENDDO
!
      ELSE IF (ICOORD.EQ.2) THEN
!
!-----------------------------------------------------------------------
!  DERIVATIVE WRT Y
!
      DO 4, IELEM = 1 , NELEM
!
         I1 = IKLE1(IELEM)
         I2 = IKLE2(IELEM)
         I3 = IKLE3(IELEM)
         I4 = IKLE4(IELEM)
         I5 = IKLE5(IELEM)
         I6 = IKLE6(IELEM)
!
         F1 = F(I1)
         F2 = F(I2)
         F3 = F(I3)
         F4 = F(I4)
         F5 = F(I5)
         F6 = F(I6)
!
         G1 = G(I1)
         G2 = G(I2)
         G3 = G(I3)
         G4 = G(I4)
         G5 = G(I5)
         G6 = G(I6)
!
!  REAL COORDINATES OF THE POINTS OF THE ELEMENT (ORIGIN IN 1)
!
         X2  =  X(I2) - X(I1)
         X3  =  X(I3) - X(I1)
         Z1  =  Z(I1)
         Z2  =  Z(I2)
         Z3  =  Z(I3)
         Z4  =  Z(I4)
         Z5  =  Z(I5)
         Z6  =  Z(I6)
!
!     VC11PP_Y (FROM MAPLE)
!
      S3 = ((24*G1+12*G2+9*G3+8*G4+4*G5+3*G6)*F2+(6*G1+3*G2+6*G3+2*G4+G5
     &+2*G6)*F3+(-24*G1-8*G2-8*G3-12*G4-4*G5-4*G6)*F4+(-4*G2-G3+4*G4+G6)
     &*F5+(-6*G1-3*G2-6*G3-2*G4-G5-2*G6)*F6)*Z1+((-24*G1-12*G2-9*G3-8*G4
     &-4*G5-3*G6)*F1+(-6*G1-3*G2-6*G3-2*G4-G5-2*G6)*F3+(16*G1+4*G2+5*G3+
     &4*G4+G6)*F4+(8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F5+(6*G1+3*G2+6*G3+2*G
     &4+G5+2*G6)*F6)*Z2+((-6*G1-3*G2-6*G3-2*G4-G5-2*G6)*F1+(6*G1+3*G2+6*
     &G3+2*G4+G5+2*G6)*F2+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F4+(2*G1+G2+2*G3+
     &2*G4+G5+2*G6)*F5)*Z3
      S4 = ((24*G1+8*G2+8*G3+12*G4+4*G5+4*G6)*F1+(-16*G1-4*G2-5*G3-4*
     &G4-G6)*F2+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F3+(-8*G1-4*G2-3*G3-8*G4-4*G
     &5-3*G6)*F5+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F6)*Z4+((4*G2+G3-4*G4-G6)*
     &F1+(-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F2+(-2*G1-G2-2*G3-2*G4-G5-2*G6
     &)*F3+(8*G1+4*G2+3*G3+8*G4+4*G5+3*G6)*F4+(2*G1+G2+2*G3+2*G4+G5+2*G6
     &)*F6)*Z5+((6*G1+3*G2+6*G3+2*G4+G5+2*G6)*F1+(-6*G1-3*G2-6*G3-2*G4-G
     &5-2*G6)*F2+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F4+(-2*G1-G2-2*G3-2*G4-G5-2
     &*G6)*F5)*Z6
      S6 = ((-6*G1-6*G2-3*G3-2*G4-2*G5-G6)*F2+(-24*G1-9*G2-12*G3-8*G4-3*
     &G5-4*G6)*F3+(24*G1+8*G2+8*G3+12*G4+4*G5+4*G6)*F4+(6*G1+6*G2+3*G3+2
     &*G4+2*G5+G6)*F5+(G2+4*G3-4*G4-G5)*F6)*Z1+((6*G1+6*G2+3*G3+2*G4+2*G
     &5+G6)*F1+(-6*G1-6*G2-3*G3-2*G4-2*G5-G6)*F3+(2*G1+2*G2+G3+2*G4+2*G5
     &+G6)*F4+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F6)*Z2+((24*G1+9*G2+12*G3+8*G
     &4+3*G5+4*G6)*F1+(6*G1+6*G2+3*G3+2*G4+2*G5+G6)*F2+(-16*G1-5*G2-4*G3
     &-4*G4-G5)*F4+(-6*G1-6*G2-3*G3-2*G4-2*G5-G6)*F5+(-8*G1-4*G2-8*G3-4*
     &G4-2*G5-4*G6)*F6)*Z3
      S5 = ((-24*G1-8*G2-8*G3-12*G4-4*G5-4*G6)*F1+(-2*G1-2*G2-G3-2*G4
     &-2*G5-G6)*F2+(16*G1+5*G2+4*G3+4*G4+G5)*F3+(2*G1+2*G2+G3+2*G4+2*G5+
     &G6)*F5+(8*G1+3*G2+4*G3+8*G4+3*G5+4*G6)*F6)*Z4+((-6*G1-6*G2-3*G3-2*
     &G4-2*G5-G6)*F1+(6*G1+6*G2+3*G3+2*G4+2*G5+G6)*F3+(-2*G1-2*G2-G3-2*G
     &4-2*G5-G6)*F4+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F6)*Z5+((-G2-4*G3+4*G4+G
     &5)*F1+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F2+(8*G1+4*G2+8*G3+4*G4+2*G5+4*G
     &6)*F3+(-8*G1-3*G2-4*G3-8*G4-3*G5-4*G6)*F4+(-2*G1-2*G2-G3-2*G4-2*G5
     &-G6)*F5)*Z6
      W1(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
      S3 = ((12*G1+24*G2+9*G3+4*G4+8*G5+3*G6)*F2+(3*G1+6*G2+6*G3+G4+2*G5
     &+2*G6)*F3+(-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F4+(-4*G1-16*G2-5*G3-4*
     &G5-G6)*F5+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F6)*Z1+((-12*G1-24*G2-9*G
     &3-4*G4-8*G5-3*G6)*F1+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F3+(4*G1+G3-4*
     &G5-G6)*F4+(8*G1+24*G2+8*G3+4*G4+12*G5+4*G6)*F5+(3*G1+6*G2+6*G3+G4+
     &2*G5+2*G6)*F6)*Z2+((-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F1+(3*G1+6*G2+6*
     &G3+G4+2*G5+2*G6)*F2+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F4+(G1+2*G2+2*G3+
     &G4+2*G5+2*G6)*F5)*Z3
      S4 = ((8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F1+(-4*G1-G3+4*G5+G6)*F2+
     &(G1+2*G2+2*G3+G4+2*G5+2*G6)*F3+(-4*G1-8*G2-3*G3-4*G4-8*G5-3*G6)*F5
     &+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F6)*Z4+((4*G1+16*G2+5*G3+4*G5+G6)*F1
     &+(-8*G1-24*G2-8*G3-4*G4-12*G5-4*G6)*F2+(-G1-2*G2-2*G3-G4-2*G5-2*G6
     &)*F3+(4*G1+8*G2+3*G3+4*G4+8*G5+3*G6)*F4+(G1+2*G2+2*G3+G4+2*G5+2*G6
     &)*F6)*Z5+((3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F1+(-3*G1-6*G2-6*G3-G4-2*G
     &5-2*G6)*F2+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F4+(-G1-2*G2-2*G3-G4-2*G5-2
     &*G6)*F5)*Z6
      S6 = ((-6*G1-18*G2-6*G3-2*G4-6*G5-2*G6)*F2+(-9*G1-12*G2-9*G3-3*G4-
     &4*G5-3*G6)*F3+(8*G1+8*G2+4*G3+4*G4+4*G5+2*G6)*F4+(6*G1+18*G2+6*G3+
     &2*G4+6*G5+2*G6)*F5+(G1+4*G2+5*G3-G4+G6)*F6)*Z1+((6*G1+18*G2+6*G3+2
     &*G4+6*G5+2*G6)*F1+(-6*G1-18*G2-6*G3-2*G4-6*G5-2*G6)*F3+(2*G1+6*G2+
     &2*G3+2*G4+6*G5+2*G6)*F4+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F6)*Z2+((
     &9*G1+12*G2+9*G3+3*G4+4*G5+3*G6)*F1+(6*G1+18*G2+6*G3+2*G4+6*G5+2*G6
     &)*F2+(-5*G1-4*G2-G3-G4+G6)*F4+(-6*G1-18*G2-6*G3-2*G4-6*G5-2*G6)*F5
     &+(-4*G1-8*G2-8*G3-2*G4-4*G5-4*G6)*F6)*Z3
      S5 = ((-8*G1-8*G2-4*G3-4*G4-4*G5-2*G6)*F1+(-2*G1-6*G2-2*G3-2*G4
     &-6*G5-2*G6)*F2+(5*G1+4*G2+G3+G4-G6)*F3+(2*G1+6*G2+2*G3+2*G4+6*G5+2
     &*G6)*F5+(3*G1+4*G2+3*G3+3*G4+4*G5+3*G6)*F6)*Z4+((-6*G1-18*G2-6*G3-
     &2*G4-6*G5-2*G6)*F1+(6*G1+18*G2+6*G3+2*G4+6*G5+2*G6)*F3+(-2*G1-6*G2
     &-2*G3-2*G4-6*G5-2*G6)*F4+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F6)*Z5+((
     &-G1-4*G2-5*G3+G4-G6)*F1+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F2+(4*G1+8
     &*G2+8*G3+2*G4+4*G5+4*G6)*F3+(-3*G1-4*G2-3*G3-3*G4-4*G5-3*G6)*F4+(-
     &2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F5)*Z6
      W2(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
      S3 = ((9*G1+9*G2+12*G3+3*G4+3*G5+4*G6)*F2+(6*G1+6*G2+18*G3+2*G4+2*
     &G5+6*G6)*F3+(-8*G1-4*G2-8*G3-4*G4-2*G5-4*G6)*F4+(-G1-5*G2-4*G3+G4-
     &G5)*F5+(-6*G1-6*G2-18*G3-2*G4-2*G5-6*G6)*F6)*Z1+((-9*G1-9*G2-12*G3
     &-3*G4-3*G5-4*G6)*F1+(-6*G1-6*G2-18*G3-2*G4-2*G5-6*G6)*F3+(5*G1+G2+
     &4*G3+G4-G5)*F4+(4*G1+8*G2+8*G3+2*G4+4*G5+4*G6)*F5+(6*G1+6*G2+18*G3
     &+2*G4+2*G5+6*G6)*F6)*Z2+((-6*G1-6*G2-18*G3-2*G4-2*G5-6*G6)*F1+(6*G
     &1+6*G2+18*G3+2*G4+2*G5+6*G6)*F2+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F
     &4+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F5)*Z3
      S4 = ((8*G1+4*G2+8*G3+4*G4+2*G5+4*G6)*F1+(-5*G1-G2-4*G3-G4+G5)*
     &F2+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F3+(-3*G1-3*G2-4*G3-3*G4-3*G5-4
     &*G6)*F5+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F6)*Z4+((G1+5*G2+4*G3-G4+
     &G5)*F1+(-4*G1-8*G2-8*G3-2*G4-4*G5-4*G6)*F2+(-2*G1-2*G2-6*G3-2*G4-2
     &*G5-6*G6)*F3+(3*G1+3*G2+4*G3+3*G4+3*G5+4*G6)*F4+(2*G1+2*G2+6*G3+2*
     &G4+2*G5+6*G6)*F6)*Z5+((6*G1+6*G2+18*G3+2*G4+2*G5+6*G6)*F1+(-6*G1-6
     &*G2-18*G3-2*G4-2*G5-6*G6)*F2+(2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F4+(-
     &2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F5)*Z6
      S6 = ((-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F2+(-12*G1-9*G2-24*G3-4*G4-3*
     &G5-8*G6)*F3+(8*G1+4*G2+8*G3+4*G4+2*G5+4*G6)*F4+(3*G1+6*G2+6*G3+G4+
     &2*G5+2*G6)*F5+(4*G1+5*G2+16*G3+G5+4*G6)*F6)*Z1+((3*G1+6*G2+6*G3+G4
     &+2*G5+2*G6)*F1+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F3+(G1+2*G2+2*G3+G4+
     &2*G5+2*G6)*F4+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F6)*Z2+((12*G1+9*G2+24*
     &G3+4*G4+3*G5+8*G6)*F1+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F2+(-4*G1-G2+G
     &5+4*G6)*F4+(-3*G1-6*G2-6*G3-G4-2*G5-2*G6)*F5+(-8*G1-8*G2-24*G3-4*G
     &4-4*G5-12*G6)*F6)*Z3
      S5 = ((-8*G1-4*G2-8*G3-4*G4-2*G5-4*G6)*F1+(-G1-2*G2-2*G3-G4-2*G
     &5-2*G6)*F2+(4*G1+G2-G5-4*G6)*F3+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F5+(4*
     &G1+3*G2+8*G3+4*G4+3*G5+8*G6)*F6)*Z4+((-3*G1-6*G2-6*G3-G4-2*G5-2*G6
     &)*F1+(3*G1+6*G2+6*G3+G4+2*G5+2*G6)*F3+(-G1-2*G2-2*G3-G4-2*G5-2*G6)
     &*F4+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F6)*Z5+((-4*G1-5*G2-16*G3-G5-4*G6)
     &*F1+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F2+(8*G1+8*G2+24*G3+4*G4+4*G5+12*G
     &6)*F3+(-4*G1-3*G2-8*G3-4*G4-3*G5-8*G6)*F4+(-G1-2*G2-2*G3-G4-2*G5-2
     &*G6)*F5)*Z6
      W3(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
      S3 = ((8*G1+4*G2+3*G3+8*G4+4*G5+3*G6)*F2+(2*G1+G2+2*G3+2*G4+G5+2*G
     &6)*F3+(-12*G1-4*G2-4*G3-24*G4-8*G5-8*G6)*F4+(4*G1+G3+16*G4+4*G5+5*
     &G6)*F5+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F6)*Z1+((-8*G1-4*G2-3*G3-8*G4-
     &4*G5-3*G6)*F1+(-2*G1-G2-2*G3-2*G4-G5-2*G6)*F3+(4*G1+G3-4*G5-G6)*F4
     &+(4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F5+(2*G1+G2+2*G3+2*G4+G5+2*G6)*F6
     &)*Z2+((-2*G1-G2-2*G3-2*G4-G5-2*G6)*F1+(2*G1+G2+2*G3+2*G4+G5+2*G6)*
     &F2+(-2*G1-G2-2*G3-6*G4-3*G5-6*G6)*F4+(2*G1+G2+2*G3+6*G4+3*G5+6*G6)
     &*F5)*Z3
      S4 = ((12*G1+4*G2+4*G3+24*G4+8*G5+8*G6)*F1+(-4*G1-G3+4*G5+G6)*F
     &2+(2*G1+G2+2*G3+6*G4+3*G5+6*G6)*F3+(-8*G1-4*G2-3*G3-24*G4-12*G5-9*
     &G6)*F5+(-2*G1-G2-2*G3-6*G4-3*G5-6*G6)*F6)*Z4+((-4*G1-G3-16*G4-4*G5
     &-5*G6)*F1+(-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F2+(-2*G1-G2-2*G3-6*G4-
     &3*G5-6*G6)*F3+(8*G1+4*G2+3*G3+24*G4+12*G5+9*G6)*F4+(2*G1+G2+2*G3+6
     &*G4+3*G5+6*G6)*F6)*Z5+((2*G1+G2+2*G3+2*G4+G5+2*G6)*F1+(-2*G1-G2-2*
     &G3-2*G4-G5-2*G6)*F2+(2*G1+G2+2*G3+6*G4+3*G5+6*G6)*F4+(-2*G1-G2-2*G
     &3-6*G4-3*G5-6*G6)*F5)*Z6
      S6 = ((-2*G1-2*G2-G3-2*G4-2*G5-G6)*F2+(-8*G1-3*G2-4*G3-8*G4-3*G5-4
     &*G6)*F3+(12*G1+4*G2+4*G3+24*G4+8*G5+8*G6)*F4+(2*G1+2*G2+G3+2*G4+2*
     &G5+G6)*F5+(-4*G1-G2-16*G4-5*G5-4*G6)*F6)*Z1+((2*G1+2*G2+G3+2*G4+2*
     &G5+G6)*F1+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F3+(2*G1+2*G2+G3+6*G4+6*G5+
     &3*G6)*F4+(-2*G1-2*G2-G3-6*G4-6*G5-3*G6)*F6)*Z2+((8*G1+3*G2+4*G3+8*
     &G4+3*G5+4*G6)*F1+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F2+(-4*G1-G2+G5+4*G6)
     &*F4+(-2*G1-2*G2-G3-2*G4-2*G5-G6)*F5+(-4*G1-2*G2-4*G3-8*G4-4*G5-8*G
     &6)*F6)*Z3
      S5 = ((-12*G1-4*G2-4*G3-24*G4-8*G5-8*G6)*F1+(-2*G1-2*G2-G3-6*G4
     &-6*G5-3*G6)*F2+(4*G1+G2-G5-4*G6)*F3+(2*G1+2*G2+G3+6*G4+6*G5+3*G6)*
     &F5+(8*G1+3*G2+4*G3+24*G4+9*G5+12*G6)*F6)*Z4+((-2*G1-2*G2-G3-2*G4-2
     &*G5-G6)*F1+(2*G1+2*G2+G3+2*G4+2*G5+G6)*F3+(-2*G1-2*G2-G3-6*G4-6*G5
     &-3*G6)*F4+(2*G1+2*G2+G3+6*G4+6*G5+3*G6)*F6)*Z5+((4*G1+G2+16*G4+5*G
     &5+4*G6)*F1+(2*G1+2*G2+G3+6*G4+6*G5+3*G6)*F2+(4*G1+2*G2+4*G3+8*G4+4
     &*G5+8*G6)*F3+(-8*G1-3*G2-4*G3-24*G4-9*G5-12*G6)*F4+(-2*G1-2*G2-G3-
     &6*G4-6*G5-3*G6)*F5)*Z6
      W4(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
      S3 = ((4*G1+8*G2+3*G3+4*G4+8*G5+3*G6)*F2+(G1+2*G2+2*G3+G4+2*G5+2*G
     &6)*F3+(-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F4+(-4*G2-G3+4*G4+G6)*F5+(-
     &G1-2*G2-2*G3-G4-2*G5-2*G6)*F6)*Z1+((-4*G1-8*G2-3*G3-4*G4-8*G5-3*G6
     &)*F1+(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F3+(-4*G2-G3-4*G4-16*G5-5*G6)*F4
     &+(4*G1+12*G2+4*G3+8*G4+24*G5+8*G6)*F5+(G1+2*G2+2*G3+G4+2*G5+2*G6)*
     &F6)*Z2+((-G1-2*G2-2*G3-G4-2*G5-2*G6)*F1+(G1+2*G2+2*G3+G4+2*G5+2*G6
     &)*F2+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F4+(G1+2*G2+2*G3+3*G4+6*G5+6*G
     &6)*F5)*Z3
      S4 = ((4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F1+(4*G2+G3+4*G4+16*G5+5*
     &G6)*F2+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F3+(-4*G1-8*G2-3*G3-12*G4-24*
     &G5-9*G6)*F5+(-G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F6)*Z4+((4*G2+G3-4*G4-G
     &6)*F1+(-4*G1-12*G2-4*G3-8*G4-24*G5-8*G6)*F2+(-G1-2*G2-2*G3-3*G4-6*
     &G5-6*G6)*F3+(4*G1+8*G2+3*G3+12*G4+24*G5+9*G6)*F4+(G1+2*G2+2*G3+3*G
     &4+6*G5+6*G6)*F6)*Z5+((G1+2*G2+2*G3+G4+2*G5+2*G6)*F1+(-G1-2*G2-2*G3
     &-G4-2*G5-2*G6)*F2+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F4+(-G1-2*G2-2*G3-
     &3*G4-6*G5-6*G6)*F5)*Z6
      S6 = ((-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F2+(-3*G1-4*G2-3*G3-3*G4-4*
     &G5-3*G6)*F3+(4*G1+4*G2+2*G3+8*G4+8*G5+4*G6)*F4+(2*G1+6*G2+2*G3+2*G
     &4+6*G5+2*G6)*F5+(-G1+G3-5*G4-4*G5-G6)*F6)*Z1+((2*G1+6*G2+2*G3+2*G4
     &+6*G5+2*G6)*F1+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F3+(2*G1+6*G2+2*G3
     &+6*G4+18*G5+6*G6)*F4+(-2*G1-6*G2-2*G3-6*G4-18*G5-6*G6)*F6)*Z2+((3*
     &G1+4*G2+3*G3+3*G4+4*G5+3*G6)*F1+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F2
     &+(-G1+G3+G4+4*G5+5*G6)*F4+(-2*G1-6*G2-2*G3-2*G4-6*G5-2*G6)*F5+(-2*
     &G1-4*G2-4*G3-4*G4-8*G5-8*G6)*F6)*Z3
      S5 = ((-4*G1-4*G2-2*G3-8*G4-8*G5-4*G6)*F1+(-2*G1-6*G2-2*G3-6*G4
     &-18*G5-6*G6)*F2+(G1-G3-G4-4*G5-5*G6)*F3+(2*G1+6*G2+2*G3+6*G4+18*G5
     &+6*G6)*F5+(3*G1+4*G2+3*G3+9*G4+12*G5+9*G6)*F6)*Z4+((-2*G1-6*G2-2*G
     &3-2*G4-6*G5-2*G6)*F1+(2*G1+6*G2+2*G3+2*G4+6*G5+2*G6)*F3+(-2*G1-6*G
     &2-2*G3-6*G4-18*G5-6*G6)*F4+(2*G1+6*G2+2*G3+6*G4+18*G5+6*G6)*F6)*Z5
     &+((G1-G3+5*G4+4*G5+G6)*F1+(2*G1+6*G2+2*G3+6*G4+18*G5+6*G6)*F2+(2*G
     &1+4*G2+4*G3+4*G4+8*G5+8*G6)*F3+(-3*G1-4*G2-3*G3-9*G4-12*G5-9*G6)*F
     &4+(-2*G1-6*G2-2*G3-6*G4-18*G5-6*G6)*F5)*Z6
      W5(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
      S3 = ((3*G1+3*G2+4*G3+3*G4+3*G5+4*G6)*F2+(2*G1+2*G2+6*G3+2*G4+2*G5
     &+6*G6)*F3+(-4*G1-2*G2-4*G3-8*G4-4*G5-8*G6)*F4+(G1-G2+5*G4+G5+4*G6)
     &*F5+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F6)*Z1+((-3*G1-3*G2-4*G3-3*G4
     &-3*G5-4*G6)*F1+(-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F3+(G1-G2-G4-5*G5-
     &4*G6)*F4+(2*G1+4*G2+4*G3+4*G4+8*G5+8*G6)*F5+(2*G1+2*G2+6*G3+2*G4+2
     &*G5+6*G6)*F6)*Z2+((-2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F1+(2*G1+2*G2+6
     &*G3+2*G4+2*G5+6*G6)*F2+(-2*G1-2*G2-6*G3-6*G4-6*G5-18*G6)*F4+(2*G1+
     &2*G2+6*G3+6*G4+6*G5+18*G6)*F5)*Z3
      S4 = ((4*G1+2*G2+4*G3+8*G4+4*G5+8*G6)*F1+(-G1+G2+G4+5*G5+4*G6)*
     &F2+(2*G1+2*G2+6*G3+6*G4+6*G5+18*G6)*F3+(-3*G1-3*G2-4*G3-9*G4-9*G5-
     &12*G6)*F5+(-2*G1-2*G2-6*G3-6*G4-6*G5-18*G6)*F6)*Z4+((-G1+G2-5*G4-G
     &5-4*G6)*F1+(-2*G1-4*G2-4*G3-4*G4-8*G5-8*G6)*F2+(-2*G1-2*G2-6*G3-6*
     &G4-6*G5-18*G6)*F3+(3*G1+3*G2+4*G3+9*G4+9*G5+12*G6)*F4+(2*G1+2*G2+6
     &*G3+6*G4+6*G5+18*G6)*F6)*Z5+((2*G1+2*G2+6*G3+2*G4+2*G5+6*G6)*F1+(-
     &2*G1-2*G2-6*G3-2*G4-2*G5-6*G6)*F2+(2*G1+2*G2+6*G3+6*G4+6*G5+18*G6)
     &*F4+(-2*G1-2*G2-6*G3-6*G4-6*G5-18*G6)*F5)*Z6
      S6 = ((-G1-2*G2-2*G3-G4-2*G5-2*G6)*F2+(-4*G1-3*G2-8*G3-4*G4-3*G5-8
     &*G6)*F3+(4*G1+2*G2+4*G3+8*G4+4*G5+8*G6)*F4+(G1+2*G2+2*G3+G4+2*G5+2
     &*G6)*F5+(G2+4*G3-4*G4-G5)*F6)*Z1+((G1+2*G2+2*G3+G4+2*G5+2*G6)*F1+(
     &-G1-2*G2-2*G3-G4-2*G5-2*G6)*F3+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F4+(-
     &G1-2*G2-2*G3-3*G4-6*G5-6*G6)*F6)*Z2+((4*G1+3*G2+8*G3+4*G4+3*G5+8*G
     &6)*F1+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F2+(G2+4*G3+4*G4+5*G5+16*G6)*F4+
     &(-G1-2*G2-2*G3-G4-2*G5-2*G6)*F5+(-4*G1-4*G2-12*G3-8*G4-8*G5-24*G6)
     &*F6)*Z3
      S5 = ((-4*G1-2*G2-4*G3-8*G4-4*G5-8*G6)*F1+(-G1-2*G2-2*G3-3*G4-6
     &*G5-6*G6)*F2+(-G2-4*G3-4*G4-5*G5-16*G6)*F3+(G1+2*G2+2*G3+3*G4+6*G5
     &+6*G6)*F5+(4*G1+3*G2+8*G3+12*G4+9*G5+24*G6)*F6)*Z4+((-G1-2*G2-2*G3
     &-G4-2*G5-2*G6)*F1+(G1+2*G2+2*G3+G4+2*G5+2*G6)*F3+(-G1-2*G2-2*G3-3*
     &G4-6*G5-6*G6)*F4+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F6)*Z5+((-G2-4*G3+4
     &*G4+G5)*F1+(G1+2*G2+2*G3+3*G4+6*G5+6*G6)*F2+(4*G1+4*G2+12*G3+8*G4+
     &8*G5+24*G6)*F3+(-4*G1-3*G2-8*G3-12*G4-9*G5-24*G6)*F4+(-G1-2*G2-2*G
     &3-3*G4-6*G5-6*G6)*F5)*Z6
      W6(IELEM) = ((S4+S3)*X3+(S5+S6)*X2)*XS1440
!
 4    ENDDO
!
      ELSE IF (ICOORD.EQ.3) THEN
!-----------------------------------------------------------------------
!  DERIVATIVE WRT Z
!
      DO 5, IELEM = 1 , NELEM
!
         I1 = IKLE1(IELEM)
         I2 = IKLE2(IELEM)
         I3 = IKLE3(IELEM)
         I4 = IKLE4(IELEM)
         I5 = IKLE5(IELEM)
         I6 = IKLE6(IELEM)
!
         F1 = F(I1)
         F2 = F(I2)
         F3 = F(I3)
         F4 = F(I4)
         F5 = F(I5)
         F6 = F(I6)
!
         G1 = G(I1)
         G2 = G(I2)
         G3 = G(I3)
         G4 = G(I4)
         G5 = G(I5)
         G6 = G(I6)
!
!  REAL COORDINATES OF THE POINTS OF THE ELEMENT
!
         X2  =  X(I2) - X(I1)
         X3  =  X(I3) - X(I1)
         Y2  =  Y(I2) - Y(I1)
         Y3  =  Y(I3) - Y(I1)
         XMU  = XS720*(X2*Y3-X3*Y2)
!
!     VC11PP_Z (FROM MAPLE)
!
      W1(IELEM) = XMU*(
     &     (12*G1+4*G2+4*G3+6*G4+2*G5+2*G6)*(F4-F1)
     &     +(4*G1+4*G2+2*G3+2*G4+2*G5+G6)*(F5-F2)
     &     +(4*G1+2*G2+4*G3+2*G4+G5+2*G6)*(F6-F3)
     &     )
      W2(IELEM) = XMU*(
     &     (4*G1+4*G2+2*G3+2*G4+2*G5+G6)*(F4-F1)
     &     +(4*G1+12*G2+4*G3+2*G4+6*G5+2*G6)*(F5-F2)
     &     +(2*G1+4*G2+4*G3+G4+2*G5+2*G6)*(F6-F3)
     &     )
      W3(IELEM) = XMU*(
     &     (4*G1+2*G2+4*G3+2*G4+G5+2*G6)*(F4-F1)
     &     +(2*G1+4*G2+4*G3+G4+2*G5+2*G6)*(F5-F2)
     &     +(4*G1+4*G2+12*G3+2*G4+2*G5+6*G6)*(F6-F3)
     &     )
      W4(IELEM) = XMU*(
     &     (6*G1+2*G2+2*G3+12*G4+4*G5+4*G6)*(F4-F1)
     &     +(2*G1+2*G2+G3+4*G4+4*G5+2*G6)*(F5-F2)
     &     +(2*G1+G2+2*G3+4*G4+2*G5+4*G6)*(F6-F3)
     &     )
      W5(IELEM) = XMU*(
     &     (2*G1+2*G2+G3+4*G4+4*G5+2*G6)*(F4-F1)
     &     +(2*G1+6*G2+2*G3+4*G4+12*G5+4*G6)*(F5-F2)
     &     +(G1+2*G2+2*G3+2*G4+4*G5+4*G6)*(F6-F3)
     &     )
      W6(IELEM) = XMU*(
     &     (2*G1+G2+2*G3+4*G4+2*G5+4*G6)*(F4-F1)
     &     +(G1+2*G2+2*G3+2*G4+4*G5+4*G6)*(F5-F2)
     &     +(2*G1+2*G2+6*G3+4*G4+4*G5+12*G6)*(F6-F3)
     &     )
!
 5    ENDDO
!
      ELSE
!
!-----------------------------------------------------------------------
!
         IF (LNG.EQ.1) WRITE(LU,200) ICOORD
         IF (LNG.EQ.2) WRITE(LU,201) ICOORD
 200     FORMAT(1X,'VC11PP (BIEF) : COMPOSANTE IMPOSSIBLE ',
     &        1I6,' VERIFIER ICOORD')
 201     FORMAT(1X,'VC11PP (BIEF) : IMPOSSIBLE COMPONENT ',
     &        1I6,' CHECK ICOORD')
         CALL PLANTE(1)
         STOP
!
      ENDIF
!-----------------------------------------------------------------------
! ERROR
!
      ELSE
!-----------------------------------------------------------------------
         IF (LNG.EQ.1) WRITE(LU,1100) IELMF,SF%NAME
         IF (LNG.EQ.1) WRITE(LU,1200) IELMG,SG%NAME
         IF (LNG.EQ.1) WRITE(LU,1300)
         IF (LNG.EQ.2) WRITE(LU,1101) IELMF,SF%NAME
         IF (LNG.EQ.2) WRITE(LU,1201) IELMG,SG%NAME
         IF (LNG.EQ.2) WRITE(LU,1301)
         CALL PLANTE(1)
         STOP
 1100  FORMAT(1X,'VC11PP (BIEF) :',/,
     &        1X,'DISCRETISATION DE F : ',1I6,
     &        1X,'NOM REEL : ',A6)
 1200  FORMAT(1X,'DISCRETISATION DE G : ',1I6,
     &        1X,'NOM REEL : ',A6)
 1300  FORMAT(1X,'CAS NON PREVU')
 1101  FORMAT(1X,'VC11PP (BIEF) :',/,
     &        1X,'DISCRETIZATION OF F:',1I6,
     &        1X,'REAL NAME: ',A6)
 1201  FORMAT(1X,'DISCRETIZATION OF G:',1I6,
     &        1X,'REAL NAME: ',A6)
 1301  FORMAT(1X,'CASE NOT IMPLEMENTED')
!
      ENDIF
!-----------------------------------------------------------------------
      RETURN
      END