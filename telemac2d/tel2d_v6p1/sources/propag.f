!                    *****************
                     SUBROUTINE PROPAG
!                    *****************
!
     &(U,V,H,UCONV,VCONV,CONVV,H0,C0,COTOND,PATMOS,ATMOS,
     & HPROP,UN,VN,HN,UTILD,VTILD,HTILD,DH,DU,DV,DHN,VISC,VISC_S,FU,FV,
     & SMH,MESH,ZF,AM1,AM2,AM3,BM1,BM2,CM1,CM2,TM1,A23,A32,MBOR,
     & CV1,CV2,CV3,W1,UBOR,VBOR,AUBOR,HBOR,DIRBOR,
     & TE1,TE2,TE3,TE4,TE5,T1,T2,T3,T4,T5,T6,T7,T8,
     & LIMPRO,MASK,GRAV,ROEAU,CF,DIFVIT,IORDRH,IORDRU,LT,AT,DT,
     & TETAH,TETAHC,TETAU,TETAD,
     & AGGLOH,AGGLOU,KDIR,INFOGR,KFROT,ICONVF,
     & PRIVE,ISOUSI,BILMAS,MASSES,YASMH,OPTBAN,CORCON,
     & OPTSUP,MSK,MASKEL,MASKPT,RO,ROVAR,
     & MAT,RHS,UNK,TB,S,BD,PRECCU,SOLSYS,CFLMAX,OPDVIT,OPTSOU,
     & NFRLIQ,SLVPRO,EQUA,VERTIC,ADJO,ZFLATS,TETAZCOMP,UDEL,VDEL,DM1,
     & ZCONV,COUPLING,FLBOR,BM1S,BM2S,CV1S,VOLU2D,V2DPAR,UNSV2D,
     & NUMDIG,NWEIRS,NPSING,HFROT,FLULIM,YAFLULIM)
!
!***********************************************************************
! TELEMAC2D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    PROPAGATION - DIFFUSION - SOURCE TERMS STEP TO SOLVE
!+                THE SAINT-VENANT EQUATIONS.
!+
!+
!+      BOUNDARY CONDITIONS:
!+
!+
!+      ==>   NEUMANN CONDITION
!+
!+
!+            * DIFFUSION   : NU DU/DN = AUBOR . U;
!+                            TREATS THE DIFFUSION MATRIX DIRECTLY
!+
!+
!+            * PROPAGATION : THE BOUNDARY TERMS ARE TREATED IN
!+                            THE SECOND MEMBERS (IMPLICIT)
!+
!+
!+      ==>   DIRICHLET CONDITION
!+
!+
!+            * DIFFUSION, PROPAGATION :
!+                            TREATED USING MODIFIED EQUATIONS IN " PROCLI "
!code
!+      IN MATRIX FORM:
!+
!+                   N+1          N+1          N+1
!+             AM1  H     +  BM1 U     +  BM2 V     =  CV1
!+
!+            T     N+1           N+1
!+          -  CM1 H      +  AM2 U                  =  CV2
!+
!+            T     N+1                        N+1
!+          -  CM2 H                   +  AM3 V     =  CV3
!
!note     BM* REPRESENT DIVERGENCE MATRICES;
!+            BM1: DERIVATION RELATIVE TO X;
!+            BM2: DERIVATION RELATIVE TO Y.
!note 
!+THE TRANSPOSE OF MATRICES BM* IS EQUAL TO THE OPPOSITE
!+            OF GRADIENT. SOME SIGNS ARE THEREFORE OPPOSITE IN
!+            THE EQUATIONS OF SPEED.
!note 
!+THE LAPLACIAN MATRIX (TM1) HAS BEEN INTEGRATED IN PART.
!+            THE SIGN IS THEREFORE OPPOSITE IN THE EQUATIONS OF
!+            SPEED.
!
!history  JMH
!+        07/05/2007
!+        
!+   MODIFICATION ON THE SOURCES IN CASE OF MASS-LUMPING 
!
!history  
!+        10/06/2008
!+        
!+   FINITE VOLUME ADVECTION FOR SPEEDS 
!
!history  
!+        02/10/2008
!+        
!+   CALL TO CVTRVF (ONE MORE WORKING ARRAY) 
!
!history  
!+        20/07/2009
!+        
!+   ICONVF (2) = 5 MANDATORY, ALL OTHER CASES ERASED 
!
!history  
!+        22/07/2009
!+        
!+   EQUALITY OF FLUXES IMPOSED ON EITHER SIDE OF A WEIR 
!
!history  J-M HERVOUET (LNHE)
!+        09/10/2009
!+        V6P0
!+   PARAMETERISED ADVECTION OPTIONS 
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
!| A23,A32        |<->| MATRICES
!| ADJO           |-->| IF YES : ADJOINT MODE
!| AGGLOH         |-->| COEFFICIENT DE MASS-LUMPING SUR H
!| AGGLOU         |-->| COEFFICIENT DE MASS-LUMPING SUR U
!| AM2            |---| 
!| AM3            |---| 
!| ATMOS          |-->| LOGIQUE INDIQUANT SI PATMOS EST REMPLI.
!| AUBOR          |-->| CONDITIONS AUX LIMITES SUR LE FROTTEMENT.
!| BD             |---| 
!| BILMAS         |-->| INDIQUE SI ON FAIT LE BILAN DE MASSE
!| BM1S           |---| 
!| BM2            |---| 
!| BM2S           |---| 
!| C0             |-->| CELERITE DE REFERENCE
!| CF             |---| 
!| CFLMAX         |---| 
!| CM1            |---| 
!| CM2            |---| 
!| CONVV          |-->| LOGIQUES INDIQUANT LES VARIABLES QUE L'ON
!|                |   | VEUT CONVECTER
!|                |   | CONVV(1):U,V CONVV(2):H
!| CORCON         |-->| CORRECTION DE CONTINUITE SUR LES POINTS A
!|                |   | HAUTEUR IMPOSEE (ON CORRIGE LES VITESSES)
!| COTOND         |<--| EXPRESSION DE CU/G DANS LA THEORIE DE L'ONDE
!|                |   | INCIDENTE
!| COUPLING       |---| 
!| CV1,CV2,CV3    |<->| SECONDS MEMBRES DU SYSTEME.
!| CV1S           |---| 
!| DH,DHN         |<--| STOCKAGE DE LA VARIABLE DH  (DHN AU TEMPS N)
!| DIFVIT         |-->| INDIQUE S'IL FAUT FAIRE LA DIFFUSION DE U,V
!| DIRBOR         |---| 
!| DM1            |---| 
!| DU,DV          |<--| STOCKAGE DES QCCROISSEMENTS EN U ET V
!| EQUA           |---| 
!| FLBOR          |---| 
!| FLULIM         |-->| FLUX LIMITATION
!| FU,FV          |<->| TERMES SOURCES TRAITES EN P1
!| GRAV           |-->| CONSTANTE DE GRAVITE .
!| H0             |---| 
!| HBOR           |-->| CONDITIONS AUX LIMITES SUR H.
!| HFROT          |---| 
!| HPROP          |-->| HAUTEUR DE PROPAGATION
!| HTILD          |---| 
!| ICONVF         |-->| FORME DE LA CONVECTION
!|                |   | TABLEAU DE 4 VALEURS ENTIERES POUR :
!|                |   | ICONVF(1) : U ET V
!|                |   | ICONVF(2) : H (MANDATORY VALUE = 5)
!|                |   | ICONVF(3) : TRACEUR
!|                |   | ICONVF(4) : K ET EPSILON
!| INFOGR         |-->| INFORMATIONS SUR LE GRADIENT (LOGIQUE)
!| IORDRH         |-->| ORDRE DU TIR INITIAL POUR H
!| IORDRU         |-->| ORDRE DU TIR INITIAL POUR U
!| ISOUSI         |-->| NUMERO DE LA SOUS-ITERATION DANS LE PAS
!|                |   | DE TEMPS.
!| KDIR           |-->| CONDITION A LA LIMITE DE TYPE DIRICHLET
!| KFROT          |-->| LOI DE FROTTEMENT SUR LE FOND
!| LIMPRO         |-->| TYPES DE CONDITIONS AUX LIMITES
!| LT,AT,DT       |-->| NUMERO D'ITERATION, TEMPS, PAS DE TEMPS
!| MASK           |-->| BLOC DE MASQUES POUR LES SEGMENTS :
!|                |   | MASK(MSK1): 1. SI KDIR SUR U 0. SINON
!|                |   | MASK(MSK2): 1. SI KDIR SUR V 0. SINON
!|                |   | MASK(MSK3): 1. SI KDDL SUR U 0. SINON
!|                |   | MASK(MSK4): 1. SI KDDL SUR V 0. SINON
!|                |   | MASK(MSK6): 1. SI KNEU SUR V 0. SINON
!|                |   | MASK(MSK7): 1. SI KOND 0. SINON
!|                |   | MASK(MSK9): 1. SI KDIR SUR H (POINT)
!| MASKEL         |-->| TABLEAU DE MASQUAGE DES ELEMENTS
!|                |   | =1. : NORMAL   =0. : ELEMENT MASQUE
!| MASKPT         |-->| MASQUES PAR POINTS.
!| MASSES         |-->| MASSE CREEE PAR TERME SOURCE PENDANT
!|                |   | LE PAS DE TEMPS.
!| MAT            |---| 
!| MBOR           |---| 
!| MESH           |---| 
!| MSK            |-->| SI OUI, PRESENCE D'ELEMENTS MASQUES.
!| NFRLIQ         |---| 
!| NPSING         |---| 
!| NUMDIG         |---| 
!| NWEIRS         |---| 
!| OPDVIT         |---| 
!| OPTBAN         |-->| OPTION DE TRAITEMENT DES BANCS DECOUVRANTS
!|                |   | NON UTILISE POUR L'INSTANT :
!| OPTSOU         |---| 
!| OPTSUP         |---| 
!| PATMOS         |-->| TABLEAU DE VALEURS DE LA PRESSION ATMOSPHER.
!| PRECCU         |---| 
!| PRIVE          |-->| TABLEAU DE TRAVAIL DEFINI DANS PRINCI
!| RHS            |---| 
!| RO             |-->| MASSE VOLUMIQUE SI ELLE VARIABLE
!| ROEAU          |-->| MASSE VOLUMIQUE DE L'EAU.
!| ROVAR          |-->| OUI SI LA MASSE VOLUMIQUE EST VARIABLE.
!| S              |-->| STRUCTURE BIDON
!| SLVPRO         |---| 
!| SMH            |-->| TERMES SOURCES DE L'EQUATION DE CONTINUITE
!| SOLSYS         |---| 
!| T1             |---| 
!| T2             |---| 
!| T3             |---| 
!| T4             |---| 
!| T5             |---| 
!| T6             |---| 
!| T7             |---| 
!| T8             |---| 
!| TB             |---| 
!| TE1            |---| 
!| TE2            |---| 
!| TE3            |---| 
!| TE4            |---| 
!| TE5            |---| 
!| TETAD          |-->| IMPLICITATION SUR LA DIFFUSION
!| TETAH          |-->| IMPLICITATION SUR H DANS L'EQUATION SUR U
!| TETAHC         |-->| IMPLICITATION SUR H DANS LA CONTINUITE
!| TETAU          |-->| IMPLICITATION SUR U ET V
!| TETAZCOMP      |---| 
!| TM1            |<->| MATRICE
!| UBOR           |-->| CONDITIONS AUX LIMITES SUR U.
!| UCONV,VCONV    |-->| CHAMP CONVECTEUR
!| UDEL           |---| 
!| UN,VN,HN       |-->| VALEURS A L' ETAPE N.
!| UNK            |---| 
!| UNSV2D         |---| 
!| UTILD          |---| 
!| V2DPAR         |---| 
!| VBOR           |-->| CONDITIONS AUX LIMITES SUR V.
!| VDEL           |---| 
!| VERTIC         |---| 
!| VISC           |-->| VISCOSITE TURBULENTE .
!| VISC_S         |---| 
!| VOLU2D         |---| 
!| VTILD          |---| 
!| W1             |<->| TABLEAU DE TRAVAIL.
!| YAFLULIM       |-->| IF, YES, FLULIM TAKEN INTO ACCOUNT
!| YASMH          |-->| INDIQUE SI ON PREND EN COMPTE SMH
!| ZCONV          |---| 
!| ZF             |-->| COTE DU FONT AU NOEUD DE MAILLAGE .
!| ZFLATS         |---| 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE DECLARATIONS_TELEMAC, ONLY : ADV_CAR,ADV_SUP,ADV_NSC,ADV_PSI,
     &   ADV_PSI_NC,ADV_NSC_NC,ADV_LPO,ADV_NSC_TF,ADV_PSI_TF,ADV_LPO_TF
!
      USE INTERFACE_TELEMAC2D, EX_PROPAG => PROPAG
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: LT,OPTSUP(4),KDIR,KFROT,ICONVF(4),NWEIRS
      INTEGER, INTENT(IN) :: IORDRH,IORDRU,ISOUSI,OPTBAN,OPTSOU,SOLSYS
      INTEGER, INTENT(IN)             :: OPDVIT,NFRLIQ,HFROT
      DOUBLE PRECISION, INTENT(IN)    :: TETAU,TETAD,TETAH,AGGLOH,AGGLOU
      DOUBLE PRECISION, INTENT(IN)    :: TETAHC,AT,DT,GRAV,ROEAU
      DOUBLE PRECISION, INTENT(IN)    :: TETAZCOMP
      DOUBLE PRECISION, INTENT(INOUT) :: CFLMAX,MASSES
      LOGICAL, INTENT(IN) :: BILMAS,ATMOS,DIFVIT,INFOGR,CONVV(4),MSK
      LOGICAL, INTENT(IN) :: YASMH,ROVAR,PRECCU,VERTIC,ADJO,CORCON
      LOGICAL, INTENT(IN) :: YAFLULIM
      TYPE(SLVCFG), INTENT(INOUT)     :: SLVPRO
      CHARACTER(LEN=20),  INTENT(IN)  :: EQUA
      CHARACTER(LEN=*) ,  INTENT(IN)  :: COUPLING
!                                                           NPSMAX
      INTEGER, INTENT(IN) :: NPSING(NWEIRS),NUMDIG(2,NWEIRS,*     )
!
!  STRUCTURES OF VECTORS
!
      TYPE(BIEF_OBJ), INTENT(IN)    :: UCONV,VCONV,SMH,UN,VN,HN
      TYPE(BIEF_OBJ), INTENT(IN)    :: VOLU2D,V2DPAR,UNSV2D,FLULIM
      TYPE(BIEF_OBJ), INTENT(INOUT) :: RO,UDEL,VDEL,DM1,ZCONV,FLBOR
      TYPE(BIEF_OBJ), INTENT(IN)    :: UTILD,VTILD,PATMOS,CF
      TYPE(BIEF_OBJ), INTENT(INOUT) :: U,V,H,CV1,CV2,CV3,PRIVE,DH,DHN
      TYPE(BIEF_OBJ), INTENT(INOUT) :: CV1S
      TYPE(BIEF_OBJ), INTENT(INOUT) :: DU,DV,FU,FV,VISC,VISC_S,HTILD
      TYPE(BIEF_OBJ), INTENT(INOUT) :: UBOR,VBOR,HBOR,AUBOR,COTOND
      TYPE(BIEF_OBJ), INTENT(IN)    :: MASKEL,MASKPT,ZF
      TYPE(BIEF_OBJ), INTENT(IN)    :: HPROP,H0,C0,LIMPRO
!
!     TE : BY ELEMENT               TE4,TE5 ONLY IF OPTBAN=3
      TYPE(BIEF_OBJ), INTENT(INOUT) :: TE1,TE2,TE3,TE4,TE5,ZFLATS
!     T  : BY POINT
      TYPE(BIEF_OBJ), INTENT(INOUT) :: T1,T2,T3,T4,T5,T6,T7,T8
      TYPE(BIEF_OBJ), INTENT(INOUT) :: W1
!     DUMMY STRUCTURE
      TYPE(BIEF_OBJ), INTENT(IN)    :: S
!
!-----------------------------------------------------------------------
!
!  STRUCTURES OF MATRICES
!
      TYPE(BIEF_OBJ), INTENT(INOUT) :: AM1,AM2,AM3,BM1,BM2,CM1,CM2,TM1
      TYPE(BIEF_OBJ), INTENT(INOUT) :: A23,A32,MBOR,BM1S,BM2S
!
!-----------------------------------------------------------------------
!
!  STRUCTURES OF BLOCKS
!
      TYPE(BIEF_OBJ), INTENT(INOUT) :: MASK,MAT,RHS,UNK,TB,BD,DIRBOR
!
!-----------------------------------------------------------------------
!
!  STRUCTURE OF MESH
!
      TYPE(BIEF_MESH), INTENT(INOUT) :: MESH
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I,IELMU,IELMH,UDIR,UDDL,UNEU,HOND,UNONNEU,IELEM,NELEM
      INTEGER I1,I2,I3,DIMLIM,N,IOPT
!
      DOUBLE PRECISION Z(1),SL1,SL1U,C
!
      DOUBLE PRECISION P_DSUM
      EXTERNAL         P_DSUM
!
      LOGICAL MSKGRA
!
      CHARACTER*16 FORMUL
!
!-----------------------------------------------------------------------
!
      DIMLIM=LIMPRO%DIM1
!
      IELMH=H%ELM
      IELMU=U%ELM
!
!  ADDRESSES OF THE ARRAYS IN THE MASKING BLOCK: MASK
!
      UDIR = 1
!     VDIR = 2
      UDDL = 3
!     VDDL = 4
      UNEU = 5
!     VNEU = 6
      HOND = 7
      UNONNEU = 8
!
!-----------------------------------------------------------------------
!
!  DIRICHLET BOUNDARY CONDITIONS FOR INCREASE IN H
!
!  HBOR = HBOR - HN (HBOR ON THE BOUNDARY, HN IN THE DOMAIN)
!
      CALL OSBD( 'X=X-Y   ' , HBOR , HN , HN , C , MESH )
!
!=======================================================================
!
!    GRADIENT MATRICES FOR THE CONTINUITY EQUATION:
!
!    BM1 = - TETAU ( D(HN.F1)/DX * F2)
!    BM2 = - TETAU ( D(HN.F1)/DY * F2)
!
      IF(OPTBAN.EQ.3) THEN
!       TAKES POROSITY INTO ACCOUNT
        CALL MATRIX(BM1,'M=N     ','MATFGR         X',IELMH,IELMU,
     &              TETAU,HPROP,S,S,S,S,S,MESH,.TRUE.,TE5)
        CALL MATRIX(BM2,'M=N     ','MATFGR         Y',IELMH,IELMU,
     &              TETAU,HPROP,S,S,S,S,S,MESH,.TRUE.,TE5)
!
!       MATRICES RESULTING FROM SUPG APPLIED TO THE ADVECTION TERM
!
        IF(OPTSUP(2).EQ.1) THEN
          CALL KSUPG(TE1,TE2,1.D0,UCONV,VCONV,MESH)
          CALL MATRIX(BM1,'M=M+N   ','MATUGH         X',IELMH,IELMU,
     &                TETAU,HPROP,S,S,TE1,TE2,S,MESH,.TRUE.,TE5)
          CALL MATRIX(BM2,'M=M+N   ','MATUGH         Y',IELMH,IELMU,
     &                TETAU,HPROP,S,S,TE1,TE2,S,MESH,.TRUE.,TE5)
        ELSEIF(OPTSUP(2).EQ.2) THEN
          CALL MATRIX(BM1,'M=M+N   ','MATUGH         X',IELMH,IELMU,
     &                0.5*DT*TETAU,HPROP,S,S,UCONV,VCONV,S,
     &                MESH,.TRUE.,TE5)
          CALL MATRIX(BM2,'M=M+N   ','MATUGH         Y',IELMH,IELMU,
     &                0.5*DT*TETAU,HPROP,S,S,UCONV,VCONV,S,
     &                MESH,.TRUE.,TE5)
        ENDIF
!
      ELSE
!
        CALL MATRIX(BM1,'M=N     ','MATFGR         X',IELMH,IELMU,
     &              TETAU,HPROP,S,S,S,S,S,MESH,MSK,MASKEL)
        CALL MATRIX(BM2,'M=N     ','MATFGR         Y',IELMH,IELMU,
     &              TETAU,HPROP,S,S,S,S,S,MESH,MSK,MASKEL)
!
!       MATRICES RESULTING FROM SUPG APPLIED TO THE ADVECTION TERM
!
        IF(OPTSUP(2).EQ.1) THEN
          CALL KSUPG(TE1,TE2,1.D0,UCONV,VCONV,MESH)
          CALL MATRIX(BM1,'M=M+N   ','MATUGH         X',IELMH,IELMU,
     &                TETAU,HPROP,S,S,TE1,TE2,S,MESH,MSK,MASKEL)
          CALL MATRIX(BM2,'M=M+N   ','MATUGH         Y',IELMH,IELMU,
     &                TETAU,HPROP,S,S,TE1,TE2,S,MESH,MSK,MASKEL)
        ELSEIF(OPTSUP(2).EQ.2) THEN
          CALL MATRIX(BM1,'M=M+N   ','MATUGH         X',IELMH,IELMU,
     &                0.5*DT*TETAU,HPROP,S,S,UCONV,VCONV,S,
     &                MESH,MSK,MASKEL)
          CALL MATRIX(BM2,'M=M+N   ','MATUGH         Y',IELMH,IELMU,
     &                0.5*DT*TETAU,HPROP,S,S,UCONV,VCONV,S,
     &                MESH,MSK,MASKEL)
        ENDIF
!
      ENDIF
!
!=======================================================================
!
!   BUILDS THE DIFFUSION MATRIX :
!
!    TM1 =  VISC . (P03 * (DF1/DX * DF2/DX + DF1/DY * DF2/DY) )
!
      IF(DIFVIT) THEN
!
        IF(OPDVIT.EQ.2) THEN
!         SAVES DIFFUSION
          CALL OS('X=Y     ',VISC_S,VISC,VISC,C)
!         MULTIPLIES DIFFUSION BY HPROP
          CALL OV_2('X=XY    ',VISC%R,1,HPROP%R,1,Z,1,C,
     &                         VISC%MAXDIM1,VISC%DIM1)
          IF(VISC%DIM2.EQ.3) THEN
            CALL OV_2('X=XY    ',VISC%R,2,HPROP%R,1,Z,1,C,
     &                           VISC%MAXDIM1,VISC%DIM1)
            CALL OV_2('X=XY    ',VISC%R,3,HPROP%R,1,Z,1,C,
     &                           VISC%MAXDIM1,VISC%DIM1)
          ENDIF
        ENDIF
!
        CALL MATRIX(TM1,'M=N     ','MATDIF          ',IELMU,IELMU,
     &              1.D0,S,S,S,VISC,S,S,MESH,MSK,MASKEL)
!
        IF(OPDVIT.EQ.2) THEN
!          MULTIPLIES THE MATRIX BY 1/HPROP
           CALL CPSTVC(HPROP,T4)
           DO I=1,HPROP%DIM1
!            BEWARE: HIDDEN PARAMETER 1.D-2, NO DIFFUSION BELOW 1 CM DEPTH
!                                            WITH THIS OPTION
             IF(HPROP%R(I).GT.1.D-2) THEN
               T4%R(I)=1.D0/HPROP%R(I)
             ELSE
               T4%R(I)=0.D0
             ENDIF
           ENDDO
           IF(T4%ELM.NE.IELMU) CALL CHGDIS(T4,T4%ELM,IELMU,MESH)
           CALL OM( 'M=X(M)  ' , TM1 , TM1 , S  , C , MESH )
           CALL OM( 'M=DM    ' , TM1 , TM1 , T4 , C , MESH )
!          RESTORES DIFFUSION
           CALL OS('X=Y     ',VISC,VISC_S,VISC_S,C)
        ENDIF
!
!       'IF' ADDED ON 23/07/2002 BY JMH (MAY HAPPEN IN PARALLEL MODE)
        IF(MESH%NPTFR.GT.0) THEN
         CALL MATRIX(MBOR,'M=N     ','FMATMA          ',
     &               IELBOR(IELMU,1),IELBOR(IELMU,1),
     &               -1.D0,AUBOR,S,S,S,S,S,MESH,.TRUE.,MASK%ADR(UNEU)%P)
         CALL OM( 'M=M+N   ' , TM1 , MBOR , S , C , MESH )
        ENDIF
!
!       EXPLICIT PART DEALT WITH IN THE NEXT IF(DIFVIT...
!
      ENDIF
!
!=======================================================================
!
!  COMPUTES THE FREE SURFACE ELEVATION (IN T8)
!
      CALL OS( 'X=Y+Z   ' , T8 , HN , ZF , C )
!
!  OPTION 1 FOR THE TREATMENT OF TIDAL FLATS
!  A MASK MAY BE USED FOR TIDAL FLATS ALTHOUGH THIS
!  IS NOT THE MASKING OPTION.
!  THIS MASK IS IN TE3
!
      IF(OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
        CALL DECVRT(TE3,T8,ZF,MESH)
      ENDIF
!
!     FREE SURFACE GRADIENT
!
      IF (OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
!                   SL CORRECTED BY ELEMENT
        CALL CORRSL(ZFLATS,T8,ZF,MESH)
        CALL VECTOR(CV2,'=','GRADF          X',IELMU,
     &              -GRAV,ZFLATS,S,S,S,S,S,MESH,MSK,MASKEL)
        CALL VECTOR(CV3,'=','GRADF          Y',IELMU,
     &              -GRAV,ZFLATS,S,S,S,S,S,MESH,MSK,MASKEL)
!       CORRSL DECLARES A DISCONTINUOUS ELEMENT, RESTORES BACK
      ELSE
        CALL VECTOR(CV2,'=','GRADF          X',IELMU,
     &              -GRAV,T8,S,S,S,S,S,MESH,MSK,MASKEL)
        CALL VECTOR(CV3,'=','GRADF          Y',IELMU,
     &              -GRAV,T8,S,S,S,S,S,MESH,MSK,MASKEL)
      ENDIF
!
!  ADDITIONAL GRADIENT TERMS : ATMOSPHERIC PRESSURE
!                              VARIABLE DENSITY
!
!  THESE DRIVING TERMS SHOULD NOT BE ADDED IN TIDAL FLATS
!
!
      IF(ROVAR.OR.ATMOS) THEN
!
!  CASE WHERE THESE GRADIENTS SHOULD BE MASKED: MASKING REQUIRED OR
!                                               OPTBAN=1
!
      IF(MSK.OR.OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
        MSKGRA = .TRUE.
!       IF OPTBAN=1 THE MASK USED HERE SHOULD HAVE VALUES
        IF(OPTBAN.NE.1.AND.OPTBAN.NE.3) THEN
         CALL OV('X=Y     ',TE3%R,MASKEL%R,MASKEL%R,C,TE3%DIM1)
        ENDIF
      ELSE
        MSKGRA = .FALSE.
      ENDIF
!
!     ATMOSPHERIC PRESSURE GRADIENT
!
      IF(ATMOS) THEN
        CALL VECTOR(CV2,'+','GRADF          X',IELMU,
     &              -1.D0/ROEAU,PATMOS,S,S,S,S,S,MESH,MSKGRA,TE3)
        CALL VECTOR(CV3,'+','GRADF          Y',IELMU,
     &              -1.D0/ROEAU,PATMOS,S,S,S,S,S,MESH,MSKGRA,TE3)
      ENDIF
!
!     ADDITIONAL TERMS IF THE DENSITY IS VARIABLE
!
      IF(ROVAR) THEN
!
        CALL OS( 'X=X+C   ' , RO , S , S , -ROEAU )
!
!       PRESSURE BAROCLINE
!
        CALL VECTOR(CV2,'+','GGRADF         X',IELMU,
     &              -0.5D0*GRAV/ROEAU,RO,HN,S,S,S,S,MESH,MSKGRA,TE3)
        CALL VECTOR(CV3,'+','GGRADF         Y',IELMU,
     &              -0.5D0*GRAV/ROEAU,RO,HN,S,S,S,S,MESH,MSKGRA,TE3)
        CALL OS( 'X=X+C   ' , RO , S , S , +ROEAU )
!
      ENDIF
!
      ENDIF
!
!=======================================================================
!
!    MASS MATRIX / DT
!    AM1 WILL BE MODIFIED AT A LATER DATE IF SUPG IS USED ON H
!
!    AM1 = ( 1 / DT )  * (F1 * F2)
!
      SL1 = 1.D0 / DT
      IF(OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
!       LOCALLY LUMPED MASS MATRIX (TIDAL FLATS)
        FORMUL='MSLUMP          '
      ELSE
!       NORMAL MASS MATRIX
        FORMUL='MATMAS          '
      ENDIF
      IF(OPTBAN.NE.3) THEN
        CALL MATRIX(AM1,'M=N     ',FORMUL,IELMH,IELMH,
     &              SL1,TE3,S,S,S,S,S,MESH,MSK,MASKEL)
      ELSE
        CALL MATRIX(AM1,'M=N     ',FORMUL,IELMH,IELMH,
     &              SL1,TE3,S,S,S,S,S,MESH,.TRUE.,TE5)
      ENDIF
!
!   MASS MATRIX FOR THE MOMENTUM EQUATION
!
      IF(SOLSYS.EQ.1) THEN
!
!                           OPTBAN.NE.3 TO AVOID POROSITY IN AM2
      IF(IELMU.EQ.IELMH.AND.OPTBAN.NE.3) THEN
        CALL OM( 'M=N     ' , AM2 , AM1 , S , C , MESH )
      ELSE
        CALL MATRIX(AM2,'M=N     ',FORMUL,IELMU,IELMU,
     &              SL1,TE3,S,S,S,S,S,MESH,MSK,MASKEL)
      ENDIF
!     MASS-LUMPING OF AM2 :
      IF(AGGLOU.GT.0.001D0) THEN
        CALL LUMP(T2,AM2,MESH,AGGLOU)
        CALL OM( 'M=CN    ' , AM2 , AM2 , S  , 1.D0-AGGLOU , MESH )
        CALL OM( 'M=M+D   ' , AM2 , AM2 , T2 , C           , MESH )
      ENDIF
!
      ELSEIF(SOLSYS.EQ.2) THEN
        IF(IELMU.NE.IELMH) THEN
          CALL VECTOR(AM2%D,'=','MASBAS          ',IELMU,
     &                SL1,S,S,S,S,S,S,MESH,MSK,MASKEL)
        ELSE
          CALL OS('X=CY    ',X=AM2%D,Y=VOLU2D,C=SL1)
        ENDIF
        AM2%TYPDIA='Q'
        AM2%TYPEXT='0'
      ENDIF
!
! MASS-LUMPING OF AM1 :
!
      IF(AGGLOH.GT.0.001D0) THEN
        CALL LUMP(T1,AM1,MESH,AGGLOH)
        CALL OM( 'M=CN    ' , AM1 , AM1 , S , 1.D0-AGGLOH , MESH )
        CALL OM( 'M=M+D   ' , AM1 , AM1 , T1 , C          , MESH )
      ENDIF
!
! END OF MASS-LUMPING
!
! TEMPORARILY STORES THE LUMPED MASS MATRIX: AM2 IN AM3
! FOR THE COMPUTATION OF THE TERMS FROM TIME DERIVATIVES
!
      IF(SOLSYS.EQ.1) THEN
        CALL OM( 'M=N     ' , AM3 , AM2 , S , C , MESH )
      ELSEIF(SOLSYS.EQ.2) THEN
        CALL OS('X=Y     ',X=AM3%D,Y=AM2%D)
        AM3%TYPDIA=AM2%TYPDIA
        AM3%TYPEXT=AM2%TYPEXT
      ENDIF
!
!=======================================================================
!
!   COMPUTES THE VECTORS IN THE SECOND MEMBERS
!
!   BEWARE : PAY A LOT OF ATTENTION TO PARAMETER LEGO (FALSE OR TRUE)
!            IN CALLS TO MATVEC, VGRADF. IF LEGO = .FALSE. THE
!            COMPUTATION RESULT GOES IN W1. IN THIS CASE, SHOULD ALWAYS
!            USE OPERATIONS 'X=X+...' NOT TO ERASE WHAT WAS IN W1,
!            AND END BY LEGO=.TRUE. FOR THE FINAL ASSEMBLY.
!
!
!-----------------------------------------------------------------------
!
!     CV1 = CV1 + SL1U * ( BM1 * UN + BM2 * VN )
!
      SL1U   = (TETAU-1.D0)/TETAU
!                           TETAU : BM1 WAS BUILT WITH THIS COEFFICIENT
      IF(ABS(SL1U).GT.0.0001D0) THEN
        CALL MATVEC('X=CAY   ',CV1,BM1,UN,SL1U,MESH)
        CALL MATVEC('X=X+CAY ',CV1,BM2,VN,SL1U,MESH)
      ELSE
        CALL CPSTVC(H,CV1)
        CALL OS('X=0     ',X=CV1)
      ENDIF
!
!     SOURCE TERMS IN THE CONTINUITY EQUATION :
!
      MASSES = 0.D0
      IF(YASMH) THEN
        IF(OPTSOU.EQ.1) THEN
!         STANDARD VERSION
!         NOTE JMH : HOW ABOUT MASS-LUMPING ?? USE DT*AM1*SMH ??
!         TAKING MASS-LUMPING INTO ACCOUNT
          CALL MATVEC( 'X=CAY   ',T1,AM1,SMH,DT,MESH)
!         WITHOUT TAKING MASS-LUMPING INTO ACCOUNT
!         CALL VECTOR(T1,'=','MASVEC          ',IELMH,
!    *                1.D0,SMH,S,S,S,S,S,MESH,MSK,MASKEL)
          CALL OS( 'X=X+Y   ' , CV1 , T1 , S , C )
          IF(BILMAS) MASSES = DT * BIEF_SUM(T1)
        ELSE
!         DIRAC VERSION
          CALL OS( 'X=X+Y   ' ,X=CV1,Y=SMH)
          IF(BILMAS) MASSES = DT * BIEF_SUM(SMH)
        ENDIF
!       THE FOLLOWING LINE GOES IN BILAN
!       IF (NCSIZE.GT.1) MASSES=P_DSUM (MASSES)
      ENDIF
!
!  DEBUT DES CONVECTIONS DE U
!
!
!-----------------------------------------------------------------------
!
!     ADVECTION OF U AND V
!
      IF(ICONVF(1).NE.ADV_LPO.AND.ICONVF(1).NE.ADV_LPO_TF.AND.
     &   ICONVF(1).NE.ADV_NSC.AND.ICONVF(1).NE.ADV_NSC_TF.AND.
     &   ICONVF(1).NE.ADV_PSI.AND.ICONVF(1).NE.ADV_PSI_TF     ) THEN
        CALL OS( 'X=CY    ' , X=T1 , Y=FU , C=DT )
        CALL OS( 'X=CY    ' , X=T2 , Y=FV , C=DT )
      ENDIF
!
      IF(ICONVF(1).EQ.ADV_CAR.OR.(.NOT.CONVV(1))) THEN
!
!       ADVECTION WITH THE METHOD OF CHARACTERISTICS
!
        CALL OS( 'X=X+Y   ' , X=T1 , Y=UTILD )
        CALL OS( 'X=X+Y   ' , X=T2 , Y=VTILD )
!
!------ SCHEMA SEMI-IMPLICITE CENTRE + S.U.P.G -----------------------
!
      ELSEIF(ICONVF(1).EQ.ADV_SUP) THEN
!
!       CENTRED SEMI-IMPLICIT ADVECTION TERM: MATRIX
!
        CALL MATRIX(CM2,'M=N     ','MATVGR          ',IELMU,IELMU,
     &              1.D0,S,S,S,UCONV,VCONV,VCONV,MESH,MSK,MASKEL)
!
!       SUPG CONTRIBUTION
!
        IF(OPTSUP(1).EQ.1) THEN
!         CLASSICAL SUPG
          CALL KSUPG(TE1,TE2,1.D0,UCONV,VCONV,MESH)
          CALL MATRIX(CM2,'M=M+N   ','MASUPG          ',IELMU,IELMU,
     &                1.D0,TE1,TE2,S,UCONV,VCONV,VCONV,
     &                MESH,MSK,MASKEL)
        ELSEIF(OPTSUP(1).EQ.2) THEN
!         MODIFIED SUPG
          CALL MATRIX(CM2,'M=M+N   ','MAUGUG          ',IELMU,IELMU,
     &                0.5D0*DT,S,S,S,UCONV,VCONV,VCONV,
     &                MESH,MSK,MASKEL)
        ENDIF
!
!       END OF SUPG CONTRIBUTION
!
!       EXPLICIT SECOND MEMBER
!
        IF(ABS(SL1U).GT.0.0001D0) THEN
          CALL MATVEC( 'X=X+CAY ',CV2,CM2,UN,TETAU-1.D0,MESH)
          CALL MATVEC( 'X=X+CAY ',CV3,CM2,VN,TETAU-1.D0,MESH)
        ENDIF
!
!       MATRIX : AM2 HAS A NON-SYMMETRICAL STRUCTURE
!
        IF(AM2%TYPEXT.NE.'Q') THEN
          CALL OM( 'M=X(M)  ' , AM2 , AM2 , S , C , MESH )
        ENDIF
        CALL OM( 'M=M+CN  ' , AM2 , CM2 , S , TETAU , MESH )
!
        CALL OS( 'X=X+Y   ' , X=T1 , Y=UN )
        CALL OS( 'X=X+Y   ' , X=T2 , Y=VN )
!
!-----------------------------------------------------------------
!
!  PSI SCHEME
!
      ELSEIF(ICONVF(1).EQ.ADV_PSI_NC) THEN
!
!       STARTS COMPUTATION OF SECOND MEMBERS CV2 AND CV3
!
        CALL VGFPSI(T6,IELMU,UCONV,VCONV,UN,DT,-1.D0,CFLMAX,
     &              T4,T5,MESH,MSK,MASKEL)
        CALL OS( 'X=X+Y   ' , X=CV2 , Y=T6 )
        CALL OS( 'X=X+Y   ' , X=T1  , Y=UN )
!
        CALL VGFPSI(T6,IELMU,UCONV,VCONV,VN,DT,-1.D0,CFLMAX,
     &              T4,T5,MESH,MSK,MASKEL)
        CALL OS( 'X=X+Y   ' , X=CV3 , Y=T6 )
        CALL OS( 'X=X+Y   ' , X=T2  , Y=VN )
!
!------ SCHEMA SEMI-IMPLICITE N --------------------------------------
!
      ELSEIF(ICONVF(1).EQ.ADV_NSC_NC) THEN
!
!       CENTRED SEMI-IMPLICIT ADVECTION TERM : MATRIX
!
        CALL MATRIX(CM2,'M=N     ','MATVGR         N',IELMU,IELMU,
     &              1.D0,S,S,S,UCONV,VCONV,VCONV,MESH,MSK,MASKEL)
!
!       EXPLICIT SECOND MEMBER
!
        IF(ABS(SL1U).GT.0.0001D0) THEN
          CALL MATVEC( 'X=X+CAY ',CV2,CM2,UN,TETAU-1.D0,MESH)
          CALL MATVEC( 'X=X+CAY ',CV3,CM2,VN,TETAU-1.D0,MESH)
        ENDIF
!
!       MATRIX : AM2 HAS A NON-SYMMETRICAL STRUCTURE
!
        IF(AM2%TYPEXT.NE.'Q') THEN
          CALL OM( 'M=X(M)  ' , AM2 , AM2 , S , C , MESH )
        ENDIF
        CALL OM( 'M=M+CN  ' , AM2 , CM2 , S , TETAU , MESH )
        CALL OS( 'X=X+Y   ' , X=T1 , Y=UN )
        CALL OS( 'X=X+Y   ' , X=T2 , Y=VN )
!
!------ FINITE VOLUMES SCHEME --------------------------------------
!
!     NOTE: HERE THE CONTINUITY EQUATION IS NOT SOLVED
!           BY H, HN AND UCONV,VCONV (UCONV, VCONV HAVE BEEN
!           UPDATED AND H, HN ARE STILL UNCHANGED, SO THE FINAL H
!           COMPUTED IN CVTRVF WILL NOT BE THE FINAL DEPTH OF THE
!           TIMESTEP).
!
      ELSEIF(ICONVF(1).EQ.ADV_LPO.OR.
     &       ICONVF(1).EQ.ADV_NSC.OR.
     &       ICONVF(1).EQ.ADV_PSI     ) THEN
!
        IF(ICONVF(1).EQ.ADV_LPO.OR.ICONVF(1).EQ.ADV_NSC) IOPT=2
        IF(ICONVF(1).EQ.ADV_PSI) IOPT=3
!       HERE YASMH=.FALSE. (SOURCES ACCOUNTED FOR IN FU)
        IF(TB%N.LT.22) THEN
          WRITE(LU,*) 'SIZE OF TB TOO SMALL IN PROPAG'
          CALL PLANTE(1)
          STOP
        ENDIF
        CALL CVTRVF(T1,UN,S,.FALSE.,.TRUE.,H,HN,
     &              HPROP,UCONV,VCONV,S,S,
     &              1,S,S,FU,S,.FALSE.,S,.FALSE.,UBOR,MASK,MESH,
     &              TB%ADR(13)%P,TB%ADR(14)%P,TB%ADR(15)%P,
     &              TB%ADR(16)%P,TB%ADR(17)%P,TB%ADR(18)%P,
     &              TB%ADR(19)%P,TB%ADR(20)%P,TB%ADR(21)%P,
     &              TB%ADR(22)%P,AGGLOH,TE1,DT,INFOGR,BILMAS,
     &              1,MSK,MASKEL,S,C,1,LIMPRO%I(1+DIMLIM:2*DIMLIM),
     &              KDIR,3,MESH%NPTFR,FLBOR,.FALSE.,
     &              V2DPAR,UNSV2D,IOPT,TB%ADR(12)%P,MASKPT)
        CALL CVTRVF(T2,VN,S,.FALSE.,.TRUE.,H,HN,
     &              HPROP,UCONV,VCONV,S,S,
     &              1,S,S,FV,S,.FALSE.,S,.FALSE.,VBOR,MASK,MESH,
     &              TB%ADR(13)%P,TB%ADR(14)%P,TB%ADR(15)%P,
     &              TB%ADR(16)%P,TB%ADR(17)%P,TB%ADR(18)%P,
     &              TB%ADR(19)%P,TB%ADR(20)%P,TB%ADR(21)%P,
     &              TB%ADR(22)%P,AGGLOH,TE1,DT,INFOGR,BILMAS,
     &              1,MSK,MASKEL,S,C,1,LIMPRO%I(1+2*DIMLIM:3*DIMLIM),
     &              KDIR,3,MESH%NPTFR,FLBOR,.FALSE.,
     &              V2DPAR,UNSV2D,IOPT,TB%ADR(12)%P,MASKPT)
        IF(IELMU.NE.11) THEN
          CALL CHGDIS(T1,11,IELMU,MESH)
          CALL CHGDIS(T2,11,IELMU,MESH)
        ENDIF
!
!------ SCHEMA VOLUMES FINIS AVEC BANCS DECOUVRANTS -------------------
!
!     NOTE: HERE THE CONTINUITY EQUATION IS NOT SOLVED
!           BY H, HN AND UCONV,VCONV (UCONV, VCONV HAVE BEEN
!           UPDATED AND H, HN ARE STILL UNCHANGED, SO THE FINAL H
!           COMPUTED IN CVTRVF WILL NOT BE THE FINAL DEPTH OF THE
!           TIMESTEP).
!
      ELSEIF(ICONVF(1).EQ.ADV_LPO_TF.OR.
     &       ICONVF(1).EQ.ADV_NSC_TF.OR.
     &       ICONVF(1).EQ.ADV_PSI_TF     ) THEN
!
        IF(ICONVF(1).EQ.ADV_LPO_TF) IOPT=2
        IF(ICONVF(1).EQ.ADV_NSC_TF) IOPT=2
        IF(ICONVF(1).EQ.ADV_PSI_TF) IOPT=3
!       HERE YASMH=.FALSE. (SOURCES ACCOUNTED FOR IN FU)
        IF(TB%N.LT.22) THEN
          WRITE(LU,*) 'SIZE OF TB TOO SMALL IN PROPAG'
          CALL PLANTE(1)
          STOP
        ENDIF
!       THIS IS EQUIVALENT TO TWO SUCCESSIVE CALLS TO CVTRVF_POS
!       FOR U AND V
        CALL CVTRVF_POS_2(T1,UN,S,T2,VN,S,.FALSE.,.TRUE.,H,HN,
     &      HPROP,UCONV,VCONV,S,S,
     &      1,S,S,FU,FV,S,.FALSE.,S,S,.FALSE.,UBOR,VBOR,MASK,MESH,
     &      TB%ADR(13)%P,TB%ADR(14)%P,TB%ADR(15)%P,
     &      TB%ADR(16)%P,TB%ADR(17)%P,TB%ADR(18)%P,
     &      TB%ADR(19)%P,TB%ADR(20)%P,TB%ADR(21)%P,
     &      TB%ADR(22)%P,
     &      AGGLOH,TE1,DT,INFOGR,BILMAS,1,MSK,MASKEL,S,C,1,
     &      LIMPRO%I(1+DIMLIM:2*DIMLIM),
     &      LIMPRO%I(1+2*DIMLIM:3*DIMLIM),
     &      KDIR,3,MESH%NPTFR,FLBOR,.FALSE.,
     &      V2DPAR,UNSV2D,IOPT,TB%ADR(11)%P,TB%ADR(12)%P,MASKPT,
     &      MESH%GLOSEG%I(                 1:  MESH%GLOSEG%DIM1),
     &      MESH%GLOSEG%I(MESH%GLOSEG%DIM1+1:2*MESH%GLOSEG%DIM1),
     &      MESH%NBOR%I,2,FLULIM%R,YAFLULIM)
!                       2: HARDCODED OPTION
!
        IF(IELMU.NE.11) THEN
          CALL CHGDIS(T1,11,IELMU,MESH)
          CALL CHGDIS(T2,11,IELMU,MESH)
        ENDIF
!
!-----------------------------------------------------------------
!
      ELSE
!
        IF(LNG.EQ.1) WRITE(LU,2002) ICONVF(1)
        IF(LNG.EQ.2) WRITE(LU,2003) ICONVF(1)
2002    FORMAT(1X,'PROPAG : FORME DE LA CONVECTION DE U INCONNUE :',1I6)
2003    FORMAT(1X,'PROPAG : UNKNOWN TYPE OF ADVECTION FOR U: ',1I6)
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
! ADDS THE TERM AM3 * T1
! HERE AM3 MUST BE MASS/DT POSSIBLY WITH MASS-LUMPING ON U
!
      IF(SOLSYS.EQ.1) THEN
        CALL MATVEC( 'X=X+AY  ',CV2,AM3,T1,C,MESH)
        CALL MATVEC( 'X=X+AY  ',CV3,AM3,T2,C,MESH)
      ELSEIF(SOLSYS.EQ.2) THEN
        CALL OS('X=X+YZ  ',X=CV2,Y=AM3%D,Z=T1)
        CALL OS('X=X+YZ  ',X=CV3,Y=AM3%D,Z=T2)
      ENDIF
!
!  END OF ADVECTION OF U AND V
!
!=======================================================================
!
!
!     COMPUTES THE DIAGONAL MATRICES: - FU* (MASS OF THE BASES)
!                                AND: - FV* (MASS OF THE BASES)
!
      IF(KFROT.NE.0.OR.VERTIC) THEN
!
!       T3,T4 : BOTTOM FRICTION      T5,T6 : VERTICAL STRUCTURES
!
        CALL FRICTI(T3,T4,T5,T6,UN,VN,HN,CF,MESH,T1,T2,VERTIC,
     &              UNSV2D,MSK,MASKEL,HFROT)
!
!       COMPUTES THE DIAGONAL MATRICES: - FU* (MASS OF THE BASES)
!                                  AND: - FV* (MASS OF THE BASES)
!
        CALL SLOPES(TE3,ZF,MESH)
        CALL VECTOR(T2,'=','MASBAS          ',IELMU,
     &              -1.D0,S,S,S,S,S,S,MESH,.TRUE.,TE3)
!
        CALL OS( 'X=XY    ' , X=T3 , Y=T2 )
        CALL OS( 'X=XY    ' , X=T4 , Y=T2 )
!
        IF(VERTIC) THEN
          CALL VECTOR(T2,'=','MASBAS          ',IELMU,
     &              -1.D0,S,S,S,S,S,S,MESH,.FALSE.,TE3)
          CALL OS( 'X=XY    ' , T5 , T2 , S , C )
          CALL OS( 'X=XY    ' , T6 , T2 , S , C )
          CALL OS( 'X=X+Y   ' , T3 , T5 , S , C )
          CALL OS( 'X=X+Y   ' , T4 , T6 , S , C )
        ENDIF
!
      ELSE
!
        CALL CPSTVC(U,T3)
        CALL CPSTVC(V,T4)
        CALL OS( 'X=0     ' , X=T3 )
        CALL OS( 'X=0     ' , X=T4 )
!
        IF(OPTBAN.EQ.1) THEN
!         SLOWING DOWN VELOCITIES ON TIDAL FLATS
!         HAPPENS WHEN CALLED BY TELEMAC-3D WITH OPTT2D=1
          IF(IELMU.NE.IELMH) THEN
            CALL VECTOR(T2,'=','MASBAS          ',IELMU,
     &                  1.D0,S,S,S,S,S,S,MESH,.FALSE.,TE3)
            IF(NCSIZE.GT.1) CALL PARCOM(T2,2,MESH)
            CALL OS('X=Y     ',X=T5,Y=HPROP)
            IF(T5%ELM.NE.IELMU) CALL CHGDIS(T5,T5%ELM,IELMU,MESH)
            DO I=1,U%DIM1
!             HIDDEN PARAMETER
              IF(T5%R(I).LT.1.D-3) THEN
                T3%R(I)=10.D0*T2%R(I)/DT
                T4%R(I)=T3%R(I)
              ENDIF
            ENDDO
          ELSE
            DO I=1,U%DIM1
!             HIDDEN PARAMETER
              IF(HPROP%R(I).LT.1.D-3) THEN
                T3%R(I)=10.D0*V2DPAR%R(I)/DT
                T4%R(I)=T3%R(I)
              ENDIF
            ENDDO
          ENDIF
        ENDIF
!
      ENDIF
!
!=======================================================================
!
!   COMPUTES THE MATRICES
!
!    AM1: ALREADY COMPUTED
!
!    AM2 = AM2 + TM1
!
      IF(DIFVIT) THEN
!
!    TEST: IMPLICITATION OF TM1 DIAGONAL OF TM1 IN WAVE EQUATION
!
!
        IF(SOLSYS.EQ.2) THEN
!
          CALL OS('X=X+CY  ',X=AM2%D,Y=TM1%D,C=TETAD)
          CALL OS('X=CX    ',X=TM1%D,C=1.D0-TETAD)
!
          CALL MATVEC( 'X=X+CAY ',CV2,TM1,UN,-1.D0,MESH)
          CALL MATVEC( 'X=X+CAY ',CV3,TM1,VN,-1.D0,MESH)
!
        ELSEIF(SOLSYS.EQ.1) THEN
!
          IF(TETAD.LT.0.9999D0) THEN
            IF(TETAD.GT.0.0001D0) THEN
              IF(AM2%TYPEXT.EQ.'S'.AND.TM1%TYPEXT.EQ.'Q') THEN
                CALL OM( 'M=X(M)  ' , AM2 , AM2 , S , C , MESH )
              ENDIF
              CALL OM( 'M=M+CN  ' , AM2 , TM1 , S , TETAD , MESH )
            ENDIF
!           EXPLICIT PART :
            CALL MATVEC( 'X=X+CAY ',CV2,TM1,UN,TETAD-1.D0,MESH)
            CALL MATVEC( 'X=X+CAY ',CV3,TM1,VN,TETAD-1.D0,MESH)
          ELSE
!           ENTIRELY IMPLICIT
            IF(AM2%TYPEXT.EQ.'S'.AND.TM1%TYPEXT.EQ.'Q') THEN
              CALL OM( 'M=X(M)  ' , AM2 , AM2 , S , C , MESH )
            ENDIF
            CALL OM( 'M=M+N   ' , AM2 , TM1 , S , C , MESH )
          ENDIF
!
        ELSE
!
          IF(LNG.EQ.1) WRITE(LU,*) 'PROPAG : MAUVAIS CHOIX POUR SOLSYS'
          IF(LNG.EQ.2) WRITE(LU,*) 'PROPAG : WRONG CHOICE FOR SOLSYS'
          CALL PLANTE(1)
          STOP
!
        ENDIF
!
      ENDIF
!
!    AM3 = AM2 (DIFFUSION HAS BEEN ADDED TO AM2, NOT TO AM3)
!
      IF(SOLSYS.EQ.1) THEN
        CALL OM( 'M=N     ' , AM3 , AM2 , S , C , MESH )
      ELSEIF(SOLSYS.EQ.2) THEN
        CALL OS('X=Y     ',X=AM3%D,Y=AM2%D)
      ENDIF
!
!=======================================================================
!
!   DEFINA METHOD CORRECTED : RIGHT HAND SIDE MODIFIED
!
!     TM1 IS DONE AS AM1, BUT WITH TE4 INSTEAD OF TE5
!
      IF(OPTBAN.EQ.3) THEN
        SL1 = 1.D0 / DT
!       LOCALLY LUMPED MASS MATRIX (TIDAL FLATS)
        FORMUL='MSLUMP          '
        CALL MATRIX(TM1,'M=N     ',FORMUL,IELMH,IELMH,
     &              SL1,TE3,S,S,S,S,S,MESH,.TRUE.,TE4)
!       MASS-LUMPING :
        IF(AGGLOH.GT.0.001D0) THEN
          CALL LUMP(T1,TM1,MESH,AGGLOH)
          CALL OM( 'M=CN    ' , TM1 , TM1 , S , 1.D0-AGGLOH , MESH )
          CALL OM( 'M=M+D   ' , TM1 , TM1 , T1 , C          , MESH )
        ENDIF
        CALL MATVEC('X=X+AY  ',CV1,TM1,HN,C,MESH)
      ENDIF
!
!=======================================================================
!
!  TAKES THE IMPLICIT SOURCE TERMS INTO ACCOUNT:
!
      CALL OM( 'M=M+D   ' , AM2,AM2 , T3 , C , MESH )
      CALL OM( 'M=M+D   ' , AM3,AM3 , T4 , C , MESH )
!
!=======================================================================
!
!
!  BOUNDARY TERMS
!
!     PARALLEL MODE : SUBDOMAINS MAY HAVE NO BOUNDARY POINT AT ALL
!
      IF(MESH%NPTFR.GT.0) THEN
!
!  TAKES INTO ACCOUNT THE TERMS SUM(PSI H(N) U(N). N) AT THE BOUNDARY
!  THESE TERMS SHOULD NOT BE TAKEN INTO ACCOUNT ON SOLID BOUNDARIES,
!  HENCE THE USE OF MASK(*, 8) WHICH IS 0 FOR SEGMENTS OF TYPE KLOG.
!
!
      CALL VECTOR(FLBOR,'=','FLUBDF          ',IELBOR(IELMH,1),
     &            1.D0-TETAU,HPROP,S,S,UN,VN,S,
     &            MESH,.TRUE.,MASK%ADR(UNONNEU)%P)
!
!-----------------------------------------------------------------------
!
!  TAKES INTO ACCOUNT THE TERMS  SUM(PSI HN U(N+1) . N ) AT THE BOUNDARY
!
!  DIRICHLET CONDITIONS : U(N+1) = UBOR ; V(N+1) = VBOR
!
!  UDIR : 1 FOR A DIRICHLET SEGMENT FOR U, 0 OTHERWISE
!
      CALL VECTOR(FLBOR,'+','FLUBDF          ',IELBOR(IELMH,1),
     &            TETAU,HPROP,S,S,UBOR,VBOR,S,
     &            MESH,.TRUE.,MASK%ADR(UDIR)%P)
!
!  TAKES INTO ACCOUNT THE TERMS  SUM(PSI HN U(N+1) . N ) AT THE BOUNDARY
!
!  FREE EXIT CONDITIONS
!
!  UDDL : 1 FOR A FREE EXIT SEGMENT FOR U, 0 OTHERWISE
!
      CALL VECTOR(FLBOR,'+','FLUBDF          ',IELBOR(IELMH,1),
     &            TETAU,HPROP,S,S,UN,VN,S,
     &            MESH,.TRUE.,MASK%ADR(UDDL)%P)
!
!     WITH POROSITY
!
      IF(OPTBAN.EQ.3) THEN
        DO I=1,MESH%NPTFR
          FLBOR%R(I)=FLBOR%R(I)*TE5%R(MESH%NELBOR%I(I))
        ENDDO
      ENDIF
!
!     EQUALITY OF FLUXES ON EITHER SIDE OF A WEIR
!     (WILL NOT WORK IN PARALLEL BUT WEIRS DON'T WORK IN
!      PARALLEL ANYWAY)
!
      IF(NWEIRS.GT.0) THEN
        DO N=1,NWEIRS
          DO I=1,NPSING(N)
            I1=NUMDIG(1,N,I)
            I2=NUMDIG(2,N,I)
            FLBOR%R(I1)=(FLBOR%R(I1)-FLBOR%R(I2))*0.5D0
            FLBOR%R(I2)=-FLBOR%R(I1)
          ENDDO
        ENDDO
      ENDIF
!
!     BOUNDARY TERMS IN THE RIGHT HAND SIDE
!
      CALL OSDB( 'X=X-Y   ' , CV1 , FLBOR , FLBOR , C , MESH )
!
!  TAKES INTO ACCOUNT THE TERMS  SUM(PSI HN U(N+1) . N ) AT THE BOUNDARY
!  HOND : 1 FOR THE INCIDENT WAVE SEGMENTS, 0 OTHERWISE
!
      CALL INCIDE(COTOND,HN,C0,PATMOS,ATMOS,ZF,MESH,
     &            LT,AT,GRAV,ROEAU,PRIVE)
!
      CALL CPSTVC(COTOND,T5)
      CALL CPSTVC(T5,T6)
      CALL CPSTVC(T5,T2)
!  COMPUTES CPROP (T5) AND CN (T2)
      CALL OSBD( 'X=CY    ' , T5 , HPROP , S , GRAV , MESH )
      CALL OS  ( 'X=+(Y,C)' , T5 , T5    , S , 0.D0        )
      CALL OS  ( 'X=SQR(Y)' , T5 , T5    , S , C           )
      CALL OSBD( 'X=CY    ' , T2 , HN    , S , GRAV , MESH )
      CALL OS  ( 'X=+(Y,C)' , T2 , T2    , S , 0.D0        )
      CALL OS  ( 'X=SQR(Y)' , T2 , T2    , S , C           )
!
      CALL OS  ( 'X=Y-Z   ' , T6 , T2    , C0     , C      )
      CALL OSBD( 'X=CXY   ' , T6 , HPROP , S      , -2.D0 , MESH )
      CALL OS  ( 'X=X+YZ  ' , T6 , T5    , COTOND , C      )
!
      CALL VECTOR(T2,'=','MASVEC          ',IELBOR(IELMH,1),
     &            1.D0,T6,S,S,S,S,S,MESH,.TRUE.,MASK%ADR(HOND)%P)
      IF(OPTBAN.EQ.3) THEN
        DO I=1,MESH%NPTFR
          T2%R(I)=T2%R(I)*TE5%R(MESH%NELBOR%I(I))
          T5%R(I)=T5%R(I)*TE5%R(MESH%NELBOR%I(I))
        ENDDO
      ENDIF
      CALL OSDB( 'X=X+Y   ' , CV1 , T2 , S , C , MESH )
!
!  IMPLICIT INCIDENT WAVE : ADDS TERMS TO THE MATRIX AM1
!  MASK(MSK7): 1 FOR INCIDENT WAVE SEGMENTS, 0 OTHERWISE
!
      CALL MATRIX(MBOR,'M=N     ','FMATMA          ',
     &            IELBOR(IELMH,1),IELBOR(IELMH,1),
     &            1.D0,T5,S,S,S,S,S,
     &            MESH,.TRUE.,MASK%ADR(HOND)%P)
      CALL OM( 'M=M+N   ' , AM1 , MBOR , S , C , MESH )
!
!     END OF: IF(MESH%NPTFR.GT.0) THEN
      ENDIF
!
! END OF BOUNDARY TERMS
!
!-----------------------------------------------------------------------
!
      IF(EQUA(1:10).EQ.'BOUSSINESQ') THEN
!
!       TAKES BOUSSINESQ TERMS INTO ACCOUNT
!
        CALL ROTNE0(MESH,CM1,
     &              AM2,A23,A32,AM3,CV2,CV3,UN,VN,H0,MSK,MASKEL,S,DT)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!  GRADIENT MATRICES
!
!     NOT USED WITH WAVE EQUATION
      IF(SOLSYS.EQ.1) THEN
!
      CALL MATRIX(CM1,'M=N     ','MATGRA         X',IELMU,IELMH,
     &            TETAH*GRAV,S,S,S,S,S,S,MESH,MSK,MASKEL)
      CALL MATRIX(CM2,'M=N     ','MATGRA         Y',IELMU,IELMH,
     &            TETAH*GRAV,S,S,S,S,S,S,MESH,MSK,MASKEL)
!
      ENDIF
!
!=======================================================================
!
! INITIAL GUESS
!
! FOR NOW U AND V ARE NOT MODIFIED, WHICH MEANS THAT U AND V STILL
! HOLD THE RESULT OF THE LAST SOLVED SYSTEM
!
      IF(IORDRH.EQ.0) THEN
!
        CALL OS( 'X=0     ' , X=DH )
!
      ELSEIF(IORDRH.EQ.1) THEN
!
        IF(LT.EQ.1.AND.ISOUSI.EQ.1) THEN
          CALL OS( 'X=0     ' , X=DH )
        ENDIF
!
      ELSEIF(IORDRH.EQ.2) THEN
!
        IF(LT.EQ.1.AND.ISOUSI.EQ.1) THEN
          CALL OS( 'X=0     ' , X=DH )
          CALL OS( 'X=0     ' , X=DHN)
        ENDIF
        IF (LT.GT.2) CALL OS( 'X=CX    ' , DH , S , S , 2.D0 )
        CALL OS( 'X=X-Y   ' , DH , DHN , S , C )
!       STORES DH(N) IN DH(N-1)
        CALL OS( 'X=X+Y   ' , DHN , DH   , S , C     )
        CALL OS( 'X=CX    ' , DHN , DHN  , S , 0.5D0 )
!
      ELSE
!
        IF(LNG.EQ.1) WRITE(LU,30) IORDRH
        IF(LNG.EQ.2) WRITE(LU,31) IORDRH
30      FORMAT(1X,'PROPAG : IORDRH=',1I6,' VALEUR NON PREVUE')
31      FORMAT(1X,'PROPAG : IORDRH=',1I6,' VALUE OUT OF RANGE')
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
      IF(IORDRU.EQ.0) THEN
!
        CALL OS( 'X=0     ' , X=U )
        CALL OS( 'X=0     ' , X=V )
!
      ELSEIF(IORDRU.EQ.1) THEN
!
!       U = UN AND V = VN ALREADY DONE
!
      ELSEIF(IORDRU.EQ.2) THEN
!
        IF(LT.EQ.1.AND.ISOUSI.EQ.1) THEN
          CALL OS( 'X=0     ' , X=DU )
          CALL OS( 'X=0     ' , X=DV )
        ENDIF
        IF(ISOUSI.EQ.1) THEN
          CALL OS( 'X=Y+Z   ' , X=U , Y=UN , Z=DU )
          CALL OS( 'X=Y+Z   ' , X=V , Y=VN , Z=DV )
        ENDIF
!
      ELSE
!
        IF(LNG.EQ.1) WRITE(LU,32) IORDRU
        IF(LNG.EQ.2) WRITE(LU,33) IORDRU
32      FORMAT(1X,'PROPAG : IORDRU=',1I6,' VALEUR NON PREVUE')
33      FORMAT(1X,'PROPAG : IORDRU=',1I6,' VALUE OUT OF RANGE')
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
!=======================================================================
!
      IF(SOLSYS.EQ.2) THEN
!
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM(AM2%D,2,MESH)
          CALL PARCOM(AM3%D,2,MESH)
        ENDIF
!       INVERSION OF AM2%D AND AM3%D (WILL BE USED AGAIN AT A LATER STAGE)
        CALL OS( 'X=1/Y   ' , AM2%D , AM2%D , AM2%D , C ,2,0.D0,1.D-6)
        CALL OS( 'X=1/Y   ' , AM3%D , AM3%D , AM3%D , C ,2,0.D0,1.D-6)
!
!       ADDS THE "DIFFUSION" MATRIX TO AM1
!
!       HERE AM2%D HAS ALREADY BEEN INVERSED
        IF(IELMH.EQ.IELMU) THEN
!         WANT TO DIVIDE BY (1/DT + FROT) WHICH IS IN AM2%D EXCEPT
!         THAT IT IS PROJECTED ON THE BASES (IN AM2%D); THEREFORE HAS
!         TO MULTIPLY BY THE MASS OF THE BASES
          CALL OS('X=CYZ   ',X=DM1,Y=V2DPAR,Z=AM2%D,C=-TETAU*TETAH*GRAV)
        ELSE
!         TAKE HERE THE MASS OF THE BASES FOR U
          CALL VECTOR(T4,'=','MASBAS          ',IELMU,
     &                1.D0,S,S,S,S,S,S,MESH,.FALSE.,TE3)
          IF(NCSIZE.GT.1) CALL PARCOM(T4,2,MESH)
          CALL OS('X=CYZ   ',X=DM1,Y=T4,Z=AM2%D,C=-TETAU*TETAH*GRAV)
          CALL CHGDIS(DM1,IELMU,IELMH,MESH)
        ENDIF
!
        CALL MATRIX(AM1,'M=M+N   ','MATDIFUV        ',IELMH,IELMH,
     &              -1.D0,S,S,S,DM1,HPROP,S,MESH,MSK,MASKEL)
!
!       NEW SECOND MEMBER CV1
!
        IF(ABS(TETAZCOMP-1.D0).LT.1.D-6) THEN
          CALL OS( 'X=YZ    ' , X=T2 , Y=CV2 , Z=AM2%D )
          CALL OS( 'X=YZ    ' , X=T3 , Y=CV3 , Z=AM3%D )
        ELSE
          CALL OS( 'X=Y     ' , X=T4 , Y=CV2 )
          CALL OS( 'X=Y     ' , X=T5 , Y=CV3 )
!         FREE SURFACE GRADIENT
          IF(OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
            CALL VECTOR(T4,'+','GRADF          X',IELMU,
     &      (1.D0-TETAZCOMP)*GRAV,ZFLATS,S,S,S,S,S,MESH,MSK,MASKEL)
            CALL VECTOR(T5,'+','GRADF          Y',IELMU,
     &      (1.D0-TETAZCOMP)*GRAV,ZFLATS,S,S,S,S,S,MESH,MSK,MASKEL)
          ELSE
            CALL VECTOR(T4,'+','GRADF          X',IELMU,
     &      (1.D0-TETAZCOMP)*GRAV,T8,S,S,S,S,S,MESH,MSK,MASKEL)
            CALL VECTOR(T5,'+','GRADF          Y',IELMU,
     &      (1.D0-TETAZCOMP)*GRAV,T8,S,S,S,S,S,MESH,MSK,MASKEL)
          ENDIF
          CALL OS( 'X=YZ    ' , X=T2 , Y=T4 , Z=AM2%D )
          CALL OS( 'X=YZ    ' , X=T3 , Y=T5 , Z=AM3%D )
        ENDIF
!
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM(T2,2,MESH)
          CALL PARCOM(T3,2,MESH)
        ENDIF
!
!       TAKES THE BOUNDARY CONDITIONS INTO ACCOUNT
!       ERROR IN GRAD(DH)
        DO I=1,MESH%NPTFR
          IF(LIMPRO%I(I+DIMLIM).EQ.KDIR) THEN
            T2%R(MESH%NBOR%I(I)) = UBOR%R(I)
          ENDIF
          IF(LIMPRO%I(I+2*DIMLIM).EQ.KDIR) THEN
            T3%R(MESH%NBOR%I(I)) = VBOR%R(I)
          ENDIF
        ENDDO
!
!       REMEMBER THAT COEFFICIENT TETAU IS IN BM1 AND BM2
!       AND THAT SUPG UPWINDING IS ALSO IN BM1 AND BM2
!       OTHERWISE COULD BE INCLUDED IN HUGRADP BELOW
        CALL MATVEC('X=X-AY  ',CV1,BM1,T2,C,MESH)
        CALL MATVEC('X=X-AY  ',CV1,BM2,T3,C,MESH)
!
        IF(ABS(TETAZCOMP-1.D0).GT.1.D-6) THEN
          FORMUL='HUGRADP3        '
!                        3: U AND V, HERE T2 AND T3 NOT TAKEN
          CALL OS('X=CY    ',X=T1,Y=DM1,
     &                       C=(1.D0-TETAZCOMP)/TETAH/TETAU)
          IF(OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
            CALL VECTOR(CV1,'+',FORMUL,IELMH,TETAU,
     &                  HPROP,T1,ZFLATS,T2,T3,T3,MESH,MSK,MASKEL)
          ELSE
            CALL VECTOR(CV1,'+',FORMUL,IELMH,TETAU,
     &                  HPROP,T1,T8    ,T2,T3,T3,MESH,MSK,MASKEL)
          ENDIF
        ENDIF
!
        CALL OS('X=CY    ',X=UDEL,Y=T2,C=TETAU)
        CALL OS('X=CY    ',X=VDEL,Y=T3,C=TETAU)
        CALL OS('X=X+CY  ',X=UDEL,Y=UN,C=1.D0-TETAU)
        CALL OS('X=X+CY  ',X=VDEL,Y=VN,C=1.D0-TETAU)
!
      ENDIF
!
!=======================================================================
!
!     AT THIS STAGE, A23 AND A32 EQUAL 0
!     THE MATRICES HAVE A VALUE ONLY AFTER A DIAGONAL-BLOCK
!     PRECONDITIONING OU WITH BOUSSINESQ
!
      IF(EQUA(1:10).NE.'BOUSSINESQ') THEN
        A23%TYPDIA='0'
        A32%TYPDIA='0'
        A23%TYPEXT='0'
        A32%TYPEXT='0'
      ENDIF
!
!=======================================================================
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!     IN ADJOINT MODE : THE SYSTEM IS NOT SOLVED, RETURN HERE
!
!
      IF(ADJO) RETURN
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!=======================================================================
!
!   DIRICHLET BOUNDARY CONDITIONS:
!
      IF(SOLSYS.EQ.1) THEN
!
        IF(CORCON.AND.NFRLIQ.GT.0) THEN
!
!         SAVES THE CONTINUITY EQUATION
          CALL OM( 'M=N     ' , TM1  , AM1 , S , C , MESH )
          CALL OM( 'M=N     ' , BM1S , BM1 , S , C , MESH )
          CALL OM( 'M=N     ' , BM2S , BM2 , S , C , MESH )
          CALL OS( 'X=Y     ' ,X=CV1S,Y=CV1)
!
        ENDIF
!
        CALL DIRICH(UNK,MAT,RHS,DIRBOR,LIMPRO%I,TB,MESH,KDIR,MSK,MASKPT)
!
      ENDIF
!
!  SOLVES THE OBTAINED SYSTEM:
!
!+++++++++++++++++++++++++++++++++++
!  SPECIAL PRECONDITIONING H-U     +
!+++++++++++++++++++++++++++++++++++
!
      IF(PRECCU) THEN
!
!     PREPARES THE DIAGONALS FOR PRECONDITIONING:
!
!     HTILD: D1 (MUST BE SIMPLIFIED BY GRAV THERE? )
      CALL OS('X=+(Y,C)' , X=HTILD , Y=HN , C=0.D0 )
      CALL OS('X=CX    ' , X=HTILD , C=4.D0/GRAV )
      CALL OS('X=SQR(Y)' , X=HTILD , Y=HTILD )
      CALL OS('X=+(Y,C)' , X=HTILD , Y=HTILD , C=2.D0/GRAV )
!     T1: D2 (NOT KEPT)
      CALL OS('X=1/Y   ' , X=T1 , Y=HTILD )
      CALL OS('X=CX    ' , X=T1 , C=4.D0*TETAH/TETAU )
!
!     MODIFIES THE SECOND MEMBER
!
      CALL OS('X=XY    ' , X=CV1 , Y=T1 )
!
!     MODIFIES THE VARIABLE DH
!
      CALL OS('X=Y/Z   ' , X=DH , Y=DH , Z=HTILD )
!
!     PRECONDITIONING FOR AM1
!
      IF(AM1%TYPEXT.EQ.'S') CALL OM( 'M=X(M)  ' , AM1,AM1 ,S,C,MESH )
      CALL OM( 'M=DM    ' , AM1 , AM1 , T1    , C , MESH )
      CALL OM( 'M=MD    ' , AM1 , AM1 , HTILD , C , MESH )
!
!     PRECONDITIONING FOR BM1 AND BM2 :
!
      CALL OM( 'M=DM    ' , BM1 , BM1 , T1 , C , MESH )
      CALL OM( 'M=DM    ' , BM2 , BM2 , T1 , C , MESH )
!
!     PRECONDITIONING FOR CM1 AND CM2 :
!
      CALL OM( 'M=MD    ' , CM1 , CM1 , HTILD , C , MESH )
      CALL OM( 'M=MD    ' , CM2 , CM2 , HTILD , C , MESH )
!
      ENDIF
!
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!  END OF SPECIAL PRECONDITIONING H-U                               +
!  EXCEPT FOR RECOVERY OF THE DH VARIABLE (SEE AFTER CALL TO SOLV09)+
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
!
      IF(SOLSYS.EQ.1) THEN
!
!       CLASSICAL METHOD
!
!       CASE OF THE BLOCK-DIAGONAL PRECONDITIONING
!       A23 AND A32 WILL BE USED, THEY ARE INITIALISED.
!       ALREADY DONE WITH COUPLED BOUSSINESQ
        IF(EQUA(1:10).NE.'BOUSSINESQ') THEN
          IF(3*(SLVPRO%PRECON/3).EQ.SLVPRO%PRECON) THEN
            A23%TYPDIA='Q'
            A32%TYPDIA='Q'
            A23%TYPEXT='Q'
            A32%TYPEXT='Q'
            CALL OM( 'M=0     ' , A23,A23 , S,C , MESH )
            CALL OM( 'M=0     ' , A32,A32 , S,C , MESH )
            IF (AM2%TYPEXT.EQ.'S') THEN
             CALL OM( 'M=X(M)  ' , AM2,AM2 , S,C , MESH )
            ENDIF
            IF (AM3%TYPEXT.EQ.'S') THEN
             CALL OM( 'M=X(M)  ' , AM3,AM3 , S,C , MESH )
            ENDIF
          ENDIF
        ENDIF
!
!       PRINT*,'DAM1=',DOTS(AM1%D,AM1%D)
!       PRINT*,'DAM2=',DOTS(AM2%D,AM2%D)
!       PRINT*,'DAM3=',DOTS(AM3%D,AM3%D)
!       PRINT*,'DBM1=',DOTS(BM1%D,BM1%D)
!       PRINT*,'DBM2=',DOTS(BM2%D,BM2%D)
!       PRINT*,'DCM1=',DOTS(CM1%D,CM1%D)
!       PRINT*,'DCM2=',DOTS(CM2%D,CM2%D)
!       PRINT*,'CV1=',DOTS(CV1,CV1)
!       PRINT*,'CV2=',DOTS(CV2,CV2)
!       PRINT*,'CV3=',DOTS(CV3,CV3)
!
        CALL SOLVE(UNK,MAT,RHS,TB,SLVPRO,INFOGR,MESH,TM1)
!
      ELSEIF(SOLSYS.EQ.2) THEN
!
!       GENERALISED WAVE EQUATION
!
!       SYSTEM IN H
!
!       STORES AM1 IN BM1 AND CV1 IN BM2%D
!
        IF(CORCON.AND.NFRLIQ.GT.0) THEN
          CALL OM('M=N     ',BM1,AM1,S,C,MESH)
          CALL OS('X=Y     ',X=BM2%D,Y=CV1)
        ENDIF
!
        CALL DIRICH(DH,AM1,CV1,HBOR,LIMPRO%I,TB,MESH,KDIR,MSK,MASKPT)
        CALL SOLVE(DH,AM1,CV1,TB,SLVPRO,INFOGR,MESH,TM1)
!
        NELEM=MESH%NELEM
        DO IELEM=1,NELEM
          ZCONV%R(IELEM        )=DH%R(MESH%IKLE%I(IELEM        ))
          ZCONV%R(IELEM+  NELEM)=DH%R(MESH%IKLE%I(IELEM+  NELEM))
          ZCONV%R(IELEM+2*NELEM)=DH%R(MESH%IKLE%I(IELEM+2*NELEM))
        ENDDO
        IF(ABS(1.D0-TETAZCOMP).GT.1.D-6) THEN
          C=(1.D0-TETAZCOMP)/TETAH
          IF(OPTBAN.EQ.1.OR.OPTBAN.EQ.3) THEN
!           FREE SURFACE PIECE-WISE LINEAR IN ZFLATS
            CALL OS('X=X+CY  ',X=ZCONV,Y=ZFLATS,C=C)
          ELSE
!           FREE SURFACE LINEAR
            DO IELEM=1,NELEM
              I1=MESH%IKLE%I(IELEM        )
              I2=MESH%IKLE%I(IELEM+  NELEM)
              I3=MESH%IKLE%I(IELEM+2*NELEM)
              ZCONV%R(IELEM        )=ZCONV%R(IELEM        )+
     &        C*(T8%R(I1))
              ZCONV%R(IELEM+  NELEM)=ZCONV%R(IELEM+  NELEM)+
     &        C*(T8%R(I2))
              ZCONV%R(IELEM+2*NELEM)=ZCONV%R(IELEM+2*NELEM)+
     &        C*(T8%R(I3))
            ENDDO
          ENDIF
        ENDIF
!
!       SYSTEMS IN U AND V
!
        CALL VECTOR(CV2,'+','GRADF          X',IELMU,
     &              -GRAV*TETAH,DH,S,S,S,S,S,MESH,MSK,MASKEL)
        CALL VECTOR(CV3,'+','GRADF          Y',IELMU,
     &              -GRAV*TETAH,DH,S,S,S,S,S,MESH,MSK,MASKEL)
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM(CV2,2,MESH)
          CALL PARCOM(CV3,2,MESH)
        ENDIF
!                                      AM2%D AND AM3%D ALREADY INVERSED
        CALL OS('X=YZ    ',X=U,Y=CV2,Z=AM2%D)
        CALL OS('X=YZ    ',X=V,Y=CV3,Z=AM3%D)
!
        DO I=1,MESH%NPTFR
          IF(LIMPRO%I(I+DIMLIM).EQ.KDIR) THEN
            U%R(MESH%NBOR%I(I)) = UBOR%R(I)
          ENDIF
          IF(LIMPRO%I(I+2*DIMLIM).EQ.KDIR) THEN
            V%R(MESH%NBOR%I(I)) = VBOR%R(I)
          ENDIF
        ENDDO
!
!       FINAL CORRECTION OF BOUNDARY FLUXES FOR ELEVATION IMPOSED
!       BOUNDARIES (TO SOLVE THE CONTINUITY EQUATION)
!
        IF(CORCON.AND.NFRLIQ.GT.0) THEN
          CALL MATVEC('X=X+CAY ',BM2%D,BM1,DH,-1.D0,MESH)
          DO I=1,MESH%NPTFR
            IF(LIMPRO%I(I).EQ.KDIR) THEN
              FLBOR%R(I)=FLBOR%R(I)+BM2%D%R(MESH%NBOR%I(I))
            ENDIF
          ENDDO
        ENDIF
!
      ENDIF
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! SPECIAL PRECONDITIONING H-U : RECOVERY OF THE DH VARIABLE
!
      IF(PRECCU) CALL OS('X=XY    ' , X=DH , Y=HTILD )
!
      IF(CORCON.AND.SOLSYS.EQ.1.AND.NFRLIQ.GT.0) THEN
!
!       FINAL CORRECTION OF BOUNDARY FLUXES FOR ELEVATION IMPOSED
!       BOUNDARIES (TO SOLVE THE CONTINUITY EQUATION)
!
        CALL MATVEC('X=X+CAY ',CV1S,TM1,DH,-1.D0,MESH)
        CALL MATVEC('X=X+CAY ',CV1S,BM1S,U,-1.D0,MESH)
        CALL MATVEC('X=X+CAY ',CV1S,BM2S,V,-1.D0,MESH)
        DO I=1,MESH%NPTFR
          IF(LIMPRO%I(I).EQ.KDIR) THEN
            FLBOR%R(I)=FLBOR%R(I)+CV1S%R(MESH%NBOR%I(I))
          ENDIF
        ENDDO
      ENDIF
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
!  FROM DH TO H
!
      CALL OS( 'X=Y+Z   ' , X=H , Y=DH , Z=HN )
!
!  HBOR = HBOR + HN
!  HBOR IS USED AGAIN IN SUB-ITERATIONS
!
      CALL OSBD( 'X=X+Y   ' , HBOR , HN , S , C , MESH )
!
!  STORES THE RELATIVE CHANGE IN SPEEDS
!
      IF(IORDRU.EQ.2) THEN
        CALL OS( 'X=Y-Z   ' , X=DU , Y=U , Z=UN )
        CALL OS( 'X=Y-Z   ' , X=DV , Y=V , Z=VN )
      ENDIF
!
!  COMPATIBLE VELOCITY FIELD IN CONTINUITY EQUATION
!
      IF(SOLSYS.EQ.1) THEN
        CALL OS ('X=CY    ',X=UDEL,Y=U ,C=     TETAU)
        CALL OS ('X=CY    ',X=VDEL,Y=V ,C=     TETAU)
        CALL OS ('X=X+CY  ',X=UDEL,Y=UN,C=1.D0-TETAU)
        CALL OS ('X=X+CY  ',X=VDEL,Y=VN,C=1.D0-TETAU)
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END