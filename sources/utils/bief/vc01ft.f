!                    *****************
                     SUBROUTINE VC01FT
!                    *****************
!
     &( XMUL,SF,F,X,Y,Z,
     &  IKLE1,IKLE2,IKLE3,NBOR,NELEM,NELMAX,W1,W2,W3)
!
!***********************************************************************
! BIEF   V6P1                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!code
!+                    /
!+    VEC(I) = XMUL  /    PSI(I) * F  D(OMEGA)
!+                  /OMEGA
!+
!+    PSI(I) IS A BASE OF TYPE P1 SEGMENT BUT ON A MESH WITH
!+    VERTICAL TRIANGLES IN THE X,Y,Z SPACE
!+
!+    F IS A VECTOR OF TYPE IELMF
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM
!
!history  J-M HERVOUET (LNH)    ; F LEPEINTRE (LNH)
!+        26/04/04
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
!| F              |-->| FUNCTION USED IN THE VECTOR FORMULA
!| IKLE1          |-->| FIRST POINT OF TRIANGLES
!| IKLE2          |-->| SECOND POINT OF TRIANGLES
!| IKLE3          |-->| THIRD POINT OF TRIANGLES
!| NBOR           |-->| GLOBAL NUMBER OF BOUNDARY POINTS
!| NELEM          |-->| NUMBER OF ELEMENTS
!| NELMAX         |-->| MAXIMUM NUMBER OF ELEMENTS
!| SF             |-->| BIEF_OBJ STRUCTURE OF F
!| W1             |<--| RESULT IN NON ASSEMBLED FORM
!| W2             |<--| RESULT IN NON ASSEMBLED FORM
!| W3             |<--| RESULT IN NON ASSEMBLED FORM
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| XMUL           |-->| MULTIPLICATION COEFFICIENT
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!| Z              |-->| ELEVATIONS OF POINTS IN THE MESH
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF  ! , EX_VC01FT => VC01FT
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
      TYPE(BIEF_OBJ), INTENT(IN) :: SF
      DOUBLE PRECISION, INTENT(IN) :: F(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF,I1,I2,I3
      DOUBLE PRECISION XSUR12,COEF,F123,F1,F2,F3,X1,X2,X3,Y1,Y2
      DOUBLE PRECISION Y3,Z1,Z2,Z3,S
!
      INTRINSIC SQRT
!
!***********************************************************************
!
      IELMF=SF%ELM
!
!-----------------------------------------------------------------------
!
!     F IS LINEAR BY BOUNDARY SIDE
!
      IF(IELMF.EQ.61.OR.IELMF.EQ.81) THEN
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
            F1 = F(IKLE1(IELEM))
            F2 = F(IKLE2(IELEM))
            F3 = F(IKLE3(IELEM))
            F123  = F1 + F2 + F3
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
100    FORMAT(1X,'VC01FT (BIEF) :',/,
     &        1X,'DISCRETISATION DE F NON PREVUE : ',1I6,
     &        1X,'NOM REEL : ',A6)
101    FORMAT(1X,'VC01FT (BIEF) :',/,
     &        1X,'DISCRETIZATION OF F NOT AVAILABLE:',1I6,
     &        1X,'REAL NAME: ',A6)
       CALL PLANTE(1)
       STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!     NOTE: FOR A PLANE TRIANGLE (VC01AA):
!
!     XSUR12 = XMUL / 12.D0
!
!     DO 3 IELEM = 1 , NELEM
!
!       F1  = F(IKLE1(IELEM))
!       F2  = F(IKLE2(IELEM))
!       F3  = F(IKLE3(IELEM))
!       F123  = F1 + F2 + F3
!
!       COEF = XSUR12 * SURFAC(IELEM)
!
!       W1(IELEM) = COEF * ( F123 + F1 )
!       W2(IELEM) = COEF * ( F123 + F2 )
!       W3(IELEM) = COEF * ( F123 + F3 )
!
!3     CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END
