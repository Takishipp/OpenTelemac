!                    ***************
                     SUBROUTINE OV_2
!                    ***************
!
     & ( OP , X , DIMX , Y , DIMY , Z , DIMZ , C , DIM1 , NPOIN )
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    BETWEEN OS AND OV WHEN 2-DIMENSION VECTORS ARE INVOLVED.
!
!history  J-M HERVOUET (LNH)
!+        29/11/94
!+        V5P2
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
!| C              |-->| CONSTANTE DONNEE
!| DIM1           |---|
!| NPOIN          |---|
!| OP             |-->| CHAINE DE CARACTERES INDIQUANT L'OPERATION
!|                |   | A EFFECTUER.
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER,          INTENT(IN)    :: DIMX,DIMY,DIMZ,DIM1,NPOIN
      DOUBLE PRECISION, INTENT(IN)    :: C
      CHARACTER(LEN=8), INTENT(IN)    :: OP
      DOUBLE PRECISION, INTENT(INOUT) :: X(DIM1,*)
      DOUBLE PRECISION, INTENT(IN)    :: Y(DIM1,*),Z(DIM1,*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CALL OV( OP , X(1,DIMX) , Y(1,DIMY) , Z(1,DIMZ) , C , NPOIN )
!
!-----------------------------------------------------------------------
!
      RETURN
      END