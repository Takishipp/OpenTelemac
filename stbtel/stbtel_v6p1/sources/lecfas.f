C                       *****************
                        SUBROUTINE LECFAS
C                       *****************
C
     * (X, Y, IKLE, NCOLOR, TFAST1, TFAST2, ADDFAS,
     *  NGEO , NFO1)
C
C***********************************************************************
C PROGICIEL : STBTEL V5.2          09/07/96   P. CHAILLET  (LHF)
C
C***********************************************************************
C
C     FONCTION  : LECTURE DES INFOS DE GEOMETRIE DANS LES FICHIERS
C                 ISSUS DU MAILLEUR FASTTABS
C
C-----------------------------------------------------------------------
C                             ARGUMENTS
C .________________.____.______________________________________________
C !      NOM       !MODE!                   ROLE
C !________________!____!______________________________________________
C ! X,Y            !<-- ! COORDONNEES DES POINTS DU MAILLAGE
C ! IKLE           !<-- ! NUMEROS GLOBAUX DES NOEUDS DE CHAQUE ELEMENT
C ! NCOLOR         !<-- ! TABLEAU DES COULEURS DES NOEUDS(POUR LES CL)
C ! NCOLOR         !<-- ! TABLEAU DES COULEURS DES NOEUDS(POUR LES CL)
C | TFAST1,2       | -->| TABLEAUX DE TRAVAIL (FASTTABS)
C | ADDFAS         | -->| INDICATEUR UTILISATION DES C.L. (FASTTABS)
C !________________!____!______________________________________________
C ! COMMON:        !    !
C !  GEO:          !    !
C !    MESH        ! -->! TYPE DES ELEMENTS DU MAILLAGE
C !    NDP         ! -->! NOMBRE DE NOEUDS PAR ELEMENTS
C !    NPOIN       ! -->! NOMBRE TOTAL DE NOEUDS DU MAILLAGE
C !    NELEM       ! -->! NOMBRE TOTAL D'ELEMENTS DU MAILLAGE
C !    NPMAX       ! -->! DIMENSION EFFECTIVE DES TABLEAUX X ET Y
C !                !    ! (NPMAX = NPOIN + 100)
C !    NELMAX      ! -->! DIMENSION EFFECTIVE DES TABLEAUX CONCERNANT
C !                !    ! LES ELEMENTS (NELMAX = NELEM + 200)
C !  FICH:         !    !
C !    NRES        !--> ! NUMERO DU CANAL DU FICHIER DE SERAFIN
C !    NGEO       !--> ! NUMERO DU CANAL DU FICHIER MAILLEUR
C !    NLIM      !--> ! NUMERO DU CANAL DU FICHIER DYNAM DE TELEMAC
C !    NFO1      !--> ! NUMERO DU CANAL DU FICHIER TRIANGLE TRIGRID
C !                !    !
C !  INFO:         !    !
C !    LNG         !--> ! LANGUE UTILISEE
C !    LU          !--> ! CANAL DE SORTIE DES MESSAGES
C !________________!____!______________________________________________
C MODE : -->(DONNEE NON MODIFIEE), <--(RESULTAT), <-->(DONNEE MODIFIEE)
C-----------------------------------------------------------------------
C APPELE PAR :
C APPEL DE :
C***********************************************************************
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INTEGER NGEO, NFO1
      INTEGER MESH, NDP, NPOIN, NELEM, NPMAX, NELMAX
      INTEGER IKLE(NELMAX,4)
      INTEGER NCOLOR(*), I, J
      INTEGER ITYPND,IPOIN,IELEM,IP,IE, IGC
      INTEGER TFAST1(*),TFAST2(*)
      LOGICAL ADDFAS
C
C VARIABLES LOCALES
      INTEGER ELMLOC(8)
      REAL    U,V
      DOUBLE PRECISION X(*), Y(*)
      CHARACTER*80 LIGNE
C
C COMMON
C
      COMMON/GEO/ MESH, NDP, NPOIN, NELEM, NPMAX, NELMAX
C
      IPOIN=0
      IELEM=0
      DO 5 I=1,NPOIN
        TFAST1(I)=  -1
 5    CONTINUE
C
C TRAITEMENT DE LA GEOMETRIE
C PREMIERE PASSE, ON S'OCCUPE DES ELEMENTS
C
      REWIND (NGEO)
 10   READ (NGEO, '(A)',ERR=8000, END=1000) LIGNE
        IF (LIGNE(1:2).EQ.'GE') THEN
           IELEM=IELEM+1
           READ(LIGNE(4:80),*,ERR=8000,END=9000) IE, (ELMLOC(J),J=1,8)
C
C TRAITEMENT EN FONCTION DU TYPE D'ELEMENT
C
C
           IF (ELMLOC(8).NE.0) THEN
C
C QUADRANGLE QUADRATIQUE
C- Il faut splitter les elements
C- on elimine des points
C
C
C - 1er element
C
             IKLE(IELEM,1)=ELMLOC(1)
             IKLE(IELEM,2)=ELMLOC(3)
             IKLE(IELEM,3)=ELMLOC(5)
C
C - 2eme element
C
             IELEM=IELEM+1
             IKLE(IELEM,1)=ELMLOC(5)
             IKLE(IELEM,2)=ELMLOC(7)
             IKLE(IELEM,3)=ELMLOC(1)
           ELSEIF (ELMLOC(6).NE.0) THEN
C
C TRIANGLE QUADRATIQUE
C- on elimine des points
C
             IKLE(IELEM,1)=ELMLOC(1)
             IKLE(IELEM,2)=ELMLOC(3)
             IKLE(IELEM,3)=ELMLOC(5)
           ELSEIF (ELMLOC(4).NE.0) THEN
C
C QUADRANGLE LINEAIRE
C- Il faut splitter les elements
C
C
C - 1er element
C
             IKLE(IELEM,1)=ELMLOC(1)
             IKLE(IELEM,2)=ELMLOC(2)
             IKLE(IELEM,3)=ELMLOC(3)
C
C - 2eme element
C
             IELEM=IELEM+1
             IKLE(IELEM,1)=ELMLOC(3)
             IKLE(IELEM,2)=ELMLOC(4)
             IKLE(IELEM,3)=ELMLOC(1)
         ELSE
C
C  TRIANGLE LINEAIRE
C- on conserve les elements tels quels
C
          DO 14 I=1,3
             IKLE(IELEM,I)=ELMLOC(I)
 14        CONTINUE
         ENDIF
C
      ENDIF
      GO TO 10
C
C TRAITEMENT DE LA GEOMETRIE
C DEUXIEME PASSE, ON S'OCCUPE DES POINTS
C
 1000 CONTINUE
      REWIND (NGEO)
 20   READ (NGEO, '(A)',ERR=8000, END=1010) LIGNE
        IF (LIGNE(1:3).EQ.'GNN') THEN
          IPOIN=IPOIN+1
          READ(LIGNE(4:70),*,ERR=8000,END=9000)IP,X(IPOIN),Y(IPOIN)
          TFAST1(IP)=IPOIN
        ENDIF
      GO TO 20
 1010 CONTINUE
C
C - CONVERTION DES NUMEROS DE POINTS DES ELEMENTS
C
      DO 25 I=1,NELEM
        DO 25 J=1,3
         IKLE(I,J)=TFAST1(IKLE(I,J))
  25  CONTINUE
C
C TRAITEMENT DES CONDITION CONDITIONS LIMITES
C SI DEMANDE
C
      IF (.NOT.ADDFAS) THEN
        RETURN
C       ------
      ENDIF
C -------------------
       DO 28 I=1,NPOIN
        TFAST1(I)=  0
 28    CONTINUE
       REWIND (NFO1)
 30    READ (NFO1, '(A)',ERR=8010, END=2000) LIGNE
       IF (LIGNE(1:3).EQ.'BCN') THEN
C
C CARTE BCN : NODAL BOUNDARY CONDITION
C
           READ(LIGNE(4:70),*,ERR=8010,END=9010)ITYPND
           IF (ITYPND.EQ.200) THEN
C
C FASTTABS BOUNDARY CONDITION = EXIT HEAD
C
             NCOLOR(IP)=1
           ELSEIF (ITYPND.EQ.1200) THEN
C
C FASTTABS BOUNDARY CONDITION = SLIP EXIT HEAD
C
             NCOLOR(IP)=11
           ELSEIF (ITYPND.EQ.1100) THEN
C
C FASTTABS BOUNDARY CONDITION = VELOCITY
C
             NCOLOR(IP)=9
           ENDIF
       ELSEIF (LIGNE(1:3).EQ.'BQL') THEN
C
C CARTE BQL : NODAL BOUNDARY CONDITION
C
           READ(LIGNE(4:70),*,ERR=8010,END=9010) IGC, U, V
           TFAST1(IGC)=8
       ELSEIF (LIGNE(1:3).EQ.'BHL') THEN
C
C CARTE BHL : NODAL BOUNDARY CONDITION
C
           READ(LIGNE(4:70),*,ERR=8010,END=9010) IGC, U
           TFAST2(IGC)=1
       ENDIF
       GO TO 30
 2000  CONTINUE
C
C ON VA RELIRE LE FICHIER NFO1 (BC)
C POUR LIRE LES CARTES GC
C
       IGC=0
       REWIND (NFO1)
 40    READ (NFO1, '(A)',ERR=8010, END=3000) LIGNE
       IF (LIGNE(1:3).EQ.'GC') THEN
        IGC=IGC+1
        READ(LIGNE(4:70),*,ERR=8010,END=9010)IE,
     +                (TFAST2(I),I=1,IE)
        DO 50 I=1,IE
          NCOLOR(TFAST2(I))=TFAST1(IGC)
 50     CONTINUE
       ENDIF
      GO TO 40
 3000 RETURN
 8000 CONTINUE
      IF (LNG.EQ.1) WRITE (LU,4000)
      IF (LNG.EQ.2) WRITE (LU,4001)
 4000 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SOUS-PROGRAMME LECFAS : ERREUR DANS LA'
     +        ,/,1X,'LECTURE DU FICHIER DE MAILLAGE FASTTABS.'
     +        ,/,1X,'***************************************')
 4001 FORMAT (//,1X,'****************************'
     +        ,/,1X,'SUBROUTINE LECFAS :'
     +        ,/,1X,'ERROR READING FASTTABS FILE.'
     +        ,/,1X,'****************************')
      STOP
 9000 CONTINUE
      IF (LNG.EQ.1) WRITE (LU,4010)
      IF (LNG.EQ.2) WRITE (LU,4011)
 4010 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SOUS-PROGRAMME LECFAS : FIN DU FICHIER'
     +        ,/,1X,'DE MAILLAGE FASTTABS RENCONTREE'
     +        ,/,1X,'***************************************')
 4011 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SUBROUTINE LECFAS : UNEXPECTED END OF'
     +        ,/,1X,'FASTTABS FILE ENCOUNTERED'
     +        ,/,1X,'***************************************')
      STOP
 8010 CONTINUE
      IF (LNG.EQ.1) WRITE (LU,4020)
      IF (LNG.EQ.2) WRITE (LU,4021)
 4020 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SOUS-PROGRAMME LECFAS : ERREUR DANS LA'
     +        ,/,1X,'LECTURE DU FICHIER CONDITIONS LIMITES '
     +        ,/,1X,'DE FASTTABS'
     +        ,/,1X,'***************************************')
 4021 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SUBROUTINE LECFAS : ERROR READING'
     +        ,/,1X,'FASTTABS BOUNDARY CONDITION FILE'
     +        ,/,1X,'***************************************')
      STOP
 9010 CONTINUE
      IF (LNG.EQ.1) WRITE (LU,4030)
      IF (LNG.EQ.2) WRITE (LU,4031)
 4030 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SOUS-PROGRAMME LECFAS :'
     +        ,/,1X,'FIN DU FICHIER CONDITIONS LIMITES RENCONTRE'
     +        ,/,1X,'***************************************')
 4031 FORMAT (//,1X,'***************************************'
     +        ,/,1X,'SUBROUTINE LECFAS : END OF'
     +        ,/,1X,'FASTTABS BOUNDARY CONDITION FILE ENCOUNTERED'
     +        ,/,1X,'***************************************')
      STOP
      END
