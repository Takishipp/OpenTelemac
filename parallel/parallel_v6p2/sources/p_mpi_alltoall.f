!                    *************************
                     SUBROUTINE P_MPI_ALLTOALL
!                    *************************
!
     &(SEND_BUFFER,NSEND,SEND_DATYP,RECV_BUFFER,NRECV,RECV_DATYP,COMM,
     & IERR)
!
!***********************************************************************
! PARALLEL   V6P2                                   21/08/2010
!***********************************************************************
!
!brief    CALLS FUNCTION MPI_ALLTOALL.
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
!| SEND_BUFFER   |-->| SEND BUFFER  
!| NSEND         |-->| SPECIFIES THE NUMBER OF ELEMENTS TO SEND TO EACH
!|               |   | PROCESSOR  
!| SEND_DATYP    |-->| DATA TYPE OF SEND BUFFER ELEMENTS
!| RECV_BUFFER   |<--| RECEIVE BUFFER
!| NRECV         |-->| SPECIFIES THE MAXIMUM NUMBER OF ELEMENTS THAT 
!|               |   | CAN BE RECEIVED FROM EACH PROCESSOR 
!| RECV_DATYP    |-->| DATA TYPE OF RECEIVE BUFFER ELEMENTS
!| COMM          |-->| COMMUNICATOR 
!| IERR          |<--| ERROR VALUE 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)  :: SEND_BUFFER(*),NSEND,SEND_DATYP,NRECV
      INTEGER, INTENT(IN)  :: RECV_DATYP,COMM
      INTEGER, INTENT(OUT) :: RECV_BUFFER(*),IERR
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CALL MPI_ALLTOALL(SEND_BUFFER,NSEND,SEND_DATYP,
     &                  RECV_BUFFER,NRECV,RECV_DATYP,
     &                  COMM,IERR)
!
      IF(IERR.NE.0) THEN
        WRITE(LU,*) 'P_MPI_ALLTOALL:'
        WRITE(LU,*) 'MPI ERROR ',IERR
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
