!                    *****************
                     SUBROUTINE LONGML
!                    *****************
!
     & (LM2,Z,HN,NPOIN3,NPOIN2,NPLAN,MIXING,KARMAN,ZF)
!
!***********************************************************************
! TELEMAC3D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES (MIXING LENGTH) ** 2  ACCORDING TO
!+                DIFFERENT MODELS.
!+
!+            SEE : RODI, TURBULENCE MODELS AND THEIR APPLICATIONS
!+                IN HYDRAULICS.
!
!history  JACEK A. JANKOWSKI PINXIT
!+        **/03/99
!+        
!+   FORTRAN 95 VERSION 
!
!history  C. VILLARET (LNHE) ; J.-M. HERVOUET (LNHE) ; C. GUILBAUD (SOGREAH)
!+        25/02/03
!+        V5P4
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
!| HN             |-->| HAUTEUR D'EAU
!| KARMAN         |-->| KARMAN CONSTANT
!| LM2            |---| 
!| MIXING         |-->| MODELE DE LONGUEUR DE MELANGE
!| NPLAN          |-->| NOMBRE DE PLANS DU MAILLAGE
!| NPOIN2         |-->| NOMBRE DE POINTS DU MAILLAGE 2D
!| NPOIN3         |-->| NOMBRE DE POINTS DU MAILLAGE 3D
!| Z              |-->| COTES DU MAILLAGE
!| ZF             |-->| BOTTOM
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: NPOIN3,NPOIN2,NPLAN,MIXING
!
      DOUBLE PRECISION, INTENT(INOUT) :: LM2(NPOIN3)
      DOUBLE PRECISION, INTENT(IN)    :: Z(NPOIN3),HN(NPOIN2),KARMAN
      DOUBLE PRECISION, INTENT(IN)    :: ZF(NPOIN2)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I,IPLAN,I3D
      DOUBLE PRECISION LMM,ZEDE,HH
!
!***********************************************************************
!
      IF(MIXING.EQ.1) THEN
!
!     PRANDTL'S MODEL
!
      DO I=1,NPOIN2
        DO IPLAN=1,NPLAN
          I3D = I + (IPLAN-1)*NPOIN2
          ZEDE=Z(I3D)-ZF(I)
          IF(ZEDE.LE.0.2D0*HN(I)) THEN
            LM2(I3D)=(KARMAN*ZEDE)**2
          ELSE
            LM2(I3D)=(0.2D0*KARMAN*HN(I))**2
          ENDIF
        ENDDO
      ENDDO
!
      ELSEIF(MIXING.EQ.3) THEN
!
!     NEZU AND NAKAGAWA MODEL
!
        DO I=1,NPOIN2
          DO IPLAN=1,NPLAN
            I3D = I + (IPLAN-1)*NPOIN2
            ZEDE=Z(I3D)-ZF(I)
            HH=MAX(HN(I),1.D-6)
            LM2(I3D)=(1.D0-ZEDE/HH)*(KARMAN*ZEDE)**2
          ENDDO
        ENDDO
!
!     QUETIN MODEL (1977) : EOLE MODEL
!
      ELSEIF(MIXING.EQ.5) THEN
!
        DO I=1,NPOIN2
          DO IPLAN=1,NPLAN
            I3D = I + (IPLAN-1)*NPOIN2
            ZEDE=Z(I3D)-ZF(I)
            LMM=1.D0/(KARMAN*ZEDE+1.D-7)+
     &          1.D0/(0.65D0*(HN(I)-ZEDE)+1.D-7)
            LM2(I3D)=(1.D0/LMM)**2
          ENDDO
        ENDDO
!
!     TSANIS MODEL (1989)
!
      ELSEIF(MIXING.EQ.6) THEN
!
        DO I=1,NPOIN2
          DO IPLAN=1,NPLAN
            I3D = I + (IPLAN-1)*NPOIN2
            ZEDE=Z(I3D)-ZF(I)
            IF(ZEDE.LE.0.2D0*HN(I)) THEN
              LM2(I3D)=(KARMAN*ZEDE)**2
            ELSEIF(ZEDE.GE.0.8D0*HN(I)) THEN
              LM2(I3D)=(KARMAN*(HN(I)-ZEDE))**2
            ELSE
              LM2(I3D)=(0.2D0*KARMAN*HN(I))**2
            ENDIF
          ENDDO
        ENDDO
!
      ELSE
!
        IF (LNG.EQ.1) WRITE(LU,11) MIXING
        IF (LNG.EQ.2) WRITE(LU,12) MIXING
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
11    FORMAT('LONGML: VARIABLE NON PREVUE MIXING: ',I2)
12    FORMAT('LONGML: UNEXPECTED PARAMETER MIXING: ',I2)
!
!-----------------------------------------------------------------------
!
      RETURN
      END