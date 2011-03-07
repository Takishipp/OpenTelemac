!                    *****************
                     SUBROUTINE PREPRO
!                    *****************
!
     &( CX    , CY    , CT    , CF    , DT    , NRK   , X     , Y     ,
     &  TETA  , COSTET, SINTET, FREQ  , IKLE2 , IFABOR, ETAP1 , TRA01 ,
     &  SHP1  , SHP2  , SHP3  , SHZ   , SHF   , ELT   , ETA   , FRE   ,
     &  DEPTH , DZHDT , DZX   , DZY   , U     , V     , DUX   , DUY   ,
     &  DVX   , DVY   , XK    , CG    , COSF  , TGF   , ITR01 , NPOIN3,
     &  NPOIN2, NELEM2, NPLAN , NF    , SURDET, COURAN, SPHE  ,
     &  PROINF, PROMIN, MESH)
!
!***********************************************************************
! TOMAWAC   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    PREPARES ADVECTION.
!+
!+            COMPUTES THE ADVECTION FIELD; TRACES BACK THE
!+                CHARACTERISTICS.
!
!history  F. MARCOS (LNH)
!+        04/12/95
!+        V1P0
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
!| CG             |-->| VITESSE DE GROUPE DISCRETISEE
!| COSF           |-->| COSINUS DES LATITUDES DES POINTS 2D
!| COSTET         |-->| COSINUS TETA
!| COURAN         |-->| LOGIQUE INDIQUANT SI ON A UN COURANT
!| CX,CY,CT,CF    |<->| CHAMP CONVECTEUR SELON X(OU PHI),
!|                |   | Y(OU LAMBDA) TETA ET F
!| DEPTH          |-->| PROFONDEUR
!| DT             |-->| TEMPS
!| DUX,DUY        |-->| GRADIENT DU COURANT SELON X SELON X,Y
!| DVX,DVY        |-->| GRADIENT DU COURANT SELON Y SELON X,Y
!| DZHDT          |---| 
!| DZX            |-->| GRADIENT DE FOND SELON X
!| DZY            |-->| GRADIENT DE FOND SELON Y
!| ELT            |<->| NUMEROS DES ELEMENTS 2D CHOISIS POUR CHAQUE
!|                |   | NOEUD.
!| ETA            |<->| NUMEROS DES ETAGES CHOISIS POUR CHAQUE NOEUD.
!| ETAP1          |<->| TABLEAU DE TRAVAIL DONNANT LE NUMERO DE
!|                |   | L'ETAGE SUPERIEUR
!| FRE            |<->| NUMEROS DES FREQ. CHOISIES POUR CHAQUE NOEUD.
!| FREQ           |-->| FREQUENCES DISCRETISEES
!| IFABOR         |-->| NUMEROS 2D DES ELEMENTS AYANT UNE FACE COMMUNE
!|                |   | AVEC L'ELEMENT .  SI IFABOR
!|                |   | ON A UNE FACE LIQUIDE,SOLIDE,OU PERIODIQUE
!| IKLE2          |-->| TRANSITION ENTRE LES NUMEROTATIONS LOCALE
!|                |   | ET GLOBALE DU MAILLAGE 2D.
!| ITR01          |<->| TABLEAU DE TRAVAIL ENTIER
!| MESH           |---| 
!| NELEM2         |-->| NOMBRE D ELEMENTS DU MAILLAGE 2D
!| NF             |-->| NOMBRE DE FREQUENCES
!| NPLAN          |-->| NOMBRE DE PLANS OU DE DIRECTIONS
!| NPOIN2         |-->| NOMBRE DE POINTS DU MAILLAGE 2D
!| NPOIN3         |-->| NOMBRE DE POINTS DU MAILLAGE 3D
!| NRK            |-->| NOMBRE DE SOUS PAS DE RUNGE KUTTA
!| PROINF         |-->| LOGIQUE INDIQUANT SI ON EST EN PROF INFINIE
!| PROMIN         |---| 
!| SHF            |<->| COORDONNEES BARYCENTRIQUES SUIVANT F DES
!|                |   | NOEUDS DANS LEURS FREQUENCES "FRE" ASSOCIEES.
!| SHP1           |---| COORDONNEES BARYCENTRIQUES 2D AU PIED DES
!|                |   | COURBES CARACTERISTIQUES.
!| SHP2           |---| 
!| SHP3           |---| 
!| SHZ            |---| 
!| SINTET         |-->| SINUS TETA
!| SPHE           |-->| LOGIQUE INDIQUANT SI ON EST EN COORD. SPHER.
!| SURDET         |-->| INVERSE DU DETERMINANT DES ELEMENTS
!| TETA           |-->| DIRECTIONS DISCRETISEES
!| TGF            |-->| TANGENTES DES LATITUDES DES POINTS 2D
!| TRA01          |<->| TABLEAU DE TRAVAIL
!| U,V            |-->| COURANT SELON X,Y
!| X,Y            |-->| COORDONNEES DES POINTS DU MAILLAGE
!| XK             |-->| NOMBRE D'ONDE DISCRETISE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
!BD_INCKA MODIFICATION FOR PARALLEL MODE
      USE TOMAWAC_MPI_TOOLS
      USE TOMAWAC_MPI
      USE INTERFACE_TOMAWAC, EX_PREPRO => PREPRO
!BD_INCKA END OF MODIFICATION
!
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
      INTEGER NRK,NPOIN3,NPOIN2,NELEM2,NPLAN,NF
!
      DOUBLE PRECISION CX(NPOIN3,NF) , CY(NPOIN3,NF)
      DOUBLE PRECISION CT(NPOIN3,NF) , CF(NPOIN3,NF)
      DOUBLE PRECISION SHP1(NPOIN3,NF) , SHP2(NPOIN3,NF)
      DOUBLE PRECISION SHP3(NPOIN3,NF) , SHZ(NPOIN3,NF)
      DOUBLE PRECISION SHF(NPOIN3,NF)  , DZHDT(NPOIN2)
      DOUBLE PRECISION X(NPOIN2),Y(NPOIN2)
      DOUBLE PRECISION XK(NPOIN2,NF),CG(NPOIN2,NF)
      DOUBLE PRECISION TETA(NPLAN),FREQ(NF)
      DOUBLE PRECISION SINTET(NPLAN),COSTET(NPLAN)
      DOUBLE PRECISION COSF(NPOIN2),TGF(NPOIN2)
      DOUBLE PRECISION DEPTH(NPOIN2),DZX(NPOIN2),DZY(NPOIN2)
      DOUBLE PRECISION U(NPOIN2),DUX(NPOIN2),DUY(NPOIN2)
      DOUBLE PRECISION V(NPOIN2),DVX(NPOIN2),DVY(NPOIN2)
      DOUBLE PRECISION SURDET(NELEM2)
      DOUBLE PRECISION DT,TRA01(NPOIN3,8),PROMIN
      INTEGER ELT(NPOIN3,NF),ETA(NPOIN3,NF),FRE(NPOIN3,NF)
      INTEGER IKLE2(NELEM2,3),IFABOR(NELEM2,7),ETAP1(NPLAN)
      INTEGER ITR01(NPOIN3,3)
      LOGICAL COURAN,SPHE,PROINF
!      REAL WW(1)
!
      INTEGER JF,I,ISTAT,IEL,I1,I2,I3,I4
      CHARACTER*3 CAR
!BD_INCKA MODIFICATION FOR PARALLEL MODE
      INTEGER          LAST_NOMB,NLOSTAGAIN,NUMBER,IER,NRECV,NUMBERLOST
      INTEGER          ITE,IP,IPLAN,NBB,IPOIN!,GOODELT(NPOIN2,NPLAN,NF)
      INTEGER          NARRSUM,IFF
!      INTEGER P_ISUM,P_IMAX
!      EXTERNAL P_ISUM,P_IMAX
!      DOUBLE PRECISION :: TEST2(NPOIN3,NF)
      DOUBLE PRECISION :: TES(NPOIN2,NPLAN)
      INTEGER,DIMENSION(:,:,:), ALLOCATABLE :: GOODELT
      TYPE(BIEF_MESH)  ::  MESH
!BD_INCKA END OF MODIFICATION
!
!----------------------------------------------------------------------
!
      NFREQ=NF
      ALLOCATE(GOODELT(NPOIN2,NPLAN,NF))
      IF (.NOT.COURAN) THEN
!
!   -------------------------------------------------------------------
!
!   RELATIVE = ABSOLUTE => ADVECTION IN 3D
!   SEPARATES OUT THE FREQUENCIES
!
        DO 200 JF=1,NF
!
        IF (NCSIZE.LE.1) THEN
!
!      ---------------------------------------------------------------
!
!      COMPUTES THE ADVECTION FIELD
!
         CALL CONWAC
     &( CY    , CX    , CT    , XK    , CG    , COSF  , TGF   , DEPTH ,
     &  DZY   , DZX   , FREQ  , COSTET, SINTET, NPOIN2, NPLAN , JF    ,
     &  NF    , PROINF, SPHE  , PROMIN, TRA01 , TRA01(1,2)    )
!
!      ----------------------------------------------------------------
!
!      DETERMINES THE FOOT OF THE CHARACTERISTICS
!
!
          CALL INIPIE
     &( CX,CY,CT,X,Y,SHP1(1,JF),SHP2(1,JF),SHP3(1,JF),SHZ(1,JF),
     &  ELT(1,JF),ETA(1,JF),
     &  TRA01,TRA01(1,2),TRA01(1,3),TETA,IKLE2,NPOIN2,NELEM2,NPLAN,
     &  ITR01,ITR01,ITR01,NELEM2,NPOIN2,IFABOR,GOODELT(1,1,JF))
!
      DO IEL=1,NELEM2
        I1=IKLE2(IEL,1)
        I2=IKLE2(IEL,2)
        I3=IKLE2(IEL,3)
        IF ((DEPTH(I1).LT.PROMIN).AND.(DEPTH(I2).LT.PROMIN).AND.
     &      (IFABOR(IEL,1).GT.0)) IFABOR(IEL,1)=-1
        IF ((DEPTH(I2).LT.PROMIN).AND.(DEPTH(I3).LT.PROMIN).AND.
     &      (IFABOR(IEL,2).GT.0)) IFABOR(IEL,2)=-1
        IF ((DEPTH(I3).LT.PROMIN).AND.(DEPTH(I1).LT.PROMIN).AND.
     &      (IFABOR(IEL,3).GT.0)) IFABOR(IEL,3)=-1
      ENDDO
!
          CALL PIEDS
     &(CX,CY,CT,DT,NRK,X,Y,TETA,IKLE2,IFABOR,ETAP1,TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),SHP1(1,JF),
     &  SHP2(1,JF),SHP3(1,JF),SHZ(1,JF),ELT(1,JF),ETA(1,JF),
     &  ITR01(1,1),NPOIN3,NPOIN2,
     &  NELEM2,NPLAN,JF,SURDET,-1,ITR01(1,2))
!
       ELSE
!
!     READS "NEEDS FOR IP"
!
!BD_INCKA MODIFICATION FOR PARALLEL MODE
         CALL CONWAC
     &( CY , CX , CT , XK , CG , COSF,TGF , DEPTH ,
     &  DZY   , DZX   , FREQ  , COSTET, SINTET, NPOIN2, NPLAN , JF    ,
     &  NF    , PROINF, SPHE  , PROMIN, TRA01 , TRA01(1,2)    )

          CALL INIPIE
     &( CX,CY,CT,X,Y,SHP1(1,JF),SHP2(1,JF),
     &  SHP3(1,JF),SHZ(1,JF),
     &  ELT(1,JF),ETA(1,JF),
     &  TRA01,TRA01(1,2),TRA01(1,3),TETA,IKLE2,NPOIN2,NELEM2,NPLAN,
     &  ITR01,ITR01,ITR01,NELEM2,NPOIN2,IFABOR,GOODELT(1,1,JF))
         IF (JF==1) THEN
           IF (ALLOCATED(SH_LOC)) THEN
               DO IFF=1,NF
             DEALLOCATE(SH_LOC(IFF)%SHP1,SH_LOC(IFF)%SHP2,
     &                  SH_LOC(IFF)%SHP3,SH_LOC(IFF)%SHZ,
     &                  SH_LOC(IFF)%SHF,SH_LOC(IFF)%ELT,
     &                  SH_LOC(IFF)%ETA,SH_LOC(IFF)%FRE)
               ENDDO
             DEALLOCATE(SH_LOC)
           ENDIF
           LAST_NOMB = 1
         ENDIF
      DO IEL=1,NELEM2
        I1=IKLE2(IEL,1)
        I2=IKLE2(IEL,2)
        I3=IKLE2(IEL,3)
        IF ((DEPTH(I1).LT.PROMIN).AND.(DEPTH(I2).LT.PROMIN).AND.
     &      (IFABOR(IEL,1).GT.0)) IFABOR(IEL,1)=-1
        IF ((DEPTH(I2).LT.PROMIN).AND.(DEPTH(I3).LT.PROMIN).AND.
     &      (IFABOR(IEL,2).GT.0)) IFABOR(IEL,2)=-1
        IF ((DEPTH(I3).LT.PROMIN).AND.(DEPTH(I1).LT.PROMIN).AND.
     &      (IFABOR(IEL,3).GT.0)) IFABOR(IEL,3)=-1
        IF ((DEPTH(I1).LT.PROMIN).AND.(DEPTH(I2).LT.PROMIN).AND.
     &      (IFABOR(IEL,1).EQ.-2)) IFABOR(IEL,1)=-1
        IF ((DEPTH(I2).LT.PROMIN).AND.(DEPTH(I3).LT.PROMIN).AND.
     &      (IFABOR(IEL,2).EQ.-2)) IFABOR(IEL,2)=-1
        IF ((DEPTH(I3).LT.PROMIN).AND.(DEPTH(I1).LT.PROMIN).AND.
     &      (IFABOR(IEL,3).EQ.-2)) IFABOR(IEL,3)=-1
      ENDDO

         CALL CORRECT_GOODELT(GOODELT(1,1,JF),NPOIN2,NPLAN,MESH)
!
         IF (.NOT.ALLOCATED(NCHARA)) ALLOCATE(NCHARA(NF),NLOSTCHAR(NF),
     &                                        NSEND(NF))
         CALL INIT_TOMAWAC(NCHARA(JF),NCHDIM,1,
     &                                       NPOIN3,LAST_NOMB)
!
         IF(.NOT.ALLOCATED(TEST)) ALLOCATE(TEST(NPOIN3,NF))
         IFREQ=JF
           CALL PIEDS_TOMAWAC
     &(CX,CY,CT,DT,NRK,X,Y,TETA,IKLE2,IFABOR,
     &  ETAP1,TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),SHP1(1,JF),
     &  SHP2(1,JF),SHP3(1,JF),SHZ(1,JF),ELT(1,JF),ETA(1,JF),
     &  ITR01(1,1),NPOIN3,NPOIN2,
     &  NELEM2,NPLAN,JF,SURDET,-1,ITR01(1,2),MESH%IFAPAR%I,TEST(1,JF),
     &  NCHDIM,NCHARA(JF),MESH,GOODELT(1,1,JF))
! CHECKS WHETHER A CHARACTERISTICS CLOSE TO THE BOUNDARY EXITS AND NOT
! THE OTHER ONE. IN THIS CASE ONLY THE MAXIMUM CONTRIBUTION (FROM BOTH)
! IS CONSIDERED AND THE EXIT CHARACTERISTICS IS NOT TREATED
          DO IP = 1,NPOIN2
              DO IPLAN = 1,NPLAN
                 TES(IP,IPLAN)  =TEST(IP+NPOIN2*(IPLAN-1),JF)
              ENDDO
          ENDDO
         WHERE (TEST(:,JF).LT.0.5D0)
             SHP1(:,JF)=0.D0
             SHP2(:,JF)=0.D0
             SHP3(:,JF)=0.D0
             SHZ(:,JF) = 0.D0
         END WHERE
          DO IPLAN = 1,NPLAN
          CALL PARCOM2
     & ( TES(1,IPLAN) ,
     &   TES(1,IPLAN) ,
     &   TES(1,IPLAN) ,
     &   NPOIN2 , 1 , 2 , 1 , MESH )
          ENDDO
          DO IP = 1,NPOIN2
             DO IPLAN = 1,NPLAN
                TEST(IP+NPOIN2*(IPLAN-1),JF)=TES(IP,IPLAN)
             ENDDO
          ENDDO
!          WHERE (TEST(:,JF).GT.1.5D0)
!             SHP1(:,JF)=SHP1(:,JF)/TEST(:,JF)
!             SHP2(:,JF)=SHP2(:,JF)/TEST(:,JF)
!             SHP3(:,JF)=SHP3(:,JF)/TEST(:,JF)
!          END WHERE
! HEAPCHAR(NCHARA,NFREQ) AND HEAPCOUNT(NCSIZE,NFREQ)
! HEAPCOUNT=> NUMBER OF CHARACTERISTICS ON EACH PROCESSOR
         CALL WIPE_HEAPED_CHAR(TEST(1,JF),NPOIN3,.TRUE.,NSEND(JF),
     &                        NLOSTCHAR(JF),NCHDIM,
     &                        NCHARA(JF))
! IS NOT NECESSARILY USEFUL, CHECKS IF TEST==1, IN WHICH CASE IT IS DELETED
! FROM THE LIST OF CHARACTERISTICS BY ASSIGNING HEAPCAHR%NEPID==-1
!        DO WHILE(P_IMAX(NLOSTCHAR(JF))>0)! THERE ARE -REALLY- LOST TRACEBACKS SOMEWHERE
          CALL PREP_INITIAL_SEND(NSEND,NLOSTCHAR,NCHARA)
! CREATES THE ARRAY 'SDISP' AND ORDERS THE DATA (ASCENDING)
          CALL GLOB_CHAR_COMM ()
! SENDS SENDCHAR AND WRITES TO RECVCHAR

!
         IF(.NOT.ALLOCATED(ISPDONE)) ALLOCATE(ISPDONE(NPOIN3,NF))
         IF(.NOT.ALLOCATED(NARRV)) ALLOCATE(NARRV(NF))
         CALL ALLOC_LOCAL(NARRV(IFREQ),IFREQ,NF,NLOSTAGAIN,
     &                      NUMBERLOST,NARRSUM)
         IF (NUMBERLOST>0) THEN
       CALL PIEDS_TOMAWAC_MPI
     &(CX,CY,CT,DT,NRK,X,Y,TETA,IKLE2,IFABOR,ETAP1,
     &  TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),SH_LOC(JF)%SHP1,
     &  SH_LOC(JF)%SHP2,SH_LOC(JF)%SHP3,SH_LOC(JF)%SHZ,
     &  SH_LOC(JF)%ELT,SH_LOC(JF)%ETA,
     &  NARRV(JF),NPOIN2,
     &  NELEM2,NPLAN,JF,SURDET,-1,MESH%IFAPAR%I,
     &  2,NCHARA(JF),RECVCHAR(1,JF))
        CALL ALLOC_AGAIN(NARRV(IFREQ),IFREQ,NLOSTAGAIN,NUMBERLOST,
     &                   NUMBER)
        CALL ORGANIZE_SENDAGAIN()
        CALL SUPP_ENVOI_AGAIN(IFREQ,NUMBER)
!
           ITE = 0
          DO WHILE((NUMBERLOST>0).AND.(ITE.LE.20))
           ITE= ITE + 1
          CALL ORGANIZE_SENDAGAIN()
          CALL ENVOI_AGAIN(NRECV)
          CALL PIEDS_TOMAWAC_MPI
     &(CX,CY,CT,DT,NRK,X,Y,TETA,IKLE2,IFABOR,
     &  ETAP1,TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),SH_AGAIN%SHP1,
     &  SH_AGAIN%SHP2,SH_AGAIN%SHP3,SH_AGAIN%SHZ,
     &  SH_AGAIN%ELT,SH_AGAIN%ETA,
     &  NRECV,NPOIN2,
     &  NELEM2,NPLAN,JF,SURDET,-1,MESH%IFAPAR%I,
     &  2,NCHARA(JF),RECVAGAIN)
        CALL INCREM_ENVOI_RECV(IFREQ,NUMBER,NLOSTAGAIN,NUMBERLOST,
     &                         NRECV)
        ENDDO ! END OF THE DOWHILE LOOP
         CALL FINAL_ORGA_RECV(NARRV(IFREQ),IFREQ)
          ELSE
           CALL RESET_COUNT(IFREQ)
          ENDIF
!
       ENDIF
!
200   CONTINUE
!
      ELSE
!
!   ---------------------------------------------------------------
!
!   IN A RELATIVE REFERENCE SYSTEM => ADVECTION IN 4D
!   IT IS NO LONGER POSSIBLE TO SEPARATE THE FREQUENCIES OUT
!$
!       IF (IPID.GT.1) THEN
!        IF(LNG.EQ.1) THEN
!         WRITE(LU,*) 'PREPRO : PAS D EXECUTION EN PARALLELE AVEC COURANT'
!        ELSE
!         WRITE(LU,*) 'PREPRO : NO PARALLELISM WITH CURRENT'
!        ENDIF
!       STOP
!       ENDIF
!
      DO JF=1,NF
         CALL CONW4D
     &(CY,CX,CT,CF,V,U,XK,CG,COSF,TGF,DEPTH,DZHDT,DZY,DZX,DVY,DVX,
     & DUY,DUX,FREQ,COSTET,SINTET,NPOIN2,NPLAN,JF,NF,PROINF,SPHE,
     & COURAN,TRA01,TRA01(1,2))
      ENDDO
!
       IF (NCSIZE.LE.1) THEN
        DO JF=1,NF
       CALL INIP4D
     &(CX(1,JF),CY(1,JF),CT(1,JF),CF(1,JF),X,Y,
     & SHP1(1,JF),SHP2(1,JF),SHP3(1,JF),
     & SHZ(1,JF),SHF(1,JF),ELT(1,JF),ETA(1,JF),FRE(1,JF),
     & TRA01,TRA01(1,2),TRA01(1,3),TRA01(1,4),TETA,FREQ,IKLE2,
     & NPOIN2,NELEM2,NPLAN,JF,NF,IFABOR,GOODELT(1,1,JF))
!
         WRITE(LU,*) 'FREQUENCE :',JF
         CALL PIED4D
     &(CX,CY,CT,CF,DT,NRK,X,Y,TETA,FREQ,IKLE2,IFABOR,ETAP1,
     & TRA01,TRA01(1,2),TRA01(1,3),TRA01(1,4),TRA01(1,5),
     & TRA01(1,6),TRA01(1,7),TRA01(1,8),SHP1(1,JF),
     & SHP2(1,JF),SHP3(1,JF),SHZ(1,JF),SHF(1,JF),
     & ELT(1,JF),ETA(1,JF),FRE(1,JF),ITR01(1,1),NPOIN3,NPOIN2,
     & NELEM2,NPLAN,NF,SURDET,-1,ITR01(1,2))
        ENDDO
!
       ELSE
         DO JF=1,NF
       CALL INIP4D
     &(CX(1,JF),CY(1,JF),CT(1,JF),CF(1,JF),X,Y,
     & SHP1(1,JF),SHP2(1,JF),SHP3(1,JF),
     & SHZ(1,JF),SHF(1,JF),ELT(1,JF),ETA(1,JF),FRE(1,JF),
     & TRA01,TRA01(1,2),TRA01(1,3),TRA01(1,4),TETA,FREQ,IKLE2,
     & NPOIN2,NELEM2,NPLAN,JF,NF,IFABOR,GOODELT(1,1,JF))
         WRITE(LU,*) 'FREQUENCE :',JF
         IF (JF==1) THEN
           IF (ALLOCATED(SH_LOC_4D)) THEN
               DO IFF=1,NF
             DEALLOCATE(SH_LOC_4D(IFF)%SHP1,SH_LOC_4D(IFF)%SHP2,
     &                  SH_LOC_4D(IFF)%SHP3,SH_LOC_4D(IFF)%SHZ,
     &                  SH_LOC_4D(IFF)%SHF,SH_LOC_4D(IFF)%ELT,
     &                  SH_LOC_4D(IFF)%ETA,SH_LOC_4D(IFF)%FRE)
               ENDDO
             DEALLOCATE(SH_LOC_4D)
           ENDIF
           LAST_NOMB = 1
         ENDIF

         CALL CORRECT_GOODELT(GOODELT(1,1,JF),NPOIN2,NPLAN,MESH)
!
         IF (.NOT.ALLOCATED(NCHARA)) ALLOCATE(NCHARA(NF),NLOSTCHAR(NF),
     &                                        NSEND(NF))
         CALL INIT_TOMAWAC_4D(NCHARA(JF),NCHDIM,1,
     &                                       NPOIN3,LAST_NOMB)
!
         IF(.NOT.ALLOCATED(TEST)) ALLOCATE(TEST(NPOIN3,NF))
         IFREQ=JF

           CALL PIED4D_TOMAWAC
     &(CX,CY,CT,CF,DT,NRK,X,Y,TETA,FREQ,IKLE2,IFABOR,
     &  ETAP1,TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),
     &  TRA01(1,7),TRA01(1,8),SHP1(1,JF),SHP2(1,JF),SHP3(1,JF),
     &  SHZ(1,JF),SHF(1,JF),ELT(1,JF),ETA(1,JF),FRE(1,JF),
     &  ITR01(1,1),NPOIN3,NPOIN2,
     &  NELEM2,NPLAN,NF,SURDET,-1,ITR01(1,2),MESH%IFAPAR%I,TEST(1,JF),
     &  NCHDIM,NCHARA(JF),MESH,GOODELT(1,1,JF),JF)
! CHECKS WHETHER A CHARACTERISTICS CLOSE TO THE BOUNDARY EXITS AND NOT
! THE OTHER ONE. IN THIS CASE ONLY THE MAXIMUM CONTRIBUTION (FROM BOTH)
! IS CONSIDERED AND THE EXIT CHARACTERISTICS IS NOT TREATED
          DO IP = 1,NPOIN2
             DO IPLAN = 1,NPLAN
                TES(IP,IPLAN)  =TEST(IP+NPOIN2*(IPLAN-1),JF)
             ENDDO
          ENDDO
         WHERE (TEST(:,JF).LT.0.5D0)
             SHP1(:,JF)=0.D0
             SHP2(:,JF)=0.D0
             SHP3(:,JF)=0.D0
             SHZ(:,JF) = 0.D0
             SHF(:,JF) = 0.D0
         END WHERE
          DO IPLAN = 1,NPLAN
          CALL PARCOM2
     & ( TES(1,IPLAN) ,
     &   TES(1,IPLAN) ,
     &   TES(1,IPLAN) ,
     &   NPOIN2 , 1 , 2 , 1 , MESH )
          ENDDO
          DO IP = 1,NPOIN2
             DO IPLAN = 1,NPLAN
                TEST(IP+NPOIN2*(IPLAN-1),JF)=TES(IP,IPLAN)
             ENDDO
          ENDDO
!          WHERE (TEST(:,JF).GT.1.5D0)
!             SHP1(:,JF)=SHP1(:,JF)/TEST(:,JF)
!             SHP2(:,JF)=SHP2(:,JF)/TEST(:,JF)
!             SHP3(:,JF)=SHP3(:,JF)/TEST(:,JF)
!          END WHERE
! HEAPCHAR(NCHARA,NFREQ) AND HEAPCOUNT(NCSIZE,NFREQ)
! HEAPCOUNT=> NUMBER OF CHARACTERISTICS ON EACH PROCESSOR
         CALL WIPE_HEAPED_CHAR_4D(TEST(1,JF),NPOIN3,.TRUE.,NSEND(JF),
     &                        NLOSTCHAR(JF),NCHDIM,
     &                        NCHARA(JF))
! IS NOT NECESSARILY USEFUL, CHECKS IF TEST==1, IN WHICH CASE IT IS DELETED
! FROM THE LIST OF CHARACTERISTICS BY ASSIGNING HEAPCAHR%NEPID==-1
!        DO WHILE(P_IMAX(NLOSTCHAR(JF))>0)! THERE ARE -REALLY- LOST TRACEBACKS SOMEWHERE
          CALL PREP_INITIAL_SEND_4D(NSEND,NLOSTCHAR,NCHARA)
! CREATES THE ARRAY 'SDISP' AND ORDERS THE DATA (ASCENDING)
          CALL GLOB_CHAR_COMM_4D ()
! SENDS SENDCHAR AND WRITES TO RECVCHAR
!
         IF(.NOT.ALLOCATED(ISPDONE)) ALLOCATE(ISPDONE(NPOIN3,NF))
         IF(.NOT.ALLOCATED(NARRV)) ALLOCATE(NARRV(NF))
         CALL ALLOC_LOCAL_4D(NARRV(IFREQ),IFREQ,NF,NLOSTAGAIN,
     &                      NUMBERLOST,NARRSUM)

         IF (NUMBERLOST>0) THEN
       CALL PIEDS4D_TOMAWAC_MPI
     &(CX,CY,CT,CF,DT,NRK,X,Y,TETA,FREQ,IKLE2,IFABOR,ETAP1,
     &  TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),TRA01(1,7),
     &  TRA01(1,8),SH_LOC_4D(JF)%SHP1,SH_LOC_4D(JF)%SHP2,
     &  SH_LOC_4D(JF)%SHP3,SH_LOC_4D(JF)%SHZ,SH_LOC_4D(JF)%SHF,
     &  SH_LOC_4D(JF)%ELT,SH_LOC_4D(JF)%ETA,SH_LOC_4D(JF)%FRE,
     &  NARRV(JF),NPOIN2,
     &  NELEM2,NPLAN,NF,JF,SURDET,-1,MESH%IFAPAR%I,
     &  2,NCHARA(JF),RECVCHAR_4D(1,JF))
        CALL ALLOC_AGAIN_4D(NARRV(IFREQ),IFREQ,NLOSTAGAIN,NUMBERLOST,
     &                   NUMBER)
        CALL ORGANIZE_SENDAGAIN_4D()
        CALL SUPP_ENVOI_AGAIN_4D(IFREQ,NUMBER)
!
        ITE = 0
        DO WHILE((NUMBERLOST>0).AND.(ITE.LE.20))
          ITE= ITE + 1
          CALL ORGANIZE_SENDAGAIN_4D()
          CALL ENVOI_AGAIN_4D(NRECV)
          CALL PIEDS4D_TOMAWAC_MPI
     &(CX,CY,CT,CF,DT,NRK,X,Y,TETA,FREQ,IKLE2,IFABOR,
     &  ETAP1,TRA01,TRA01(1,2),
     &  TRA01(1,3),TRA01(1,4),TRA01(1,5),TRA01(1,6),TRA01(1,7),
     &  TRA01(1,8),SH_AGAIN_4D%SHP1,SH_AGAIN_4D%SHP2,SH_AGAIN_4D%SHP3,
     &  SH_AGAIN_4D%SHZ,SH_AGAIN_4D%SHF,
     &  SH_AGAIN_4D%ELT,SH_AGAIN_4D%ETA,SH_AGAIN_4D%FRE,
     &  NRECV,NPOIN2,
     &  NELEM2,NPLAN,NF,JF,SURDET,-1,MESH%IFAPAR%I,
     &  2,NCHARA(JF),RECVAGAIN_4D)
         CALL INCREM_ENVOI_RECV_4D(IFREQ,NUMBER,NLOSTAGAIN,NUMBERLOST,
     &                         NRECV)
        ENDDO ! END OF THE DOWHILE LOOP
        CALL FINAL_ORGA_RECV_4D(NARRV(IFREQ),IFREQ)
!
          ELSE
           CALL RESET_COUNT(IFREQ)
          ENDIF
!
         ENDDO
       ENDIF
      ENDIF
!
      DEALLOCATE(GOODELT)
!
!----------------------------------------------------------------------
!
      RETURN
      END