!                       *****************
                        SUBROUTINE VOLFIN
!                       *****************
!
     & (W1,AT,DT,LT,NELEM,NPTFR,NSEG,
     &  TB,ZF,CF,NPOIN,HN,H,U,V,QU,QV,G,LISTIN,
     &  MESH,LIMPRO,NBOR,KDIR,KNEU,KDDL,
     &  HBOR,UBOR,VBOR,MASSES,FLUENT,FLUSOR,CFLWTD,DTVARI,KFROT,
     &  NREJET,ISCE,TSCE2,MAXSCE,MAXTRA,YASMH,SMH,
     &  NTRAC,DIMT,T,HT,TN,
     &  TBOR,MASSOU,FLUTENT,FLUTSOR,DTHAUT,DPX,DPY,DJX,DJY,CMI,JMI,
     &  DJXT,DJYT,DIFVIT,ITURB,PROPNU,DIFT,DIFNU,
     &  DX,DY,OPTVF,
     &  HSTOK,HCSTOK,LOGFR,DSZ,FLUXT,FLUHBOR,FLBOR,DTN,FLUSORTN,
     &  FLUENTN,LTT,
     &  FLUXTEMP,FLUHBTEMP,HC,SMTR,AIRST,TMAX,DTT,GAMMA,FLUX_OLD,
     &  MXPTVS,NEISEG,V2DPAR,UDEL,VDEL,HROPT)
!
!***********************************************************************
! TELEMAC2D   V6P3                                   15/06/2013
!***********************************************************************
!
!brief    1. SOLVES THE PROBLEM BY A METHOD OF TYPE ROE OR BY A KINETIC
!            SCHEME (ORDER 1 OR 2) OR TCHAMEN/ZOKAGOA SCHEME
!            FOR INTERIOR FLUXES
!            AND OF TYPE STEGER AND WARMING FOR I/O;
!+
!+
!+            2. SOLVES IN TIME USING A NEWMARK TYPE SCHEME OF SECOND ORDER.
!
!history  N.GOUTAL; INRIA
!+        22/03/1998
!+
!+   ROE SCHEME (NG); KINETIC SCHEMES (INRIA)
!
!history  J-M HERVOUET (LNHE)
!+        05/09/2007
!+
!+   MULTIPLE TRACERS
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
!history  R. ATA (EDF-LNHE)
!+        03/15/2011
!+        V6P1
!+    CHANGE EXPLICIT EULER BY NEWMARK SCHEME
!+    ADD TCHAMEN AND ZOKAGA FLUXES
!
!history  R. ATA (EDF-LNHE)
!+        07/15/2012
!+        V6P2
!+   ADD NEW ARGUEMENTS (MXPTVS,NEISEG)
!+   FOR WAF SCHEME
!
!history  R. ATA (EDF-LNHE)
!+        06/15/2013
!+        V6P3
!+   NO MORE CALL FOR VECTOR TO BUILD TB
!+   INSTEAD USE V2DPAR
!+   CLEAN UNUSED VARIABLES
!
!history  R. ATA
!+        28/01/2014
!+        V7P0
!+    change diemensions of CMI
!+    from (2,nseg) to (nseg,2)
!
!history  R. ATA
!+        25/05/2015
!+        V7P1
!+    include udel and vdel for the coupling
!+    with DELWAQ and Sisyphe
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AIRE           |-->| ELEMENT AREA
!| AIRS           |-->| CELL AREA
!| AIRST          |-->| AREA OF SUB-TRIANGLES (SECOND ORDER)
!| AT,DT,LT       |-->| TIME, TIME STEP AND NUMBER OF THE STEP
!| CF             |-->| FRICTION COEFFICIENT
!| CFLWTD         |-->| WANTED CFL NUMBER
!| CMI            |-->| COORDINATES OF MIDDLE PONTS OF EDGES
!| COUPLING       |-->| STRING WITH THE LIST OF COUPLED PROGRAMMES
!| DIFNU          |-->| COEFFICIENT OF DIFFUSION FOR TRACER
!| DIFT           |-->| LOGICAL: DIFFUSION FOR TRACER OR NOT
!| DIFVIT         |-->|  LOGICAL: DIFFUSION FOR VELOCITY OR NOT
!| DIMT           |-->| DIMENSION OF TRACER
!| DJXT,DJYT      |<->| WORKING TABLES FOR TRACER
!| DSZ            |<->| VARIATION OF Z FOR ORDER 2
!| DTHAUT         |-->| CHARACTERISTIC LENGTH (DX) USED FOR CFL
!| DTN            |<->| TIME STEP   FROM TN+1 TO TN+2
!| DTT            |<->| TIME STEP FOR TRACER
!| DTVARI         |-->| DT VARIALE OR NOT
!| DX,DY          |<->| WORKING TABLES
!| DXT,DYT        |<->| WORKING TABLES FOR TRACER
!| FLUENT,FLUSORT |<--| MASS FLUX MASSE INLET AND OUTLET FROM TN TO TN+1
!| FLUHBTEMP      |<->| BORD FLUX FOR TRACER
!| FLUSCE         |-->| SOURCE FLUXES
!| FLUSORTN,FLUENT|<->| MASS FLUX MASSE INLET AND OUTLET FROM TN+1 TO TN+2
!| FLUTENT,FLUTSOR|<--| FLUX TRACER INLET AND OUTLET
!| FLUX           |<--| FLUX
!| FLUXT,FLUHBOR  |<->| FLUX, FLUX BORD FOR TRACER
!| FLUXTEMP       |<->| FLUX POUR TRACER
!| FLUX_OLD       |<->| FLUX OF OLD TIME STEP
!| GAMMA          |-->| NEWMARK COEFFICIENT FOR TIME INTEGRATION
!| G              |-->| GRAVITY
!| H              |<--| WATER DEPTH AT TIME N+1
!| HBOR           |-->| IMPOSED VALUE FOR H
!| HC             |<->| H RECONSTRUCTED (ORDER 2) CORRECTED
!| HN             |-->| WATER DEPTH AT TIME N
!| HSTOK,HCSTOK   |<->| H, H CORRECTED TO STOCK FOR TRACER
!| HTN,TN         |-->| HT, T  AT TIME N
!| HROPT          |-->| OPTION FOR HYDROSTATIC RECONSTRUCTION:
!|                |   | 1:AUDUSSE, 2: NOELLE
!| IKLE           |-->| INDICES OF NODES FOR TRIANGLE
!| ISCE           |-->| SOURCE POINTS
!| ITURB          |-->| MODEL OF TURBULENCE  1 : LAMINAIRE
!| JMI            |-->| NUMBER OF THE TRIANGLE IN WHICH IS LOCATED
!|                |   | THE MIDPOINT OF THE INTERFACE
!| KDDL           |-->| CONVENTION FOR FREE POINTS (BC)
!| KDIR           |-->| CONVENTION FOR DIRICHLET POINTS
!| KFROT          |-->| BED FRICTION LAW
!| KNEU           |-->| CONVENTION NEUMANN POINTS
!| LIMPRO         |-->| TYPES OF BOUNDARY CONDITION
!| LIMTRA         |-->| TYPES OF BOUNDARY CONDITION FOR TRACER
!| LISTIN         |-->| IF YES, PRINT MESSAGES AT LISTING.
!| LOGFR          |<->| REFERENCE OF BOUNDARY NODES
!| LTT            |<->| NUMBER OF TIME STEP FOR TRACER
!| MASSES         |<--| ADDED MASS BY SOURCE TERMS
!| MASSOU         |<--| ADDED TRACER MASS BY SOURCE TERM
!| MAXSCE         |-->| MAXIMUM NUMBER OF SOURCES
!| MAXTRA         |-->| MAXIMUM NUMBER OF TRACERS
!| MXPTVS         |-->| MAX NUMBER OF NEIGHBOR FOR A NODE
!| NBOR           |-->| GLOBAL INDICES FOR BORD NODES
!| NEISEG         |-->| NEIGHBOR OF THE SEGMENT
!| NELEM          |-->| NUMBER OF ELEMENTS
!| NELMAX         |-->| MAXIMUM NUMBER OF ELEMENTS
!| NIT            |-->| TOTAL NUMBER OF TIME STEPS
!| NPOIN          |-->| TOTAL NUMBER OF NODES
!| NPTFR          |-->| TOTAL NUMBER OF BOUNDARY NODES
!| NREJET         |-->| NUMBER OF SOURCE/SINK
!| NSEG           |-->| NUMBER OF EDGES
!| NTRAC          |-->| NUMBER OF TRACERS
!| NUBO           |-->| GLOBAL INDICES OF EDGE EXTREMITIES
!| OPTVF          |-->| OPTION OF THE SCHEME
!|                |   | 0:ROE, 1:KINETIC ORDRE 1,2:KINETIC ORDRE 2
!|                |   | 3:ZOKAGOA, 4:TCHAMEN,5:HLLC,6:WAF
!| PROPNU         |-->| COEFFICIENT OF MOLECULAR DIFFUSION
!| QU,QV          |<->| FLOW COMPOENENTS AT TIME N THEN AT TIME  N+1
!| SMH            |-->| SOURCE TERMS FOR CONTINUITY EQUATION
!| SMTR           |<--| SOURCE TERMS FOR TRACERS
!| T              |<--| TRACER UPDATED
!| TBOR           |-->| PRESCRIBED BOUNDARY CONDITIONS FOR T
!| TMAX           |-->| FINAL TIME
!| TSCE2          |-->| VALUES OF TRACERS AT SOURCES
!| U,V            |<--| VELOCITY COMPONENTS AT TIME N+1
!| UDEL,VDEL      |<--| COMPATIBLE COMPONENTS (OF DELWAQ) VELOCITY FIELD
!| UBOR           |-->| IMPOSED VALUES FOR U
!| VBOR           |-->| IMPOSED VALUES FOR V
!| VNOIN          |-->| NORMAL TO THE INTERFACE
!|                |   | (2 FIRST COMPONENTS) AND
!|                |   | SEGMENT LENGTH (3RD COMPONENT)
!| W              |<->| WORKING TABLE
!| WINF           |-->| BOUNDARY CONDITIONS GIVEN BY BORD
!| X,Y            |-->| COORDINATES FOR MESH NODES
!| XNEBOR,YNEBOR  |-->| NORMAL TO BOUNDARY POINTS
!| YASMH          |-->| LOGICAL: TO TAKE INTO ACCOUNT SMH
!| ZF             |-->| BED TOPOGRAPHY (BATHYMETRY)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE INTERFACE_TELEMAC2D, EX_VOLFIN => VOLFIN
!
      USE DECLARATIONS_SPECIAL
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: NPTFR,KDIR,KNEU,KDDL,DIMT,KFROT,OPTVF
      INTEGER, INTENT(IN)    :: NELEM,NPOIN,LT,NREJET,ITURB
      INTEGER, INTENT(IN)    :: NTRAC,MAXSCE,MAXTRA,MXPTVS,HROPT
      INTEGER, INTENT(INOUT) :: LTT
      INTEGER, INTENT(IN)    :: LIMPRO(NPTFR,6),NBOR(NPTFR)
      INTEGER, INTENT(IN)    :: ISCE(NREJET),NSEG
      INTEGER, INTENT(INOUT) :: JMI(*),LOGFR(NPOIN),NEISEG(2,*)
      LOGICAL, INTENT(IN)    :: DIFVIT,DIFT,LISTIN,DTVARI,YASMH

      DOUBLE PRECISION, INTENT(IN) :: PROPNU,DIFNU,GAMMA
      DOUBLE PRECISION, INTENT(INOUT) :: AT,DT,MASSES,DTT
      DOUBLE PRECISION, INTENT(INOUT) :: H(NPOIN),QU(NPOIN),QV(NPOIN)
      DOUBLE PRECISION, INTENT(INOUT) :: W1(*)

      DOUBLE PRECISION, INTENT(INOUT) :: DSZ(2,*),HC(2,*)
      DOUBLE PRECISION, INTENT(INOUT) :: U(NPOIN),V(NPOIN),HN(NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: SMH(NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: CF(NPOIN),ZF(NPOIN),G
      DOUBLE PRECISION, INTENT(INOUT) :: HSTOK(DIMT),HCSTOK(2,*)
      DOUBLE PRECISION, INTENT(IN)    :: HBOR(NPTFR),UBOR(NPTFR)
      DOUBLE PRECISION, INTENT(IN)    :: VBOR(NPTFR)
      DOUBLE PRECISION, INTENT(IN)    :: TSCE2(MAXSCE,MAXTRA)
      DOUBLE PRECISION, INTENT(INOUT) :: DX(3,*),DY(3,*)
      DOUBLE PRECISION, INTENT(IN)    :: AIRST(2,*)
      DOUBLE PRECISION, INTENT(INOUT) :: DPX(3,*),DPY(3,*)
      DOUBLE PRECISION, INTENT(INOUT) :: CMI(NSEG,2),DJX(3,*),DJY(3,*)
      DOUBLE PRECISION, INTENT(IN)    :: CFLWTD,DTHAUT(NPOIN),TMAX
      DOUBLE PRECISION, INTENT(INOUT) :: FLUSOR,FLUENT,DTN,MASSOU(*)
      DOUBLE PRECISION, INTENT(INOUT) :: FLUSORTN,FLUENTN
      DOUBLE PRECISION, INTENT(INOUT) :: DJXT(*),DJYT(*)
      DOUBLE PRECISION, INTENT(INOUT) :: FLUTENT(*),FLUTSOR(*)
      TYPE(BIEF_OBJ), INTENT(INOUT)   :: TB,UDEL,VDEL
      TYPE(BIEF_MESH), INTENT(INOUT)  :: MESH
      TYPE(BIEF_OBJ) , INTENT(IN)     :: TBOR,TN,V2DPAR
      TYPE(BIEF_OBJ) , INTENT(INOUT)  :: T,HT,SMTR,FLUHBOR,FLUHBTEMP
      TYPE(BIEF_OBJ) , INTENT(INOUT)  :: FLUXTEMP,FLUXT,FLBOR,FLUX_OLD
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
!
!
      MASSES = 0.D0
!
      CALL RESOLU(W1,W1(1+3*NPOIN),MESH%NUBO%I,
     &            MESH%VNOIN%R,W1(1+9*NPOIN),AT,DT,LT,
     &            NELEM,MESH%NSEG,NPTFR,W1(1+6*NPOIN),
!RA  &            TB%ADR(1)%P%R,MESH%SURFAC%R,
     &            V2DPAR%R,MESH%SURFAC%R,
     &            MESH%X%R,MESH%Y%R,MESH%IKLE%I,
     &            ZF,CF,NPOIN,HN,H,U,V,QU,QV,G,LISTIN,
     &            MESH%XNEBOR%R,MESH%YNEBOR%R,
     &            LIMPRO,NBOR,KDIR,KNEU,KDDL,HBOR,UBOR,VBOR,
     &            FLUSOR,FLUENT,CFLWTD,DTVARI,MESH%NELMAX,KFROT,
     &            NREJET,ISCE,TSCE2,MAXSCE,MAXTRA,YASMH,SMH,MASSES,
     &            NTRAC,DIMT,T,HT,TN,DIMT,
     &            TBOR,MASSOU,FLUTENT,FLUTSOR,DTHAUT,DPX,DPY,DJX,DJY,
     &            CMI,JMI,SMTR,TB%ADR(3)%P%R,TB%ADR(4)%P%R,
     &            DJXT,DJYT,DIFVIT,ITURB,PROPNU,DIFT,DIFNU,DX,DY,OPTVF,
     &            FLUSORTN,FLUENTN,DSZ,AIRST,HSTOK,HCSTOK,FLUXT,FLUHBOR,
     &            FLBOR,LOGFR,LTT,DTN,FLUXTEMP,FLUHBTEMP,HC,TMAX,DTT,
     &            TB%ADR(6)%P%R,TB%ADR(7)%P%R,TB%ADR(8)%P%R,
     &            TB%ADR(9)%P%R,TB%ADR(10)%P%R,
     &            GAMMA,FLUX_OLD%R,MXPTVS,NEISEG,
     &            MESH%ELTSEG%I,MESH%IFABOR%I,HROPT,MESH)
!
!-----------------------------------------------------------------------
!
!
!  COMPATIBLE VELOCITY FIELD IN CONTINUITY EQUATION
!  USED BY SISYPHE AND DELWAQ
      CALL OV ('X=Y     ',UDEL%R,U,U,1.D0,NPOIN)
      CALL OV ('X=Y     ',VDEL%R,V,V,1.D0,NPOIN)
!-----------------------------------------------------------------------
      RETURN
      END
