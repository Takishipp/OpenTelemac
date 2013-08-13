!                    *****************
                     SUBROUTINE ALMESH
!                    *****************
!
     &(MESH,NOM,IELM,SPHERI,CFG,NFIC,EQUA,NPLAN,NPMAX,NPTFRX,NELMAX,
     & I3,I4,FILE_FORMAT,PROJECTION,LATI0,LONGI0)
!
!***********************************************************************
! BIEF   V6P3                                   21/08/2010
!***********************************************************************
!
!brief    ALLOCATES A BIEF_MESH MESH STRUCTURE.
!
!history  J-M HERVOUET (LNHE)
!+        05/02/2010
!+        V6P0
!+   EDGE-BASED STUCTURES ALWAYS ALLOCATED
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
!history  J-M HERVOUET (LNHE)
!+        28/11/2011
!+        V6P2
!+   Calls to eleb3d and eleb3dt changed. Calls of READGEO3 and CPIKLE2
!+   and CPIKLE3 swapped (now KNOLG used in CPIKLE3).
!
!history  J-M HERVOUET (LNHE)
!+        20/07/2012
!+        V6P2
!+   Finding the original number of nodes in parallel, and completing
!+   KNOLG for upper planes in 3D.
!
!history  J-M HERVOUET (LNHE)
!+        07/02/2013
!+        V6P3
!+   Argument NELMAX removed in call to SEGBOR.
!
!history  J-M HERVOUET (EDF R&D, LNHE)
!+        11/03/2013
!+        V6P3
!+   Dimension of LIMVOI now set to (11,2).
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| EQUA           |-->| NAME IN 20 CHARACTERS TO ENABLE DIFFERENT
!|                |   | OPTIONS. OPTIONS ARE:
!|                |   | "SAINT-VENANT EF"
!|                |   | "SAINT-VENANT VF"
!|                |   | "BOUSSINESQ"
!| I3             |-->| ABSCISSA IN METERS OF ORIGIN POINT (OPTIONAL)
!| I4             |-->| ORDINATE IN METERS OF ORIGIN POINT (OPTIONAL)
!| IELM           |-->| ELEMENT TYPE WITH THE LARGET NUMBER OF DEGREES
!|                |   | OF FREEDOM THAT WILL BE USED
!| LATI0          |-->| LATITUDE OF ORIGIN POINT
!| LONGI0         |-->| LONGITUDE OF ORIGIN POINT
!| MESH           |-->| MESH STRUCTURE TO BE ALLOCATED
!| NELMAX         |-->| MAXIMUM NUMBER OF ELEMENTS IN THE MESH
!| NFIC           |-->| LOGICAL UNIT WHERE TO READ THE MESH
!| NOM            |-->| NAME OF THE MESH
!| NPLAN          |-->| NUMBER OF PLANES (OPTIONAL,3D MESHES OF PRISMS)
!| NPMAX          |-->| MAXIMUM NUMBER OF POINTS IN THE MESH
!| NPTFRX         |-->| MAXIMUM NUMBER OF BOUNDARY NODES
!| PROJECTION     |<->| SPATIAL PROJECTION TYPE
!| SPHERI         |-->| LOGICAL, IF YES : SPHERICAL COORDINATES
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_ALMESH => ALMESH
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      TYPE(BIEF_MESH)  , INTENT(INOUT)           :: MESH
      INTEGER          , INTENT(IN)              :: IELM
      INTEGER          , INTENT(IN)              :: NFIC
      LOGICAL          , INTENT(IN)              :: SPHERI
      CHARACTER(LEN=6) , INTENT(IN)              :: NOM
      CHARACTER(LEN=20), INTENT(IN)              :: EQUA
      INTEGER          , INTENT(INOUT)           :: CFG(2)
      INTEGER          , INTENT(IN),    OPTIONAL :: NPLAN
      INTEGER          , INTENT(IN),    OPTIONAL :: NPMAX
      INTEGER          , INTENT(IN),    OPTIONAL :: NPTFRX
      INTEGER          , INTENT(IN),    OPTIONAL :: NELMAX
      INTEGER          , INTENT(INOUT), OPTIONAL :: I3,I4,PROJECTION
      CHARACTER(LEN=8) , INTENT(IN),    OPTIONAL :: FILE_FORMAT
      DOUBLE PRECISION , INTENT(IN),    OPTIONAL :: LATI0,LONGI0
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER D,IELM0,IELM1,STOCFG,IELB0,IELB1,NSEG,NNPMAX
      INTEGER NNPTFRX,NNELEB,ERR,NNELMAX,NNPLAN,NPOIN,NPTFR,NELEM
      INTEGER MXPTVS,MXELVS,NDP,IB(10),IELEM,NSEGBOR,IPLAN,NPOIN_GLOB
!
!     TEMPORARY CONNECTIVITY TABLE
!
      INTEGER, ALLOCATABLE :: IKLES(:)
!
!     TEMPORARY TABLE TO NUMBER THE BOUNDARY NODES
!
      INTEGER, ALLOCATABLE :: IPOBO(:)
!
      INTEGER IELB0V,IELB1V,I
      INTEGER, EXTERNAL :: P_IMAX
!
      CHARACTER(LEN=8) FFORMAT
!
      INTEGER PROJEC
      DOUBLE PRECISION LATI,LONGI
!
!-----------------------------------------------------------------------
!
      IF(PRESENT(FILE_FORMAT)) THEN
        FFORMAT=FILE_FORMAT
      ELSE
        FFORMAT='SERAFIN '
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(PRESENT(PROJECTION)) THEN
        PROJEC=PROJECTION
      ELSE
        PROJEC=1
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(PRESENT(LATI0)) THEN
        LATI=LATI0
      ELSE
        LATI=0.D0
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(PRESENT(LONGI0)) THEN
        LONGI=LONGI0
      ELSE
        LONGI=0.D0
      ENDIF
!
!-----------------------------------------------------------------------
!
!     FIRST READS THE GEOMETRY FILE TO GET NPOIN,.. IB
!
      MESH%NAME = NOM
!
!CCCCCCCCCCCCCCCCCCCC
! 3D : ALSO GETS NNELEB
!CCCCCCCCCCCCCCCCCCCC
!
!     IN PARALLEL MODE, THIS IS WHERE NPTIR IS READ
!
      CALL READGEO1(NPOIN,NELEM,NPTFR,NDP,IB,NFIC,NNELEB)
!
      IF(PRESENT(I3)) I3=IB(3)
      IF(PRESENT(I4)) I4=IB(4)
!
! ALLOCATES THE TEMPORARY CONNECTIVITY TABLE
!
      ALLOCATE(IKLES(NELEM*NDP),STAT=ERR)
!
      IF(ERR.NE.0) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'ALMESH : ALLOCATION DE IKLES DEFECTUEUSE'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'ALMESH : WRONG ALLOCATION OF IKLES'
        ENDIF
        STOP
      ENDIF
!
! ALLOCATES THE TEMPORARY TABLE FOR THE BOUNDARY NODES
!
      ALLOCATE(IPOBO(NPOIN),STAT=ERR)
!
      IF(ERR.NE.0) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'ALMESH : ALLOCATION DE IPOBO DEFECTUEUSE'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'ALMESH : WRONG ALLOCATION OF IPOBO'
        ENDIF
        STOP
      ENDIF
!
!CCCCCCCCCCCCCCCCCCCCCC
! READGEO2 WILL ALSO TAKE IPOBO (ARRAY READ IN THIS SUBROUTINE) IN
! ARGUMENT. IT IS CURRENTLY ONLY USED INSIDE THIS SUBROUTINE, EXCEPT
! IN THIS CASE, WHERE IT WILL BE REQUIRED LATER.
! SINCE IT IS IN THE GEO FILE, WHY NOT USE IT?
! ARGUMENTS MXPTVS AND MXELVS WILL BE DELETED AND TRANSFERED IN UPCOMING
! CALL TO MXPTEL. THESE NUMBERS ARE NOT RELATED TO THE READING OF THE
! GEO FILE.
!CCCCCCCCCCCCCCCCCCCCCC
!
! READS IPOBO
!
      CALL READGEO2(NPOIN,NELEM,NPTFR,NDP,IKLES,IPOBO,IB,NFIC)
!
!CCCCCCCCCCCCCCCCCCCCCC
! THIS IS WHERE CALL TO MXPTEL WILL NOW BE (INSTEAD OF WITHIN READGEO2)
! MXPTVS AND MXELVS WILL BE COMPUTED DEPENDING ON THE TYPE OF ELEMENT
!CCCCCCCCCCCCCCCCCCCCCC
!
! CALCULATES THE MAXIMUM NUMBER OF ELEMENTS AROUND A NODE MXELVS
! AND THE MAXIMUM NUMBER OF SURROUNDING NODES, MXPTVS
!
      CALL MXPTEL(MXPTVS,MXELVS,IKLES,IELM,
     &              NPOIN,NELEM,NDP,IPOBO,.TRUE.)
!
      DEALLOCATE(IPOBO)
!
!
!-----------------------------------------------------------------------
!
!
!     INITIALISES COMMONS DIMS AND NODES
!
      IF(PRESENT(NPMAX)) THEN
        NNPMAX = NPMAX
      ELSE
        NNPMAX = NPOIN
      ENDIF
      IF(PRESENT(NPTFRX)) THEN
        NNPTFRX = NPTFRX
      ELSE
        NNPTFRX = NPTFR
      ENDIF
      IF(PRESENT(NELMAX)) THEN
        NNELMAX = NELMAX
      ELSE
        NNELMAX = NELEM
      ENDIF
      IF(PRESENT(NPLAN)) THEN
        NNPLAN = NPLAN
      ELSE
        NNPLAN = 1
      ENDIF
!
      IF(NCSIZE.GT.1) THEN
!
!     IN PARALLEL MODE NSEGBOR (COMPUTED IN SEGBOR) IS NOT NPTFR
!
        CALL SEGBOR(NSEGBOR,IKLES,NELEM,NPOIN)
      ELSE
        NSEGBOR=NPTFR
      ENDIF
!
!     IN CALL ININDS, ALL VALUES ARE 2D VALUES
!     ONLY NNPLAN TELLS IF IT'S 2D OR 3D
!
!     3D TETRAHEDRONS MESH:
!     ADD THE OPTIONAL ARGUMENT NNELEB
!
      ALLOCATE(MESH%NDS(0:81,7))
      CALL BIEF_ININDS(NPOIN,NPTFR,NELEM,NNPMAX,NNPTFRX,NNELMAX,NNPLAN,
     &                 NSEGBOR,MESH%NDS,NNELEB)
!
!     P0 AND P1 ELEMENTS
!
      IELM0  = 10*(IELM/10)
      IELM1  = IELM0 + 1
      D      = DIMENS(IELM0)
!
! BOUNDARY ELEMENTS (AT THE SURFACE AND AT THE BOTTOM FOR PRISMS)
!
      IELB0  = IELBOR(IELM0,1)
      IELB1  = IELBOR(IELM1,1)
!
! LATERAL BOUNDARY ELEMENTS (DIFFERENT FOR PRISMS)
!
      IELB0V = IELBOR(IELM0,2)
      IELB1V = IELBOR(IELM1,2)
!
!-----------------------------------------------------------------------
!
!  ALLOCATES THE ARRAYS OF REALS
!
!     COORDINATES BY ELEMENTS: XEL, YEL, ZEL
!
      ALLOCATE(MESH%XEL)
      ALLOCATE(MESH%YEL)
      ALLOCATE(MESH%ZEL)
!
      CALL BIEF_ALLVEC(1,MESH%XEL,'XEL   ',
     &                 IELM0,BIEF_NBPEL(IELM1,MESH),1,MESH)
      CALL BIEF_ALLVEC(1,MESH%YEL,'YEL   ',
     &                 IELM0,BIEF_NBPEL(IELM1,MESH),1,MESH)
!
      IF(D.GE.3) THEN
        CALL BIEF_ALLVEC(1,MESH%ZEL,'ZEL   ',
     &                   IELM0,BIEF_NBPEL(IELM1,MESH),1,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%ZEL,'ZEL   ',    0,           1,0,MESH)
      ENDIF
!
!     SURFACES OF THE ELEMENTS: SURFAC
!     JAJ CAN BE USED FOR ELEMENT VOLUMES...
!
      ALLOCATE(MESH%SURFAC)
      CALL BIEF_ALLVEC(1,MESH%SURFAC,'SURFAC',IELM0,1,1,MESH)
!
!     1/DET : SURDET ! NOT USED IN 3D, WHY?
!
      ALLOCATE(MESH%SURDET)
      CALL BIEF_ALLVEC(1,MESH%SURDET,'SURDET',IELM0,1,1,MESH)
!
!     LENGTHS OF THE SEGMENTS: LGSEG
!     CAN BE USED (IN THEORY) FOR LATERAL SURFACES IN 3D,
!     BUT THEN IELB0V INSTEAD OF IELB0! (2D CASE NOT AFFECTED)
!
      ALLOCATE(MESH%LGSEG)
      CALL BIEF_ALLVEC(1,MESH%LGSEG,'LGSEG ',IELB0V,1,1,MESH)
!
!     NORMALS TO THE SEGMENTS: XSGBOR, YSGBOR, ZSGBOR
! CAN BE (IN THEORY) USED FOR "NON-SIGMA" MESH FOR LATERAL NORMAL VECTORS
! PER LATERAL BOUNDARY ELEMENT, BUT THEN IELB0V INSTEAD OF IELB0!
! 2D CASE NOT AFFECTED
!
      ALLOCATE(MESH%XSGBOR)
      ALLOCATE(MESH%YSGBOR)
      ALLOCATE(MESH%ZSGBOR)
!     SEE NORMAB FOR MEANING OF 4 DIMENSIONS
      CALL BIEF_ALLVEC(1,MESH%XSGBOR,'XSGBOR',IELB0V,4,1,MESH)
      CALL BIEF_ALLVEC(1,MESH%YSGBOR,'YSGBOR',IELB0V,4,1,MESH)
      IF(D.GE.3) THEN
        CALL BIEF_ALLVEC(1,MESH%ZSGBOR,'ZSGBOR',IELB0V,4,1,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%ZSGBOR,'ZSGBOR',     0,4,0,MESH)
      ENDIF
!
!     NORMALS AT THE NODES: XNEBOR, YNEBOR, ZNEBOR
!
! IN 3D THEY ARE NORMAL VECTORS AT THE BOTTOM
! SO THAT IELB1 REMAINS
!
      ALLOCATE(MESH%XNEBOR)
      ALLOCATE(MESH%YNEBOR)
      ALLOCATE(MESH%ZNEBOR)
!
      CALL BIEF_ALLVEC(1,MESH%XNEBOR,'XNEBOR',IELB1,2,1,MESH)
      CALL BIEF_ALLVEC(1,MESH%YNEBOR,'YNEBOR',IELB1,2,1,MESH)
!
      IF(D.GE.3) THEN !JAJ NOT USED, ACTUALLY
        CALL BIEF_ALLVEC(1,MESH%ZNEBOR,'ZNEBOR',IELB1,2,1,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%ZNEBOR,'ZNEBOR',    0,2,0,MESH)
      ENDIF
!
!     COORDINATES BY POINTS: X, Y AND Z
!
      ALLOCATE(MESH%X)
      ALLOCATE(MESH%Y)
      ALLOCATE(MESH%Z)
      CALL BIEF_ALLVEC(1,MESH%X,'X     ',IELM1,1,1,MESH)
      CALL BIEF_ALLVEC(1,MESH%Y,'Y     ',IELM1,1,1,MESH)
      IF(D.GE.3) THEN
        CALL BIEF_ALLVEC(1,MESH%Z,'Z     ',IELM1,1,1,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%Z,'Z     ',    0,1,0,MESH)
      ENDIF
!
!     COS AND SIN OF THE LATITUDE
!     WITH IELM (EXAMPLE : VELOCITY IN CORIOLIS)
!     COSLAT AND SINLAT ARE WORKING ARRAYS, TO WHICH
!     THE STRUCTURE OF X IS GIVEN TO BEGIN WITH.
!     THEY CAN BE EXTENDED TO ELEMENT IELM AT A LATER DATE.
!
      ALLOCATE(MESH%COSLAT)
      ALLOCATE(MESH%SINLAT)
      IF(SPHERI) THEN ! DIFFERENT COMPARED TO V2.3
        CALL BIEF_ALLVEC(1,MESH%COSLAT,'COSLAT',IELM,1,2,MESH)
        CALL BIEF_ALLVEC(1,MESH%SINLAT,'SINLAT',IELM,1,2,MESH)
        CALL CPSTVC(MESH%X,MESH%COSLAT)
        CALL CPSTVC(MESH%X,MESH%SINLAT)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%COSLAT,'COSLAT',   0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%SINLAT,'SINLAT',   0,1,0,MESH)
      ENDIF
!
!     DISTANCES TO BOUNDARIES : DISBOR
!
      ALLOCATE(MESH%DISBOR)
      CALL BIEF_ALLVEC(1,MESH%DISBOR,'DISBOR',IELB0,1,1,MESH)
!
!     WORKING MATRIX (INTERNAL TO BIEF), WITH CLASSICAL STORAGE
!
      STOCFG = CFG(1)
      CFG(1) = 1
      ALLOCATE(MESH%M)
      CALL BIEF_ALLMAT(MESH%M,'M     ',IELM,IELM,CFG,'Q','Q',MESH)
      CFG(1) = STOCFG
!
!     WORKING MATRIX BY SEGMENT
!
      ALLOCATE(MESH%MSEG)
!     FROM 5.9 ON, ALWAYS DONE IN 2D (IELM=11,12,13 OR 14)
      IF(CFG(1).EQ.3.OR.10*(IELM/10).EQ.10) THEN
        CALL BIEF_ALLMAT(MESH%MSEG,'MSEG  ',
     &                   IELM,IELM,CFG,'Q','Q',MESH)
      ELSE
        CALL BIEF_ALLMAT(MESH%MSEG,'MSEG  ',
     &                   IELM,IELM,CFG,'0','0',MESH)
      ENDIF
!
!     WORKING ARRAY FOR A NOT ASSEMBLED VECTOR
!
      ALLOCATE(MESH%W)
      CALL BIEF_ALLVEC(1,MESH%W,'W     ',
     &                 IELM0,BIEF_NBPEL(IELM,MESH),2,MESH)
!
!     WORKING ARRAY FOR A NORMAL VECTOR
!
      ALLOCATE(MESH%T)
      CALL BIEF_ALLVEC(1,MESH%T,'T     ',IELM,1,2,MESH)
!
!     VNOIN: ARRAY WITH NORMALS VNOIN FOR FINITE VOLUMES
!     CMI: COORDINATES OF THE MIDDLE OF THE SEGMENTS (KINETIC SCHEMES)
!     DTHAUT:
!     DPX,DPY: GRADIENTS OF THE BASE FUNCTIONS
!
      ALLOCATE(MESH%VNOIN)
      ALLOCATE(MESH%CMI)
      ALLOCATE(MESH%AIRST)
      ALLOCATE(MESH%DTHAUT)
      ALLOCATE(MESH%DPX)
      ALLOCATE(MESH%DPY)
      IF(EQUA(1:15).EQ.'SAINT-VENANT VF') THEN
        NSEG=BIEF_NBSEG(IELM1,MESH)
        CALL BIEF_ALLVEC(1,MESH%VNOIN ,'VNOIN ',3*NSEG,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%CMI   ,'CMI   ',2*NSEG,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%AIRST ,'AIRST ',2*NSEG,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%DTHAUT,'DTHAUT',IELM1 ,1,2,MESH)
        CALL BIEF_ALLVEC(1,MESH%DPX   ,'DPX   ',IELM0 ,3,2,MESH)
        CALL BIEF_ALLVEC(1,MESH%DPY   ,'DPY   ',IELM0 ,3,2,MESH)
      ELSE
        CALL BIEF_ALLVEC(1,MESH%VNOIN ,'VNOIN ',     0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%CMI   ,'CMI   ',     0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%AIRST ,'AIRST ',     0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%DTHAUT,'DTHAUT',     0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%DPX   ,'DPX   ',     0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%DPY   ,'DPY   ',     0,1,0,MESH)
      ENDIF
!     FOR COORDINATES OF CENTER OF GRAVITY OF ELEMENTS NEIGHBORING EDGES 
!   
      ALLOCATE(MESH%COORDG)
      NSEG=BIEF_NBSEG(IELM1,MESH)
      CALL BIEF_ALLVEC(1,MESH%COORDG ,'COORDG',4*NSEG,1,0,MESH)
!
!     FOR PARALLEL MODE
!
      ALLOCATE(MESH%XSEG)
      ALLOCATE(MESH%YSEG)
      ALLOCATE(MESH%FAC)
!     THERE ALLVEC IS IN PARINI
      ALLOCATE(MESH%BUF_SEND)
      ALLOCATE(MESH%BUF_RECV)
!
      IF(NCSIZE.GT.1) THEN
!
!       XSEG
        CALL BIEF_ALLVEC(1,MESH%XSEG,'XSEG  ',IELBOR(IELM1,2),1,2,MESH)
!       YSEG
        CALL BIEF_ALLVEC(1,MESH%YSEG,'YSEG  ',IELBOR(IELM1,2),1,2,MESH)
!       FAC
        CALL BIEF_ALLVEC(1,MESH%FAC,'FAC   ',IELM ,1,2,MESH)
!
      ELSE
        CALL BIEF_ALLVEC(1,MESH%XSEG  ,'XSEG  ',0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%YSEG  ,'YSEG  ',0,1,0,MESH)
        CALL BIEF_ALLVEC(1,MESH%FAC   ,'FAC   ',0,1,0,MESH)
      ENDIF
!
!-----------------------------------------------------------------------
!
!     1) INTEGER VALUES (ALLOCATE BECAUSE THEY ARE POINTERS)
!
      ALLOCATE(MESH%NELEM)
      MESH%NELEM  = BIEF_NBPTS(IELM0,MESH)
      ALLOCATE(MESH%NELMAX)
!     WILL GIVE BACK NNELMAX FEEDED TO BIEF_ININDS ABOVE...
      MESH%NELMAX = BIEF_NBMPTS(IELM0,MESH)
!
!
! I DO USE MESH%NPTFR FOR THE NUMBER OF LATERAL BOUNDARY NODES
! IELBOR(IELM0,1) CHANGED TO IELBOR(IELM1,1)
! THE PROBLEM IS, THAT FOR 3D (IELM=41):
! BIEF_NBPTS(IELBOR(IELM0,1),MESH) IS THE NUMBER OF HORIZONTAL BOUNDARY ELEMENTS
! BIEF_NBPTS(IELBOR(IELM0,2),MESH) IS THE NUMBER OF VERTICAL BOUNDARY ELEMENTS
! BIEF_NBPTS(IELBOR(IELM1,1),MESH) IS THE NUMBER OF HORIZONTAL BOUNDARY NODES
! BIEF_NBPTS(IELBOR(IELM1,2),MESH) IS THE NUMBER OF VERTICAL BOUNDARY NODES
!
! FUNNY, BUT THE 2D CASE IS NOT AFFECTED, BECAUSE THE NUMBER OF BOUNDARY
! SEGMENTS IS EQUAL TO THE NUMBER OF BOUNDARY NODES.
!
      ALLOCATE(MESH%NPTFR)
      MESH%NPTFR  = BIEF_NBPTS(IELBOR(IELM1,2),MESH)
      ALLOCATE(MESH%NPTFRX)
      MESH%NPTFRX = BIEF_NBMPTS(IELBOR(IELM1,2),MESH)
!
! NUMBER OF LATERAL BOUNDARY ELEMENTS
!
      ALLOCATE(MESH%NELEB)
      ALLOCATE(MESH%NELEBX)
!
!     3D MESH
!
      IF(IELM.EQ.31) THEN
!       HERE NNELEB HAS BEEN READ IN THE GEOMETRY FILE
        MESH%NELEB   = NNELEB
        MESH%NELEBX  = NNELEB
      ELSEIF(IELM.EQ.11.OR.IELM.EQ.12.OR.IELM.EQ.13.OR.IELM.EQ.14) THEN
        MESH%NELEB   = NPTFR
        MESH%NELEBX  = NNPTFRX
      ELSEIF(IELM.EQ.41) THEN
        MESH%NELEB   = NPTFR*(NNPLAN-1)
        MESH%NELEBX  = NNPTFRX*(NNPLAN-1)
      ELSEIF(IELM.EQ.51) THEN
        MESH%NELEB   = 2*NPTFR*(NNPLAN-1)
        MESH%NELEBX  = 2*NNPTFRX*(NNPLAN-1)
      ELSE
        WRITE(LU,*) 'ALMESH, UNEXPECTED ELEMENT FOR NELEB:',IELM
        CALL PLANTE(1)
        STOP
      ENDIF
!
      ALLOCATE(MESH%DIM)
      MESH%DIM    = DIMENS(IELM0)
      ALLOCATE(MESH%TYPELM)
      MESH%TYPELM = IELM0
      ALLOCATE(MESH%NPOIN)
      MESH%NPOIN  = BIEF_NBPTS(IELM1,MESH)
      ALLOCATE(MESH%NPMAX)
      MESH%NPMAX  = BIEF_NBMPTS(IELM1,MESH)
      ALLOCATE(MESH%MXPTVS)
      MESH%MXPTVS = MXPTVS
      ALLOCATE(MESH%MXELVS)
      MESH%MXELVS = MXELVS
!     LV WILL BE RECOMPUTED LATER
      ALLOCATE(MESH%LV)
      MESH%LV     = 1
      ALLOCATE(MESH%NSEG)
      MESH%NSEG = BIEF_NBSEG(IELM1,MESH)
!
!     2) ARRAYS OF INTEGERS
!
!     ALLOCATES IKLE AND KLEI (SAME SIZE, 2 INVERTED DIMENSIONS)
!
      ALLOCATE(MESH%IKLE)
      CALL BIEF_ALLVEC(2,MESH%IKLE,'IKLE  ',
     &                 IELM0,BIEF_NBPEL(IELM,MESH),1,MESH)
      ALLOCATE(MESH%KLEI)
      CALL BIEF_ALLVEC(2,MESH%KLEI,'KLEI  ',
     &                 IELM0,BIEF_NBPEL(IELM,MESH),1,MESH)
!
!     IFABOR
!
      ALLOCATE(MESH%IFABOR)
      CALL BIEF_ALLVEC(2,MESH%IFABOR,'IFABOR',
     &                 IELM0,BIEF_NBFEL(IELM,MESH),1,MESH)
!
!     NELBOR
!
! NELBOR & NULONE
! IT IS NOW CHANGED TO VERTICAL BOUNDARY ELEMENT...
! 2D NOT AFFECTED, 3D USAGE NELBO3(NPTFR,NETAGE) - NO. OF LAT. BD. ELEMENTS
!
      ALLOCATE(MESH%NELBOR)
      CALL BIEF_ALLVEC(2,MESH%NELBOR,'NELBOR',IELBOR(IELM0,2),1,1,MESH)
!
!     NULONE
!
!
! EXTRAORDINARILY STRANGE GEOMETRICALLY
! IN 2D NUMBER OF BOUNDARY NODES IS EQUAL TO THE NUMBER OF BOUNDARY
! ELEMENTS... IN 3D IT IS NOT THE CASE!
! NULONE 3D IS USED INTERNALLY AS: NULONE(NPTFR,NETAGE,4)
! "ASSOCIATES THE LOCAL BOUNDARY NUMBERING TO LOCAL 3D NUMBERING"
!
      ALLOCATE(MESH%NULONE)
!
      CALL BIEF_ALLVEC(2,MESH%NULONE,'NULONE',
     &                 IELBOR(IELM0,2),
     &                 BIEF_NBPEL(IELBOR(IELM,2),MESH),1,MESH)
!
!!! NOTE : FOR THE TETRAHEDRONS, THIS IS NO LONGER THE CASE. WE READ THE
!          BOUNDARY CONNECTIVITY TABLE BEFORE INITIALISING THE NUMBER OF
!          BOUNDARY NODES AND ELEMENTS. THIS IS WELL DEFINED NOW.
!
! IN 2D IT IS CALL BIEF_ALLVEC(2, MESH%NULONE, 'NULONE', 0,  2, 1,MESH)
! WHICH, IN 2D ONLY IS EQUIVALENT TO
!             CALL BIEF_ALLVEC(2, MESH%NULONE, 'NULONE', 1,  2, 1,MESH)
! IN 3D IT IS CALL BIEF_ALLVEC(2, MESH%NULONE, 'NULONE', 20, 4, 1,MESH)
!
!
!     KP1BOR
!
      ALLOCATE(MESH%KP1BOR)
      CALL BIEF_ALLVEC(2,MESH%KP1BOR,'KP1BOR', IELBOR(IELM,1),2,1,MESH)
!
!     NBOR: GLOBAL NUMBERS OF THE BOUNDARY NODES
!     ALLOCATES NBOR, IT WILL BE READ IN LECLIM
!
      ALLOCATE(MESH%NBOR)
      CALL BIEF_ALLVEC(2,MESH%NBOR,'NBOR  ',IELBOR(IELM,2),1,1,MESH)
!
!     IKLBOR: IKLE FOR THE SEGMENTS OR BOUNDARY SIDES
!
      ALLOCATE(MESH%IKLBOR)
!
      IF(IELM.EQ.41.OR.IELM.EQ.51) THEN
!       LATERAL BOUNDARY SIDES
!       SEE ININDS FOR ELEMENTS 20 AND 21
!       CALL BIEF_ALLVEC(2,MESH%IKLBOR,'IKLBOR',
!    &                   IELBOR(IELM0,2),
!    &                   BIEF_NBPEL(IELBOR(IELM1,2),MESH),1,MESH)
        CALL BIEF_ALLVEC(2,MESH%IKLBOR,'IKLBOR',
     &                   MESH%NELEBX,
     &                   BIEF_NBPEL(IELBOR(IELM1,2),MESH),0,MESH)
      ELSEIF(IELM.EQ.11.OR.IELM.EQ.12.OR.IELM.EQ.13
     &   .OR.IELM.EQ.31) THEN
        CALL BIEF_ALLVEC(2,MESH%IKLBOR,'IKLBOR',
     &                   IELBOR(IELM0,1),
     &                   BIEF_NBPEL(IELBOR(IELM ,2),MESH),1,MESH)
      ELSE
        WRITE(LU,*) 'ALMESH : UNKNOWN ELEMENT FOR IKLBOR:',IELM
        CALL PLANTE(1)
        STOP
      ENDIF
!
!     IFANUM: NUMBER OF THE SIDE IN ADJACENT ELEMENT
!
      ALLOCATE(MESH%IFANUM)
      IF(CFG(1).EQ.2) THEN
        CALL BIEF_ALLVEC(2,MESH%IFANUM,'IFANUM',
     &                   3*BIEF_NBMPTS(IELM0,MESH)
     &                   + BIEF_NBMPTS(01   ,MESH) ,1,0 ,MESH)
      ELSEIF(CFG(1).NE.1.AND.CFG(1).NE.3) THEN
        IF(LNG.EQ.1) WRITE(LU,98) CFG(1)
        IF(LNG.EQ.2) WRITE(LU,99) CFG(1)
98      FORMAT(1X,'ALMESH : STOCKAGE INCONNU :',1I6)
99      FORMAT(1X,'ALMESH : UNKNOWN STORAGE:',1I6)
        CALL PLANTE(1)
        STOP
      ELSE
        CALL BIEF_ALLVEC(2,MESH%IFANUM,'IFANUM', 0 , 1,0,MESH )
      ENDIF
!
!     IKLEM1: INVERSE CONNECTIVITY TABLE FOR FRONTAL PRODUCT
!     LIMVOI: LIMITING NUMBER OF A GIVEN NUMBER OF NEIGHBOURS
!
      ALLOCATE(MESH%IKLEM1)
      ALLOCATE(MESH%LIMVOI)
      IF(CFG(2).EQ.2) THEN
!       CALL BIEF_ALLVEC(2,MESH%IKLEM1,'IKLEM1',
!                        NBMPTS(IELM1)*MXPTVS,4,0,MESH)
!       FOR OPTASS=3: SYM AND NOT SYM ARE DIFFERENT
        CALL BIEF_ALLVEC(2,MESH%IKLEM1,'IKLEM1',
     &                   BIEF_NBMPTS(IELM1,MESH)*MXPTVS,8,0,MESH)
!       11 IS HERE THE MAXIMUM MXPTVS PROGRAMMED IN OPASS
        CALL BIEF_ALLVEC(2,MESH%LIMVOI,'LIMVOI',11,2,0,MESH)
      ELSEIF(CFG(2).NE.1) THEN
        IF(LNG.EQ.1) WRITE(LU,96) CFG(2)
        IF(LNG.EQ.2) WRITE(LU,97) CFG(2)
96      FORMAT(1X,'ALMESH : PRODUIT MATRICE-VECTEUR INCONNU :',1I6)
97      FORMAT(1X,'ALMESH: UNKNOWN MATRIX-VECTOR PRODUCT:',1I6)
        STOP
      ELSE
        CALL BIEF_ALLVEC(2,MESH%IKLEM1,'IKLEM1',0,4,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%LIMVOI,'LIMVOI',0,2,0,MESH)
      ENDIF
!
!     INTEGER ARRAYS FOR SEGMENT-BASED STORAGE
!
      ALLOCATE(MESH%GLOSEG)
      ALLOCATE(MESH%ELTSEG)
      ALLOCATE(MESH%ORISEG)
      ALLOCATE(MESH%GLOSEGBOR)
      ALLOCATE(MESH%ELTSEGBOR)
      ALLOCATE(MESH%ORISEGBOR)
      !
      CALL BIEF_ALLVEC(2,MESH%GLOSEG,'GLOSEG',
     &                 BIEF_NBSEG(IELM,MESH),2,0,MESH)
      CALL BIEF_ALLVEC(2,MESH%ELTSEG,'ELTSEG',
     &                 BIEF_NBMPTS(IELM0,MESH),
     &                 BIEF_NBSEGEL(IELM,MESH),0,MESH)
      CALL BIEF_ALLVEC(2,MESH%ORISEG,'ORISEG',
     &                 BIEF_NBMPTS(IELM0,MESH),
     &                 BIEF_NBSEGEL(IELM,MESH),0,MESH)
      CALL BIEF_ALLVEC(2,MESH%GLOSEGBOR,'GLOSEGBOR',
     &                 BIEF_NBSEG(IELB1,MESH),2,0,MESH)
      CALL BIEF_ALLVEC(2,MESH%ELTSEGBOR,'ELTSEGBOR',
     &                 BIEF_NBMPTS(IELB0,MESH),
     &                 BIEF_NBSEGEL(IELB1,MESH),0,MESH)
      CALL BIEF_ALLVEC(2,MESH%ORISEGBOR,'ORISEGBOR',
     &                 BIEF_NBMPTS(IELB0,MESH),
     &                 BIEF_NBSEGEL(IELB1,MESH),0,MESH)
!
!     INTEGER ARRAY FOR THE METHOD OF CHARACTERISTICS
!     THE STARTING ELEMENT (0 IF NOT IN THIS SUBDOMAIN)
!
      ALLOCATE(MESH%ELTCAR)
      CALL BIEF_ALLVEC(2,MESH%ELTCAR,'ELTCAR',IELM,1,1,MESH)
!
!     INTEGER ARRAYS FOR PARALLEL MODE
!
!     KNOLG
!     NACHB
!     ISEG
!     KNOGL
!     INDPU
!     NHP
!     NHM
!
      ALLOCATE(MESH%KNOLG)
      ALLOCATE(MESH%NACHB)
      ALLOCATE(MESH%ISEG)
      ALLOCATE(MESH%KNOGL)
      ALLOCATE(MESH%INDPU)
      ALLOCATE(MESH%NHP)
      ALLOCATE(MESH%NHM)
      ALLOCATE(MESH%IFAPAR)
      ALLOCATE(MESH%NB_NEIGHB)
      ALLOCATE(MESH%NB_NEIGHB_SEG)
!     THERE ALLVEC IS IN PARINI
      ALLOCATE(MESH%NB_NEIGHB_PT)
      ALLOCATE(MESH%LIST_SEND)
      ALLOCATE(MESH%NH_COM)
      ALLOCATE(MESH%NB_NEIGHB_PT_SEG)
      ALLOCATE(MESH%LIST_SEND_SEG)
      ALLOCATE(MESH%NH_COM_SEG)
!
!     DATA STRUCTURE IN PARALLEL (KNOGL WILL BE ALLOCATED
!                                 FURTHER DOWN)
!
      IF(NCSIZE.GT.1) THEN
!
        CALL BIEF_ALLVEC(2,MESH%KNOLG,'KNOLG ',
     &                   IELM1            ,1,1,MESH)
        CALL BIEF_ALLVEC(2,MESH%NACHB,'NACHB ',
     &                   NBMAXNSHARE*NPTIR,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%ISEG ,'ISEG  ',
     &                   IELBOR(IELM1,1)  ,1,1,MESH)
        CALL BIEF_ALLVEC(2,MESH%INDPU,'INDPU ',
     &                   IELM1              ,1,1,MESH)
        CALL BIEF_ALLVEC(2,MESH%NHP  ,'NHP   ',
     &                   NBMAXDSHARE*2*NPTIR,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%NHM  ,'NHM   ',
     &                   NBMAXDSHARE*2*NPTIR,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%IFAPAR,'IFAPAR',
     &                   10,6,1,MESH)
!
        DO I=1,6*BIEF_NBPTS(10,MESH)
          MESH%IFAPAR%I(I)=0
        ENDDO
!
      ELSE
!
        CALL BIEF_ALLVEC(2,MESH%KNOLG ,'KNOLG ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%NACHB ,'NACHB ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%ISEG  ,'ISEG  ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%INDPU ,'INDPU ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%NHP   ,'NHP   ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%NHM   ,'NHM   ',0,1,0,MESH)
        CALL BIEF_ALLVEC(2,MESH%IFAPAR,'IFAPAR',0,1,0,MESH)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!  FINITE VOLUMES
!
      ALLOCATE(MESH%NUBO)
      IF(EQUA(1:15).EQ.'SAINT-VENANT VF') THEN
        CALL BIEF_ALLVEC(2,MESH%NUBO,'NUBO  ',2*NSEG,1,0,MESH)
      ELSE
        CALL BIEF_ALLVEC(2,MESH%NUBO,'NUBO  ',     0,1,0,MESH)
      ENDIF
!
      ALLOCATE(MESH%JMI)
      IF(EQUA(1:15).EQ.'SAINT-VENANT VF') THEN
        CALL BIEF_ALLVEC(2,MESH%JMI,'JMI   ',NSEG,1,0,MESH)
      ELSE
        CALL BIEF_ALLVEC(2,MESH%JMI,'JMI   ',   0,1,0,MESH)
      ENDIF
!
!-----------------------------------------------------------------------
!
!     FILLS ARRAYS IKLE, X AND Y (AND Z)
!
!     PRISMS CUT INTO TETRAHEDRONS
!
      IF(IELM.EQ.51) THEN
!
!       NOTE : NO Z HERE, AS IELM.EQ.41, SEE NOTE BELOW
        CALL READGEO3(MESH%KNOLG%I,MESH%X%R,MESH%Y%R,NPOIN,NFIC,IB,
     *                FFORMAT,PROJEC,LATI,LONGI)
!
        CALL CPIKLE3(MESH%IKLE%I,IKLES,NELEM,NNELMAX,NPOIN,NNPLAN,
     *               MESH%KNOLG%I)
!
!     PRISMS
!
      ELSEIF(IELM.EQ.41) THEN
!
!       NOTE : WITH PRISMS Z IS COMPUTED WITH ZF AND H, OR
!              READ IN THE PREVIOUS COMPUTATION FILE, HENCE NO Z HERE
        CALL READGEO3(MESH%KNOLG%I,MESH%X%R,MESH%Y%R,NPOIN,NFIC,IB,
     *                FFORMAT,PROJEC,LATI,LONGI)
!
        CALL CPIKLE2(MESH%IKLE%I,MESH%KLEI%I,IKLES,
     &               NELEM,NNELMAX,NPOIN,NNPLAN)
!
!     TRIANGLES OR TETRAHEDRONS
!
      ELSEIF(IELM.EQ.11.OR.IELM.EQ.12.OR.IELM.EQ.13.OR.IELM.EQ.14
     &   .OR.IELM.EQ.31) THEN
!
!       IKLES(NDP,NELEM) COPIED INTO IKLE(NELMAX,NDP) AND KLEI(NDP,NELMAX)
        DO I = 1,NDP
          DO IELEM  = 1,NELEM
            MESH%IKLE%I((I-1)*NNELMAX+IELEM) = IKLES((IELEM-1)*NDP+I)
            MESH%KLEI%I((IELEM-1)*NDP+I)     = IKLES((IELEM-1)*NDP+I)
          ENDDO
        ENDDO
        IF(IELM.EQ.11.OR.IELM.EQ.12.OR.IELM.EQ.13.OR.IELM.EQ.14) THEN
          CALL READGEO3(MESH%KNOLG%I,MESH%X%R,MESH%Y%R,NPOIN,NFIC,IB,
     &                  FFORMAT,PROJEC,LATI,LONGI)
        ELSEIF(IELM.EQ.31) THEN
!         TETRAHEDRONS: READS THE Z COORDINATE AFTER X AND Y
          CALL READGEO3(MESH%KNOLG%I,MESH%X%R,MESH%Y%R,NPOIN,NFIC,IB,
     &                  FFORMAT,PROJEC,LATI,LONGI,Z=MESH%Z%R)
        ENDIF
!
      ELSE
!
! OTHER ELEMENT TYPES
!
        WRITE(LU,*) 'ALMESH : UNKNOWN ELEMENT:',IELM
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
!     NOW WE HAVE KNOGL IN 2D
!     FINDING THE NUMBER OF POINTS IN THE ORIGINAL MESH
!     = MAXIMUM OF ALL KNOLG OF ALL SUB-DOMAINS
!
      NPOIN_GLOB=0
      IF(NCSIZE.GT.1) THEN
        DO I=1,NPOIN
          NPOIN_GLOB=MAX(NPOIN_GLOB,MESH%KNOLG%I(I))
        ENDDO
        NPOIN_GLOB=P_IMAX(NPOIN_GLOB)
      ENDIF
!
!     NOW WE HAVE NPOIN_GLOB, WE CAN ALLOCATE KNOGL
!     (WITH SIZE 0 IF NOT IN PARALLEL)
!
      CALL BIEF_ALLVEC(2,MESH%KNOGL,'KNOGL ',
     &                   NPOIN_GLOB,1,0,MESH)
!
!     COMPLEMENTS: ARRAYS X, Y FOR PRISMS AND TETRAHEDRONS
!                  KNOLG FOR PRISMS AND TETRAHEDRONS     
!
      IF(IELM.EQ.41.OR.IELM.EQ.51) THEN
        DO IPLAN = 2,NNPLAN
          CALL OV_2( 'X=Y     ' , MESH%X%R,IPLAN, MESH%X%R,1,
     &                            MESH%X%R,1, 0.D0, NNPMAX,NPOIN)
          CALL OV_2( 'X=Y     ' , MESH%Y%R,IPLAN, MESH%Y%R,1,
     &                            MESH%Y%R,1, 0.D0, NNPMAX,NPOIN)
        ENDDO
        IF(NCSIZE.GT.1) THEN
          DO IPLAN = 2,NNPLAN
            DO I=1,NPOIN
              MESH%KNOLG%I(I+(IPLAN-1)*NPOIN)=
     &        MESH%KNOLG%I(I)+(IPLAN-1)*NPOIN_GLOB             
            ENDDO
          ENDDO
        ENDIF
      ENDIF
!
!-----------------------------------------------------------------------
!
! DEALLOCATES TEMPORARY ARRAYS
!
      DEALLOCATE(IKLES)
!
!-----------------------------------------------------------------------
!
      IF(LNG.EQ.1) WRITE(LU,*) 'MAILLAGE : ',NOM,' ALLOUE'
      IF(LNG.EQ.2) WRITE(LU,*) 'MESH: ',NOM,' ALLOCATED'
!
!-----------------------------------------------------------------------
!
      RETURN
      END
