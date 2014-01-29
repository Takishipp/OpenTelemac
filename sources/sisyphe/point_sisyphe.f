!                    ************************
                     SUBROUTINE POINT_SISYPHE
!                    ************************
!
!
!***********************************************************************
! SISYPHE   V6P2                                   21/07/2011
!***********************************************************************
!
!brief    ALLOCATES STRUCTURES.
!
!history  C. LENORMANT; J.-M. HERVOUET
!+        11/09/1995
!+
!+
!
!history  C. MACHET
!+        10/06/2002
!+
!+
!
!history  JMH
!+        16/06/2008
!+
!+   ADDED BOUNDARY_COLOUR
!
!history  JMH
!+        16/09/2009
!+
!+   AVAIL(NPOIN,10,NSICLA)
!
!history  JMH
!+        18/09/2009
!+        V6P0
!+   SEE AVAI AND LAYTHI
!
!history  JMH
!+        19/08/2010
!+        V6P0
!+   SEE MS_VASE (FOR MIXED SEDIMENTS)
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
!history  MAK (HRW)
!+        31/05/2012
!+        V6P2
!+    Added bief object for CSRATIO
!
!history  JWI (HRW)
!+        31/05/2012
!+        V6P2
!+    Added line to use wave orbital velocities directly if found in hydro file
!
!history  PAT (LNHE)
!+        18/06/2012
!+        V6P2
!+   updated version with HRW's development 
!
!history  CV (LNHE)
!+        01/07/2012
!+        V6P2
!+   added bloc ZFCL_MS for evolution for each class due to sloping bed effects
!
!history  J-M HERVOUET (EDF R&D, LNHE)
!+        08/03/2013
!+        V6P3
!+   Allocation of ZFCL_MS under condition of SLIDE.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE DECLARATIONS_SISYPHE
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU


      ! 2/ LOCAL VARIABLES
      ! ------------------
      INTEGER :: I,K,NTR,IELM0,IELM1,IELBT,IELM0_SUB
      INTEGER :: CFG(2),CFGBOR(2)

C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------

      IF (LNG == 1) WRITE(LU,11)
      IF (LNG == 2) WRITE(LU,12)

      ! ************************************** !
      ! I - DISCRETISATION AND TYPE OF STORAGE !
      ! ************************************** !
      ! IELMT, IELMH_SIS AND IELMU_SIS HARD-CODED IN LECDON
      IELM0     = 10
      IELM1     = 11
      IELBT     = IELBOR(IELMT,1)
      IELM0_SUB = 10*(IELMT/10)

      CFG(1)    = OPTASS
      CFG(2)    = PRODUC
      CFGBOR(1) = 1 ! CFG IMPOSED FOR BOUNDARY MATRICES
      CFGBOR(2) = 1 ! CFG IMPOSED FOR BOUNDARY MATRICES

      IF(VF) EQUA(1:15)='SAINT-VENANT VF'

      ! ******************************************* !
      ! II - ALLOCATES THE MESH STRUCTURE           !
      ! ******************************************* !
      CALL ALMESH(MESH,'MESH_S',IELMT,SPHERI,CFG,
     &            SIS_FILES(SISGEO)%LU,EQUA,
     &            FILE_FORMAT=SIS_FILES(SISGEO)%FMT)

      IKLE  => MESH%IKLE
      X     => MESH%X%R
      Y     => MESH%Y%R
      NELEM => MESH%NELEM
      NELMAX=> MESH%NELMAX
      NPTFR => MESH%NPTFR
      NPTFRX=> MESH%NPTFRX
      DIM   => MESH%DIM
      TYPELM=> MESH%TYPELM
      NPOIN => MESH%NPOIN
      NPMAX => MESH%NPMAX
      MXPTVS=> MESH%MXPTVS
      MXELVS=> MESH%MXELVS
      LV    => MESH%LV


      ! ******************** !
      ! III - REAL ARRAYS    !
      ! ******************** !
      CALL BIEF_ALLVEC(1,S     , 'S     ', 0    , 1, 1,MESH) ! VOID STRUCTURE
      CALL BIEF_ALLVEC(1,E     , 'E     ', IELMT, 1, 2,MESH) ! RESULT
      CALL BIEF_ALLVEC(1,Z     , 'Z     ', IELMT, 1, 2,MESH) ! RESULT
      CALL BIEF_ALLVEC(1,DEL_Z , 'DEL_Z ', IELMT, 1, 2,MESH) ! INCREMENT OF Z IF HYDRO
      CALL BIEF_ALLVEC(1,ZF_C  , 'ZF_C  ', IELMT, 1, 2,MESH) ! VARIABLES E SUMMED UP
      CALL BIEF_ALLVEC(1,ZF_S  , 'ZF_S  ', IELMT, 1, 2,MESH) ! VARIABLES E SUMMED U
      CALL BIEF_ALLVEC(1,ESOMT , 'ESOMT ', IELMT, 1, 2,MESH) ! VARIABLES E SUMMED U
      CALL BIEF_ALLVEC(1,EMAX  , 'EMAX  ', IELMT, 1, 2,MESH) ! VARIABLES E SUMMED U
      CALL BIEF_ALLVEC(1,Q     , 'Q     ', IELMT, 1, 2,MESH) ! FLOWRATE
      CALL BIEF_ALLVEC(1,QU    , 'QU    ', IELMT, 1, 2,MESH) ! X FLOWRATE
      CALL BIEF_ALLVEC(1,QV    , 'QV    ', IELMT, 1, 2,MESH) ! Y FLOWRATE
      CALL BIEF_ALLVEC(1,DEL_QU, 'DEL_QU', IELMT, 1, 2,MESH) ! INCREMENT OF QU IF HYDRO
      CALL BIEF_ALLVEC(1,DEL_QV, 'DEL_QV', IELMT, 1, 2,MESH) ! INCREMENT OF QV IF HYDRO
! JWI 31/05/2012 - added line to use wave orbital velocities directly if found in hydro file
      CALL BIEF_ALLVEC(1,DEL_UW, 'DEL_UW', IELMT, 1, 2,MESH) ! INCREMENT OF QV IF HYDRO
! JWI END
      CALL BIEF_ALLVEC(1,U2D   , 'U2D   ', IELMT, 1, 2,MESH) ! X VELOCITY
      CALL BIEF_ALLVEC(1,V2D   , 'V2D   ', IELMT, 1, 2,MESH) ! Y VELOCITY
      CALL BIEF_ALLVEC(1,QS    , 'QS    ', IELMT, 1, 2,MESH) ! TRANSPORT RATE
      CALL BIEF_ALLVEC(1,QSX   , 'QSX   ', IELMT, 1, 2,MESH) ! X TRANSPORT RATE
      CALL BIEF_ALLVEC(1,QSY   , 'QSY   ', IELMT, 1, 2,MESH) ! Y TRANSPORT RATE
      CALL BIEF_ALLVEC(1,QS_C  , 'QS_C  ', IELMT, 1, 2,MESH) ! BEDLOAD RATE
      CALL BIEF_ALLVEC(1,QSXC  , 'QSXC  ', IELMT, 1, 2,MESH) ! X BEDLOAD RATE
      CALL BIEF_ALLVEC(1,QSYC  , 'QSYC  ', IELMT, 1, 2,MESH) ! Y BEDLOAD RATE
      CALL BIEF_ALLVEC(1,QS_S  , 'QS_S  ', IELMT, 1, 2,MESH) ! SUSPENSION RATE
      CALL BIEF_ALLVEC(1,QSXS  , 'QSXS  ', IELMT, 1, 2,MESH) ! X SUSPENSION RATE
      CALL BIEF_ALLVEC(1,QSYS  , 'QSYS  ', IELMT, 1, 2,MESH) ! Y SUSPENSION RATE
      CALL BIEF_ALLVEC(1,HIDING, 'HIDING', IELMT, 1, 2,MESH) ! HIDING FACTOR
      CALL BIEF_ALLVEC(1,ZF    , 'ZF    ', IELMT, 1, 2,MESH) ! BED ELEVATIONS
      CALL BIEF_ALLVEC(1,ZR    , 'ZR    ', IELMT, 1, 2,MESH) ! NON-ERODABLE BED ELEVATIONS
      CALL BIEF_ALLVEC(1,ZREF  , 'ZREF  ', IELMT, 1, 2,MESH) ! REFERENCE ELEVATION
      CALL BIEF_ALLVEC(1,CHESTR, 'CHESTR', IELMT, 1, 2,MESH) ! FRICTION COEFFICIENT
      CALL BIEF_ALLVEC(1,COEFPN, 'COEFPN', IELMT, 1, 2,MESH) ! SLOPE EFFECT
      CALL BIEF_ALLVEC(1,CALFA , 'CALFA ', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,SALFA , 'SALFA ', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,CF    , 'CF    ', IELMT, 1, 2,MESH) ! ADIMENSIONAL FRICTION
      CALL BIEF_ALLVEC(1,TOB   , 'TOB   ', IELMT, 1, 2,MESH) ! TOTAL FRICTION
      CALL BIEF_ALLVEC(1,TOBW  , 'TOBW  ', IELMT, 1, 2,MESH) ! WAVE VARIABLE
      CALL BIEF_ALLVEC(1,MU    , 'MU    ', IELMT, 1, 2,MESH) ! SKIN FRICTION
      CALL BIEF_ALLVEC(1,KSP   , 'KSP   ', IELMT, 1, 2,MESH) ! SKIN ROUGHNESS
      CALL BIEF_ALLVEC(1,KS    , 'KS    ', IELMT, 1, 2,MESH) ! TOTAL ROUGHNESS
      CALL BIEF_ALLVEC(1,KSR   , 'KSR   ', IELMT, 1, 2,MESH) ! RIPPLE INDUCED ROUGHNESS
      CALL BIEF_ALLVEC(1,THETAW, 'THETAW', IELMT, 1, 2,MESH) ! WAVE VARIABLE
      CALL BIEF_ALLVEC(1,FW    , 'FW    ', IELMT, 1, 2,MESH) ! WAVE VARIABLE
      CALL BIEF_ALLVEC(1,UW    , 'UW    ', IELMT, 1, 2,MESH) ! WAVE VARIABLE
      CALL BIEF_ALLVEC(1,HW    , 'HW    ', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,TW    , 'TW    ', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,DZF_GF, 'DZF_GF', IELMT, 1, 2,MESH) ! BED LEVEL CHANGE FOR GRAIN-FEEDING
      CALL BIEF_ALLVEC(1,ACLADM, 'ACLADM', IELMT, 1, 2,MESH) ! MEAN DIAMETER IN ACTIVE LAYER
      CALL BIEF_ALLVEC(1,UNLADM, 'UNLADM', IELMT, 1, 2,MESH) ! MEAN DIAMETER IN 2ND LAYER
      CALL BIEF_ALLVEC(1,HCPL  , 'HCPL  ', IELMT, 1, 2,MESH) ! WATER DEPTH SAVED FOR CONSTANT FLOW DISCHARGE
      CALL BIEF_ALLVEC(1,ECPL  , 'ECPL  ', IELMT, 1, 2,MESH) ! EVOLUTION SAVED FOR CONSTANT FLOW DISCHARGE
      CALL BIEF_ALLVEC(1,ELAY  , 'ELAY  ', IELMT, 1, 2,MESH) ! ACTIVE LAYER THICKNESS
      CALL BIEF_ALLVEC(1,ESTRAT, 'ESTRAT', IELMT, 1, 2,MESH) ! 2ND LAYER THICKNESS
      CALL BIEF_ALLVEC(1,KX    , 'KX    ', IELMT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,KY    , 'KY    ', IELMT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,KZ    , 'KZ    ', IELMT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,UCONV , 'UCONV ', IELMT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,VCONV , 'VCONV ', IELMT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,UNORM , 'UNORM ', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,DISP  , 'DISP  ', IELMT, 3, 1,MESH)
      CALL BIEF_ALLVEC(1,DISP_C, 'DISP_C', IELMT, 3, 1,MESH)
      CALL BIEF_ALLVEC(1,MASKB , 'MASKB ', IELM0, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,MASK  , 'MASK  ', IELBT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,AFBOR , 'AFBOR ', IELBT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,BFBOR , 'BFBOR ', IELBT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,FLBOR , 'FLBOR ', IELBT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,Q2BOR , 'Q2BOR ', IELBT, 1, 1,MESH)
C     BOUNDARY FLUX FOR CALL TO CVDFTR
      CALL BIEF_ALLVEC(1,FLBOR_SIS , 'FLBORS', IELBT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,FLBORTRA  , 'FLBTRA', IELBT, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,CSTAEQ, 'CSTAEQ', IELMT, 1, 2,MESH)
!     MAK ADDITION
      CALL BIEF_ALLVEC(1,CSRATIO, 'CSRATIO', IELMT, 1, 2,MESH)
      CALL BIEF_ALLVEC(1,HN    , 'HN    ', IELMH_SIS, 1, 2,MESH) ! WATER DEPTH
      CALL BIEF_ALLVEC(1,HCLIP , 'HCLIP ', IELMH_SIS, 1, 2,MESH) ! CLIPPING WATER DEPTH
      CALL BIEF_ALLVEC(1,HPROP , 'HPROP ', IELMH_SIS, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,VOLU2D, 'VOLU2D', IELMH_SIS, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,V2DPAR, 'V2DPAR', IELMH_SIS, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,UNSV2D, 'UNSV2D', IELMH_SIS, 1, 1,MESH)
      CALL BIEF_ALLVEC(1,MPM_ARAY,'MPMARAY', IELMT, 1, 2,MESH)   ! MPM Array
      CALL BIEF_ALLVEC(1,FLULIM  ,'FLULIM' ,MESH%NSEG,1,0,MESH)
!
      IF(MSK) THEN
        CALL BIEF_ALLVEC(1,MASKEL,'MASKEL', IELM0 , 1 , 2 ,MESH)
        CALL BIEF_ALLVEC(1,MSKTMP,'MSKTMP', IELM0 , 1 , 2 ,MESH)
        CALL BIEF_ALLVEC(1,MASKPT,'MASKPT', IELMT , 1 , 2 ,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MASKEL,'MASKEL', 0 , 1 , 0 ,MESH)
        CALL BIEF_ALLVEC(1,MSKTMP,'MSKTMP', 0 , 1 , 0 ,MESH)
        CALL BIEF_ALLVEC(1,MASKPT,'MASKPT', 0 , 1 , 0 ,MESH)
      ENDIF
!
C     FOR MIXED SEDIMENTS
!
      IF(SEDCO(1).OR.SEDCO(2)) THEN
!      IF(MIXTE.OR.TASS) THEN
! CV V6.2: replacement of NCOUCH_TASS in NOMBLAY
! 
        CALL BIEF_ALLVEC(1,FLUER_VASE,'FRMIXT',IELMT,1,2,MESH)
        CALL BIEF_ALLVEC(1,TOCE_MIXTE ,'TCMIXT',
     &                   IELMT,NOMBLAY,2,MESH)
        CALL BIEF_ALLVEC(1,MS_SABLE   ,'MSSABL',
     &                   IELMT,NOMBLAY,2,MESH)
        CALL BIEF_ALLVEC(1,MS_VASE    ,'MSVASE',
     &                   IELMT,NOMBLAY,2,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,FLUER_VASE ,'FRMIXT',0,1,0,MESH)
        CALL BIEF_ALLVEC(1,TOCE_MIXTE ,'TCMIXT',0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MS_SABLE   ,'MSSABL',0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MS_VASE    ,'MSVASE',0,1,0,MESH)
      ENDIF
!... END MODIF cv
      ! *********************** !
      ! IV - INTEGER ARRAYS     ! (_IMP_)
      ! *********************** !
      CALL BIEF_ALLVEC(2, LIEBOR, 'LIEBOR', IELBOR(IELM1,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LIQBOR, 'LIQBOR', IELBOR(IELM1,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LIMTEC, 'LIMTEC', IELBOR(IELM1,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, NUMLIQ, 'NUMLIQ', IELBOR(IELM1,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, CLT   , 'CLT   ', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, CLU   , 'CLU   ', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, CLV   , 'CLV   ', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LIMDIF, 'LIMDIF', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LICBOR, 'LICBOR', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LIHBOR, 'LIHBOR', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, BOUNDARY_COLOUR,
     &                       'BNDCOL', IELBOR(IELMT,1), 1, 1,MESH)
      CALL BIEF_ALLVEC(2, LIMPRO, 'LIMPRO', IELBOR(IELMT,1), 6, 1,MESH)
      CALL BIEF_ALLVEC(2, INDIC , 'INDIC ', IELM1          , 1, 1,MESH)
      CALL BIEF_ALLVEC(2, IT1   , 'IT1   ', IELM1          , 1, 2,MESH)
      CALL BIEF_ALLVEC(2, IT2   , 'IT2   ', IELM1          , 1, 2,MESH)
      CALL BIEF_ALLVEC(2, IT3   , 'IT3   ', IELM1          , 1, 2,MESH)
      CALL BIEF_ALLVEC(2, IT4   , 'IT4   ', IELM1          , 1, 2,MESH)
! NUMBER OF LAYERS
      CALL BIEF_ALLVEC(2, NLAYER, 'NLAYE ', IELMT          , 1, 2,MESH) 

      IF(VF) THEN
        CALL BIEF_ALLVEC(2,BREACH,'BREACH',IELM1,1,2,MESH)
      ELSE
        CALL BIEF_ALLVEC(2,BREACH,'BREACH',0,1,0,MESH)
      ENDIF

      IF(MSK) THEN
        CALL BIEF_ALLVEC(2,IFAMAS,'IFAMAS',
     *                   IELM0,BIEF_NBFEL(IELM0,MESH),1,MESH)
      ELSE
        CALL BIEF_ALLVEC(2,IFAMAS,'IFAMAS',0,1,0,MESH)
      ENDIF

      ! ******************* !
      ! V - BLOCK OF ARRAYS !
      ! ******************* !
      ALLOCATE(AVAIL(NPOIN,NOMBLAY,NSICLA)) ! FRACTION OF EACH CLASS FOR EACH LAYER
      ALLOCATE(ES(NPOIN,NOMBLAY))           ! THICKNESS OF EACH CLASS
! CV
      ALLOCATE(ES_SABLE(NPOIN,NOMBLAY))           ! THICKNESS OF EACH CLASS
      ALLOCATE(ES_VASE(NPOIN,NOMBLAY))            ! THICKNESS OF EACH CLASS
! CV V6P2 ...new variables for consolidation model
      ALLOCATE(CONC(NPOIN,NOMBLAY))           ! THICKNESS OF EACH CLASS
!
      ALLOCATE(IVIDE(NPOIN,NOMBLAY+1)) ! FRACTION OF EACH CLASS FOR EACH LAYER
!
!      
!
      CALL ALLBLO(MASKTR, 'MASKTR') ! MASK OF THE BOUNDARY CONDITIONS
      CALL ALLBLO(EBOR  , 'EBOR  ') ! BOUNDARY CONDITIONS
      CALL ALLBLO(QBOR  , 'QBOR  ') ! BOUNDARY CONDITIONS
      CALL ALLBLO(AVAI  , 'AVAI  ') ! FRACTION OF EACH CLASS FOR THE TWO FIRST LAYERS
      CALL ALLBLO(LAYTHI, 'LAYTHI') ! LAYER THICKNESSES
!     V6P2 : concentration per layer for printout (CV)
      CALL ALLBLO(LAYCONC, 'LAYCONC') ! LAYER THICKNESSES
!
      CALL ALLBLO(QSCL  , 'QSCL  ') ! TRANSPORT RATE FOR EACH CLASS
      CALL ALLBLO(QSCL_C, 'QSCL_C') ! BEDLOAD TRANSPORT RATE FOR EACH CLASS
      CALL ALLBLO(QSCLXC, 'QSCLXC') ! BEDLOAD TRANSPORT RATE FOR EACH CLASS ALONG X
      CALL ALLBLO(QSCLYC, 'QSCLYC') ! BEDLOAD TRANSPORT RATE FOR EACH CLASS ALONG Y
      CALL ALLBLO(ZFCL  , 'ZFCL  ') ! EVOLUTION FOR EACH CLASS
      CALL ALLBLO(ZFCL_C, 'ZFCL_C') ! EVOLUTION FOR EACH CLASS DUE TO BEDLOAD TRANSPORT
!
      CALL ALLBLO(CBOR  , 'CBOR  ') ! BOUNDARY CONDITIONS
      CALL ALLBLO(QSCL_S, 'QSCL_S') ! SUSPENDED TRANSPORT RATE FOR EACH CLASS
      CALL ALLBLO(QSCLXS, 'QSCLXS') ! SUSPENDED TRANSPORT RATE FOR EACH CLASS ALONG X
      CALL ALLBLO(QSCLYS, 'QSCLYS') ! SUSPENDED TRANSPORT RATE FOR EACH CLASS ALONG Y
      CALL ALLBLO(ZFCL_S, 'ZFCL_S') ! EVOLUTION FOR EACH CLASS DUE TO SUSPENDED TRANSPORT
      CALL ALLBLO(FLUDP , 'FLUDP ') ! DEPOSITION FLUX
      CALL ALLBLO(FLUDPT, 'FLUDPT') ! DEPOSITION FLUX FOR IMPLICITATION
      CALL ALLBLO(FLUER , 'FLUER ') ! EROSION FLUX
      CALL ALLBLO(FLUERT, 'FLUERT') ! EROSION FLUX FOR IMPLICITATION
      CALL ALLBLO(CS    , 'CS    ') ! CONCENTRATION AT TIME N
      CALL ALLBLO(CTILD , 'CTILD ') ! CONCENTRATION AT TIME N+1/2 (=> ADVECTION STEP)
      CALL ALLBLO(CST   , 'CST   ') ! CONCENTRATION AT TIME N+1   (=> RESULT)      
!
!     V6p2 (CV)
      CALL ALLBLO(ZFCL_MS, 'ZFCL_MS') ! EVOLUTION FOR EACH CLASS DUE TO SLOPING BED EFFECTS
!
      CALL BIEF_ALLVEC_IN_BLOCK(MASKTR,5     ,1,'MSKTR ',IELBT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(EBOR  ,NSICLA,1,'EBOR  ',IELBT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QBOR  ,NSICLA,1,'QBOR  ',IELBT,1,2,MESH)
!
!     V6P2 (JMH) FLUXES AT BOUNDARY FOR EVERY CLASS
!
      CALL ALLBLO(FLBCLA,'FLBCLA')
      CALL BIEF_ALLVEC_IN_BLOCK(FLBCLA,NSICLA,1,'FLBC  ',IELBT,1,2,MESH)
!
!     JMH 18/09/09 AVAI ALLOCATED WITH SIZE 0 AND POINTING TO
!                  RELEVANT SECTIONS OF AVAIL
!
      CALL BIEF_ALLVEC_IN_BLOCK(AVAI,NOMBLAY*NSICLA,
     *                          1,'AVAI  ',0,1,0,MESH)
      DO I=1,NSICLA
        DO K=1,NOMBLAY
          AVAI%ADR(K+(I-1)*NOMBLAY)%P%R=>AVAIL(1:NPOIN,K,I)
          AVAI%ADR(K+(I-1)*NOMBLAY)%P%MAXDIM1=NPOIN
          AVAI%ADR(K+(I-1)*NOMBLAY)%P%DIM1=NPOIN
        ENDDO
      ENDDO
!
!     LAYTHI ALLOCATED WITH SIZE 0 AND POINTING TO RELEVANT SECTIONS OF ES
!
      CALL BIEF_ALLVEC_IN_BLOCK(LAYTHI,NOMBLAY,1,'LAYTHI',0,1,0,MESH)
      DO K=1,NOMBLAY
        LAYTHI%ADR(K)%P%R=>ES(1:NPOIN,K)
        LAYTHI%ADR(K)%P%MAXDIM1=NPOIN
        LAYTHI%ADR(K)%P%DIM1=NPOIN
      ENDDO
!
!     LAYCONC ALLOCATED WITH SIZE 0 AND POINTING TO RELEVANT SECTIONS OF ES
!
      CALL BIEF_ALLVEC_IN_BLOCK(LAYCONC,NOMBLAY,1,'LAYCONC',0,1,0,MESH)
      DO K=1,NOMBLAY
        LAYCONC%ADR(K)%P%R=>CONC(1:NPOIN,K)
        LAYCONC%ADR(K)%P%MAXDIM1=NPOIN
        LAYCONC%ADR(K)%P%DIM1=NPOIN
      ENDDO
!
      CALL BIEF_ALLVEC_IN_BLOCK(QSCL  ,NSICLA,1,'QSCL  ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCL_C,NSICLA,1,'QSCL_C',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCLXC,NSICLA,1,'QSCLXC',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCLYC,NSICLA,1,'QSCLYC',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(ZFCL  ,NSICLA,1,'ZFCL  ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(ZFCL_C,NSICLA,1,'ZFCL_C',IELMT,1,2,MESH)
!
      CALL BIEF_ALLVEC_IN_BLOCK(CBOR  ,NSICLA,1,'CBOR  ',IELBT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCL_S,NSICLA,1,'QSCL_S',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCLXS,NSICLA,1,'QSCLXS',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(QSCLYS,NSICLA,1,'QSCLYS',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(ZFCL_S,NSICLA,1,'ZFCL_S',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(FLUDP ,NSICLA,1,'FLUDP ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(FLUDPT,NSICLA,1,'FLUDPT',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(FLUER ,NSICLA,1,'FLUER ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(FLUERT,NSICLA,1,'FLUERT',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(CS    ,NSICLA,1,'CS    ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(CTILD ,NSICLA,1,'CTILD ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(CST   ,NSICLA,1,'CST   ',IELMT,1,2,MESH)
!
      IF(SLIDE) THEN
        CALL BIEF_ALLVEC_IN_BLOCK(ZFCL_MS,NSICLA,1,
     *                            'ZFCLMS',IELMT,1,2,MESH)
      ELSE
        CALL BIEF_ALLVEC_IN_BLOCK(ZFCL_MS,NSICLA,1,
     *                            'ZFCLMS',    0,1,0,MESH)
      ENDIF
!
!     ************* 
!     VI - MATRICES 
!     ************* 
!
!
      CALL BIEF_ALLMAT(AM1_S,'AM1_S ',IELMT,IELMT,CFG   ,'Q','Q',MESH) ! SUSPENSION WORK MATRIX
      CALL BIEF_ALLMAT(AM2_S,'AM2_S ',IELMT,IELMT,CFG   ,'Q','Q',MESH) ! SUSPENSION WORK MATRIX
      CALL BIEF_ALLMAT(MBOR ,'MBOR  ',IELBT,IELBT,CFGBOR,'Q','Q',MESH) ! SUSPENSION BOUNDRAY MATRIX
!
!
!     ****************** 
!     VII - OTHER ARRAYS 
!     ****************** 
!
!     NTR SHOULD AT LEAST BE THE NUMBER OF VARIABLES IN VARSOR THAT WILL BE READ IN
!     VALIDA. HERE UP TO THE LAYER THICKNESSES
!
!     CV V6P2 
!     NTR   = 27+(NOMBLAY+4)*NSICLA+NOMBLAY+NPRIV
      NTR   = 27+(NOMBLAY+4)*NSICLA+2*NOMBLAY+NPRIV
      IF(SLVSED%SLV == 7) NTR = MAX(NTR,2+2*SLVSED%KRYLOV)
      IF(SLVTRA%SLV == 7) NTR = MAX(NTR,2+2*SLVTRA%KRYLOV)
      IF(3*(SLVSED%PRECON/3) == SLVSED%PRECON) NTR = NTR + 2 ! IF PRECOND. BLOC-DIAG (+2 DIAG)
      IF(3*(SLVTRA%PRECON/3) == SLVTRA%PRECON) NTR = NTR + 2 ! IF PRECOND. BLOC-DIAG (+2 DIAG)
!
!     W1 NO LONGER USED (IS SENT TO CVDFTR BUT CVDFTR DOES NOTHING WITH IT)
      CALL BIEF_ALLVEC(1, W1 , 'W1    ', IELM0    , 1,1,MESH) ! WORK ARRAY
      CALL BIEF_ALLVEC(1, TE1, 'TE1   ', IELM0_SUB, 1,1,MESH) ! WORK ARRAY BY ELEMENT
      CALL BIEF_ALLVEC(1, TE2, 'TE2   ', IELM0_SUB, 1,1,MESH) ! WORK ARRAY BY ELEMENT
      CALL BIEF_ALLVEC(1, TE3, 'TE3   ', IELM0_SUB, 1,1,MESH) ! WORK ARRAY BY ELEMENT
!
      CALL ALLBLO(VARCL, 'VARCL ') ! CLANDESTINE VARIABLES
      CALL ALLBLO(PRIVE, 'PRIVE ') ! USER ARRAY
      CALL ALLBLO(TB   , 'TB    ') ! WORKING ARRAY
!
      CALL BIEF_ALLVEC_IN_BLOCK(TB   ,NTR   ,1,'T     ',IELMT,1,2,MESH)
      CALL BIEF_ALLVEC_IN_BLOCK(VARCL,NVARCL,1,'CL    ',IELMT,1,2,MESH)
      IF(NPRIV.GT.0) THEN
        CALL BIEF_ALLVEC_IN_BLOCK(PRIVE,MAX(NPRIV,4),
     *                            1,'PRIV  ',IELMT,1,2,MESH)
      ELSE
        CALL BIEF_ALLVEC_IN_BLOCK(PRIVE,4,1,'PRIV  ',0,1,0,MESH)
      ENDIF
!     TO AVOID WRITING NON-INITIALISED ARRAYS TO FILES
      CALL OS('X=0     ',X=PRIVE)
!
      ! ************ !
      ! VIII - ALIAS !
      ! ************ !
!
      T1   => TB%ADR( 1)%P ! WORK ARRAY
      T2   => TB%ADR( 2)%P ! WORK ARRAY
      T3   => TB%ADR( 3)%P ! WORK ARRAY
      T4   => TB%ADR( 4)%P ! WORK ARRAY
      T5   => TB%ADR( 5)%P ! WORK ARRAY
      T6   => TB%ADR( 6)%P ! WORK ARRAY
      T7   => TB%ADR( 7)%P ! WORK ARRAY
      T8   => TB%ADR( 8)%P ! WORK ARRAY
      T9   => TB%ADR( 9)%P ! WORK ARRAY
      T10  => TB%ADR(10)%P ! WORK ARRAY
      T11  => TB%ADR(11)%P ! WORK ARRAY
      T12  => TB%ADR(12)%P ! WORK ARRAY
      T13  => TB%ADR(13)%P ! WORK ARRAY
      T14  => TB%ADR(14)%P ! WORK ARRAY
!
!     **************************************************************
!     IX - ALLOCATES A BLOCK CONNECTING A VARIABLE NAME TO ITS ARRAY
!     **************************************************************
!
      CALL ALLBLO(VARSOR, 'VARSOR')
      CALL ADDBLO(VARSOR, U2D    )            ! 01
      CALL ADDBLO(VARSOR, V2D    )            ! 02
      CALL ADDBLO(VARSOR, HN    )             ! 03
      CALL ADDBLO(VARSOR, Z     )             ! 04
      CALL ADDBLO(VARSOR, ZF    )             ! 05
      CALL ADDBLO(VARSOR, Q     )             ! 06
      CALL ADDBLO(VARSOR, QU    )             ! 07
      CALL ADDBLO(VARSOR, QV    )             ! 08
      CALL ADDBLO(VARSOR, ZR    )             ! 09
      CALL ADDBLO(VARSOR, CHESTR)             ! 10
      CALL ADDBLO(VARSOR, TOB   )             ! 11
      CALL ADDBLO(VARSOR, HW    )             ! 12
      CALL ADDBLO(VARSOR, TW    )             ! 13
      CALL ADDBLO(VARSOR, THETAW)             ! 14
      CALL ADDBLO(VARSOR, QS    )             ! 15
      CALL ADDBLO(VARSOR, QSX   )             ! 16
      CALL ADDBLO(VARSOR, QSY   )             ! 17
      CALL ADDBLO(VARSOR, ESOMT )             ! 18
      CALL ADDBLO(VARSOR, KS)                 ! 19
      CALL ADDBLO(VARSOR, MU)                 ! 20
!     CV 2010
      CALL ADDBLO(VARSOR, ACLADM)             ! 21
! CV +1
! JWI 31/05/2012 - added line to include wave orbital velocities
      CALL ADDBLO(VARSOR, UW  )               ! 22
! JWI END
!     AVAI: FROM 23 TO 22+NOMBLAY*NSICLA
!
      DO I = 1,NOMBLAY*NSICLA
        CALL ADDBLO(VARSOR, AVAI%ADR(I)%P)
      ENDDO
! CV +1
!     QSCL: FROM 23+NOMBLAY*NSICLA TO 22+(NOMBLAY+1)*NSICLA
!
      DO I = 1, NSICLA
        CALL ADDBLO(VARSOR, QSCL%ADR(I)%P)
      ENDDO
!
!     CS: FROM 23+(NOMBLAY+1)*NSICLA TO 22+(NOMBLAY+2)*NSICLA
!
      DO I=1,NSICLA
        CALL ADDBLO(VARSOR, CS%ADR(I)%P)
      ENDDO
!     CV 2010 ! +1      
      CALL ADDBLO(VARSOR,QS_C)               ! 23+(NOMBLAY+2)*NSICLA
      CALL ADDBLO(VARSOR,QSXC)               ! 24+(NOMBLAY+2)*NSICLA
      CALL ADDBLO(VARSOR,QSYC)               ! 25+(NOMBLAY+2)*NSICLA
      CALL ADDBLO(VARSOR,QS_S)               ! 26+(NOMBLAY+2)*NSICLA
      CALL ADDBLO(VARSOR,QSXS)               ! 27+(NOMBLAY+2)*NSICLA
      CALL ADDBLO(VARSOR,QSYS)               ! 28+(NOMBLAY+2)*NSICLA
!
!     QSCL_C: FROM 29+(NOMBLAY+2)*NSICLA TO 28+(NOMBLAY+3)*NSICLA
!
      DO I=1,NSICLA
        CALL ADDBLO(VARSOR,QSCL_C%ADR(I)%P)
      ENDDO
!
!     QSCL_S: FROM 29+(NOMBLAY+3)*NSICLA TO 28+(NOMBLAY+4)*NSICLA
!
      DO I=1,NSICLA
        CALL ADDBLO(VARSOR,QSCL_S%ADR(I)%P)
      ENDDO
!
!     LAYTHI: FROM 29+(NOMBLAY+4)*NSICLA TO 28+(NOMBLAY+4)*NSICLA+NOMBLAY
!
      DO I=1,NOMBLAY
        CALL ADDBLO(VARSOR,LAYTHI%ADR(I)%P) 
      ENDDO
!
!CV   V6P2: CONC FROM  29+(NOMBLAY+4)*NSICLA+NOMBLAY TO 28+(NOMBLAY+4)*NSICLA+2*NOMBLAY
!
      DO I=1,NOMBLAY
        CALL ADDBLO(VARSOR,LAYCONC%ADR(I)%P)
      ENDDO
!
!     PRIVE: FROM 29+(NOMBLAY+4)*NSICLA+2*NOMBLAY TO
!                 28+(NOMBLAY+4)*NSICLA+MAX(4,NPRIV)+2*NOMBLAY
!
      DO I=1,MAX(4,NPRIV)
        CALL ADDBLO(VARSOR,PRIVE%ADR(I)%P)
      ENDDO
!
      IF(VARCL%N.GT.0) THEN
        DO I=1,VARCL%N
          CALL ADDBLO(VARSOR,VARCL%ADR(I)%P)
! CV 2010 +1         
! CV   V6P2   ??    
! JWI 31/05/2012 - added 1 to include wave orbital velocities
!         SORLEO(27+MAX(4,NPRIV)+NSICLA*(NOMBLAY+4)+NOMBLAY+I)=.TRUE.
          SORLEO(28+MAX(4,NPRIV)+NSICLA*(NOMBLAY+4)+2*NOMBLAY+I)=.TRUE.
! JWI END
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
! !JAJ #### IF REQUIRED, HERE WE CAN READ THE INPUT SECTIONS FILE
!      AND MODIFY NCP AND CTRLSC(1:NCP) ACCORDINGLY IN READ_SECTIONS
!
      IF(TRIM(SIS_FILES(SISSEC)%NAME).NE.'') THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*)
     &   'POINT_SISYPHE: SECTIONS DEFINIES PAR FICHIER'
        ELSEIF(LNG.EQ.2) THEN
          WRITE(LU,*)
     &   'POINT_SISYPHE: SECTIONS DEFINED IN THE SECTIONS INPUT FILE'
        ENDIF
        CALL READ_SECTIONS_SISYPHE
      ELSE ! THE PREVIOUS WAY OF DOING THINGS
        IF(NCP.NE.0) THEN
          IF(LNG.EQ.1) THEN
            WRITE(LU,*)
     &      'POINT_SISYPHE: SECTIONS DEFINED IN THE PARAMETER FILE'
          ELSEIF(LNG.EQ.2) THEN
            IF(NCP.NE.0) WRITE(LU,*)
     &      'POINT_SISYPHE: SECTIONS DEFINED IN THE PARAMETER FILE'
          ENDIF
        ENDIF
      ENDIF
!
      IF(LNG == 1) WRITE(LU,21)
      IF(LNG == 2) WRITE(LU,22)
!
11    FORMAT(1X,///,21X,'*******************************',/,
     &21X,              '* ALLOCATION DE LA MEMOIRE    *',/,
     &21X,              '*******************************',/)
21    FORMAT(1X,///,21X,'****************************************',/,
     &21X,              '* FIN DE L''ALLOCATION DE LA MEMOIRE  : *',/,
     &21X,              '****************************************',/)

12    FORMAT(1X,///,21X,'*******************************',/,
     &21X,              '*     MEMORY ORGANISATION     *',/,
     &21X,              '*******************************',/)
22    FORMAT(1X,///,21X,'*************************************',/,
     &21X,              '*    END OF MEMORY ORGANIZATION:    *',/,
     &21X,              '*************************************',/)
C
C-----------------------------------------------------------------------
C
      RETURN
      END
