C                       *****************
                        SUBROUTINE EXTRAC
C                       *****************
C
     *(X,Y,SOM,IKLE,INDIC,NELEM,NELMAX,NPOIN,NSOM,PROJEC)
C
C***********************************************************************
C PROGICIEL : STBTEL V5.2    07/12/88    J-M HERVOUET (LNH) 30 87 80 18
C                            19/02/93    J-M JANIN    (LNH) 30 87 72 84
C                                        A   WATRIN
C***********************************************************************
C
C  FONCTION  :  PREPARATION DE DONNEES AVANT L'APPEL DE FMTSEL
C
C-----------------------------------------------------------------------
C                             ARGUMENTS
C .________________.____.______________________________________________
C !      NOM       !MODE!                   ROLE
C !________________!____!______________________________________________
C !________________!____!______________________________________________
C MODE : -->(DONNEE NON MODIFIEE), <--(RESULTAT), <-->(DONNEE MODIFIEE)
C-----------------------------------------------------------------------
C
C APPELE PAR : PREDON
C APPEL DE : -
C
C***********************************************************************
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INTEGER NELEM,NELMAX,NPOIN,NSOM,IELEM,IPOIN,ISOM,IDP,I1,I2,I3
      INTEGER IKLE(NELMAX,3),INDIC(NPOIN)
C
      DOUBLE PRECISION X(NPOIN),Y(NPOIN),SOM(10,2),DX,DY,A1,A2,A3
C
      LOGICAL PROJEC,FLAG,F1,F2,F3
C
C=======================================================================
C BOUCLE SUR TOUS LES PLANS DE COUPE      
C=======================================================================
C
      DO 5 ISOM = 1,NSOM
C
         DX = SOM(ISOM+1,1) - SOM(ISOM,1)
         DY = SOM(ISOM+1,2) - SOM(ISOM,2)
C
C=======================================================================
C POUR UN DEMI PLAN DE COUPE DONNE :      
C      RECHERCHE DES POINTS EXT.(=0) , INT.(=1) , SUR LE BORD (=2)
C=======================================================================
C
         DO 10 IPOIN = 1,NPOIN
            INDIC(IPOIN) = 0
            IF (DX*(Y(IPOIN)-SOM(ISOM,2)).GE.DY*(X(IPOIN)-SOM(ISOM,1)))
     *          INDIC(IPOIN) = 1
10       CONTINUE
C
         IELEM = 1
20       CONTINUE
         I1 = INDIC(IKLE(IELEM,1))
         I2 = INDIC(IKLE(IELEM,2))
         I3 = INDIC(IKLE(IELEM,3))
         IF (I1.EQ.0.OR.I2.EQ.0.OR.I3.EQ.0) THEN
            IF (I1.EQ.1) INDIC(IKLE(IELEM,1)) = 2
            IF (I2.EQ.1) INDIC(IKLE(IELEM,2)) = 2
            IF (I3.EQ.1) INDIC(IKLE(IELEM,3)) = 2
            IKLE(IELEM,1) = IKLE(NELEM,1)
            IKLE(IELEM,2) = IKLE(NELEM,2)
            IKLE(IELEM,3) = IKLE(NELEM,3)
            NELEM = NELEM - 1
         ELSE
            IELEM = IELEM + 1
         ENDIF
         IF (IELEM.NE.NELEM+1) GOTO 20
C
C=======================================================================
C POUR UN DEMI PLAN DE COUPE DONNE :      
C      ELIMINATION DES ELEMENTS DEGENERES
C=======================================================================
C
30       CONTINUE
         IELEM = 1
         FLAG = .FALSE.
35       CONTINUE
         I1 = IKLE(IELEM,1)
         I2 = IKLE(IELEM,2)
         I3 = IKLE(IELEM,3)
         F1 = INDIC(I1).EQ.2
         F2 = INDIC(I2).EQ.2
         F3 = INDIC(I3).EQ.2
         IF (F1.AND.F2.AND.F3) THEN
            IKLE(IELEM,1) = IKLE(NELEM,1)
            IKLE(IELEM,2) = IKLE(NELEM,2)
            IKLE(IELEM,3) = IKLE(NELEM,3)
            NELEM = NELEM - 1
         ELSE
            IF (F1.AND.F2) THEN
               IF (DX*(X(I2)-X(I1))+DY*(Y(I2)-Y(I1)).LE.0.D0) THEN
                  FLAG = .TRUE.
                  INDIC(I3) = 2
               ENDIF
            ENDIF
            IF (F2.AND.F3) THEN
               IF (DX*(X(I3)-X(I2))+DY*(Y(I3)-Y(I2)).LE.0.D0) THEN
                  FLAG = .TRUE.
                  INDIC(I1) = 2
               ENDIF
            ENDIF
            IF (F3.AND.F1) THEN
               IF (DX*(X(I1)-X(I3))+DY*(Y(I1)-Y(I3)).LE.0.D0) THEN
                  FLAG = .TRUE.
                  INDIC(I2) = 2
               ENDIF
            ENDIF
            IELEM = IELEM + 1
         ENDIF
         IF (IELEM.NE.NELEM+1) GOTO 35
         IF (FLAG) GOTO 30
C
C=======================================================================
C POUR UN DEMI PLAN DE COUPE DONNE :      
C      PROJECTION DES NOUVEAUX POINTS DE BORD
C=======================================================================
C
         IF (PROJEC) THEN
            A1 = 1.D0 / (DX*DX + DY*DY)
            A2 = A1 * (SOM(ISOM,1)*SOM(ISOM+1,2) -
     *                 SOM(ISOM,2)*SOM(ISOM+1,1) )
            DO 40 IDP = 1,3
               DO 50 IELEM = 1,NELEM
                  IPOIN = IKLE(IELEM,IDP)
                  IF (INDIC(IPOIN).EQ.2) THEN
                     A3 = A1*(X(IPOIN)*DX+Y(IPOIN)*DY)
                     X(IPOIN) = DX*A3 + DY*A2
                     Y(IPOIN) = DY*A3 - DX*A2
                  ENDIF
50             CONTINUE
40          CONTINUE
         ENDIF
C
5     CONTINUE
C
C=======================================================================
C
      RETURN
      END
