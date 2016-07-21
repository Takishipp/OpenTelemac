!                    *******************
                     SUBROUTINE HYDROMAP
!                    *******************
!
     &(CN,X,Y,NPOIN,NCN,NBOR,KP1BOR,NPTFR)
!
!***********************************************************************
! BIEF   V7P2                                         
!***********************************************************************
!
!brief    INTERPOLATE CN (ANTECEDENT MOISTURE CONDITIONS) ON THE MESH
!         (INSPIRED FROM SUBROUTINE FOND (BIEF))
!
!history  RIADH ATA (LNHE)
!+        29/06/16
!+        V7P2
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| KP1BOR         |-->| GIVES THE NEXT BOUNDARY POINT IN A CONTOUR
!| NBOR           |-->| GLOBAL NUMBER OF BOUNDARY POINTS
!| NCN            |-->| LOGICAL UNIT OF FILE FOR CN VALUES
!| NPOIN          |-->| NUMBER OF POINTS
!| NPTFR          |-->| NUMBER OF BOUNDARY POINTS
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!| CN             |<--| INTERPOLATED CN VALUES 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_HYDROMAP => HYDROMAP 
      USE DECLARATIONS_SPECIAL
!
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER,          INTENT(IN)    :: NCN,NPOIN,NPTFR
      DOUBLE PRECISION, INTENT(INOUT) :: CN(NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: X(NPOIN),Y(NPOIN)
      INTEGER,          INTENT(IN)    :: NBOR(NPTFR),KP1BOR(NPTFR)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER NP,ERR
!
      DOUBLE PRECISION BID
!
      CHARACTER(LEN=1) C
!
      DOUBLE PRECISION, DIMENSION(:), ALLOCATABLE :: XRELV,YRELV,LUCN
!
!-----------------------------------------------------------------------
!                    READS THE DIGITISED POINTS
!                      FROM LOGICAL UNIT NCN
!-----------------------------------------------------------------------
!
      CALL OV('X=C     ',CN,CN,CN,0.D0,NPOIN)
!
!  ASSESSES THE EXTENT OF DATA
!
      NP = 0
20    READ(NCN,120,END=24,ERR=124) C
120   FORMAT(A1)
      IF(C(1:1).NE.'#') THEN
        BACKSPACE ( UNIT = NCN )
        NP = NP + 1
        READ(NCN,*) BID,BID,BID
      ENDIF
      GO TO 20
124   CONTINUE
      IF(LNG.EQ.1) WRITE(LU,18) NP
      IF(LNG.EQ.2) WRITE(LU,19) NP
18    FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERREUR DANS LE FICHIER DE L HUMIDITE PRECEDENTE'
     &      ,/,1X,'A LA LIGNE ',I7)
19    FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERROR IN THE PREVIOUS MOISTURE FILE'
     &      ,/,1X,'AT LINE ',I7)
      CALL PLANTE(1)
      STOP
24    CONTINUE
!
!  DYNAMICALLY ALLOCATES THE ARRAYS
!
      ALLOCATE(XRELV(NP),STAT=ERR)
      ALLOCATE(YRELV(NP),STAT=ERR)
      ALLOCATE(LUCN(NP) ,STAT=ERR)
!
      IF(ERR.NE.0) THEN
        IF(LNG.EQ.1) WRITE(LU,10) NP
        IF(LNG.EQ.2) WRITE(LU,11) NP
10      FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERREUR A L''ALLOCATION DE 3 TABLEAUX'
     &      ,/,1X,'DE TAILLE ',I7)
11      FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERROR DURING ALLOCATION OF 3 ARRAYS'
     &      ,/,1X,'OF SIZE ',I7)
        CALL PLANTE(1)
        STOP
      ENDIF
!
!  READS THE DATA
!
      REWIND(NCN)
      NP = 0
23    READ(NCN,120,END=22,ERR=122) C
      IF(C(1:1).NE.'#') THEN
        BACKSPACE ( UNIT = NCN )
        NP = NP + 1
        READ(NCN,*) XRELV(NP) , YRELV(NP) , LUCN(NP)
      ENDIF
      GO TO 23 
!
122   CONTINUE
      IF(LNG.EQ.1) WRITE(LU,12) NP
      IF(LNG.EQ.2) WRITE(LU,13) NP
12    FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERREUR DANS LE FICHIER DE L HUMIDITE '
     &      ,/,1X,'PRECEDENTE, A LA LIGNE ',I7)
13    FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'ERROR IN THE PREVIOUS MOISTURE FILE'
     &      ,/,1X,'AT LINE ',I7)
      CALL PLANTE(1)
      STOP
!
22    CONTINUE
!
      IF(LNG.EQ.1) WRITE(LU,112) NP
      IF(LNG.EQ.2) WRITE(LU,113) NP
112   FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'NOMBRE DE POINTS DANS LE FICHIER DE L HUMITIE'
     &      ,/,1X,'PRECEDENTE : ',I7
     &      ,/,1X,'INTERPOLATION EN COURS ........')
113   FORMAT(1X,'HYDROMAP (BIEF):'
     &      ,/,1X,'NUMBER OF POINTS IN THE PREVIOUS MOISTURE FILE:',I7
     &      ,/,1X,'INTERPOLATING ........')
!
!-----------------------------------------------------------------------
!   THE BOTTOM ELEVATION IS COMPUTED BY INTERPOLATION ONTO THE
!                      DOMAIN INTERIOR POINTS
!-----------------------------------------------------------------------
!
      CALL FASP(X,Y,CN,NPOIN,XRELV,YRELV,LUCN,NP,NBOR,KP1BOR,NPTFR,0.D0)
!
!-----------------------------------------------------------------------
!
!     VERIFICATION
!      DO NP=1,10
!        WRITE(LU,*)'DANS HYDROMAP:',CN(NP),LUCN(NP)
!      ENDDO
!
!-----------------------------------------------------------------------
!
      DEALLOCATE(XRELV)
      DEALLOCATE(YRELV)
      DEALLOCATE(LUCN)
!
!-----------------------------------------------------------------------
!
      RETURN
      END