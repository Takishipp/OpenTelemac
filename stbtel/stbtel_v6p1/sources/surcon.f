C                       ***************** 
                        SUBROUTINE SURCON
C                       *****************
C
     *(X,Y,IKLE,IPO,NBOR,NPTFR,NCOLOR,IFABOR,COLOR)
C
C***********************************************************************
C PROGICIEL : STBTEL V5.2                   19/04/91  J-C GALLAND  (LNH)
C                                           19/02/93  J-M JANIN    (LNH)
C***********************************************************************
C
C FONCTION : DECOUPAGE DES TRIANGLES SURCONTRAINTS
C
C-----------------------------------------------------------------------
C                             ARGUMENTS
C .________________.____.______________________________________________.
C |      NOM       |MODE|                   ROLE                       |
C |________________|____|______________________________________________|
C |   X,Y          |<-->| COORDONNEES DU MAILLAGE .
C |   IKLE         |<-->| NUMEROS GLOBAUX DES NOEUDS DE CHAQUE ELEMENT
C |   TRAV1        |<-->| TABLEAU DE TRAVAIL
C |   NBOR         | -->| TABLEAU DES POINTS DE BORD
C |   NPTFR        | -->| NOMBRE DE POINT FRONTIERE
C |   NCOLOR       |<-->| TABLEAU DES COULEURS DES POINTS
C |   IFABOR       |<-->| TABLEAU DES VOISINS DES ELEMENTS
C |    COLOR       |<-->| STOCKAGE COULEURS DES NOEUDS SUR FICHIER GEO
C |________________|____|______________________________________________
C | COMMON:        |    |
C |  GEO:          |    |
C |    MESH        | -->| TYPE DES ELEMENTS DU MAILLAGE
C |    NDP         | -->| NOMBRE DE NOEUDS PAR ELEMENTS
C |    NPOIN       |<-->| NOMBRE TOTAL DE NOEUDS DU MAILLAGE
C |    NELEM       |<-->| NOMBRE TOTAL D'ELEMENTS DU MAILLAGE
C |    NPMAX       | -->| DIMENSION EFFECTIVE DES TABLEAUX X ET Y
C |                |    | (NPMAX = NPOIN + 0.1*NELEM)
C |    NELMAX      | -->| DIMENSION EFFECTIVE DES TABLEAUX CONCERNANT
C |                |    | LES ELEMENTS (NELMAX = NELEM + 0.2*NELEM)
C |                |    |
C |________________|____|______________________________________________|
C MODE : -->(DONNEE NON MODIFIEE), <--(RESULTAT), <-->(DONNEE MODIFIEE)
C-----------------------------------------------------------------------
C APPELE PAR : STBTEL
C APPEL DE : DECOUP
C***********************************************************************
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INTEGER NPOIN2 , NPOIN , NELEM2 , NELEM
      INTEGER ITEST , IELEM , KELEM , ISWAP , KSWAP
      INTEGER I , J , K , NPTFR , NPMAX , MESH , NDP , NELMAX
      INTEGER NBOR(*) , IKLE(NELMAX,4) , NCOLOR(*)
      INTEGER IFABOR(NELMAX,*) , IPO(*) , IP(3) , KP , ISUI(3)
C
      DOUBLE PRECISION X(*) , Y(*)
C
      LOGICAL COLOR
C
      COMMON/GEO/ MESH , NDP , NPOIN , NELEM , NPMAX , NELMAX
C
      DATA ISUI / 2 , 3 , 1 /
C
C=======================================================================
C
      IF (LNG.EQ.1) WRITE(LU,1050)
      IF (LNG.EQ.2) WRITE(LU,4050)
C
      NPOIN2 = NPOIN
      NELEM2 = NELEM
      ITEST  = 0
C
C=======================================================================
C RECHERCHE DES TRIANGLES SURCONTRAINTS
C=======================================================================
C
      DO 10 K = 1 , NPMAX
         IPO(K) = 0
10    CONTINUE
C
      DO 20 K = 1 , NPTFR
         IPO(NBOR(K)) = 1
20    CONTINUE
C
      DO 30 K = 1 , NELEM
         IF (IPO(IKLE(K,1))+IPO(IKLE(K,2))+IPO(IKLE(K,3)).EQ.3) THEN
C
C LE TRIANGLE EST SURCONTRAINT, ON LE DECOUPE EN TROIS
C
            ITEST  = ITEST + 1
            IF (ITEST.GT.INT(0.1*NELMAX)) THEN
               IF (LNG.EQ.1) WRITE(LU,1000) INT(0.1*NELMAX)
               IF (LNG.EQ.2) WRITE(LU,4000) INT(0.1*NELMAX)
               STOP
            ENDIF
C
            IF (LNG.EQ.1) WRITE(LU,1070) X(IKLE(K,1)),Y(IKLE(K,1)),
     *         X(IKLE(K,2)),Y(IKLE(K,2)),X(IKLE(K,3)),Y(IKLE(K,3))
            IF (LNG.EQ.2) WRITE(LU,4070) X(IKLE(K,1)),Y(IKLE(K,1)),
     *         X(IKLE(K,2)),Y(IKLE(K,2)),X(IKLE(K,3)),Y(IKLE(K,3))
C
            CALL DECOUP (K,X,Y,IKLE,NCOLOR,IFABOR,
     *                   NELEM2,NPOIN2,COLOR)
C
         ENDIF
30    CONTINUE
C
C=======================================================================
C REMISE A JOUR DE NPOIN ET NELEM
C=======================================================================
C
      NPOIN = NPOIN2
      NELEM = NELEM2
C
C=======================================================================
C MAINTENANT ON SWAPE LES ARETES CONTENANT 2 POINTS DE BORD ET QUI NE
C SONT PAS DES ARETES DE BORD
C
C REMARQUE : LES IFABOR NE SONT PAS MODIFIES DANS CE QUI SUIT CAR
C            ILS NE SERVENT PLUS APRES POUR LE LOGICIEL
C=======================================================================
C
      ISWAP = 0
      KSWAP = 0
      DO 40 IELEM = 1,NELEM
         IP(1) = IKLE(IELEM,1)
         IP(2) = IKLE(IELEM,2)
         IP(3) = IKLE(IELEM,3)
         DO 50 I = 1,3
            J = ISUI(I)
            IF(IFABOR(IELEM,I).GT.0.AND.IPO(IP(I))+IPO(IP(J)).EQ.2) THEN
               KELEM = IFABOR(IELEM,I)
C
C COMPTE TENU DU PREMIER DECOUPAGE, ON EST SUR QUE TOUT ELEMENT CONTIENT
C AU MOINS UN POINT INTERIEUR, ET DANS CE CAS UN SEUL.
C K EST SUR D'ETRE REMPLI.
C
               IF (IPO(IKLE(KELEM,1)).EQ.0) K=1
               IF (IPO(IKLE(KELEM,2)).EQ.0) K=2
               IF (IPO(IKLE(KELEM,3)).EQ.0) K=3
               KP = IKLE(KELEM,K)
C
               IF ((X(KP)-X(IP(I)))*(Y(IP(ISUI(J)))-Y(IP(I))).GT.
     *             (Y(KP)-Y(IP(I)))*(X(IP(ISUI(J)))-X(IP(I))).AND.
     *             (X(KP)-X(IP(J)))*(Y(IP(ISUI(J)))-Y(IP(J))).LT.
     *             (Y(KP)-Y(IP(J)))*(X(IP(ISUI(J)))-X(IP(J)))) THEN
C
                  ISWAP = ISWAP + 1
                  IKLE(IELEM,I) = KP
                  IKLE(KELEM,ISUI(K)) = IP(ISUI(J))
C
                  IF (LNG.EQ.1) WRITE(LU,1080) X(IP(I)),Y(IP(I)),
     *                                         X(IP(J)),Y(IP(J))
                  IF (LNG.EQ.2) WRITE(LU,4080) X(IP(I)),Y(IP(I)),
     *                                         X(IP(J)),Y(IP(J))
C
               ELSE
C
                  KSWAP = KSWAP + 1
C
               ENDIF
            ENDIF
 50      CONTINUE
 40   CONTINUE
C
C=======================================================================
C
      IF (LNG.EQ.1) WRITE(LU,1100) ITEST,NPOIN,NELEM,ISWAP
      IF (LNG.EQ.2) WRITE(LU,4100) ITEST,NPOIN,NELEM,ISWAP
C
      IF (KSWAP.NE.0) THEN
         IF (LNG.EQ.1) WRITE(LU,1200) KSWAP
         IF (LNG.EQ.2) WRITE(LU,4200) KSWAP
      ENDIF
C
 1000 FORMAT(//,1X,'**************************************************',
     *        /,1X,'LE NOMBRE MAXIMUM DE TRIANGLES SURCONTRAINTS PREVU',
     *        /,1X,'EST DE',I5,' : IL EST PLUS GRAND DANS VOTRE CAS ||',
     *        /,1X,'**************************************************')
 4000 FORMAT(//,1X,'**************************************************',
     *        /,1X,'THE MAXIMUM NUMBER OF OVERSTRESSED TRIANGLES   ',
     *        /,1X,'IS',I5,' : IT IS GREATER IN YOUR CASE ||',
     *        /,1X,'**************************************************')
 1050 FORMAT(//,1X,'ELIMINATION DES TRIANGLES SURCONTRAINTS',/,
     *          1X,'---------------------------------------',/)
 1070 FORMAT   (1X,'RAJOUT D''UN NOEUD AU CENTRE DU TRIANGLE :',/,
     *          1X,'(',D9.3,',',D9.3,'),(',D9.3,',',D9.3,'),',
     *             '(',D9.3,',',D9.3,')')
 1080 FORMAT   (1X,'SWAP DE L''ARETE :',/,
     *          1X,'(',D9.3,',',D9.3,'),(',D9.3,',',D9.3,')')
 1100 FORMAT (/,1X,'NOMBRE D''ELEMENTS SURCONTRAINTS : ',I5,/,
     *          1X,'APRES LEUR ELIMINATION :',/,
     *          1X,'          NOMBRE DE POINTS      : ',I5,/,
     *          1X,'          NOMBRE DE D''ELEMENTS  : ',I5,//,
     *          1X,'DE PLUS,',I4,' TRIANGLES ONT ETE SWAPES',//)
 1200 FORMAT   (1X,'    MAIS',I4,' N''ONT PU L''ETRE',//)
 4050 FORMAT(//,1X,'OVERSTRESSED ELEMENTS ARE CANCELLED',/,
     *          1X,'-----------------------------------',/)
 4070 FORMAT   (1X,'ADDITIONAL NODE AT CENTRE OF TRIANGLE :',/,
     *          1X,'(',D9.3,',',D9.3,'),(',D9.3,',',D9.3,'),',
     *             '(',D9.3,',',D9.3,')')
 4080 FORMAT   (1X,'SWAP OF FACE :',/,
     *          1X,'(',D9.3,',',D9.3,'),(',D9.3,',',D9.3,')')
 4100 FORMAT (/,1X,'NUMBER OF CANCELLED ELEMENTS : ',I5,/,
     *          1X,'AFTER BEING CANCELLED :',/,
     *          1X,'          NUMBER OF POINTS      : ',I5,/,
     *          1X,'          NUMBER OF ELEMENTS    : ',I5,//,
     *          1X,'MOREOVER,',I4,' TRIANGLES HAVE BEEN SWAPPED',//)
 4200 FORMAT   (1X,'      BUT',I4,' COULD NOT BE',//)
C
      RETURN
      END
