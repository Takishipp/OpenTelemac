!                    *****************
                     SUBROUTINE CLSEDI
!                    *****************
!
     &( ATABOF , BTABOF , ATABOS , BTABOS , TA     ,
     &  WC     , GRADZFX, GRADZFY, GRADZSX, GRADZSY,
     &  X      , Y      , Z      , HN     , DELTAR ,
     &  TOB    , DENSI  , TRA03  ,  IVIDE  , EPAI   ,
     &  CONC   , HDEP   , FLUER  , PDEPOT , LITABF ,
     &  LITABS , KLOG   , NPOIN3 , NPOIN2 , NPLAN  ,
     &  NPFMAX , NCOUCH , NPF    , ITURBV , DT     , RHO0   ,
     &  RHOS   , CFDEP  , TOCD   , MPART  , TOCE   , TASSE  ,
     &  GIBSON , PRIVE  , UETCAR ,
     &  GRAV   , SEDCO  , DMOY   , CREF   , CF,
     &  AC     , KSPRATIO,ICR)
!
!***********************************************************************
! TELEMAC3D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    EXPRESSES THE BOUNDARY CONDITIONS FOR THE SEDIMENT,
!+                AT THE BOTTOM AND SURFACE (FOR COHESIVE SEDIMENT OR NOT).
!
!history  JACEK A. JANKOWSKI PINXIT
!+        **/03/99
!+        
!+   FORTRAN95 VERSION 
!
!history  CAMILLE LEQUETTE
!+        **/06/03
!+        
!+   
!
!history  C LE NORMANT (LNH)
!+        12/09/07
!+        V5P0
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
!| AC             |-->| 
!| ATABOF         |---| 
!| ATABOS         |---| 
!| BTABOF         |---| 
!| BTABOS         |---| 
!| CF             |---| 
!| CFDEP          |-->| CONCENTRATION(G/L) DE LA VASE QUI SE DEPOSE
!| CONC           |-->| CONCENTRATIONS DES COUCHES DU FOND VASEUX
!| CREF           |---| 
!| DELTAR         |-->| DELTA RHO SUR RHO0 = (RHO-RHO0)/RHO0
!| DENSI          |-->| DENSITE DE L'EAU
!| DMOY           |-->| DIAMETRE MOYEN DES GRAINS
!| DT             |-->| PAS DE TEMPS HYDRAULIQUE
!| EPAI           |<->| TAILLE DES MAILLES DU FOND EN
!|                |   | COORDONNEES MATERIELLES (EPAI=DZ/(1+IVIDE))
!| FLUER          |<--| FLUX D'EROSION EN CHAQUE POINT 2D
!| GIBSON         |-->| LOGIQUE POUR MODELE DE GIBSON
!| GRADZFX        |---| 
!| GRADZFY        |---| 
!| GRADZSX        |---| 
!| GRADZSY        |---| 
!| GRAV           |-->| CONSTANTE GRAVITATIONNELLE
!| HDEP           |<->| HAUTEUR DES DEPOTS FRAIS (COUCHE TAMPON)
!| HN             |-->| HAUTEUR D'EAU A L'INSTANT N
!| ITURBV         |-->| MODELE DE TURBULENCE  VERTICAL
!| IVIDE          |<->| INDICE DES VIDES AUX POINTS DU MAILLAGE
!| KLOG           |-->| INDICATEUR DE PAROI SOLIDE
!| KSPRATIO       |-->| RATIO RUGOSITE DE PEAU / DIAMETRE DES GRAINS
!| LITABF         |---| 
!| LITABS         |---| 
!| MPART          |-->| COEFFICIENT D'EROSION (LOI DE PARTHENIADES)
!| NCOUCH         |-->| NOMBRE DE COUCHES DISCRETISANT LE FOND VASEUX
!|                |   | (MODELE DE TASSEMENT MULTICOUCHES)
!| NPF            |-->| NOMBRE DE POINTS DU FOND  SUR UNE VERTICALE
!| NPFMAX         |-->| NOMBRE MAXIMUM DE PLANS HORIZONTAUX
!|                |   | DISCRETISANT LE FOND VASEUX(MODELE DE GIBSON)
!| NPLAN          |---| 
!| NPOIN2         |-->| NOMBRE DE POINTS 2D
!| NPOIN3         |-->| NOMBRE DE POINTS 3D
!| PDEPOT         |<--| PROBABILITE DE DEPOT EN CHAQUE POINT 2D
!| PRIVE          |-->| TABLEAUX RESERVES A L'UTILISATEUR
!| RHO0           |-->| DENSITE DE REFERENCE DE L'EAU
!| RHOS           |-->| MASSE VOLUMIQUE DU SEDIMENT
!| SEDCO          |-->| LOGIQUE POUR SEDIMENT COHESIF
!| TA             |-->| CONCENTRATION EN SEDIMENT
!| TASSE          |-->| LOGIQUE POUR MODELE DE TASSEMENT MULTICOUCHES
!| TOB            |-->| CONTRAINTE DE FROTTEMENT AU FOND
!| TOCD           |-->| CONTRAINTE CRITIQUE DE DEPOT
!| TOCE           |-->| CONTRAINTE CRITIQUE D'EROSION
!| TRA03          |<->| TABLEAU DE TRAVAIL
!| UETCAR         |-->| U ETOILE CARRE
!| WC             |-->| VITESSE DE CHUTE DU SEDIMENT
!| X,Y,Z          |-->| COORDONNEES DU MAILLAGE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE INTERFACE_TELEMAC3D, EX_CLSEDI => CLSEDI
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NPOIN2,NPOIN3,KLOG,NPFMAX
      INTEGER, INTENT(IN) :: NCOUCH,ITURBV,NPLAN,ICR
!
      DOUBLE PRECISION, INTENT(INOUT) :: ATABOF(NPOIN2), BTABOF(NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) :: ATABOS(NPOIN2), BTABOS(NPOIN2)
!
      DOUBLE PRECISION, INTENT(IN) :: X(NPOIN3), Y(NPOIN3), Z(NPOIN3)
      DOUBLE PRECISION, INTENT(IN) :: TA(NPOIN3)
      DOUBLE PRECISION, INTENT(IN) :: WC(NPOIN3), DELTAR(NPOIN3)
!
      TYPE(BIEF_OBJ), INTENT(INOUT) :: PRIVE,TOB,CREF
      TYPE(BIEF_OBJ), INTENT(IN)    :: DMOY,HN,CF
!
      DOUBLE PRECISION, INTENT(INOUT) :: EPAI(NPFMAX-1,NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) :: IVIDE(NPFMAX,NPOIN2)
      DOUBLE PRECISION, INTENT(IN)    :: CONC(NCOUCH)
!
      DOUBLE PRECISION, INTENT(INOUT) :: DENSI(NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) :: TRA03(NPOIN2),UETCAR(NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) :: HDEP(NPOIN2),FLUER(NPOIN2)
      DOUBLE PRECISION, INTENT(INOUT) :: PDEPOT(NPOIN2)
      DOUBLE PRECISION, INTENT(IN) :: GRADZFX(NPOIN2),GRADZFY(NPOIN2)
      DOUBLE PRECISION, INTENT(IN) :: GRADZSX(NPOIN2),GRADZSY(NPOIN2)
!
      DOUBLE PRECISION, INTENT(IN) :: DT    , RHO0   , RHOS
      DOUBLE PRECISION, INTENT(IN) :: CFDEP , TOCD   , GRAV
      DOUBLE PRECISION, INTENT(IN) :: MPART , TOCE
!
      INTEGER, INTENT(INOUT) :: LITABF(NPOIN2), LITABS(NPOIN2)
      INTEGER, INTENT(INOUT) :: NPF(NPOIN2)
!
      LOGICAL, INTENT(IN)             :: TASSE , GIBSON , SEDCO
      DOUBLE PRECISION, INTENT(IN)    :: AC, KSPRATIO
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION KSP,A,C,ZERO,HCLIP,MU
      INTEGER IPOIN,I
!
!-----------------------------------------------------------------------
!
      ZERO = 1.D-6
!
      DO IPOIN=1,NPOIN2
!       COMPUTES THE FLUID DENSITY
        DENSI(IPOIN) = (DELTAR(IPOIN)+1.D0)*RHO0
!       COMPUTES THE STRESS AT THE BOTTOM
        TOB%R(IPOIN) = DENSI(IPOIN)*UETCAR(IPOIN)
      ENDDO
!
      IF(ICR.EQ.1) THEN
!
        DO IPOIN=1,NPOIN2
!         CORRECTION FOR SKIN FRICTION (SEE TOB_SISYPHE)
          KSP=KSPRATIO *DMOY%R(IPOIN)
          IF(CF%R(IPOIN) > ZERO.AND.HN%R(IPOIN).GT.KSP) THEN
            HCLIP=MAX(HN%R(IPOIN),KSP)
            A = 2.5D0*LOG(12.D0*HCLIP/KSP)
            MU =2.D0/(A**2*CF%R(IPOIN))
          ELSE
            MU=0.D0
          ENDIF
          TOB%R(IPOIN) = MU* TOB%R(IPOIN)
        ENDDO
!
      ENDIF
!
!      -----COMPUTES THE EXPLICIT EROSION FLUX-----
!
      IF(SEDCO) THEN
!
        IF(TASSE) THEN
!
          CALL ERODC(CONC,EPAI,FLUER,TOB%R,DENSI,
     &               MPART,DT,NPOIN2,NCOUCH)
!
        ELSE
!
          CALL ERODE(IVIDE,EPAI,HDEP,FLUER,TOB%R,DENSI,
     &               NPOIN2,NPFMAX,NPF,MPART,TOCE,
     &               CFDEP,RHOS,DT,GIBSON)
!
        ENDIF
      ELSE
!
          CALL ERODNC(CFDEP,WC,HDEP,FLUER,TOB,DT,
     &                NPOIN2,NPOIN3,KSPRATIO,AC,RHOS,RHO0,HN,
     &                GRAV,DMOY,CREF,CF)
!
      ENDIF
!
!      -----WRITES THE BOUNDARY CONDITIONS AT THE BOTTOM / SURFACE-----
!      -----                FOR THE SEDIMENT                      -----
!
      CALL FLUSED(ATABOF , BTABOF , ATABOS , BTABOS ,
     &            LITABF , LITABS , TA     , WC     ,
     &            X      , Y      , Z      , HN%R   ,
     &            GRADZFX, GRADZFY, GRADZSX, GRADZSY,
     &            TOB%R  , PDEPOT , FLUER  , TOCD   ,
     &            NPOIN3 , NPOIN2 , NPLAN  , KLOG   , SEDCO)
!
!-----------------------------------------------------------------------
!
      RETURN
      END