!                    **************
                     SUBROUTINE CMD
!                    **************
!
     &(ICOL   , LIGNE  , ADRESS , DIMENS , TROUVE , MOTCLE , NMOT ,
     & MOTINT , MOTREA , MOTLOG , MOTCAR , MOTATT , INDIC  , SIZE ,
     & UTINDX , DYNAM  , VUCMD  , EXECMD , NFICDA , NMAXR  )
!
!***********************************************************************
! DAMOCLES   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    CARRIES OUT A COMMAND PROVIDED IN THE DICTIONARY AND
!+             STEERING FILES : COMMAND = '&' + 3 LETTERS.
!
!note     PORTABILITY : IBM,CRAY,HP,SUN
!note      DOCUMENTATION : COMMANDS &LIS, &ETA, &IND, &STO, &FIN
!+                             ARE ONLY CARRIED OUT IF EXECMD=.TRUE.
!+                             AND VUCMD(NB_CMB)=.TRUE.
!+                             COMMAND &DYN IS IGNORED IN THE STEERING FILE
!
!history  O. QUIQUEMPOIX (LNH)
!+        14/12/1993
!+        
!+   
!
!history  J-M HERVOUET (LNH); A. YESSAYAN; L. LEGUE
!+        15/01/2008
!+        V5P8
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
!| ADRESS         |-->| TABLEAU DES ADRESSES DES MOTS CLES
!| DIMENS         |-->| TABLEAU DES DIMENSIONS DES MOTS CLES
!| DYNAM          |<->| LOGIQUE POUR LE MODE DYNAMIQUE
!| EXECMD         |-->| LOGIQUE D'ACTIVATION DES COMMANDES MEMORISEES
!| ICOL           |<->| POSITION COURANTE DU POINTEUR DANS LA LIGNE
!| INDIC          |-->| TABLEAU D'INDICATEURS D'ETAT DES MOTS CLES
!|                |   | = 0 : PAS DE SUBMIT & NON TABLEAU
!|                |   | = 1 : PAS DE SUBMIT & TABLEAU
!|                |   | = 2 : AVEC   SUBMIT & NON TABLEAU
!|                |   | = 3 : AVEC   SUBMIT & NON TABLEAU
!| LIGNE          |-->| LIGNE EN COURS DE DECODAGE.
!| MOTATT         |-->| TABLEAU DES SUBMITS
!| MOTCAR         |-->| TABLEAU DES VALEURS CARACTERES
!| MOTCLE         |-->| TABLEAU DES MOTS CLES ACTIFS
!| MOTINT         |-->| TABLEAU DES VALEURS ENTIERES
!| MOTLOG         |-->| TABLEAU DES VALEURS LOGIQUES
!| MOTREA         |-->| TABLEAU DES VALEURS REELLES
!| NFICDA         |-->| NUMERO DE CANAL DU FICHIER DES DONNEES
!| NMAXR          |-->| TABLEAU DES INDEX MAXIMUM REELS PAR TYPES
!| NMOT           |-->| TABLEAU DU NOMBRE DE MOTS CLES PAR TYPE
!| SIZE           |-->| TABLEAU DES LONGUEURS DES MOTS CLES
!| TROUVE         |-->| INDICATEUR D'ETAT DES MOTS CLES
!|                |   | = 0 : AUCUNE VALEUR TROUVEE
!|                |   | = 1 : VALEUR PAR DEFAUT TROUVEE
!|                |   | = 2 : VALEUR TROUVEE (FICHIER DE DONNEES)
!|                |   | = 3 : AUCUNE VALEUR TROUVEE (OPTIONNELLE)
!|                |   | = 5 : TABLEAU DE MOTS A SUBMIT COMPACTE
!|                |   | = 6 : MOT CLE A SUBMIT FORCE NON AFFECTE
!|                |   | = 7 : MOT CLE A SUBMIT FORCE AFFECTE (DICO)
!|                |   | = 8 : MOT CLE A SUBMIT FORCE AFFECTE (CAS)
!|                |   | = 9 : FICHIER DICO : SUBMIT + VALEUR LANCEUR
!|                |   | =10 : FICHIER CAS  : SUBMIT + VALEUR LANCEUR
!| UTINDX         |-->| TABLEAU DE LOGIQUES D'UTILISATION DES INDEX
!| VUCMD          |<->| TABLEAU DE LOGIQUES (MEMORISATION DES CMDES)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
!
      INTEGER          ICOL,ADRESS(4,*),DIMENS(4,*),NMOT(4),TROUVE(4,*)
      INTEGER          SIZE(4,*),INDIC(4,*),MOTINT(*),NFICDA,NMAXR(4)
      LOGICAL          MOTLOG(*),DYNAM,UTINDX(4,*),VUCMD(5),EXECMD
      CHARACTER*(*)    MOTCLE(4,*),LIGNE
      CHARACTER*144    MOTATT(4,*),MOTCAR(*)
      DOUBLE PRECISION MOTREA(*)
!
      INTEGER  PREVAL,LONGLU
      EXTERNAL PREVAL,LONGLU
!
      INTEGER          LNG,LU
      INTEGER          NLIGN,LONGLI
      INTEGER          NFIC
      LOGICAL          ERREUR , RETOUR
!
!-----------------------------------------------------------------------
!
      INTEGER          I1,IAD,L1,L2,TRANS,ISIZE,K,I,N
      CHARACTER*72     FORMA1(35)
      CHARACTER*6      TYP(4)
      CHARACTER*1      TABUL
!
!-----------------------------------------------------------------------
!
      COMMON / DCINFO / LNG,LU
      COMMON / DCCHIE / NFIC
      COMMON / DCMLIG / NLIGN , LONGLI
      COMMON / DCRARE / ERREUR , RETOUR
!
      INTRINSIC CHAR
!
!-----------------------------------------------------------------------
!
      DATA TYP/'MOTINT','MOTREA','MOTLOG','MOTCAR'/
!
!***********************************************************************
!                                    RCS AND SCCS MARKING
!
!***********************************************************************
!
      TABUL = CHAR(9)
      I1 = ICOL + 1
!     ADDED BY JMH 15/01/2008: CASE WHERE LIGNE='NUL'
      IF(I1+2.GT.LONGLI) I1=1
!
! *********************** COMMAND &FIN **************************
!
      IF(LIGNE(I1:I1+2).EQ.'FIN'.OR.(EXECMD.AND.VUCMD(5))) THEN
           IF (.NOT.(EXECMD)) THEN
             VUCMD(5) = .TRUE.
             RETOUR = .TRUE.
             GO TO 1000
           ENDIF
           IF(LNG.EQ.1) THEN
             WRITE (LU,10)
 10          FORMAT(1X,/,1X,'FIN DU FICHIER POUR DAMOCLES',/)
           ELSEIF(LNG.EQ.2) THEN
             WRITE (LU,12)
 12          FORMAT(1X,/,1X,'END OF FILE FOR DAMOCLES',/)
           ENDIF
!
! *********************** COMMAND &ETA **************************
!
      ELSE IF (LIGNE(I1:I1+2).EQ.'ETA'.OR.(EXECMD.AND.VUCMD(2))) THEN
           IF (.NOT.(EXECMD)) THEN
             VUCMD(2) = .TRUE.
             GO TO 1000
           ENDIF
           IF(LNG.EQ.1) THEN
             WRITE (LU,11)
 11          FORMAT(1X,/,1X,'VALEUR DES MOTS-CLES :',/)
           ELSEIF(LNG.EQ.2) THEN
             WRITE (LU,13)
 13          FORMAT(1X,/,1X,'VALUES OF THE KEY-WORDS:',/)
           ENDIF
!
           FORMA1(1)= '(1X,A,/,1X,7HMOTINT(,1I3,2H)=,A,I9   ,/)'
           FORMA1(2)= '(1X,A,/,1X,7HMOTREA(,1I3,2H)=,A,G16.7,/)'
           FORMA1(3)= '(1X,A,/,1X,7HMOTLOG(,1I3,2H)=,A,L1   ,/)'
           FORMA1(4)= '(1X,A,/,1X,7HMOTCAR(,1I3,2H)=,A,A    ,/)'
           FORMA1(5)= '(1X,A,/,1X,7HMOTINT(,1I3,4H) = ,A,3H ; ,I9   ,/)'
           FORMA1(6)= '(1X,A,/,1X,7HMOTREA(,1I3,4H) = ,A,3H ; ,G16.7,/)'
           FORMA1(7)= '(1X,A,/,1X,7HMOTLOG(,1I3,4H) = ,A,3H ; ,L1   ,/)'
           FORMA1(8)= '(1X,A,/,1X,7HMOTCAR(,1I3,4H) = ,A,3H ; ,A    ,/)'
!
           DO 209 N =1,4
           DO 210 I = 1 , NMAXR(N)
           IF(UTINDX(N,I)) THEN
           ISIZE = SIZE(N,I)
           IF(TROUVE(N,I).GE.1) THEN
             DO 211 K=1,DIMENS(N,I)
             IAD = ADRESS(N,I) + K - 1
              IF (INDIC(N,I).LT.2) THEN
                TRANS=0
                MOTATT(N,IAD)=' '
                L1=1
              ELSE
                TRANS=4
                L1=LONGLU(MOTATT(N,IAD))
              ENDIF
!             IF (TROUVE(N,I).NE.3) THEN
               IF(N.EQ.1) THEN
                WRITE(LU,FORMA1(N+TRANS))
     &          MOTCLE(N,I)(1:ISIZE),IAD,MOTATT(N,IAD)(1:L1),MOTINT(IAD)
               ELSE IF (N.EQ.2) THEN
                WRITE(LU,FORMA1(N+TRANS))
     &          MOTCLE(N,I)(1:ISIZE),IAD,MOTATT(N,IAD)(1:L1),MOTREA(IAD)
               ELSE IF (N.EQ.3) THEN
                WRITE(LU,FORMA1(N+TRANS))
     &          MOTCLE(N,I)(1:ISIZE),IAD,MOTATT(N,IAD)(1:L1),MOTLOG(IAD)
               ELSE IF (N.EQ.4) THEN
                L2 = LONGLU(MOTCAR(IAD))
                WRITE(LU,FORMA1(N+TRANS))
     &          MOTCLE(N,I)(1:ISIZE),IAD,MOTATT(N,IAD)(1:L1),
     &          MOTCAR(IAD)(1:L2)
               ENDIF
!             ENDIF
211        CONTINUE
           ELSE
             IF(LNG.EQ.1) THEN
               WRITE(LU,212) MOTCLE(N,I)(1:ISIZE)
212            FORMAT(1X,A,/,1X,'VALEUR NON TROUVEE',/,1X)
             ELSEIF(LNG.EQ.2) THEN
               WRITE(LU,213) MOTCLE(N,I)(1:ISIZE)
213            FORMAT(1X,A,/,1X,'VALUE NOT FOUND',/,1X)
             ENDIF
           ENDIF
!
           ENDIF
210        CONTINUE
209        CONTINUE
!
! *********************** COMMAND &IND **************************
!
      ELSE IF (LIGNE(I1:I1+2).EQ.'IND'.OR.(EXECMD.AND.VUCMD(3))) THEN
           IF (.NOT.(EXECMD)) THEN
             VUCMD(3) = .TRUE.
             GOTO 1000
           ENDIF
!
! DEFINITION OF THE FORMATS USED
!
           FORMA1(1)  = '(1X,7HMOTINT(,1I3,3H) =,A,I9   )'
           FORMA1(2)  = '(1X,7HMOTREA(,1I3,3H) =,A,G16.7)'
           FORMA1(3)  = '(1X,7HMOTLOG(,1I3,3H) =,A,L1   )'
           FORMA1(4)  = '(1X,7HMOTCAR(,1I3,3H) =,A,A    )'
           FORMA1(5)  = '(1X,7HMOTINT(,1I3,4H) = ,A,3H ; ,I9   )'
           FORMA1(6)  = '(1X,7HMOTREA(,1I3,4H) = ,A,3H ; ,G16.7)'
           FORMA1(7)  = '(1X,7HMOTLOG(,1I3,4H) = ,A,3H ; ,L1   )'
           FORMA1(8)  = '(1X,7HMOTCAR(,1I3,4H) = ,A,3H ; ,A    )'
           FORMA1(9)  = '(1X,24H!!! TABLEAU COMPACTE !!!)'
           FORMA1(10) = '(1X,23H!!! COMPACTED ARRAY !!!)'
           FORMA1(11) = '(1X,32HATTENTION ! TAILLE EN SORTIE = 0)'
           FORMA1(12) = '(1X,25HWARNING ! OUTPUT SIZE = 0)'
           FORMA1(13) = '(1X,9HTAILLE = ,I4)'
           FORMA1(14) = '(1X,8HSIZE  = ,I4)'
           FORMA1(15) = '(1X,30HVALEUR OPTIONNELLE NON TROUVEE)'
           FORMA1(16) = '(1X,24HOPTIONAL VALUE NOT FOUND)'
           FORMA1(17) = '(1X,25HVALEUR FORCEE NON TROUVEE)'
           FORMA1(18) = '(1X,22HFORCED VALUE NOT FOUND)'
           FORMA1(19) = '(1X,9HINDEX  = ,I4)'
           FORMA1(20) = '(1X,8HINDEX = ,I4)'
           FORMA1(21) = '(1X,18HVALEUR NON TROUVEE)'
           FORMA1(22) = '(1X,15HVALUE NOT FOUND)'
           FORMA1(23) = '(/,1X,22HVALEUR DES MOTS-CLES :,/)'
           FORMA1(24) = '(/,1X,25HVALUES OF THE KEY-WORDS :,/)'
           FORMA1(25) = '(1X,29HNOMBRE DE MOTS ENTIERS     = ,I4,'//
     &                  '10X,16H(DERNIER INDEX :,I4,1H))'
           FORMA1(26) = '(1X,32HNUMBER OF INTEGER   KEY WORDS = ,I4,'//
     &                  '10X,13H(LAST INDEX :,I4,1H))'
           FORMA1(27) = '(1X,29HNOMBRE DE MOTS REELS       = ,I4,'//
     &                  '10X,16H(DERNIER INDEX :,I4,1H))'
           FORMA1(28) = '(1X,32HNUMBER OF REAL      KEY WORDS = ,I4,'//
     &                  '10X,13H(LAST INDEX :,I4,1H))'
           FORMA1(29) = '(1X,29HNOMBRE DE MOTS LOGIQUES    = ,I4,'//
     &                  '10X,16H(DERNIER INDEX :,I4,1H))'
           FORMA1(30) = '(1X,32HNUMBER OF LOGICAL   KEY WORDS = ,I4,'//
     &                  '10X,13H(LAST INDEX :,I4,1H))'
           FORMA1(31) = '(1X,29HNOMBRE DE MOTS CARACTERES  = ,I4,'//
     &                  '10X,16H(DERNIER INDEX :,I4,1H))'
           FORMA1(32) = '(1X,32HNUMBER OF CHARACTER KEY WORDS = ,I4,'//
     &                  '10X,13H(LAST INDEX :,I4,1H))'
           FORMA1(33) = '(1X,29HNOMBRE TOTAL DE MOTS CLES  = ,I4)'
           FORMA1(34) = '(1X,32HTOTAL NUMBER OF KEY WORDS     = ,I4)'
           FORMA1(35) = '(/,1X,70(1H-),/,1X,A,/,1X,70(1H-))'
!
! TITLE
           WRITE(LU,FORMA1(22+LNG))
!
           WRITE(LU,*)' '
           WRITE(LU,*)'====================================='
           WRITE(LU,FORMA1(24+LNG)) NMOT(1),NMAXR(1)
           WRITE(LU,FORMA1(26+LNG)) NMOT(2),NMAXR(2)
           WRITE(LU,FORMA1(28+LNG)) NMOT(3),NMAXR(3)
           WRITE(LU,FORMA1(30+LNG)) NMOT(4),NMAXR(4)
           WRITE(LU,*)'-------------------------------------'
           WRITE(LU,FORMA1(32+LNG)) NMOT(1)+NMOT(2)+NMOT(3)+NMOT(4)
           WRITE(LU,*)'====================================='
           WRITE(LU,*)' '
!
           DO 409 N =1,4
           DO 410 I = 1 , NMAXR(N)
           IF(UTINDX(N,I)) THEN
           IF(TROUVE(N,I).GE.1.OR.DIMENS(N,I).GT.1) THEN
             WRITE(LU,FORMA1(35)) MOTCLE(N,I)(1:SIZE(N,I))
! COMPACTED ?
             IF (TROUVE(N,I).EQ.5) WRITE(LU,FORMA1(8+LNG))
! INDEX
             WRITE(LU,FORMA1(18+LNG)) I
! SIZE
             WRITE(LU,FORMA1(12+LNG)) DIMENS(N,I)
             IF (DIMENS(N,I).GT.1.AND.TROUVE(N,I).EQ.0.AND.DYNAM)
     &          WRITE(LU,FORMA1(10+LNG))
!
! TROUVE ?
             IF (TROUVE(N,I).EQ.3) WRITE(LU,FORMA1(14+LNG))
             IF (TROUVE(N,I).EQ.6) WRITE(LU,FORMA1(16+LNG))
!
! LINEFEED FOR PRESENTATION PURPOSES
             IF (DIMENS(N,I).GT.1) WRITE(LU,*) ' '
!
             DO 411 K=1,DIMENS(N,I)
              IAD = ADRESS(N,I) + K - 1
              IF (INDIC(N,I).GE.2) THEN
                TRANS = 4
                L1=LONGLU(MOTATT(N,IAD))
              ELSE
                TRANS = 0
                MOTATT(N,IAD)=' '
                L1 =1
              ENDIF
!
!             IF (TROUVE(N,I).NE.3) THEN
               IF(N.EQ.1) THEN
                    WRITE(LU,FORMA1(N+TRANS))
     &                    IAD,MOTATT(N,IAD)(1:L1),MOTINT(IAD)
               ELSE IF (N.EQ.2) THEN
                    WRITE(LU,FORMA1(N+TRANS))
     &                    IAD,MOTATT(N,IAD)(1:L1),MOTREA(IAD)
               ELSE IF (N.EQ.3) THEN
                    WRITE(LU,FORMA1(N+TRANS))
     &                    IAD,MOTATT(N,IAD)(1:L1),MOTLOG(IAD)
               ELSE IF (N.EQ.4) THEN
                    L2 = LONGLU(MOTCAR(IAD))
                    WRITE(LU,FORMA1(N+TRANS))
     &                    IAD,MOTATT(N,IAD)(1:L1),MOTCAR(IAD)(1:L2)
               ENDIF
!             ENDIF
411        CONTINUE
           ELSE
              WRITE(LU,FORMA1(35)) MOTCLE(N,I)(1:SIZE(N,I))
              WRITE(LU,FORMA1(20+LNG))
              WRITE(LU,FORMA1(18+LNG)) I
              WRITE(LU,FORMA1(12+LNG)) DIMENS(N,I)
              WRITE(LU,*)' '
           ENDIF
!
           ENDIF
410        CONTINUE
409        CONTINUE
!
! *********************** COMMAND &LIS **************************
!
      ELSE IF (LIGNE(I1:I1+2).EQ.'LIS'.OR.(EXECMD.AND.VUCMD(1))) THEN
           IF (.NOT.(EXECMD)) THEN
             VUCMD(1) = .TRUE.
             GO TO 1000
           ENDIF
! FORMATS
           FORMA1(1) = '(/,1X,21HLISTE DES MOTS-CLES :,/)'
           FORMA1(2) = '(/,1X,16HKEY-WORDS LIST :,/)'
           FORMA1(3) = '(1X,12HDIMENSION : ,I3,5X,13HADRESSE DANS ,A,'//
     &                 '1X,1H:,1X,I3)'
           FORMA1(4) = '(1X,7HSIZE : ,I3,5X,10HADRESS IN ,A,'//
     &                 '1X,1H:,1X,I3)'
           FORMA1(5) =  '(1X,/,1X,A)'
! TITLE
           WRITE (LU,FORMA1(LNG))
!
           DO 309 N = 1 , 4
           DO 310 I = 1 , NMAXR(N)
!
           IF(UTINDX(N,I)) THEN
             IAD = ADRESS(N,I)
             WRITE (LU,FORMA1(5)) MOTCLE(N,I)(1:SIZE(N,I))
             IF (DIMENS(N,I).GT.1.AND.TROUVE(N,I).EQ.0.AND.DYNAM) THEN
               WRITE (LU,FORMA1(2+LNG)) 0,TYP(N),IAD
             ELSE
               WRITE (LU,FORMA1(2+LNG)) DIMENS(N,I),TYP(N),IAD
             ENDIF
           ENDIF
310        CONTINUE
309        CONTINUE
!
! *********************** COMMAND &DOC **************************
!
      ELSE IF ( LIGNE(I1:I1+2).EQ.'DOC' ) THEN
!
       IF(LNG.EQ.1) THEN
         WRITE(LU,*) 'COMMANDE &DOC SUPPRIMEE DANS CETTE VERSION'
       ELSEIF(LNG.EQ.2) THEN
         WRITE(LU,*) 'COMMAND &DOC HAS BEEN SUPPRESSED IN THIS RELEASE'
       ENDIF
!
! *********************** COMMAND &STO **************************
!
      ELSE IF (LIGNE(I1:I1+2).EQ.'STO'.OR.(EXECMD.AND.VUCMD(4))) THEN
           IF (.NOT.(EXECMD)) THEN
             VUCMD(4) = .TRUE.
             RETOUR=.TRUE.
             GO TO 1000
           ENDIF
           IF(LNG.EQ.1) THEN
             WRITE (LU,1113)
1113         FORMAT(1X,/,1X,'ARRET DE DAMOCLES PAR LA COMMANDE &STO')
           ELSEIF(LNG.EQ.2) THEN
             WRITE (LU,1114)
1114         FORMAT(1X,/,1X,'DAMOCLES STOPPED BY COMMAND &STO')
           ENDIF
           STOP 'FIN DE DAMOCLES 10'
!
! *********************** COMMAND &DYN **************************
!
      ELSEIF ( LIGNE(I1:I1+2).EQ.'DYN' ) THEN
           IF (NFIC.EQ.NFICDA) THEN
             IF (LNG.EQ.1) THEN
               WRITE(LU,*)'COMMANDE &DYN DU FICHIER CAS IGNOREE !!'
             ELSEIF(LNG.EQ.2) THEN
               WRITE(LU,*)'WARNING : INSTRUCTION &DYN FROM STEERING ',
     &                    'FILE HAS BEEN IGNORED !!'
             ENDIF
           ELSE
             DYNAM=.TRUE.
           ENDIF
      ELSE
           IF(LNG.EQ.1) THEN
           WRITE(LU,'(1X,A)') LIGNE(1:LONGLI)
           WRITE(LU,'(1X,A6,I4,A)') 'LIGNE: ',NLIGN,' COMMANDE INCONNUE'
           ELSEIF(LNG.EQ.2) THEN
           WRITE(LU,'(1X,A)') LIGNE(1:LONGLI)
           WRITE(LU,'(1X,A6,I4,A)') 'LINE: ',NLIGN,' UNKNOWN COMMAND'
           ENDIF
      ENDIF
!
!     //// SEEKS THE FIRST WHITE CHARACTER FOLLOWING & ////
!
 1000 CONTINUE
      ICOL = PREVAL (I1+1,LIGNE,' ',TABUL,' ')
!
!-----------------------------------------------------------------------
!
      RETURN
      END