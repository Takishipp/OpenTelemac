!                    *****************
                     SUBROUTINE SPETMA
!                    *****************
!
     &( SPEC  , FREQ  , NF    , AL    , FP     , GAMMA , SIGMAA, SIGMAB,
     &  DEUPI , GRAVIT, E2FMIN, FPMIN , DEPTH  )
!
!***********************************************************************
! TOMAWAC   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES A TMA FREQUENCY SPECTRUM BASED
!+                ON A SERIES OF FREQUENCIES.
!
!history  M. BENOIT (EDF/DER/LNH)
!+        10/01/96
!+        V1P1
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
!| AL             |-->| CONSTANTE DE PHILLIPS (ALPHA)
!| DEPTH          |-->| PROFONDEUR D'EAU AU POINT CONSIDERE (M)
!| DEUPI          |-->| 2.PI
!| E2FMIN         |-->| SEUIL MINIMUM DE SPECTRE CONSIDERE
!| FP             |-->| FREQUENCE DE PIC DU SPECTRE JONSWAP
!| FPMIN          |-->| VALEUR MINIMUM DE LA FREQUENCE DE PIC
!| FREQ           |---|
!| GAMMA          |-->| FACTEUR DE FORME DE PIC JONSWAP
!| GRAVIT         |-->| ACCELERATION DE LA PESANTEUR
!| NF             |-->| NOMBRE DE FREQUENCES DE DISCRETISATION
!| SIGMAA         |-->| VALEUR DE SIGMA JONSWAP POUR F
!| SIGMAB         |-->| VALEUR DE SIGMA JONSWAP POUR F > FP
!| SPEC           |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
!.....VARIABLES IN ARGUMENT
!     """"""""""""""""""""
      INTEGER  NF
      DOUBLE PRECISION GRAVIT, SIGMAA, SIGMAB, GAMMA , DEUPI , FPMIN
      DOUBLE PRECISION FP    , E2FMIN, AL    , DEPTH
      DOUBLE PRECISION SPEC(NF)      , FREQ(NF)
!
!.....LOCAL VARIABLES
!     """""""""""""""""
      INTEGER  JF
      DOUBLE PRECISION COEF  , ARG1   , ARG2  , ARG3  , SIG   , FF
      DOUBLE PRECISION ARG4  , OMEGH
!
!
      IF (FP.GT.FPMIN) THEN
        COEF=AL*GRAVIT**2/DEUPI**4
        DO 100 JF=1,NF
          FF=FREQ(JF)
          IF (FF.LT.FP) THEN
            SIG=SIGMAA
          ELSE
            SIG=SIGMAB
          ENDIF
          ARG1=0.5D0*((FF-FP)/(SIG*FP))**2
          IF (ARG1.LT.99.D0) THEN
            ARG1=GAMMA**EXP(-ARG1)
          ELSE
            ARG1=1.D0
          ENDIF
          ARG2=1.25D0*(FP/FF)**4
          IF (ARG2.LT.99.D0) THEN
            ARG2=EXP(-ARG2)
          ELSE
            ARG2=0.D0
          ENDIF
          ARG3=COEF/FF**5
          OMEGH=DEUPI*FF*SQRT(DEPTH/GRAVIT)
          IF (OMEGH.LT.1.D0) THEN
            ARG4=0.5D0*OMEGH*OMEGH
          ELSEIF (OMEGH.LT.2.D0) THEN
            ARG4=1.D0-0.5D0*(2.D0-OMEGH)**2
          ELSE
            ARG4=1.D0
          ENDIF
          SPEC(JF)=ARG1*ARG2*ARG3*ARG4
          IF (SPEC(JF).LT.E2FMIN) SPEC(JF)=0.D0
  100   CONTINUE
      ELSE
        DO 150 JF=1,NF
          SPEC(JF)=0.D0
  150   CONTINUE
      ENDIF
!
      RETURN
      END