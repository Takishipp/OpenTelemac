!                    *****************
                     SUBROUTINE VC01PP
!                    *****************
!
     &( XMUL,SF,F,Z,SURFAC,
     &  IKLE1,IKLE2,IKLE3,IKLE4,IKLE5,IKLE6,NELEM,NELMAX,
     &  W1,W2,W3,W4,W5,W6)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!code
!+                    /
!+    VEC(I) = XMUL  /    PSI(I) * F  D(OMEGA)
!+                  /OMEGA
!+
!+    PSI(I) IS A BASE OF TYPE P1 PRISM
!+
!+    F IS A VECTOR OF TYPE IELMF
!
!warning  THE JACOBIAN MUST BE POSITIVE
!warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM - REAL MESH
!
!history  J-M HERVOUET (LNH)    ; F LEPEINTRE (LNH)
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
!| IKLE2          |---|
!| IKLE3          |---|
!| IKLE4          |---|
!| IKLE5          |---|
!| IKLE6          |---|
!| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
!| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
!| SURFAC         |-->| SURFACE DES ELEMENTS.
!| W2             |---|
!| W3             |---|
!| W4             |---|
!| W5             |---|
!| W6             |---|
!| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
!| Z              |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_VC01PP => VC01PP
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX),IKLE3(NELMAX)
      INTEGER, INTENT(IN) :: IKLE4(NELMAX),IKLE5(NELMAX),IKLE6(NELMAX)
!
      DOUBLE PRECISION, INTENT(IN) :: Z(*)
      DOUBLE PRECISION, INTENT(IN) :: SURFAC(NELMAX)
      DOUBLE PRECISION,INTENT(INOUT)::W1(NELMAX),W2(NELMAX),W3(NELMAX)
      DOUBLE PRECISION,INTENT(INOUT)::W4(NELMAX),W5(NELMAX),W6(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XMUL
!
!     STRUCTURE OF F AND REAL DATA
!
      TYPE(BIEF_OBJ),   INTENT(IN) :: SF
      DOUBLE PRECISION, INTENT(IN) :: F(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IELMF
      DOUBLE PRECISION SUR360,COEF,H1,H2,H3,SHT,SH1,SH2,SH3
      DOUBLE PRECISION F1,F2,F3,F4,F5,F6,SFI,SFS,SF1,SF2,SF3,SF4,SF5,SF6
      DOUBLE PRECISION HF1,HF2,HF3,HF4,HF5,HF6,SHFI,SHFS
      DOUBLE PRECISION SHF1,SHF2,SHF3,SHF4,SHF5,SHF6
!
!***********************************************************************
!
      IELMF=SF%ELM
!
!-----------------------------------------------------------------------
!
!   F IS LINEAR
!
      IF(IELMF.EQ.41) THEN
!
         SUR360 = XMUL / 360.D0
!
         DO 3 IELEM = 1 , NELEM
!
            COEF = SUR360 * SURFAC(IELEM)
!
            H1  = COEF * (Z(IKLE4(IELEM)) - Z(IKLE1(IELEM)))
            H2  = COEF * (Z(IKLE5(IELEM)) - Z(IKLE2(IELEM)))
            H3  = COEF * (Z(IKLE6(IELEM)) - Z(IKLE3(IELEM)))
            SHT = H1 + H2 + H3
            SH1 = H1 + SHT
            SH2 = H2 + SHT
            SH3 = H3 + SHT
!
            F1  = F(IKLE1(IELEM))
            F2  = F(IKLE2(IELEM))
            F3  = F(IKLE3(IELEM))
            F4  = F(IKLE4(IELEM))
            F5  = F(IKLE5(IELEM))
            F6  = F(IKLE6(IELEM))
            SFI = F1 + F2 + F3
            SFS = F4 + F5 + F6
            SF1 = F1 + SFI
            SF2 = F2 + SFI
            SF3 = F3 + SFI
            SF4 = F4 + SFS
            SF5 = F5 + SFS
            SF6 = F6 + SFS
!
            HF1  = H1 * F1
            HF2  = H2 * F2
            HF3  = H3 * F3
            HF4  = H1 * F4
            HF5  = H2 * F5
            HF6  = H3 * F6
            SHFI = HF1 + HF2 + HF3
            SHFS = HF4 + HF5 + HF6
            SHF1 = HF1 + SHFI
            SHF2 = HF2 + SHFI
            SHF3 = HF3 + SHFI
            SHF4 = HF4 + SHFS
            SHF5 = HF5 + SHFS
            SHF6 = HF6 + SHFS
!
            W1(IELEM) = SH1 * (SF1+SF1+SF4) + SHF1 + SHF1 + SHF4
            W2(IELEM) = SH2 * (SF2+SF2+SF5) + SHF2 + SHF2 + SHF5
            W3(IELEM) = SH3 * (SF3+SF3+SF6) + SHF3 + SHF3 + SHF6
            W4(IELEM) = SH1 * (SF1+SF4+SF4) + SHF1 + SHF4 + SHF4
            W5(IELEM) = SH2 * (SF2+SF5+SF5) + SHF2 + SHF5 + SHF5
            W6(IELEM) = SH3 * (SF3+SF6+SF6) + SHF3 + SHF6 + SHF6
!
3        CONTINUE
!
!-----------------------------------------------------------------------
!
      ELSE
!
       IF (LNG.EQ.1) WRITE(LU,101) IELMF,SF%NAME
       IF (LNG.EQ.2) WRITE(LU,102) IELMF,SF%NAME
101    FORMAT(1X,'VC01PP (BIEF) :',/,
     &        1X,'DISCRETISATION DE F : ',1I6,' CAS NON PREVU',/,
     &        1X,'NOM REEL DE F : ',A6)
102    FORMAT(1X,'VC01PP (BIEF) :',/,
     &        1X,'DISCRETISATION OF F : ',1I6,' NOT IMPLEMENTED',/,
     &        1X,'REAL NAME OF F: ',A6)
       CALL PLANTE(1)
       STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END