!                    *****************
                     SUBROUTINE INTANG
!                    *****************
!
     &( LAVANT, LAPRES, IPLAN , NPLAN , DELTAD)
!
!***********************************************************************
! TOMAWAC   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    GETS THE ANGULAR INDICES AROUND A GIVEN DIRECTION
!+                FOR THE NON-LINEAR INTERACTION TERM, USING THE DIA
!+               ("DISCRETE INTERACTION APPROXIMATION") METHOD
!+                PROPOSED BY HASSELMANN AND HASSELMANN (1985).
!+
!+
!+            PROCEDURE SPECIFIC TO THE CASE WHERE THE DIRECTIONS
!+                ARE EVENLY DISTRIBUTED OVER [0;2.PI].
!
!note     THE DELTAD DEVIATION SHOULD BE GIVEN IN DEGREES.
!note   LAVANT AND LAPRES ARE COMPRISED BETWEEN 1 AND NPLAN.
!
!reference  HASSELMANN S., HASSELMANN K. ET AL.(1985) :
!+                     "COMPUTATIONS AND PARAMETERIZATIONS OF THE NONLINEAR
!+                      ENERGY TRANSFER IN GRAVITY-WAVE SPECTRUM. PART2 :
!+                      PARAMETERIZATIONS OF THE NONLINEAR ENERGY TRANSFER
!+                      FOR APPLICATION IN WAVE MODELS". JPO, VOL 15, PP 1378-1391.
!
!history  M. BENOIT
!+        26/06/96
!+        V1P2
!+   CREATED
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
!| DELTAD         |-->| DEVIATION PAR RAPPORT A LA DIRECTION DEPART
!| IPLAN          |-->| INDICE DE LA DIRECTION DE DEPART
!| LAPRES         |<--| INDICE ANGULAIRE SUIVANT   LA DIR. ARRIVEE
!| LAVANT         |<--| INDICE ANGULAIRE PRECEDANT LA DIR. ARRIVEE
!| NPLAN          |-->| NOMBRE DE DIRECTIONS DE DISCRETISATION
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
!.....VARIABLES IN ARGUMENT
!     """""""""""""""""""""
      INTEGER  LAVANT, LAPRES, NPLAN , IPLAN
      DOUBLE PRECISION DELTAD
!
!.....LOCAL VARIABLES
!     """"""""""""""""""
      DOUBLE PRECISION TETA  , DTETAD
!
!
      DTETAD=360.D0/DBLE(NPLAN)
      TETA=DBLE(IPLAN-1)*DTETAD+DELTAD
!
!.....TETA IS ADJUSTED TO BE COMPRISED BETWEEN 0 AND 360 DEG.
!     """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  100 IF (TETA.GE.360.D0) THEN
        TETA=TETA-360.D0
        GOTO 100
      ENDIF
  110 IF (TETA.LT.0.D0) THEN
        TETA=TETA+360.D0
        GOTO 110
      ENDIF
!
!.....GETS THE ANGULAR INDICES PRECEDING AND FOLLOWING TETA
!     """"""""""""""""""""""""""""""""""""""""""""""""""""""""
      LAVANT=INT(TETA/DTETAD)+1
      LAPRES=LAVANT+1
      IF (LAPRES.GT.NPLAN) LAPRES=1
!
      RETURN
      END