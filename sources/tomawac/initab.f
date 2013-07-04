!                    *****************
                     SUBROUTINE INITAB
!                    *****************
!
     &(IBOR1,IFABOR1,NELEM2_DIM,PART)
!
!***********************************************************************
! TOMAWAC   V6P3                                   20/06/2011
!***********************************************************************
!
!brief    INITIALISES USEFUL ARRAYS.
!
!history  F.MARCOS (LNH)
!+        23/05/96
!+        V1P2
!+
!
!history  DC
!+
!+
!+   ADDED ARG NPOIN2 TO DIMENSION THE ARRAYS
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
!history  G.MATTAROLO (EDF)
!+        05/2011
!+        V6P1
!+   Modification for direct coupling with TELEMAC
!+   Initialisation of the variabel BETA
!
!history  G.MATTAROLO (EDF - LNHE)
!+        20/06/2011
!+        V6P1
!+   Translation of French names of the variables in argument
!
!history  J-M HERVOUET (EDF - LNHE)
!+        07/12/2012
!+        V6P3
!+   Optimisation.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| IBOR1          |<--| WORK TABLE
!| IFABOR1        |-->| ELEMENTS BEHIND THE EDGES OF A TRIANGLE
!|                |   | IF NEGATIVE OR ZERO, THE EDGE IS A LIQUID,
!|                |   | SOLID OR PERIODIC BOUNDARY
!| NELEM2_DIM     |---| NUMBER OF ELEMENTS IN 2D
!| PART           |-->| FLAG FOR DIRECT COUPLING WITH TELEMAC
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE DECLARATIONS_TELEMAC
      USE DECLARATIONS_TOMAWAC
!
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: PART,NELEM2_DIM
      INTEGER, INTENT(IN)    :: IFABOR1(NELEM2_DIM,3)
      INTEGER, INTENT(INOUT) :: IBOR1(NELEM2_DIM,7)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IPLAN,IPOIN,IELEM2,IFREQ
      DOUBLE PRECISION AUXI,C
!
!-----------------------------------------------------------------------
!
      DO IPLAN = 1,NPLAN
        COSTET(IPLAN) = COS(TETA(IPLAN))
        SINTET(IPLAN) = SIN(TETA(IPLAN))
        ETAP1(IPLAN)=IPLAN+1
      ENDDO
      ETAP1(NPLAN)=1
!
      AUXI=(RAISF-1.D0)/2.D0
      DFREQ(1)=AUXI*FREQ(1)
      DFREQ(NF)=AUXI*FREQ(NF-1)
      DO IFREQ = 2,NF-1
        DFREQ(IFREQ) = AUXI*(FREQ(IFREQ)+FREQ(IFREQ-1))
        DO IPOIN=1,NPOIN2
          B(IPOIN+(IFREQ-1)*NPOIN2)=0.D0
        ENDDO
      ENDDO
!
      IF(SPHE) THEN
        DO IPOIN=1,NPOIN2
          COSF(IPOIN)=COS(Y(IPOIN)*DEGRAD)
          TGF(IPOIN)=TAN(Y(IPOIN)*DEGRAD)
        ENDDO
      ENDIF
!
      DO IELEM2=1,NELEM2
        IBOR1(IELEM2,1)=IFABOR1(IELEM2,1)
        IBOR1(IELEM2,2)=IFABOR1(IELEM2,2)
        IBOR1(IELEM2,3)=IFABOR1(IELEM2,3)
        IBOR1(IELEM2,4)=1
        IBOR1(IELEM2,5)=1
        IBOR1(IELEM2,6)=1
        IBOR1(IELEM2,7)=1
      ENDDO
!
!     INITIALISES THE VARIABLE BETA
!
      DO IPOIN=1,NPOIN2
        BETA(IPOIN)=0.D0
      ENDDO
!
!     INITIALISES THE GRADIENTS OF DEPTH, U AND V
!
!
!     INVERSE OF INTEGRAL OF TEST FUNCTIONS
!
      IF(.NOT.PROINF.OR.COURAN.OR.PART.EQ.0) THEN
        CALL VECTOR(ST0,'=','MASBAS          ',IELM2,1.D0,MESH%X,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        IF(NCSIZE.GT.1) CALL PARCOM(ST0,2,MESH)
        CALL OV('X=1/Y   ',ST0%R,ST0%R,ST0%R,C,NPOIN2)
      ENDIF
!
!     NOW PROJECTED GRADIENTS DIVIDED BY INTEGRALS OF TEST FUNCTIONS
!
      IF(.NOT.PROINF) THEN
        CALL VECTOR(SDZX,'=','GRADF          X',IELM2,1.D0,SDEPTH,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        CALL VECTOR(SDZY,'=','GRADF          Y',IELM2,1.D0,SDEPTH,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM(SDZX,2,MESH)
          CALL PARCOM(SDZY,2,MESH)
        ENDIF
        CALL OV('X=XY    ',SDZX%R,ST0%R,ST0%R,C,NPOIN2)
        CALL OV('X=XY    ',SDZY%R,ST0%R,ST0%R,C,NPOIN2)
      ENDIF
!
      IF(COURAN.OR.PART.EQ.0) THEN
        CALL VECTOR(SDUX,'=','GRADF          X',IELM2,1.D0,SUC,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        CALL VECTOR(SDVX,'=','GRADF          X',IELM2,1.D0,SVC,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        CALL VECTOR(SDUY,'=','GRADF          Y',IELM2,1.D0,SUC,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        CALL VECTOR(SDVY,'=','GRADF          Y',IELM2,1.D0,SVC,
     &              ST0,ST0,ST0,ST0,ST0,MESH,.FALSE.,ST0)
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM(SDUX,2,MESH)
          CALL PARCOM(SDVX,2,MESH)
          CALL PARCOM(SDUY,2,MESH)
          CALL PARCOM(SDVY,2,MESH)
        ENDIF
        CALL OV('X=XY    ',SDUX%R,ST0%R,ST0%R,C,NPOIN2)
        CALL OV('X=XY    ',SDVX%R,ST0%R,ST0%R,C,NPOIN2)
        CALL OV('X=XY    ',SDUY%R,ST0%R,ST0%R,C,NPOIN2)
        CALL OV('X=XY    ',SDVY%R,ST0%R,ST0%R,C,NPOIN2)
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
