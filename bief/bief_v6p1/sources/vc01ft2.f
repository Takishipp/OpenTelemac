!                    ******************
                     SUBROUTINE VC01FT2
!                    ******************
!
     &( XMUL,SF,F,SG,G,X,Y,Z,
     &  IKLE1,IKLE2,IKLE3,NBOR,NELEM,NELMAX,W1,W2,W3)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!code
!+                    /
!+    VEC(I) = XMUL  /    PSI(I) * F * G * D(OMEGA)
!+                  /OMEGA
!+
!+    PSI(I) IS A BASE OF TYPE P1 SEGMENT BUT ON A MESH WITH
!+    VERTICAL TRIANGLES IN THE X,Y,Z SPACE
!+
!+    F IS A VECTOR OF TYPE IELMF
!+    G IS A VECTOR OF TYPE IELMG
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM
!
!history  J-M HERVOUET (LNH)    ; F LEPEINTRE (LNH)
!+        26/04/04
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
!| IKLE2          |---|
!| IKLE3          |---|
!| NBOR           |---|
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| W2             |---|
!| W3             |---|
!| X              |---|
!| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
!| Y              |---|
!| Z              |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_VC01FT2 => VC01FT2
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: NBOR(*)
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX),IKLE3(NELMAX)
!
      DOUBLE PRECISION, INTENT(IN) :: X(*),Y(*),Z(*)
      DOUBLE PRECISION, INTENT(INOUT) ::W1(NELMAX),W2(NELMAX),W3(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
!     STRUCTURE OF F AND REAL DATA
!
      TYPE(BIEF_OBJ), INTENT(IN) :: SF,SG
      DOUBLE PRECISION, INTENT(IN) :: F(*),G(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF,IELMG,I1,I2,I3
      DOUBLE PRECISION XSUR12,COEF,F123,F1,F2,F3,X1,X2,X3,Y1,Y2
      DOUBLE PRECISION Y3,Z1,Z2,Z3,S
!
      INTRINSIC SQRT
!
!***********************************************************************
!
      IELMF=SF%ELM
      IELMG=SG%ELM
!
!-----------------------------------------------------------------------
!
!     F IS LINEAR AND CONSTANT BY BOUNDARY SIDE
!
      IF( (IELMF.EQ.61.OR.IELMF.EQ.81) .AND. IELMG.EQ.10 ) THEN
!
         XSUR12 = XMUL/12.D0
!
!   LOOP ON THE BOUNDARY SIDES
!
         DO 1 IELEM = 1,NELEM
!
!           GLOBAL NUMBERING OF THE SIDE NODES
!
            I1 = NBOR(IKLE1(IELEM))
            I2 = NBOR(IKLE2(IELEM))
            I3 = NBOR(IKLE3(IELEM))
!
            X1 = X(I1)
            Y1 = Y(I1)
            Z1 = Z(I1)
!
            X2 = X(I2)-X1
            X3 = X(I3)-X1
            Y2 = Y(I2)-Y1
            Y3 = Y(I3)-Y1
            Z2 = Z(I2)-Z1
            Z3 = Z(I3)-Z1
!
            F1 = F(IKLE1(IELEM))*G(IELEM)
            F2 = F(IKLE2(IELEM))*G(IELEM)
            F3 = F(IKLE3(IELEM))*G(IELEM)
            F123  = (F1 + F2 + F3)
!
!
!           COMPUTES THE AREA OF THE TRIANGLE (BY VECTOR PRODUCT)
!
            S=0.5D0*SQRT(  (Y2*Z3-Y3*Z2)**2
     &                    +(X3*Z2-X2*Z3)**2
     &                    +(X2*Y3-X3*Y2)**2  )
!
            COEF=XSUR12*S
!
            W1(IELEM) = COEF * ( F123 + F1 )
            W2(IELEM) = COEF * ( F123 + F2 )
            W3(IELEM) = COEF * ( F123 + F3 )
!
1        CONTINUE
!
!-----------------------------------------------------------------------
!
      ELSE
!
!-----------------------------------------------------------------------
!
       IF (LNG.EQ.1) WRITE(LU,100) IELMF,SF%NAME
       IF (LNG.EQ.2) WRITE(LU,101) IELMF,SF%NAME
100    FORMAT(1X,'VC01FT2 (BIEF) :',/,
     &        1X,'DISCRETISATION DE F NON PREVUE : ',1I6,
     &        1X,'NOM REEL : ',A6)
101    FORMAT(1X,'VC01FT2 (BIEF) :',/,
     &        1X,'DISCRETIZATION OF F NOT AVAILABLE:',1I6,
     &        1X,'REAL NAME: ',A6)
       CALL PLANTE(1)
       STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
!
      RETURN
      END