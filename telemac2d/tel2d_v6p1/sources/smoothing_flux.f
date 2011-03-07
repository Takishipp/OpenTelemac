!                    *************************
                     SUBROUTINE SMOOTHING_FLUX
!                    *************************
!
     &(XMUL,SF,F,SURFAC,IKLE1,IKLE2,IKLE3,NELEM,NELMAX,W)
!
!***********************************************************************
! TELEMAC2D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS.
!code
!+                    /
!+    VEC(I) = XMUL  /    PSI(I) * F -  VOLU2D(I)*F(I)  D(OMEGA)
!+                  /OMEGA
!+
!+    PSI (I) IS A BASE OF TYPE TRIANGLE P1
!+
!+    F IS A DISCRETISATION VECTOR P0, P1 OR DISCONTINUOUS P1
!+    VOLU2D IS THE INTEGRAL OF THE BASES
!
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM
!warning  THE JACOBIAN MUST BE POSITIVE
!
!history  J-M HERVOUET (LNHE)
!+        20/05/2008
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
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| SURFAC         |-->| SURFACE DES ELEMENTS.
!| W              |<->| VECTEUR RESULTAT SOUS FORME NON ASSEMBLEE.
!| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX),IKLE3(NELMAX)
!
      DOUBLE PRECISION, INTENT(INOUT) :: W(NELMAX,3)
      DOUBLE PRECISION, INTENT(IN)    :: SURFAC(NELMAX)
      DOUBLE PRECISION, INTENT(IN)    :: XMUL
!
!     STRUCTURE OF F AND REAL DATA
!
      TYPE(BIEF_OBJ), INTENT(IN)   :: SF
      DOUBLE PRECISION, INTENT(IN) :: F(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF
      DOUBLE PRECISION XSUR12,F1,F2,F3,COEF
!
!-----------------------------------------------------------------------
!
      IELMF=SF%ELM
!
!-----------------------------------------------------------------------
!
!     F IS LINEAR
!
      IF(IELMF.EQ.11) THEN
!
      XSUR12 = XMUL / 12.D0
!
      DO IELEM = 1 , NELEM
!
        F1  = F(IKLE1(IELEM))
        F2  = F(IKLE2(IELEM))
        F3  = F(IKLE3(IELEM))
!
        COEF = XSUR12 * SURFAC(IELEM)
!
        W(IELEM,1) = W(IELEM,1) + COEF * ( F2+F3-2*F1 )
        W(IELEM,2) = W(IELEM,2) + COEF * ( F1+F3-2*F2 )
        W(IELEM,3) = W(IELEM,3) + COEF * ( F1+F2-2*F3 )
!
      ENDDO
!
!-----------------------------------------------------------------------
!
      ELSE
!
!-----------------------------------------------------------------------
!
       IF (LNG.EQ.1) WRITE(LU,100) IELMF,SF%NAME
       IF (LNG.EQ.2) WRITE(LU,101) IELMF,SF%NAME
100    FORMAT(1X,'ESSAI (BIEF) :',/,
     &        1X,'DISCRETISATION DE F NON PREVUE : ',1I6,
     &        1X,'NOM REEL : ',A6)
101    FORMAT(1X,'ESSAI (BIEF) :',/,
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