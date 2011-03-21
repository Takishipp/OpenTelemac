!                    *********************
                     SUBROUTINE CVTRVF_POS
!                    *********************
!
     &(F,FN,FSCEXP,DIFT,CONV,H,HN,HPROP,UDEL,VDEL,DM1,ZCONV,SOLSYS,
     & VISC,VISC_S,SM,SMH,YASMH,SMI,YASMI,FBOR,MASKTR,MESH,
     & T1,T2,T3,T4,T5,T6,T7,T8,HNT,HT,AGGLOH,TE1,DT,ENTET,BILAN,
     & OPDTRA,MSK,MASKEL,S,MASSOU,OPTSOU,LIMTRA,KDIR,KDDL,NPTFR,FLBOR,
     & YAFLBOR,V2DPAR,UNSV2D,IOPT,FLBORTRA,MASKPT,GLOSEG1,GLOSEG2,NBOR,
     & OPTION,FLULIM,YAFLULIM)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    FINITE VOLUMES, UPWIND, EXPLICIT AND MONOTONIC
!+                ADVECTOR EVEN WITH TIDAL FLATS.
!
!warning  AFBOR AND BFBOR MUST BE 0 FOR THE BOUNDARY ELEMENTS
!+            WITH NO FRICTION
!warning  DISCRETISATION OF VISC
!
!history  J-M HERVOUET   (LNHE)
!+        19/11/2010
!+        V6P0
!+   OPTIMIZATION (2 ABS SUPPRESSED)
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
!| AGGLOH         |-->| MASS-LUMPING UTILISE DANS L'EQUATION DE CONTINUITE
!| BILAN          |-->| LOGIQUE INDIQUANT SI ON DOIT FAIRE UN BILAN
!|                |   | DE MASSE. DANS CE CAS IL FAUT RETOURNER LA
!|                |   | VALEUR DE L'APPORT DES TERMES SOURCES.
!| CONV           |-->| LOGIQUE INDIQUANT S'IL Y A CONVECTION DE F
!| DIFT           |-->| LOGIQUE INDIQUANT S'IL Y A DIFFUSION DE F
!| DM1            |---|
!| DT             |-->| PAS DE TEMPS
!| ENTET          |-->| LOGIQUE INDIQUANT SI ON IMPRIME DES INFOS
!|                |   | SUR LE BILAN DE MASSE DE TRACEUR
!| F              |<--| VALEURS A L' ETAPE N+1.
!| FBOR           |-->| CONDITIONS DE DIRICHLET SUR F.
!| FLBOR          |---|
!| FLBORTRA       |---|
!| FN             |-->| VALEURS A L' ETAPE N.
!| FSCEXP         |-->| PARTIE EXPLICITE DU TERME SOURCE
!|                |   | EGALE A ZERO PARTOUT SAUF POUR LES POINTS
!|                |   | SOURCES OU IL Y A FSCE - (1-TETAT) FN
!|                |   | VOIR DIFSOU
!| GLOSEG1        |---|
!| GLOSEG2        |---|
!| HNT,HT         |<--| TABLEAUX DE TRAVAIL (HAUTEURS MODIFIEES POUR
!|                |   | TENIR COMPTE DU MASS-LUMPING)
!| HPROP          |-->| HAUTEUR DE PROPAGATION (FAITE DANS CVDFTR).
!| IOPT           |---| OPTIONS DE CALCUL
!|                |   | CHIFFRE DES DIZAINES (IOPT2):
!|                |   | 0 : UCONV RESPECTE L'EQUATION DE CONTINUITE
!|                |   | 1 : UCONV NE RESPECTE PAS LA CONTINUITE
!|                |   | CHIFFRE DES UNITES (IOPT1):
!|                |   | 0 : CONSTANTE PAR ELEMENT NULLE
!|                |   | 1 : CONSTANTE DE CHI-TUAN PHAM
!|                |   | 2 : CONSTANTE DE LEO POSTMA
!| KDDL           |-->| CONVENTION POUR LES DEGRES DE LIBERTE
!| KDIR           |---|
!| LIMTRA         |---|
!| MASKEL         |-->| TABLEAU DE MASQUAGE DES ELEMENTS
!|                |   | =1. : NORMAL   =0. : ELEMENT MASQUE
!| MASKPT         |---|
!| MASSOU         |-->| MASSE DE TRACEUR AJOUTEE PAR TERME SOURCE
!|                |   | VOIR DIFSOU
!| MESH           |-->| BLOC DES ENTIERS DU MAILLAGE.
!| MSK            |-->| SI OUI, PRESENCE D'ELEMENTS MASQUES.
!| NBOR           |---|
!| NPTFR          |---|
!| OPDTRA         |-->| MOT-CLE : OPTION POUR LA DIFFUSION DU TRACEUR
!| OPTION         |-->| OPTION OF ALGORITHM FOR EDGE-BASED ADVECTION
!|                |   | 1: FAST BUT SENSITIVE TO SEGMENT NUMBERING
!|                |   | 2: INDEPENDENT OF SEGMENT NUMBERING
!| OPTSOU         |-->| OPTION DE TRAITEMENT DES TERMES SOURCES.
!|                |   | 1 : NORMAL
!|                |   | 2 : DIRAC
!| S              |-->| DUMMY STRUCTURE
!| SM             |-->| SOURCE TERMS.
!| SMH            |-->| TERME SOURCE DE L'EQUATION DE CONTINUITE
!| SMI            |---|
!| SOLSYS         |---|
!| T5,T6,T7       |<->| TABLEAUX DE TRAVAIL
!| T8             |---|
!| TE1            |<->| TABLEAU DE TRAVAIL SUR LES ELEMENTS
!| UDEL           |---|
!| UNSV2D         |---|
!| V2DPAR         |---|
!| VDEL           |---|
!| VISC           |-->| COEFFICIENTS DE VISCOSITE SUIVANT X,Y ET Z .
!|                |   | SI P0 : VISCOSITE DONNEE PAR ELEMENT
!|                |   | SINON : VISCOSITE DONNEE PAR POINT
!| VISC_S         |---|
!| YAFLBOR        |---|
!| YASMH          |-->| LOGIQUE INDIQUANT DE PRENDRE EN COMPTE SMH
!| YASMI          |---|
!| ZCONV          |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_CVTRVF_POS => CVTRVF_POS
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: OPDTRA,OPTSOU,KDIR,NPTFR,SOLSYS
      INTEGER, INTENT(IN)             :: KDDL,IOPT,OPTION
      INTEGER, INTENT(IN)             :: GLOSEG1(*),GLOSEG2(*)
      INTEGER, INTENT(IN)             :: LIMTRA(NPTFR),NBOR(NPTFR)
!                                                         NSEG
      DOUBLE PRECISION, INTENT(IN)    :: DT,AGGLOH,FLULIM(*)
      DOUBLE PRECISION, INTENT(INOUT) :: MASSOU
      LOGICAL, INTENT(IN)             :: BILAN,CONV,YASMH,YAFLBOR
      LOGICAL, INTENT(IN)             :: DIFT,MSK,ENTET,YASMI,YAFLULIM
      TYPE(BIEF_OBJ), INTENT(IN)      :: MASKEL,H,HN,DM1,ZCONV,MASKPT
      TYPE(BIEF_OBJ), INTENT(IN)      :: V2DPAR,UNSV2D,HPROP
      TYPE(BIEF_OBJ), INTENT(INOUT)   :: F,SM,HNT,HT
      TYPE(BIEF_OBJ), INTENT(IN)      :: FBOR,UDEL,VDEL,FN,SMI,SMH
      TYPE(BIEF_OBJ), INTENT(INOUT)   :: TE1,FLBORTRA
      TYPE(BIEF_OBJ), INTENT(INOUT)   :: T1,T2,T3,T4,T5,T6,T7,T8
      TYPE(BIEF_OBJ), INTENT(IN)      :: FSCEXP,S,MASKTR,FLBOR
      TYPE(BIEF_OBJ), INTENT(IN)      :: VISC_S,VISC
      TYPE(BIEF_MESH)                 :: MESH
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION P_DSUM,P_DMIN,P_DMAX
      EXTERNAL         P_DSUM,P_DMIN,P_DMAX
!
      INTEGER I,IOPT1,IOPT2,NPOIN,IPTFR,I1,I2,NITER,REMAIN_SEG,NEWREMAIN
      INTEGER IR
!
!-----------------------------------------------------------------------
!
      DOUBLE PRECISION C,CPREV,CINIT,HFL1,HFL2,TET,H1N,H2N,HSEG1,HSEG2
      CHARACTER(LEN=16) FORMUL
      DOUBLE PRECISION, POINTER, DIMENSION(:) :: FXMAT
      LOGICAL TESTING
      DATA TESTING/.FALSE./
      DOUBLE PRECISION EPS_FLUX
      DATA             EPS_FLUX/1.D-15/
!
!-----------------------------------------------------------------------
!
!     INDIC WILL BE A LIST OF SEGMENTS WITH NON ZERO FLUXES
!
      LOGICAL DEJA
      DATA DEJA/.FALSE./
      INTEGER, ALLOCATABLE          :: INDIC(:)
      SAVE
      IF(.NOT.DEJA) THEN
        ALLOCATE(INDIC(MESH%NSEG))
        DEJA=.TRUE.
      ENDIF
!
!-----------------------------------------------------------------------
!
      FXMAT=>MESH%MSEG%X%R(1:MESH%NSEG)
!
!-----------------------------------------------------------------------
!
      NPOIN=H%DIM1
!
!     EXTRACTION DES OPTIONS
!
      IOPT2=IOPT/10
      IOPT1=IOPT-10*IOPT2
!
!-----------------------------------------------------------------------
!
!     STARTING AGAIN FROM NON CORRECTED DEPTH
!
      IF(TESTING) THEN
        C=1.D99
        CINIT=1.D99
        DO I=1,NPOIN
          C    =MIN(C    ,H%R(I))
          CINIT=MIN(CINIT,HN%R(I))
        ENDDO
        IF(NCSIZE.GT.1) THEN
          C=P_DMIN(C)
          CINIT=P_DMIN(CINIT)
        ENDIF
        WRITE(LU,*) 'AVANT TRAITEMENT HAUTEURS NEGATIVES, H MIN=',C
        WRITE(LU,*) 'AVANT TRAITEMENT HAUTEURS NEGATIVES, HN MIN=',CINIT
      ENDIF
!
!     CALCUL DES FLUX PAR NOEUDS
!
      FORMUL='HUGRADP         '
      IF(SOLSYS.EQ.2) FORMUL(8:8)='2'
      CALL VECTOR(T1,'=',FORMUL,H%ELM,-1.D0,
     &            HPROP,DM1,ZCONV,UDEL,VDEL,VDEL,MESH,MSK,MASKEL)
!                 T1 AS HUGRADP IS NOT USED AS AN ASSEMBLED VECTOR
!                 BUT TO GET THE NON ASSEMBLED FORM MESH%W
!     CALCUL DES FLUX PAR SEGMENT (TE1 SUIVI DE FALSE NON UTILISE)
!     FXMAT IS NOT ASSEMBLED IN //
!
!----------------------------------------
! DIFFERENT OPTIONS TO COMPUTE THE FLUXES
!----------------------------------------
!
      CALL FLUX_EF_VF(FXMAT,MESH%W%R,MESH%NSEG,MESH%NELEM,
     &                MESH%ELTSEG%I,MESH%ORISEG%I,
     &                MESH%IKLE%I,.TRUE.,IOPT1)
!
!----------------------------------------
!
!     AVERAGING FLUXES ON INTERFACE SEGMENTS BY ASSEMBLING AND
!     DIVIDING BY 2. THIS WILL GIVE THE UPWINDING INFORMATION
!
      IF(NCSIZE.GT.1) THEN
        CALL PARCOM2_SEG(FXMAT,FXMAT,FXMAT,MESH%NSEG,1,2,1,MESH,
     &                   1)
        CALL MULT_INTERFACE_SEG(FXMAT,MESH%NH_COM_SEG%I,
     &                          MESH%NH_COM_SEG%DIM1,
     &                          MESH%NB_NEIGHB_SEG,
     &                          MESH%NB_NEIGHB_PT_SEG%I,
     &                          0.5D0,MESH%NSEG)
      ENDIF
!
!----------------------------------------
! END OF THE OPTIONS
!----------------------------------------
!
      CALL CPSTVC(H,T2)
!
!     INITIALIZING F AT THE OLD VALUE
!
      CALL OS('X=Y     ',X=F,Y=FN)
!
      CPREV=0.D0
      DO I=1,MESH%NSEG
        CPREV=CPREV+ABS(FXMAT(I))
      ENDDO
      IF(NCSIZE.GT.1) CPREV=P_DSUM(CPREV)
      CINIT=CPREV
      IF(TESTING) WRITE(LU,*) 'SOMME INITIALE DES FLUX=',CPREV
!
!     BOUCLE SUR LES SEGMENTS, POUR PRENDRE EN COMPTE LES FLUX
!     ADMISSIBLES
!
!     ADDING THE SOURCES (SMH IS NATURALLY ASSEMBLED IN //)
      IF(YASMH) THEN
        IF(OPTSOU.EQ.1) THEN
          DO I=1,NPOIN
            HT%R(I)=HN%R(I)+DT*SMH%R(I)
            F%R(I)=FN%R(I)+DT/MAX(HT%R(I),1.D-4)*SMH%R(I)*FSCEXP%R(I)
          ENDDO
        ELSEIF(OPTSOU.EQ.2) THEN
          DO I=1,NPOIN
            HT%R(I)=HN%R(I)+DT*SMH%R(I)*UNSV2D%R(I)
            F%R(I)=FN%R(I)+DT/MAX(HT%R(I),1.D-4)*
     &                       UNSV2D%R(I)*SMH%R(I)*FSCEXP%R(I)
          ENDDO
        ENDIF
      ELSE
        DO I=1,NPOIN
          HT%R(I)=HN%R(I)
        ENDDO
      ENDIF
!
!     BOUNDARY FLUXES : ADDING THE ENTERING (NEGATIVE) FLUXES
!     FIRST PUTTING FLBOR (BOUNDARY) IN T2 (DOMAIN)
      CALL OSDB( 'X=Y     ' ,T2,FLBOR,FLBOR,0.D0,MESH)
!     ASSEMBLING T2 (FLBOR IS NOT ASSEMBLED)
      IF(NCSIZE.GT.1) CALL PARCOM(T2,2,MESH)
      DO IPTFR=1,NPTFR
        I=NBOR(IPTFR)
        HT%R(I)=HT%R(I)-DT*UNSV2D%R(I)*MIN(T2%R(I),0.D0)
!       ENTERING FLUXES OF TRACERS
!       THE FINAL DEPTH IS TAKEN
        IF(LIMTRA(IPTFR).EQ.KDIR) THEN
          F%R(I)=FN%R(I)-DT/MAX(HT%R(I),1.D-4)*
     &       UNSV2D%R(I)*MIN(T2%R(I),0.D0)*(FBOR%R(IPTFR)-FN%R(I))
        ELSEIF(LIMTRA(IPTFR).EQ.KDDL) THEN
          IF(T2%R(I).LE.0.D0) THEN
!           FLBORTRA IS NOT ASSEMBLED
            FLBORTRA%R(IPTFR)=FLBOR%R(IPTFR)*FN%R(I)
          ENDIF
        ENDIF
      ENDDO
!
!     FOR OPTIMIZING THE LOOP ON SEGMENTS, ONLY SEGMENTS
!     WITH NON ZERO FLUXES WILL BE CONSIDERED, THIS LIST
!     WILL BE UPDATED. TO START WITH, ALL FLUXES ASSUMED NON ZERO
!
      REMAIN_SEG=MESH%NSEG
      DO I=1,REMAIN_SEG
        INDIC(I)=I
      ENDDO
!
      NITER = 0
777   CONTINUE
      NITER = NITER + 1
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!     FOR DISTRIBUTING THE DEPTHS BETWEEN SEGMENTS
!
      IF(OPTION.EQ.2) THEN
!
!       T1 : TOTAL FLUX REMOVED OF EACH POINT
!       T4 : DEPTH H SAVED
!       T6 : F SAVED
!
        CALL CPSTVC(H,T1)
        IF(NITER.EQ.1) THEN
          DO I=1,NPOIN
            T1%R(I)=0.D0
            T4%R(I)=HT%R(I)
            T6%R(I)=F%R(I)
            T5%R(I)=HT%R(I)*F%R(I)
          ENDDO
          IF(NCSIZE.GT.1) THEN
            DO IPTFR=1,NPTIR
              I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
!             AVAILABLE DEPTH IS SHARED BETWEEN PROCESSORS
              HT%R(I)=HT%R(I)*MESH%FAC%R(I)
              T5%R(I)=T5%R(I)*MESH%FAC%R(I)
            ENDDO
          ENDIF
        ELSE
!         NOT ALL THE POINTS NEED TO BE INITIALISED NOW
          DO IR=1,REMAIN_SEG
            I=INDIC(IR)
            I1=GLOSEG1(I)
            I2=GLOSEG2(I)
            T1%R(I1)=0.D0
            T1%R(I2)=0.D0
!           SAVING THE DEPTH AND TRACER
            T4%R(I1)=HT%R(I1)
            T4%R(I2)=HT%R(I2)
            T6%R(I1)=F%R(I1)
            T6%R(I2)=F%R(I2)
            T5%R(I1)=HT%R(I1)*F%R(I1)
            T5%R(I2)=HT%R(I2)*F%R(I2)
          ENDDO
!         CANCELLING INTERFACE POINTS (SOME MAY BE ISOLATED IN A SUBDOMAIN
!         AT THE TIP OF AN ACTIVE SEGMENT WHICH IS ELSEWHERE)
          IF(NCSIZE.GT.1) THEN
            DO IPTFR=1,NPTIR
              I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
              T1%R(I)=0.D0
!             SAVING THE DEPTH AND TRACER
              T4%R(I)=HT%R(I)
              T6%R(I)=F%R(I)
!             AVAILABLE DEPTH IS SHARED BETWEEN PROCESSORS
              HT%R(I)=HT%R(I)*MESH%FAC%R(I)
              T5%R(I)=T5%R(I)*MESH%FAC%R(I)
            ENDDO
          ENDIF
        ENDIF
        DO IR=1,REMAIN_SEG
          I=INDIC(IR)
          I1=GLOSEG1(I)
          I2=GLOSEG2(I)
          IF(FXMAT(I).GT.EPS_FLUX) THEN
            T1%R(I1)=T1%R(I1)+FXMAT(I)
            HT%R(I1)=0.D0
            T5%R(I1)=0.D0
          ELSEIF(FXMAT(I).LT.-EPS_FLUX) THEN
            T1%R(I2)=T1%R(I2)-FXMAT(I)
            HT%R(I2)=0.D0
            T5%R(I2)=0.D0
          ENDIF
        ENDDO
!
        IF(NCSIZE.GT.1) CALL PARCOM(T1,2,MESH)
!
!       FOR ISOLATED POINTS CONNECTED TO AN ACTIVE SEGMENT
!       THAT IS IN ANOTHER SUBDOMAIN
        IF(NCSIZE.GT.1) THEN
          DO IPTFR=1,NPTIR
            I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
            IF(T1%R(I).GT.EPS_FLUX) THEN
              HT%R(I)=0.D0
              T5%R(I)=0.D0
            ENDIF
          ENDDO
        ENDIF
!
      ELSEIF(OPTION.EQ.1) THEN
!
!       AT THIS LEVEL H THE SAME AT INTERFACE POINTS
!       THIS IS DONE EVEN FOR OPTION 2, TO ANTICIPATE THE FINAL PARCOM
        IF(NCSIZE.GT.1) THEN
          DO IPTFR=1,NPTIR
!           AVAILABLE DEPTH IS SHARED BETWEEN PROCESSORS
!           NACHB(1,IPTFR) WITH DIMENSION NACHB(NBMAXNSHARE,NPTIR)
            I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
            HT%R(I)=HT%R(I)*MESH%FAC%R(I)
          ENDDO
        ENDIF
!
      ENDIF
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
      C=0.D0
      NEWREMAIN=0
!
      IF(OPTION.EQ.1) THEN
!
      DO IR=1,REMAIN_SEG
        I=INDIC(IR)
        IF(FXMAT(I).GT.EPS_FLUX) THEN
          I1=GLOSEG1(I)
          I2=GLOSEG2(I)
          HFL1= DT*UNSV2D%R(I1)*FXMAT(I)
          HFL2=-DT*UNSV2D%R(I2)*FXMAT(I)
!         POUR TRACEURS
          H1N=HT%R(I1)
          H2N=HT%R(I2)
!         FIN POUR TRACEURS
          IF(HFL1.GT.HT%R(I1)) THEN
            TET=HT%R(I1)/HFL1
            HT%R(I1)=0.D0
            HT%R(I2)=HT%R(I2)-HFL2*TET
            FXMAT(I)=FXMAT(I)*(1.D0-TET)
            C=C+FXMAT(I)
            NEWREMAIN=NEWREMAIN+1
            INDIC(NEWREMAIN)=I
          ELSE
            HT%R(I1)=HT%R(I1)-HFL1
            HT%R(I2)=HT%R(I2)-HFL2
          ENDIF
!         TRACER (WITH TEST HT%R(I2) CANNOT BE 0.D0)
          IF(H2N.LT.HT%R(I2)) THEN
            F%R(I2)=F%R(I2)+(1.D0-H2N/HT%R(I2))*(F%R(I1)-F%R(I2))
          ENDIF
!         END TRACER
        ELSEIF(FXMAT(I).LT.-EPS_FLUX) THEN
          I1=GLOSEG1(I)
          I2=GLOSEG2(I)
          HFL1= DT*UNSV2D%R(I1)*FXMAT(I)
          HFL2=-DT*UNSV2D%R(I2)*FXMAT(I)
!         POUR TRACEURS
          H1N=HT%R(I1)
          H2N=HT%R(I2)
!         FIN POUR TRACEURS
          IF(HFL2.GT.HT%R(I2)) THEN
            TET=HT%R(I2)/HFL2
            HT%R(I1)=HT%R(I1)-HFL1*TET
            HT%R(I2)=0.D0
            FXMAT(I)=FXMAT(I)*(1.D0-TET)
            C=C-FXMAT(I)
            NEWREMAIN=NEWREMAIN+1
            INDIC(NEWREMAIN)=I
          ELSE
            HT%R(I1)=HT%R(I1)-HFL1
            HT%R(I2)=HT%R(I2)-HFL2
          ENDIF
!         TRACER (WITH TEST HT%R(I1) CANNOT BE 0.D0)
          IF(H1N.LT.HT%R(I1)) THEN
            F%R(I1)=F%R(I1)+(1.D0-H1N/HT%R(I1))*(F%R(I2)-F%R(I1))
          ENDIF
!         FIN TRACEUR
        ENDIF
      ENDDO
!
      ELSEIF(OPTION.EQ.2) THEN
!
      DO IR=1,REMAIN_SEG
        I=INDIC(IR)
        I1=GLOSEG1(I)
        I2=GLOSEG2(I)
        IF(FXMAT(I).GT.EPS_FLUX) THEN
!         SHARING ON DEMAND: FRACTION OF DEPTH TAKEN
!         T4 IS THE STORED DEPTH
          IF(T4%R(I1).GT.0.D0) THEN
            HSEG1=T4%R(I1)*FXMAT(I)/T1%R(I1)
!           END OF SHARING ON DEMAND
            HFL1= DT*UNSV2D%R(I1)*FXMAT(I)
            IF(HFL1.GT.HSEG1) THEN
              TET=HSEG1/HFL1
!             HSEG2 AND THUS HT WILL BE STRICTLY POSITIVE
              HSEG2=DT*UNSV2D%R(I2)*FXMAT(I)*TET
              HT%R(I2)=HT%R(I2)+HSEG2
!             GROUPING H*F
              T5%R(I2)=T5%R(I2)+HSEG2*T6%R(I1)
!             RECOMPUTING F (AS WEIGHTED AVERAGE)
!             THIS MAY BE DONE SEVERAL TIMES FOR THE SAME POINT
!             BUT THE LAST ONE WILL BE THE GOOD ONE
              F%R(I2)=T5%R(I2)/HT%R(I2)
              FXMAT(I)=FXMAT(I)*(1.D0-TET)
              C=C+FXMAT(I)
              NEWREMAIN=NEWREMAIN+1
              INDIC(NEWREMAIN)=I
            ELSE
              HSEG1=HSEG1-HFL1
              HSEG2=DT*UNSV2D%R(I2)*FXMAT(I)
              HT%R(I2)=HT%R(I2)+HSEG2
              T5%R(I2)=T5%R(I2)+HSEG2*T6%R(I1)
!             THE LAST ONE WILL BE THE GOOD ONE
              F%R(I2)=T5%R(I2)/HT%R(I2)
              IF(HSEG1.GT.0.D0) THEN
                HT%R(I1)=HT%R(I1)+HSEG1
                T5%R(I1)=T5%R(I1)+HSEG1*T6%R(I1)
!               THE LAST ONE WILL BE THE GOOD ONE
                F%R(I1)=T5%R(I1)/HT%R(I1)
              ENDIF
            ENDIF
          ELSE
!           NO WATER NO FLUX TRANSMITTED, NOTHING CHANGED
            C=C+FXMAT(I)
            NEWREMAIN=NEWREMAIN+1
            INDIC(NEWREMAIN)=I
          ENDIF
        ELSEIF(FXMAT(I).LT.-EPS_FLUX) THEN
!         SHARING ON DEMAND
          IF(T4%R(I2).GT.0.D0) THEN
            HSEG2=-T4%R(I2)*FXMAT(I)/T1%R(I2)
!           END OF SHARING ON DEMAND
            HFL2=-DT*UNSV2D%R(I2)*FXMAT(I)
            IF(HFL2.GT.HSEG2) THEN
              TET=HSEG2/HFL2
!             HSEG1 AND THUS HT WILL BE STRICTLY POSITIVE
              HSEG1=-DT*UNSV2D%R(I1)*FXMAT(I)*TET
              HT%R(I1)=HT%R(I1)+HSEG1
              T5%R(I1)=T5%R(I1)+HSEG1*T6%R(I2)
!             THE LAST ONE WILL BE THE GOOD ONE
              F%R(I1)=T5%R(I1)/HT%R(I1)
              FXMAT(I)=FXMAT(I)*(1.D0-TET)
              C=C-FXMAT(I)
              NEWREMAIN=NEWREMAIN+1
              INDIC(NEWREMAIN)=I
            ELSE
              HSEG1=-DT*UNSV2D%R(I1)*FXMAT(I)
              HSEG2=HSEG2-HFL2
              HT%R(I1)=HT%R(I1)+HSEG1
              T5%R(I1)=T5%R(I1)+HSEG1*T6%R(I2)
              F%R(I1)=T5%R(I1)/HT%R(I1)
              IF(HSEG2.GT.0.D0) THEN
                HT%R(I2)=HT%R(I2)+HSEG2
                T5%R(I2)=T5%R(I2)+HSEG2*T6%R(I2)
!               THE LAST ONE WILL BE THE GOOD ONE
                F%R(I2)=T5%R(I2)/HT%R(I2)
              ENDIF
            ENDIF
          ELSE
!           NO WATER NO FLUX TRANSMITTED, NOTHING CHANGED
            C=C-FXMAT(I)
            NEWREMAIN=NEWREMAIN+1
            INDIC(NEWREMAIN)=I
          ENDIF
        ENDIF
      ENDDO
!
!     ELSE
!       UNKNOWN OPTION
      ENDIF
!
      REMAIN_SEG=NEWREMAIN
!
!     MERGING DEPTHS AND F AT INTERFACE POINTS
!
      IF(NCSIZE.GT.1) THEN
        DO IPTFR=1,NPTIR
!         ARRAY WITH HT*F AT INTERFACE POINTS
          I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
          T1%R(I)=HT%R(I)*F%R(I)
        ENDDO
!       SUMMING HT*F AT INTERFACE POINTS
        CALL PARCOM(T1,2,MESH)
!       SUMMING THE NEW POSITIVE PARTIAL DEPTHS OF INTERFACE POINTS
        CALL PARCOM(HT,2,MESH)
!       AVERAGE F AT INTERFACE POINTS
        DO IPTFR=1,NPTIR
          I=MESH%NACHB%I(NBMAXNSHARE*(IPTFR-1)+1)
          IF(HT%R(I).GT.0.D0) F%R(I)=T1%R(I)/HT%R(I)
        ENDDO
      ENDIF
!
      IF(NCSIZE.GT.1) C=P_DSUM(C)
      IF(TESTING) WRITE(LU,*) 'FLUX NON PRIS EN COMPTE=',C
      IF(C.NE.CPREV.AND.ABS(C-CPREV).GT.CINIT*1.D-9
     &             .AND.C.NE.0.D0) THEN
        CPREV=C
        GO TO 777
      ENDIF
!
!     BOUNDARY FLUXES : ADDING THE EXITING (POSITIVE) FLUXES
!                       WITH A POSSIBLE LIMITATION
!
      DO IPTFR=1,NPTFR
        I=NBOR(IPTFR)
!                               T2 = // ASSEMBLED FLBOR
        HFL1=DT*UNSV2D%R(I)*MAX(T2%R(I),0.D0)
        TET=1.D0
!       NEXT LINE SHOULD NEVER HAPPEN (DONE IN POSITIVE_DEPTHS)
        IF(HFL1.GT.HT%R(I)) TET=HT%R(I)/HFL1
!       MAX IS ONLY TO PREVENT TRUNCATION ERROR
        HT%R(I)=MAX(HT%R(I)-HFL1*TET,0.D0)
!       LIMITATION OF FLBOR (MUST HAVE BEEN DONE ALREADY
!                            IN POSITIVE_DEPTHS)
!       FLBOR%R(IPTFR)=FLBOR%R(IPTFR)*TET
        IF(LIMTRA(IPTFR).EQ.KDIR) THEN
          F%R(I)=F%R(I)-HFL1*TET/MAX(HT%R(I),1.D-4)*
     &           (FBOR%R(IPTFR)-F%R(I))
          FLBORTRA%R(IPTFR)=FLBOR%R(IPTFR)*FBOR%R(IPTFR)
        ELSEIF(LIMTRA(IPTFR).EQ.KDDL) THEN
          IF(T2%R(I).GT.0.D0) THEN
            FLBORTRA%R(IPTFR)=FLBOR%R(IPTFR)*F%R(I)
          ENDIF
        ELSE
          FLBORTRA%R(IPTFR)=0.D0
        ENDIF
      ENDDO
!
      IF(TESTING) THEN
        C=0.D0
        DO I=1,NPOIN
          C=C+(HT%R(I)-H%R(I))**2
        ENDDO
!                       FAUX MAIS PAS GRAVE SI 0.
        IF(NCSIZE.GT.1) C=P_DSUM(C)
        WRITE(LU,*) 'DIFFERENCE ENTRE H ET HT =',C
!
        C=1.D99
        DO I=1,NPOIN
          C=MIN(C,F%R(I))
        ENDDO
        IF(NCSIZE.GT.1) C=P_DMIN(C)
        WRITE(LU,*) 'APRES TRAITEMENT TRACEUR MIN=',C
        C=-1.D99
        DO I=1,NPOIN
          C=MAX(C,F%R(I))
        ENDDO
        IF(NCSIZE.GT.1) C=P_DMAX(C)
        WRITE(LU,*) 'APRES TRAITEMENT TRACEUR MAX=',C
      ENDIF
!
!-----------------------------------------------------------------------
!
!     EXPLICIT SOURCE TERM
!
      DO I = 1,MESH%NPOIN
        F%R(I) = F%R(I)+DT*SM%R(I)
      ENDDO
!
!     IMPLICIT SOURCE TERM
!
      IF(YASMI) THEN
        DO I = 1,MESH%NPOIN
          F%R(I) = F%R(I)/(1.D0-DT*SMI%R(I)/MAX(H%R(I),1.D-4))
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(ENTET) THEN
        IF(LNG.EQ.1) WRITE(LU,101) NITER
        IF(LNG.EQ.2) WRITE(LU,102) NITER
      ENDIF
!
101   FORMAT(' CVTRVF_POS (SCHEMA 13 OU 14) : ',1I3,' ITERATIONS')
102   FORMAT(' CVTRVF_POS (SCHEME 13 OR 14): ',1I3,' ITERATIONS')
!
!-----------------------------------------------------------------------
!
      RETURN
      END
