!                    *************************
                     MODULE INTERFACE_PARALLEL
!                    *************************
!
!
!***********************************************************************
! PARALLEL VERSION 6.2                                  31/07/2012
!***********************************************************************
!
!brief    INTERFACES OF PARALLEL LIBRARY PUBLIC SUBROUTINES
!+
!
!history  J-M HERVOUET (LNHE)
!+        31/07/2012
!+        V6P2
!+   Original version.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
!
      INTERFACE
!
!-----------------------------------------------------------------------
!      
!     DEFINITION OF INTERFACES
!
      SUBROUTINE ERRPVM(ERROR_NUMBER)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: ERROR_NUMBER
      END SUBROUTINE
!
      SUBROUTINE GET_MPI_PARAMETERS
     &                   (P_INTEGER,P_REAL8,P_UB,P_COMM_WORLD,P_SUCCESS)
        IMPLICIT NONE
        INTEGER, INTENT(OUT) :: P_INTEGER,P_REAL8,P_UB
        INTEGER, INTENT(OUT) :: P_COMM_WORLD,P_SUCCESS
      END SUBROUTINE
!
      SUBROUTINE ORG_CHARAC_TYPE1(NOMB,TRACE,CHARACTERISTIC)                      
        IMPLICIT NONE  
        INTEGER, INTENT(IN)    :: NOMB 
        INTEGER, INTENT(INOUT) :: CHARACTERISTIC 
        LOGICAL, INTENT(IN)    :: TRACE 
      END SUBROUTINE
!
      DOUBLE PRECISION FUNCTION P_DMAX(MYPART)
        IMPLICIT NONE
        DOUBLE PRECISION, INTENT(IN) :: MYPART
      END FUNCTION
!
      DOUBLE PRECISION FUNCTION P_DMIN(MYPART)
        IMPLICIT NONE
        DOUBLE PRECISION, INTENT(IN) :: MYPART
      END FUNCTION
!
      DOUBLE PRECISION FUNCTION P_DSUM(MYPART)
        IMPLICIT NONE
        DOUBLE PRECISION, INTENT(IN) :: MYPART
      END FUNCTION
!
      INTEGER FUNCTION P_IMAX(MYPART)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: MYPART
      END FUNCTION
!
      INTEGER FUNCTION P_IMIN(MYPART)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: MYPART
      END FUNCTION
!
      INTEGER FUNCTION P_ISUM(MYPART)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: MYPART
      END FUNCTION
!
      SUBROUTINE P_INIT(CHAINE,NCAR,IPID,NCSIZE)
        IMPLICIT NONE
        INTEGER, INTENT(OUT)            :: NCAR,IPID,NCSIZE
        CHARACTER(LEN=250), INTENT(OUT) :: CHAINE
      END SUBROUTINE
!
      SUBROUTINE P_IREAD(BUFFER,NBYTES,SOURCE,ITAG,IREQ)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: NBYTES,SOURCE,ITAG,IREQ
        DOUBLE PRECISION, INTENT(OUT) :: BUFFER(*)
      END SUBROUTINE
!
      SUBROUTINE P_IREAD_C(BUFFER,NBYTES,SOURCE,ITAG,IREQ)
        IMPLICIT NONE
        INTEGER, INTENT(IN)           :: NBYTES,SOURCE,ITAG,IREQ
        CHARACTER(LEN=*), INTENT(OUT) :: BUFFER
      END SUBROUTINE
!
      SUBROUTINE P_IWRIT(BUFFER,NBYTES,DEST,ITAG,IREQ)
        IMPLICIT NONE
        INTEGER, INTENT(IN)          :: NBYTES,DEST,ITAG,IREQ
        DOUBLE PRECISION, INTENT(IN) :: BUFFER(*)
      END SUBROUTINE
!
      SUBROUTINE P_IWRIT_C(BUFFER,NBYTES,DEST,ITAG,IREQ)
        IMPLICIT NONE
        INTEGER, INTENT(IN)          :: NBYTES,DEST,ITAG,IREQ
        CHARACTER(LEN=*), INTENT(IN) :: BUFFER
      END
!
      SUBROUTINE P_LSUM(IARG1,LARG2)
        IMPLICIT NONE
        INTEGER LNG,LU
        COMMON/INFO/LNG,LU
        INTEGER, INTENT(IN) :: IARG1
        LOGICAL, DIMENSION(IARG1), INTENT(INOUT) :: LARG2
      END SUBROUTINE
!
      SUBROUTINE P_MAIL(CHAINE,NCAR)
        IMPLICIT NONE
        INTEGER, INTENT(IN)               :: NCAR
        CHARACTER(LEN=250), INTENT(INOUT) :: CHAINE
      END SUBROUTINE
!
!     SUBROUTINE P_MPI_ADDRESS(LOCATION,ADDRESS,IER)
!       IMPLICIT NONE
!       INTEGER MPI_ADDRESS_KIND       ! from mpif.h
!       PARAMETER(MPI_ADDRESS_KIND=8) ! from mpif.h
!       INTEGER, INTENT(IN)                     :: LOCATION
!       INTEGER, INTENT(OUT)                    :: IER
!       INTEGER(MPI_ADDRESS_KIND), INTENT(OUT) :: ADDRESS
!     END SUBROUTINE
!
!     SUBROUTINE P_MPI_ADDRESS2(LOCATION,ADDRESS,IER)
!       IMPLICIT NONE
!       INTEGER MPI_ADDRESS_KIND       ! from mpif.h
!       PARAMETER(MPI_ADDRESS_KIND=8) ! from mpif.h
!       DOUBLE PRECISION, INTENT(IN)            :: LOCATION
!       INTEGER, INTENT(OUT)                    :: IER
!       INTEGER(MPI_ADDRESS_KIND), INTENT(OUT) :: ADDRESS
!     END SUBROUTINE
!
!     SUBROUTINE P_MPI_ADDRESS3(LOCATION,ADDRESS,IER)
!       IMPLICIT NONE
!       INTEGER MPI_ADDRESS_KIND       ! from mpif.h
!       PARAMETER(MPI_ADDRESS_KIND=8)  ! from mpif.h
!       DOUBLE PRECISION, INTENT(IN)            :: LOCATION(*)
!       INTEGER, INTENT(OUT)                    :: IER
!       INTEGER(MPI_ADDRESS_KIND), INTENT(OUT) :: ADDRESS
!     END SUBROUTINE
!
      SUBROUTINE P_MPI_ALLTOALLV(I1,I2,I3,I4,I5,I6,I7,I8,I9,I10)
        IMPLICIT NONE
        TYPE CHARAC_TYPE 
          SEQUENCE     
          INTEGER :: MYPID 
          INTEGER :: NEPID   
          INTEGER :: INE   
          INTEGER :: KNE   
          INTEGER :: IOR   
          INTEGER :: ISP,NSP 
          INTEGER :: VOID  
          DOUBLE PRECISION :: XP,YP,ZP                
          DOUBLE PRECISION :: DX,DY,DZ                
          DOUBLE PRECISION :: BASKET(10)    
        END TYPE CHARAC_TYPE 
        INTEGER, INTENT(IN)  :: I2(*),I3(*),I4,I6(*),I7(*),I8,I9
        INTEGER, INTENT(OUT) :: I10
        TYPE(CHARAC_TYPE), INTENT(IN)  :: I1(*)
        TYPE(CHARAC_TYPE), INTENT(OUT) :: I5(*)
      END SUBROUTINE
!
      SUBROUTINE P_MPI_ALLTOALLV_ALG(I1,I2,I3,I4,I5,I6,I7,I8,I9,I10)
      IMPLICIT NONE
      TYPE ALG_TYPE 
        SEQUENCE   ! NECESSARY TO DEFINE MPI TYPE ALG_CHAR
        INTEGER :: MYPID ! PARTITION OF THE TRACEBACK ORIGIN (HEAD) 
        INTEGER :: NEPID ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO  
        INTEGER :: IGLOB  ! THE GLOBAL NUMBER OF THE PARTICLES 
        INTEGER :: FLAG  ! USED TO ALIGN FIELDS
        DOUBLE PRECISION :: VX,VY,VZ  ! THE (X,Y,Z) PARTICLE VELOCITY  
        DOUBLE PRECISION :: UX,UY,UZ  ! THE (X,Y,Z) FLUID VELOCITY  
        DOUBLE PRECISION :: UX_AV,UY_AV,UZ_AV  ! THE (X,Y,Z) AVERAGE FLUID VELOCITY  
        DOUBLE PRECISION :: K_AV,EPS_AV  ! THE VALUES OF K AND EPS  
        DOUBLE PRECISION :: H_FLU  ! THE WATER DEPTH AT POSITION OF VELOCITY 
      END TYPE ALG_TYPE 
      INTEGER, INTENT(IN)  :: I2(*),I3(*),I4,I6(*),I7(*),I8,I9
      INTEGER, INTENT(OUT) :: I10
      TYPE(ALG_TYPE), INTENT(IN)  :: I1(*)
      TYPE(ALG_TYPE), INTENT(OUT) :: I5(*)
      END SUBROUTINE
!
      SUBROUTINE P_MPI_ALLTOALLV_I(I1,I2,I3,I4,I5,I6,I7,I8,I9,I10)
        IMPLICIT NONE
        INTEGER, INTENT(IN)  :: I1(*),I2(*),I3(*),I4,I6(*),I7(*),I8,I9
        INTEGER, INTENT(OUT) :: I5(*),I10
      END SUBROUTINE
!
      SUBROUTINE P_MPI_ALLTOALL(I1,I2,I3,I4,I5,I6,I7,I8)
        IMPLICIT NONE
        INTEGER, INTENT(IN)  :: I1(*),I2,I3,I5,I6,I7
        INTEGER, INTENT(OUT) :: I4(*),I8
      END SUBROUTINE
!   
      SUBROUTINE P_MPI_TYPE_COMMIT(I1,I2)
        IMPLICIT NONE
        INTEGER, INTENT(IN)  :: I1
        INTEGER, INTENT(OUT) :: I2
      END SUBROUTINE
!
!     SUBROUTINE P_MPI_TYPE_CREATE_STRUCT(I1,I2,I3,I4,I5,I6)
!       IMPLICIT NONE
!       INTEGER MPI_ADDRESS_KIND       ! from mpif.h
!       PARAMETER (MPI_ADDRESS_KIND=8) ! from mpif.h
!       INTEGER, INTENT(IN)                           :: I1,I6
!       INTEGER, INTENT(OUT)                          :: I5
!       INTEGER, INTENT(IN)                           :: I2(I1),I4(I1)
!       INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(INOUT) :: I3(I1)
!     END SUBROUTINE
!
      SUBROUTINE P_MPI_TYPE_FREE(I1,I2)
        IMPLICIT NONE
        INTEGER, INTENT(IN)  :: I1
        INTEGER, INTENT(OUT) :: I2
      END SUBROUTINE
!
!     SUBROUTINE P_MPI_TYPE_GET_EXTENT(I1,I2,I3,IERR)
!       IMPLICIT NONE
!       INTEGER MPI_ADDRESS_KIND       ! from mpif.h
!       PARAMETER (MPI_ADDRESS_KIND=8) ! from mpif.h
!       INTEGER(KIND=MPI_ADDRESS_KIND), INTENT(INOUT) :: I2,I3
!       INTEGER, INTENT(INOUT)                        :: I1
!       INTEGER, INTENT(OUT)                          :: IERR
!     END SUBROUTINE
!
      SUBROUTINE P_READ(BUFFER,NBYTES,SOURCE,TYPE)
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: NBYTES,SOURCE,TYPE
        DOUBLE PRECISION, INTENT(OUT) :: BUFFER(*)
      END SUBROUTINE
!
      SUBROUTINE P_WAIT_PARACO(IBUF,NB)
        IMPLICIT NONE
        INTEGER,INTENT(IN) :: IBUF(*),NB
      END SUBROUTINE
!
      SUBROUTINE P_WRIT(BUFFER,NBYTES,DEST,TYPE)
        IMPLICIT NONE
        INTEGER, INTENT(IN)          :: NBYTES,DEST,TYPE
        DOUBLE PRECISION, INTENT(IN) :: BUFFER(*)
      END SUBROUTINE
!
!------------------------------------------------------------------------
!
      END INTERFACE
!
!=======================================================================
!
      END MODULE INTERFACE_PARALLEL
