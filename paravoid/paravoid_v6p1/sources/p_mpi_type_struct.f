!                    *****************************
                     SUBROUTINE  P_MPI_TYPE_STRUCT
!                    *****************************
!
     &(I1,I2,I3,I4,I5,I6)
!
!***********************************************************************
! PARAVOID   V6P1                                   21/08/2010
!***********************************************************************
!
!brief    CALLS FUNCTION MPI_TYPE_STRUCT.
!
!warning  EMPTY SHELL IN SCALAR MODE FOR PARALLEL COMPATIBILITY
!
!history  C. DENIS (SINETICS)
!+        27/10/2009
!+        V6P0
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
!| I1             |-->| NUMBER OF BLOCKS 
!| I2             |-->| NUMBER OF ELEMENTS IN EACH BLOCK
!| I3             |-->| BYTE DISLACEMENT   IN EACH BLOCK
!| I4             |-->| TYPE OF ELEMENTS   IN EACH BLOCK 
!| I5             |<--| NEW DATATYPE
!| I6             |<--| ERROR VALUE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!
      INTEGER, INTENT(IN) :: I1,I5,I6
      INTEGER, INTENT(IN) :: I2(I1),I3(I1),I4(I1)
!
!-----------------------------------------------------------------------
!
      IF(LNG.EQ.1) WRITE(LU,*) 'APPEL DE P_MPI_TYPE_STRUCT VERSION VIDE'
      IF(LNG.EQ.2) WRITE(LU,*) 'CALL OF P_MPI_TYPE_STRUCT VOID VERSION'
!
!-----------------------------------------------------------------------
!
      STOP
      END
