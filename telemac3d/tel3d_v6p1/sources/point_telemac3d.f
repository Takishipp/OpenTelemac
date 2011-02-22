
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       ALLOCATES TELEMAC3D STRUCTURES.

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
!> </td><td> 19/10/2009
!> </td><td> J-M HERVOUET (LNHE)
!> </td><td>
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> **/03/1999
!> </td><td> JACEK A. JANKOWSKI PINXIT
!> </td><td> FORTRAN95 VERSION
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        SUBROUTINE POINT_TELEMAC3D
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE BIEF
      USE DECLARATIONS_TELEMAC
      USE DECLARATIONS_TELEMAC3D
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!-----------------------------------------------------------------------
!
      INTEGER CFG(2),CFG2D(2),CFGMURD(2),CFGBOR2D(2),CFGMURD_TF(2)
      INTEGER ITRAC, ITAB
      INTEGER IELM, IELV, IELH, STATUT
      INTEGER NTR,I,NSEG
      CHARACTER(LEN=1) TYPDIA, TYPEXT
!
!-----------------------------------------------------------------------
!
      IF(LISTIN) THEN
        IF(LNG.EQ.1) WRITE(LU,20)
        IF(LNG.EQ.2) WRITE(LU,21)
      ENDIF
 20   FORMAT(1X,/,1X,'POINT_TELEMAC3D: ALLOCATION DE LA MEMOIRE',/)
 21   FORMAT(1X,/,1X,'POINT_TELEMAC3D: MEMORY ALLOCATION',/)
!
!-----------------------------------------------------------------------
C DECLARES DISCRETISATION TYPES HERE

      IELM0 = 10*(IELMH/10) ! FOR TELEMAC2D
      IELM1 = IELM0 + 1     ! FOR TELEMAC2D
!
C TELEMAC3D DISCRETISATION TYPES: 3D, 2D HORIZONTAL BOUNDARY,
C 2D VERTICAL BOUNDARY
!
      IF(ELEMENT(1:5).EQ.'PRISM') THEN
!
        IELM3  = 41     ! TELEMAC3D PRISMS
        IELM2H = 11     ! TRIANGULAR BOTTOM AND SURFACE
        IELM2V = 71     ! QUADRILATERAL LATERAL BOUNDARIES
!
      ELSEIF(ELEMENT(1:5).EQ.'TETRA') THEN
!
        IELM3  = 51     ! PRISMS CUT INTO TETRAHEDRONS
        IELM2H = 11     ! TRIANGULAR BOTTOM AND SURFACE
        IELM2V = 61     ! TRIANGULAR LATERAL BOUNDARIES
!
      ELSE
        IF(LNG.EQ.1) WRITE(LU,*) 'ELEMENT INCONNU : ',ELEMENT
        IF(LNG.EQ.2) WRITE(LU,*) 'UNKNOWN ELEMENT: ',ELEMENT
        CALL PLANTE(1)
        STOP
      ENDIF
!
      IELM1  = IELBOR(IELMH,1) ! BOUNDARY DISCRET. FOR TELEMAC2D
!
C IELMU IS 12, WHEN QUASI-BUBBLE FREE SURFACE REQUIRED (IN LECDON)
C IF NOT, IELMU=IELMH
!
      IELMX=MAX(IELMU,IELM2H,IELM1,IELMH) ! IT WILL BE MAX. DISCR. IN 2D
!
C STORAGE TYPE AND MATRIX-VECTOR PRODUCT TYPE
!
      CFG(1) = OPTASS
      CFG(2) = PRODUC   ! PRODUC=1 HARD IN LECDON
      CFG2D(1) = OPTASS2D
      CFG2D(2) = PRODUC   ! PRODUC=1 HARD IN LECDON
C     MURD MATRIX WITH EDGE-BASED STORAGE FOR TIDAL FLATS
      CFGMURD_TF(1)=3
      CFGMURD_TF(2)=1
C     NORMAL MURD MATRIX WITH EBE STORAGE
      CFGMURD(1)=1
      CFGMURD(2)=1
!
      CFGBOR2D(1)=1
      CFGBOR2D(2)=1
!
!=======================================================================
!
!                     *********************
C                     *  MESH - GEOMETRY  *
!                     *********************
!
C TWO MESHES ARE ALLOCATED: (1) 2D BASE MESH, (2) 3D SIGMA-MESH
!
C ALLOCATES THE 2D MESH STRUCTURE FOR TELEMAC2D
C DISCRETISATION IELMH GIVEN IN LECDON
C IELMX = IELMU IF QUASI-BUBBLE ELEMENT REQUIRED, OTHERWISE IELMH
!
      EQUA = 'NO_EQUATION_IS_GIVEN'
!
      CALL ALMESH(MESH2D,'MESH2D',IELMX,SPHERI,CFG2D,
     &            T3D_FILES(T3DGEO)%LU,EQUA,NPLAN=1)
      NSEG=MESH2D%NSEG
!
C ALIASES FOR CERTAIN COMPONENTS OF THE 2D MESH STRUCTURE
!
      X2      => MESH2D%X
      Y2      => MESH2D%Y
      Z2      => MESH2D%Z
      SURFA2  => MESH2D%SURFAC
      XNEBOR2 => MESH2D%XNEBOR
      YNEBOR2 => MESH2D%YNEBOR
      XSGBOR2 => MESH2D%XSGBOR
      YSGBOR2 => MESH2D%YSGBOR
      IKLE2   => MESH2D%IKLE
      NBOR2   => MESH2D%NBOR   ! PREVIOUSLY SIMPLY NBOR
!
      MTRA2D  => MESH2D%M      ! USED ONLY IN PROPAG IN A HIDDEN WAY !
      W2      => MESH2D%W
!
      NELEM2  => MESH2D%NELEM
      NELMAX2 => MESH2D%NELMAX  ! PREVIOUSLY NELMA2 (ADAPTIVITY OUTLOOK)
      NPTFR2  => MESH2D%NPTFR   ! PREVIOUSLY SIMPLY NPTFR
      NPTFRX2 => MESH2D%NPTFRX
      DIM2    => MESH2D%DIM
      TYPELM2 => MESH2D%TYPELM
      NPOIN2  => MESH2D%NPOIN
      NPMAX2  => MESH2D%NPMAX
      MXPTVS2 => MESH2D%MXPTVS
      MXELVS2 => MESH2D%MXELVS
      LV      => MESH2D%LV      ! MESH-CHECKED? 2D=3D FOR SIGMA MESH
!
!-----------------------------------------------------------------------
C ALLOCATES THE 3D MESH STRUCTURE (EQUA=EMPTY) (READ AGAIN?)
!
      EQUA = 'NO_EQUATION_IS_GIVEN'
!
      CALL ALMESH(MESH3D,'MESH3D',IELM3,SPHERI,CFG,T3D_FILES(T3DGEO)%LU,
     &            EQUA,NPLAN=NPLAN)
!
C ALIAS FOR CERTAIN COMPONENTS OF THE 3D MESH STRUCTURE
C THEY ARE DEFINED IN DECLARATIONS
!
      X       => MESH3D%X%R
      Y       => MESH3D%Y%R
      Z       => MESH3D%Z%R
      X3      => MESH3D%X    ! POINTERS
      Y3      => MESH3D%Y
      Z3      => MESH3D%Z
      SURFA3  => MESH3D%SURFAC
      XSGBOR3 => MESH3D%XSGBOR
      YSGBOR3 => MESH3D%YSGBOR
      ZSGBOR3 => MESH3D%ZSGBOR
      IKLE3   => MESH3D%IKLE
      NBOR3   => MESH3D%NBOR
!
      W1      => MESH3D%W
!
      NELEM3  => MESH3D%NELEM
      NELMAX3 => MESH3D%NELMAX   ! PREVIOUSLY NELMA3 (ADAPTIVITY?)
      NELEB   => MESH3D%NELEB
      NELEBX  => MESH3D%NELEBX
      NPTFR3  => MESH3D%NPTFR
      NPTFRX3 => MESH3D%NPTFRX
      DIM3    => MESH3D%DIM
      TYPELM3 => MESH3D%TYPELM
      NPOIN3  => MESH3D%NPOIN
      NPMAX3  => MESH3D%NPMAX
      MXPTVS3 => MESH3D%MXPTVS
      MXELVS3 => MESH3D%MXELVS
!
!-----------------------------------------------------------------------
C VARIOUS MESH PARAMETER FIX
!
      NETAGE = NPLAN - 1
!     
!     NUMBER OF ADVECTED VARIABLES (3 FOR VELOCITY, 2 FOR K-EPSILON
!                                   THEN TRACERS)
      NVBIL  = 5 + NTRAC
!
      IF (LISTIN) THEN
        IF (LNG.EQ.1) WRITE(LU,31)
     &             TYPELM2,NPOIN2,NELEM2,NPTFR2,TYPELM3,NPOIN3,NELEM3,
     &             NPLAN,NELEB,NPTFR3+2*NPOIN2,NPTFR3,NPOIN2,NPOIN2
        IF (LNG.EQ.2) WRITE(LU,32)
     &             TYPELM2,NPOIN2,NELEM2,NPTFR2,TYPELM3,NPOIN3,NELEM3,
     &             NPLAN,NELEB,NPTFR3+2*NPOIN2,NPTFR3,NPOIN2,NPOIN2
      ENDIF
!
 31   FORMAT(/,' MAILLAGE 2D',/,
     &         ' -----------',//,
     &         ' 2D ELEMENT TYPE                : ',I8,/,
     &         ' NOMBRE DE POINTS 2D            : ',I8,/,
     &         ' NOMBRE D''ELEMENTS 2D           : ',I8,/,
     &         ' NOMBRE DE POINTS DE BORD 2D    : ',I8,///,
     &         ' MAILLAGE 3D',/,
     &         ' -----------',//,
     &         ' 3D ELEMENT TYPE                : ',I8,/,
     &         ' NOMBRE DE POINTS 3D            : ',I8,/,
     &         ' NOMBRE D''ELEMENTS 3D           : ',I8,/,
     &         ' NOMBRE DE PLANS                : ',I8,/,
     &         ' NOMBRE D''ELEMENTS DE BORD      : ',I8,/,
     &         ' NOMBRE TOTAL DE POINTS DE BORD : ',I8,/,
     &         ' DONT            COTES LATERAUX : ',I8,/,
     &         '                        SURFACE : ',I8,/,
     &         '                           FOND : ',I8,/)
!
 32   FORMAT(/,' 2D MESH',/,
     &         ' -------',//,
     &         ' 2D ELEMENT TYPE                : ',I8,/,
     &         ' NUMBER OF 2D NODES             : ',I8,/,
     &         ' NUMBER OF 2D ELEMENTS          : ',I8,/,
     &         ' NUMBER OF 2D BOUNDARY NODES    : ',I8,///,
     &         ' 3D MESH',/,
     &         ' -------',//,
     &         ' 3D ELEMENT TYPE                : ',I8,/,
     &         ' NUMBER OF 3D NODES             : ',I8,/,
     &         ' NUMBER OF 3D ELEMENTS          : ',I8,/,
     &         ' NUMBER OF LEVELS               : ',I8,/,
     &         ' NUMBER OF BOUNDARY ELEMENTS    : ',I8,/,
     &         ' TOTAL NUMBER OF BOUNDARY NODES : ',I8,/,
     &         ' INCLUDING   LATERAL BOUNDARIES : ',I8,/,
     &         '                        SURFACE : ',I8,/,
     &         '                         BOTTOM : ',I8,/)
!
!-----------------------------------------------------------------------
C FIELDS CONNECTED STRONGLY WITH GEOMETRY AND MESH
C REAL
!
      CALL BIEF_ALLVEC(1, ZPROP,  'ZPROP ', IELM3 , 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, ZT   ,  'ZT    ', IELM3 , 1, 1,MESH3D)
!
      CALL ALLBLO(GRADZF, 'GRADZF')
!     23/11/2010 NOW GRADZF CONTAINS GRADIENTS OF ALL PLANES
      CALL BIEF_ALLVEC_IN_BLOCK(GRADZF,2,1,'GRAZF ',IELM3 ,1,1,MESH3D)
!
      CALL ALLBLO(GRADZS, 'GRADZS')
      CALL BIEF_ALLVEC_IN_BLOCK(GRADZS,2,1,'GRAZS ',IELM2H,1,1,MESH2D)
      CALL ALLBLO(GRADZN, 'GRADZN')
      CALL BIEF_ALLVEC_IN_BLOCK(GRADZN,2,1,'GRAZN ',IELM2H,1,1,MESH2D)
!
      CALL BIEF_ALLVEC(1, DSSUDT, 'DSSUDT', IELM2H, 1, 1,MESH2D)
!
C     DESCRIBES THE MESH ON THE VERTICAL
!
      CALL BIEF_ALLVEC(1, ZSTAR       , 'ZSTAR ' , NPLAN ,1,0,MESH3D)
      CALL BIEF_ALLVEC(1, ZPLANE      , 'ZPLANE' , NPLAN ,1,0,MESH3D)
      CALL BIEF_ALLVEC(1, ZCHAR       , 'ZCHAR ' , NPLAN ,1,0,MESH3D)
      CALL BIEF_ALLVEC(2, TRANSF_PLANE, 'TRAPLA' , NPLAN ,1,0,MESH3D)
!
C MESH AND GEOMETRY, INTEGERS
!
      CALL BIEF_ALLVEC(2, LIHBOR, 'LIHBOR',         IELM1,1,1,MESH2D)
      CALL BIEF_ALLVEC(2, NUMLIQ, 'NUMLIQ',        IELM2V,1,1,MESH3D)
      CALL BIEF_ALLVEC(2, BOUNDARY_COLOUR ,'BNDCOL',IELM1,1,1,MESH2D)
      CALL BIEF_ALLVEC(2, LIMPRO, 'LIMPRO',         IELM1,6,1,MESH2D)
!
!-----------------------------------------------------------------------
!
C  BLOCK OF BOUNDARY CONDITIONS MASKS FOR PROPAGATION
C
C  BLOCK OF 9 VECTORS FOR MASKING (USED BY T2D)
!
      CALL ALLBLO(MASK, 'MASK  ')
      CALL BIEF_ALLVEC_IN_BLOCK(MASK,9,1,'MASK  ',IELM1,1,1,MESH2D)
!
C MASKING
C JMH : I USE MASKEL IN VELRES
!
      IF (MSK.OR.(OPTBAN.EQ.1.AND.NONHYD)) THEN
        CALL BIEF_ALLVEC(1, MASKEL, 'MASKEL',10*(IELM3/10),1,1,MESH3D)
        CALL BIEF_ALLVEC(1, MASKPT, 'MASKPT', IELM3,       1,1,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1, MASKEL, 'MASKEL', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, MASKPT, 'MASKPT', 0, 1, 0,MESH3D)
      ENDIF
!
!     A NEW MASK FOR LATERAL BOUNDARY ELEMENTS...
!
      CALL BIEF_ALLVEC(1, MASKBR, 'MASKBR',10*(IELM2V/10), 1, 1,MESH3D)
!
!=======================================================================
!                     ********************
C                     *    VARIABLES     *
!                     ********************
!
!-----------------------------------------------------------------------
C HORIZONTAL VELOCITY (U,V)
!
C U AND V VELOCITY COMPONENTS
!
      CALL BIEF_ALLVEC(1, UN,       'UN    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, VN,       'VN    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, UC,       'UC    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, VC,       'VC    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, UD,       'UD    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, VD,       'VD    ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, U,        'U     ',IELM3,  1,2,MESH3D)
      CALL BIEF_ALLVEC(1, V,        'V     ',IELM3,  1,2,MESH3D)
      CALL BIEF_ALLVEC(1, S0U,      'S0U   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, S0V,      'S0V   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, S1U,      'S1U   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, S1V,      'S1V   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, SMU,      'SMU   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, SMV,      'SMV   ',IELM3,  1,1,MESH3D)
      CALL BIEF_ALLVEC(1, UBORF,    'UBORF ',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, VBORF,    'VBORF ',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, UBORL,    'UBORL ',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, VBORL,    'VBORL ',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, UBORS,    'UBORS ',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, VBORS,    'VBORS ',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, AUBORF,   'AUBORF',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, AVBORF,   'AVBORF',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, AUBORL,   'AUBORL',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, UETCAL,   'UETCAL',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, AVBORL,   'AVBORL',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, AUBORS,   'AUBORS',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, AVBORS,   'AVBORS',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, BUBORF,   'BUBORF',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, BUBORL,   'BUBORL',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, BUBORS,   'BUBORS',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, BVBORF,   'BVBORF',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, BVBORL,   'BVBORL',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, BVBORS,   'BVBORS',IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(1, UBORSAVE, 'UBSAVE',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, VBORSAVE, 'VBSAVE',IELM2V, 1,1,MESH3D)
      CALL BIEF_ALLVEC(1, WBORSAVE, 'WBSAVE',IELM2V, 1,1,MESH3D)
!
C FRICTION VELOCITY **2 ON THE BOTTOM
!
      CALL BIEF_ALLVEC(1, UETCAR, 'UETCAR', IELM2H, 1,1,MESH2D)
!
C PLANE ON THE BOTTOM (THE FIRST ONE WITH A REAL ELEMENT HEIGHT ABOVE)
!
      CALL BIEF_ALLVEC(2, IPBOT,  'IPBOT ', IELM2H, 1,1,MESH2D)
!
C BOUNDARY CONDITION TYPES/
C ATTRIBUTES FOR THE HORIZONTAL VELOCITY COMPONENTS
!
      CALL BIEF_ALLVEC(2, LIUBOF,     'LIUBOF', IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(2, LIUBOL,     'LIUBOL', IELM2V, 2,1,MESH3D)
      CALL BIEF_ALLVEC(2, LIUBOS,     'LIUBOS', IELM2H, 1,1,MESH2D)
!
      CALL BIEF_ALLVEC(2, LIVBOF,     'LIVBOF', IELM2H, 1,1,MESH2D)
      CALL BIEF_ALLVEC(2, LIVBOL,     'LIVBOL', IELM2V, 2,1,MESH3D)
      CALL BIEF_ALLVEC(2, LIVBOS,     'LIVBOS', IELM2H, 1,1,MESH2D)
!
!-----------------------------------------------------------------------
C W VERTICAL VELOCITY COMPONENT (REAL VALUES)
C TREATED DIFFERENTLY DEPENDING ON THE (NON)HYDROSTATIC OPTION
!
      IF (NONHYD) THEN
        CALL BIEF_ALLVEC(1, WN,     'WN    ', IELM3, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, WC,     'WC    ', IELM3, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, WD,     'WD    ', IELM3, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, WCONV , 'WCONV ', IELM3, 1, 1,MESH3D)
      ELSE ! DUMMIES
        CALL BIEF_ALLVEC(1, WN,     'WN    ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, WC,     'WC    ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, WD,     'WD    ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, WCONV , 'WCONV ', 0, 1, 0,MESH3D)
      ENDIF
      CALL BIEF_ALLVEC(1, W,      'W     ', IELM3,  1, 1,MESH3D)
      IF (NONHYD) THEN
        CALL BIEF_ALLVEC(1, S0W,    'S0W   ', IELM3,  1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, S1W,    'S1W   ', IELM3,  1, 1,MESH3D)
      ELSE ! DUMMIES
        CALL BIEF_ALLVEC(1, S0W,    'S0W   ', 0,  1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, S1W,    'S1W   ', 0,  1, 0,MESH3D)
      ENDIF
      CALL BIEF_ALLVEC(1, WBORF,  'WBORF ', IELM2H, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, WBORL,  'WBORL ', IELM2V, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, WBORS,  'WBORS ', IELM2H, 1, 1,MESH2D)
      IF (NONHYD) THEN
        CALL BIEF_ALLVEC(1, AWBORF, 'AWBORF', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, AWBORL, 'AWBORL', IELM2V, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, AWBORS, 'AWBORS', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, BWBORF, 'BWBORF', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, BWBORL, 'BWBORL', IELM2V, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, BWBORS, 'BWBORS', IELM2H, 1, 1,MESH2D)
      ELSE ! DUMMIES
        CALL BIEF_ALLVEC(1, AWBORF, 'AWBORF', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, AWBORL, 'AWBORL', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, AWBORS, 'AWBORS', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, BWBORF, 'BWBORF', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, BWBORL, 'BWBORL', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, BWBORS, 'BWBORS', 0, 1, 0,MESH2D)
      ENDIF
!
      CALL BIEF_ALLVEC(2, LIWBOF,    'LIWBOF', IELM2H, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(2, LIWBOL,    'LIWBOL', IELM2V, 2, 1,MESH3D)
      CALL BIEF_ALLVEC(2, LIWBOS,    'LIWBOS', IELM2H, 1, 1,MESH2D)
!
C SIGMA-TRANSFORMED VALUES / NO BLOCK
!
      CALL BIEF_ALLVEC(1, WS,        'WS    ', IELM3,  1, 1,MESH3D)
!
!=======================================================================
C HYDRODYNAMIC PRESSURE SPECIFIC FOR THE NON-HYDROSTATIC OPTION
!
      IF (NONHYD) THEN
        CALL BIEF_ALLVEC(1, DP,     'DP    ', IELM3,  1, 2,MESH3D)
        CALL BIEF_ALLVEC(1, DPN,    'DPN   ', IELM3,  1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, PH,     'PH    ', IELM3,  1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, PBORF,  'PBORF ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, PBORL,  'PBORL ', IELM2V, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(1, PBORS,  'PBORS ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(2, LIPBOF, 'LIPBOF', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(2, LIPBOL, 'LIPBOL', IELM2V, 1, 1,MESH3D)
        CALL BIEF_ALLVEC(2, LIPBOS, 'LIPBOS', IELM2H, 1, 1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC(1, DP,     'DP    ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, DPN,    'DPN   ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, PH,     'PH    ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, PBORF,  'PBORF ', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, PBORL,  'PBORL ', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(1, PBORS,  'PBORS ', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(2, LIPBOF, 'LIPBOF', 0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(2, LIPBOL, 'LIPBOL', 0, 1, 0,MESH3D)
        CALL BIEF_ALLVEC(2, LIPBOS, 'LIPBOS', 0, 1, 0,MESH2D)
      ENDIF
!
!=======================================================================
!
      CALL ALLBLO(TAN      ,'TAN   ')
      CALL ALLBLO(TAC      ,'TAC   ')
      CALL ALLBLO(TA       ,'TA    ')
      CALL ALLBLO(S0TA     ,'S0TA  ')
      CALL ALLBLO(S1TA     ,'S1TA  ')
      CALL ALLBLO(TABORF   ,'TABORF')
      CALL ALLBLO(TABORL   ,'TABORL')
      CALL ALLBLO(TABORS   ,'TABORS')
      CALL ALLBLO(ATABOF   ,'ATABOF')
      CALL ALLBLO(ATABOL   ,'ATABOL')
      CALL ALLBLO(ATABOS   ,'ATABOS')
      CALL ALLBLO(BTABOF   ,'BTABOF')
      CALL ALLBLO(BTABOL   ,'BTABOL')
      CALL ALLBLO(BTABOS   ,'BTABOS')
      CALL ALLBLO(LITABF   ,'LITABF')
      CALL ALLBLO(LITABL   ,'LITABL')
      CALL ALLBLO(LITABS   ,'LITABS')
      CALL ALLBLO(TRBORSAVE,'TBSAVE')
      CALL ALLBLO(TA_SCE   ,'TA_SCE')
!
      IF(NTRAC.NE.0) THEN
        IELM   = IELM3
        IELH   = IELM2H
        IELV   = IELM2V
        STATUT = 1
      ELSE
        IELM   = 0
        IELH   = 0
        IELV   = 0
        STATUT = 0
      ENDIF
!
C GENERIC NAMES SHORTENED IN ORDER TO PROVIDE THE AUTOMATIC
C NUMBERING MECHANISM!
!
C NOTE JMH : MAX(NTRAC,1) BELOW : TO HAVE AT LEAST ONE ARRAY, EVEN EMPTY
C                                 TO PUT IN THE CALL TO CONLIM
!
      CALL BIEF_ALLVEC_IN_BLOCK(TAN,    NTRAC,
     *                          1, 'TAN   ', IELM, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(TAC,    NTRAC,
     *                          1, 'TAC   ', IELM, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(TA,     NTRAC,
     *                          1, 'TA    ', IELM, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(S0TA,   NTRAC,
     *                          1, 'S0TA  ', IELM, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(S1TA,   NTRAC,
     *                          1, 'S1TA  ', IELM, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(TABORF, NTRAC,
     *                          1, 'TABF  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(TABORL, MAX(NTRAC,1) ,
     *                          1, 'TABL  ', IELV, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(TABORS, NTRAC,
     *                          1, 'TABS  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(ATABOF, NTRAC,
     *                          1, 'ATAF  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(ATABOL, MAX(NTRAC,1),
     *                          1, 'ATAL  ', IELV, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(ATABOS, NTRAC,
     *                          1, 'ATAS  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(BTABOF, NTRAC,
     *                          1, 'BTAF  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(BTABOL, MAX(NTRAC,1),
     *                          1, 'BTAL  ', IELV, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(BTABOS, NTRAC,
     *                          1, 'BTAS  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(LITABF, NTRAC,
     *                          2, 'LTAF  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(LITABL, MAX(NTRAC,1) ,
     *                          2, 'LTAL  ', IELV, 2, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(LITABS, NTRAC,
     *                          2, 'LTAS  ', IELH, 1, STATUT,MESH2D)
      CALL BIEF_ALLVEC_IN_BLOCK(TRBORSAVE,NTRAC,
     *                          1, 'TBSA  ', IELV, 1, STATUT,MESH3D)
      CALL BIEF_ALLVEC_IN_BLOCK(TA_SCE,NTRAC,
     *                          1, 'TSCE  ', NSCE, 1, 0     ,MESH3D)
!                                                     SIZE NSCE ALWAYS
!
!=======================================================================
C K-EPSILON MODEL
!
      IF(ITURBV.EQ.3.OR.ITURBV.EQ.7) THEN
        IELM   = IELM3
        IELH   = IELM2H
        IELV   = IELM2V
        STATUT = 1
      ELSE
        IELM   = 0
        IELH   = 0
        IELV   = 0
        STATUT = 0
      ENDIF
!
      CALL BIEF_ALLVEC(1, AKN,      'AKN   ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, AKC,      'AKC   ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, AK,       'AK    ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, S0AK,     'S0AK  ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, S1AK,     'S1AK  ',IELM,1, STATUT,MESH3D )
!
      CALL BIEF_ALLVEC(1, EPN,      'EPN   ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, EPC,      'EPC   ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, EP,       'EP    ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, S0EP,     'S0EP  ',IELM,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, S1EP,     'S1EP  ',IELM,1, STATUT,MESH3D )
!
      CALL BIEF_ALLVEC(1, KBORF,    'KBORF ',IELH,1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, KBORL,    'KBORL ',IELV,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, KBORSAVE, 'KBSAVE',IELV,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, KBORS,    'KBORS ',IELH,1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(1, EBORF,    'EBORF ',IELH,1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, EBORL,    'EBORL ',IELV,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, EBORSAVE, 'EBSAVE',IELV,1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, EBORS,    'EBORS ',IELH,1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(1, AKBORF, 'AKBORF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, AKBORL, 'AKBORL', IELV, 1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, AKBORS, 'AKBORS', IELH, 1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(1, AEBORF, 'AEBORF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, AEBORL, 'AEBORL', IELV, 1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, AEBORS, 'AEBORS', IELH, 1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(1, BKBORF, 'BKBORF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, BKBORL, 'BKBORL', IELV, 1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, BKBORS, 'BKBORS', IELH, 1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(1, BEBORF, 'BEBORF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(1, BEBORL, 'BEBORL', IELV, 1, STATUT,MESH3D )
      CALL BIEF_ALLVEC(1, BEBORS, 'BEBORS', IELH, 1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(2, LIKBOF, 'LIKBOF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(2, LIKBOL, 'LIKBOL', IELV, 2, STATUT,MESH3D )
      CALL BIEF_ALLVEC(2, LIKBOS, 'LIKBOS', IELH, 1, STATUT,MESH2D )
!
      CALL BIEF_ALLVEC(2, LIEBOF, 'LIEBOF', IELH, 1, STATUT,MESH2D )
      CALL BIEF_ALLVEC(2, LIEBOL, 'LIEBOL', IELV, 2, STATUT,MESH3D )
      CALL BIEF_ALLVEC(2, LIEBOS, 'LIEBOS', IELH, 1, STATUT,MESH2D )
!
!=======================================================================
!
!		      *******************
!                     * OTHER VARIABLES *
!		      *******************
!
C  VARIOUS VELOCITY COMPONENTS 3D, 2D, BOUNDARY CONDITION VALUES
!
      CALL BIEF_ALLVEC(1, U2D,        'U2D   ', IELMU,  1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, UN2D,       'UN2D  ', IELMU,  1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, FU,         'FU    ', IELMU,  1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, V2D,        'V2D   ', IELMU,  1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, VN2D,       'VN2D  ', IELMU,  1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, FV,         'FV    ', IELMU,  1, 1,MESH2D)
C     DIMENSION 2 : SEE IN LECLIM, USED IN BORD3D
      CALL BIEF_ALLVEC(1, UBOR2D,     'UBOR2D', IELM1, 2, 1,MESH2D)
      CALL BIEF_ALLVEC(1, VBOR2D,     'VBOR2D', IELM1, 2, 1,MESH2D)
!
      CALL BIEF_ALLVEC(1, FLBOR ,     'FLBOR ', IELM1, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, FLBLIM,     'FLBLIM', IELM1, 1, 1,MESH2D)
!
      CALL BIEF_ALLVEC(1, UCONV ,      'UCONV ', IELM3, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, VCONV ,      'VCONV ', IELM3, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, VCONVC,      'VCONVC', IELM3, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, UCONVC,      'UCONVC', IELM3, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, WSCONV,      'WSCONV', IELM3, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, DM1   ,      'DM1   ', IELM3, 1, 1,MESH3D)
!
!-----------------------------------------------------------------------
C WATER DEPTH AND VARIABLES DERIVED FROM IT,
C PRINCIPALLY T2D DISCRETISATION OF DEPTH IELMH = IELM2H
!
      CALL BIEF_ALLVEC(1, H,      'H     ', IELMH, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, HN,     'HN    ', IELMH, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, HPROP,  'HPROP ', IELMH, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, NUWAVE, 'NUWAVE', 10   , 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, HBOR,   'HBOR  ', IELM1, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, DH,     'DH    ', IELMH, 1, 2,MESH2D)
      CALL BIEF_ALLVEC(1, SMH,    'SMH   ', IELMH, 1, 1,MESH2D)
!
      IF(RAIN) THEN
        CALL BIEF_ALLVEC(1,PLUIE,'PLUIE ',IELMH,1,2,MESH2D)
        IF(NCSIZE.GT.1) THEN
          CALL BIEF_ALLVEC(1,PARAPLUIE,'PARAPL',IELMH,1,2,MESH2D)
        ELSE
          CALL BIEF_ALLVEC(1,PARAPLUIE,'PARAPL',0    ,1,0,MESH2D)
          PARAPLUIE%R=>PLUIE%R
        ENDIF
      ELSE
        CALL BIEF_ALLVEC(1,PLUIE    ,'PLUIE ',0    ,1,0,MESH2D)
        CALL BIEF_ALLVEC(1,PARAPLUIE,'PARAPL',0    ,1,0,MESH2D)
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(COUROU) THEN
        CALL BIEF_ALLVEC(1,FXH,'FXH   ',IELMU,1,1,MESH2D)
        CALL BIEF_ALLVEC(1,FYH,'FYH   ',IELMU,1,1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC(1,FXH,'FXH   ',0    ,1,0,MESH2D)
        CALL BIEF_ALLVEC(1,FYH,'FYH   ',0    ,1,0,MESH2D)
      ENDIF
!
!-----------------------------------------------------------------------
C NUMERICAL VARIABLES
!
      CALL BIEF_ALLVEC(1, VOLU  , 'VOLU  ', IELM3 , 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, VOLUN , 'VOLUN ', IELM3 , 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, VOLU3D, 'VOLU3D', IELM3 , 1, 1,MESH3D)
      IF(NCSIZE.GT.1) THEN
        CALL BIEF_ALLVEC(1,VOLUPAR,'VOLUPA',IELM3,1,1,MESH3D)
        CALL BIEF_ALLVEC(1,VOLUNPAR,'VLNPAR',IELM3,1,1,MESH3D)
        CALL BIEF_ALLVEC(1,VOLU3DPAR,'VLTDPA',IELM3,1,1,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1,VOLUPAR,'VOLUPA',0    ,1,0,MESH3D)
        VOLUPAR%R=>VOLU%R
        CALL BIEF_ALLVEC(1,VOLUNPAR,'VLNPAR',0    ,1,0,MESH3D)
        VOLUNPAR%R=>VOLUN%R
        CALL BIEF_ALLVEC(1,VOLU3DPAR,'VLTDPA',0    ,1,0,MESH3D)
        VOLU3DPAR%R=>VOLU3D%R
      ENDIF
      CALL BIEF_ALLVEC(1, VOLUT , 'VOLUT ', IELM3 , 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, VOLU2D, 'VOLU2D', IELM2H, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, V2DPAR, 'V2DPAR', IELM2H, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, UNSV2D, 'UNSV2D', IELM2H, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, UNSV3D, 'UNSV3D', IELM3 , 1, 1,MESH3D)
!
      CALL BIEF_ALLVEC(1, FLUINT,    'FLUINT', IELM3 , 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, FLUEXT,    'FLUEXT', IELM3 , 1, 1,MESH3D)
      IF(NCSIZE.GT.1) THEN
        CALL BIEF_ALLVEC(1,FLUEXTPAR,'FLXTPA',IELM3,1,1,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1,FLUEXTPAR,'FLXTPA',0    ,1,0,MESH3D)
        FLUEXTPAR%R=>FLUEXT%R
      ENDIF
      CALL BIEF_ALLVEC(1, FLINT2,    'FLINT2', IELM2H, 1, 1,MESH2D)
!
!-----------------------------------------------------------------------
C PHYSICAL VARIABLES
!
C (COMPONENTS OF VISCOSITY AS SEPARATE VECTORS ARE REQUIRED!)
!
      CALL ALLBLO(VISCVI, 'VISCVI')
      CALL BIEF_ALLVEC_IN_BLOCK(VISCVI,3,1,'VISC  ',IELM3,1,2,MESH3D)
!
C ADDRESSING IS AWKWARD, E.G. REAL PART OF THE DIFFUSIVITY STRUCTURE
C OF THE THIRD TRACER IN THE Y-DIRECTION IS VISCTA%ADR(3)%P%ADR(2)%P%R
C DEAR ME!
!
      CALL ALLBLO(VISCTA, 'VISCTA')
      IF(NTRAC.GT.0) THEN
        CALL ALLBLO_IN_BLOCK(VISCTA, NTRAC, 'VBTA  ')
        DO ITRAC = 1,NTRAC
          CALL BIEF_ALLVEC_IN_BLOCK ( VISCTA%ADR(ITRAC)%P, 3 , 1,
     &                              'VITA  ',IELM3,1,2,MESH3D)
        ENDDO
      ENDIF
!
      CALL BIEF_ALLVEC(1, ROTAT,  'ROTAT ', IELM3,  1, 1,MESH3D)
!
      CALL BIEF_ALLVEC(1, DELTAR, 'DELTAR', IELM3,  1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, RI,     'RI    ', IELM3,  1, 1,MESH3D)
!
      CALL BIEF_ALLVEC(1, RUGOF,  'RUGOF ', IELMU , 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1, RUGOL,  'RUGOL ', IELM2V, 1, 1,MESH3D)
      CALL BIEF_ALLVEC(1, CF   ,  'CF    ', IELMU , 1, 1,MESH2D)
!
      CALL ALLBLO(WIND, 'WIND  ')
      IF (VENT) THEN
        CALL BIEF_ALLVEC_IN_BLOCK(WIND, 2, 1,'WIND  ',IELM2H,1,1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC_IN_BLOCK(WIND, 2, 1,'WIND  ',0,1,0,MESH2D)
      ENDIF
!
      IF (ATMOS) THEN
        CALL BIEF_ALLVEC(1, PATMOS, 'PATMOS', IELM2H, 1, 1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC(1, PATMOS, 'PATMOS', 0,      1, 0,MESH2D)
      ENDIF
!
!-----------------------------------------------------------------------
!     VARIABLES USED IN MASS BALANCE 
!     THEY WILL CORRESPOND TO THE NUMBERING OF ADVECTED VARIABLES
!
      CALL BIEF_ALLVEC(1, MASINI, 'MASINI', NVBIL,1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, MASSE,  'MASSE ', NVBIL,1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, MASSEN, 'MASSEN', NVBIL,1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, FLUCUM, 'FLUCUM', NVBIL,1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, FLUX,   'FLUX  ', NVBIL,1, 0,MESH3D)
!
C BOTTOM AS GIVEN FROM THE GEOMETRY FILE
!
      CALL BIEF_ALLVEC(1, ZF, 'ZF    ', IELM2H, 1, 1,MESH2D)
!
C BOTTOM GEOMETRY PER 2D-ELEMENT FOR TIDAL FLATS TREATMENT
!
      IF(MSK) THEN
        CALL BIEF_ALLVEC(1, ZFE, 'ZFE   ', 10, 1, 1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC(1, ZFE, 'ZFE   ',  0, 1, 0,MESH2D)
      ENDIF
!
!-----------------------------------------------------------------------
C DROGUES (FLOATS ...EHM, TRACERS...)
!
      CALL BIEF_ALLVEC(1, XFLOT,  'XFLOT ', NFLOT*NITFLO,  1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, YFLOT,  'YFLOT ', NFLOT*NITFLO,  1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, ZFLOT,  'ZFLOT ', NFLOT*NITFLO,  1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, ZSFLOT, 'ZSFLOT', NFLOT*NITFLO,  1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, SHPFLO, 'SHPFLO', 3*NFLOT,       1, 0,MESH3D)
      CALL BIEF_ALLVEC(1, SHZFLO, 'SHZFLO', NFLOT,         1, 0,MESH3D)
!
      CALL BIEF_ALLVEC(2, DEBFLO, 'DEBFLO', NFLOT,         1, 0,MESH3D)
      CALL BIEF_ALLVEC(2, FINFLO, 'FINFLO', NFLOT,         1, 0,MESH3D)
      CALL BIEF_ALLVEC(2, ELTFLO, 'ELTFLO', NFLOT,         1, 0,MESH3D)
      CALL BIEF_ALLVEC(2, ETAFLO, 'ETAFLO', NFLOT,         1, 0,MESH3D)
      CALL BIEF_ALLVEC(2, IKLFLO, 'IKLFLO', 3*NFLOT*NITFLO,1, 0,MESH3D)
      CALL BIEF_ALLVEC(2, TRAFLO, 'TRAFLO', 3*NFLOT*NITFLO,1, 0,MESH3D)
!
!-----------------------------------------------------------------------
!
!     VALUES AT SOURCES OF ADVECTED VARIABLES U,V,W,AK AND EP
!     ALL ARE ALLOCATED, EVEN IF NOT USED
!
      CALL BIEF_ALLVEC(1,U_SCE ,'U_SCE ',NSCE,1,0,MESH3D)
      CALL BIEF_ALLVEC(1,V_SCE ,'V_SCE ',NSCE,1,0,MESH3D) 
      CALL BIEF_ALLVEC(1,W_SCE ,'W_SCE ',NSCE,1,0,MESH3D) 
      CALL BIEF_ALLVEC(1,AK_SCE,'AK_SCE',NSCE,1,0,MESH3D) 
      CALL BIEF_ALLVEC(1,EP_SCE,'EP_SCE',NSCE,1,0,MESH3D) 
!
!     COPYING USCE AND VSCE INTO U_SCE AND VSCE
!     PROVISIONNALY CANCELLING W_SCE, AK_SCE AND EP_SCE
!
      IF(NSCE.GT.0) THEN
        DO I=1,NSCE
          U_SCE%R(I) =USCE(I)
          V_SCE%R(I) =VSCE(I)
          W_SCE%R(I) =0.D0
          AK_SCE%R(I)=0.D0
          EP_SCE%R(I)=0.D0
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
! VARIOUS TABLES, AS W1, ITRAV3 , PRIVE
! W1 ALLOCATED BY ALMESH
!
      CALL ALLBLO (PRIVE,'PRIVE ')
      CALL BIEF_ALLVEC_IN_BLOCK(PRIVE,MAX(4,NPRIV),
     *                          1,'PRIV  ',IELM3,1,2,MESH3D)
!
! INTEGER WORK FIELDS
!
      CALL ALLBLO(ITRAV3,'ITRAV3')
      CALL BIEF_ALLVEC_IN_BLOCK(ITRAV3,4,2,'ITR3V ',IELM3,1,1,MESH3D)
!
! POINTERS TO 5 INTEGER WORK FIELDS
!
      IT1 => ITRAV3%ADR(1)%P
      IT2 => ITRAV3%ADR(2)%P
      IT3 => ITRAV3%ADR(3)%P
      IT4 => ITRAV3%ADR(4)%P
!
!     BLOCKS OF ADVECTED VARIABLES AND VARIOUS BIEF_OBJ STRUCTURES
!     BUILT FOR A COLLECTIVE ADVECTION
!
      CALL ALLBLO(BL_FC ,'BL_FC ')
      CALL ADDBLO(BL_FC,UC)
      CALL ADDBLO(BL_FC,VC)
      CALL ADDBLO(BL_FC,WC)
      CALL ADDBLO(BL_FC,AKC)
      CALL ADDBLO(BL_FC,EPC)
!
      CALL ALLBLO(BL_FN ,'BL_FN ')
!     ADVECTION OF VELOCITIES IS DONE FOR THE NEXT TIME-STEP
      CALL ADDBLO(BL_FN,U)
      CALL ADDBLO(BL_FN,V)
      CALL ADDBLO(BL_FN,W)
      CALL ADDBLO(BL_FN,AKN)
      CALL ADDBLO(BL_FN,EPN)
!
      CALL ALLBLO(BL_S0F,'BL_S0F')
      CALL ADDBLO(BL_S0F,S0U)
      CALL ADDBLO(BL_S0F,S0V)
      CALL ADDBLO(BL_S0F,S0W)
      CALL ADDBLO(BL_S0F,S0AK)
      CALL ADDBLO(BL_S0F,S0EP)
!
      CALL ALLBLO(BL_FSC,'BL_FSC')
      CALL ADDBLO(BL_FSC,U_SCE)
      CALL ADDBLO(BL_FSC,V_SCE)
      CALL ADDBLO(BL_FSC,W_SCE)
      CALL ADDBLO(BL_FSC,AK_SCE)
      CALL ADDBLO(BL_FSC,EP_SCE)
!
      CALL ALLBLO(BL_BOL,'BL_BOL')
      CALL ADDBLO(BL_BOL,LIUBOL)
      CALL ADDBLO(BL_BOL,LIVBOL)
      CALL ADDBLO(BL_BOL,LIWBOL)
      CALL ADDBLO(BL_BOL,LIKBOL)
      CALL ADDBLO(BL_BOL,LIEBOL)
!
      CALL ALLBLO(BL_BORL,'BL_BOR')
      CALL ADDBLO(BL_BORL,UBORL)
      CALL ADDBLO(BL_BORL,VBORL)
      CALL ADDBLO(BL_BORL,WBORL)
      CALL ADDBLO(BL_BORL,AKBORL)
      CALL ADDBLO(BL_BORL,EBORL)
!
      IF(NTRAC.GT.0) THEN
        DO ITRAC=1,NTRAC
          CALL ADDBLO(BL_FC ,    TAC%ADR(ITRAC)%P)
          CALL ADDBLO(BL_FN ,    TAN%ADR(ITRAC)%P)
          CALL ADDBLO(BL_S0F,   S0TA%ADR(ITRAC)%P)
          CALL ADDBLO(BL_FSC, TA_SCE%ADR(ITRAC)%P)
          CALL ADDBLO(BL_BOL, LITABL%ADR(ITRAC)%P)
          CALL ADDBLO(BL_BORL,TABORL%ADR(ITRAC)%P)
        ENDDO
      ENDIF
!      
!     BLOCKS OF ADVECTED VARIABLES WITH CHARACTERISTICS
!     MODULE STREAMLINE MUST BE CHANGED TO DEAL WITH A
!     LIST IN A BLOCK AS DONE ABOVE 
!     
      CALL ALLBLO(FC3D, 'FC3D  ')
      CALL ALLBLO(FN3D, 'FN3D  ')
!     ADVECTION OF VELOCITIES IS DONE FOR THE NEXT STEP
!     SO HERE U AND NOT UN
      IF(SCHCVI.EQ.ADV_CAR) THEN  
        CALL ADDBLO(FN3D,U )
        CALL ADDBLO(FC3D,UC)
        CALL ADDBLO(FN3D,V )
        CALL ADDBLO(FC3D,VC)
        IF(NONHYD) THEN
          CALL ADDBLO(FN3D,W )
          CALL ADDBLO(FC3D,WC)
        ENDIF
      ENDIF
      IF(SCHCKE.EQ.ADV_CAR.AND.(ITURBH.EQ.3.OR.
     *                          ITURBH.EQ.7.OR.
     *                          ITURBV.EQ.3.OR.
     *                          ITURBV.EQ.7)) THEN  
        CALL ADDBLO(FN3D,AKN)
        CALL ADDBLO(FC3D,AKC)
        CALL ADDBLO(FN3D,EPN)
        CALL ADDBLO(FC3D,EPC)
      ENDIF
      IF(NTRAC.GT.0) THEN
        DO ITRAC=1,NTRAC
          IF(SCHCTA(ITRAC).EQ.ADV_CAR) THEN  
            CALL ADDBLO(FN3D,TAN%ADR(ITRAC)%P)
            CALL ADDBLO(FC3D,TAC%ADR(ITRAC)%P)
          ENDIF 
        ENDDO
      ENDIF           
!
!=======================================================================
!
!                   *********************************
C                   * STRUCTURES FOR THE RESOLUTION *
C                   *  OF LINEAR EQUATION SYSTEMS   *
C                   *          F I R S T            *
C                   *        M A T R I C E S        *
!                   *********************************
!
C BEWARE : 2D AND ESPECIALLY 3D MATRICES OCCUPY
C ======   A LARGE CHUNK OF MEMORY
!
!-----------------------------------------------------------------------
C 3D MATRICES
!
C S.U.P.G.
!
      TYPDIA = '0'
      TYPEXT = '0'
      IF(N_ADV(ADV_SUP).GT.0) THEN
        TYPDIA = 'Q'
        TYPEXT = 'Q'
      ENDIF
      CALL BIEF_ALLMAT(MSUPG,'SUPG  ',
     *                 IELM3,IELM3,CFG,TYPDIA,TYPEXT,MESH3D)
!
C M.U.R.D.
!
      TYPDIA = '0'
      TYPEXT = '0'
      IF(N_ADV(ADV_NSC).GT.0.OR.N_ADV(ADV_PSI).GT.0) THEN
        TYPDIA = 'Q'
        TYPEXT = 'Q'
      ENDIF
      CALL BIEF_ALLMAT(MMURD,'MURD  ',
     *                 IELM3,IELM3,CFGMURD,TYPDIA,TYPEXT,MESH3D)
!
C M.U.R.D. (EDGE-BASED FOR TIDAL FLATS)
!
      TYPDIA = '0'
      TYPEXT = '0'
      IF(N_ADV(ADV_NSC_TF).GT.0) THEN
        TYPDIA = 'Q'
        TYPEXT = 'Q'
      ENDIF
      CALL BIEF_ALLMAT(MURD_TF,'MURDTF',IELM3,IELM3,CFGMURD_TF,
     &                 TYPDIA,TYPEXT,MESH3D)
!
C DIFFUSION
!
      TYPDIA = '0'
      IF (DIF(1) .OR. NONHYD) TYPDIA = 'Q'
      TYPEXT = '0'
      IF (DIF(1) .OR. NONHYD) TYPEXT = 'S'
      CALL BIEF_ALLMAT (MDIFF, 'DIFF  ',
     *                  IELM3, IELM3, CFG, TYPDIA, TYPEXT,MESH3D)
!
C THE 3D WORK MATRICES (ALWAYS ALLOCATED AS NON SYMMETRICAL)
C                       SEE USE OF MTRA2%X IN WAVE_EQUATION
!
      TYPDIA = 'Q'
      TYPEXT = 'Q'
      CALL BIEF_ALLMAT (MTRA2, 'MTRA2 ',
     *                  IELM3, IELM3, CFG, TYPDIA, TYPEXT,MESH3D)
      CALL BIEF_ALLMAT (MTRA1, 'MTRA1 ',
     *                  IELM3, IELM3, CFG, TYPDIA, TYPEXT,MESH3D)
!
!-----------------------------------------------------------------------
C 3 2D MATRICES (IELM2H) - (EACH OF THEM ALLOCATED IN A
C SEPARATE BLOCK), ALL IN BLOCK MAT2D 
C E.G. WORK MATRIX 3 IS: MAT2D%ADR(3)%P
C THEY ALL GET NAMED MAT2D...............
!
      CALL ALLBLO (MAT2D, 'MAT2D ')
      CALL ALLBLO_IN_BLOCK(MAT2D,3,'MAT2D ')
      DO ITAB = 1,3
        CALL BIEF_ALLMAT(MAT2D%ADR(ITAB)%P, 'MAT2D ',
     &                   IELMU, IELMU, CFG2D, 'Q', 'Q',MESH2D)
      END DO
!
C ANOTHER WORK MATRIX IS BUILT USING ALMESH FOR THE 2D MESH: MTRA2
!
C BOUNDARY MATRIX FOR 2D
!
      CALL BIEF_ALLMAT(MBOR2D, 'MBOR2D',
     *                 IELM1, IELM1, CFGBOR2D, 'Q','Q',MESH2D)
!
C 2D WORK MATRIX FOR IELMU.
!
      CALL BIEF_ALLMAT(MATR2H,'MATR2H',IELMU ,IELMU ,CFG,'Q','Q',MESH2D)
!
!=======================================================================
!
!                   *********************************
C                   * STRUCTURES FOR THE RESOLUTION *
C                   *  OF LINEAR EQUATION SYSTEMS   *
C                   *  S E C O N D   M E M B E R S  *
C                   *         V E C T O R S         *
!                   *********************************
!
!-----------------------------------------------------------------------
C FOR 3D PART
C COMPUTES THE NUMBER OF 3D WORK FIELDS AS A FUNCTION OF
C SOLVER AND PRECONDITIONING TYPE AND NUMBER OF VARIABLES
!
      NTR = 10
!
      IF(SLVDVI%SLV.EQ.7) NTR = MAX(NTR,2+2*SLVDVI%KRYLOV)
      IF(NTRAC.GT.0) THEN
        DO ITRAC=1,NTRAC
          IF(SLVDTA(ITRAC)%SLV.EQ.7) THEN
            NTR = MAX(NTR,2+2*SLVDTA(ITRAC)%KRYLOV)
          ENDIF
        ENDDO
      ENDIF
      IF (SLVDKE%SLV.EQ.7) NTR = MAX(NTR,2+2*SLVDKE%KRYLOV)
      IF (SLVDSE%SLV.EQ.7) NTR = MAX(NTR,2+2*SLVDSE%KRYLOV)
      IF (SLVPOI%SLV.EQ.7) NTR = MAX(NTR,2+2*SLVPOI%KRYLOV)
      IF (SLVPRJ%SLV.EQ.7) NTR = MAX(NTR,2+2*SLVPRJ%KRYLOV)
!
      I = NTR
!
      IF (3*(SLVDVI%PRECON/3).EQ.SLVDVI%PRECON .OR.
     &    3*(SLVDKE%PRECON/3).EQ.SLVDKE%PRECON .OR.
     &    3*(SLVDSE%PRECON/3).EQ.SLVDSE%PRECON .OR.
     &    3*(SLVPOI%PRECON/3).EQ.SLVPOI%PRECON) NTR = I+2
!
      IF(NTRAC.GT.0) THEN
        DO ITRAC=1,NTRAC
          IF(3*(SLVDTA(ITRAC)%PRECON/3).EQ.SLVDTA(1)%PRECON) NTR = I+2          
        ENDDO
      ENDIF
!
      IF (ITURBV.EQ.3) NTR = MAX(NTR,12)
      IF (ITURBV.EQ.7) NTR = MAX(NTR,18)
!     TRAV3 WILL BE USED IN BIEF_VALIDA WITH THIS SIZE
!     SEE ALIRE3D IN TELEMAC3D.F AND VARSO3 IN POINT_TELEMAC3D.F
      NTR = MAX(NTR,13+NTRAC)
!
      CALL ALLBLO(TRAV3, 'TRAV3 ')
      CALL BIEF_ALLVEC_IN_BLOCK(TRAV3,NTR,1,'TRAV  ',IELM3,1,2,MESH3D)
!
C POINTERS TO THESE 3D WORK VECTORS; FIRST 10 EXIST FOR SURE
!
      T3_01 => TRAV3%ADR(1)%P
      T3_02 => TRAV3%ADR(2)%P
      T3_03 => TRAV3%ADR(3)%P
      T3_04 => TRAV3%ADR(4)%P
      T3_05 => TRAV3%ADR(5)%P
      T3_06 => TRAV3%ADR(6)%P
      T3_07 => TRAV3%ADR(7)%P
      T3_08 => TRAV3%ADR(8)%P
      T3_09 => TRAV3%ADR(9)%P
      T3_10 => TRAV3%ADR(10)%P
      IF(NTR.GE.12) THEN
        T3_11 => TRAV3%ADR(11)%P
        T3_12 => TRAV3%ADR(12)%P
      ENDIF
      IF(NTR.GE.18) THEN
        T3_13 => TRAV3%ADR(13)%P
        T3_14 => TRAV3%ADR(14)%P
        T3_15 => TRAV3%ADR(15)%P
        T3_16 => TRAV3%ADR(16)%P
        T3_17 => TRAV3%ADR(17)%P
        T3_18 => TRAV3%ADR(18)%P
      ENDIF
!
C SECOND MEMBER 3D
!
      CALL BIEF_ALLVEC(1, SEM3D, 'SEM3D ', IELM3, 1, 2,MESH3D)
!
C RIGHT HAND SIDE OF CONTINUITY EQUATIONS IF SOURCES
!
      CALL ALLBLO(SOURCES, 'SOURCE')
      I=NSCE
      IF(NCSIZE.GT.1) I=2*NSCE
      IF(NSCE.GT.0) THEN
        CALL BIEF_ALLVEC_IN_BLOCK(SOURCES,I,1,'SCE   ',IELM3,1,1,MESH3D)
      ELSE
        CALL BIEF_ALLVEC_IN_BLOCK(SOURCES,I,1,'SCE   ',0    ,1,0,MESH3D)
      ENDIF
!
!-----------------------------------------------------------------------
C FOR 2D PART
!
C COMPUTES THE NUMBER OF 3D WORK FIELDS AS A FUNCTION OF
C SOLVER AND PRECONDITIONING TYPE AND NUMBER OF VARIABLES
C FIRST 21 ALLOCATED FOR SURE... (WOW!?)
!
      NTR = 21
      IF (SLVPRO%SLV.EQ.7) NTR = MAX(NTR,6+6*SLVPRO%KRYLOV)
      IF (SLVW%SLV.EQ.7)   NTR = MAX(NTR,2+2*SLVW%KRYLOV)
      IF (3*(SLVPRO%PRECON/3) .EQ. SLVPRO%PRECON .OR.
     &    3*(SLVW%PRECON/3)   .EQ. SLVW%PRECON ) NTR = NTR + 6
!
C     SEE VARSOR BELOW
      NTR=MAX(NTR,13+NTRAC)
!
      CALL ALLBLO(TRAV2, 'TRAV2 ')
      CALL BIEF_ALLVEC_IN_BLOCK(TRAV2,NTR,1,'TR2D  ',IELMU,1,2,MESH2D)
!
C POINTERS TO FIRST 10 2D WORK VECTORS (21 EXIST FOR SURE)
!
      T2_01 => TRAV2%ADR( 1)%P
      T2_02 => TRAV2%ADR( 2)%P
      T2_03 => TRAV2%ADR( 3)%P
      T2_04 => TRAV2%ADR( 4)%P
      T2_05 => TRAV2%ADR( 5)%P
      T2_06 => TRAV2%ADR( 6)%P
      T2_07 => TRAV2%ADR( 7)%P
      T2_08 => TRAV2%ADR( 8)%P
      T2_09 => TRAV2%ADR( 9)%P
      T2_10 => TRAV2%ADR(10)%P
      T2_11 => TRAV2%ADR(11)%P
      T2_12 => TRAV2%ADR(12)%P
      T2_13 => TRAV2%ADR(13)%P
      T2_14 => TRAV2%ADR(14)%P
      T2_15 => TRAV2%ADR(15)%P
      T2_16 => TRAV2%ADR(16)%P
      T2_17 => TRAV2%ADR(17)%P
      T2_18 => TRAV2%ADR(18)%P
      T2_19 => TRAV2%ADR(19)%P
      T2_20 => TRAV2%ADR(20)%P
      T2_21 => TRAV2%ADR(21)%P
!
C SECOND MEMBERS BLOCK - 3 NEEDED
!
      CALL ALLBLO (SEM2D,'SEM2D ')
      CALL BIEF_ALLVEC_IN_BLOCK(SEM2D,3,1,'SEM2D ',IELMU,1,2,MESH2D)
!
C WORK FIELDS WITH A DIMENSION OF THE MAX. 2D ELEMENT NUMBER
C IELM = 10
!
      CALL BIEF_ALLVEC(1,   TE1, 'TE1   ', 10, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1,   TE2, 'TE2   ', 10, 1, 1,MESH2D)
      CALL BIEF_ALLVEC(1,   TE3, 'TE3   ', 10, 1, 1,MESH2D)
!
C PIECE-WISE LINEAR FREE SURFACE
      CALL BIEF_ALLVEC(1,ZFLATS, 'ZFLATS', 10, 3, 1,MESH2D)
      CALL BIEF_ALLVEC(1,ZCONV , 'ZCONV ', 10, 3, 1,MESH2D)
      ZFLATS%DIMDISC=11
      ZCONV%DIMDISC =11
!
C DELWAQ FLOWS BETWEEN POINTS
      CALL BIEF_ALLVEC(1,FLODEL,'FLODEL',
     *                 NSEG*NPLAN+NETAGE*NPOIN2, 1, 0,MESH3D)
C     FULL SIZE OF FLOPAR PROBABLY NOT USEFUL IF NOT PARALLEL MODE
      CALL BIEF_ALLVEC(1,FLOPAR,'FLOPAR',
     *                 NSEG*NPLAN+NETAGE*NPOIN2, 1, 0,MESH3D)
C LIMITATION OF 2D SEGMENT FLUXES
      CALL BIEF_ALLVEC(1,FLULIM,'FLULIM',NSEG,1,0,MESH3D)
!
!-----------------------------------------------------------------------
C ALLOCATES VOID STRUCTURE
!
      CALL BIEF_ALLVEC(1, SVIDE, 'SVIDE ', 0, 1, 1,MESH3D)
!
C PREVIOUSLY CALLED CALL BIEF_ALLVEC(1,SVIDE,'SVIDE ',0,1,-99,MESH3D)
!
C A VOID BLOCK
!
      CALL ALLBLO(BVIDE,'BVIDE ')
!
!=======================================================================
C SEDIMENT
C  IF CONSOLIDATION IS MODELLED USING THE MULTI-LAYER MODEL,
C  THE MAXIMUM NUMBER OF PLANES DISCRETISING THE BED: NPFMAX
C  EQUALS (NCOUCH+1) :
!
      IF(SEDI) THEN
        CALL BIEF_ALLVEC(1, WCHU,      'WCHU  ', IELM3, 1,1,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1, WCHU,      'WCHU  ', 0    , 1,0,MESH3D)
      ENDIF
!
      IF(TASSE .AND. SEDI) NPFMAX = NCOUCH + 1
!
      IF((GIBSON.OR.TASSE).AND.SEDI) THEN
        CALL BIEF_ALLVEC(1,EPAI,'EPAI  ',(NPFMAX-1)*NPOIN2,1,0,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1,EPAI,'EPAI  ',0,                1,0,MESH3D)
      ENDIF
!
      IF(GIBSON.AND.SEDI) THEN
        CALL BIEF_ALLVEC(1, IVIDE, 'IVIDE ', NPFMAX*NPOIN2, 1,0,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1, IVIDE, 'IVIDE ', 0,             1,0,MESH3D)
      ENDIF
!
      IF(TASSE.AND.SEDI) THEN
        CALL BIEF_ALLVEC(1, TEMP, 'TEMP  ', NCOUCH*NPOIN2, 1,0,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1, TEMP, 'TEMP  ', 0,             1,0,MESH3D)
      ENDIF
!
      IF(TASSE.AND.SEDI) THEN
        CALL BIEF_ALLVEC(1, CONC, 'CONC  ', NCOUCH, 1, 0,MESH3D)
      ELSE
        CALL BIEF_ALLVEC(1, CONC, 'CONC  ',      0, 1, 0,MESH3D)
      ENDIF
!
      IF(SEDI) THEN
        CALL BIEF_ALLVEC(1, DMOY,  'DMOY  ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, CREF,  'CREF  ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, HDEP,  'HDEP  ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, FLUER, 'FLUER ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, PDEPO, 'PDEPO ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(1, ZR,    'ZR    ', IELM2H, 1, 1,MESH2D)
        CALL BIEF_ALLVEC(2, NPF,   'NPF   ', IELM2H, 1, 1,MESH2D)
      ELSE
        CALL BIEF_ALLVEC(1, DMOY,  'DMOY  ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, CREF,  'CREF  ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, HDEP,  'HDEP  ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, FLUER, 'FLUER ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, PDEPO, 'PDEPO ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(1, ZR,    'ZR    ',      0, 1, 0,MESH2D)
        CALL BIEF_ALLVEC(2, NPF,   'NPF   ',      0, 1, 0,MESH2D)
      ENDIF
!
!-----------------------------------------------------------------------
C VARSOR BLOCK FOR 2D OUTPUT COMPATIBILITY
!
      CALL ALLBLO(VARSOR ,'VARSOR')
!
      CALL ADDBLO(VARSOR,U2D)             ! U  01 VELOCITY ALONG X
      CALL ADDBLO(VARSOR,V2D)             ! V  02 VELOCITY ALONG Y
      CALL ADDBLO(VARSOR,T2_10)           ! C  03 WAVE CELERITY
      CALL ADDBLO(VARSOR,H)               ! H  04 DEPTH
      CALL ADDBLO(VARSOR,T2_01)           ! S  05 FREE SURFACE
      CALL ADDBLO(VARSOR,ZF)              ! B  06 BOTTOM
      CALL ADDBLO(VARSOR,T2_02)           ! F  07 FROUDE NUMBER
      CALL ADDBLO(VARSOR,T2_03)           ! Q  08 Q SCALAR FLOW RATE
      CALL ADDBLO(VARSOR,SVIDE)           ! T  09 NOT IMPLEMENTED
      CALL ADDBLO(VARSOR,SVIDE)           ! D  10 NOT IMPLEMENTED
      CALL ADDBLO(VARSOR,SVIDE)           ! E  11 NOT IMPLEMENTED
      CALL ADDBLO(VARSOR,SVIDE)           ! P  12 NOT IMPLEMENTED
      CALL ADDBLO(VARSOR,T2_04)           ! I  13 HU
      CALL ADDBLO(VARSOR,T2_05)           ! J  14 HV
      CALL ADDBLO(VARSOR,T2_06)           ! M  15 SQRT(U**2+V**2)
      CALL ADDBLO(VARSOR,WIND%ADR(1)%P)   ! X  16 WIND COMPONENT X DIRECT
      CALL ADDBLO(VARSOR,WIND%ADR(2)%P)   ! Y  17 WIND COMPONENT Y DIRECT
      CALL ADDBLO(VARSOR,PATMOS)          ! K  18 ATMOSPHERIC PRESSURE
      CALL ADDBLO(VARSOR,RUGOF)           ! W  19 FRICTION COEFFICIENT
      CALL ADDBLO(VARSOR,SVIDE)         !!! A  20
      CALL ADDBLO(VARSOR,SVIDE)         !!! G  21
      CALL ADDBLO(VARSOR,SVIDE)         !!! L  22
      CALL ADDBLO(VARSOR,ZR)              ! RB 23 RIGID BED
      CALL ADDBLO(VARSOR,EPAI)            ! FD 24 FRESH DEPOSITS
      CALL ADDBLO(VARSOR,FLUER)           ! EF 25 EROSION FLUX
      CALL ADDBLO(VARSOR,PDEPO)           ! DP 26 DEPOSITION PROBABILITY
      CALL ADDBLO(VARSOR,PRIVE%ADR(1)%P)  !    27 MNEMO PRIVE1
      CALL ADDBLO(VARSOR,PRIVE%ADR(2)%P)  !    28 MNEMO PRIVE2
      CALL ADDBLO(VARSOR,PRIVE%ADR(3)%P)  !    29 MNEMO PRIVE3
      CALL ADDBLO(VARSOR,PRIVE%ADR(4)%P)  !    30 MNEMO PRIVE4
      CALL ADDBLO(VARSOR,T2_07)           ! US 31 FRICTION VELOCITY
      CALL ADDBLO(VARSOR,T2_11)           ! QS 32 SOLID DISCHARGE
      CALL ADDBLO(VARSOR,T2_12)           ! QS 33 SOLID DISCHARGE ALONG X
      CALL ADDBLO(VARSOR,T2_13)           ! QS 34 SOLID DISCHARGE ALONG Y
!
C     VARIABLES 35 TO 35+NTRAC-1
!
      IF(NTRAC.GT.0) THEN
        DO I=1,NTRAC
C         SIZE OF TRAV2 MUST BE GREATER THAN 13+NTRAC
          CALL ADDBLO(VARSOR,TRAV2%ADR(13+I)%P)
        ENDDO
      ENDIF
!
C QUASI - OTHER VARIABLES, AN EMPTY BLOCK
!
      CALL ALLBLO(VARCL,'VARCL ')
!
!-----------------------------------------------------------------------
C VARSOR BLOCK FOR 3D OUTPUT
!
      CALL ALLBLO(VARSO3 ,'VARSO3')
C 1
      CALL ADDBLO(VARSO3,Z3)
C 2
      CALL ADDBLO(VARSO3,U)
C 3
      CALL ADDBLO(VARSO3,V)
C 4
      CALL ADDBLO(VARSO3,W)
C 5
      CALL ADDBLO(VARSO3,VISCVI%ADR(1)%P)
C 6
      CALL ADDBLO(VARSO3,VISCVI%ADR(2)%P)
C 7
      CALL ADDBLO(VARSO3,VISCVI%ADR(3)%P)
C 8
      CALL ADDBLO(VARSO3,AK)
C 9
      CALL ADDBLO(VARSO3,EP)
C 10
      CALL ADDBLO(VARSO3,RI)
C 11
      CALL ADDBLO(VARSO3,DELTAR)
C 12 : DYNAMIC PRESSURE
      CALL ADDBLO(VARSO3,DP)
C 13 : HYDROSTATIC PRESSURE
      CALL ADDBLO(VARSO3,PH)
!
C  NEXT = 14
!
C VARIABLES NUMBER "NEXT" TO "NEXT" + NTRAC - 1
!
      IF(NTRAC.GT.0) THEN
        DO I=1,NTRAC
          CALL ADDBLO(VARSO3,TA%ADR(I)%P)
        ENDDO
      ENDIF
!
C VARIABLES NUMBER "NEXT" + NTRAC TO "NEXT" + 4*NTRAC - 1
!
      IF(NTRAC.GT.0) THEN
        DO I=1,NTRAC
          CALL ADDBLO(VARSO3,VISCTA%ADR(I)%P%ADR(1)%P)
          CALL ADDBLO(VARSO3,VISCTA%ADR(I)%P%ADR(2)%P)
          CALL ADDBLO(VARSO3,VISCTA%ADR(I)%P%ADR(3)%P)
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
      IF(LISTIN) THEN
        IF(LNG.EQ.1) WRITE(LU,41)
        IF(LNG.EQ.2) WRITE(LU,42)
      ENDIF
 41   FORMAT(1X,/,' FIN DE L''ALLOCATION DE LA MEMOIRE ',/)
 42   FORMAT(1X,/,' END OF MEMORY ALLOCATION  ',/)
!
!-----------------------------------------------------------------------
!
      RETURN
      END
