!                    *****************
                     SUBROUTINE ACTUZF
!                    *****************
!
     & ( IVIDE , EPAI , ZF , NPOIN2, NPFMAX , NPF )
!
!***********************************************************************
! TELEMAC3D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    UPDATES THE BOTTOM ELEVATION.
!
!history  C LE NORMANT (LNH)
!+        13/05/92
!+        V1P2
!+   
!
!history  
!+        05/05/93
!+        V1P2
!+   MODIFIED 
!
!history  JACEK A. JANKOWSKI PINXIT
!+        **/03/99
!+        V5P1
!+   FORTRAN95 VERSION 
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
!| EPAI           |-->| EPAISSEURS DES MAILLES DISCRETISANT LE LIT
!| IVIDE          |-->| INDICE DES VIDES AUX POINTS DU MAILLAGE
!| NPF            |-->| NOMBRE DE POINTS DU FOND SUR UNE VERTICALE
!| NPFMAX         |-->| NOMBRE MAXIMUM DE PLANS HORIZONTAUX
!|                |   | DISCRETISANT LE FOND VASEUX
!| NPOIN2         |-->| NOMBRE DE POINTS 2D
!| ZF             |<->| COTE DU FOND
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
       IMPLICIT NONE
!
!-----------------------------------------------------------------------
!
       INTEGER, INTENT(IN)             :: NPOIN2, NPFMAX
       DOUBLE PRECISION, INTENT(IN)    :: IVIDE(NPFMAX,NPOIN2)
       DOUBLE PRECISION, INTENT(IN)    :: EPAI(NPFMAX-1,NPOIN2)
       DOUBLE PRECISION, INTENT(INOUT) :: ZF(NPOIN2)
       INTEGER, INTENT(IN)             :: NPF(NPOIN2)
!
!-----------------------------------------------------------------------
!
       INTEGER IPOIN , IPF
       DOUBLE PRECISION  ECOUCH
!
!-----------------------------------------------------------------------
!
       DO IPOIN=1,NPOIN2
!
!         -----COMPUTES THE BOTTOM ELEVATION-----
!
          DO IPF=1,NPF(IPOIN)-1
            ECOUCH=(IVIDE(IPF,IPOIN)+IVIDE(IPF+1,IPOIN))/2.D0
            ZF(IPOIN)=ZF(IPOIN)+(1.D0+ECOUCH)*EPAI(IPF,IPOIN)
          END DO
!
       END DO
!
!-----------------------------------------------------------------------
!
       RETURN
       END SUBROUTINE ACTUZF