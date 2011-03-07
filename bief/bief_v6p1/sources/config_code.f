!                    **********************
                     SUBROUTINE CONFIG_CODE
!                    **********************
!
     &(ICODE)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    1) RESETS CORRESPONDING LOGICAL UNITS AND FILE NAMES
!+                  WHEN THERE ARE SEVERAL PROGRAMS COUPLED.
!
!history  J-M HERVOUET (LNH)
!+
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
!| ICODE          |---| NUMERO DU CODE EN CAS DE COUPLAGE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_CONFIG_CODE => CONFIG_CODE
      USE DECLARATIONS_TELEMAC
!
      IMPLICIT NONE
      INTEGER     LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER , INTENT(IN)    :: ICODE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!     SETS NAME OF CURRENT CODE
!
      NAMECODE = NNAMECODE(ICODE)
!
!-----------------------------------------------------------------------
!
      RETURN
      END