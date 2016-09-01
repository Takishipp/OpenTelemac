!                    **********************
                     SUBROUTINE MURD3D_LIPS
!                    **********************
!
     &(SFC,FC,FN,VOLU,VOLUN,B,DB,XB,DIM1XB,
     & FNSUB,TRA02,TRA03,SFNSUB,STRA02,STRA03,IKLE3,MESH2D,MESH3D,
     & NELEM3,NPOIN3,DT,INFOR,CALFLU,FLUX,FLUEXT,S0F,NSCE,ISCE,KSCE,
     & SOURCES,FSCE,RAIN,PLUIE,PARAPLUIE,TRAIN,NPOIN2,MINFC,MAXFC,
     & OPTBAN,GLOSEG,DIMGLO,NSEG,NPLAN,IELM3,OPTSOU,
     & NPTFR3,NBOR3,FLUEXTPAR,FBORL,ZN,FI_I,TRAV10,
     & TETAF_VAR,T2_01,BEDBOU,BEDFLU,VOLU2D,NCO_DIST,NSP_DIST,
     & SLVDIF,ORISEG,MTRA1,T3_14,T3_15,T3_16,ELTSEG,TB2,
     & VNP1MT,DENOM,VOLUN_SUB,VOLU_SUB,ZSUBN,ZSUBP)
!
!***********************************************************************
! TELEMAC3D   V7P2
!***********************************************************************
!
!brief ADVECTION OF A VARIABLE WITH THE
!+     LOCALLY IMPLICIT DISTRIBUTIVE SCHEME,
!+     BASED ON THE N, PSI, PREDICTOR CORRECTOR SCHEMES.
!+     This scheme is the equivalent of the 2D LIPS, but in 3D.
!
!history S. PAVAN (LHSV) & J-M HERVOUET (EDF LAB, LNHE)
!+     01/09/2016
!+     V7P2
!+     First version.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| B              |-->| MATRIX
!| BEDBOU         |-->| OPEN BOUNDARY CONDITIONS ON THE BED
!| BEDFLU         |-->| RIGHT HAND SIDE OF CONTINUITY EQUATION
!|                |   | WHEN DEALING WITH OPEN BOUNDARIES ON THE BED
!| CALFLU         |-->| INDICATE IF FLUX IS CALCULATED FOR BALANCE
!| DB             |<->| NOT SYMMETRIC MURD MATRIX OPTION N
!| DENOM          |<->| WORK BIEF_OBJ
!| DIMGLO         |-->| FIRST DIMENSION OF GLOSEG
!| DIM1XB         |-->| FIRST DIMENSION OF XB
!| DT             |-->| TIME STEP
!| ELTSEG         |-->| SEGMENTS FORMING AN ELEMENT
!| FBORL          |<->| DIRICHLET CONDITIONS ON F ON LATERAL BOUNDARIES
!| FC             |<->| VARIABLE AFTER CONVECTION
!| FI_I           |<->| WORKING VECTOR
!| FLODEL         |-->| FLUX BY MESH EDGES
!| FLOPAR         |-->| FLUXES BY SEGMENT, ASSEMBLED IN PARALLEL
!| FLUEXT         |-->| OUTPUT FLUX BY NODE
!| FLUEXTPAR      |-->| OUTPUT FLUX BY NODE IN PARALLEL
!| FLUX           |<->| FLUXES TO BE CHANGED
!| FN             |-->| VARIABLE AT TIME N
!| FSCE           |-->| SOURCE
!| GLOSEG         |-->| FIRST AND SECOND POINT OF SEGMENTS
!| IELM3          |-->| TYPE OF ELEMENT (41:PRISM, ETC.)
!| IKLE3          |-->| GLOBAL 3D CONNECTIVITY
!| INFOR          |-->| INFORMATIONS FOR SOLVERS
!| ISCE           |-->| ADDRESSES OF SOURCE POINTS IN THE 2D MESH
!| KSCE           |-->| PLANE NUMBERS OF SOURCE POINTS IN THE 2D MESH
!| LV             |-->| VECTOR LENGTH OF THE MACHINE
!| MASKEL         |-->| MASKING OF ELEMENTS
!|                |   | =1. : NORMAL   =0. : MASKED ELEMENT
!| MASKPT         |-->| MASKING PER POINT.
!|                |   | =1. : NORMAL   =0. : MASKED
!| MAXFC          |<->| WORKING VECTOR
!| MESH2D         |<->| 2D MESH
!| MESH3D         |<->| 3D MESH
!| MINFC          |<->| WORKING VECTOR
!| MSK            |-->| IF YES, THERE IS MASKED ELEMENTS.
!| MTRA1          |<->| WORKING MATRIX
!| NBOR3          |-->| CONNECTIVITY TABLE FOR NODE BOUNDARY
!| NCO_DIST       |-->| NUMBER OF CORRECTIONS OF DISTRIBUTIVE SCHEMES
!| NSP_DIST       |-->| NUMBER OF SUB-ITERATIONS OF DISTRIBUTIVE SCHEMES
!| NELEM3         |-->| NUMBER OF ELEMENTS IN 3D
!| NPLAN          |-->| NUMBER OF PLANES IN THE 3D MESH OF PRISMS
!| NPOIN2         |-->| NUMBER OF POINTS IN 2D
!| NPOIN3         |-->| NUMBER OF 3D POINTS
!| NPTFR3         |-->| NUMBER OF 3D BOUNDARY POINTS
!| NSCE           |-->| NUMBER OF GIVEN POINTS FOR SOURCES
!| NSEG           |-->| NUMBER OF SEGMENTS IN 2D
!| OPTADV         |-->| NUMBER OF SEGMENTS
!|                |   | 1 CLASSICAL EXPLICIT SCHEME
!|                |   | 2 PREDICTOR CORRECTOR
!|                |   | 3 PREDICTOR CORRECTOR SECOND ORDER
!|                |   | 4 LOCALLY IMPLICIT
!| OPTBAN         |-->| OPTION FOR TIDAL FLATS, IF 1, FREE SURFACE
!|                |   | MODIFIED AND PIECE-WISE LINEAR
!| OPTSOU         |-->| OPTION FOR THE TREATMENT OF SOURCES 
!| ORISEG         |-->| ORIENTATION OF SEGMENTS
!| PLUIE          |-->| RAIN IN M/S MULTIPLIED BY VOLU2D
!| RAIN           |-->| IF YES, THERE IS RAIN OR EVAPORATION
!| S0F            |-->| EXPLICIT SOURCE TERM
!| SCHCF          |-->| ADVECTION SCHEME FOR F
!| SFC            |<->| BIEF STRUCTURE OF FC
!| SLVDIF         |-->| SOLVER FOR DIFFUSION
!| SOURCES        |-->| SOURCES
!| SFNSUB         |<->| STRUCTURE OF TRA01, HERE RENAMES
!| STRA02         |<->| STRUCTURE OF TRA02
!| STRA03         |<->| STRUCTURE OF TRA03
!| TB2            |<->| BLOCK OF WORK VECTORS
!| TETAF_VAR      |<->| WORKING VECTOR
!| FNSUB          |<->| WORK ARRAY OF DIMENSION NPOIN3
!| TRA02          |<->| WORK ARRAY
!| TRA03          |<->| WORK ARRAY
!| TRAIN          |-->| VALUE OF TRACER IN RAIN
!| TRAV10         |<->| WORK VECTOR
!| T2_01          |<->| WORK VECTOR DIMENSION NPOIN2
!| T3_14          |<->| WORK VECTOR
!| T3_15          |<->| WORK VECTOR 
!| T3_16          |<->| WORK VECTOR
!| VOLU           |-->| CONTROL VOLUME AT TIME N+1
!| VOLUN          |-->| CONTROL VOLUME AT TIME N
!| VOLU_SUB       |-->| CONTROL VOLUME AT TIME N+1 FOR SUB-ITERATION
!| VOLUN_SUB      |-->| CONTROL VOLUME AT TIME N FOR SUB-ITERATION
!| XB             |<->| NOT SYMMETRIC MURD MATRIX OPTION N
!| ZN             |-->| Z SAVED AT TIME T(N)
!| ZSUBN          |<->| ELEVATIONS AT BEGINNING OF SUB-ITERATIONS
!| ZSUBP          |<->| ELEVATIONS AT END OF SUB-ITERATIONS
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE INTERFACE_PARALLEL
      USE DECLARATIONS_TELEMAC
      USE DECLARATIONS_SPECIAL
!
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: NELEM3,NPOIN3,NPOIN2,DIM1XB
      INTEGER, INTENT(IN)             :: IELM3,OPTSOU,NPTFR3
!                                                     6 OR 4
      INTEGER, INTENT(IN)             :: IKLE3(NELEM3,*),NSCE,OPTBAN
!                                        NSEG ARE 2D!
      INTEGER, INTENT(IN)             :: NSEG,NPLAN,DIMGLO,NBOR3(NPTFR3)
      INTEGER, INTENT(IN)             :: GLOSEG(DIMGLO,2)
      INTEGER, INTENT(IN)             :: ORISEG(NELEM3,15)
      INTEGER, INTENT(IN)             :: ELTSEG(NELEM3,15)
      INTEGER, INTENT(IN)             :: ISCE(NSCE),KSCE(NSCE)
      INTEGER, INTENT(IN)             :: NCO_DIST,NSP_DIST
!
      DOUBLE PRECISION, INTENT(INOUT) :: FC(NPOIN3),FBORL(NPTFR3)
      DOUBLE PRECISION, INTENT(IN)    :: FN(NPOIN3),PLUIE(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)    :: PARAPLUIE(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)    :: FLUEXT(NPOIN3)
      DOUBLE PRECISION, INTENT(IN)    :: FLUEXTPAR(NPOIN3)
!
      DOUBLE PRECISION, INTENT(IN)    :: VOLUN(NPOIN3),VOLU(NPOIN3)
      DOUBLE PRECISION, INTENT(IN)    :: FSCE(NSCE),VOLU2D(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)    :: DT,TRAIN
      DOUBLE PRECISION, INTENT(INOUT) :: FNSUB(NPOIN3)
      DOUBLE PRECISION, INTENT(INOUT) :: TRA02(NPOIN3),TRA03(NPOIN3)
      DOUBLE PRECISION, INTENT(INOUT) :: FLUX
      DOUBLE PRECISION, INTENT(INOUT) :: TETAF_VAR(NPOIN3)
      DOUBLE PRECISION, INTENT(INOUT) :: DB(NPOIN3),XB(DIM1XB,NELEM3)
      DOUBLE PRECISION, INTENT(INOUT) :: ZSUBN(NPOIN3),ZSUBP(NPOIN3)
!
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: TRAV10,TB2
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: MTRA1
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: T3_14,T3_15,T3_16
!
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: MINFC,MAXFC,T2_01,B,SFC
      TYPE(BIEF_OBJ),  INTENT(IN)     :: SOURCES,S0F
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: SFNSUB,STRA02,STRA03,FI_I
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: BEDFLU,VNP1MT,DENOM
      TYPE(BIEF_OBJ),  INTENT(INOUT)  :: VOLUN_SUB,VOLU_SUB
      TYPE(BIEF_MESH), INTENT(INOUT)  :: MESH2D,MESH3D
      TYPE(SLVCFG), INTENT(IN)        :: SLVDIF
!
      DOUBLE PRECISION, INTENT(IN)    :: ZN(NPOIN3)
!
      LOGICAL, INTENT(IN)             :: INFOR,CALFLU,RAIN,BEDBOU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER          :: I,ISEG,IPOIN,ISEG3D,OTHERS,IPTFR3,IELEM
      INTEGER          :: IPLAN,IS,IIS,I1,I2,I3,I4,I5,I6,ICOR,N,IP,ITER
      DOUBLE PRECISION :: SECU,C,XSUR6,LOCALMIN,LOCALMAX,COEF
      DOUBLE PRECISION :: H1,H2,H3,H4,H5,H6,SURNSP,DDT
      TYPE(SLVCFG)     :: SLVPSI
!
      DOUBLE PRECISION, POINTER, DIMENSION(:) :: FXMAT,FXMATPAR,SUR2VOL
!
!-----------------------------------------------------------------------
!
      SUR2VOL=>MTRA1%X%R(1:MESH3D%NSEG)
!
      XSUR6 =1.D0/6.D0
      SURNSP=1.D0/NSP_DIST
      DDT=DT/NSP_DIST
!
!-----------------------------------------------------------------------
!
!     SOLVER OPTIONS FOR IMPLICIT SCHEMES : SLVDIF TAKEN BUT EITHER
!                                           GMRES OR DIRECT ASKED
!                                           AND HARDCODED HERE
!                                           KRYLOV DIMENSION SET TO 3
!
!     SEE ALSO TVF_IMP WITH A JACOBI METHOD
!
      SLVPSI%SLV   =SLVDIF%SLV
      SLVPSI%NITMAX=SLVDIF%NITMAX
      SLVPSI%PRECON=SLVDIF%PRECON
      SLVPSI%KRYLOV=SLVDIF%KRYLOV
      SLVPSI%EPS   =SLVDIF%EPS
      SLVPSI%ZERO  =SLVDIF%ZERO
!
!     CHANGING THIS WILL TRIGGER CHANGING THE SIZE OF TB2 IN CALLING
!     PROGRAMMES
      SLVPSI%KRYLOV=3
!
!-----------------------------------------------------------------------
! 
      FXMAT=>MESH3D%MSEG%X%R(1:MESH3D%NSEG)
!     IN PARALLEL MODE, ASSEMBLED AND NON ASSEMBLED VERSIONS ARE DIFFERENT!  
      IF(NCSIZE.GT.1) THEN
        FXMATPAR=>MESH3D%MSEG%X%R(MESH3D%NSEG+1:2*MESH3D%NSEG)
      ELSE
        FXMATPAR=>MESH3D%MSEG%X%R(1:MESH3D%NSEG)
      ENDIF
!
!-----------------------------------------------------------------------
!
!     THE SCHEME IS IMPLEMENTED ONLY FOR PRISMS AT THE MOMENT
!
      IF(IELM3.NE.41) THEN 
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'MURD3D_LIPS : ELEMENT NON CODE : ',IELM3
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'MURD3D_LIPS: ELEMENT NOT IMPLEMENTED: ',IELM3
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF
!
!----------------------------------------------------------------------
!
      CALL CPSTVC(S0F,SFNSUB)
      CALL CPSTVC(S0F,STRA02)
      CALL CPSTVC(S0F,STRA03)
      CALL CPSTVC(S0F,MINFC)
      CALL CPSTVC(S0F,MAXFC)
      CALL CPSTVC(S0F,VNP1MT)
      CALL CPSTVC(S0F,VOLUN_SUB)
      CALL CPSTVC(S0F,VOLU_SUB)
!
!----------------------------------------------------------------------
!
!     WE BUILD THE ASSEMBLED N FLUXES ON SEGMENTS
!     BEWARE: FXMAT(ISEG)>0 MEANS THAT
!     - FOR HORIZONTAL SEGMENTS: 
!     THE FLUX IS ORIENTED LIKE THE 
!     SEGMENTS (FROM THE SMALLER GLOBAL NODE TO THE BIGGER GLOBAL NODE)
!     - FOR VERTICAL AND CROSSED SEGMENTS:
!     THE FLUX GOES FROM THE LOWER PLANE TO THE UPPER PLANE
!
!     EXAMPLE:XM(16,IELEM) IS LAMBDA_{21} AND XM(01,IELEM) IS LAMBDA_{12}
!     VERY VERY IMPORTANT:
!     LAMBDA_{21} IS THE ELEMENTARY FLUX FROM 1 TO 2 AND LAMBDA_{12} IS FROM 2 TO 1
! 
!     FOR THIS REASON THE STORAGE IS DONE AS FOLLOWS (IN ORDER TO HAVE A POSITIVE FLUX 
!     IF THE FLUX HAS THE SAME ORIENTATION OF THE SEGMENT) :
!
      DO ISEG=1,MESH3D%NSEG
        FXMAT(ISEG) = 0.D0
      ENDDO 
!
      DO IELEM=1,NELEM3
!       SEGMENT 1: POINTS 1-2
        ISEG = ELTSEG(IELEM,1)
        IF(ORISEG(IELEM,1).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(16,IELEM) - XB(01,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(16,IELEM) + XB(01,IELEM)
        ENDIF
!       SEGMENT 2: POINTS 2-3
        ISEG = ELTSEG(IELEM,2)
        IF(ORISEG(IELEM,2).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(21,IELEM) - XB(06,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(21,IELEM) + XB(06,IELEM)
        ENDIF
!       SEGMENT 3: POINTS 3-1
        ISEG = ELTSEG(IELEM,3)
        IF(ORISEG(IELEM,3).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(02,IELEM) - XB(17,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(02,IELEM) + XB(17,IELEM)
        ENDIF
!       SEGMENT 4: POINTS 4-5 
        ISEG = ELTSEG(IELEM,4)
        IF(ORISEG(IELEM,4).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(28,IELEM) - XB(13,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(28,IELEM) + XB(13,IELEM)
        ENDIF
!       SEGMENT 5: POINTS 5-6
        ISEG = ELTSEG(IELEM,5)
        IF(ORISEG(IELEM,5).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(30,IELEM) - XB(15,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(30,IELEM) + XB(15,IELEM)
        ENDIF
!       SEGMENT 6: POINTS 6-4
        ISEG = ELTSEG(IELEM,6)
        IF(ORISEG(IELEM,6).EQ.1) THEN
          FXMAT(ISEG) = FXMAT(ISEG) + XB(14,IELEM) - XB(29,IELEM)
        ELSE
          FXMAT(ISEG) = FXMAT(ISEG) - XB(14,IELEM) + XB(29,IELEM)
        ENDIF
!       SEGMENT 7: FROM 1 TO 4
        ISEG = ELTSEG(IELEM,7)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(03,IELEM) + XB(18,IELEM)
!       SEGMENT 8: FROM 2 TO 5
        ISEG = ELTSEG(IELEM,8)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(08,IELEM) + XB(23,IELEM)
!       SEGMENT 9: FROM 3 TO 6
        ISEG = ELTSEG(IELEM,9)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(12,IELEM) + XB(27,IELEM)
!       SEGMENT 10: FROM 1 TO 5 
        ISEG = ELTSEG(IELEM,10)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(04,IELEM) + XB(19,IELEM)
!       SEGMENT 11: FROM 2 TO 4 
        ISEG = ELTSEG(IELEM,11)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(07,IELEM) + XB(22,IELEM)
!       SEGMENT 12: FROM 2 TO 6 
        ISEG = ELTSEG(IELEM,12)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(9,IELEM) + XB(24,IELEM)
!       SEGMENT 13: FROM 3 TO 5 
        ISEG = ELTSEG(IELEM,13)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(11,IELEM) + XB(26,IELEM)
!       SEGMENT 14: FROM 3 TO 4 
        ISEG = ELTSEG(IELEM,14)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(10,IELEM) + XB(25,IELEM)
!       SEGMENT 15: FROM 1 TO 6 
        ISEG = ELTSEG(IELEM,15)
        FXMAT(ISEG) = FXMAT(ISEG) - XB(05,IELEM) + XB(20,IELEM)
      ENDDO
!
!----------------------------------------------------------------------
!
!     LIMITATION OF FLUXES IF POSITIVE DEPTHS ALGORITHM IS USED: 
!     (IN MY OPINION SHOULD BE MANDATORY TO USE THE P.D.A.!)
!     LIMITS 3D FLUXES BY COEFFICIENT OF 2D FLUXES
!     (LIKE IN FLUX3DLIM)
!-----------------------------------------------------------------------
!
!     verification of volumes and fluxes
!
!     CALL OV ('X=Y     ',TRA02, VOLUN, VOLUN, C, NPOIN3)
!     DO ISEG=1,MESH3D%NSEG
!       I1=GLOSEG(ISEG,1)
!       I2=GLOSEG(ISEG,2)
!       TRA02(I1)=TRA02(I1)-FXMAT(ISEG)*DT
!       TRA02(I2)=TRA02(I2)+FXMAT(ISEG)*DT
!     ENDDO 
!     DO IPTFR3=1,NPTFR3
!       IPOIN=NBOR3(IPTFR3)
!       TRA02(IPOIN)=TRA02(IPOIN)-DT*FLUEXT(IPOIN)
!     ENDDO
!     DO I=1,NPOIN3
!       T3_14%R(I)=TRA02(I)-VOLU(I)
!     ENDDO
!     IF(NCSIZE.GT.1) CALL PARCOM(T3_14,2,MESH3D)
!     PRINT*,'ERROR ON VOLUMES=',P_DOTS(T3_14,T3_14,MESH3D)
!
!----------------------------------------------------------------------
!
!     ASSEMBLES THE FLUXES AT INTERFACES IN PARALLEL MODE, THIS
!     IS FOR UPWINDING (STORED IN SECOND DIMENSION OF MESH3D%MSEG)
!
      IF(NCSIZE.GT.1) THEN
        CALL OV('X=Y     ',FXMATPAR,FXMAT,FXMAT,0.D0,MESH3D%NSEG)
        CALL PARCOM2_SEG(FXMATPAR,FXMATPAR,FXMATPAR,
!                        NSEG2D !       MESH2D!
     &                   NSEG,NPLAN,2,1,MESH2D,1,41)
      ENDIF
!
!----------------------------------------------------------------------
!
!     COMPUTATION OF THE LOCAL ADMISSIBLE TIME STEP
!
!----------------------------------------------------------------------
!
!     DENOM WILL CONTAIN THE DENOMINATOR (SUM OF FLUXES..)
!
      DO IPOIN=1,NPOIN3
        DENOM%R(IPOIN)=0.D0
      ENDDO
!
      DO I=1,MESH3D%NSEG
!          ASSEMBLED (THEN FXMAT NOT ASSEMBLED IS USED)
        IF(FXMATPAR(I).GT.0.D0) THEN
!         MAX(...,0.D0) FOR 1
          DENOM%R(GLOSEG(I,1)) = DENOM%R(GLOSEG(I,1)) + FXMAT(I)
        ELSE
!         MAX(...,0.D0) FOR 2
          DENOM%R(GLOSEG(I,2)) = DENOM%R(GLOSEG(I,2)) - FXMAT(I)
        ENDIF
      ENDDO
!
!     masking points/elements not done
!
!     BOUNDARY TERMS (IF NEGATIVE: ENTERING FLUXES)
!
      DO IPOIN = 1,NPOIN3
!          ASSEMBLED
        IF(FLUEXTPAR(IPOIN).GT.0.D0) THEN
!                                       NOT ASSEMBLED
          DENOM%R(IPOIN)=DENOM%R(IPOIN)+FLUEXT(IPOIN)
        ENDIF
      ENDDO
!
!     SOURCES CHANGE THE MONOTONICITY CRITERION
!
      IF(NSCE.GT.0) THEN
        IF(OPTSOU.EQ.1) THEN
!         SOURCE NOT CONSIDERED AS A DIRAC
          DO IS=1,NSCE
            IIS=IS
!           HERE IN PARALLEL SOURCES WITHOUT PARCOM
!           ARE STORED AT ADRESSES IS+NSCE (SEE SOURCES_SINKS.F)
!           WITH PARCOM... AS MINFC ASSEMBLED BEFORE...
!           AND NECESSARY FOR MAX AND MIN
            IF(NCSIZE.GT.1) IIS=IIS+NSCE
            DO IPOIN=1,NPOIN3
!                            ASSEMBLED
              IF(SOURCES%ADR(IS)%P%R(IPOIN).LT.0.D0) THEN
                DENOM%R(IPOIN)=DENOM%R(IPOIN)
!                                          NOT ASSEMBLED
     &                        -SOURCES%ADR(IIS)%P%R(IPOIN)
              ENDIF
            ENDDO
          ENDDO
        ELSEIF(OPTSOU.EQ.2) THEN
!         SOURCE CONSIDERED AS A DIRAC
          DO IS=1,NSCE
            IIS=1
!           HERE IN PARALLEL SOURCES WITHOUT PARCOM
!           ARE STORED AT ADRESSES IS+NSCE (SEE SOURCES_SINKS.F)
!           WITH PARCOM... AS MINFC ASSEMBLED BEFORE...
!           AND NECESSARY FOR MAX AND MIN
            IF(NCSIZE.GT.1) IIS=2
            IF(ISCE(IS).GT.0) THEN
              IPOIN=(KSCE(IS)-1)*NPOIN2+ISCE(IS)
!                            ASSEMBLED
              IF(SOURCES%ADR(IS)%P%R(IPOIN).LT.0.D0) THEN
                DENOM%R(IPOIN)=DENOM%R(IPOIN)
!                                          NOT ASSEMBLED
     &                        -SOURCES%ADR(IIS)%P%R(IPOIN)
              ENDIF
            ENDIF
          ENDDO
        ENDIF
      ENDIF
!
!     EVAPORATION CHANGES THE MONOTONICITY CRITERION (NOT RAIN)
!
      IF(RAIN) THEN
        DO N=1,NPOIN2
          IPOIN=NPOIN3-NPOIN2+N
          DENOM%R(IPOIN)=DENOM%R(IPOIN)-MIN(PLUIE(N),0.D0)
        ENDDO
      ENDIF
!
!     BED FLUXES CHANGE THE MONOTONICITY CRITERION
!
!     IF(BEDBOU) THEN
!       STORE BEDFLU IN T2_01 AS IT NEEDS TO BE ASSEMBLED
!       CALL CPSTVC(BEDFLU,T2_01)
!       CALL OS('X=Y     ',X=T2_01,Y=BEDFLU)
!       IF(NCSIZE.GT.1) CALL PARCOM(T2_01,2,MESH2D)
!       DO IPOIN=1,NPOIN2
!         revoir la convention pour bedflu...
!         DENOM%R(IPOIN)=DENOM%R(IPOIN)+MAX(T2_01%R(IPOIN),0.D0)
!    &                                 -MIN(T2_01%R(IPOIN),0.D0)
!       ENDDO
!     ENDIF
!
!     HERE IS THE TIME STEP COMPUTATION,TRA01 IS VOLUN ASSEMBLED IN //
!
!     ASSEMBLING DENOM IN //. IT CAN BE KEPT FOR ALL STEPS SINCE IT
!     DOES NOT DEPEND ON VOLUMES, HENCE ON TIME WITHIN THE FULL TIME STEP
!
      IF(NCSIZE.GT.1) CALL PARCOM(DENOM,2,MESH3D)
!
!     SUB-ITERATIONS
!
      DO ITER=1,NSP_DIST
!
!       FNSUB IS THE STARTING VALUE OF F FOR THE SUB-ITERATION
!
        IF(ITER.EQ.1) THEN
          CALL OV('X=Y     ',FNSUB,FN,FN,C,NPOIN3)
          CALL OV('X=Y     ',FC   ,FN,FN,C,NPOIN3)
        ELSE
          CALL OV('X=Y     ',FNSUB,FC,FC,C,NPOIN3)
        ENDIF 
!
!       VOLUMES AT THE BEGINNING AND END OF THE SUB-ITERATION
!
        IF(ITER.EQ.NSP_DIST) THEN
          DO I=1,NPOIN3
            VOLU_SUB%R(I)=VOLU(I)
          ENDDO
        ELSE
          C=ITER*SURNSP
          DO I=1,NPOIN3
            VOLU_SUB%R(I)=VOLUN(I)+C*(VOLU(I)-VOLUN(I))
          ENDDO
        ENDIF
        IF(ITER.EQ.1) THEN
          DO I=1,NPOIN3
            VOLUN_SUB%R(I)=VOLUN(I)
          ENDDO
        ELSE
          DO I=1,NPOIN3
            VOLUN_SUB%R(I)=VOLU_SUB%R(I)
          ENDDO
        ENDIF    
!
!       TRA02 IS FIRST THE VOLUME (ASSEMBLED IN //) AT THE BEGINNING OF THE SUB-ITERATION
!
        CALL OV ('X=Y     ',TRA02, VOLUN_SUB%R,VOLUN_SUB%R,C,NPOIN3)
        IF(NCSIZE.GT.1) CALL PARCOM(STRA02,2,MESH3D)
!
!       NOW TRA02 IS THE ADMISSIBLE TIME STEP
!
        DO I=1,NPOIN3
          TRA02(I)=TRA02(I)/MAX(DENOM%R(I),1.D-20)
        ENDDO
!
!----------------------------------------------------------------------
!
!       COMPUTATION OF LOCAL IMPLICITATION COEFFICIENT
!
        SECU=0.9999999D0
        DO I=1,NPOIN3
          TETAF_VAR(I)=MAX(0.D0,1.D0-0.5D0*SECU*TRA02(I)/DDT)
        ENDDO
!
!----------------------------------------------------------------------
!       PREDICTOR STEP
!----------------------------------------------------------------------
!
!       BUILDING INTERMEDIATE VOLUMES VOLU(N+1-THETA) AND THEIR INVERSE
!
        DO I=1,NPOIN3
          VNP1MT%R(I)=      TETAF_VAR(I) *VOLUN_SUB%R(I)
     &               +(1.D0-TETAF_VAR(I))*VOLU_SUB%R(I)
        ENDDO
!
!     BUILDING Z AT BEGINNING AND END OF SUBSTEP
!     FOR COMPUTING THE COEFFICIENT SUR2VOL BELOW (SEE FLUX_IMP3D)
!
        DO I=1,NPOIN3
          ZSUBN(I)=ZN(I)+(ITER-1)*SURNSP*(MESH3D%Z%R(I)-ZN(I))
          ZSUBP(I)=ZN(I)+ ITER   *SURNSP*(MESH3D%Z%R(I)-ZN(I))
        ENDDO
!
!       BUILDING A COEFFICIENT TO SHARE ASSEMBLED FLUXES AMONG ELEMENTS
!
        DO ISEG=1,MESH3D%NSEG
          SUR2VOL(ISEG)=0.D0
        ENDDO
!
        DO IELEM=1,NELEM3
!
          I1 = IKLE3(IELEM,1)
          I2 = IKLE3(IELEM,2)
          I3 = IKLE3(IELEM,3)
          I4 = IKLE3(IELEM,4)
          I5 = IKLE3(IELEM,5)
          I6 = IKLE3(IELEM,6)
!
          H1 =      TETAF_VAR(I1) *(ZSUBN(I4)-ZSUBN(I1))
     &       +(1.D0-TETAF_VAR(I1))*(ZSUBP(I4)-ZSUBP(I1))
          H2 =      TETAF_VAR(I2) *(ZSUBN(I5)-ZSUBN(I2))
     &       +(1.D0-TETAF_VAR(I2))*(ZSUBP(I5)-ZSUBP(I2))
          H3 =      TETAF_VAR(I3) *(ZSUBN(I6)-ZSUBN(I3))
     &       +(1.D0-TETAF_VAR(I3))*(ZSUBP(I6)-ZSUBP(I3))
          H4 =      TETAF_VAR(I4) *(ZSUBN(I4)-ZSUBN(I1))
     &       +(1.D0-TETAF_VAR(I4))*(ZSUBP(I4)-ZSUBP(I1))
          H5 =      TETAF_VAR(I5) *(ZSUBN(I5)-ZSUBN(I2))
     &       +(1.D0-TETAF_VAR(I5))*(ZSUBP(I5)-ZSUBP(I2))
          H6 =      TETAF_VAR(I6) *(ZSUBN(I6)-ZSUBN(I3))
     &       +(1.D0-TETAF_VAR(I6))*(ZSUBP(I6)-ZSUBP(I3))
!
          COEF = MESH3D%SURFAC%R(IELEM)/6.D0
!
!         SEGMENT 01
          ISEG = ELTSEG(IELEM,1)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H1+H2)*COEF
!         SEGMENT 02
          ISEG = ELTSEG(IELEM,2)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H2+H3)*COEF
!         SEGMENT 03
          ISEG = ELTSEG(IELEM,3)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H3+H1)*COEF  
!         SEGMENT 04      
          ISEG = ELTSEG(IELEM,4)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H4+H5)*COEF
!         SEGMENT 05
          ISEG = ELTSEG(IELEM,5)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H5+H6)*COEF
!         SEGMENT 06
          ISEG = ELTSEG(IELEM,6)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H6+H4)*COEF
!         SEGMENT 07
          ISEG = ELTSEG(IELEM,7)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H1+H4)*COEF
!         SEGMENT 08
          ISEG = ELTSEG(IELEM,8)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H2+H5)*COEF
!         SEGMENT 09
          ISEG = ELTSEG(IELEM,9)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H3+H6)*COEF
!         SEGMENT 10
          ISEG = ELTSEG(IELEM,10)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H1+H5)*COEF
!         SEGMENT 11
          ISEG = ELTSEG(IELEM,11)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H2+H4)*COEF
!         SEGMENT 12
          ISEG = ELTSEG(IELEM,12)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H2+H6)*COEF
!         SEGMENT 13
          ISEG = ELTSEG(IELEM,13)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H3+H5)*COEF
!         SEGMENT 14
          ISEG = ELTSEG(IELEM,14)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H3+H4)*COEF
!         SEGMENT 15
          ISEG = ELTSEG(IELEM,15)
          SUR2VOL(ISEG)=SUR2VOL(ISEG)+(H1+H6)*COEF
!
        ENDDO
!
        IF(NCSIZE.GT.1) THEN
          CALL PARCOM2_SEG(SUR2VOL,SUR2VOL,SUR2VOL,
!                          NSEG2D !       MESH2D !
     &                     NSEG,NPLAN,2,1,MESH2D,1,41)
        ENDIF
        DO ISEG=1,MESH3D%NSEG
!                             1.D-6 GIVES ERRORS
          IF(SUR2VOL(ISEG).GT.1.D-30) THEN
            SUR2VOL(ISEG)=1.D0/SUR2VOL(ISEG)
          ELSE
            SUR2VOL(ISEG)=0.D0
          ENDIF
        ENDDO
!
!       PREDICTOR (ICO=0) AND CORRECTOR (ICO=1 TO NCO_DIST)
!
        DO ICOR=0,NCO_DIST
!
!         THE PREDICTOR AND FIRST CORRECTOR ARE GUARANTEED 
!         WITHOUT STABILITY PROBLEM
          IF(ICOR.GT.1) THEN
!           LIMITING THE PREDICTOR
            DO I=1,NPOIN3
              MINFC%R(I)=FNSUB(I)
              MAXFC%R(I)=FNSUB(I)
            ENDDO
            DO I=1,NPTFR3
              N=NBOR3(I)
!             IF(LIMTRA(I).EQ.KDIR) THEN
              IF(FLUEXTPAR(N).LT.0.D0)THEN
                MINFC%R(N)=MIN(MINFC%R(N),FBORL(I))
                MAXFC%R(N)=MAX(MAXFC%R(N),FBORL(I))
              ENDIF
            ENDDO
            DO IELEM=1,NELEM3
              I1=IKLE3(IELEM,1)
              I2=IKLE3(IELEM,2)
              I3=IKLE3(IELEM,3)
              I4=IKLE3(IELEM,4)
              I5=IKLE3(IELEM,5)
              I6=IKLE3(IELEM,6)
              LOCALMIN=MIN(FC(I1),FC(I2),FC(I3),FC(I4),FC(I5),FC(I6),
     &                     FNSUB(I1),FNSUB(I2),FNSUB(I3),
     &                     FNSUB(I4),FNSUB(I5),FNSUB(I6))
              LOCALMAX=MAX(FC(I1),FC(I2),FC(I3),FC(I4),FC(I5),FC(I6),
     &                     FNSUB(I1),FNSUB(I2),FNSUB(I3),
     &                     FNSUB(I4),FNSUB(I5),FNSUB(I6))
              MINFC%R(I1)=MIN(MINFC%R(I1),LOCALMIN)
              MAXFC%R(I1)=MAX(MAXFC%R(I1),LOCALMAX)
              MINFC%R(I2)=MIN(MINFC%R(I2),LOCALMIN)
              MAXFC%R(I2)=MAX(MAXFC%R(I2),LOCALMAX)
              MINFC%R(I3)=MIN(MINFC%R(I3),LOCALMIN)
              MAXFC%R(I3)=MAX(MAXFC%R(I3),LOCALMAX)
              MINFC%R(I4)=MIN(MINFC%R(I4),LOCALMIN)
              MAXFC%R(I4)=MAX(MAXFC%R(I4),LOCALMAX)
              MINFC%R(I5)=MIN(MINFC%R(I5),LOCALMIN)
              MAXFC%R(I5)=MAX(MAXFC%R(I5),LOCALMAX)
              MINFC%R(I6)=MIN(MINFC%R(I6),LOCALMIN)
              MAXFC%R(I6)=MAX(MAXFC%R(I6),LOCALMAX)
            ENDDO
            IF(NCSIZE.GT.1) THEN
              CALL PARCOM(MINFC,4,MESH3D)
              CALL PARCOM(MAXFC,3,MESH3D)
            ENDIF
            DO I=1,NPOIN3
              FC(I)=MIN(FC(I),FNSUB(I)+0.5D0*(MAXFC%R(I)-FNSUB(I)))
              FC(I)=MAX(FC(I),FNSUB(I)+0.5D0*(MINFC%R(I)-FNSUB(I)))
            ENDDO
          ENDIF
!
!         DERIVATIVE IN TIME
!
          IF(ICOR.EQ.0) THEN
            DO I=1,NPOIN3
!             DFDT(I)=0.D0
              TRA02(I)=0.D0
            ENDDO
          ELSE
            DO I=1,NPOIN3
!             HERE DFDT=H*DFDT WITH SEMI IMPLICIT H
              TRA02(I)=(FC(I)-FNSUB(I))/DDT
            ENDDO
          ENDIF
!
          CALL FLUX_IMP3D(DIM1XB,XB,NELEM3,ELTSEG,ORISEG,FXMATPAR,
     &                    MESH3D%NSEG,IKLE3,NPOIN3,FNSUB,FI_I%R,
!                                         DFDT
     &                    MESH3D%SURFAC%R,TRA02,TETAF_VAR,
     &                    ZSUBN,ZSUBP,SUR2VOL)
!
          CALL TVF_IMP_3D(FC,FNSUB,FXMAT,FXMATPAR,DDT,VNP1MT%R,
     &                    MESH3D%NSEG,NPOIN3,FLUEXT,FLUEXTPAR,NPTFR3,
     &                    NBOR3,DIMGLO,GLOSEG,TETAF_VAR,FI_I%R,FBORL,
     &                    MESH3D,ICOR,NCO_DIST,ICOR.EQ.0,ICOR.NE.0,
     &                    INFOR,SFC,TRAV10,MTRA1,SLVPSI,IELM3,TB2,
     &                    RAIN,TRAIN,PLUIE,VOLU2D,NPOIN2,OPTSOU,NSCE,
     &                    ISCE,KSCE,FSCE,SOURCES,BEDBOU,BEDFLU)
!
          IF(CALFLU.AND.ICOR.EQ.NCO_DIST) THEN
            DO IPTFR3=1,NPTFR3
              IPOIN=NBOR3(IPTFR3)
              IF(FLUEXTPAR(IPOIN).LT.0.D0) THEN
                FLUX=FLUX+DDT*FLUEXT(IPOIN)*FBORL(IPTFR3)
              ELSE
                FLUX=FLUX+FLUEXT(IPOIN)*DDT*
     &          ((1.D0-TETAF_VAR(IPOIN))*FNSUB(IPOIN)+
     &           TETAF_VAR(IPOIN)*FC(IPOIN))
              ENDIF
            ENDDO
            IF(NSCE.GT.0) THEN
              IF(OPTSOU.EQ.1) THEN
!               SOURCE NOT CONSIDERED AS A DIRAC
                DO IS=1,NSCE
                  IIS=IS
!                 HERE IN PARALLEL SOURCES WITHOUT PARCOM
!                 ARE STORED AT ADRESSES IS+NSCE (SEE SOURCES_SINKS.F)
                  IF(NCSIZE.GT.1) IIS=IIS+NSCE
                  DO IP=1,NPOIN3
                    IF(SOURCES%ADR(IS)%P%R(IP).GT.0.D0) THEN
                      FLUX=FLUX-DDT*FSCE(IS)*SOURCES%ADR(IIS)%P%R(IP)
                    ELSE
                      FLUX=FLUX-DDT*SOURCES%ADR(IIS)%P%R(IP)*
     &               ((1.D0-TETAF_VAR(IP)*FNSUB(IP)
     &                     +TETAF_VAR(IP)*FC(IP)))                       
                    ENDIF
                  ENDDO
                ENDDO
              ELSEIF(OPTSOU.EQ.2) THEN
!               SOURCE CONSIDERED AS A DIRAC
                IIS = 1
!               HERE IN PARALLEL SOURCES WITHOUT PARCOM
!               ARE STORED AT ADRESSES 2 (SEE SOURCES_SINKS.F)
                IF(NCSIZE.GT.1) IIS=2
                DO IS=1,NSCE
                  IF(ISCE(IS).GT.0) THEN
                    IP=(KSCE(IS)-1)*NPOIN2+ISCE(IS)
                    IF(SOURCES%ADR(1)%P%R(IP).GT.0.D0) THEN
                      FLUX=FLUX-DDT*FSCE(IS)*SOURCES%ADR(IIS)%P%R(IP)
                    ELSE
                      FLUX=FLUX-DDT*SOURCES%ADR(IIS)%P%R(IP)*
     &               ((1.D0-TETAF_VAR(IP)*FNSUB(IP)
     &                     +TETAF_VAR(IP)*FC(IP)))
                    ENDIF
                  ENDIF
                ENDDO
              ENDIF
            ENDIF
!           DONE IN BIL3D.F
!           IF(RAIN) THEN
!             DO N=1,NPOIN2
!               IF(PLUIE(N).GT.0.D0) THEN
!                 REAL RAIN, VALUE IN RAIN CONSIDERED...
!                 FLUX=FLUX-DDT*PLUIE(N)*TRAIN
!               ELSE
!                 EVAPORATION, NO FLUX LEAVING...
!               ENDIF
!             ENDDO
!           ENDIF
!
!           BED FLUXES
            IF(BEDBOU) THEN
              DO IP=1,NPOIN2
                IF(BEDFLU%R(IP).LE.0.D0) THEN
!                 FLUX EXITING THE DOMAIN
                  FLUX=FLUX-DDT*BEDFLU%R(IP)*
     &            ((1.D0-TETAF_VAR(IP)*FNSUB(IP)+TETAF_VAR(IP)*FC(IP)))
                ENDIF
              ENDDO
            ENDIF
!
          ENDIF ! CALFLU.AND.NCO_DIST.EQ.0
!
!----------------------------------------------------------------------
! END OF PREDICTOR-CORRECTOR LOOP
!----------------------------------------------------------------------
!
        ENDDO
!
!----------------------------------------------------------------------
! END OF SUB-ITERATIONS LOOP
!----------------------------------------------------------------------
!
      ENDDO
!
      IF(INFOR) THEN
        IF(LNG.EQ.1) WRITE(LU,902) NSP_DIST
        IF(LNG.EQ.2) WRITE(LU,903) NSP_DIST
902     FORMAT(1X,'MURD3D_LIPS : ',1I4,' ITERATIONS')
903     FORMAT(1X,'MURD3D_LIPS: ',1I4,' ITERATIONS')
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
