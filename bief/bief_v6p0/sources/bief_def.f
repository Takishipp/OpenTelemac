C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       DEFINITION OF THE BIEF STRUCTURES<br>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Internal(s)
!>    </th><td> IPID, NBMAXDSHARE, NBMAXNSHARE, NCSIZE, NHALO, NPTIR
!>   </td></tr>
!>     </table>

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>     </table>
C
C#######################################################################
C
      MODULE BIEF_DEF
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
C=======================================================================
C
C     COMMON VALUES FOR PARALLEL MODE
C
C     NPTIR: NUMBER OF INTERFACE POINTS OF THE SUB-DOMAIN
C     IPID: PROCESSOR NUMBER
C     NCSIZE: NUMBER OF PROCESSORS
      INTEGER NPTIR,IPID,NCSIZE,NHALO
C
C     MAXIMUM GEOMETRICAL MULTIPLICITY OF A NODE
      INTEGER, PARAMETER :: NBMAXNSHARE =  10
C     FOR A DOMAIN, MAXIMUM NUMBER OF DOMAIN NEIGHBOURS/2
C     BE CAREFUL: VARIABLE USED IN PARTEL.F TOO
      INTEGER, PARAMETER :: NBMAXDSHARE = 80
C
C=======================================================================
C
C  STRUCTURE OF POINTER TO A BIEF_OBJ, TO HAVE ARRAYS OF POINTERS
C  IN THE BIEF_OBJ STRUCTURE FOR BLOCKS
C
C  BIEF RELEASE 6.0
C
C=======================================================================
C
C       THIS IS NECESSARY IN FORTRAN 90 TO HAVE ARRAYS OF POINTERS
C       LIKE THE COMPONENT ADR BELOW, WHICH ENABLES TO BUILD BLOCKS
C       WHICH ARE ARRAYS OF POINTERS TO BIEF_OBJ STRUCTURES
C
        TYPE POINTER_TO_BIEF_OBJ
          TYPE(BIEF_OBJ), POINTER :: P
        END TYPE POINTER_TO_BIEF_OBJ
C
C=======================================================================
C
C  STRUCTURE OF VECTOR, MATRIX OR BLOCK IN A SINGLE OBJECT : BIEF_OBJ
C
C=======================================================================
C
        TYPE BIEF_OBJ
C
C-----------------------------------------------------------------------
C
C       HEADER COMMON TO ALL OBJECTS
C
C         KEY : ALWAYS 123456 TO CHECK MEMORY OVERWRITING
          INTEGER KEY
C
C         TYPE: 2: VECTOR,  3: MATRIX,  4: BLOCK
          INTEGER TYPE
C
C         NAME: FORTRAN NAME OF OBJECT IN 6 CHARACTERS
          CHARACTER(LEN=6) NAME
C
C-----------------------------------------------------------------------
C
C       FOR VECTORS
C
C
C         NAT: NATURE (1:DOUBLE PRECISION  2:INTEGER)
          INTEGER NAT
C
C         ELM: TYPE OF ELEMENT
          INTEGER ELM
C
C         DIM1: FIRST DIMENSION OF VECTOR
          INTEGER DIM1
C
C         MAXDIM1: MAXIMUM SIZE PER DIMENSION
          INTEGER MAXDIM1
C
C         DIM2: SECOND DIMENSION OF VECTOR
          INTEGER DIM2
C
C         MAXDIM2: MAXIMUM SECOND DIMENSION OF VECTOR
          INTEGER MAXDIM2
C
C         DIMDISC: TYPE OF ELEMENT IF VECTOR IS DISCONTINUOUS AT
C                  THE BORDER BETWEEN ELEMENTS, OR 0 IF NOT
          INTEGER DIMDISC
C
C         STATUS:
C         0: ANY ARRAY
C         1: VECTOR DEFINED ON A MESH, NO CHANGE OF DISCRETISATION
C         2: VECTOR DEFINED ON A MESH, CHANGE OF DISCRETISATION ALLOWED
          INTEGER STATUS
C
C         TYPR: TYPE OF VECTOR OF REALS
C         '0' : NIL   '1' : EQUAL TO 1  'Q' : NO SPECIFIC PROPERTY
          CHARACTER*1 TYPR
C
C         TYPR: TYPE OF VECTOR OF REALS
C         '0' : NIL   '1' : EQUAL TO 1  'Q' : NO SPECIFIC PROPERTY
          CHARACTER*1 TYPI
C
C         POINTER TO DOUBLE PRECISION 1-DIMENSION ARRAY
C         DATA ARE STORED HERE FOR A DOUBLE PRECISION VECTOR
          DOUBLE PRECISION, POINTER,DIMENSION(:)::R
C
C         POINTER TO INTEGER 1-DIMENSION ARRAY
C         DATA ARE STORED HERE FOR AN INTEGER VECTOR
          INTEGER, POINTER,DIMENSION(:)::I
C
C-----------------------------------------------------------------------
C
C       FOR MATRICES
C
C         STO: TYPE OF STORAGE  1: CLASSICAL EBE   3: EDGE-BASED STORAGE
          INTEGER STO
C
C         ELMLIN: TYPE OF ELEMENT OF ROW
          INTEGER ELMLIN
C
C         ELMCOL: TYPE OF ELEMENT OF COLUMN
          INTEGER ELMCOL
C
C         TYPDIA: TYPE OF DIAGONAL
C         '0' : NIL   'I' : IDENTITY  'Q' : NO SPECIFIC PROPERTY
          CHARACTER*1 TYPDIA
C
C         TYPEXT: TYPE OF EXTRA-DIAGONAL TERMS
C         '0' : NIL   'S' : SYMMETRY  'Q' : NO SPECIFIC PROPERTY
          CHARACTER*1 TYPEXT
C
C         POINTER TO A BIEF_OBJ FOR DIAGONAL
          TYPE(BIEF_OBJ), POINTER :: D
C
C         POINTER TO A BIEF_OBJ FOR EXTRA-DIAGONAL TERMS
          TYPE(BIEF_OBJ), POINTER :: X
C
C         PRO: TYPE OF MATRIX-VECTOR PRODUCT
          INTEGER PRO
C
C-----------------------------------------------------------------------
C
C       FOR BLOCKS
C
C         BLOCKS ARE IN FACT ARRAYS OF POINTERS TO BIEF_OBJ STRUCTURES
C         ADR(I)%P WILL BE THE I-TH BIEF_OBJ OBJECT
C
C         N: NUMBER OF OBJECTS IN THE BLOCK
          INTEGER N
C         MAXBLOCK: MAXIMUM NUMBER OF OBJECTS IN THE BLOCK
          INTEGER MAXBLOCK
C         ADR: ARRAY OF POINTERS TO OBJECTS (WILL BE OF SIZE MAXBLOCK)
          TYPE(POINTER_TO_BIEF_OBJ), POINTER, DIMENSION(:) :: ADR
C
C-----------------------------------------------------------------------
C
        END TYPE BIEF_OBJ
C
C
C=======================================================================
C
C  STRUCTURE OF MESH : BIEF_MESH
C
C=======================================================================
C
        TYPE BIEF_MESH
C
C         1) A HEADER
C
C         NAME: NAME OF MESH IN 6 CHARACTERS
          CHARACTER(LEN=6) NAME
C
C         2) A SERIES OF INTEGER VALUES (DECLARED AS POINTERS TO ENABLE
C                                        ALIASES)
C
C         NELEM: NUMBER OF ELEMENTS IN MESH
          INTEGER, POINTER :: NELEM
C
C         NELMAX: MAXIMUM NUMBER OF ELEMENTS ENVISAGED
          INTEGER, POINTER :: NELMAX
C
C         NPTFR: NUMBER OF 1D BOUNDARY NODES, EVEN IN 3D
          INTEGER, POINTER :: NPTFR
C
C         NPTFRX: NUMBER OF 1D BOUNDARY NODES, EVEN IN 3D
          INTEGER, POINTER :: NPTFRX
C
C         NELEB: NUMBER OF BOUNDARY ELEMENTS (SEGMENTS IN 2D)
C         IN 3D WITH PRISMS:
C         NUMBER OF LATERAL BOUNDARY ELEMENTS FOR SIGMA MESH
          INTEGER, POINTER :: NELEB
C
C         NELEBX: MAXIMUM NELEB
          INTEGER, POINTER :: NELEBX
C
C         NSEG: NUMBER OF SEGMENTS IN THE MESH
          INTEGER, POINTER :: NSEG
C
C         DIM: DIMENSION OF DOMAIN (2 OR 3)
          INTEGER, POINTER :: DIM
C
C         TYPELM: TYPE OF ELEMENT (10 FOR TRIANGLES, 40 FOR PRISMS)
          INTEGER, POINTER :: TYPELM
C
C         NPOIN: NUMBER OF VERTICES (OR LINEAR NODES) IN THE MESH
          INTEGER, POINTER :: NPOIN
C
C         NPMAX: MAXIMUM NUMBER OF VERTICES IN THE MESH
          INTEGER, POINTER :: NPMAX
C
C         MXPTVS: MAXIMUM NUMBER OF POINTS ADJACENT TO 1 POINT
          INTEGER, POINTER :: MXPTVS
C
C         MXELVS: MAXIMUM NUMBER OF ELEMENTS ADJACENT TO 1 POINT
          INTEGER, POINTER :: MXELVS
C
C         LV: MAXIMUM VECTOR LENGTH ALLOWED ON VECTOR COMPUTERS,
C             DUE TO ELEMENT NUMBERING
          INTEGER, POINTER :: LV
C
C
C         3) A SERIES OF BIEF_OBJ TO STORE INTEGER ARRAYS
C
C         IKLE: CONNECTIVITY TABLE IKLE(NELMAX,NDP) AND KLEI(NDP,NELMAX)
          TYPE(BIEF_OBJ), POINTER :: IKLE,KLEI
C
C         IFABOR: TABLE GIVING ELEMENTS BEHIND FACES OF A TRIANGLE
          TYPE(BIEF_OBJ), POINTER :: IFABOR
C
C         NELBOR: ELEMENTS OF THE BOUNDARY
          TYPE(BIEF_OBJ), POINTER :: NELBOR
C
C         NULONE: LOCAL NUMBER OF BOUNDARY POINTS FOR BOUNDARY ELEMENTS
          TYPE(BIEF_OBJ), POINTER :: NULONE
C
C         KP1BOR: POINTS FOLLOWING AND PRECEDING A BOUNDARY POINT
          TYPE(BIEF_OBJ), POINTER :: KP1BOR
C
C         NBOR: GLOBAL NUMBER OF BOUNDARY POINTS
          TYPE(BIEF_OBJ), POINTER :: NBOR
C
C         IKLBOR: CONNECTIVITY TABLE FOR BOUNDARY POINTS
          TYPE(BIEF_OBJ), POINTER :: IKLBOR
C
C         IFANUM: FOR STORAGE 2, NUMBER OF SEGMENT IN ADJACENT ELEMENT
C         OF A TRIANGLE
          TYPE(BIEF_OBJ), POINTER :: IFANUM
C
C         IKLEM1: ADRESSES OF NEIGHBOURS OF POINTS FOR FRONTAL
C         MATRIX-VECTOR PRODUCT
          TYPE(BIEF_OBJ), POINTER :: IKLEM1
C
C         LIMVOI: FOR FRONTAL MATRIX-VECTOR PRODUCT, ADDRESSES OF POINTS
C         WITH A GIVEN NUMBER OF NEIGHBOURS
          TYPE(BIEF_OBJ), POINTER :: LIMVOI
C
C         NUBO: FOR FINITE VOLUMES, GLOBAL NUMBERS OF VERTICES OF SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: NUBO
C
C         FOR SEGMENT-BASED STORAGE
C
C         GLOSEG: GLOBAL NUMBERS OF VERTICES OF SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: GLOSEG
C         ELTSEG: SEGMENTS FORMING AN ELEMENT
          TYPE(BIEF_OBJ), POINTER :: ELTSEG
C         ORISEG: ORIENTATION OF SEGMENTS FORMING AN ELEMENT 1:ANTI 2:CLOCKWISE
          TYPE(BIEF_OBJ), POINTER :: ORISEG
C
C         SERIES OF ARRAYS FOR PARALLEL MODE
C         HERE GLOBAL MEANS NUMBER IN THE WHOLE DOMAIN
C              LOCAL  MEANS NUMBER IN THE SUB-DOMAIN
C
C         KNOLG: GIVES THE INITIAL GLOBAL NUMBER OF A LOCAL POINT
          TYPE(BIEF_OBJ), POINTER :: KNOLG
C         NACHB: NUMBERS OF PROCESSORS CONTAINING A GIVEN POINT
          TYPE(BIEF_OBJ), POINTER :: NACHB
C         ISEG: GLOBAL NUMBER OF FOLLOWING OR PRECEDING POINT IN THE BOUNDARY
C         IF IT IS IN ANOTHER SUB-DOMAIN.
          TYPE(BIEF_OBJ), POINTER :: ISEG
C         KNOGL: INVERSE OF KNOLG, KNOGL(KNOLG(I))=I
C         LOCAL NUMBER OF A POINT WITH GIVEN GLOBAL NUMBER
          TYPE(BIEF_OBJ), POINTER :: KNOGL
C         ADDRESSES IN ARRAYS SENT BETWEEN PROCESSORS
          TYPE(BIEF_OBJ), POINTER :: INDPU
C
C         DIMENSION NHP(NBMAXNSHARE,NPTIR)
C         NHP(IZH,IR) IS THE GLOBAL NUMBER IN THE SUB-DOMAIN OF A POINT
C         WHOSE NUMBER IS IR IN THE INTERFACE WITH THE IZ-TH HIGHER RANK PROCESSOR
          TYPE(BIEF_OBJ), POINTER :: NHP
C         NHM IS LIKE NHP, BUT WITH LOWER RANK PROCESSORS
          TYPE(BIEF_OBJ), POINTER :: NHM
C
C         FOR FINITE VOLUMES AND KINETIC SCHEMES
          TYPE(BIEF_OBJ), POINTER :: JMI
C         ELEMENTAL HALO NEIGHBOURHOOD DESCRIPTION IN PARALLEL
C         IFAPAR(6,NELEM2)
C         IFAPAR(1:3,IELEM): PROCESSOR NUMBERS BEHIND THE 3 ELEMENT EDGES
C                            NUMBER FROM 0 TO NCSIZE-1
C         IFAPAR(4:6,IELEM): -LOCAL- ELEMENT NUMBERS BEHIND THE 3 EDGES
C                            IN THE NUMBERING OF PARTITIONS THEY BELONG TO
          TYPE(BIEF_OBJ), POINTER :: IFAPAR
C
C         4) A SERIES OF BIEF_OBJ TO STORE REAL ARRAYS
C
C         XEL: COORDINATES X PER ELEMENT
          TYPE(BIEF_OBJ), POINTER :: XEL
C
C         YEL: COORDINATES Y PER ELEMENT
          TYPE(BIEF_OBJ), POINTER :: YEL
C
C         ZEL: COORDINATES Z PER ELEMENT
          TYPE(BIEF_OBJ), POINTER :: ZEL
C
C         SURFAC: AREAS OF ELEMENTS (IN 2D)
          TYPE(BIEF_OBJ), POINTER :: SURFAC
C
C         SURDET: 1/DET OF ISOPARAMETRIC TRANSFORMATION
          TYPE(BIEF_OBJ), POINTER :: SURDET
C
C         LGSEG: LENGTH OF 2D BOUNDARY SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: LGSEG
C
C         XSGBOR: NORMAL X TO 1D BOUNDARY SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: XSGBOR
C
C         YSGBOR: NORMAL Y TO 1D BOUNDARY SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: YSGBOR
C
C         ZSGBOR: NORMAL Z TO 1D BOUNDARY SEGMENTS
          TYPE(BIEF_OBJ), POINTER :: ZSGBOR
C
C         XNEBOR: NORMAL X TO 1D BOUNDARY POINTS
          TYPE(BIEF_OBJ), POINTER :: XNEBOR
C
C         YNEBOR: NORMAL Y TO 1D BOUNDARY POINTS
          TYPE(BIEF_OBJ), POINTER :: YNEBOR
C
C         ZNEBOR: NORMAL Z TO 1D BOUNDARY POINTS
          TYPE(BIEF_OBJ), POINTER :: ZNEBOR
C
C         X: COORDINATES OF POINTS
          TYPE(BIEF_OBJ), POINTER :: X
C
C         Y: COORDINATES OF POINTS
          TYPE(BIEF_OBJ), POINTER :: Y
C
C         Z: COORDINATES OF POINTS
          TYPE(BIEF_OBJ), POINTER :: Z
C
C         COSLAT: LATITUDE COSINE
          TYPE(BIEF_OBJ), POINTER :: COSLAT
C
C         SINLAT: LATITUDE SINE
          TYPE(BIEF_OBJ), POINTER :: SINLAT
C
C         DISBOR: DISTANCE TO 1D BOUNDARIES
          TYPE(BIEF_OBJ), POINTER :: DISBOR
C
C         M: WORKING MATRIX
          TYPE(BIEF_OBJ), POINTER :: M
C
C         MSEG: WORKING MATRIX FOR SEGMENT-BASED STORAGE
          TYPE(BIEF_OBJ), POINTER :: MSEG
C
C         W: WORKING ARRAY FOR A NON-ASSEMBLED VECTOR
          TYPE(BIEF_OBJ), POINTER :: W
C
C         T: WORKING ARRAY FOR AN ASSEMBLED VECTOR
          TYPE(BIEF_OBJ), POINTER :: T
C
C         VNOIN: FOR FINITE VOLUMES
          TYPE(BIEF_OBJ), POINTER :: VNOIN
C
C         XSEG: X COORDINATE OF FOLLOWING OR PRECEDING POINT IN THE BOUNDARY
C         IF IT IS IN ANOTHER SUB-DOMAIN
          TYPE(BIEF_OBJ), POINTER :: XSEG
C
C         YSEG: Y COORDINATE OF FOLLOWING OR PRECEDING POINT IN THE BOUNDARY
C         IF IT IS IN ANOTHER SUB-DOMAIN
          TYPE(BIEF_OBJ), POINTER :: YSEG
C
C         FAC: MULTIPLICATION FACTOR FOR POINTS IN THE BOUNDARY FOR
C              DOT PRODUCT. FAC=1/(NUMBER OF SUBDOMAINS WITH THIS POINT)
          TYPE(BIEF_OBJ), POINTER :: FAC
C
C         FOR PARALLEL MODE AND NON BLOCKING COMMUNICATION (SEE PARINI.F)
C
C         NUMBER OF NEIGHBOURING PROCESSORS (SEEN BY POINTS)
          INTEGER       , POINTER :: NB_NEIGHB
C         FOR ANY NEIGHBOURING PROCESSOR, NUMBER OF POINTS
C         SHARED WITH IT
          TYPE(BIEF_OBJ), POINTER :: NB_NEIGHB_PT
C         RANK OF PROCESSORS WITH WHICH TO COMMUNICATE FOR POINTS
          TYPE(BIEF_OBJ), POINTER :: LIST_SEND
C         NH_COM(DIM1NHCOM,NB_NEIGHB)
C         WHERE DIM1NHCOM IS THE MAXIMUM NUMBER OF POINTS SHARED
C         WITH ANOTHER PROCESSOR (OR SLIGHTLY MORE FOR 16 BYTES ALIGNMENT)
C         NH_COM(I,J) IS THE GLOBAL NUMBER IN THE SUB-DOMAIN OF I-TH
C         POINT SHARED WITH J-TH NEIGHBOURING PROCESSOR
          TYPE(BIEF_OBJ), POINTER :: NH_COM
C
C         NUMBER OF NEIGHBOURING PROCESSORS (SEEN BY EDGES)
          INTEGER       , POINTER :: NB_NEIGHB_SEG
C         FOR ANY NEIGHBOURING PROCESSOR, NUMBER OF EDGES
C         SHARED WITH IT
          TYPE(BIEF_OBJ), POINTER :: NB_NEIGHB_PT_SEG
C         RANK OF PROCESSORS WITH WHICH TO COMMUNICATE FOR EDGES
          TYPE(BIEF_OBJ), POINTER :: LIST_SEND_SEG
C         LIKE NH_COM BUT FOR EDGES
          TYPE(BIEF_OBJ), POINTER :: NH_COM_SEG
C
C         WILL BE USED AS BUFFER BY MPI IN PARALLEL
C
          TYPE(BIEF_OBJ), POINTER :: BUF_SEND
          TYPE(BIEF_OBJ), POINTER :: BUF_RECV
C
C         FOR FINITE VOLUMES AND KINETIC SCHEMES
C
          TYPE(BIEF_OBJ), POINTER :: CMI,DPX,DPY
          TYPE(BIEF_OBJ), POINTER :: DTHAUT,AIRST
C
        END TYPE BIEF_MESH
C
C=======================================================================
C
C  STRUCTURE OF SOLVER CONFIGURATION
C
C=======================================================================
C
        TYPE SLVCFG
C
C         SLV: CHOICE OF SOLVER
          INTEGER SLV
C
C         NITMAX: MAXIMUM NUMBER OF ITERATIONS
          INTEGER NITMAX
C
C         PRECON: TYPE OF PRECONDITIONING
          INTEGER PRECON
C
C         KRYLOV: DIMENSION OF KRYLOV SPACE FOR GMRES SOLVER
          INTEGER KRYLOV
C
C         EPS: ACCURACY
          DOUBLE PRECISION EPS
C
C         ZERO: TO CHECK DIVISIONS BY ZERO
          DOUBLE PRECISION ZERO
C
C         OK: IF PRECISION EPS HAS BEEN REACHED
          LOGICAL OK
C
C         NIT: NUMBER OF ITERATIONS IF PRECISION REACHED
          INTEGER NIT
C
        END TYPE SLVCFG
C
C=======================================================================
C
C  STRUCTURE OF FILE
C
C=======================================================================
C
        TYPE BIEF_FILE
C
C         LU: LOGICAL UNIT TO OPEN THE FILE
          INTEGER LU
C
C         NAME: NAME OF FILE
          CHARACTER(LEN=144) NAME
C
C         TELNAME: NAME OF FILE IN TEMPORARY DIRECTORY
          CHARACTER(LEN=6) TELNAME
C
C         FMT: FORMAT (SERAFIN, MED, ETC.)
          CHARACTER(LEN=8) FMT
C
C         ACTION: READ, WRITE OR READWRITE
          CHARACTER(LEN=9) ACTION
C
C         BINASC: ASC FOR ASCII OR BIN FOR BINARY
          CHARACTER(LEN=3) BINASC
C
C         TYPE: KIND OF FILE
          CHARACTER(LEN=12) TYPE
C
        END TYPE BIEF_FILE
C
C=======================================================================
C
C  STRUCTURE OF CONTROL SECTION
C
C  ADDED BY JACEK JANKOWSKI, BAW KARLSRUHE,
C  USED BY TELEMAC-2D AND SISYPHE
C
C=======================================================================
C
      TYPE CHAIN_TYPE
        INTEGER :: NPAIR(2)
        DOUBLE PRECISION :: XYBEG(2), XYEND(2)
        CHARACTER(LEN=24) :: DESCR
        INTEGER :: NSEG
        INTEGER, POINTER :: LISTE(:,:)
      END TYPE
C
C=======================================================================
C
      END MODULE BIEF_DEF

C
C#######################################################################
C