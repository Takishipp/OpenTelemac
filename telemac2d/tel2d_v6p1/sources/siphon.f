!                    *****************
                     SUBROUTINE SIPHON
!                    *****************
!
     &(RELAXS,NSIPH,ENTSIP,SORSIP,GRAV,
     & H,ZF,ISCE,DSCE,SECSCE,ALTSCE,CSSCE,CESCE,DELSCE,ANGSCE,LSCE,
     & NTRAC,T,TSCE,USCE,VSCE,U,V,ENTET,MAXSCE)
!
!***********************************************************************
! TELEMAC2D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    TREATS SIPHONS.
!
!history  V. GUINOT (LHF)
!+        19/04/1996
!+        
!+   
!
!history  J.-M. HERVOUET (LNH)
!+        03/10/1996
!+        
!+   
!
!history  E. DAVID (SOGREAH)
!+        **/03/2000
!+        
!+   
!
!history  J-M HERVOUET (LNH)
!+        16/02/2009
!+        V5P9
!+   CORRECTED 03/2000 CORRECTION (IN PARALLEL MODE) 
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
!| ALTSCE         |-->| COTE DES BUSES.
!| ANGSCE         |-->| ANGLE DES BUSES AVEC L'AXE OX.
!| CESCE          |<--| COEFFICIENTS DE PERTE DE CHARGE
!|                |   | LORS D'UN FONCTIONNEMENT EN ENTREE.
!| CSSCE          |<--| COEFFICIENTS DE PERTE DE CHARGE
!|                |   | LORS D'UN FONCTIONNEMENT EN SORTIE.
!| DELSCE         |-->| ANGLE DES BUSES AVEC LA VERTICALE
!| DSCE           |<--| DEBIT DES SOURCES.
!| ENTET          |---| 
!| ENTSIP         |-->| NUMERO DE L'ENTREE D'UNE BUSE DANS LA
!|                |   | NUMEROTATION DES SOURCES.
!| GRAV           |-->| PESANTEUR.
!| H              |---| HAUTEUR D'EAU.
!| ISCE           |-->| NUMERO GLOBAL DES POINTS SOURCES.
!| LSCE           |<--| PERTE DE CHARGE LINEAIRE DE LA CONDUITE.
!| MAXSCE         |---| 
!| NSIPH          |---| 
!| NTRAC          |---| 
!| RELAXS         |-->| COEFFICIENT DE RELAXATION.
!| SECSCE         |-->| SECTION DES BUSES.
!| SORSIP         |-->| NUMERO DE LA SORTIE D'UNE BUSE DANS LA
!|                |   | NUMEROTATION DES SOURCES.
!| T              |-->| TRACEUR.
!| TSCE           |-->| VALEUR DU TRACEUR AUX SOURCES.
!| U              |-->| VITESSE U.
!| USCE           |-->| VITESSE U DU COURANT AUX SOURCES.
!| V              |-->| VITESSE V.
!| VSCE           |-->| VITESSE V DU COURANT AUX SOURCES.
!| ZF             |---| COTES DU FOND.
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
      INTEGER, INTENT(IN)             :: NSIPH,NTRAC,MAXSCE
      INTEGER, INTENT(IN)             :: ENTSIP(*),SORSIP(*),ISCE(*)
      LOGICAL, INTENT(IN)             :: ENTET
      DOUBLE PRECISION, INTENT(IN)    :: RELAXS,GRAV
      DOUBLE PRECISION, INTENT(INOUT) :: USCE(*),VSCE(*),DSCE(*)
      DOUBLE PRECISION, INTENT(INOUT) :: TSCE(MAXSCE,NTRAC)
      DOUBLE PRECISION, INTENT(IN)    :: ANGSCE(*),LSCE(*),CESCE(*)
      DOUBLE PRECISION, INTENT(IN)    :: CSSCE(*),DELSCE(*)
      DOUBLE PRECISION, INTENT(IN)    :: SECSCE(*),ALTSCE(*)
      DOUBLE PRECISION, INTENT(IN)    :: H(*),ZF(*),U(*),V(*)
      TYPE(BIEF_OBJ)  , INTENT(IN)    :: T
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER N,I1,I2,IR1,IR2,ITRAC
!
      DOUBLE PRECISION SEC,L
      DOUBLE PRECISION D1,D2,S1,S2,CE1,CE2,CS1,CS2,Q,HIR1,HIR2
!
      INTRINSIC SQRT,COS,SIN
!
      DOUBLE PRECISION P_DMAX
      EXTERNAL         P_DMAX
!
!-----------------------------------------------------------------------
!
! LOOP OVER THE SIPHONS
!
      DO 10 N=1,NSIPH
!
!     IDENTIFIES ENTRY / EXIT NODES
!
!     NUMBER OF THE CORRESPONDING SOURCES
      I1=ENTSIP(N)
      I2=SORSIP(N)
!     NUMBER OF THE POINTS FOR THESE SOURCES
      IR1=ISCE(I1)
      IR2=ISCE(I2)
!
!     LOADS, TAKEN AS FREE SURFACE ELEVATION
!
      IF(IR1.GT.0) THEN
        S1=H(IR1)+ZF(IR1)
        HIR1=H(IR1)
      ELSE
        S1=-1.D10
        HIR1=-1.D10
      ENDIF
      IF(IR2.GT.0) THEN
        S2=H(IR2)+ZF(IR2)
        HIR2=H(IR2)
      ELSE
        S2=-1.D10
        HIR2=-1.D10
      ENDIF
!     CASE WHERE ONE OF THE ENDS IS NOT IN THE SUB-DOMAIN
      IF(NCSIZE.GT.1) THEN
        S1=P_DMAX(S1)
        S2=P_DMAX(S2)
        HIR1=P_DMAX(HIR1)
        HIR2=P_DMAX(HIR2)
      ENDIF
!
!     COEFFICIENTS FOR COMPUTATION OF PRESSURE LOSS
!
      D1=DELSCE(I1)
      D2=DELSCE(I2)
      CE1=CESCE(I1)
      CE2=CESCE(I2)
      CS1=CSSCE(I1)
      CS2=CSSCE(I2)
      SEC=SECSCE(I1)
      L  =LSCE(I1)
!
!     COMPUTES THE FLOW ACCORDING TO DELTAH
!     IF THE LINEAR PRESSURE LOSS IS NEGLIGIBLE, COULD HAVE DIFFERENT
!     ENTRY / EXIT SECTIONS
!
      IF(S1.GE.S2) THEN
! EDD + CCT 03/2000 (CORRECTED BY JMH 16/02/2009 H(IR1) AND H(IR2)
!                    ARE NOT GUARANTEED TO WORK IN PARALLEL ==>  HIR1 AND HIR2)
!        IF(S1.GT.ALTSCE(I1).AND.S1.GT.ALTSCE(I2)) THEN
        IF(S1.GT.ALTSCE(I1).AND.S1.GT.ALTSCE(I2).AND.
     &     HIR1.GT.0.02D0) THEN
!
          Q = SEC * SQRT( 2.D0*GRAV*(S1-S2)/(CE1+L+CS2) )
        ELSE
          Q=0.D0
        ENDIF
      ELSE
! EDD + CCT 03/2000
!        IF(S2.GT.ALTSCE(I1).AND.S2.GT.ALTSCE(I2)) THEN
        IF(S2.GT.ALTSCE(I1).AND.S2.GT.ALTSCE(I2).AND.
     &     HIR2.GT.0.02D0) THEN
!
          Q = - SEC * SQRT( 2.D0*GRAV*(S2-S1)/(CS1+L+CE2) )
        ELSE
          Q=0.D0
        ENDIF
      ENDIF
!
!     NOTHING HAPPENS IF THE LOADS AT THE 2 ENDS ARE LOWER THAN
!     THE ELEVATION OF THE NOZZLES
!
      IF(S1.LT.ALTSCE(I1).AND.S2.LT.ALTSCE(I2)) Q=0.D0
!
!  FILLS OUT DSCE USING RELAXATION
!
      DSCE(I2)= RELAXS * Q + (1.D0-RELAXS) * DSCE(I2)
      DSCE(I1)=-DSCE(I2)
!
      IF(ENTET) THEN
        WRITE(LU,*) ' '
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'SIPHON ',N,' DEBIT DE ',DSCE(I2),' M3/S'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'CULVERT ',N,' DISCHARGE OF ',DSCE(I2),' M3/S'
        ENDIF
        WRITE(LU,*) ' '
      ENDIF
!
!  TREATS THE VELOCITIES AT THE SOURCES
!  SAME APPROACH FOR VELOCITY AND TRACER
!
      IF(DSCE(I1).GT.0.D0) THEN
        USCE(I1) = ( COS(D1)*DSCE(I1)/SECSCE(I1) ) * COS(ANGSCE(I1))
        VSCE(I1) = ( COS(D1)*DSCE(I1)/SECSCE(I1) ) * SIN(ANGSCE(I1))
      ELSE
        IF(IR1.GT.0) THEN
          USCE(I1) = U(IR1)
          VSCE(I1) = V(IR1)
        ENDIF
      ENDIF
      IF(DSCE(I2).GT.0.D0) THEN
        USCE(I2) = ( COS(D2)*DSCE(I2)/SECSCE(I2) ) * COS(ANGSCE(I2))
        VSCE(I2) = ( COS(D2)*DSCE(I2)/SECSCE(I2) ) * SIN(ANGSCE(I2))
      ELSE
        IF(IR2.GT.0) THEN
          USCE(I2) = U(IR2)
          VSCE(I2) = V(IR2)
        ENDIF
      ENDIF
!
!  TREATS THE TRACER :
!
      IF(NTRAC.GT.0) THEN
        DO ITRAC=1,NTRAC
          IF(DSCE(I1).GT.0.D0) THEN
            IF(IR2.GT.0) THEN
              TSCE(I1,ITRAC)=T%ADR(ITRAC)%P%R(IR2)
            ELSE
              TSCE(I1,ITRAC)=-1.D10
            ENDIF
            IF(NCSIZE.GT.1) TSCE(I1,ITRAC)=P_DMAX(TSCE(I1,ITRAC))
          ENDIF
          IF(DSCE(I2).GT.0.D0) THEN
            IF(IR1.GT.0) THEN
              TSCE(I2,ITRAC)=T%ADR(ITRAC)%P%R(IR1)
            ELSE
              TSCE(I2,ITRAC)=-1.D10
            ENDIF
            IF(NCSIZE.GT.1) TSCE(I2,ITRAC)=P_DMAX(TSCE(I2,ITRAC))
          ENDIF
        ENDDO
      ENDIF
!
!  END OF THE LOOP OVER THE SIPHONS
!
10    CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END