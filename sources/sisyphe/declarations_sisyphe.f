!                    ***************************
                     MODULE DECLARATIONS_SISYPHE
!                    ***************************
!
!
!***********************************************************************
! SISYPHE   V7P1
!***********************************************************************
!
!brief    DECLARATION OF PRINCIPAL SISYPHE VARIABLES
!
!history  CV
!+        15/03/2009
!+
!+   ADDED VARIABLES MU, KS, KSP, KSR
!+
!+   VITCE AND VITCD ARE CONSTANT
!
!history  JMH
!+        13/08/2009
!+
!+   IT5 DELETED
!
!history  CV+RK+UW
!+        15/03/2011
!+
!+   ADDED VARIABLES MPM_ARRAY, MPM, MOFAC,ALPHA
!+
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
!history  MAK (HRW)
!+        01/01/2012
!+        V6P2
!+   CHANGE create parameter for ratio depth averaged and reference concentration.
!+   CSRATIO
!
!history  JWI (HRW)
!+        31/05/2012
!+        V6P2
!+ added lines to include wave orbital velocities
!+ TYPE(BIEF_OBJ), TARGET :: DEL_UW
!
!history  CV (EDF)
!+        30/07/2012
!+        V6P2
!+ added new variable ZFCL_MS 
!
!history  Pablo Tassi PAT (EDF-LNHE)
!+        12/02/2013
!+        V6P3
!+ Preparing for the use of a higher NSICLM value
!+ (by Rebekka Kopmann)
!
!history  Pablo Tassi PAT (EDF-LNHE)
!+        12/02/2013
!+        V6P3
!+ Settling lag: determines choice between Rouse and Miles concentration profile
!+ (by Michiel Knaapen HRW)
!
!history  J-M HERVOUET (EDF-LAB, LNHE)
!+        11/09/2015
!+        V7P1
!+ Arrays of size MAXFRO now allocatable. 
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
!
!       NOTE: THIS MODULE IS ORGANISED IN 10 PARTS
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF_DEF
!
!       NOTE: THIS MODULE IS ORGANISED IN 10 PARTS
!
!       1) VECTORS (WILL BE DECLARED AS BIEF_OBJ STRUCTURES)
!       2) MATRICES (WILL BE DECLARED AS BIEF_OBJ STRUCTURES)
!       3) BLOCKS (WILL BE DECLARED AS BIEF_OBJ STRUCTURES)
!       4) INTEGERS
!       5) LOGICAL VALUES
!       6) REALS
!       7) STRINGS
!       8) SLVCFG STRUCTURES
!       9) MESH STRUCTURE
!      10) ALIASES
!
!-----------------------------------------------------------------------
!
!       1) VECTORS
!
!-----------------------------------------------------------------------
!
!     EVOLUTION
!
      TYPE(BIEF_OBJ), TARGET :: E
!
!     EVOLUTION SAVED FOR CONSTANT FLOW DISCHARGE
!
      TYPE(BIEF_OBJ), TARGET :: ECPL
!
!     FREE SURFACE ELEVATION
!
      TYPE(BIEF_OBJ), TARGET :: Z
!
!     INCREMENT OF FREE SURFACE ELEVATION WHEN READING AN HYDRO FILE
!
      TYPE(BIEF_OBJ), TARGET :: DEL_Z
!
!     EVOLUTION DUE TO BEDLOAD
!
      TYPE(BIEF_OBJ), TARGET :: ZF_C
!
!     EVOLUTION DUE TO SUSPENSION
!
      TYPE(BIEF_OBJ), TARGET :: ZF_S
!
!     CUMULATED BED EVOLUTION
!
      TYPE(BIEF_OBJ), TARGET :: ESOMT
!
!     MAXIMUM EVOLUTION
!
      TYPE(BIEF_OBJ), TARGET :: EMAX
!
!     COMPONENTS OF DEPTH-AVERAGED FLOW RATE
!
      TYPE(BIEF_OBJ), TARGET :: QU
!
!     COMPONENTS OF DEPTH-AVERAGED FLOW RATE
!
      TYPE(BIEF_OBJ), TARGET :: QV
!
!     INCREMENTS OF FLOW RATE COMPONENTS WHEN READING AN HYDRO FILE
!
      TYPE(BIEF_OBJ), TARGET :: DEL_QU
!
!     INCREMENTS OF FLOW RATE COMPONENTS WHEN READING AN HYDRO FILE
!
      TYPE(BIEF_OBJ), TARGET :: DEL_QV
! JWI 31/05/2012 - added lines to include wave orbital velocities
!> @brief INCREMENTS OF WAVE ORBITAL VELOCITY WHEN READING AN HYDRO FILE
!
      TYPE(BIEF_OBJ), TARGET :: DEL_UW
! JWI END
!
!     FLOW RATE
!
      TYPE(BIEF_OBJ), TARGET :: Q
!
!     SOLID DISCHARGE
!
      TYPE(BIEF_OBJ), TARGET :: QS
!
!     SOLID DISCHARGE ,ALONG X AND Y
!
      TYPE(BIEF_OBJ), TARGET :: QSX,QSY
!
!     SOLID DISCHARGE (BEDLOAD)
!
      TYPE(BIEF_OBJ), TARGET :: QS_C
!
!     SOLID DISCHARGE (BEDLOAD), ALONG X AND Y
!
      TYPE(BIEF_OBJ), TARGET :: QSXC,QSYC
!
!     SOLID DISCHARGE (SUSPENSION)
!
      TYPE(BIEF_OBJ), TARGET :: QS_S
!
!     SOLID DISCHARGE (SUSPENSION), ALONG X AND Y
!
      TYPE(BIEF_OBJ), TARGET :: QSXS,QSYS
!
!     WATER DEPTH
!
      TYPE(BIEF_OBJ), TARGET :: HN
!
!     DEPTH AFTER CLIPPING
!
      TYPE(BIEF_OBJ), TARGET :: HCLIP
!
!     COMPONENTS OF DEPTH-AVERAGED VELOCITY
!
      TYPE(BIEF_OBJ), TARGET :: U2D,V2D
!
!     FLOW INTENSITY
!
      TYPE(BIEF_OBJ), TARGET :: UNORM
!
!     WATER DEPTH SAVED FOR CONSTANT FLOW DISCHARGE
!
      TYPE(BIEF_OBJ), TARGET :: HCPL
!
!     IMPOSED BED EVOLUTION AT THE BOUNDARY
!
      TYPE(BIEF_OBJ), TARGET :: EBOR
!
!     IMPOSED SOLID TRANSPORT AT THE BOUNDARY
!     QBOR : IN M3/S, FOR EVERY CLASS
!     Q2BOR: IN M2/S, TOTAL, READ IN THE BOUNDARY CONDITIONS FILE
!
      TYPE(BIEF_OBJ), TARGET :: QBOR,Q2BOR
!
!     ZF VALUES ON BOUNDARIES
!
      TYPE(BIEF_OBJ), TARGET :: FLBOR
!
!     BOTTOM ELEVATION
!
      TYPE(BIEF_OBJ), TARGET :: ZF
!
!     NON ERODABLE (RIGID) BOTTOM ELEVATION
!
      TYPE(BIEF_OBJ), TARGET :: ZR
!
!     REFERENCE ELEVATION
!
      TYPE(BIEF_OBJ), TARGET :: ZREF
!
!     INTEGRAL OF BASES
!
      TYPE(BIEF_OBJ), TARGET :: VOLU2D
!
!     INTEGRAL OF BASES IN PARALLEL
!
      TYPE(BIEF_OBJ), TARGET :: V2DPAR
!
!     INVERSE OF INTEGRAL OF BASES
!
      TYPE(BIEF_OBJ), TARGET :: UNSV2D
!
!     BOTTOM FRICTION COEFFICIENT (CHEZY, NIKURADSE OR STRICKLER)
!
      TYPE(BIEF_OBJ), TARGET :: CHESTR
!
!     ANGLE BETWEEN QS AND Q
!
      TYPE(BIEF_OBJ), TARGET :: CALFA
!
!     ANGLE BETWEEN QS AND Q
!
      TYPE(BIEF_OBJ), TARGET :: SALFA
!
!     VOID STRUCTURE
!
      TYPE(BIEF_OBJ), TARGET :: S
!
!     MASK ON POINTS
!
      TYPE(BIEF_OBJ), TARGET :: MASKPT
!
!     MASK
!
      TYPE(BIEF_OBJ), TARGET :: MASKTR
!
!     MASK
!
      TYPE(BIEF_OBJ), TARGET :: MASKB
!
!     MASK
!
      TYPE(BIEF_OBJ), TARGET :: MASKEL
!
!     MASK
!
      TYPE(BIEF_OBJ), TARGET :: MSKTMP
!
!     WORKING ARRAYS
!
      TYPE(BIEF_OBJ), TARGET :: W1
!
! WAVE DATA
! --------
!
!     WAVE DIRECTION (DEG WRT OX AXIS)    !!!!!SOME SAY OY AXIS!!!!!
!
      TYPE(BIEF_OBJ), TARGET :: THETAW
!
!     FRICTION COEFFICIENT (WAVES)
!
      TYPE(BIEF_OBJ), TARGET :: FW
!
!     ORBITAL VELOCITY
!
      TYPE(BIEF_OBJ), TARGET :: UW
!
!     SIGNIFICANT WAVE HEIGHT
!
      TYPE(BIEF_OBJ), TARGET :: HW
!
!     MEAN WAVE PERIOD
!
      TYPE(BIEF_OBJ), TARGET :: TW
!
!
!
      TYPE(BIEF_OBJ), TARGET :: INDIC,IFAMAS
!
!     INTEGER WORKING ARRAYS
!
      TYPE(BIEF_OBJ), TARGET :: IT1,IT2,IT3,IT4
!
!     TYPE OF BOUNDARY CONDITIONS ON BED EVOLUTION
!
      TYPE(BIEF_OBJ), TARGET :: LIEBOR
!
!     TYPE OF BOUNDARY CONDITIONS ON SAND TRANSPORT RATE
!
      TYPE(BIEF_OBJ), TARGET :: LIQBOR
!
!     TYPE OF BOUNDARY CONDITIONS
!
      TYPE(BIEF_OBJ), TARGET :: LIMTEC
!
!     IMPACT OF THE SLOPE EFFECT ON AMPLITUDE
!
      TYPE(BIEF_OBJ), TARGET :: COEFPN
!
!     LIQUID BOUNDARY NUMBERING
!
      TYPE(BIEF_OBJ), TARGET :: NUMLIQ
!
!     SHEAR STRESS
!
      TYPE(BIEF_OBJ), TARGET :: TOB
!
!     FRICTION COEFFICIENT
!
      TYPE(BIEF_OBJ), TARGET :: CF
!
!     WAVE INDUCED SHEAR STRESS
!
      TYPE(BIEF_OBJ), TARGET :: TOBW
!
!     rapport entre la contrainte de frottement de peau et la contrainte totale
!
      TYPE(BIEF_OBJ), TARGET :: MU
!
!     rugosite totale
!
      TYPE(BIEF_OBJ), TARGET :: KS
!
!     rugosite de peau
!
      TYPE(BIEF_OBJ), TARGET :: KSP
!
!     rugosite de ride
!
      TYPE(BIEF_OBJ), TARGET :: KSR
!
!     BED LEVEL CHANGE FOR GRAIN-FEEDING
!
      TYPE(BIEF_OBJ), TARGET :: DZF_GF
!
!     MEAN DIAMETER OF ACTIVE-LAYER
!
      TYPE(BIEF_OBJ), TARGET :: ACLADM
!
!     MEAN DIAMETER OF UNDER-LAYER
!
      TYPE(BIEF_OBJ), TARGET :: UNLADM
!
!     NUMBER OF LAYERS FOR EACH POINT
!
      TYPE(BIEF_OBJ), TARGET :: NLAYER
!
!     HIDING FACTOR FOR PARTICULAR SIZE CLASS
!
      TYPE(BIEF_OBJ), TARGET :: HIDING
!
! 
!
      TYPE(BIEF_OBJ), TARGET :: ELAY
!
!     ACTIVE STRATUM THICKNESS
!
      TYPE(BIEF_OBJ), TARGET :: ESTRAT
!
!     DEPOSITION FLUX
!
      TYPE(BIEF_OBJ), TARGET :: FLUDP
!
!     DEPOSITION FLUX
!
      TYPE(BIEF_OBJ), TARGET :: FLUDPT
!
!     EROSION FLUX
!
      TYPE(BIEF_OBJ), TARGET :: FLUER
!
!     EROSION FLUX
!
      TYPE(BIEF_OBJ), TARGET :: FLUERT
!
!     CONCENTRATION AT TIME N
!
      TYPE(BIEF_OBJ), TARGET :: CS

!     MAK CHANGE create parameter for ratio depth averaged and reference concentration.
!     TYPE(BIEF_OBJ), TARGET :: CST, CTILD, CSTAEQ
      TYPE(BIEF_OBJ), TARGET :: CST, CTILD, CSTAEQ, CSRATIO
!
!     IMPOSED SUSPENDED SAND CONCENTRATION AT THE BOUNDARY (DIM.NPTFR)
!
      TYPE(BIEF_OBJ), TARGET :: CBOR
!
!     CONCENTRATION IN G/L
!
      TYPE(BIEF_OBJ), TARGET :: CSGL
!
!     COMPONENTS OF VELOCITY VECTORS
!
      TYPE(BIEF_OBJ), TARGET ::  UCONV,VCONV
!
!     PROPAGATION HEIGHT
!
      TYPE(BIEF_OBJ), TARGET :: HPROP
!
! 
!
      TYPE(BIEF_OBJ), TARGET :: DISP,DISP_C
!
!     FLUX CONDITION NU DF/DN=AFBOR * F + BFBOR
!
      TYPE(BIEF_OBJ), TARGET :: AFBOR,BFBOR
!
!     FLUX AT THE BOUNDARIES
!
      TYPE(BIEF_OBJ), TARGET :: FLBOR_SIS
!
!     FLUX AT THE BOUNDARIES FOR TRACER
!
      TYPE(BIEF_OBJ), TARGET :: FLBORTRA
!
!     BOUNDARY CONDITIONS FOR SEDIMENT                     : LICBOR
!     TYPES OF BOUNDARY CONDITIONS FOR H                   : LIHBOR
!     TYPES OF BOUNDARY CONDITIONS FOR PROPAGATION         : LIMPRO
!                    POINTS   :    .1:H  .2:U  .3:V
!                    SEGMENTS :    .4:H  .5:U  .6:V
!
!     TYPE OF BOUNDARY CONDITIONS ON SUSPENDED SAND CONCENTRATION
!
      TYPE(BIEF_OBJ), TARGET :: LICBOR
!
!     TYPE OF BOUNDARY CONDITIONS FOR H
!
      TYPE(BIEF_OBJ), TARGET :: LIHBOR
!
!     TYPE OF BOUNDARY CONDITIONS FOR PROPAGATION
!
      TYPE(BIEF_OBJ), TARGET :: LIMPRO
!
!     TYPE OF BOUNDARY CONDITIONS FOR DIFFUSION
!
      TYPE(BIEF_OBJ), TARGET :: LIMDIF
!
!     LAST COLUMN OF THE BOUNDARY CONDITION FILE
!
      TYPE(BIEF_OBJ), TARGET :: BOUNDARY_COLOUR
!
!     BOUNDARY CONDITIONS FOR TRACER, U AND V (MODIFIED LITBOR, LIUBOR,LIVBOR)
!
      TYPE(BIEF_OBJ), TARGET :: CLT,CLU,CLV
!
!     WORK ARRAYS FOR ELEMENTS
!
      TYPE(BIEF_OBJ), TARGET :: TE1,TE2,TE3
!
!     COEFFICIENTS OF THE DISPERSION TENSOR (DIM. NPOIN)
!
      TYPE(BIEF_OBJ), TARGET :: KX,KY,KZ
!
!     ARRAY SAYING WHETHER THE NON-ERODABLE BOTTOM HAS BEEN REACHED (VF)
!
      TYPE(BIEF_OBJ), TARGET :: BREACH
!
!     FOR MIXED SEDIMENTS
!
      TYPE(BIEF_OBJ), TARGET :: FLUER_VASE,TOCE_MIXTE,MS_SABLE,MS_VASE
!
!-----------------------------------------------------------------------
!
!       2) MATRICES
!
!-----------------------------------------------------------------------
!
!     BOUNDARY MATRIX
!
      TYPE(BIEF_OBJ), TARGET :: MBOR
!
!     MATRICES
!
      TYPE(BIEF_OBJ), TARGET :: AM1_S,AM2_S
!
!-----------------------------------------------------------------------
!
!       3) BLOCKS
!
!-----------------------------------------------------------------------
!
!     BLOCK OF MASKS
!
      TYPE(BIEF_OBJ), TARGET :: MASK
!
!     BLOCKS OF WORKING ARRAYS
!
      TYPE(BIEF_OBJ), TARGET :: TB,TB2
!
!     BLOCK OF PRIVATE VECTORS
!
      TYPE(BIEF_OBJ), TARGET :: PRIVE
!
!     BLOCK OF CLANDESTINE VARIABLES
!
      TYPE(BIEF_OBJ), TARGET :: VARCL
!
!     BLOCK OF VARIABLES FOR INPUT
!
      TYPE(BIEF_OBJ), TARGET :: VARHYD
!
!     BLOCK OF VARIABLES FOR OUTPUT
!
      TYPE(BIEF_OBJ), TARGET :: VARSOR

! UHM / PAT

!     VERTICAL SORTING PROFILE: FRACTION FOR EACH LAYER, CLASS, POINT

      DOUBLE PRECISION,DIMENSION(:,:,:),TARGET,ALLOCATABLE::PRO_F

!     VERTICAL SORTING PROFILE: DEPTH FOR EACH LAYER, CLASS, POINT

      DOUBLE PRECISION,DIMENSION(:,:,:),TARGET,ALLOCATABLE::PRO_D

! UHM / PAT

!
!     SEDIMENT FRACTION FOR EACH LAYER, CLASS, POINT
!
      DOUBLE PRECISION,DIMENSION(:,:,:),TARGET,ALLOCATABLE::AVAIL
!
!     LAYER THICKNESSES AS DOUBLE PRECISION
!
      DOUBLE PRECISION,DIMENSION(:,:),TARGET,ALLOCATABLE :: ES
!
!     LAYER THICKNESSES OF THE MUD AS DOUBLE PRECISION
!
      DOUBLE PRECISION,DIMENSION(:,:),TARGET,ALLOCATABLE :: ES_VASE
!
!     LAYER THICKNESSES OF THE SAND AS DOUBLE PRECISION
!
      DOUBLE PRECISION,DIMENSION(:,:),TARGET,ALLOCATABLE :: ES_SABLE
!
!     SEDIMENT COMPOSITION
!
      TYPE(BIEF_OBJ), TARGET :: AVAI
!
!     LAYER THICKNESSES
!
      TYPE(BIEF_OBJ), TARGET :: LAYTHI
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: LAYCONC
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: QSCL
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: QSCL_C
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: QSCLXC, QSCLYC
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: QSCL_S
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: QSCLXS, QSCLYS
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: ZFCL
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: ZFCL_C
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: ZFCL_S
!> @brief
!
      TYPE(BIEF_OBJ), TARGET :: ZFCL_MS

!> @brief MEYER PETER MUELLER factor
!  
      TYPE(BIEF_OBJ), TARGET :: MPM_ARAY
!
!     FLUX LIMITATION PER SEGMENT
!
      TYPE(BIEF_OBJ), TARGET :: FLULIM
!
!     FLUXES AT BOUNDARY FOR EVERY CLASS
!
      TYPE(BIEF_OBJ), TARGET :: FLBCLA
! 
!     CV modifs V6P2 new variables for consolidation model
! 
!     VOID INDEX OF BED LAYERS
!
      DOUBLE PRECISION,DIMENSION(:,:),TARGET,ALLOCATABLE::IVIDE
!
!     CONCENTRATION OF BED LAYER
!
      DOUBLE PRECISION,DIMENSION(:,:),TARGET,ALLOCATABLE::CONC
!
!-----------------------------------------------------------------------
!
!       4) INTEGERS
!
!-----------------------------------------------------------------------
!
!      KEYWORDS AND PARAMETERS

!     Maximum Layer Number in a VERTICAL SORTING PROFILE FOR EACH POINT (UHM)
      INTEGER, ALLOCATABLE :: PRO_MAX(:)
!
!      MAXIMUM NUMBER OF OUTPUT VARIABLES
!
      INTEGER, PARAMETER :: MAXVAR = 500
!
!     MAXIMUM NUMBER OF (LIQUID BOUNDARIES, SOLID BOUNDARIES)
!
      INTEGER MAXFRO
!
!     NUMBER OF LIQUID, SOLID BOUNDARIES
!
      INTEGER NFRLIQ,NFRSOL
!
!     BEGINNING AND END OF LIQUID BOUNDARIES, OF SOLID BOUNDARIES
!
      INTEGER, ALLOCATABLE :: DEBLIQ(:),FINLIQ(:),DEBSOL(:),FINSOL(:)
!
!     OPTION FOR THE DIFFUSION OF TRACER
!
      INTEGER OPDTRA
!
!     OPTION FOR THE DISPERSION
! 
      INTEGER OPTDIF
!
!     SUPG OPTION
!
      INTEGER OPTSUP
!
!     NUMBER OF ITERATIONS WITH CONSTANT FLOW DISCHARGE
!
      INTEGER :: NCONDIS
!
!     LAW OF BOTTOM FRICTION
! 
      INTEGER KFROT
!
!     BED-LOAD TRANSPORT FORMULA
! 
      INTEGER ICF
!
!> @brief
!
      INTEGER NPAS
!
!     NUMBER OF TIDES OR FLOODS
! 
      INTEGER NMAREE
!
      INTEGER LEOPR
!
      INTEGER LISPR
!
      INTEGER NVARCL
!
      INTEGER IELMT,IELMH_SIS,IELMU_SIS,IELMX
!
!     standard du fichier de geometrie
!
      INTEGER STDGEO
!
      INTEGER LOGDES ,LOGPRE ,OPTBAN ,LVMAC
!
!     HYDRODYNAMIC CODE
! 
      INTEGER HYDRO
!
!     MATRIX STORAGE
! 
      INTEGER OPTASS
!
!     NUMBER OF SUB-ITERATIONS
! 
      INTEGER NSOUS
!
!
!
      INTEGER MARDAT(3),MARTIM(3),PRODUC
!
!     OPTION FOR THE TREATMENT OF NON ERODABLE BEDS
! 
      INTEGER CHOIX
!
      INTEGER PTINIL,PTINIG
!
!     NUMBER OF PRIVATE ARRAYS, NUMBER OF PRIVATE ARRAYS WITH GIVEN NAME
!
      INTEGER NPRIV,N_NAMES_PRIV
!
!     COUPLING PERIOD
! 
      INTEGER PERCOU
!
!     NUMERO DU PAS DE TEMPS
!
      INTEGER LT
!
      INTEGER RESOL
!
      INTEGER DEPER
!
!     FORMULA FOR DEVIATION
!
      INTEGER DEVIA
!
!     FORMULA FOR SLOPE EFFECT
!
      INTEGER SLOPEFF
!
! NON-EQUILIBRIUM BEDLOAD AND NON-UNIFORM BED MATERIA (BMD AND MGDL)
! --------
!
!     MAXIMUM NUMBER OF SIZE-CLASSES
!
      INTEGER, PARAMETER :: NSICLM = 10
!
!     NUMBER OF SIZE-CLASSES OF BED MATERIAL (LESS THAN 10)
!
      INTEGER :: NSICLA
!
!     MAXIMUM NUMBER OF LAYERS ON THE MESH
!
      INTEGER, PARAMETER :: NLAYMAX = 20
!
!     NUMBER OF BED LOAD MODEL LAYERS
!
      INTEGER NOMBLAY
!     
!     FORMULATION FOR THE HIDING FACTOR
!
      INTEGER HIDFAC
!
      INTEGER :: LOADMETH
!
!     DEBUGGER
!
      INTEGER :: DEBUG
!
!     REFERENCE CONCENTRATION FORMULA
!
      INTEGER :: ICQ
!
!     NUMBER OF CONTROL SECTIONS POINTS
!
      INTEGER NCP
!
!     ARRAY CONTAINING THE GLOBAL NUMBER OF THE POINTS IN THE CONTROL SECTIONS
!
      INTEGER, ALLOCATABLE :: CTRLSC(:)
!
!     COORDINATES OF THE ORIGIN
!
      INTEGER I_ORIG,J_ORIG
!
!     NUMBER OF LAYERS FOR CONSOLIDATION
!
      INTEGER NCOUCH_TASS
!
!     SKIN FRICTION CORRECTION
!
      INTEGER ICR
!
!     BED ROUGHNESS PREDICTOR OPTION
!
      INTEGER IKS
!
!     CONSOLIDATION MODEL
!
      INTEGER ITASS
!
!     TREATMENT OF FLUXES AT THE BOUNDARIES
!
      INTEGER DIRFLU
!
!     NUMBER OF GIVEN SSOLID DISCHARGES GIVEN BY USER
!
      INTEGER NSOLDIS
!
!// UHM // For the Continous Vertical Sorting MODEL
!
!     Type of the Vertical Grain Sorting: Hirano Layers or Continous-VSM
!
      INTEGER VSMTYPE
!
!     Maximum Number of Profile SECTIONS
!
      INTEGER PRO_MAX_MAX
!
!     Printout Period for Full Vertical Sorting Model: PRO_D & PRO_F
!
      INTEGER CVSMPPERIOD
!
!     CHOOSE POINTS or FULL MODEL AS PRINTOUT
!
      INTEGER CVSMOUTPUT(100)    !Limited to 100 for no specific reason
!
!     CHOOSE A MODEL FOR ESTIMATION OF A DYNAMIC ACTIVE LAYER THICKNESS
!
      INTEGER ALT_MODEL
!
!     MAXIMUM NUMBER OF ITERATIONS FOR ADVECTION SCHEMES
!
      INTEGER MAXADV
!
!     SCHEME OPTION FOR ADVECTION
!
      INTEGER OPTADV
!
!     NUMBER OF CORRECTIONS FOR DISTRIBUTIVE SCHEMES 
!     NUMBER OF SUB-STEPS FOR DISTRIBUTIVE SCHEMES 
!
      INTEGER NCO_DIST,NSP_DIST
!
!-----------------------------------------------------------------------
!
!       5) LOGICAL VALUES
!
!-----------------------------------------------------------------------
!
!     USED IN FUNCTION CGL
!
      LOGICAL, ALLOCATABLE :: OKCGL(:)
!
!  C-VSM WRITES OUT (OR NOT) IN THIS TIMESTEP
!
      LOGICAL :: CVSM_OUT !UHM

!  C-VSM_FULL WRITES OUT (OR NOT) EVER
!
      LOGICAL :: CVSM_OUT_FULL !UHM
!
!     GRAPHICAL OUTPUT
!
      LOGICAL :: SORLEO(MAXVAR)
!
!     LISTING OUTPUT
!
      LOGICAL :: SORIMP(MAXVAR)
!
!     MASKING
!
      LOGICAL :: MSK
!
!     WRITES OUT (OR NOT)
!
      LOGICAL :: ENTET
!
!     RESOLUTION FOR SUSPENSION IS IMPLICIT (OR NOT)
!
      LOGICAL :: YASMI
!
!     SPHERICAL EQUATIONS (HARD-CODED)
!
      LOGICAL :: SPHERI
!
!     STEADY HYDRODYNAMICS
!
      LOGICAL :: PERMA
!
!     TIDAL FLATS
!
      LOGICAL :: BANDEC
!
!     WAVE EFFECT
! 
      LOGICAL :: HOULE
!
!     FALL VELOCITY (PARTIALLY HARD-CODED)
!
      LOGICAL :: CALWC
!
!     SHIELDS PARAMETER
!
      LOGICAL :: CALAC
!
!     BEDLOAD
!
      LOGICAL :: CHARR
!
!     LOADING LAW USED OR NOT
!
      LOGICAL :: NOEQUBED
!
!     FINITE VOLUMES
! 
      LOGICAL :: VF
!
!     MASS-LUMPING
!
      LOGICAL :: LUMPI
!
!     CONSTANT FLOW DISCHARGE
!
      LOGICAL :: LCONDIS
!
!     GRAIN-FEEDING
! 
      LOGICAL :: LGRAFED
!
!     CONSTANT ACTIVE LAYER THICKNESS
! 
      LOGICAL :: CONST_ALAYER
!
!     SUSPENSION
! 
      LOGICAL :: SUSP
!
!     MASS BALANCE
!
      LOGICAL :: BILMA
!
!     VALIDATION
! 
      LOGICAL :: VALID
!
!     IMPOSED CONCENTRATION IN INFLOW
! 
      LOGICAL :: IMP_INFLOW_C
!
!     SECONDARY CURRENTS
! 
      LOGICAL :: SECCURRENT
!
!     MASS CONCENTRATIONS IN G/L
! 
      LOGICAL :: UNIT
!
!     CORRECTION ON CONVECTION VELOCITY
! 
      LOGICAL :: CORR_CONV
!
!     COMPUTATION CONTINUED
! 
      LOGICAL :: DEBU
!
!     DIFFUSION OF SUSPENDED SEDIMENT CONCENTRATION
! 
      LOGICAL :: DIFT
!
!     SEDIMENT SLIDE
! 
      LOGICAL :: SLIDE
!
!     COHESIVE SEDIMENTS (FOR EACH CLASS)
! 
      LOGICAL :: SEDCO(NSICLM)
!
!     CONSOLIDATION TAKEN INTO ACCOUNT
! 
      LOGICAL :: TASS
!
!     MIXED SEDIMENTS
! 
      LOGICAL :: MIXTE
!
!     COUPLING WITH DREDGESIM
! 
      LOGICAL :: DREDGESIM
!
!     BED FRICTION PREDICTION
! 
      LOGICAL :: KSPRED
!
! MAK
!     Settling lag: determines choice between Rouse and Miles concentration profile
!     SET_LAG = TRUE : Miles
!             = FALSE: Rouse
!
      LOGICAL :: SET_LAG
!     STATIONARY MODE: calculate sediment transport without updating the bed.
      LOGICAL :: STAT_MODE
!
!-----------------------------------------------------------------------
!
!       6) REALS
!
!-----------------------------------------------------------------------
!
!
!
      DOUBLE PRECISION RC
!
!     WATER DENSITY
! 
      DOUBLE PRECISION XMVE
!
!     SAND DENSITY
! 
      DOUBLE PRECISION XMVS
!
!     COEFFICIENT FUNCTION OF THE POROSITY
! 
      DOUBLE PRECISION XKV
!
!     GRAVITY ACCELERATION
! 
      DOUBLE PRECISION GRAV
!
      DOUBLE PRECISION SFON
!
!     FLOW VISCOSITY
! 
      DOUBLE PRECISION VCE
!
      DOUBLE PRECISION TETA
!
!     MINIMAL VALUE OF THE WATER HEIGHT
! 
      DOUBLE PRECISION HMIN
!
      DOUBLE PRECISION BETA ,DELT
!
!     TIDAL PERIOD
!
      DOUBLE PRECISION PMAREE
!
!     STARTING TIME OF THE HYDROGRAM
! 
      DOUBLE PRECISION TPREC
!
      DOUBLE PRECISION PHI0
!
!     TIME STEP
!
      DOUBLE PRECISION DT
!
!     CRITERION TO UPDATE THE FLOW (WITH CONSTANT FLOW DISCHARGE)
!
      DOUBLE PRECISION :: CRIT_CFD
!
      DOUBLE PRECISION :: FRACSED_GF(NSICLM)
!
!     INITIAL SUSPENSION CONCENTRATIONS
! 
      DOUBLE PRECISION :: CS0(NSICLM)
!
!     MASS EXCHANGED BY SOURCE TERM
!
      DOUBLE PRECISION MASSOU
!
      DOUBLE PRECISION CSF_SABLE
!
!     SETTLING VELOCITIES
! 
      DOUBLE PRECISION XWC(NSICLM)
!
!     CRITICAL SHIELDS PARAMETER
!
      DOUBLE PRECISION AC(NSICLM)
!
!     TETA SUSPENSION
!
      DOUBLE PRECISION TETA_SUSP
!
      DOUBLE PRECISION  XKX, XKY
!
!     FRICTION ANGLE OF THE SEDIMENT
! 
      DOUBLE PRECISION PHISED
!
!     PARAMETER FOR DEVIATION
! 
      DOUBLE PRECISION BETA2
!
!     HIDING FACTOR FOR PARTICULAR SIZE CLASS WHEN THE USER SUBROUTINE INIT_HIDING IS NOT USED
! 
      DOUBLE PRECISION HIDI(NSICLM)
!
!     D90
! 
      DOUBLE PRECISION FD90(NSICLM)
!
!     SEDIMENT DIAMETERS
! 
      DOUBLE PRECISION FDM(NSICLM)
!
!     INITIAL SEDIMENT COMPOSITION FOR PARTICULAR SIZE CLASS WHEN INIT_COMPO IS NOT USED
! 
      DOUBLE PRECISION AVA0(NSICLM)
!
!     WANTED ACTIVE LAYER THICKNESS; ELAYO=FIXED VALUE, ELAY=REAL VALUE FOR EACH POINT; WHEN ENOUGH SEDIMENT ELAY = ELAY0
! 
      DOUBLE PRECISION ELAY0
!
!     TOTAL VOLUME OF SEDIMENT IN EACH CLASS
!
      DOUBLE PRECISION VOLTOT(NSICLM)
!
!     CRITICAL SHEAR VELOCITY FOR MUD DEPOSITION
! 
      DOUBLE PRECISION :: VITCD
!
!     CRITICAL EROSION SHEAR VELOCITY OF THE MUD
! 
      DOUBLE PRECISION :: VITCE
!
!     SUSPENDED MASS BALANCE
!
      DOUBLE PRECISION :: MASED0(NSICLM)
!
!     SUSPENDED MASS BALANCE
!
      DOUBLE PRECISION :: MASINI(NSICLM)
      DOUBLE PRECISION :: MASTEN(NSICLM),MASTOU(NSICLM)
      DOUBLE PRECISION :: MASTCP(NSICLM),MASFIN(NSICLM)
      DOUBLE PRECISION :: MASDEP(NSICLM),MASDEPT(NSICLM)
!
!     FOR MASS BALANCE OF COHESIVE SEDIMENT AND MIXTE
!
      DOUBLE PRECISION :: MASVT,MASV0,MASST,MASS0
!
!     FOR NON-EQUILIBIRUM BEDLOAD
!
      DOUBLE PRECISION :: LS0
!
!     RATIO BETWEEN SKIN FRICTION AND MEAN DIAMETER
! 
      DOUBLE PRECISION :: KSPRATIO
!
!     KARIM, HOLLY & YANG CONSTANT
!
      DOUBLE PRECISION :: KARIM_HOLLY_YANG
!
!     KARMAN CONSTANT
!
      DOUBLE PRECISION :: KARMAN
!
!     PARTHENIADES CONSTANT
! 
      DOUBLE PRECISION :: PARTHENIADES
!
!     MAXIMUM CONCENTRATION
!
      DOUBLE PRECISION :: CMAX
!
!     PI
!
      DOUBLE PRECISION :: PI
!
!     Meyer Peter Mueller-Coefficient
! 
      DOUBLE PRECISION :: MPM
!
!     Secondary Current Alpha Coefficient
!
      DOUBLE PRECISION :: ALPHA
!
!     Morphological Factor
!
      DOUBLE PRECISION :: MOFAC
!
!     ZERO OF THE CODE
!
      DOUBLE PRECISION :: ZERO
!
!     B VALUE FOR THE BIJKER FORMULA
!
      DOUBLE PRECISION :: BIJK
!
!     MUD CONCENTRATION AT BOUNDARIES FOR EACH CLASS
!
      DOUBLE PRECISION, ALLOCATABLE :: CBOR_CLASSE(:)
!
!     MUD CONCENTRATION FOR EACH LAYER (Constant)
!
      DOUBLE PRECISION :: CONC_VASE(NLAYMAX)
!
!     MASS TRANSFER BETWEEN LAYERS
!
      DOUBLE PRECISION :: TRANS_MASS(NLAYMAX)
!
!     CRITICAL EROSION SHEAR STRESS OF THE MUD PER LAYER
!
      DOUBLE PRECISION :: TOCE_VASE(NLAYMAX)
!
!     CRITICAL EROSION SHEAR STRESS OF THE SAND
!
      DOUBLE PRECISION :: TOCE_SABLE
!
!     THIEBOT MODEL
! 
      DOUBLE PRECISION :: CONC_GEL, COEF_N,CONC_MAX
!
!     PRESCRIBED SOLID DISCHARGES
! 
      DOUBLE PRECISION, ALLOCATABLE :: SOLDIS(:)
!
!     FOR MASS BALANCE OF COHESIVE SEDIMENT
!
      DOUBLE PRECISION :: MASBED0,MASBED
!
!-----------------------------------------------------------------------
!
!       7) STRINGS
!
!-----------------------------------------------------------------------
!
!
      CHARACTER(LEN=72) TITCA,SORTIS,VARIM
!
      CHARACTER(LEN=3) BINGEOSIS,BINPRESIS,BINHYDSIS
!
      CHARACTER(LEN=3) BINRESSIS,BINREFSIS
!
!     FOR CLANDESTINE VARIABLES
!
      CHARACTER(LEN=32) VARCLA(NSICLM),TEXTE(MAXVAR),TEXTPR(MAXVAR)
!
!     NAMES OF PRIVATE ARRAYS (GIVEN BY USER)
!
      CHARACTER(LEN=32) NAMES_PRIVE(4)    
!
!     EQUATION SOLVED
!
      CHARACTER(LEN=20) EQUA
!
!     MNEMO OF VARIABLES FOR GRAPHIC PRINTOUTS (B FOR BOTTOM, ETC.)
!
      CHARACTER(LEN=8) MNEMO(MAXVAR)
!
      CHARACTER(LEN=144) COUPLINGSIS
!
!-----------------------------------------------------------------------
!
!       8) SLVCFG STRUCTURES
!
!-----------------------------------------------------------------------
!
      TYPE(SLVCFG) :: SLVSED
!
      TYPE(SLVCFG) :: SLVTRA
!
!-----------------------------------------------------------------------
!
!       9) MESH STRUCTURE
!
!-----------------------------------------------------------------------
!
!     MESH STRUCTURE
!
      TYPE(BIEF_MESH) :: MESH
!
!-----------------------------------------------------------------------
!
!      10) ALIASES
!
!-----------------------------------------------------------------------
!
!     DECLARATION OF POINTERS FOR ALIASES
!     TARGETS ARE DEFINED IN POINT_TELEMAC2D
!
!     ALIASES FOR WORK VECTORS IN TB
!
      TYPE(BIEF_OBJ),POINTER :: T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12
      TYPE(BIEF_OBJ),POINTER :: T13,T14
!
!     USEFUL COMPONENTS IN STRUCTURE MESH
! 
!
!     CONNECTIVITY TABLE
!
      TYPE(BIEF_OBJ),   POINTER :: IKLE
!
!     2D COORDINATES OF THE MESH
! 
      DOUBLE PRECISION, DIMENSION(:), POINTER :: X,Y
!
!     NUMBER OF ELEMENTS IN THE MESH
! 
      INTEGER, POINTER:: NELEM
!
!     MAXIMUM NUMBER OF ELEMENTS IN THE MESH
! 
      INTEGER, POINTER:: NELMAX
!
!     NUMBER OF BOUNDARY POINTS, MAXIMUM NUMBER
! 
      INTEGER, POINTER:: NPTFR,NPTFRX
!
      INTEGER, POINTER:: TYPELM
!
!     NUMBER OF 2D POINTS IN THE MESH
! 
      INTEGER, POINTER:: NPOIN
!
      INTEGER, POINTER:: NPMAX
!
      INTEGER, POINTER:: MXPTVS
!
      INTEGER, POINTER:: MXELVS
!
      INTEGER, POINTER:: LV
!
!-----------------------------------------------------------------------
!
!      11) SISYPHE FILES + INTEGER DECLARATION FOR MED APPROACH
!
!-----------------------------------------------------------------------
!
!     MAXIMUM RANK OF LOGICAL UNITS AS DECLARED IN SUBMIT STRINGS IN THE DICTIONARY
!
      INTEGER, PARAMETER :: MAXLU_SIS = 46
!
!     FOR STORING INFORMATION ON FILES
!
      TYPE(BIEF_FILE) :: SIS_FILES(MAXLU_SIS)
!
!     VARIOUS FILES RANKS, WHICH ARE ALSO LOGICAL UNITS IF NO COUPLING
!
      INTEGER SISRES,SISREF,SISPRE,SISHYD,SISCOU,SISGEO,SISCLI,SISCAS
      INTEGER SISFON,SISMAF,SISSEC,SISSEO,SISLIQ
!
!-----------------------------------------------------------------------
!
!      12) SECTIONS
!
!-----------------------------------------------------------------------
!
      TYPE (CHAIN_TYPE), ALLOCATABLE :: CHAIN(:)
!
      END MODULE DECLARATIONS_SISYPHE

