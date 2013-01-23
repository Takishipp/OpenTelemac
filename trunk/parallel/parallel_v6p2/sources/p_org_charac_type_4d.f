!                    *******************************
                     SUBROUTINE P_ORG_CHARAC_TYPE_4D 
!                    ******************************* 
! 
     &(NOMB,TRACE,CHARACTER_4D)                      
!
!***********************************************************************
! PARALLEL   V6P2                                   21/08/2010
!***********************************************************************
!
!brief    MPI TYPE FOR TYPE CHARAC_TYPE - CHARACTERISTICS /
!+        USED BY TOMAWAC ONLY
!
!history  C. DENIS
!+        01/07/2011
!+        V6P1
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
!history  J-M HERVOUET
!+        05/07/2012
!+        V6P2
!+   NOMB set to INTENT(IN)
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| NOMB           |--->| NUMBER OF VARIABLES 
!| TRACE          |--->| IF .TRUE. TRACE EXECUTION
!| CHARACTERISTIC |--->| DATATYPE FOR CHARACTERISTIC 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!         
      IMPLICIT NONE 
      INCLUDE 'mpif.h' 
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: NOMB 
      INTEGER, INTENT(INOUT) :: CHARACTER_4D
      LOGICAL, INTENT(IN)    :: TRACE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, PARAMETER     :: MAX_BASKET_SIZE=12 
      TYPE CHARAC_TYPE_4D
          INTEGER :: MYPID ! PARTITION OF THE TRACEBACK ORIGIN (HEAD)
          INTEGER :: NEPID ! THE NEIGHBOUR PARTITION THE TRACEBACK ENTERS TO
          INTEGER :: INE   ! THE LOCAL 2D ELEMENT NR THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: KNE   ! THE LOCAL LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: FNE   ! THE LOCAL FREQUENCE LEVEL THE TRACEBACK ENTERS IN THE NEIGBOUR PARTITION
          INTEGER :: IOR   ! THE POSITION OF THE TRAJECTORY -HEAD- IN MYPID [THE 2D/3D NODE OF ORIGIN]
          INTEGER :: ISP,NSP ! NUMBERS OF RUNGE-KUTTA PASSED AS COLLECTED AND TO FOLLOW AT ALL
          DOUBLE PRECISION :: XP,YP,ZP,FP                ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: DX,DY,DZ,DF                ! THE (X,Y,Z)-POSITION NOW
          DOUBLE PRECISION :: BASKET(MAX_BASKET_SIZE) ! VARIABLES INTERPOLATED AT THE FOOT
      END TYPE CHARAC_TYPE_4D
      INTEGER, DIMENSION(18) :: CH_BLENGTH_4D=
     &                         (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
                                ! ARRAY OF DISPLACEMENTS BETWEEN BASIC COMPONENTS, HERE INITIALISED ONLY
      INTEGER (KIND=MPI_ADDRESS_KIND), DIMENSION(18) :: CH_DELTA_4D=
     &     (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
        ! ARRAY OF COMPONENT TYPES IN TERMS OF THE MPI COMMUNICATION
      INTEGER, DIMENSION(18) :: CH_TYPES_4D       
      INTEGER (KIND=MPI_ADDRESS_KIND)  :: INTEX,ILB,IUB 
      TYPE(CHARAC_TYPE_4D) :: CH 
!          
      INTEGER LNG,LU 
      COMMON/INFO/LNG,LU 
      INTEGER I,IER,IBASE 
!                 
      CALL P_MPI_ADDRESS (CH%MYPID,  CH_DELTA_4D(1),  IER)
      CALL P_MPI_ADDRESS (CH%NEPID,  CH_DELTA_4D(2),  IER)
      CALL P_MPI_ADDRESS (CH%INE,    CH_DELTA_4D(3),  IER)
      CALL P_MPI_ADDRESS (CH%KNE,    CH_DELTA_4D(4),  IER)
      CALL P_MPI_ADDRESS (CH%FNE,    CH_DELTA_4D(5),  IER)
      CALL P_MPI_ADDRESS (CH%IOR,    CH_DELTA_4D(6),  IER)
      CALL P_MPI_ADDRESS (CH%ISP,    CH_DELTA_4D(7),  IER)
      CALL P_MPI_ADDRESS (CH%NSP,    CH_DELTA_4D(8),  IER)
      CALL P_MPI_ADDRESS2(CH%XP,     CH_DELTA_4D(9),  IER)
      CALL P_MPI_ADDRESS2(CH%YP,     CH_DELTA_4D(10), IER)
      CALL P_MPI_ADDRESS2(CH%ZP,     CH_DELTA_4D(11), IER)
      CALL P_MPI_ADDRESS2(CH%FP,     CH_DELTA_4D(12), IER)
      CALL P_MPI_ADDRESS2(CH%DX,     CH_DELTA_4D(13), IER)
      CALL P_MPI_ADDRESS2(CH%DY,     CH_DELTA_4D(14), IER)
      CALL P_MPI_ADDRESS2(CH%DZ,     CH_DELTA_4D(15), IER)
      CALL P_MPI_ADDRESS2(CH%DF,     CH_DELTA_4D(16), IER)
      CALL P_MPI_ADDRESS3(CH%BASKET, CH_DELTA_4D(17), IER) ! BASKET STATIC
!
!
      CALL P_MPI_TYPE_GET_EXTENT(MPI_REAL8,ILB,INTEX,IER)
          ! MARKING THE END OF THE TYPE
      CH_DELTA_4D(18) = CH_DELTA_4D(17) + MAX_BASKET_SIZE*INTEX ! MPI_UB POSITION
      IBASE = CH_DELTA_4D(1)
      CH_DELTA_4D = CH_DELTA_4D - IBASE ! RELATIVE ADDRESSES
      IF (NOMB>0.AND.NOMB<=MAX_BASKET_SIZE) THEN
         CH_BLENGTH_4D(17) = NOMB ! CH%BASKET RANGE APPLIED FOR COMMUNICATION
      ELSE
         WRITE(LU,*) ' @STREAMLINE::ORG_CHARAC_TYPE::',
     &        ' NOMB NOT IN RANGE [1..MAX_BASKET_SIZE]'
         WRITE(LU,*) ' MAX_BASKET_SIZE, NOMB: ',MAX_BASKET_SIZE,NOMB
         CALL PLANTE(1)
         STOP
      ENDIF
      CH_TYPES_4D(1)=MPI_INTEGER
      CH_TYPES_4D(2)=MPI_INTEGER
      CH_TYPES_4D(3)=MPI_INTEGER
      CH_TYPES_4D(4)=MPI_INTEGER
      CH_TYPES_4D(5)=MPI_INTEGER
      CH_TYPES_4D(6)=MPI_INTEGER
      CH_TYPES_4D(7)=MPI_INTEGER
      CH_TYPES_4D(8)=MPI_INTEGER
      CH_TYPES_4D(9)=MPI_REAL8
      CH_TYPES_4D(10)=MPI_REAL8
      CH_TYPES_4D(11)=MPI_REAL8
      CH_TYPES_4D(12)=MPI_REAL8
      CH_TYPES_4D(13)=MPI_REAL8
      CH_TYPES_4D(14)=MPI_REAL8
      CH_TYPES_4D(15)=MPI_REAL8
      CH_TYPES_4D(16)=MPI_REAL8
      CH_TYPES_4D(17)=MPI_REAL8
      CH_TYPES_4D(18)=MPI_UB    ! THE TYPE UPPER BOUND MARKER
!
      CALL P_MPI_TYPE_CREATE_STRUCT(18,CH_BLENGTH_4D,CH_DELTA_4D,
     &     CH_TYPES_4D,CHARACTER_4D,IER)
      CALL P_MPI_TYPE_COMMIT(CHARACTER_4D,IER)
!      
      CALL P_MPI_TYPE_GET_EXTENT(CHARACTER_4D,ILB,INTEX,IER)
      IUB=INTEX+ILB
!
      IF(TRACE) THEN
        WRITE(LU,*) ' @STREAMLINE::ORG_CHARAC_TYPE:'
        WRITE(LU,*) ' MAX_BASKET_SIZE: ', MAX_BASKET_SIZE
        WRITE(LU,*) ' SIZE(CH%BASKET): ',SIZE(CH%BASKET)
        WRITE(LU,*) ' CH_DELTA: ',CH_DELTA_4D
        WRITE(LU,*) ' CH_BLENGTH: ',CH_BLENGTH_4D
        WRITE(LU,*) ' CH_TYPES: ',CH_TYPES_4D
        WRITE(LU,*) ' COMMITING MPI_TYPE_CREATE_STRUCT: ',
     &                CHARACTER_4D
        WRITE(LU,*) ' MPI_TYPE_LB, MPI_TYPE_UB: ',ILB, IUB
      ENDIF
      IF (TRACE) WRITE(LU,*) ' -> LEAVING P_ORG_CHARAC_TYPE_4D'
!     
!----------------------------------------------------------------------
!     
      RETURN  
      END 
 
 
