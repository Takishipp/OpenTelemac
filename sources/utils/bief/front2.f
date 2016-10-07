!                    *****************
                     SUBROUTINE FRONT2
!                    *****************
!
     &(NFRLIQ,NFRSOL,DEBLIQ,FINLIQ,DEBSOL,FINSOL,LIHBOR,LIUBOR,
     & X,Y,NBOR,KP1BOR,DEJAVU,NPOIN,NPTFR,KLOG,LISTIN,NUMLIQ,MAXFRO,
     & YAWALL,WALLDIST)
!
!***********************************************************************
! BIEF   V7P1
!***********************************************************************
!
!brief    IDENTIFIES AND NUMBERS THE LIQUID AND SOLID BOUNDARIES.
!
!note     SOLID BOUNDARIES ARE INDICATED WITH LIHBOR(K) = KLOG
!+         FOR A BOUNDARY NODE NUMBER K.
!+         A SEGMENT CONNECTING A LIQUID AND A SOLID NODE IS
!+         CONSIDERED TO BE SOLID.
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
!+        15/09/2015
!+        V7P1
!+   Now checking the maximum number of boundaries before using the
!+   would-be undersized arrays.
!
!history  R. ATA
!+        19/04/2016
!+        v7p2
!+   Bug correction:LIQF and SOLF were not changed for cases where     
!+   the 3 nodes (prevK, K,kp1bor(k)) are all liquid
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| DEBLIQ         |<--| BEGINNING OF LIQUID BOUNDARIES
!| DEBSOL         |<--| BEGINNING OF SOLID BOUNDARIES
!| DEJAVU         |<->| WORK ARRAY
!| FINLIQ         |<--| END OF LIQUID BOUNDARIES
!| FINSOL         |<--| END OF SOLID BOUNDARIES
!| KLOG           |-->| LIHBOR(K)=KLOG : SOLID BOUNDARY
!| KP1BOR         |-->| GIVES THE NEXT BOUNDARY POINT IN A CONTOUR
!| LIHBOR         |-->| TYPE OF BOUNDARY CONDITIONS ON DEPTH
!| LISTIN         |-->| IF YES, PRINTING ON LISTING
!| LIUBOR         |-->| TYPE OF BOUNDARY CONDITIONS ON U
!| MAXFRO         |-->| MAXIMUM NUMBER OF LIQUID OR SOLID BOUNDARIES
!| NBOR           |-->| GLOBAL NUMBER OF BOUNDARY POINTS
!| NFRLIQ         |<--| NUMBER OF LIQUID BOUNDARIES
!| NFRSOL         |<--| NUMBER OF SOLID BOUNDARIES
!| NPOIN          |-->| NUMBER OF POINTS
!| NPTFR          |-->| NUMBER OF BOUNDARY POINTS
!| NUMLIQ         |-->| BOUNDARY NUMBER OF BOUNDARY POINTS
!| WALLDIST       |<--| DISTANCE OF ANY POINT TO THE THE WALL
!| YAWALL         |-->| IF YES COMPUTE WALLDIST
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE DECLARATIONS_SPECIAL
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)  :: NPOIN,NPTFR,KLOG,MAXFRO
      INTEGER, INTENT(OUT) :: NFRLIQ,NFRSOL
      INTEGER, INTENT(OUT) :: DEBLIQ(MAXFRO),FINLIQ(MAXFRO)
      INTEGER, INTENT(OUT) :: DEBSOL(MAXFRO),FINSOL(MAXFRO)
      INTEGER , INTENT(IN) :: LIHBOR(NPTFR),LIUBOR(NPTFR)
      DOUBLE PRECISION, INTENT(IN) :: X(NPOIN) , Y(NPOIN)
      DOUBLE PRECISION, INTENT(OUT):: WALLDIST(NPOIN)
      INTEGER, INTENT(IN) :: NBOR(NPTFR),KP1BOR(NPTFR)
      INTEGER, INTENT(OUT) :: DEJAVU(NPTFR)
      LOGICAL, INTENT(IN) :: LISTIN,YAWALL
      INTEGER, INTENT(OUT) :: NUMLIQ(NPTFR)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER K,KPREV,IDEP,SOL1,LIQ1,L1,L2,L3,NILE
!
      LOGICAL SOLF,LIQF,SOLD,LIQD
!
      DOUBLE PRECISION MINNS,MAXNS,EPS,YMIN,NS,DIST
      DOUBLE PRECISION, PARAMETER :: EPSS=1.D-6
!
      INTRINSIC ABS
!
!-----------------------------------------------------------------------
!
!  INITIALISES
!
!  DEJAVU : MARKS WITH 1 THE POINTS THAT HAVE ALREADY BEEN TREATED
!  NILE   : NUMBER OF ISLANDS
!
      DO K=1,NPTFR
        DEJAVU(K) = 0
      ENDDO ! K
!
      NILE = 0
      IDEP = 1
      NFRLIQ = 0
      NFRSOL = 0
!
!-----------------------------------------------------------------------
!
!  COMES BACK TO LABEL 20 IF THERE IS AT LEAST 1 ISLAND
!
20    CONTINUE
!
!  LOOKS FOR THE SOUTH-WESTERNMOST POINT (THERE CAN BE MORE THAN 1)
!
      MINNS = X(NBOR(IDEP)) + Y(NBOR(IDEP))
      MAXNS = MINNS
      YMIN  = Y(NBOR(IDEP))
!
      DO K = 1 , NPTFR
        IF(DEJAVU(K).EQ.0) THEN
          NS = X(NBOR(K)) + Y(NBOR(K))
          IF(NS.LT.MINNS) THEN
            IDEP = K
            MINNS = NS
            YMIN = Y(NBOR(K))
          ENDIF
          IF(NS.GT.MAXNS) MAXNS = NS
        ENDIF
      ENDDO ! K
!
      EPS = (MAXNS-MINNS) * 1.D-4
!
!  SELECTS THE SOUTHERNMOST POINT FROM THE SOUTH-WESTERNMOST CANDIDATES
!
      DO K = 1 , NPTFR
        IF(DEJAVU(K).EQ.0) THEN
          NS = X(NBOR(K)) + Y(NBOR(K))
          IF(ABS(MINNS-NS).LT.EPS) THEN
            IF(Y(NBOR(K)).LT.YMIN) THEN
              IDEP = K
              YMIN = Y(NBOR(K))
            ENDIF
          ENDIF
        ENDIF
      ENDDO ! K
!
!-----------------------------------------------------------------------
!
!  NUMBERS AND LOCATES THE CONTOUR BOUNDARIES STARTING
!  AT POINT IDEP
!
!  SOLD = .TRUE. : THE BOUNDARY STARTING AT IDEP IS SOLID
!  LIQD = .TRUE. : THE BOUNDARY STARTING AT IDEP IS LIQUID
!  SOLF = .TRUE. : THE BOUNDARY ENDING AT IDEP IS SOLID
!  LIQF = .TRUE. : THE BOUNDARY ENDING AT IDEP IS LIQUID
!  LIQ1 : NUMBER OF THE 1ST LIQUID BOUNDARY OF THE CONTOUR
!  SOL1 : NUMBER OF THE 1ST SOLID BOUNDARY OF THE CONTOUR
!
      K = IDEP
!
      SOL1 = 0
      LIQ1 = 0
      LIQF = .FALSE.
      SOLF = .FALSE.
!
! TYPE OF THE 1ST SEGMENT
!
!     LAW OF PREDOMINANCE SOLID OVER LIQUID
      IF(LIHBOR(K).EQ.KLOG.OR.LIHBOR(KP1BOR(K)).EQ.KLOG) THEN
!       THE 1ST SEGMENT IS SOLID
        NFRSOL = NFRSOL + 1
        IF(NFRSOL.GT.MAXFRO) GO TO 1000
        SOL1 = NFRSOL
        SOLD = .TRUE.
        LIQD = .FALSE.
      ELSE
!       THE 1ST SEGMENT IS LIQUID
        NFRLIQ = NFRLIQ + 1
        IF(NFRLIQ.GT.MAXFRO) GO TO 1000
        LIQ1 = NFRLIQ
        LIQD = .TRUE.
        SOLD = .FALSE.
      ENDIF
!
      DEJAVU(K) = 1
      KPREV = K
      K = KP1BOR(K)
!
50    CONTINUE
!
! LOOKS FOR TRANSITION POINTS FROM THE POINT FOLLOWING IDEB
!
! ALSO LOOKS FOR ISOLATED POINTS TO DETECT THE ERRORS IN
! THE DATA
!
      L1 = LIHBOR(KPREV)
      L2 = LIHBOR(K)
      L3 = LIHBOR(KP1BOR(K))
!
      IF(L1.EQ.KLOG.AND.L2.NE.KLOG.AND.L3.NE.KLOG) THEN
!     SOLID-LIQUID TRANSITION AT POINT K
        NFRLIQ = NFRLIQ + 1
        IF(NFRLIQ.GT.MAXFRO) GO TO 1000
        FINSOL(NFRSOL) = K
        DEBLIQ(NFRLIQ) = K
        LIQF = .TRUE.
        SOLF = .FALSE.
      ELSEIF(L1.NE.KLOG.AND.L2.NE.KLOG.AND.L3.EQ.KLOG) THEN
!     LIQUID-SOLID TRANSITION AT POINT K
        NFRSOL = NFRSOL + 1
        IF(NFRSOL.GT.MAXFRO) GO TO 1000
        FINLIQ(NFRLIQ) = K
        DEBSOL(NFRSOL) = K
        LIQF = .FALSE.
        SOLF = .TRUE.
      ELSEIF(L1.NE.KLOG.AND.L2.NE.KLOG.AND.L3.NE.KLOG) THEN
        LIQF = .TRUE.
        SOLF = .FALSE. 
!     LIQUID-LIQUID TRANSITIONS AT POINT K
        IF(L2.NE.L3.OR.LIUBOR(K).NE.LIUBOR(KP1BOR(K))) THEN
          FINLIQ(NFRLIQ) = K
          NFRLIQ = NFRLIQ + 1
          IF(NFRLIQ.GT.MAXFRO) GO TO 1000
          DEBLIQ(NFRLIQ) = KP1BOR(K)
        ENDIF
      ELSEIF(L1.EQ.KLOG.AND.L2.NE.KLOG.AND.L3.EQ.KLOG) THEN
!     ERROR IN THE DATA
        IF(LNG.EQ.1) WRITE(LU,102) K
        IF(LNG.EQ.2) WRITE(LU,103) K
        CALL PLANTE(1)
        STOP
      ELSEIF(L1.NE.KLOG.AND.L2.EQ.KLOG.AND.L3.NE.KLOG) THEN
!     ERROR IN THE DATA
        IF(LNG.EQ.1) WRITE(LU,104) K
        IF(LNG.EQ.2) WRITE(LU,105) K
        CALL PLANTE(1)
        STOP
      ENDIF
!
      DEJAVU(K) = 1
      KPREV = K
      K = KP1BOR(K)
      IF(K.NE.IDEP) GO TO 50
!
!  CASE WHERE THE BOUNDARY TYPE CHANGES AT IDEP
!
      IF(SOLF) THEN
!       THE LAST CONTOUR BOUNDARY WAS SOLID
        IF(SOLD) THEN
!         THE FIRST CONTOUR BOUNDARY WAS SOLID
          DEBSOL(SOL1) = DEBSOL(NFRSOL)
          NFRSOL = NFRSOL - 1
        ELSEIF(LIQD) THEN
!         THE FIRST CONTOUR BOUNDARY WAS LIQUID
          DEBLIQ(LIQ1) = IDEP
          FINSOL(NFRSOL) = IDEP
        ENDIF
!
      ELSEIF(LIQF) THEN
!       THE LAST CONTOUR BOUNDARY WAS LIQUID
        IF(LIQD) THEN
!         THE FIRST CONTOUR BOUNDARY WAS LIQUID
          DEBLIQ(LIQ1) = DEBLIQ(NFRLIQ)
          NFRLIQ = NFRLIQ - 1
        ELSEIF(SOLD) THEN
!         THE FIRST CONTOUR BOUNDARY WAS SOLID
          DEBSOL(SOL1) = IDEP
          FINLIQ(NFRLIQ) = IDEP
        ENDIF
!
      ELSE
!     CASE WHERE THE WHOLE CONTOUR HAS THE SAME TYPE
        IF(SOL1.NE.0) THEN
          DEBSOL(SOL1) = IDEP
          FINSOL(SOL1) = IDEP
        ELSEIF(LIQ1.NE.0) THEN
          DEBLIQ(LIQ1) = IDEP
          FINLIQ(LIQ1) = IDEP
        ELSE
          IF(LISTIN.AND.LNG.EQ.1) THEN
           WRITE(LU,'(1X,A)') 'CAS IMPOSSIBLE DANS FRONT2'
          ENDIF
          IF(LISTIN.AND.LNG.EQ.2) THEN
           WRITE(LU,'(1X,A)') 'IMPOSSIBLE CASE IN FRONT2'
          ENDIF
          CALL PLANTE(1)
          STOP
        ENDIF
      ENDIF
!
!-----------------------------------------------------------------------
!
!  CHECKS WHETHER THERE ARE OTHER CONTOURS LEFT:
!
      DO K = 1 , NPTFR
        IF(DEJAVU(K).EQ.0) THEN
          IDEP = K
          NILE = NILE + 1
          GO TO 20
        ENDIF
      ENDDO ! K
!
!-----------------------------------------------------------------------
!
      DO K=1,NPTFR
        NUMLIQ(K)=0
      ENDDO ! K
!
!-----------------------------------------------------------------------
!     COMPUTE WALLDIST: THE DISTANCE OF EACH INTERNAL POINT TO THE WALL 
      IF(YAWALL)THEN
!       1- INITIALISE
        DO K=1,NPOIN
          WALLDIST(K)=1.D10
        ENDDO
!       2-COMPUTE WALLDIST
        DO K=1,NPOIN
          MINNS=1.D10
          IF(NPTFR.GT.0)THEN
            DO L2=1,NPTFR
              IF(LIUBOR(L2).EQ.KLOG) THEN
                L1=NBOR(L2)
                DIST=SQRT((X(K)-X(L1))**2+(Y(K)-Y(L1))**2)
                IF(DIST.LT.MINNS) THEN
                  MINNS=DIST
                ENDIF
              ENDIF
            ENDDO
          ENDIF
          WALLDIST(K)=MAX(MINNS,EPSS)
        ENDDO
      ENDIF ! YAWALL
!
!-----------------------------------------------------------------------
!
!
!  PRINTS OUT THE RESULTS AND COMPUTES NUMLIQ
!
      IF(NILE.NE.0.AND.LISTIN.AND.LNG.EQ.1) WRITE(LU,69) NILE
      IF(NILE.NE.0.AND.LISTIN.AND.LNG.EQ.2) WRITE(LU,169) NILE
!
      IF(NFRLIQ.NE.0) THEN
        IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,70) NFRLIQ
        IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,170) NFRLIQ
        DO K = 1, NFRLIQ
!
!  MARKS THE NUMBERS OF THE LIQUID BOUNDARIES
!
          L1=DEBLIQ(K)
          NUMLIQ(L1)=K
707       L1=KP1BOR(L1)
          NUMLIQ(L1)=K
          IF(L1.NE.FINLIQ(K)) GO TO 707
!
!  END OF MARKING
!
          IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,90)
     &                            K,DEBLIQ(K),NBOR(DEBLIQ(K)),
     &                            X(NBOR(DEBLIQ(K))),Y(NBOR(DEBLIQ(K))),
     &                            FINLIQ(K),NBOR(FINLIQ(K)),
     &                            X(NBOR(FINLIQ(K))),Y(NBOR(FINLIQ(K)))
          IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,190)
     &                            K,DEBLIQ(K),NBOR(DEBLIQ(K)),
     &                            X(NBOR(DEBLIQ(K))),Y(NBOR(DEBLIQ(K))),
     &                            FINLIQ(K),NBOR(FINLIQ(K)),
     &                            X(NBOR(FINLIQ(K))),Y(NBOR(FINLIQ(K)))
        ENDDO ! K
      ENDIF
!
      IF(NFRSOL.NE.0) THEN
        IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,100) NFRSOL
        IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,101) NFRSOL
        DO K = 1, NFRSOL
          IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,90)
     &                            K,DEBSOL(K),NBOR(DEBSOL(K)),
     &                            X(NBOR(DEBSOL(K))),Y(NBOR(DEBSOL(K))),
     &                            FINSOL(K),NBOR(FINSOL(K)),
     &                            X(NBOR(FINSOL(K))),Y(NBOR(FINSOL(K)))
          IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,190)
     &                            K,DEBSOL(K),NBOR(DEBSOL(K)),
     &                            X(NBOR(DEBSOL(K))),Y(NBOR(DEBSOL(K))),
     &                            FINSOL(K),NBOR(FINSOL(K)),
     &                            X(NBOR(FINSOL(K))),Y(NBOR(FINSOL(K)))
        ENDDO ! K
      ENDIF
!
!-----------------------------------------------------------------------
!
      GO TO 2000
!
!-----------------------------------------------------------------------
!
!  FORMATS
!
69    FORMAT(/,1X,'IL Y A ',1I5,' ILE(S) DANS LE DOMAINE')
169   FORMAT(/,1X,'THERE IS ',1I5,' ISLAND(S) IN THE DOMAIN')
70    FORMAT(/,1X,'IL Y A ',1I5,' FRONTIERE(S) LIQUIDE(S) :')
170   FORMAT(/,1X,'THERE IS ',1I5,' LIQUID BOUNDARIES:')
100   FORMAT(/,1X,'IL Y A ',1I5,' FRONTIERE(S) SOLIDE(S) :')
101   FORMAT(/,1X,'THERE IS ',1I5,' SOLID BOUNDARIES:')
102   FORMAT(/,1X,'FRONT2 : ERREUR AU POINT DE BORD ',1I8,
     &       /,1X,'         POINT LIQUIDE ENTRE DEUX POINTS SOLIDES')
103   FORMAT(/,1X,'FRONT2 : ERROR AT BOUNDARY POINT ',1I8,
     &       /,1X,'         LIQUID POINT BETWEEN TWO SOLID POINTS')
104   FORMAT(/,1X,'FRONT2 : ERREUR AU POINT DE BORD ',1I8,
     &       /,1X,'         POINT SOLIDE ENTRE DEUX POINTS LIQUIDES')
105   FORMAT(/,1X,'FRONT2 : ERROR AT BOUNDARY POINT ',1I8,
     &       /,1X,'         SOLID POINT BETWEEN TWO LIQUID POINTS')
90    FORMAT(/,1X,'FRONTIERE ',1I4,' : ',/,1X,
     &            ' DEBUT AU POINT DE BORD ',1I8,
     &            ' , DE NUMERO GLOBAL ',1I9,/,1X,
     &            ' ET DE COORDONNEES : ',G16.7,3X,G16.7,
     &       /,1X,' FIN AU POINT DE BORD ',1I8,
     &            ' , DE NUMERO GLOBAL ',1I9,/,1X,
     &            ' ET DE COORDONNEES : ',G16.7,3X,G16.7)
190   FORMAT(/,1X,'BOUNDARY ',1I4,' : ',/,1X,
     &            ' BEGINS AT BOUNDARY POINT: ',1I8,
     &            ' , WITH GLOBAL NUMBER: ',1I9,/,1X,
     &            ' AND COORDINATES: ',G16.7,3X,G16.7,
     &       /,1X,' ENDS AT BOUNDARY POINT: ',1I8,
     &            ' , WITH GLOBAL NUMBER: ',1I9,/,1X,
     &            ' AND COORDINATES: ',G16.7,3X,G16.7)
!
!-----------------------------------------------------------------------
!
1000  CONTINUE
!
      IF(LNG.EQ.1) THEN
        WRITE(LU,*) 'FRONT2 : DEPASSEMENT DE TABLEAUX'
        WRITE(LU,*) '         AUGMENTER LE MOT-CLE'
        WRITE(LU,*) '         NOMBRE MAXIMUM DE FRONTIERES'
        WRITE(LU,*) '         DANS LE CODE APPELANT'
        WRITE(LU,*) '         LA VALEUR ACTUELLE EST ',MAXFRO
      ENDIF
      IF(LNG.EQ.2) THEN
        WRITE(LU,*) 'FRONT2: SIZE OF ARRAYS EXCEEDED'
        WRITE(LU,*) '        INCREASE THE KEYWORD'
        WRITE(LU,*) '        MAXIMUM NUMBER OF BOUNDARIES'
        WRITE(LU,*) '        IN THE CALLING PROGRAM'
        WRITE(LU,*) '        THE CURRENT VALUE IS ',MAXFRO
      ENDIF
      CALL PLANTE(1)
      STOP
!
!-----------------------------------------------------------------------
!
2000  CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END
