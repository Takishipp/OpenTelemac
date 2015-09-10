!                    *****************
                     SUBROUTINE LIMWAC
!                    *****************
!
     &(F     , FBOR  , LIFBOR, NPTFR , NPLAN , NF    ,  TETA , FREQ  ,
     & NPOIN2, NBOR  , AT    , LT    , DDC   , LIMSPE, FPMAXL, FETCHL,
     & SIGMAL, SIGMBL, GAMMAL, FPICL , HM0L  , APHILL, TETA1L, SPRE1L,
     & TETA2L, SPRE2L, XLAMDL, X ,Y  , KENT  , KSORT , NFO1  , NBI1  ,
     & BINBI1, UV    , VV    , SPEULI, VENT  , VENSTA, GRAVIT, DEUPI ,
     & PRIVE , NPRIV , SPEC  , FRA   , DEPTH , FRABL ,BOUNDARY_COLOUR)
!
!***********************************************************************
! TOMAWAC   V6P3                                   21/06/2011
!***********************************************************************
!
!brief    BOUNDARY CONDITIONS.
!
!warning  BY DEFAULT, THE BOUNDARY CONDITIONS SPECIFIED IN THE FILE
!+            DYNAM ARE DUPLICATED ON ALL THE DIRECTIONS AND FREQUENCIES
!
!history  F. MARCOS (LNH)
!+        01/02/95
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
!history  G.MATTAROLO (EDF - LNHE)
!+        20/06/2011
!+        V6P1
!+   Translation of French names of the variables in argument
!
!history  E. GAGNAIRE-RENOU & J.-M. HERVOUET (EDF R&D, LNHE)
!+        12/03/2013
!+        V6P3
!+   A line IF(LIMSPE.EQ.0...) RETURN removed.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| APHILL         |-->| BOUNDARY PHILLIPS CONSTANT
!| AT             |-->| COMPUTATION TIME
!| BINBI1         |-->| BINARY FILE 1 BINARY
!| BOUNDARY_COLOUR|-->| COLOUR OF BOUNDARY POINT (DEFAULT: ITS RANK)
!| DDC            |-->| DATE OF COMPUTATION BEGINNING
!| DEPTH          |-->| WATER DEPTH
!| DEUPI          |-->| 2.PI
!| F              |-->| VARIANCE DENSITY DIRECTIONAL SPECTRUM
!| FBOR           |<->| SPECTRAL VARIANCE DENSITY AT THE BOUNDARIES
!| FETCHL         |-->| BOUNDARY MEAN FETCH VALUE
!| FPICL          |-->| BOUNDARY PEAK FREQUENCY
!| FPMAXL         |-->| BOUNDARY MAXIMUM PEAK FREQUENCY
!| FRA            |<--| DIRECTIONAL SPREADING FUNCTION VALUES
!| FRABL          |-->| BOUNDARY ANGULAR DISTRIBUTION FUNCTION
!| FREQ           |-->| DISCRETIZED FREQUENCIES
!| GAMMAL         |-->| BOUNDARY PEAK FACTOR
!| GRAVIT         |-->| GRAVITY ACCELERATION
!| HM0L           |-->| BOUNDARY SIGNIFICANT WAVE HEIGHT
!| KENT           |-->| B.C.: A SPECTRUM IS PRESCRIBED AT THE BOUNDARY
!| KSORT          |-->| B.C.: FREE BOUNDARY: NO ENERGY ENTERING THE DOMAIN
!| LIFBOR         |-->| TYPE OF BOUNDARY CONDITION ON F
!| LIMSPE         |-->| TYPE OF BOUNDARY DIRECTIONAL SPECTRUM
!| LT             |-->| NUMBER OF THE TIME STEP CURRENTLY SOLVED
!| NBI1           |-->| LOGICAL UNIT NUMBER OF THE USER BINARY FILE
!| NBOR           |-->| GLOBAL NUMBER OF BOUNDARY POINTS
!| NF             |-->| NUMBER OF FREQUENCIES
!| NFO1           |-->| LOGICAL UNIT NUMBER OF THE USER FORMATTED FILE
!| NPLAN          |-->| NUMBER OF DIRECTIONS
!| NPOIN2         |-->| NUMBER OF POINTS IN 2D MESH
!| NPRIV          |-->| NUMBER OF PRIVATE ARRAYS
!| NPTFR          |-->| NUMBER OF BOUNDARY POINTS
!| PRIVE          |-->| USER WORK TABLE
!| SIGMAL         |-->| BOUNDARY SPECTRUM VALUE OF SIGMA-A
!| SIGMBL         |-->| BOUNDARY SPECTRUM VALUE OF SIGMA-B
!| SPEC           |<--| VARIANCE DENSITY FREQUENCY SPECTRUM
!| SPEULI         |-->| INDICATES IF B.C. SPECTRUM IS MODIFIED BY USER
!| SPRE1L         |-->| BOUNDARY DIRECTIONAL SPREAD 1
!| SPRE2L         |-->| BOUNDARY DIRECTIONAL SPREAD 2
!| TETA           |-->| DISCRETIZED DIRECTIONS
!| TETA1L         |-->| BOUNDARY MAIN DIRECTION 1
!| TETA2L         |-->| BOUNDARY MAIN DIRECTION 2
!| UV, VV         |-->| WIND VELOCITIES AT THE MESH POINTS
!| VENSTA         |-->| INDICATES IF THE WIND IS STATIONARY
!| VENT           |-->| INDICATES IF WIND IS TAKEN INTO ACCOUNT
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| XLAMDL         |-->| BOUNDARY WEIGHTING FACTOR FOR ANGULAR
!|                |   | DISTRIBUTION FUNCTION
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE INTERFACE_TOMAWAC, EX_LIMWAC => LIMWAC
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
      INTEGER, INTENT(IN)            :: NPTFR,NPLAN,NF,NPOIN2,LT,NPRIV
      INTEGER, INTENT(IN)            :: LIMSPE,KENT,KSORT,FRABL
      INTEGER, INTENT(IN)            :: NFO1,NBI1
      INTEGER, INTENT(IN)            :: LIFBOR(NPTFR),NBOR(NPTFR)
      INTEGER, INTENT(IN)            :: BOUNDARY_COLOUR(NPTFR)
      DOUBLE PRECISION, INTENT(IN)   :: TETA(NPLAN),FREQ(NF)
      DOUBLE PRECISION, INTENT(IN)   :: X(NPOIN2),Y(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)   :: UV(NPOIN2),VV(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)   :: SPEC(NF)
      DOUBLE PRECISION, INTENT(IN)   ::PRIVE(NPOIN2,NPRIV),DEPTH(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)   :: AT,DDC,FPMAXL,FETCHL,SIGMAL
      DOUBLE PRECISION, INTENT(IN)   :: GAMMAL,FPICL, SIGMBL
      DOUBLE PRECISION, INTENT(IN)   :: HM0L  , APHILL,TETA1L,SPRE1L
      DOUBLE PRECISION, INTENT(IN)   :: SPRE2L,XLAMDL,TETA2L
      DOUBLE PRECISION, INTENT(IN)   :: GRAVIT,DEUPI
      LOGICAL,          INTENT(IN)   :: SPEULI, VENT, VENSTA
      CHARACTER(LEN=3), INTENT(IN)   :: BINBI1
      DOUBLE PRECISION, INTENT(INOUT):: F(NPOIN2,NPLAN,NF), FRA(NPLAN)
      DOUBLE PRECISION, INTENT(INOUT):: FBOR(NPTFR,NPLAN,NF)
!
      INTEGER NPB,IFF,IPLAN,IPTFR
!
!     DOUBLE PRECISION, ALLOCATABLE :: TRAV(:)
      DOUBLE PRECISION, ALLOCATABLE :: UV2D(:),VV2D(:),PROF(:)
      DOUBLE PRECISION, ALLOCATABLE :: FB_CTE(:,:)
      DOUBLE PRECISION E2FMIN
      LOGICAL FLAG
!
!GM
      INTEGER IP,IMIL(40),IDRO(40),IGAU(40)
!GM Fin
!
      SAVE NPB,UV2D,VV2D,PROF,FB_CTE
!
!***********************************************************************
!
!     MODIFIES THE TYPE OF BOUNDARY CONDITION (OPTIONAL)
!
!     CAN BE CODED BY THE USER (SPEULI=.TRUE.)
!
!     LIFBOR(IPTFR)=KENT OR KSORT
!
      FLAG=.FALSE.
      IF (VENT .AND. (LIMSPE.EQ.1 .OR. LIMSPE.EQ.2 .OR. LIMSPE.EQ.3
     & .OR. LIMSPE.EQ.5)) FLAG=.TRUE.
!
!     THE FIRST TIME, ALLOCATES MEMORY FOR THE USEFUL ARRAYS
!     ---------------------------------------------------------------
!
      IF(LT.LT.1) THEN
        NPB=1
        IF(FLAG) THEN
          ALLOCATE(UV2D(1:NPTFR),VV2D(1:NPTFR))
          NPB=NPTFR
        ENDIF
        IF(LIMSPE.EQ.7 .OR. SPEULI) THEN
          ALLOCATE(PROF(1:NPTFR))
          NPB=NPTFR
        ENDIF
        IF(NPB.EQ.1) THEN
          ALLOCATE(FB_CTE(1:NPLAN,1:NF))
        ENDIF
      ENDIF
      IF (.NOT.ALLOCATED(UV2D)) ALLOCATE(UV2D(NPTFR))
      IF (.NOT.ALLOCATED(VV2D)) ALLOCATE(VV2D(NPTFR))
      IF (.NOT.ALLOCATED(PROF)) ALLOCATE(PROF(NPTFR))
      IF (.NOT.ALLOCATED(FB_CTE)) ALLOCATE(FB_CTE(1:NPLAN,1:NF))
!
!     THE FIRST TIME (AND POSSIBLY SUBSEQUENTLY IF THE WIND IS NOT
!     STATIONARY AND IF THE BOUNDARY SPECTRUM DEPENDS ON IT),
!     COMPUTES THE BOUNDARY SPECTRUM
!
      IF(LT.LT.1 .OR. (.NOT.VENSTA.AND.FLAG) .OR. SPEULI) THEN
        IF(FLAG) THEN
          DO IPTFR=1,NPTFR
            UV2D(IPTFR)=UV(NBOR(IPTFR))
            VV2D(IPTFR)=VV(NBOR(IPTFR))
          ENDDO
        ENDIF
        IF(LIMSPE.EQ.7 .OR. SPEULI) THEN
          DO IPTFR=1,NPTFR
            PROF(IPTFR)=DEPTH(NBOR(IPTFR))
          ENDDO
        ENDIF
!
        E2FMIN = 1.D-30
!
!       WHEN NPB=1 FBOR ONLY FILLED FOR FIRST POINT
!
!       SPECTRUM ON BOUNDARIES
!
        IF(NPB.EQ.NPTFR) THEN
          CALL SPEINI
     &(   FBOR  ,SPEC  ,FRA   ,UV2D  ,VV2D  ,FREQ ,
     &    TETA  ,GRAVIT,FPMAXL,FETCHL,SIGMAL,SIGMBL,GAMMAL,FPICL,
     &    HM0L  ,APHILL,TETA1L,SPRE1L,TETA2L,SPRE2L,XLAMDL,
     &    NPB   ,NPLAN ,NF    ,LIMSPE,E2FMIN,PROF  ,FRABL )
        ELSE
          CALL SPEINI
     &(   FB_CTE,SPEC  ,FRA   ,UV2D  ,VV2D  ,FREQ ,
     &    TETA  ,GRAVIT,FPMAXL,FETCHL,SIGMAL,SIGMBL,GAMMAL,FPICL,
     &    HM0L  ,APHILL,TETA1L,SPRE1L,TETA2L,SPRE2L,XLAMDL,
     &    NPB   ,NPLAN ,NF    ,LIMSPE,E2FMIN,PROF  ,FRABL )
        ENDIF
!
!     ===========================================================
!     TO BE MODIFIED BY USER - RESU CAN BE CHANGED
!     ===========================================================
!
        IF(SPEULI) THEN
!
!        EXEMPLE DE MODIFICATION DE FRA - A MODIFIER SUIVANT VOTRE CAS
!        EXAMPLE OF MODIFICATION OF FRA - TO BE MODIFIED DEPENDING
!        ON YOUR CASE
!
!        ALLOCATE(TRAV(1:NF))
!
!        DO IFREQ=1,NF
!          IF(FREQ(IFF).LT.FPIC) THEN
!            TRAV(IFF)=0.4538D0*(FREQ(IFF)/FPIC)**(-2.03D0)
!          ELSE
!            TRAV(IFF)=0.4538D0*(FREQ(IFF)/FPIC)**(1.04D0)
!          ENDIF
!        ENDDO
!
!        DO IPLAN=1,NPLAN
!           DTETA=TETA(IPLAN)-TETA1
!           IF((TETA(IPLAN)-TETA1).GT.DEUPI/2.D0) THEN
!              DTETA=DEUPI-DTETA
!           ENDIF
!           DO IFF=1,NF
!              FRA(IPLAN)=1.D0/SQRT(DEUPI)*TRAV(IFF)*
!     *                       EXP(-DTETA**2/(2.D0*TRAV(IFF)**2))
!              DO IPTFR=1,NPTFR
!                FBOR(IPTFR,IPLAN,IFF)= SPEC(IFF)*FRA(IPLAN)
!              ENDDO
!           ENDDO
!        ENDDO
!        DEALLOCATE(TRAV)
!
!        PARTIE A SUPPRIMER SI ON FAIT DES MODIFICATIONS
!        DELETE THESE LINES IF MODIFICATIONS HAVE BEEN IMPLEMENTED
!
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) '*****  ERREUR LIMWAC  ******'
          WRITE(LU,*)
     &      ' VOUS NE MODIFIEZ PAS LE SPECTRE AUX LIMITES ALORS QUE'
          WRITE(LU,*) ' VOUS EN DEMANDEZ LA POSSIBILITE'
        ELSE
          WRITE(LU,*) '*****  ERROR LIMWAC  ******'
          WRITE(LU,*)
     &      ' YOU DID NOT MODIFY THE BOUNDARY SPECTRUM WHEREAS '
          WRITE(LU,*) ' YOU ASK FOR THAT '
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF
!
!     ===========================================================
!     END OF USER MODIFICATIONS
!     ===========================================================
!
      ENDIF
!
!     -----------------------------------------------------------------
!     DUPLICATES THE BOUNDARY CONDITION FROM DYNAM ON ALL THE
!     DIRECTIONS AND FREQUENCIES, IF LIQUID BOUNDARY
!     -----------------------------------------------------------------
!
      IF(FLAG.OR.LIMSPE.EQ.7.OR.SPEULI) THEN
        DO IPTFR=1,NPTFR
          IF(LIFBOR(IPTFR).EQ.KENT) THEN
            DO IFF=1,NF
              DO IPLAN=1,NPLAN
                F(NBOR(IPTFR),IPLAN,IFF)=FBOR(IPTFR,IPLAN,IFF)
              ENDDO
            ENDDO
          ENDIF
        ENDDO
      ELSE
        DO IPTFR=1,NPTFR
          IF(LIFBOR(IPTFR).EQ.KENT) THEN
            DO IFF=1,NF
              DO IPLAN=1,NPLAN
                F(NBOR(IPTFR),IPLAN,IFF)=FB_CTE(IPLAN,IFF)
              ENDDO
            ENDDO
          ENDIF
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!     MODIFICATION M. BENOIT (12/03/2002) POUR METTRE SUR LES LIMITES
!     LATERALES LE SPECTRE CALCULE SUR L'AXE DU DOMAINE
!     (ATTENTION : CECI N'EST VALABLE QUE POUR LE MAILLAGE "COURANT
!      LITTORAL" ; LES NUMEROS DE POINTS SONT CODES EN DUR)
!-----------------------------------------------------------------------
!
      DO IP=1,40
        IMIL(IP)=1117+IP-1
        IF (IMIL(IP).EQ.1156) IMIL(IP)=116
        IGAU(IP)=180-IP+1
        IDRO(IP)= 52+IP-1
      ENDDO
!
      IF(NCSIZE.GT.1) THEN
        DO IP=1,40
           CALL BORD_WAC(F,NPLAN,NF,NPOIN2,IP)
        ENDDO
      ENDIF
!
      IF(NCSIZE.LE.1) THEN
        DO IP=1,40
          DO IFF=1,NF
            DO IPLAN = 1,NPLAN
              F(IGAU(IP),IPLAN,IFF) = F(IMIL(IP),IPLAN,IFF)
              F(IDRO(IP),IPLAN,IFF) = F(IMIL(IP),IPLAN,IFF)
            ENDDO
          ENDDO
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
!                  *******************
                   SUBROUTINE BORD_WAC
!                  *******************
!
     &(F,NPLAN,NF,NPOIN2,IP)
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .________________.____.______________________________________________.
! !      NOM       !MODE!                   ROLE                       !
! !________________!____!______________________________________________!
! !    F           ! <->!  DENSITE SPECTRALE                           !
! !    NPLAN       ! -->!  NOMBRE DE DIRECTIONS                        !
! !    NF          ! -->!  NOMBRE DE FREQUENCES                        !
! !    NPOIN2      ! -->!  NOMBRE DE POINTS 2D                         !
! !________________!____!______________________________________________!
! MODE : -->(DONNEE NON MODIFIEE), <--(RESULTAT), <-->(DONNEE MODIFIEE)
!
!-----------------------------------------------------------------------
!
! SOUS-PROGRAMME APPELE PAR : LIMWAC
!
!***********************************************************************
!
      USE BIEF
      USE DECLARATIONS_TOMAWAC ,ONLY : MESH, NCSIZE
!
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
      INTEGER NPLAN,NF,NPOIN2,NPTFR,LT,NPRIV
!
      DOUBLE PRECISION F(NPOIN2,NPLAN,NF)
!
      INTEGER IFF,IPLAN
      INTEGER IP, IMIL, IDRO, IGAU
      DOUBLE PRECISION DUMMY(100,100)
      DOUBLE PRECISION P_DMAX, P_DMIN
      EXTERNAL P_DMAX, P_DMIN
!
!***********************************************************************
!
      IMIL=1117+IP-1
      IF (IMIL.EQ.1156) IMIL=116
      IGAU=180-IP+1
      IDRO= 52+IP-1
!
      IMIL=GLOBAL_TO_LOCAL_POINT(IMIL,MESH)
      IF(IMIL.EQ.0) THEN
        DO IFF=1,NF
          DO IPLAN = 1,NPLAN
            DUMMY(IPLAN,IFF)=0.D0
          ENDDO
        ENDDO
      ELSE
        DO IFF=1,NF
          DO IPLAN = 1,NPLAN
            DUMMY(IPLAN,IFF)=F(IMIL,IPLAN,IFF)
          ENDDO
        ENDDO
      ENDIF
!
      DO IFF=1,NF
        DO IPLAN=1,NPLAN
          DUMMY(IPLAN,IFF) = P_DMAX(DUMMY(IPLAN,IFF))+
     &                       P_DMIN(DUMMY(IPLAN,IFF))
        ENDDO
      ENDDO
!
      IGAU=GLOBAL_TO_LOCAL_POINT(IGAU,MESH)
      IDRO=GLOBAL_TO_LOCAL_POINT(IDRO,MESH)
      IF(IGAU.GT.0) THEN
        DO IFF=1,NF
          DO IPLAN = 1,NPLAN
           F(IGAU,IPLAN,IFF) = DUMMY(IPLAN,IFF)
          ENDDO
        ENDDO
      ENDIF
      IF(IDRO.GT.0) THEN
        DO IFF=1,NF
          DO IPLAN = 1,NPLAN
           F(IDRO,IPLAN,IFF) = DUMMY(IPLAN,IFF)
          ENDDO
        ENDDO
      ENDIF
!
      RETURN
      END
!                       *****************
                        SUBROUTINE ANACOS
!                       *****************
!
     &( UC    , VC    , X     , Y     , NPOIN2 )
!
!***********************************************************************
!  TOMAWAC VERSION 5.2    07/06/01
!***********************************************************************
!
!     FONCTION  : PERMET LA SPECIFICATION D'UN COURANT ANALYTIQUE
!                 (! STATIONNAIRE !)
!
!     FUNCTION  : SPECIFICATION OF AN ANALYTICAL CURRENT
!                 (! STATIONNARY !)
!
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .________________.____.______________________________________________.
! !      NOM       !MODE!                   ROLE                       !
! !________________!____!______________________________________________!
! !    UC,VC       !<-- ! COMPOSANTES DU CHAMP DE COURANT              !
! !    X,Y         ! -->! COORDONNEES DES POINTS DU MAILLAGE 2D        !
! !    NPOIN2      ! -->! NOMBRE DE POINTS 2D                          !
! !________________!____!______________________________________________!
! MODE : -->(DONNEE NON MODIFIEE), <--(RESULTAT), <-->(DONNEE MODIFIEE)
!
!-----------------------------------------------------------------------
!
!  APPELE PAR : CONDIW
!
!  SOUS-PROGRAMME APPELE : NEANT
!
!***********************************************************************
!
      IMPLICIT NONE
!
      INTEGER LNG,LU
      COMMON/INFO/ LNG,LU
!
!.....VARIABLES IN ARGUMENT
!     """"""""""""""""""""
      INTEGER, INTENT(IN)             ::  NPOIN2
      DOUBLE PRECISION, INTENT(IN)    ::  X (NPOIN2) , Y (NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) ::  UC(NPOIN2) , VC(NPOIN2)
!
!.....VARIABLES LOCALES
!     """""""""""""""""
      INTEGER  IP
      DOUBLE PRECISION UCONST, VCONST
!
!
      UCONST=1.0D0
      VCONST=1.0D0
!
      DO 100 IP=1,NPOIN2
        UC(IP)=UCONST
        VC(IP)=VCONST
  100 CONTINUE
!
      RETURN
      END
!
