!                    *****************
                     SUBROUTINE BORNES
!                    *****************
!
     &( B     , N     , A     , XM    , X0    , X1    )
!
!***********************************************************************
! TOMAWAC   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE INTEGRATION BOUNDS FOR THE INTEGRATION
!+                OF  THE FUNCTION "FONCRO", USING GAUSS QUADRATURES.
!
!history  F. BECQ (EDF/DER/LNH)
!+        26/03/96
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
!| A              |-->| PARAMETRE A DE LA FONCTION A INTEGRER
!| B              |-->| PARAMETRE B DE LA FONCTION A INTEGRER
!| N              |-->| EXPOSANT N  DE LA FONCTION A INTEGRER
!| X0             |<--| BORNE INFERIEURE DE L'INTERVALLE
!| X1             |<--| BORNE SUPERIEURE DE L'INTERVALLE
!| XM             |-->| PARAMETRE M DE LA FONCTION A INTEGRER
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
!     VARIABLES IN ARGUMENT
!     """""""""""""""""""""
      INTEGER  N
      DOUBLE PRECISION B     , A     , XM    , X0    , X1
!
!     LOCAL VARIABLES
!     """"""""""""""""""
      INTEGER  I0    , I1    , II    , JJ    , IMAX  , INP
      DOUBLE PRECISION X(11) , Y(11) , EPS   , EPS1  , DX
!
!.....EXTERNAL FUNCTIONS
!     """"""""""""""""""
      DOUBLE PRECISION  FONCRO
      EXTERNAL          FONCRO
!
!
      I1  = 11
      I0  = 1
      X(I0)= 0.D0
      X(I1)= 20.D0
      Y(1) = 0.D0
      EPS1 = 0.01D0
      EPS  = 0.0001D0
      INP  = 0
!
      DO 10 II=1,20
         DX = (X(I1)-X(I0))/10.D0
         X(1) = X(I0)
         IMAX = 0
         I0   = 1
         I1   = 11
         DO JJ=2,11
            X(JJ)=X(JJ-1)+DX
            Y(JJ)=FONCRO(X(JJ),B,N,A,XM)
            IF(Y(JJ).EQ.0.D0.AND.JJ.EQ.2.AND.INP.EQ.0D0) THEN
               X(I1) = X(I1)/10.D0
               INP   = 1
               GOTO 10
            END IF
            IF(Y(JJ).LT.Y(JJ-1)) THEN
               IF(IMAX.EQ.0) THEN
                  IMAX = JJ-1
                  EPS  = EPS1*Y(IMAX)
               END IF
               IF (Y(JJ).LT.EPS) THEN
                  I1 = JJ
                  GOTO 30
               END IF
            ELSEIF(IMAX.EQ.0.AND.Y(JJ).LT.EPS.AND.JJ.NE.2) THEN
               I0 = JJ
            END IF
         END DO
   30    CONTINUE
         IF((I1-I0).LE.2) THEN
            GOTO 10
         ELSE
            GOTO 20
         END IF
   10 CONTINUE
!
   20 CONTINUE
!
      X0 = X(I0)
      X1 = X(I1)
!
      RETURN
      END