
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief  

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Development history
!>   <br><table>
!> <tr><th> Release </th><th> Date </th><th> Author </th><th> Notes </th></tr>
!>  <tr><td><center> 6.0                                       </center>
!>    </td><td> 21/08/2010
!>    </td><td> N.DURAND (HRW), S.E.BOURBAN (HRW)
!>    </td><td> Creation of DOXYGEN tags for automated documentation and cross-referencing of the FORTRAN sources
!>   </td></tr>
!>  <tr><td><center> 6.0                                       </center>
!>    </td><td> 13/07/2010
!>    </td><td> N.DURAND (HRW), S.E.BOURBAN (HRW)
!>    </td><td> Translation of French comments within the FORTRAN sources into English comments
!>   </td></tr>
!>      <tr>
!>      <td><center> 6.0                                       </center>
!> </td><td> 05/05/2010
!> </td><td> J-M HERVOUET (LNHE) 01 30 87 80 18
!> </td><td> K-OMEGA MODEL BY HOLGER WEILBEER (ISEB/UHA)
!>           NOW AT BAW HAMBURG
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> 16/02/2010
!> </td><td> JMH
!> </td><td> ZCHAR INSTEAD OF ZSTAR IN CALL TO DERI3D
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> 26/08/2009
!> </td><td> JMH
!> </td><td> VOLU3D INSTEAD OF VOLU AND VOLUN IN THE CALLS TO CVDF3D
!>           FOR U, V AND W
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> **/03/1999
!> </td><td> JACEK A. JANKOWSKI PINXIT
!> </td><td> FORTRAN95 VERSION
!> </td></tr>
!>  </table>

C
C#######################################################################
C
                          SUBROUTINE TELEMAC3D
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE BIEF
      USE DECLARATIONS_TELEMAC
      USE DECLARATIONS_TELEMAC3D
      USE INTERFACE_TELEMAC3D
      USE INTERFACE_TELEMAC2D
      USE INTERFACE_SISYPHE, ONLY: SISYPHE
      USE INTERFACE_TOMAWAC, ONLY: WAC
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!-----------------------------------------------------------------------
C DECLARATIONS
!-----------------------------------------------------------------------
C DECLARES VARIABLES FOR PARALLEL MODE LOCALLY
!
      DOUBLE PRECISION P_TIME
      INTEGER P_IMAX
      EXTERNAL P_TIME,P_IMAX
!
!-----------------------------------------------------------------------
C DECLARES LOCAL VARIABLES FOR TELEMAC3D
!-----------------------------------------------------------------------
!
      INTEGER LT,DATE(3),TIME(3)
      INTEGER ITRAC, NVARCL, NVAR, ISOUSI
      INTEGER SCHDVI_HOR,SCHDVI_VER,SCHCVI_HOR,SCHCVI_VER
      INTEGER, PARAMETER :: NSOR = 26 ! HERE MAXVAR FOR 2D
      INTEGER ALIRE2D(MAXVAR),TROUVE(MAXVAR+10),ALIRE3D(MAXVAR)
      INTEGER IBID,I,K,I3D,IP
!
      DOUBLE PRECISION LAMBD0,TETADIVER
      DOUBLE PRECISION UMIN,  UMAX,  SIGMAU, VMIN,  VMAX, SIGMAV
      DOUBLE PRECISION WMIN,  WMAX,  SIGMAW
      DOUBLE PRECISION TAMIN, TAMAX, SIGMTA,TETATRA
!
      DOUBLE PRECISION HIST(1)
      DATA HIST /9999.D0/
!
      LOGICAL CLUMIN, CLUMAX, CLVMIN, CLVMAX, CLWMIN, CLWMAX
      LOGICAL CTAMIN, CTAMAX, YASEM3D,YAS0U,YAS1U
      LOGICAL CLKMIN, CLKMAX, CLEMIN, CLEMAX
      LOGICAL TRAC,YAWCHU,NEWDIF,LBID,BC,CHARR,SUSP
!
      CHARACTER(LEN=24), PARAMETER :: CODE1='TELEMAC3D               '
      CHARACTER(LEN=16) FORMUL
!
      INTRINSIC MOD
!
      TYPE(SLVCFG) :: SLVD
!
      DOUBLE PRECISION, POINTER, DIMENSION(:) :: SAVEZ
!
!=======================================================================
!
C  VARIABLES TO BE READ WHEN SUITE IS CALLED:
C  0 : DISCARD    1 : READ  (SAME NUMBERING AS IN NOMVAR)
!
C                  U V   H   ZF
      DATA ALIRE2D/1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/
!
C     IN 3D FILES
C                  Z U V W       K E     DP
      DATA ALIRE3D/1,1,1,1,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     &             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/
!
C     READS TRACERS IN PREVIOUS FILES
C     !!! WARNING: 14 BELOW IS NEXT IN NOMVAR,
C                 MAY CHANGE IF VARIABLES ARE ADDED IN NOMVAR
!
      IF(NTRAC.GT.0) THEN
        DO I=14,14+NTRAC-1
          ALIRE3D(I)=1
        ENDDO
      ENDIF
!
!=======================================================================
! FOR COMPUTING FLUXES OF ADVECTED VARIABLES
!=======================================================================
!
!     NO FLUX COMPUTED FOR U,V,W,K,EPSILON
      DO I=1,5
        CALCFLU(I)=.FALSE.
      ENDDO
!     DEPENDING ON BILMAS FOR TRACERS
      IF(NTRAC.GT.0) THEN
        DO I=6,5+NTRAC
          CALCFLU(I)=BILMAS
        ENDDO
      ENDIF
!
!=======================================================================
! FOR TAKING INTO ACCOUNT RAIN IN ADVECTION OF VARIOUS VARIABLES
!=======================================================================
!
!     NO RAIN FOR U,V,W,K,EPSILON
      DO I=1,5
        CALCRAIN(I)=.FALSE.
      ENDDO
!     DEPENDING OF RAIN FOR TRACERS
      IF(NTRAC.GT.0) THEN
        DO I=6,5+NTRAC
          CALCRAIN(I)=RAIN
        ENDDO
      ENDIF
!
!=======================================================================
! INITIALISATION: READS, PREPARES AND CHECKS
!=======================================================================
!
      LT     = 0       ! INITIALISES TIMESTEP
C     INITIALISES NUMBER OF SUB-ITERATIONS, LOOK IN PRECON
      ISOUSI = 0
      NVARCL = 0
      IF(NTRAC.GT.0) THEN
        TRAC=.TRUE.
      ELSE
        TRAC=.FALSE.
      ENDIF
!
!     DATE AND TIME (SO FAR NOT A KEYWORD IN TELEMAC-3D)
!
      DATE(1) = 0      
      DATE(2) = 0     
      DATE(3) = 0
      TIME(1) = 0
      TIME(2) = 0
      TIME(3) = 0
!
      INFOGR = LISTIN
!
!-----------------------------------------------------------------------
!
C 2D BOUNDARY CONDITIONS:
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE LECLIM'
      CALL LECLIM
     & (LIHBOR%I,LIUBOL%I,LIVBOL%I,IT4%I,HBOR%R,UBOR2D%R,VBOR2D%R,
     &  T2_01%R,T2_02%R,T2_03%R,T2_04%R,NPTFR2,3,.FALSE.,
     &  T3D_FILES(T3DCLI)%LU,
     &  KENT,KENTU,KSORT,KADH,KLOG,KINC,NUMLIQ%I,MESH2D)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE LECLIM'
!
C MESH ORGANISATION - 2D LEVEL
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE INBIEF POUR MESH2D'
      CALL INBIEF(LIHBOR%I,KLOG,IT1,IT2,IT3,
     &            LVMAC,IELMX,LAMBD0,SPHERI,MESH2D,
     &            T2_01,T2_02,OPTASS2D,PRODUC,EQUA)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE INBIEF'
!
C CORRECTS THE NORMAL VECTORS AT THE POINTS
C WHERE LIQUID AND SOLID BOUNDARIES MEET
!
      CALL CORNOR(MESH2D%XNEBOR%R,MESH2D%YNEBOR%R,
     &            MESH2D%XSGBOR%R,MESH2D%YSGBOR%R,
     &            MESH2D%KP1BOR%I,NPTFR2,KLOG,LIHBOR%I,
     &            T2_01,T2_02,MESH2D)
!
C 3D BOUNDARY CONDITIONS (SO FAR SAME FILE AS 2D)
C T2_02 IS AUBOR IN T2D, COULD BE KEPT
C THIS TIME BOUNDARY COLOURS ARE READ
!
      CALL LECLIM
     & (LIHBOR%I,LIUBOL%I,LIVBOL%I,LITABL%ADR(1)%P%I,
     &  HBOR%R,UBORL%R,VBORL%R,TABORL%ADR(1)%P%R,AUBORL%R,
     &  ATABOL%ADR(1)%P%R,BTABOL%ADR(1)%P%R,
     &  NPTFR2,3,TRAC,T3D_FILES(T3DCLI)%LU,KENT,KENTU,
     &  KSORT,KADH,KLOG,KINC,
     &  NUMLIQ%I,MESH3D,BOUNDARY_COLOUR%I)
!
C MESH ORGANISATION - 3D LEVEL
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE INBIEF POUR MESH3D'
      CALL INBIEF(LIHBOR%I,KLOG,IT1,IT2,IT3,
     &            LVMAC,IELM3,LAMBD0,SPHERI,MESH3D,
     &            T3_01,T3_02,OPTASS,PRODUC,EQUA)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE INBIEF'
!
C INITIALISES 3D BOUNDARY CONDITION ATTRIBUTES FOR BOUNDARY NODES
C DUPLICATES 2D CONDITIONS ON THE VERTICAL
!
      CALL LIMI3D
!
C COMPLETES IFABOR IN 3D
!
      CALL IFAB3D
     & (MESH3D%IFABOR%I, LIUBOF%I, LIUBOL%I, LIUBOS%I,
     &  MESH2D%KP1BOR%I, MESH2D%NELBOR%I,
     &  MESH3D%NULONE%I, IKLE2%I,
     &  NELEM2, NPOIN2, NPTFR2, NPLAN, NPLINT, NETAGE,
     &  KLOG,TRANSF)
!
C CONTROLS MESH
!
      CALL CHECK
     & (IKLE2%I, NBOR2%I, MESH2D%NELBOR%I, MESH3D%IKLBOR%I,
     &  IKLE3%I, MESH3D%NELBOR%I, MESH3D%NULONE%I, NBOR3%I,
     &  NELEM2, NPOIN2, NPTFR2, NETAGE, NELEM3, NPTFR3, NTRAC,
     &  LISTIN )
!
C LOOKS FOR THE BOTTOM AND BOTTOM FRICTION VARIABLES IN THE GEOMETRY FILE
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE FONSTR'
      CALL FONSTR(T2_01,ZF,T2_02,RUGOF,T3D_FILES(T3DGEO)%LU,
     &            T3D_FILES(T3DFON)%LU,T3D_FILES(T3DFON)%NAME,
     &            MESH2D,RUGOF0,LISTIN)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE FONSTR'
      IF(RUGOF%ELM.NE.11) CALL CHGDIS(RUGOF,11,RUGOF%ELM,MESH2D)
!
C INITIALISES PRIVATE VECTOR BLOCK
!
      IF(NPRIV.GT.0) CALL OS('X=0     ',X=PRIVE)
!
!-----------------------------------------------------------------------
C CORRECTS THE BOTTOM
!
C  - SMOOTHES ACCORDING TO THE LISFON VALUE
C  - CHANGES THE BOTTOM TOPOGRAPHY (FORTRAN)
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CORFON'
      CALL CORFON(ZF,T2_01,T2_02,ZF%R,T2_01%R,T2_02%R,
     &            X,Y,PRIVE,NPOIN2,LISFON,.FALSE.,MASKEL,
     &            MATR2H,MESH2D,SVIDE)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CORFON'
!
C FINELY ANALYSES THE BATHYMETRY
C IN T2D CALLED IF (OPTBAN == 2)
!
      IF(MSK) CALL TOPOGR(ZF%R,T2_01%R,ZFE%R,IKLE2%I,MESH2D%IFABOR%I,
     &  MESH2D%NBOR%I, MESH2D%NELBOR%I, MESH2D%NULONE%I,
     &  IT1%I, IT2%I, IT3%I, NELEM2, NPTFR2, NPOIN2, MXPTVS2)
!
!=======================================================================
C VARIOUS INITIALISATIONS
!=======================================================================
!
C     COUNTS THE LIQUID BOUNDARIES
!
      IF(NCSIZE.GT.1) THEN
       NFRLIQ=0
       DO I=1,NPTFR2
         NFRLIQ=MAX(NFRLIQ,NUMLIQ%I(I))
       ENDDO
       NFRLIQ=P_IMAX(NFRLIQ)
       WRITE(LU,*) ' '
       IF(LNG.EQ.1) WRITE(LU,*) 'NOMBRE DE FRONTIERES LIQUIDES :',NFRLIQ
       IF(LNG.EQ.2) WRITE(LU,*) 'NUMBER OF LIQUID BOUNDARIES:',NFRLIQ
      ELSE
       IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE FRONT2'
       CALL FRONT2(NFRLIQ,NFRSOL,DEBLIQ,FINLIQ,DEBSOL,FINSOL,
     &             LIHBOR%I,LIUBOL%I,X,Y,NBOR2%I,MESH2D%KP1BOR%I,
     &             IT1%I,NPOIN2,NPTFR2,KLOG,LISTIN,NUMLIQ%I,MAXFRO)
       IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE FRONT2'
      ENDIF
!
!     3D EXTENSION OF NUMLIQ
!
      DO I=2,NPLAN
        DO K=1,NPTFR2
          IP=(I-1)*NPTFR2+K
          NUMLIQ%I(IP)=NUMLIQ%I(K)
        ENDDO
      ENDDO
C
C=======================================================================
C
C     READS THE STAGE-DISCHARGE CURVES FILE
C
      IF(T3D_FILES(T3DPAR)%NAME(1:1).NE.' ') THEN
        CALL T3D_READ_FIC_CURVES(T3D_FILES(T3DPAR)%LU,NFRLIQ,
     &                           STA_DIS_CURVES,PTS_CURVES)
      ENDIF
!
C     SETS TURBULENCE CONSTANTS (ALL MODELS)
!
      CALL CSTKEP(KARMAN,CMU,C1,C2,SIGMAK,SIGMAE,VIRT,SCHMIT,
     &            KMIN,KMAX,EMIN,EMAX,PRANDTL,ALPHA,BETA,BETAS,OMSTAR,
     &            ITURBV)
!
C INITIALISES DILATATION COEFFICIENTS AND REFERENCE VALUES
C FOR ALL ACTIVE TRACERS, DEFAULT RHO = RHO0
!
!
C COMPUTES VERTICAL AND HORIZONTAL CORIOLIS PARAMETERS
!
      IF(NONHYD .AND. CORIOL) CALL CORPAR (FVER, FHOR, PHILAT)
!
!-----------------------------------------------------------------------
C READS INITIAL CONDITIONS FROM A PREVIOUS 3D COMPUTATION FILE
C OR SETS THEM IN FORTRAN
!
      AKEP = .TRUE.
      AKOM = .TRUE.
!
C     STARTS FROM A 2D FILE (U,V AND H ARE READ TO BE USED IN CONDIM)
C                            AT IS ALSO INITIALISED
!
      IF(DEBU.AND.SUIT2) THEN
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE SUITE AVEC UN FICHIER 2D'
         CALL BIEF_SUITE(VARSOR,VARCL,IBID,
     &                   T3D_FILES(T3DBI1)%LU,T3D_FILES(T3DBI1)%FMT,
     &                   HIST,0,NPOIN2,AT,TEXTPR,VARCLA,
     &                   NVARCL,TROUVE,ALIRE2D,LISTIN,.TRUE.,MAXVAR)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SUITE'
      ENDIF
!
C     COPIES THE BOTTOM TOPOGRAPHY INTO Z (= MESH3D%Z%R)
C    (IF IT IS A CONTINUATION, Z WILL BE ALSO FOUND
C     IN THE PREVIOUS RESULTS FILE. ANYWAY THE COPY IS USEFUL HERE
C     TO AVOID A CRASH IN CONDIM)
!
      CALL OV('X=Y     ',Z(1:NPOIN2),ZF%R,ZF%R,0.D0,NPOIN2)
!
C     NOW CALLS CONDIM EVEN IF A COMPUTATION IS CONTINUED
C    (DONE TO RETRIEVE ZSTAR)
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CONDIM'
      CALL CONDIM
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CONDIM'
!
C     COMPUTES TRANSF AND ZCHAR
!
      CALL TRANSF_ZCHAR(TRANSF,ZCHAR,ZSTAR,TRANSF_PLANE,NPLAN)
C     DETERMINES THE KIND OF TRANSFORMATION
!
C     1: CLASSICAL SIGMA TRANSFORMATION
C     2: SIGMA TRANSFORMATION WITH GIVEN PROPORTIONS
C     3: GENERALISED SIGMA TRANSFORMATION
!
C     IF(TRANSF.NE.0) THEN
C       TRANSF=1
C       DO I=2,NPLAN
C         IF(TRANSF_PLANE%I(I).EQ.2) THEN
C           TRANSF=2
C         ENDIF
C       ENDDO
C       DO I=2,NPLAN
C         IF(TRANSF_PLANE%I(I).EQ.3) TRANSF=3
C       ENDDO
C     ENDIF
!
C     CLIPS POSSIBLE NEGATIVE DEPTHS SET BY USER
!
      CALL OS('X=+(Y,C)',X=H,Y=H,C=0.D0)
!
C     IF COMPUTATION CONTINUED, RETRIEVES SOME VARIABLES + Z + DEPTH
!
      IF(.NOT.DEBU) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE SUITE'
        CALL BIEF_SUITE(VARSO3,VARCL,IBID,
     &                  T3D_FILES(T3DPRE)%LU,T3D_FILES(T3DPRE)%FMT,
     &                  HIST,0,NPOIN3,AT,TEXTP3,VARCLA,NVARCL,
     &                  TROUVE,ALIRE3D,LISTIN,.TRUE.,MAXVAR,NPLAN)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SUITE'
!
        IF(RAZTIM) THEN
          AT=0.D0
          IF(LNG.EQ.1) WRITE(LU,*) 'TEMPS ECOULE REMIS A ZERO'
          IF(LNG.EQ.2) WRITE(LU,*) 'ELAPSED TIME RESET TO ZERO'
        ENDIF
!
        DO K=1,NPOIN2
          H%R(K)=Z(K+NPOIN2*(NPLAN-1))-Z(K)
          ZF%R(K)=Z(K)
        ENDDO
!
C       SEE VARSO3 IN POINT FOR INDICES 8 AND 9 (K AND EPSILON)
        IF(TROUVE(8).EQ.1.AND.TROUVE(9).EQ.1) THEN
          AKEP=.FALSE.
        ENDIF
!
      ENDIF
!
C     INITIALISES SEDIMENT PROPERTIES
!
      IF(SEDI) THEN
        IF(T3D_FILES(T3DSUS)%NAME(1:1).EQ.' ') THEN
          CALL CONDIS(IVIDE%R,EPAI%R,TREST,CONC%R,TEMP%R,HDEP%R,
     &                ZR%R,ZF%R,X,Y,NPOIN2,NPOIN3,NPF%I,NPFMAX,
     &                NCOUCH,TASSE,GIBSON,PRIVE,CONSOL)
C
        ELSE
          CALL SUISED(IVIDE%R,EPAI%R,HDEP%R,CONC%R,TEMP%R,FLUER%R,
     &                PDEPO%R,ZR%R,ZF%R,NPF%I,
     &                NPOIN2,NPOIN3,NPFMAX,NCOUCH,TASSE,GIBSON,
     &                T3D_FILES(T3DSUS)%LU,BISUIS)
        ENDIF
C       SO FAR CONSTANT MEAN DIAMETER=D50
        CALL OS('X=C     ',X=DMOY,C=D50)
      ENDIF
C
C CLIPS H AND COMPUTES Z, HPROP AND ZPROP
C NOTE : HMIN = -1000.0 IN DICTIONARY BUT HMIN IS AT LEAST 0.0
C        IF OPTBAN=2
C
      IF(OPTBAN.EQ.2) THEN
        CALL CLIP (H, HMIN, .TRUE., 1.D6, .FALSE., 0)
      ENDIF
C
      CALL CALCOT(Z,H%R)
      CALL OV ( 'X=Y     ',ZPROP%R(1:NPOIN2),Z3%R(1:NPOIN2),
     &                     Z3%R(1:NPOIN2),0.D0,NPOIN2)
!
!-----------------------------------------------------------------------
C MASKING:
!
      IF(MSK) THEN
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MASK3D'
        CALL MASK3D(MESH3D%IFABOR%I,MASKEL%R,MASKPT,MASKBR%R,
     &              X2%R,Y2%R,ZF%R,ZFE%R,H%R,HMIN,AT,LT,IT1%I,
     &              MESH3D%NELBOR%I,NELMAX2,NELEM2,NPOIN2,NPTFR2,
     &              NPLAN,NETAGE,IELM3,MESH2D)
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MASK3D'
      ENDIF
!
C MESH FOR PROPAGATION
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MESH_PROP'
      CALL MESH_PROP(HPROP,H,H,PROLIN,HAULIN,TETAH,NSOUSI,ZPROP,
     &               IPBOT,NPOIN2,NPLAN,OPTBAN,SIGMAG,OPT_HNEG,
     &               MDIFF,MESH3D,VOLU3D,VOLU3DPAR,
     &               UNSV3D,MSK,MASKEL,IELM3)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE MESH_PROP'
!
C INITIALISES THE MEAN VELOCITY IN 2D
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VERMOY'
      CALL VERMOY(U2D%R,V2D%R,U%R,V%R,2,Z,
     &            T3_01%R,T3_02%R,T3_03%R,1,NPLAN,NPOIN2,NPLAN,OPTBAN)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VERMOY'
!
!-----------------------------------------------------------------------
C HARMONISES  BOUNDARY CONDITIONS
C INITIALISES BOUNDARY CONDITIONS FOR TELEMAC
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE LICHEK'
      CALL LICHEK(LIMPRO%I,NPTFR2)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE LICHEK'
!
!-----------------------------------------------------------------------
C INITIALISES THE VOLUMES ASSOCIATED WITH THE NODES
!
      CALL VECTOR(VOLU, '=', 'MASBAS          ',IELM3,1.D0-AGGLOH,
     &  SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,MESH3D,.FALSE.,MASKEL)
      IF(AGGLOH.GT.1.D-6) THEN
        CALL VECTOR(VOLU, '+', 'MASBAS2         ',IELM3,AGGLOH,
     &  SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,MESH3D,.FALSE.,MASKEL)
      ENDIF
!
      CALL OS('X=Y     ',X=VOLUN,Y=VOLU)
!
      IF(NCSIZE.GT.1) THEN
        CALL OS('X=Y     ',X=VOLUPAR,Y=VOLU)
        CALL PARCOM(VOLUPAR,2,MESH3D)
        CALL OS('X=Y     ',X=VOLUNPAR,Y=VOLUPAR)
      ENDIF
!
!     IN 2D
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MASBAS2D'
      CALL MASBAS2D(VOLU2D,V2DPAR,UNSV2D,
     &              IELM2H,MESH2D,MSK,MASKEL,T2_01,SVIDE)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE MASBAS2D'
!
!-----------------------------------------------------------------------
C FREE SURFACE AND BOTTOM GRADIENTS
C INITIALISES DSSUDT = 0
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE GRAD2D'
      CALL GRAD2D(GRADZF%ADR(1)%P,GRADZF%ADR(2)%P,ZPROP,NPLAN,SVIDE,
     *            UNSV2D,T2_02,T2_03,T2_04,IELM2H,MESH2D,MSK,MASKEL)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE GRAD2D'
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE FSGRAD'
      CALL FSGRAD(GRADZS,ZFLATS,Z(NPOIN3-NPOIN2+1:NPOIN3),
     &            ZF,IELM2H,MESH2D,MSK,MASKEL,
     &            UNSV2D,T2_01,NPOIN2,OPTBAN,SVIDE)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE FSGRAD'
!
      CALL OS('X=C     ',X=DSSUDT,C=0.D0)
!
C INITIALISES THE METEOROLOGICAL VARIABLES
!
      IF (VENT.OR.ATMOS) CALL METEO
     &   (PATMOS%R, WIND%ADR(1)%P%R, WIND%ADR(2)%P%R, FUAIR, FVAIR,
     &    X2%R, Y2%R, AT, LT, NPOIN2, VENT, ATMOS, H%R, T2_01%R,
     &    GRAV, RHO0, 0.D0, PRIVE)
!
!-----------------------------------------------------------------------
C INITIALISES K AND EPSILON
C IF AKEP = .FALSE. K AND EPSILON HAVE BEEN GIVEN IN LECSUI OR CONDIM
!
      IF (ITURBV.EQ.3.AND.AKEP) CALL KEPINI(AK%R,EP%R,U%R,V%R,Z,
     &             ZF%R,NPOIN2,NPLAN,DNUVIH,DNUVIV,KARMAN,CMU,KMIN,EMIN)
!
      IF(ITURBV.EQ.7.AND.AKOM) THEN
        CALL OS('X=C     ',X=AK,C=KMIN)
        CALL OS('X=C     ',X=EP,C=EMIN)
        CALL OS('X=0     ',X=ROTAT)
      ENDIF
!
!-----------------------------------------------------------------------
!
C COMPUTES (DELTA RHO)/RHO FOR THE INITIAL OUTPUT
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE DRSURR'
      CALL DRSURR(DELTAR,TA,BETAC,T0AC,T3_01,RHO0,RHOS,DENLAW,SEDI,
     &            NTRAC,IND_T,IND_S)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE DRSURR'
!
!-----------------------------------------------------------------------
!
C INITIALISES U* FOR OUTPUT OF INITIAL CONDITIONS AND SISYPHE
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE COEFRO'
      CALL COEFRO(CF,H,U2D,V2D,KARMAN,KFROT,RUGOF,GRAV,MESH2D,T2_01)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE COEFRO'
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE TFOND'
      CALL TFOND(AUBORF%R,CF%R,U2D%R,V2D%R,U%R,V%R,W%R,KARMAN,
     &           LISRUF,DNUVIV,Z,NPOIN2,KFROT,RUGOF%R,UETCAR%R,
     &           NONHYD,OPTBAN,HN%R,GRAV,IPBOT%I,NPLAN)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TFOND'
!
!-----------------------------------------------------------------------
!
C COMPUTES THE VISCOSITIES VISCVI AND VISCTA
!
      IF(ITURBH.EQ.1.OR.ITURBV.EQ.1) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCOS'
        CALL VISCOS(VISCVI,VISCTA,DNUTAV,DNUTAH,
     &              DNUVIV,DNUVIH,NTRAC,ITURBH,ITURBV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCOS'
!
      ENDIF
!
      IF(ITURBV.EQ.2) THEN
!
         IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCLM'
         CALL VISCLM(VISCVI,VISCTA,RI,U,V,DELTAR,X3,Y3,Z3,H,
     &               T3_01, T3_02, T3_03, T3_04, T3_05, T3_06, T3_07,
     &               SVIDE, MESH3D, IELM3, GRAV, NPLAN,
     &               NPOIN3, NPOIN2, NTRAC, MSK, MASKEL,
     &               TA,MIXING,DAMPING,IND_T,DNUVIV,DNUTAV,KARMAN,
     &               PRANDTL,UETCAR,KFROT,RUGOF,ZF)
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCLM'
!
      ENDIF
!
      IF(ITURBV.EQ.3.OR.ITURBH.EQ.3) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCKE'
C       FOR FIRST PRINTOUT (RI ONLY DONE IN SOUKEP LATER)
        CALL OS('X=0     ',X=RI)
        CALL VISCKE(VISCVI,VISCTA,AK,EP,NTRAC,CMU,
     &              DNUVIH,DNUVIV,DNUTAH,DNUTAV,KMIN,EMIN,
     &              ITURBH,ITURBV,PRANDTL)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCKE'
!
      ENDIF
!
      IF(ITURBH.EQ.4) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISSMA'
        CALL VISSMA(VISCVI,VISCTA,DNUTAH,DNUVIH,DNUVIV,DNUTAV,
     &              U,V,W,T3_01,T3_02,T3_03,T3_04,T3_05,T3_06,
     &              SVIDE,MESH3D,
     &              IELM3,NTRAC,MSK,MASKEL,ITURBV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISSMA'
!
      ENDIF
!
      IF(ITURBV.EQ.7) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCKO'
        CALL VISCKO(VISCVI,VISCTA,ROTAT,AK,EP,NTRAC,CMU,
     &              DNUVIH,DNUVIV,DNUTAH,DNUTAV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCKO'
!
      ENDIF
!
      IF(OPTBAN.EQ.1) THEN
!
        CALL VISCLIP(VISCVI,VISCTA,H,NPLAN,NPOIN3,NPOIN2,NTRAC)
!
      ENDIF
!
!-----------------------------------------------------------------------
C FLOATS (EHM... TRACERS...)
!
      IF (NFLOT.NE.0) CALL FLOT3D
     &   (XFLOT%R, YFLOT%R, ZFLOT%R, NFLOT, NITFLO, FLOPRD, X, Y, Z,
     &    NPOIN3, DEBFLO%I, FINFLO%I, NIT)
!
!------------------------------------
C PREPARES THE 3D OUTPUT FILE :
!------------------------------------
!
C     OUTPUT FOR THE INITIAL CONDITIONS
!
      IF (INFOGR) CALL MITTIT(1,AT,LT)
!
C     PREPARES THE 2D AND 3D OUTPUT FOR INITIAL CONDITIONS
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE PRERES_TELEMAC3D'
      CALL PRERES_TELEMAC3D(LT)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE PRERES_TELEMAC3D'
!
!-----------------------------------------------------------------------
!
C     COUPLING WITH DELWAQ
!
      IF(INCLUS(COUPLING,'DELWAQ')) THEN
!
         IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE TEL4DEL'
         CALL TEL4DEL(NPOIN3,NPOIN2,NELEM3,MESH2D%NSEG,IKLE2%I,
     &   MESH2D%ELTSEG%I,MESH2D%GLOSEG%I,MESH2D%ORISEG%I,
     &   MESH2D%GLOSEG%DIM1,X,Y,MESH3D%NPTFR,LIHBOR%I,MESH3D%NBOR%I,
     &   NPLAN,AT,DT,LT,NIT,H%R,HPROP%R,MESH3D%Z%R,U%R,V%R,
     &   TA%ADR(MAX(IND_S,1))%P%R,
     &   TA%ADR(MAX(IND_T,1))%P%R,VISCVI%ADR(3)%P%R,TITCAS,
     &T3D_FILES(T3DGEO)%NAME,T3D_FILES(T3DCLI)%NAME,WAQPRD,
     &T3D_FILES(T3DDL1)%LU,T3D_FILES(T3DDL1)%NAME,T3D_FILES(T3DDL2)%LU,
     &T3D_FILES(T3DDL2)%NAME,T3D_FILES(T3DDL3)%LU,
     &T3D_FILES(T3DDL3)%NAME,T3D_FILES(T3DDL5)%LU,
     &T3D_FILES(T3DDL5)%NAME,
     &   T3D_FILES(T3DDL6)%LU,T3D_FILES(T3DDL6)%NAME,
     &   T3D_FILES(T3DDL7)%LU,T3D_FILES(T3DDL7)%NAME,
     &   T3D_FILES(T3DL11)%LU,T3D_FILES(T3DL11)%NAME,
     &   T3D_FILES(T3DDL4)%LU,T3D_FILES(T3DDL4)%NAME,
     &   T3D_FILES(T3DDL8)%LU,T3D_FILES(T3DDL8)%NAME,
     &T3D_FILES(T3DDL9)%LU,T3D_FILES(T3DDL9)%NAME,T3D_FILES(T3DL10)%LU,
     &T3D_FILES(T3DL10)%NAME,INFOGR,NELEM2,SALI_DEL,TEMP_DEL,VELO_DEL,
     &DIFF_DEL,MARDAT,MARTIM,FLODEL%R,.TRUE.,MESH3D%W%R,.FALSE.,
     &FLULIM%R,V2DPAR%R,MESH2D%KNOLG%I,MESH2D,MESH3D)
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TEL4DEL'
!
      ENDIF
!
C     3D OUTPUT
!
      CALL CREATE_DATASET(T3D_FILES(T3DRES)%FMT, ! RESULT FILE FORMAT
     &                    T3D_FILES(T3DRES)%LU,  ! RESULT FILE LU
     &                    TITCAS,     ! TITLE
     &                    MAXVA3,     ! MAX NUMBER OF OUTPUT VARIABLES
     &                    TEXT3,      ! NAMES OF OUTPUT VARIABLES
     &                    SORG3D)     ! OUTPUT OR NOT
      CALL WRITE_MESH(T3D_FILES(T3DRES)%FMT, ! RESULT FILE FORMAT
     &                T3D_FILES(T3DRES)%LU,  ! RESULT FILE LU
     &                MESH3D,          ! MESH
     &                NPLAN,           ! NUMBER OF PLANE /NA/
     &                DATE,            ! START DATE
     &                TIME,            ! START HOUR
     &                I_ORIG,J_ORIG)   ! COORDINATES OF THE ORIGIN
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE DESIMP'
       CALL BIEF_DESIMP(T3D_FILES(T3DRES)%FMT,VARSO3,
     &                  HIST,0,NPOIN3,T3D_FILES(T3DRES)%LU,'STD',AT,LT,
     &                  LISPRD,GRAPRD,
     &                  SORG3D,SORIM3,MAXVA3,TEXT3,GRADEB,LISDEB)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE DESIMP'
!
C     SEDIMENTOLOGY OUTPUT
!
      IF(SEDI.AND.T3D_FILES(T3DSED)%NAME(1:1).NE.' ') THEN
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE DESSED'
        CALL DESSED(NPF%I,IVIDE%R,EPAI%R,HDEP%R,
     &              CONC%R,TEMP%R,ZR%R,NPOIN2,NPFMAX,
     &              NCOUCH,NIT,GRAPRD,LT,DTC,TASSE,GIBSON,
     &              T3D_FILES(T3DSED)%LU,TITCAS,BIRSED,0)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE DESSED'
      ENDIF
!
C PREPARES THE 2D OUTPUT FILE : NHYD CHANNEL, NSOR VARIABLES (?)
!
      NVAR = NSOR
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE ECRGEO'
      CALL CREATE_DATASET(T3D_FILES(T3DHYD)%FMT, ! FORMAT FICHIER RESULTAT
     &                    T3D_FILES(T3DHYD)%LU,  ! LU FICHIER RESULTAT
     &                    TITCAS,     ! TITRE DE L'ETUDE
     &                    MAXVAR,     ! MAX VARIABLES SORTIE
     &                    TEXTE,      ! NOMS VARIABLES SORTIE
     &                    SORG2D)     ! SORTIE OU PAS DES VARIABLES
      CALL WRITE_MESH(T3D_FILES(T3DHYD)%FMT, ! FORMAT FICHIER RESULTAT
     &                T3D_FILES(T3DHYD)%LU,  ! LU FICHIER RESULTAT
     &                MESH2D,          ! DESCRIPTEUR MAILLAGE
     &                1,               ! NOMBRE DE PLAN /NA/
     &                DATE,            ! DATE DEBUT
     &                TIME,            ! HEURE DEBUT
     &                I_ORIG,J_ORIG)   ! COORDONNEES DE L'ORIGINE.
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE ECRGEO'
!
C 2D OUTPUT
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE BIEF_DESIMP POUR 2D'
      CALL BIEF_DESIMP(T3D_FILES(T3DHYD)%FMT,VARSOR,
     &                 HIST,0,NPOIN2,T3D_FILES(T3DHYD)%LU,'STD',AT,LT,
     &                 LISPRD,GRAPRD,
     &                 SORG2D,SORIMP,MAXVAR,TEXTE,GRADEB,LISDEB)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE BIEF_DESIMP POUR 2D'
!
!-----------------------------------------------------------------------
C INITIALISES MASS BALANCE AND CUMULATIVE FLUXES
!
      IF(BILMAS) THEN
!
         CALL MITTIT(10,AT,LT)
!
         CALL MASS3D(.TRUE.,LT)
!
         CALL OS ( 'X=Y     ', X=MASINI, Y=MASSE)
         CALL OS ( 'X=0     ', X=FLUCUM         )
         MASINI_WATER=MASSE_WATER
         FLUXTOTCUM=0.D0
!        MAYBE NOT USEFUL
         CALL OS ( 'X=0     ', X=FLUX           )
!
         IF(SEDI) THEN
           IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MASSED'
           CALL MASSED(MASSE%R(5+NTRAC),TA%ADR(NTRAC)%P,X,Y,Z,
     &                 IVIDE%R,EPAI%R,CONC%R,HDEP%R,MESH2D%SURFAC%R,
     &                 T3_01,T3_02%R,SVIDE,IKLE2%I,MESH3D,
     &                 IELM3,NPLAN,NELEM2,NELEM3,NPOIN2,NPOIN3,
     &                 NTRAC,NVBIL,NPFMAX,NCOUCH,NPF%I,TASSE,GIBSON,
     &                 RHOS,CFDEP,MSK,MASKEL)
           IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE MASSED'
         ENDIF
!
      ENDIF
!
!-----------------------------------------------------------------------
C RETURNS WHEN THE NUMBER OF REQUIRED TIMESTEPS IS 0
!
      IF(NIT.EQ.0) THEN
         IF (LNG == 1) WRITE(LU,11)
         IF (LNG == 2) WRITE(LU,12)
         RETURN
      ENDIF
!
11    FORMAT(' ARRET DANS TELEMAC-3D, NOMBRE D''ITERATIONS DEMANDE NUL')
12    FORMAT(' BREAK IN TELEMAC-3D, NUMBER OF ITERATIONS ASKED NULL')
!
!-----------------------------------------------------------------------
!
      CALL OS ( 'X=Y     ' , X=UC, Y=U )
      CALL OS ( 'X=Y     ' , X=VC, Y=V )
!
      IF (NTRAC.NE.0) CALL OS ('X=Y     ', X=TAC, Y=TA )
!
! THE SAME FOR K AND EPSILON
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
        CALL OS ( 'X=Y     ', X=AKC, Y=AK )
        CALL OS ( 'X=Y     ', X=EPC, Y=EP )
      ENDIF
!
C INITIALISES THE HORIZONTAL VELOCITY AFTER DIFFUSION
C IN ORDER TO ACCELERATE THE SOLVER CONVERGENCE
!
      CALL OS ( 'X=Y     ', X=UD, Y=U)
      CALL OS ( 'X=Y     ', X=VD, Y=V)
!
C INITIALISES THE FREE SURFACE AND DIFFERENT VERTICAL VELOCITIES
!
      IF(NONHYD) THEN
        CALL OS ( 'X=Y     ', X=WC,  Y=W  )
        CALL OS ( 'X=Y     ', X=WD,  Y=W  )
      ENDIF
!
C SOURCE TERMS : FINDS LOCATION OF SOURCES (USED IN PRECON HEREAFTER)
C                WILL SUBSEQUENTLY BE DONE AT EACH TIMESTEP
!
      IF(NSCE.GT.0) THEN
!
C       IN THE 2D MESH -> ISCE
        CALL PROXIM(ISCE,XSCE,YSCE,MESH2D%X%R,MESH2D%Y%R,NSCE,NPOIN2,
     &              IKLE2%I,NELEM2,NELMAX2)
C       ON THE VERTICAL -> KSCE
        CALL FINDKSCE(NPOIN2,NPLAN,Z3%R,NSCE,ISCE,ZSCE,KSCE,INFOGR)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!     INITIALISING WSCONV
!     ADDED BY JMH ON 19/12/2000
!     WSCONV WAS NOT INITIALISED BEFORE GOING INTO SOLVE IN TRIDW2
      CALL OS('X=0     ',X=WSCONV)
!
!=======================================================================
!     COUPLING WITH SISYPHE
!=======================================================================
!
!     COUPLING WITH SISYPHE
!     WRITES THE INITIAL CONDITIONS FOR U(Z=0), V(Z=0) AND H
!
      IF(COUPLING.NE.' ') THEN
        IF(LNG.EQ.1) WRITE(LU,*) 'TELEMAC3D COUPLE AVEC : ',COUPLING
        IF(LNG.EQ.2) WRITE(LU,*) 'TELEMAC3D COUPLED WITH: ',COUPLING
      ENDIF
!
      IF(INCLUS(COUPLING,'SISYPHE')) THEN
!
C       U AND V WITH 2D STRUCTURE : BOTTOM VELOCITY AS A 2D VARIABLE
        CALL CPSTVC(U2D,U)
        CALL CPSTVC(V2D,V)
!
        CALL CONFIG_CODE(2)
C       INOUT VARIABLES IN SISYPHE CANNOT BE HARDCODED
        IBID=1
        LBID=.FALSE.
        IF(DEBUG.GT.0) WRITE(LU,*) 'PREMIER APPEL DE SISYPHE'
        CALL SISYPHE(0,LT,GRAPRD,LISPRD,NIT,U2D,V2D,H,H,ZF,UETCAR,CF,
     &               RUGOF,
     &               LBID,IBID,LBID,CODE1,1,U,V,AT,VISCVI,DT,CHARR,SUSP,
C                          1 PRECLUDES THE USE OF THE FOLLOWING ARGUMENTS
     &               FLBOR,1,DM1,UCONV,VCONV,ZCONV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DU PREMIER APPEL DE SISYPHE'
        CALL CONFIG_CODE(1)
!
C       RETRIEVES ORIGINAL U AND V STRUCTURE
!
        CALL CPSTVC(UN,U)
        CALL CPSTVC(VN,V)
!
      ENDIF
!
!=======================================================================
!     COUPLING WITH TOMAWAC
!=======================================================================
!
      IF(INCLUS(COUPLING,'TOMAWAC')) THEN
C
        IF(LNG.EQ.1) THEN
          WRITE (LU,*) 'TELEMAC-3D : COUPLAGE INTERNE AVEC TOMAWAC'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE (LU,*) 'TELEMAC-3D: INTERNAL COUPLING WITH TOMAWAC'
        ENDIF
        CALL CONFIG_CODE(3)
        IF(DEBUG.GT.0) WRITE(LU,*) 'PREMIER APPEL DE TOMAWAC'
!       CALL WAC(0,U2D,V2D,H,FXH,FYH,WINDX,WINDY,CODE1,AT,DT,NIT,
!                PERCOU_WAC)
        CALL WAC(0,U2D,V2D,H,FXH,FYH,T2_01,T2_02,CODE1,AT,DT,NIT,
     *           PERCOU_WAC)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TOMAWAC'
        CALL CONFIG_CODE(1)
C
      ENDIF
!
!=======================================================================
!
C     INITIALISES THE SEDIMENT SETTLING VELOCITY
C     NEGLECTS TURBULENCE HERE
C     WCHU COMPUTED HERE IS USED IN BORD3D FOR ROUSE PROFILES
!
      IF(SEDI) CALL VITCHU(WCHU,WCHU0)
!
!=======================================================================
C THE TIME LOOP BEGINS HERE
!=======================================================================
!
      TIMELOOP: DO LT=1,NIT
!
      AT = AT + DT
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'BOUCLE EN TEMPS LT=',LT
      INFOGR = .FALSE.
      IF (MOD(LT,LISPRD) == 0) INFOGR = .TRUE.
      INFOGR = LISTIN .AND. INFOGR
      IF (INFOGR) CALL MITTIT(1,AT,LT)
!
!=======================================================================
! SOURCES : COMPUTES INPUTS WHEN VARYING IN TIME
!           IF NO VARIATION IN TIME QSCE2=QSCE AND TASCE2=TASCE
!=======================================================================
!
      IF(NSCE.GT.0) THEN
        DO I=1,NSCE
          QSCE2(I)=T3D_DEBSCE(AT,I,QSCE)
        ENDDO
        IF(NTRAC.GT.0) THEN
          DO I=1,NSCE
            DO ITRAC=1,NTRAC
              TA_SCE%ADR(ITRAC)%P%R(I)=T3D_TRSCE(AT,I,ITRAC)
            ENDDO
          ENDDO
        ENDIF
      ENDIF
!
!=======================================================================
C C. LEQUETTE'S MODIFS FOR COUPLING WITH SISYPHE INSIDE THE TIMELOOP
!=======================================================================
!
C     INTERNAL COUPLING WITH SISYPHE
!
      IF( INCLUS(COUPLING,'SISYPHE')   .AND.
     &   (PERCOU_SIS*(LT/PERCOU_SIS).EQ.LT.OR.LT.EQ.1) ) THEN
!
!       U AND V WITH 2D STRUCTURE : BOTTOM VELOCITY AS A 2D VARIABLE
        CALL CPSTVC(U2D,U)
        CALL CPSTVC(V2D,V)
!
C       HDEP MUST INCLUDE BEDLOAD AND SUSPENSION
        IF(SEDI) CALL OS('X=X-Y   ',X=HDEP,Y=ZF)
!
C       NOW RUNS ONE TURN OF SISYPHE'S TIME LOOP AND RETURNS
        CALL CONFIG_CODE(2)
        IBID=1
        LBID=.FALSE.
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE SISYPHE'
        CALL SISYPHE(1,LT,GRAPRD,LISPRD,NIT,U2D,V2D,H,HN,ZF,UETCAR,
     &               CF,RUGOF,LBID,IBID,LBID,CODE1,1,U,V,AT,VISCVI,
     &               DT,CHARR,SUSP,
C                          1 PRECLUDES THE USE OF THE FOLLOWING ARGUMENTS
     &               FLBOR,1,DM1,UCONV,VCONV,ZCONV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SISYPHE'
        CALL CONFIG_CODE(1)
!
C       HDEP MUST INCLUDE BEDLOAD AND SUSPENSION
        IF(SEDI) CALL OS('X=X+Y   ',X=HDEP,Y=ZF)
!
C       RETRIEVES ORIGINAL U AND V STRUCTURE
        CALL CPSTVC(UN,U)
        CALL CPSTVC(VN,V)
!
      ENDIF
!
!=======================================================================
! END OF CAMILLE LEQUETTE'S MODIFICATIONS
!=======================================================================
!
!     COUPLING WITH TOMAWAC
!
      IF(INCLUS(COUPLING,'TOMAWAC').AND.
     *   PERCOU_WAC*((LT-1)/PERCOU_WAC).EQ.LT-1) THEN
!
        CALL CONFIG_CODE(3)
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE TOMAWAC'
!       CALL WAC(1,U2D,V2D,H,FXH,FYH,WINDX,WINDY,CODE1,AT,
!    *           DT*PERCOU_WAC,NIT,PERCOU_WAC)
        CALL WAC(1,U2D,V2D,H,FXH,FYH,T2_01,T2_02,CODE1,AT,
     *           DT*PERCOU_WAC,NIT,PERCOU_WAC)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TOMAWAC'
        CALL CONFIG_CODE(1)
!
      ENDIF
!
!=======================================================================
!
! SAVES H, TA, TP, AK, EP
! IN    HN,TAN,TPN,AKN,EPN
!
      CALL OS ( 'X=Y     ', X=HN,    Y=H     )
      CALL OS ( 'X=Y     ', X=VOLUN, Y=VOLU  )
      IF(NCSIZE.GT.1) CALL OS('X=Y     ',X=VOLUNPAR,Y=VOLUPAR)
      CALL OS ( 'X=Y     ', X=UN,    Y=U     )
      CALL OS ( 'X=Y     ', X=VN,    Y=V     )
      CALL OS ( 'X=Y     ', X=GRADZN,Y=GRADZS)
!
      IF(NONHYD) CALL OS ( 'X=Y     ' , X=WN, Y=W)
!
C IS IT OK FOR THE WHOLE BLOCKS (THEIR STRUCTURE IS IDENTICAL!)
!
      IF (NTRAC.NE.0) CALL OS ('X=Y     ', X=TAN, Y=TA)
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
        CALL OS ( 'X=Y     ', X=AKN, Y=AK )
        CALL OS ( 'X=Y     ', X=EPN, Y=EP )
      ENDIF
!
      IF(BILMAS) THEN
        MASSEN_WATER = MASSE_WATER
        CALL OS ( 'X=Y     ', X=MASSEN, Y=MASSE )
      ENDIF
!
C COMPUTES MEAN UN AND VN IN THE VERTICAL
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VERMOY'
      CALL VERMOY(UN2D%R,VN2D%R,UN%R,VN%R,2,Z,
     &            T3_01%R,T3_02%R,T3_03%R,1,NPLAN,NPOIN2,NPLAN,OPTBAN)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VERMOY'
!
!-----------------------------------------------------------------------
!
C COMPUTES FRICTION COEFFICIENT
!
C     TIME VARIATIONS OF RUGOF (CORSTR IS IN TELEMAC-2D LIBRARY)
C     MUST BE USER-IMPLEMENTED - NOTHING DONE IN STANDARD
      CALL CORSTR
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE COEFRO'
      CALL COEFRO(CF,H,UN2D,VN2D,KARMAN,KFROT,RUGOF,GRAV,MESH2D,T2_01)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE COEFRO'
!
!-----------------------------------------------------------------------
!
C CHECKS AND HARMONISES THE BOUNDARY CONDITION TYPES
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE LICHEK'
      CALL LICHEK(LIMPRO%I,NPTFR2)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE LICHEK'
!
! BOUNDARY CONDITIONS FOR THE K-EPSILON MODEL
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
        CALL KEPICL(LIKBOF%I, LIEBOF%I, LIUBOF%I,
     &              LIKBOL%I, LIEBOL%I, LIUBOL%I,
     &              LIKBOS%I, LIEBOS%I, LIUBOS%I,
     &              NPTFR2, NPLAN, NPOIN2, KENT, KSORT, KADH, KLOG)
      ENDIF
!
!-----------------------------------------------------------------------
C FORCING AT THE BOUNDARIES
!
C METEOROLOGICAL CONDITIONS
!
      IF (VENT.OR.ATMOS) CALL METEO
     &   (PATMOS%R, WIND%ADR(1)%P%R, WIND%ADR(2)%P%R, FUAIR, FVAIR,
     &    X2%R, Y2%R, AT, LT, NPOIN2, VENT, ATMOS, H%R, T2_01%R,
     &    GRAV, RHO0, 0.D0, PRIVE)
!
!-----------------------------------------------------------------------
!
C     SEDIMENT
!
      IF(SEDI) THEN
!
C       COMPUTES THE SEDIMENT SETTLING VELOCITY
!
        IF(.NOT.TURBWC) THEN
          CALL VITCHU(WCHU,WCHU0)
        ELSE
          CALL WCTURB(WCHU,WCHU0,U,V,W,H,RUGOF,LISRUF,T3_01,T3_02,T3_03,
     &    SVIDE,MESH3D,IELM3,NPOIN2,NPLAN,TURBA,TURBB,MSK,MASKEL,UETCAR)
        ENDIF
!
C       BOUNDARY CONDITIONS FOR THE SEDIMENTOLOGY
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CLSEDI'
        CALL CLSEDI
     &   (ATABOF%ADR(NTRAC)%P%R,BTABOF%ADR(NTRAC)%P%R,
     &    ATABOS%ADR(NTRAC)%P%R,BTABOS%ADR(NTRAC)%P%R,
     &    TA%ADR(NTRAC)%P%R,WCHU%R,
     &    GRADZF%ADR(1)%P%R,GRADZF%ADR(2)%P%R,
     &    GRADZS%ADR(1)%P%R,GRADZS%ADR(2)%P%R,
     &    X, Y, Z, H, DELTAR%R, T3_01, T3_02%R, T3_03%R,
     &    IVIDE%R, EPAI%R, CONC%R, HDEP%R, FLUER%R,
     &    PDEPO%R, LITABF%ADR(NTRAC)%P%I, LITABS%ADR(NTRAC)%P%I,
     &    KLOG, NPOIN3, NPOIN2, NPLAN, NPFMAX, NCOUCH,
     &    NPF%I, ITURBV, DT, RHO0, RHOS,
     &    CFDEP,TOCD,MPART,TOCE,TASSE,GIBSON, PRIVE,UETCAR%R,
     &    GRAV,SEDCO,DMOY,CREF,CF,AC,KSPRATIO,ICR)
!
C         ATABOF AND BTABOF ARE NO LONGER 0 FOLLOWING CLSEDI
          ATABOF%ADR(NTRAC)%P%TYPR='Q'
          BTABOF%ADR(NTRAC)%P%TYPR='Q'
C         ATABOS%ADR(NTRAC)%P%TYPR='Q'
C         BTABOS%ADR(NTRAC)%P%TYPR='Q'
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CLSEDI'
      ENDIF
!
C UPDATES BOUNDARY CONDITION VALUES
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE BORD3D'
      CALL BORD3D(AT,LT,INFOGR,NPTFR2,NFRLIQ)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE BORD3D'
!
C BOUNDARY CONDITIONS FOR THE VELOCITY ON LATERAL BOUNDARIES
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE TBORD'
      CALL TBORD(AUBORL%R,LIUBOL%I,
     &           RUGOL%R,
     &           MESH2D%DISBOR%R,MESH2D%NELBOR%I,MESH2D%NULONE%I,
     &           MESH2D%IKLE%I,NELEM2,
     &           U%R,V%R,W%R,
     &           NBOR2%I,NPOIN2,NPLAN,NPTFR2,DNUVIH,DNUVIV,
     &           KARMAN,LISRUL,KFROTL,
     &           KENT,KENTU,KSORT,KADH,KLOG,UETCAL%R,NONHYD,
     &           T2_01%R,MESH2D)
      IF(KFROTL.EQ.0) THEN
        AUBORL%TYPR='0'
      ELSE
        AUBORL%TYPR='Q'
      ENDIF
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TBORD, APPEL DE TFOND'
!
C BOUNDARY CONDITIONS FOR THE VELOCITY ON THE BOTTOM
!
      CALL TFOND(AUBORF%R,
     &           CF%R,UN2D%R,VN2D%R,U%R,V%R,W%R,KARMAN,
     &           LISRUF,DNUVIV,Z,NPOIN2,KFROT,RUGOF%R,UETCAR%R,
     &           NONHYD,OPTBAN,HN%R,GRAV,IPBOT%I,NPLAN)
      AUBORF%TYPR='Q'
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TFOND'
!
C BOUNDARY CONDITIONS FOR K-EPSILON MODEL + COMPUTES CONSTRAINTS
C AT THE BOTTOM AND LATERAL BOUNDARIES IF K-EPSILON IS REQUIRED
!
      IF (ITURBV.EQ.3) THEN
         IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE KEPCL3'
         CALL KEPCL3(KBORF%R,  EBORF%R,LIKBOF%I, LIEBOF%I, LIUBOF%I,
     &    KBORL%R,  EBORL%R,  LIKBOL%I, LIEBOL%I, LIUBOL%I,
     &    RUGOL%R,  KBORS%R,  EBORS%R,
     &    LIKBOS%I, LIEBOS%I, LIUBOS%I,
     &    MESH2D%DISBOR%R, AK%R, U%R, V%R, H%R, Z,
     &    NBOR2%I, NPOIN2, NPLAN, NPTFR2, DNUVIH, DNUVIV,
     &    KARMAN, CMU, LISRUF, LISRUL,
     &    VIRT,KMIN,KMAX,EMIN,EMAX,KENT,KENTU,KSORT,KADH,KLOG,
     &    UETCAR%R,UETCAL%R)
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE KEPCL3'
!
      ELSEIF (ITURBV.EQ.7) THEN
!
         IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE KOMCL3'
         CALL KOMCL3(KBORF%R,  EBORF%R,
     &    LIKBOF%I, LIEBOF%I, LIUBOF%I,
     &    KBORL%R,  EBORL%R,
     &    LIKBOL%I, LIEBOL%I, LIUBOL%I, RUGOL%R,
     &    KBORS%R,  EBORS%R,
     &    LIKBOS%I, LIEBOS%I, LIUBOS%I,
     &    MESH2D%DISBOR%R,AK%R,EP%R,U%R,V%R,W%R,H%R,Z,
     &    NBOR2%I, NPOIN2, NPLAN, NPTFR2, DNUVIH, DNUVIV,
     &    KARMAN, ALPHA,BETA,BETAS,OMSTAR, SCHMIT, LISRUF, LISRUL,
     &    VIRT,GRAV,KMIN,KMAX,EMIN,EMAX,KENTU,KENT,KSORT,KADH,KLOG,
     &    UETCAR%R,UETCAL%R)
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE KOMCL3'
!
      ENDIF
!
C CLIPS HBOR
!
      IF(OPTBAN.EQ.2) THEN
        CALL CLIP(HBOR,HMIN,.TRUE.,1.D6,.FALSE.,0)
      ENDIF
!
!-----------------------------------------------------------------------
C SOURCE TERMS
!
      IF(NSCE.GT.0) THEN
        CALL FINDKSCE(NPOIN2,NPLAN,Z3%R,NSCE,ISCE,ZSCE,KSCE,INFOGR)
      ENDIF
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE TRISOU'
      CALL TRISOU
     & (S0U%R,S0V%R, S0U,S0V,UN%R,VN%R,TA,X,Y,Z,
     &  T3_01%R, DELTAR, MESH3D, FCOR, CORIOL, NTRAC, LT,
     &  AT, DT, SURFA2%R, T3_02%R, T3_02, W1%R,
     &  MESH3D%M%X%R(1:6*NELEM3),MESH3D%M%X%R(6*NELEM3+1:12*NELEM3),
     &  SEDI, GRAV, NPOIN3, NELEM3, NPOIN2, NELEM2, NPLAN, NETAGE,
     &  IKLE3%I, PRIVE, LV, MSK, MASKEL%R, INCHYD,
     &  VOLU,VOLU%R,SVIDE,IELM3,MASKEL,NREJEU,ISCE,KSCE,QSCE2,
     &  U_SCE%R,V_SCE%R,
     &  IELM2H,GRADZS%ADR(1)%P,GRADZS%ADR(2)%P,Z3,T2_01, T2_02,MESH2D,
     &  T3_03, T3_03%R, T3_04, T3_04%R, LATIT, LONGIT, NORD,SMU,SMV,
     &  YASEM3D,SCHCVI,DENLAW,FXH,FYH,COUROU,NPTH,T3D_FILES,T3DBI1)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE TRISOU, APPEL DE SOURCE'
!
      CALL SOURCE(S0U, S0V, S0W, S1U, S1V, S1W,
     &            U, V, WS, W,
     &            VOLU, VOLUN,T3_01,
     &            NPOIN3, NTRAC, LT, AT, DT, PRIVE, NONHYD,
     &            NPOIN2, NSCE,ISCE,KSCE,QSCE2,U_SCE%R,V_SCE%R,MAXSCE)
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SOURCE'
!
C     SAVES BOUNDARY VALUES FOR TIME TN
!
      IF(NSOUSI.GT.1) THEN
        DO IP=1,NPTFR3
          UBORSAVE%R(IP)=UN%R(NBOR3%I(IP))
          VBORSAVE%R(IP)=VN%R(NBOR3%I(IP))
        ENDDO
        IF(NONHYD) THEN
          DO IP=1,NPTFR3
            WBORSAVE%R(IP)=WN%R(NBOR3%I(IP))
          ENDDO
        ENDIF
        IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
          DO IP=1,NPTFR3
            KBORSAVE%R(IP)=AKN%R(NBOR3%I(IP))
            EBORSAVE%R(IP)=EPN%R(NBOR3%I(IP))
          ENDDO
        ENDIF
        IF(NTRAC.GT.0) THEN
          DO ITRAC=1,NTRAC
            DO IP=1,NPTFR3
              TRBORSAVE%ADR(ITRAC)%P%R(IP)=
     &        TAN%ADR(ITRAC)%P%R(NBOR3%I(IP))
            ENDDO
          ENDDO
        ENDIF
      ENDIF
!
!=======================================================================
C THE SUB-ITERATIONS LOOP BEGINS HERE
!=======================================================================
!
      SUBITER: DO ISOUSI = 1,NSOUSI
!
C     RESTORES BOUNDARY VALUES FOR TIME TN
!
      IF(ISOUSI.GT.1) THEN
        DO IP=1,NPTFR3
          UN%R(NBOR3%I(IP))=UBORSAVE%R(IP)
          VN%R(NBOR3%I(IP))=VBORSAVE%R(IP)
        ENDDO
        IF(NONHYD) THEN
          DO IP=1,NPTFR3
            WN%R(NBOR3%I(IP))=WBORSAVE%R(IP)
          ENDDO
        ENDIF
        IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
          DO IP=1,NPTFR3
            AKN%R(NBOR3%I(IP))=KBORSAVE%R(IP)
            EPN%R(NBOR3%I(IP))=EBORSAVE%R(IP)
          ENDDO
        ENDIF
        IF(NTRAC.GT.0) THEN
          DO ITRAC=1,NTRAC
            DO IP=1,NPTFR3
          TAN%ADR(ITRAC)%P%R(NBOR3%I(IP))=TRBORSAVE%ADR(ITRAC)%P%R(IP)
            ENDDO
          ENDDO
        ENDIF
      ENDIF
!
C     BUILDS THE MESH FOR PROPAGATION STEP
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MESH_PROP'
      CALL MESH_PROP(HPROP,HN,H,PROLIN,HAULIN,TETAH,NSOUSI,ZPROP,
     &               IPBOT,NPOIN2,NPLAN,OPTBAN,SIGMAG,OPT_HNEG,
     &               MDIFF,MESH3D,VOLU3D,VOLU3DPAR,
     &               UNSV3D,MSK,MASKEL,IELM3)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE MESH_PROP'
!
      IF(ISOUSI.GT.1) THEN
C       REBUILDS THE INITIAL MESH
C       NOTE: EVOLUTION OF ZF IS NOT TAKEN INTO ACCOUNT HERE - INVESTIGATE
        CALL CALCOT(Z,HN%R)
        CALL OS('X=Y     ',X=VOLU,Y=VOLUN)
        IF(NCSIZE.GT.1) CALL OS('X=Y     ',X=VOLUPAR,Y=VOLUNPAR)
        CALL GRAD2D(GRADZF%ADR(1)%P,GRADZF%ADR(2)%P,ZPROP,NPLAN,SVIDE,
     &              UNSV2D,T2_02,T2_03,T2_04,
     &              IELM2H,MESH2D,MSK,MASKEL)
        CALL FSGRAD(GRADZS,ZFLATS,Z(NPOIN3-NPOIN2+1:NPOIN3),
     &              ZF,IELM2H,MESH2D,MSK,MASKEL,
     &              UNSV2D,T2_01,NPOIN2,OPTBAN,SVIDE)
      ENDIF
!
!     SOURCES AND SINKS OF WATER
!
C     TEMPORARILY PUTS ZPROP IN MESH3D%Z
      SAVEZ     =>MESH3D%Z%R
      MESH3D%Z%R=>ZPROP%R
      CALL SOURCES_SINKS
C     RESTORES Z
      MESH3D%Z%R=>SAVEZ
!
!     SETS ADVECTION AND DIFFUSION PARAMETERS TO MONITOR CVDF3D
!     DIFFUSION AND SOURCE TERMS ARE DONE IN WAVE_EQUATION
!     IN CVDF3D (THIS IS DONE IN WAVE_EQUATION)
!
!     DIFFUSION OF U AND V IS DONE IN WAVE_EQUATION
      SCHDVI_HOR = 0
      SCHDVI_VER = SCHDVI
!
      SCHCVI_HOR = SCHCVI
      SCHCVI_VER = SCHCVI
!     ADVECTION IS NOT DONE AT THE FIRST TIME-STEP
      IF(LT.EQ.1.AND.ISOUSI.EQ.1) THEN
        SCHCVI_HOR = 0
        SCHCVI_VER = 0
      ENDIF
!
!     WHEN SCHCVI=ADV_SUP DIFF3D IS CALLED AND
!     SOURCE TERMS WOULD BE TREATED TWICE
      YAS0U=.FALSE.
      YAS1U=.FALSE.
!
!-----------------------------------------------------------------------
! ADVECTION-DIFFUSION STEP FOR VELOCITY COMPONENTS
!-----------------------------------------------------------------------
!
      IF(INFOGR) THEN
        IF (NONHYD) THEN
          CALL MITTIT(17,AT,LT)
        ELSE
          CALL MITTIT(4,AT,LT)
        ENDIF
      ENDIF
!
      SIGMAU = 1.D0
      UMIN   = 0.D0
      UMAX   = 1.D0
      CLUMIN = .FALSE.
      CLUMAX = .FALSE.
      YAWCHU = .FALSE.
C     YASEM3D = DONE IN TRISOU
      NEWDIF=.TRUE.
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CVDF3D POUR U'
      CALL CVDF3D
     & (UD,UC,UN,VISCVI,SIGMAU,S0U,YAS0U,S1U,YAS1U,
     &  UBORL, UBORF, UBORS, AUBORL, AUBORF, AUBORS,
     &  BUBORL, BUBORF, BUBORS, LIUBOL, LIUBOF, LIUBOS,
     &  FLUX%R(1), FLUEXT,FLUEXTPAR,UMIN, CLUMIN, UMAX, CLUMAX,
     &  SCHCVI_HOR,SCHDVI_HOR,SLVDVI,TRBAVI,INFOGR,NEWDIF,
     &  CALCFLU(1),T2_01,T2_02,T2_03,
     &  T3_01,T3_02,T3_03,T3_04,MESH3D,IKLE3,MASKEL,MTRA1,
C    *  W1 , NPTFR3 , MMURD , VOLU , VOLUN ,
     &  W1,NPTFR3,MMURD,MURD_TF,VOLU3D,VOLU3DPAR,VOLU3D,VOLU3DPAR,
     &  NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &  NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &  INCHYD,MASKBR,MASKPT,SMU,YASEM3D,SVIDE,IT1,IT2,
     &  TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,TETADI,YAWCHU,WCHU,
     &  AGGLOD,NSCE,SOURCES,U_SCE%R,NUMLIQ%I,DIRFLU,NFRLIQ,
     &  VOLUT,ZT,ZPROP,CALCRAIN(1),PLUIE,PARAPLUIE,
     &  FLODEL,FLOPAR,SIGMAG,IPBOT%I)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CVDF3D POUR U'
!
       SIGMAV = 1.D0
       VMIN   = 0.D0
       VMAX   = 1.D0
       CLVMIN = .FALSE.
       CLVMAX = .FALSE.
       YAWCHU = .FALSE.
C      YASEM3D = DONE IN TRISOU
C      MDIFF ALREADY COMPUTED FOR U
       NEWDIF=.FALSE.
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CVDF3D POUR V'
C     USE OF AUBORL,AUBORF,AUBORS IS NOT A MISTAKE
      CALL CVDF3D
     & (VD,VC,VN,VISCVI,SIGMAV,S0V,YAS0U,S1V,YAS1U,
     &  VBORL, VBORF, VBORS, AUBORL,AUBORF,AUBORS,
     &  BVBORL, BVBORF, BVBORS, LIVBOL, LIVBOF, LIVBOS,
     &  FLUX%R(2), FLUEXT,FLUEXTPAR,VMIN, CLVMIN, VMAX, CLVMAX,
     &  SCHCVI_HOR,SCHDVI_HOR,SLVDVI,TRBAVI,INFOGR,NEWDIF,
     &  CALCFLU(2),T2_01,T2_02,T2_03,
     &  T3_01,T3_02,T3_03,T3_04, MESH3D , IKLE3 , MASKEL , MTRA1,
C    *  W1 , NPTFR3 , MMURD , VOLU , VOLUN ,
     &  W1,NPTFR3,MMURD,MURD_TF,VOLU3D,VOLU3DPAR,VOLU3D,VOLU3DPAR,
     &  NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &  NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &  INCHYD,MASKBR,MASKPT,SMV,YASEM3D,SVIDE,IT1,IT2,
     &  TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,TETADI,YAWCHU,WCHU,
     &  AGGLOD,NSCE,SOURCES,V_SCE%R,NUMLIQ%I,DIRFLU,NFRLIQ,
     &  VOLUT,ZT,ZPROP,CALCRAIN(2),PLUIE,PARAPLUIE,
     &  FLODEL,FLOPAR,SIGMAG,IPBOT%I)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CVDF3D POUR V'
!
      IF(NONHYD) THEN
!
       SIGMAW = 1.D0
       WMIN   = 0.D0
       WMAX   = 1.D0
       CLWMIN = .FALSE.
       CLWMAX = .FALSE.
       YASEM3D= .FALSE.
       YAWCHU = .FALSE.
       NEWDIF=.TRUE.
C      TETADI MAY BE EQUAL TO 2 FOR U AND V, WHEN THE WAVE EQUATION
C      IS USED - NOT DONE ON W SO FAR
       TETADIVER = MIN(TETADI,1.D0)
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CVDF3D POUR W'
C       USE OF AUBORL,AUBORF,AUBORS IS NOT A MISTAKE
        CALL CVDF3D
     & (WD,WC,WN,VISCVI,SIGMAW,S0W,.TRUE.,S1W,.TRUE.,
     &  WBORL, WBORF, WBORS, AUBORL, AUBORF, AUBORS,
     &  BWBORL, BWBORF, BWBORS, LIWBOL, LIWBOF, LIWBOS,
     &  FLUX%R(3), FLUEXT,FLUEXTPAR,WMIN, CLWMIN, WMAX, CLWMAX,
     &  SCHCVI_VER,SCHDVI_VER,SLVDVI,TRBAVI,INFOGR,NEWDIF,
     &  CALCFLU(3),T2_01,T2_02,T2_03,
     &  T3_01,T3_02,T3_03,T3_04, MESH3D , IKLE3 , MASKEL , MTRA1,
C    *  W1 , NPTFR3 , MMURD , VOLU , VOLUN ,
     &  W1,NPTFR3,MMURD,MURD_TF,VOLU3D,VOLU3DPAR,VOLU3D,VOLU3DPAR,
     &  NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &  NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &  INCHYD,MASKBR,MASKPT,SEM3D,YASEM3D,SVIDE,IT1,IT2,
     &  TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,
     &  TETADIVER,YAWCHU,WCHU,AGGLOD,NSCE,SOURCES,W_SCE%R,NUMLIQ%I,
     &  DIRFLU,NFRLIQ,VOLUT,ZT,ZPROP,CALCRAIN(3),PLUIE,
     &  PARAPLUIE,FLODEL,FLOPAR,SIGMAG,IPBOT%I)
!
      ENDIF
!
!-----------------------------------------------------------------------
! DIFFUSION AND PROPAGATION STEP BY WAVE_EQUATION
!-----------------------------------------------------------------------
!
      IF(INFOGR) CALL MITTIT(6,AT,LT)
C     TEMPORARILY PUTS ZPROP IN MESH3D%Z
      SAVEZ     =>MESH3D%Z%R
C     ALL PROPAGATION WILL BE DONE WITH ZPROP INSTEAD OF Z
      MESH3D%Z%R=>ZPROP%R
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE WAVE_EQUATION'
!
      CALL WAVE_EQUATION(LT,ISOUSI)
!
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE WAVE_EQUATION'
C     RESTORES Z
      MESH3D%Z%R=>SAVEZ
!
!-----------------------------------------------------------------------
C CLIPS NEGATIVE DEPTHS
!-----------------------------------------------------------------------
!
      CALL CORRECTION_DEPTH_3D(MESH2D%W%R,MESH3D%W%R,MESH2D%GLOSEG%I,
     &                         MESH2D%GLOSEG%DIM1)
!
!-----------------------------------------------------------------------
C BUILDS NEW MESH WITH THE NEW FREE SURFACE
!-----------------------------------------------------------------------
!
      CALL CALCOT(Z,H%R)
!
!----------------------------------------------------------------------
!
C     GENERATES DATA FOR DELWAQ
!
      IF(INCLUS(COUPLING,'DELWAQ')) THEN
!
      FORMUL = 'VGRADP       HOR'
      FORMUL(8:8) = '2'
C     ADVECTION FLUXES PER NODE (STORED IN MESH3D%W%R)
C     THE ASSEMBLED RESULT IN T3_04 IS NOT USED HERE
      SAVEZ     =>MESH3D%Z%R
      MESH3D%Z%R=>ZPROP%R
      CALL VECTOR(T3_04,'=',FORMUL,IELM3,-1.D0,DM1,ZCONV,SVIDE,
     &            UCONV,VCONV,SVIDE,MESH3D,MSK,MASKEL)
      MESH3D%Z%R=>SAVEZ
C     SENDS UCONV AND VCONV AS ADVECTING FIELD (SEE WAVE_EQUATION)
      CALL TEL4DEL(NPOIN3,NPOIN2,NELEM3,MESH2D%NSEG,
     &  MESH2D%IKLE%I,MESH2D%ELTSEG%I,MESH2D%GLOSEG%I,MESH2D%ORISEG%I,
     &  MESH2D%GLOSEG%DIM1,X,Y,MESH3D%NPTFR,LIHBOR%I,MESH3D%NBOR%I,
     &  NPLAN,AT,DT,LT,NIT,H%R,HPROP%R,MESH3D%Z%R,UCONV%R,
     &  VCONV%R,TA%ADR(MAX(IND_S,1))%P%R,TA%ADR(MAX(IND_T,1))%P%R,
     &  VISCVI%ADR(3)%P%R,TITCAS,
     &  T3D_FILES(T3DGEO)%NAME,T3D_FILES(T3DCLI)%NAME,WAQPRD,
     &T3D_FILES(T3DDL1)%LU,T3D_FILES(T3DDL1)%NAME,T3D_FILES(T3DDL2)%LU,
     &T3D_FILES(T3DDL2)%NAME,T3D_FILES(T3DDL3)%LU,
     &T3D_FILES(T3DDL3)%NAME,T3D_FILES(T3DDL5)%LU,
     &T3D_FILES(T3DDL5)%NAME,
     &  T3D_FILES(T3DDL6)%LU,T3D_FILES(T3DDL6)%NAME,
     &  T3D_FILES(T3DDL7)%LU,T3D_FILES(T3DDL7)%NAME,
     &  T3D_FILES(T3DL11)%LU,T3D_FILES(T3DL11)%NAME,
     &  T3D_FILES(T3DDL4)%LU,T3D_FILES(T3DDL4)%NAME,
     &  T3D_FILES(T3DDL8)%LU,T3D_FILES(T3DDL8)%NAME,
     &T3D_FILES(T3DDL9)%LU,T3D_FILES(T3DDL9)%NAME,T3D_FILES(T3DL10)%LU,
     &T3D_FILES(T3DL10)%NAME,INFOGR,NELEM2,SALI_DEL,TEMP_DEL,VELO_DEL,
     &DIFF_DEL,MARDAT,MARTIM,FLODEL%R,.TRUE.,MESH3D%W%R,OPT_HNEG.EQ.2,
     &FLULIM%R,V2DPAR%R,MESH2D%KNOLG%I,MESH2D,MESH3D)
!
      ENDIF
!
!----------------------------------------------------------------------
!
! MASKING
!
      IF(ISOUSI.EQ.NSOUSI) THEN
        IF(MSK) THEN
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE MASK3D'
        IF(MSK) CALL MASK3D(MESH3D%IFABOR%I,MASKEL%R,MASKPT,MASKBR%R,
     &          X2%R,Y2%R,ZF%R,ZFE%R,H%R,HMIN,AT,LT,IT1%I,
     &          MESH3D%NELBOR%I,NELMAX2,NELEM2,NPOIN2,NPTFR2,
     &          NPLAN,NETAGE,IELM3,MESH2D)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE MASK3D'
        ENDIF
      ENDIF
!
! COMPUTES SURFACE GRADIENTS AT TIME LEVEL N+1 AND DSSUDT
!
      CALL FSGRAD(GRADZS,ZFLATS,Z(NPOIN3-NPOIN2+1:NPOIN3),
     &            ZF,IELM2H,MESH2D,MSK,MASKEL,
     &            UNSV2D,T2_01,NPOIN2,OPTBAN,SVIDE)
!
      CALL OS( 'X=Y-Z   ', X=DSSUDT, Y=H, Z=HN )
      CALL OS( 'X=CX    ', X=DSSUDT, C=1.D0/DT )
!
! COMPUTES THE VOLUMES ASSOCIATED WITH NODES
!
      CALL VECTOR(VOLU, '=', 'MASBAS          ',IELM3,1.D0-AGGLOH,
     &  SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,MESH3D,.FALSE.,MASKEL)
      IF(AGGLOH.GT.1.D-6) THEN
        CALL VECTOR(VOLU, '+', 'MASBAS2         ',IELM3,AGGLOH,
     &  SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,SVIDE,MESH3D,.FALSE.,MASKEL)
      ENDIF
      IF(NCSIZE.GT.1) THEN
        CALL OS('X=Y     ',X=VOLUPAR,Y=VOLU)
        CALL PARCOM(VOLUPAR,2,MESH3D)
      ENDIF
!
! IN 2D, ONLY IF MASKING (OTHERWISE NOTHING CHANGED)
!
      IF(MSK) CALL MASBAS2D(VOLU2D,V2DPAR,UNSV2D,
     &                      IELM2H,MESH2D,MSK,MASKEL,T2_01,SVIDE)
!
!-----------------------------------------------------------------------
! CONTINUITY STEP (NON-HYDROSTATIC OPTION) IN NEW MESH
!-----------------------------------------------------------------------
!
      IF(NONHYD.AND..NOT.DPWAVEQ) THEN
!
        IF(INFOGR) CALL MITTIT(18,AT,LT)
!
        CALL OS ('X=Y     ', X=W , Y=WD  )
!
!-----------------------------------------------------------------------
!
! COMPUTES THE DYNAMIC PRESSURE
!
!       WITH WAVE EQUATION, DYNAMIC PRESSURE HERE IS INCREMENTAL
!       THUS WITHOUT BOUNDARY CONDITIONS
        BC=.NOT.DPWAVEQ
        CALL PREDIV(DP,U,V,W,INFOGR,BC,1,.TRUE.,.TRUE.,.TRUE.)
!
!-----------------------------------------------------------------------
! VELOCITY PROJECTION STEP
!-----------------------------------------------------------------------
!
        IF(INFOGR) CALL MITTIT(19,AT,LT)
!
        CALL VELRES(U%R,V%R,W%R,DP,
     &              T3_01,T3_02,T3_03,MSK,MASKEL,MESH3D,
     &              SVIDE,IELM3,NPLAN,OPTBAN,UNSV3D,NPOIN3,NPOIN2,
     &              SIGMAG,IPBOT%I)
!
!       BOUNDARY CONDITIONS ON W AT THE BOTTOM AND FREE SURFACE
!
!       FREE SURFACE (NOT ALWAYS TO BE DONE, DSSUDT IS SOMETIMES TOO BIG)
!
        IF(CLDYN) THEN
!
          CALL OV('X=Y     ',W%R(NPOIN3-NPOIN2+1:NPOIN3),DSSUDT%R,
     &                       DSSUDT%R,0.D0,NPOIN2)
          CALL OV('X=X+YZ  ',W%R(NPOIN3-NPOIN2+1:NPOIN3),
     &                       GRADZS%ADR(1)%P%R,
     &                       U%R(NPOIN3-NPOIN2+1:NPOIN3),0.D0,NPOIN2)
          CALL OV('X=X+YZ  ',W%R(NPOIN3-NPOIN2+1:NPOIN3),
     &                       GRADZS%ADR(2)%P%R,
     &                       V%R(NPOIN3-NPOIN2+1:NPOIN3),0.D0,NPOIN2)
!
        ENDIF
!
!       BOTTOM
!
        IF(VELPROBOT) THEN
          IF(SIGMAG.OR.OPTBAN.EQ.1) THEN
            DO I=1,NPOIN2
              DO IP=0,IPBOT%I(I)
                I3D=IP*NPOIN2+I
                W%R(I3D)=GRADZF%ADR(1)%P%R(I)*U%R(I3D)
     &                  +GRADZF%ADR(2)%P%R(I)*V%R(I3D)
              ENDDO
            ENDDO
          ELSE
            DO I=1,NPOIN2
              W%R(I)=GRADZF%ADR(1)%P%R(I)*U%R(I)
     &              +GRADZF%ADR(2)%P%R(I)*V%R(I)
            ENDDO
          ENDIF
        ENDIF
!
!       RE-ENSURES THE DIRICHLET BOUNDARY CONDITIONS AND U.N = 0
!
        CALL AIRWIK2(LIHBOR%I, UBORF%R, VBORF%R, WBORF%R,
     &               LIUBOF%I, LIVBOF%I, LIWBOF%I,
     &               UBORL%R, VBORL%R, WBORL%R,
     &               LIUBOL%I, LIVBOL%I, LIWBOL%I,
     &               UBORS%R, VBORS%R, WBORS%R,
     &               LIUBOS%I, LIVBOS%I, LIWBOS%I,
     &               U%R,V%R,W%R,MESH2D%XNEBOR%R,MESH2D%YNEBOR%R,
     &               NBOR2%I,NPTFR2,NPLAN,NPOIN2,KENT,KADH,KLOG,KENTU,
     &               MESH2D%KP1BOR%I,VELPROLAT)
!
      ENDIF ! IF NONHYD
!
!-----------------------------------------------------------------------
!     PREPARING SOURCE TERMS FOR ADVECTION-DIFFUSION STEP 
!-----------------------------------------------------------------------
!
!     PREPARING SOURCE TERMS FOR K-EPSILON AND K-OMEGA MODELS
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
!
        IF (INFOGR) CALL MITTIT(7,AT,LT)
!
        S0AK%TYPR='Q'
        S0EP%TYPR='Q'
        S1AK%TYPR='Q'
        S1EP%TYPR='Q'
!
        IF(ITURBV.EQ.3) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE SOUKEP'
        CALL SOUKEP(S0AK%R,S0EP%R,S1AK%R,S1EP%R,
     &              U,V,W,DELTAR,RI%R,T3_01,T3_02,T3_03,T3_04,
     &              T3_05,T3_06,T3_07,T3_08,T3_09,
     &              T3_10,AK%R,EP%R,C1,C2,CMU,GRAV,
     &              T3_11,NPOIN3,MSK,MASKEL,MESH3D,IELM3,SVIDE,DT,
     &              VENT,WIND,H,EBORS,NPOIN2,KMIN,EMIN,PRANDTL)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SOUKEP'
!
        ENDIF
!
        IF(ITURBV.EQ.7) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE SOUKOM'
        CALL SOUKOM(S0AK,S0EP,S1AK,S1EP,U,V,W,
     &              DELTAR,T3_01,T3_02,T3_03,
     &              T3_04,T3_05,T3_06,T3_07,T3_08,
     &              T3_09,T3_10,T3_12,T3_13,
     &              T3_14,T3_15,T3_16,T3_17,
     &              ROTAT,AK,EP,ALPHA,BETA,BETAS,GRAV,
     &              T3_11,NPOIN3,MSK,MASKEL,MESH3D,IELM3,SVIDE,PRANDTL)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE SOUKOM'
!
        ENDIF
!
      ENDIF
!
!     PREPARING SOURCE TERMS FOR TRACERS
!
      IF(NTRAC.GT.0) CALL SOURCE_TRAC
!
!-----------------------------------------------------------------------
! ADVECTION-DIFFUSION STEP FOR ALL ADVECTED VARIABLES
!-----------------------------------------------------------------------
!
!     ALL ADVECTION SCHEMES EXCEPT SUPG
!
      IF (INFOGR .AND. (.NOT.NONHYD)) CALL MITTIT(9,AT,LT)
      IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE PRECON'
      CALL PRECON(W,WS,ZPROP,ISOUSI,LT)
      IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE PRECON'
!
!-----------------------------------------------------------------------
!     NOW CVDF3D WILL DO SUPG AND DIFFUSION
!-----------------------------------------------------------------------
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
!
        CLKMIN = .TRUE.
        CLKMAX = .TRUE.
        YASEM3D = .FALSE.
        YAWCHU = .FALSE.
        NEWDIF = .TRUE.
        TETATRA=MIN(TETADI,1.D0)
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CVDF3D POUR AK'
        CALL CVDF3D
     & (AK,AKC,AKN,VISCVI,SIGMAK,S0AK,.TRUE.,S1AK,.TRUE.,
     &  KBORL, KBORF, KBORS, AKBORL, AKBORF, AKBORS,
     &  BKBORL, BKBORF, BKBORS, LIKBOL, LIKBOF, LIKBOS,
     &  FLUX%R(1), FLUEXT,FLUEXTPAR,KMIN, CLKMIN, KMAX, CLKMAX,
     &  SCHCKE,SCHDKE,SLVDKE,TRBAKE,INFOGR,NEWDIF,CALCFLU(4),
     &  T2_01,T2_02,T2_03,
     &  T3_01,T3_02,T3_03,T3_04, MESH3D , IKLE3 , MASKEL , MTRA1,
     &  W1,NPTFR3,MMURD,MURD_TF,VOLU,VOLUPAR,VOLUN ,VOLUNPAR,
     &  NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &  NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &  INCHYD,MASKBR,MASKPT,SEM3D,YASEM3D,SVIDE,IT1,IT2,
     &  TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,TETATRA,
     &  YAWCHU,WCHU,AGGLOD,NSCE,SOURCES,AK_SCE%R,
     &  NUMLIQ%I,DIRFLU,NFRLIQ,VOLUT,ZT,ZPROP,CALCRAIN(4),
     &  PLUIE,PARAPLUIE,FLODEL,FLOPAR,SIGMAG,IPBOT%I)
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CVDF3D POUR AK'
!
        CLEMIN  = .TRUE.
        CLEMAX  = .TRUE.
        YASEM3D = .FALSE.
        YAWCHU  = .FALSE.
!
!       NEGLECTS MOLECULAR DIFFUSIVITY...
!       DIFFUSION MATRIX NOT RECOMPUTED
        NEWDIF = .FALSE.
        CALL OM('M=CN    ',MDIFF,MDIFF,SVIDE,SIGMAE/SIGMAK,MESH3D)
!
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE CVDF3D POUR EP'
        CALL CVDF3D
     & (EP,EPC,EPN,VISCVI,SIGMAE,S0EP,.TRUE.,S1EP,.TRUE.,
     &  EBORL, EBORF, EBORS, AEBORL, AEBORF, AEBORS,
     &  BEBORL, BEBORF, BEBORS, LIEBOL, LIEBOF, LIEBOS,
     &  FLUX%R(1), FLUEXT,FLUEXTPAR,EMIN, CLEMIN, EMAX, CLEMAX,
     &  SCHCKE,SCHDKE,SLVDKE,TRBAKE,INFOGR,NEWDIF,CALCFLU(5),
     &  T2_01,T2_02,T2_03,
     &  T3_01,T3_02,T3_03,T3_04, MESH3D , IKLE3 , MASKEL , MTRA1,
     &  W1,NPTFR3,MMURD,MURD_TF,VOLU,VOLUPAR,VOLUN,VOLUNPAR,
     &  NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &  NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &  INCHYD,MASKBR,MASKPT,SEM3D,YASEM3D,SVIDE,IT1,IT2,
     &  TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,TETATRA,
     &  YAWCHU,WCHU,AGGLOD,NSCE,SOURCES,EP_SCE%R,
     &  NUMLIQ%I,DIRFLU,NFRLIQ,VOLUT,ZT,ZPROP,CALCRAIN(5),
     &  PLUIE,PARAPLUIE,FLODEL,FLOPAR,SIGMAG,IPBOT%I)
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE CVDF3D POUR EP'
!
      ENDIF
!
!-----------------------------------------------------------------------
!
! COMPUTES THE VISCOSITIES VISCVI, VISCTA AND VISCTP
!
      IF(ITURBH.EQ.1.OR.ITURBV.EQ.1) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCOS'
        CALL VISCOS(VISCVI,VISCTA,DNUTAV,DNUTAH,
     &              DNUVIV,DNUVIH,NTRAC,ITURBH,ITURBV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCOS'
!
      ENDIF
!
      IF(ITURBV.EQ.2) THEN
!
         IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCLM'
         CALL VISCLM(VISCVI,VISCTA,RI,U,V,DELTAR,X3,Y3,Z3,H,
     &               T3_01, T3_02, T3_03, T3_04, T3_05, T3_06, T3_07,
     &               SVIDE, MESH3D, IELM3, GRAV, NPLAN,
     &               NPOIN3, NPOIN2, NTRAC, MSK, MASKEL,
     &               TA,MIXING,DAMPING,IND_T,DNUVIV,DNUTAV,KARMAN,
     &               PRANDTL,UETCAR,KFROT,RUGOF,ZF)
         IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCLM'
!
      ENDIF
!
      IF(ITURBV.EQ.3.OR.ITURBH.EQ.3) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCKE'
        CALL VISCKE(VISCVI,VISCTA,AK,EP,NTRAC,CMU,
     &              DNUVIH,DNUVIV,DNUTAH,DNUTAV,KMIN,EMIN,
     &              ITURBH,ITURBV,PRANDTL)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCKE'
!
      ENDIF
!
      IF(ITURBH.EQ.4) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISSMA'
        CALL VISSMA(VISCVI,VISCTA,
     &              DNUTAH,DNUVIH,DNUVIV,DNUTAV,
     &              U,V,W,T3_01,T3_02,T3_03,T3_04,T3_05,T3_06,
     &              SVIDE,MESH3D,
     &              IELM3,NTRAC,MSK,MASKEL,ITURBV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISSMA'
!
      ENDIF
!
      IF(ITURBH.EQ.7) THEN
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE VISCKO'
        CALL VISCKO(VISCVI,VISCTA,ROTAT,AK,EP,NTRAC,CMU,
     &              DNUVIH,DNUVIV,DNUTAH,DNUTAV)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE VISCKO'
!
      ENDIF
!
      IF(OPTBAN.EQ.1) THEN
!
        CALL VISCLIP(VISCVI,VISCTA,H,NPLAN,NPOIN3,NPOIN2,NTRAC)
!
      ENDIF
!
!-----------------------------------------------------------------------
C ADVECTION-DIFFUSION OF TRACERS
!
      IF(NTRAC.GT.0) THEN
!
        IF (INFOGR) CALL MITTIT(5,AT,LT)
!
          SIGMTA = 1.D0
          TAMIN  = 0.D0
          TAMAX  = 1.D0
          CTAMIN = .FALSE.
          CTAMAX = .FALSE.
          YASEM3D = .FALSE.
          NEWDIF = .TRUE.
          TETATRA=MIN(TETADI,1.D0)
!
        DO ITRAC = 1,NTRAC
!
          IF(SEDI.AND.ITRAC.EQ.NTRAC) THEN
            YAWCHU=.TRUE.
!           SOLVER STRUCTURE
            SLVD=SLVDSE
          ELSE
            YAWCHU=.FALSE.
!           SOLVER STRUCTURE
            SLVD=SLVDTA(ITRAC)
          ENDIF
!
          IF(DEBUG.GT.0) THEN
            WRITE(LU,*) 'APPEL DE CVDF3D POUR TRACEUR ',ITRAC
          ENDIF
!
          CALL CVDF3D
     &   (TA%ADR(ITRAC)%P,TAC%ADR(ITRAC)%P,TAN%ADR(ITRAC)%P,
     &   VISCTA%ADR(ITRAC)%P,SIGMTA,
     &   S0TA%ADR(ITRAC)%P,.TRUE.,S1TA%ADR(ITRAC)%P,.TRUE.,
     &   TABORL%ADR(ITRAC)%P,TABORF%ADR(ITRAC)%P,TABORS%ADR(ITRAC)%P,
     &   ATABOL%ADR(ITRAC)%P,ATABOF%ADR(ITRAC)%P,ATABOS%ADR(ITRAC)%P,
     &   BTABOL%ADR(ITRAC)%P,BTABOF%ADR(ITRAC)%P,BTABOS%ADR(ITRAC)%P,
     &   LITABL%ADR(ITRAC)%P,LITABF%ADR(ITRAC)%P,LITABS%ADR(ITRAC)%P,
     &   FLUX%R(5+ITRAC),FLUEXT,FLUEXTPAR,
     &   TAMIN,CTAMIN,TAMAX,CTAMAX,SCHCTA(ITRAC),
     &   SCHDTA,SLVD,TRBATA,INFOGR,NEWDIF,CALCFLU(5+ITRAC),
     &   T2_01,T2_02,T2_03,T3_01,T3_02,T3_03,T3_04,MESH3D,IKLE3,MASKEL,
     &   MTRA1,W1,NPTFR3,MMURD,MURD_TF,VOLU,VOLUPAR,VOLUN,VOLUNPAR,
     &   NBOR3,NPOIN3,NPOIN2,DT,MSK,NELEM2,NELEM3,
     &   NPLAN,LV,IELM3,MSUPG,IELM2H,IELM2V,MDIFF,MTRA2,
     &   INCHYD,MASKBR,MASKPT,SEM3D,YASEM3D,SVIDE,IT1,IT2,
     &   TRAV3,MESH2D,MATR2H,H,OPTBAN,OPTDIF,TETATRA,
     &   YAWCHU,WCHU,AGGLOD,NSCE,SOURCES,TA_SCE%ADR(ITRAC)%P%R,
     &   NUMLIQ%I,DIRFLU,NFRLIQ,VOLUT,ZT,ZPROP,CALCRAIN(5+ITRAC),
     &   PLUIE,PARAPLUIE,FLODEL,FLOPAR,SIGMAG,IPBOT%I)
!
!         NEWDIF=.FALSE. (POSSIBLE IF SIGMTA UNCHANGED)
!
          IF(DEBUG.GT.0) THEN
            WRITE(LU,*) 'RETOUR DE CVDF3D POUR TRACEUR ',ITRAC
          ENDIF
!
        ENDDO
!
!-----------------------------------------------------------------------
C COMPUTES DELRA RHO / RHO FOR THE BUOYANCY TERMS
!
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE DRSURR'
        CALL DRSURR(DELTAR,TA,BETAC,T0AC,T3_01,RHO0,RHOS,DENLAW,
     &              SEDI,NTRAC,IND_T,IND_S)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE DRSURR'

      ENDIF
!
      END DO SUBITER
!
!-----------------------------------------------------------------------
!
C SEDIMENTOLOGY : BOTTOM TREATMENT
!
      IF(SEDI) THEN
!
C       FONVAS DOES ZF=ZR+HDEP, THUS HDEP MUST INCLUDE BEDLOAD
!
        CALL FONVAS
     &  (IVIDE%R, EPAI%R, CONC%R, TREST, TEMP%R, HDEP%R, PDEPO%R,
     &   ZR%R, ZF%R,TA%ADR(NTRAC)%P%R, WCHU%R,
     &   T3_01%R, T3_02%R, T3_03%R, NPOIN2, NPOIN3, NPFMAX, NCOUCH,
     &   NPF%I, LT, DT, DTC, GRAV, RHOS, CFMAX, CFDEP, EPAI0,
     &   TASSE,GIBSON)
!
      ENDIF
!
C UPDATES GEOMETRY IF THE BOTTOM HAS EVOLVED
!
      IF(INCLUS(COUPLING,'SISYPHE').OR.SEDI) THEN
!
C       COPIES MODIFIED BOTTOM TOPOGRAPHY INTO Z AND ZPROP
        CALL OV('X=Y     ',      Z(1:NPOIN2),ZF%R,ZF%R,0.D0,NPOIN2)
        CALL OV('X=Y     ',ZPROP%R(1:NPOIN2),ZF%R,ZF%R,0.D0,NPOIN2)
C       COMPUTES NEW BOTTOM GRADIENTS AFTER SEDIMENTATION
        CALL GRAD2D(GRADZF%ADR(1)%P,GRADZF%ADR(2)%P,ZPROP,NPLAN,SVIDE,
     &              UNSV2D,T2_02,T2_03,T2_04,
     &              IELM2H,MESH2D,MSK,MASKEL)
!       USEFUL ? NOT SURE, IS DONE AT EACH TIME-STEP ELSEWHERE, SO..
C       COMPUTES NEW Z COORDINATES
C       CALL CALCOT(Z,H%R)
C       USEFUL ? NOT SURE, IS DONE AT EACH TIMESTEP ELSEWHERE, SO..
C       CALL CALCOT(ZPROP%R,HPROP%R)
C       CALL FSGRAD(GRADZS,ZFLATS,Z(NPOIN3-NPOIN2+1:NPOIN3),
C    *              ZF,IELM2H,MESH2D,MSK,MASKEL,
C    *              UNSV2D,T2_01,NPOIN2,OPTBAN,SVIDE)
!
      ENDIF
!
!-----------------------------------------------------------------------
C RESULT OUTPUT
!
C PREPARES 3D OUTPUT
!
      IF (MOD(LT,GRAPRD).EQ.0.AND.LT.GE.GRADEB) THEN
!
C PREPARES 2D AND 3D OUTPUT
!
      CALL PRERES_TELEMAC3D(LT)
!
C 3D OUTPUT
!
      CALL BIEF_DESIMP(T3D_FILES(T3DRES)%FMT,VARSO3,
     &                 HIST,0,NPOIN3,T3D_FILES(T3DRES)%LU,BINRES,AT,LT,
     &                 LISPRD,GRAPRD,
     &                 SORG3D,SORIM3,MAXVA3,TEXT3,GRADEB,LISDEB)
!
C 2D OUTPUT
!
      CALL BIEF_DESIMP(T3D_FILES(T3DHYD)%FMT,VARSOR,
     &                 HIST,0,NPOIN2,T3D_FILES(T3DHYD)%LU,BINHYD,AT,LT,
     &                 LISPRD,GRAPRD,
     &                 SORG2D,SORIMP,MAXVAR,TEXTE,GRADEB,LISDEB)
!
      ENDIF
!
C SEDIMENTOLOGY OUTPUT
!
      IF(SEDI.AND.T3D_FILES(T3DSED)%NAME(1:1).NE.' ') THEN
        IF(DEBUG.GT.0) WRITE(LU,*) 'APPEL DE DESSED'
        CALL DESSED(NPF%I,IVIDE%R,EPAI%R,HDEP%R,
     &              CONC%R,TEMP%R,ZR%R,NPOIN2,NPFMAX,
     &              NCOUCH,NIT,GRAPRD,LT,DTC,TASSE,GIBSON,
     &              T3D_FILES(T3DSED)%LU,TITCAS,BIRSED,0)
        IF(DEBUG.GT.0) WRITE(LU,*) 'RETOUR DE DESSED'
      ENDIF
!
C SCOPE OUTPUT: CROSS-SECTIONS, SECTIONS, ETC.
!
      CALL SCOPE(U%R,V%R,W%R,H%R,ZF%R,X,Y,Z,T3_01%R,T3_02%R,T3_03%R,
     &           SURFA2%R,IKLE3%I,MESH2D%IFABOR%I,NELEM3,NELEM2,
     &           NPOIN2,NPOIN3,NETAGE,NPLAN,LT,AT,DT,NIT,
     &           T3D_FILES(T3DSCO)%LU,PRIVE)
!
C OPTIONAL USER OUTPUT
!
      CALL UTIMP(LT,AT,GRADEB,GRAPRD,LISDEB,LISPRD)
!
C SEDIMENT OUTPUT
!
      IF (SEDI) CALL IMPSED
     &   (IVIDE%R, EPAI%R, CONC%R, TEMP%R, HDEP%R, PDEPO%R, FLUER%R,
     &    ZR%R, ZF%R, TA%ADR(NTRAC)%P%R, WCHU%R, X, Y,
     &    NPOIN2, NPOIN3, NPFMAX, NCOUCH, NPF%I, LT, RHOS, CFMAX,
     &    CFDEP, EPAI0, TASSE, GIBSON, PRIVE, LISPRD)
!
!-----------------------------------------------------------------------
C DROGUES/FLOATS/BUOYS
!
      IF(NFLOT.GT.0) THEN
!
         IF (INFOGR) CALL MITTIT(12,AT,LT)
!
         CALL DERI3D(UCONV%R,VCONV%R,WSCONV%R,DT,X,Y,ZCHAR%R,Z,IKLE2%I,
     &               MESH3D%IFABOR%I,LT,NPOIN2,NELEM2,NPLAN,NPLINT,
     &               MESH2D%SURDET%R,XFLOT%R,YFLOT%R,ZFLOT%R,ZSFLOT%R,
     &               SHPFLO%R,SHZFLO%R,DEBFLO%I,FINFLO%I,ELTFLO%I,
     &               ETAFLO%I,NFLOT,NITFLO,FLOPRD)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
C MASS BALANCE FOR THE CURRENT TIMESTEP
!
      IF (BILMAS) THEN
!
        IF (.NOT.INFMAS) INFOGR = .FALSE.
        INFOGR = INFOGR .AND. LISTIN
        IF (INFOGR) CALL MITTIT(10,AT,LT)
!
        CALL MASS3D(INFOGR,LT)
!
        IF(SEDI) CALL SED3D
     &     (MASSE%R(5+NTRAC),U%R,V%R,W%R,WCHU%R,TA%ADR(NTRAC)%P%R,X,Y,Z,
     &      IVIDE%R, EPAI%R, HDEP%R, CONC%R, FLUER%R, PDEPO%R,
     &      SURFA2%R, T3_01%R, T3_02%R, IKLE2%I,
     &      NELEM2, NPOIN2, NPOIN3, NTRAC, NVBIL, NPFMAX, NCOUCH,
     &      NPF%I, LT, AT, DT, INFOGR, TASSE, GIBSON, RHOS, CFDEP)
!
        CALL BIL3D(LT,MESH3D%IKLBOR%I,IKLE2%I,NPTFR2,NETAGE,NELEM2)
!
      ENDIF
!
C COMPARES WITH REFERENCE FILE
!
      IF(VALID) THEN
        CALL BIEF_VALIDA(TRAV3,TEXTP3,
     &                   T3D_FILES(T3DREF)%LU,T3D_FILES(T3DREF)%FMT,
     &                   VARSO3,TEXT3,
     &                   T3D_FILES(T3DRES)%LU,T3D_FILES(T3DRES)%FMT,
     &                   MAXVA3,NPOIN3,LT,NIT,ALIRE3D)
      ENDIF
!
!
C CHECKS VALUES SHARED BETWEEN SUBDOMAINS
!
C     CALL CHECK_DIGITS(H ,T2_01,MESH2D)
C     CALL CHECK_DIGITS(U ,T3_01,MESH3D)
C     CALL CHECK_DIGITS(V ,T3_01,MESH3D)
C     CALL CHECK_DIGITS(W ,T3_01,MESH3D)
C     IF(NTRAC.GT.0) THEN
C       DO ITRAC=1,NTRAC
C         CALL CHECK_DIGITS(TA%ADR(ITRAC)%P,T3_01,MESH3D)
C       ENDDO
C     ENDIF
!
!
!
C END OF TIME LOOP
!
      END DO TIMELOOP
!
!=======================================================================
C THE TIME LOOP ENDS HERE
!=======================================================================
!
C TRACER/FLOAT OUTPUT
!
C NOTE: BINHYD DOES NOT CORRESPOND TO NOMRBI (BUT THERE IS NO SPECIFIC
C                                             KEYWORD FOR WHAT BINRBI
C                                             SHOULD BE)
!
      IF(NFLOT.NE.0) THEN
        CALL SFLO3D(XFLOT%R,YFLOT%R,ZFLOT%R,IKLFLO%I,
     &              TRAFLO%I,DEBFLO%I,FINFLO%I,NFLOT,NITFLO,FLOPRD,
     &              T3D_FILES(T3DRBI)%LU,LISTIN,TITCAS,BINHYD,
     &              T3D_FILES(T3DRBI)%NAME,NIT,I_ORIG,J_ORIG)
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
