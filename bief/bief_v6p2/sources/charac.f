!                    *****************
                     SUBROUTINE CHARAC
!                    *****************
!
     &( FN    , FTILD  , NOMB  , UCONV  , VCONV , WCONV  , FRCONV , 
     &  ZSTAR , FREQ   ,
     &  DT    , IFAMAS , IELM  , NPOIN2 , NPLAN , JF     , NF     ,
     &  MSK   , MASKEL , SHP   , SHZ    , SHF   , TB     , ELT ,
     &  ETA   , FRE    , IT3   , ISUB   , FREBUF, MESH   ,
     &  NELEM2, NELMAX2, IKLE2 , SURDET2, POST , PERIO , YA4D, SIGMA,
     &  STOCHA, VISC)
!
!***********************************************************************
! BIEF   V6P3                                   21/08/2010
!***********************************************************************
!
!brief    CALLS THE METHOD OF CHARACTERISTICS
!+               (SUBROUTINE CARACT).
!
!warning  So far the size of some arrays cannot be checked:
!+        FRE, ELT, ETA, IT3, ISUB, FREBUF, it would be better to send
!+        BIEF_OBJ structures.        
!
!history  J-M HERVOUET (LNHE)
!+        12/02/2010
!+        V6P0
!+   First version.
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
!+        03/01/2012
!+        V6P2
!+   NPOIN instead of NPOIN2 in the call to SCARACT at the position
!+   of argument NPLOT (goes with corrections in Streamline.f)
!
!history  J-M HERVOUET (LNHE)
!+        18/04/2013
!+        V6P3
!+   NPOIN instead of NPOIN2 in the call to SCARACT at the position
!+   of argument NPLOT (goes with corrections in Streamline.f)
!
!history  J-M HERVOUET (LNHE)
!+        02/05/2013
!+        V6P3
!+   Arguments STOCHA and VISC added. Attribute target added for some
!+   others (it helps prepare weak form of characteristics).
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| DT             |-->| TIME STEP
!| FN             |-->| VARIABLES AT TIME N .
!| FTILD          |<--| VARIABLES AFTER ADVECTION .
!| IELM           |-->| TYPE OF ELEMENT : 11 : TRIANGLE P1
!|                |   |                   41 : PRISM IN TELEMAC3D
!| IFAMAS         |-->| A MODIFIED IFABOR WHEN ELEMENTS ARE MASKED
!| IKLE2          |-->| CONNECTIVITY TABLE FOR TRIANGLES
!| ELT            |<->| ARRIVAL ELEMENT
!| ETA            |<->| ARRIVAL LAYER (IN 3D WITH PRISMS)
!| FRCONV         |-->| FREQUENCY COMPONENT OF ADVECTION FIELD
!| FRE            |<->| ARRIVAL FREQUENCY (IN 4D)
!| FREBUF         |<->| INTEGER WORK ARRAY (IN 4D)
!| FREQ           |-->| DISCRETISED FREQUENCIES (IN 4D).
!|                |   | IF NOT TOMAWAC, MUST BE ZSTAR !!!!!!!!!!!
!| JF             |-->| FREQUENCY (IN A RANGE OF 1 TO NF)
!| IT3            |<->| INTEGER WORK ARRAY
!| ISUB           |<->| ARRIVAL SUB-DOMAIN (IN PARALLEL)
!| MASKEL         |-->| MASKING OF ELEMENTS
!|                |   | =1. : NORMAL   =0. : MASKED ELEMENT
!| MESH           |-->| MESH STRUCTURE
!| MSK            |-->| IF YES, THERE IS MASKED ELEMENTS.
!| NELEM2         |-->| NUMBER OF ELEMENTS IN 2D
!| NELMAX2        |-->| MAXIMUM NUMBER OF ELEMENTS IN 2D
!| NF             |-->| NUMBER OF FREQUENCIES (IN 4D)
!| NOMB           |-->| NUMBER OF VARIABLES TO BE ADVECTED
!| NPLAN          |-->| NUMBER OF PLANES IN THE 3D MESH OF PRISMS
!| NPOIN2         |-->| NUMBER OF POINTS IN THE 2D MESH
!| PERIO          |-->| IF YES, PERIODIC VERSION ON THE VERTICAL
!| POST           |-->| IF YES, DATA MUST BE KEPT FOR A POSTERIORI
!|                |   | INTERPOLATION
!| SHP            |<->| BARYCENTRIC COORDINATES OF POINTS IN TRIANGLES
!| SHZ            |<->| BARYCENTRIC COORDINATES ON VERTICAL
!| SHF            |<->| BARYCENTRIC COORDINATES ON THE FREQUENCY AXIS
!| SIGMA          |-->| IF YES, TRANSFORMES MESh FOR TELEMAC-3D
!| STOCHA         |-->| STOCHASTIC DIFFUSION MODEL
!|                |   | 0: NO DIFFUSION 1: oil spill       2: algae
!| SURDET2        |-->| GEOMETRIC COEFFICIENT USED IN PARAMETRIC TRANSFORMATION
!| TB             |<->| BLOCK CONTAINING THE BIEF_OBJ WORK ARRAYS
!| UCONV          |-->| X-COMPONENT OF ADVECTION FIELD
!| VCONV          |-->| Y-COMPONENT OF ADVECTION FIELD
!| VISC           |-->| VISCOSITY (MAY BE TENSORIAL)
!| WCONV          |-->| Z-COMPONENT OF ADVECTION FIELD IN THE TRANSFORMED MESH
!| YA4D           |-->| IF YES, 4D VERSION FOR TOMAWAC
!| ZSTAR          |-->| TRANSFORMED VERTICAL COORDINATES IN 3D 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_CHARAC => CHARAC
      USE STREAMLINE, ONLY : SCARACT  
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER         , INTENT(IN)           :: NOMB
      INTEGER         , INTENT(IN)           :: NPLAN,JF,NF,NELEM2
      INTEGER         , INTENT(IN)           :: NPOIN2,NELMAX2
      INTEGER         , INTENT(INOUT)        :: IELM
      INTEGER         , INTENT(INOUT)        :: FRE(*)
!     NEXT 3 DIMENSIONS ARE A MINIMUM
      INTEGER         , INTENT(INOUT),TARGET :: ELT(NPOIN2*NPLAN)
      INTEGER         , INTENT(INOUT),TARGET :: ETA(NPOIN2*NPLAN)
      INTEGER         , INTENT(INOUT),TARGET :: IT3(NPOIN2*NPLAN)
      INTEGER         , INTENT(INOUT)        :: ISUB(*),FREBUF(*)
      TYPE(BIEF_OBJ)  , INTENT(IN)           :: FN,UCONV,VCONV,WCONV
      TYPE(BIEF_OBJ)  , INTENT(IN)           :: FRCONV
      TYPE(BIEF_OBJ)  , INTENT(IN)           :: ZSTAR,MASKEL,IKLE2
      TYPE(BIEF_OBJ)  , INTENT(IN)           :: SURDET2
      TYPE(BIEF_OBJ)  , INTENT(IN)           :: FREQ
      TYPE(BIEF_OBJ)  , INTENT(INOUT)        :: TB,SHF
      TYPE(BIEF_OBJ)  , INTENT(INOUT),TARGET :: FTILD,SHP,SHZ
      LOGICAL         , INTENT(IN)           :: MSK
      DOUBLE PRECISION, INTENT(IN)           :: DT
      TYPE(BIEF_MESH) , INTENT(INOUT)        :: MESH
      TYPE(BIEF_OBJ)  , INTENT(IN), TARGET   :: IFAMAS
      LOGICAL, INTENT(IN), OPTIONAL          :: POST,PERIO,YA4D,SIGMA
      INTEGER, INTENT(IN), OPTIONAL          :: STOCHA
      TYPE(BIEF_OBJ), INTENT(IN), OPTIONAL, TARGET :: VISC
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER NPOIN,IELMU,IELEM,SIZEBUF,ASTOCHA    
!
!-----------------------------------------------------------------------
!
      TYPE(BIEF_OBJ), POINTER :: T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,AVISC
      INTEGER, DIMENSION(:), POINTER :: IFA
      INTEGER I,J,K,NPT,DIM1F,IPLAN
      LOGICAL QUAD,QUAB,APOST,APERIO,AYA4D,ASIGMA  
!
      INTRINSIC MIN
! 
!-----------------------------------------------------------------------
!  OPTIONAL OPTIONS
!-----------------------------------------------------------------------
!
!     ENABLING A POSTERIORI INTERPOLATION
!
      IF(PRESENT(POST)) THEN
        APOST=POST
      ELSE
        APOST=.FALSE.      
      ENDIF
!
!     PERIODICITY FOR TOMAWAC
!
      IF(PRESENT(PERIO)) THEN
        APERIO=PERIO
      ELSE
        APERIO=.FALSE.      
      ENDIF
!
!     4D FOR TOMAWAC
!
      IF(PRESENT(YA4D)) THEN
        AYA4D=YA4D
      ELSE
        AYA4D=.FALSE.
      ENDIF
!
!     TRANSFORMED MESH FOR TELEMAC-3D
!
      IF(PRESENT(SIGMA)) THEN
        ASIGMA=SIGMA
      ELSE
        ASIGMA=.FALSE.
      ENDIF
!
!     STOCHASTIC DIFFUSION
!
      IF(PRESENT(STOCHA)) THEN
        ASTOCHA=STOCHA
      ELSE
        ASTOCHA=0
      ENDIF
      IF(PRESENT(VISC)) THEN
        AVISC => VISC
      ELSE
        IF(ASTOCHA.NE.0) THEN
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'CHARAC : AVEC DIFFUSION STOCHASTIQUE'
            WRITE(LU,*) '         UN ARGUMENT VISC DOIT ETRE DONNE'
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'CHARAC: WITH STOCHASTIC DIFFUSION'
            WRITE(LU,*) '        AN ARGUMENT VISC MUST BE GIVEN'
          ENDIF
          CALL PLANTE(1)
          STOP          
        ELSE
!         HERE A DUMMY TARGET, WILL NOT BE USED 
!         MAYBE NULLIFY WOULD BE BETTER ?
          AVISC => IFAMAS
        ENDIF
      ENDIF
! 
!-----------------------------------------------------------------------
!  TABLEAUX DE TRAVAIL PRIS DANS LE BLOC TB
!-----------------------------------------------------------------------
!
      IF(TB%N.GE.10) THEN
        T1 =>TB%ADR( 1)%P
        T2 =>TB%ADR( 2)%P
        T3 =>TB%ADR( 3)%P
        T4 =>TB%ADR( 4)%P
        T5 =>TB%ADR( 5)%P
        T6 =>TB%ADR( 6)%P
        T7 =>TB%ADR( 7)%P
        T8 =>TB%ADR( 8)%P
        T9 =>TB%ADR( 9)%P
        T10=>TB%ADR(10)%P
      ELSE
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'TAILLE DU BLOC TB:',TB%N
          WRITE(LU,*) 'TROP PETITE DANS CHARAC'
          WRITE(LU,*) '10 REQUIS'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'SIZE OF BLOCK TB:',TB%N
          WRITE(LU,*) 'TOO SMALL IN CHARAC'
          WRITE(LU,*) '10 REQUESTED'
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!  DEPLOIEMENT DE LA STRUCTURE DE MAILLAGE
!-----------------------------------------------------------------------
!
      NPOIN = MESH%NPOIN
      IELMU = UCONV%ELM
!
!     PREPARING WORK ARRAYS
!
!     THE OFF-DIAGONAL TERMS OF WORK MATRIX IN MESH WILL BE USED AS
!     SHPBUF(3,SIZEBUF)
!
      SIZEBUF=(MESH%M%X%MAXDIM1*MESH%M%X%MAXDIM2)/3
!
!     T7 WILL BE USED AS SHZBUF(SIZEBUF)
!
      SIZEBUF=MIN(SIZEBUF,T7%MAXDIM1)
!
!     IT3 WILL BE USED AS ELTBUF
!
      SIZEBUF=MIN(SIZEBUF,NPOIN)
!
!-----------------------------------------------------------------------
!  ARE THERE QUADRATIC OR QUASI-BUBBLE VARIABLES ?
!  AND COMPUTATION OF LARGEST NUMBER OF POINTS
!-----------------------------------------------------------------------
!
      QUAD=.FALSE.
      QUAB=.FALSE.
      NPT=0
      IF(FN%TYPE.EQ.4) THEN    
        DO I=1,FN%N
          IF(FN%ADR(I)%P%ELM.EQ.12) QUAB = .TRUE.
          IF(FN%ADR(I)%P%ELM.EQ.13) QUAD = .TRUE.
          NPT=MAX(NPT,FN%ADR(I)%P%DIM1)
        ENDDO
      ELSEIF(FN%TYPE.EQ.2) THEN
        IF(FN%ELM.EQ.12) QUAB = .TRUE.
        IF(FN%ELM.EQ.13) QUAD = .TRUE.
        NPT=MAX(NPT,FN%DIM1)
      ENDIF
      IF(QUAB.AND.QUAD) THEN
        WRITE(LU,*) 'CHARAC: QUADRATIC AND QUASI-BUBBLE CANNOT BE MIXED'
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!     CHECKING DIMENSIONS OF ARRAYS 
!-----------------------------------------------------------------------
!
      IF(3*NPT.GT.SHP%MAXDIM1*SHP%MAXDIM2) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'TAILLE DE SHP:',SHP%MAXDIM1*SHP%MAXDIM2
          WRITE(LU,*) 'TROP PETITE DANS CHARAC, ',3*NPT
          WRITE(LU,*) 'REQUISE'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'SIZE OF SHP:',SHP%MAXDIM1*SHP%MAXDIM2
          WRITE(LU,*) 'TOO SMALL IN CHARAC, ',3*NPT
          WRITE(LU,*) 'REQUESTED'
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF
!
      IF(MAX(NPOIN2,NPT).GT.T2%MAXDIM1) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'TAILLE DE T2:',T2%MAXDIM1
          WRITE(LU,*) 'TROP PETITE DANS CHARAC, ',MAX(NPOIN2,NPT)
          WRITE(LU,*) 'REQUISE'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'SIZE OF T2:',T2%MAXDIM1
          WRITE(LU,*) 'TOO SMALL IN CHARAC, ',MAX(NPOIN2,NPT)
          WRITE(LU,*) 'REQUESTED'
        ENDIF
        CALL PLANTE(1)
        STOP
      ENDIF         
!
!-----------------------------------------------------------------------
!  APPEL DE CARACT
!-----------------------------------------------------------------------
!
      IF(MSK) THEN
!       APPEL AVEC IFAMAS
        IFA=>IFAMAS%I
      ELSE
!       APPEL AVEC IFABOR
        IFA=>MESH%IFABOR%I
      ENDIF
!
!     STARTING X AND Y OF POINTS (T1=XCONV AND T2=YCONV)
!
      CALL OS('X=Y     ',X=T1,Y=MESH%X)
      CALL OS('X=Y     ',X=T2,Y=MESH%Y)
!
!     IELM MUST BE INTENT(INOUT) BECAUSE IT IS SUCH IN CHGDIS
      IF(QUAD) THEN    
        CALL CHGDIS(T1,IELM,13,MESH)
        CALL CHGDIS(T2,IELM,13,MESH)
      ELSEIF(QUAB) THEN
        CALL CHGDIS(T1,IELM,12,MESH)
        CALL CHGDIS(T2,IELM,12,MESH)
      ENDIF 
!           
      IF(IELM.EQ.11) THEN
        CALL GTSH11(SHP%R,ELT,IKLE2%I,MESH%ELTCAR%I,NPOIN2,
     &              NELEM2,NELMAX2,MESH%NSEG,QUAB,QUAD)
        DIM1F=NPT
      ELSEIF(IELM.EQ.41) THEN
!       STARTING Z OF POINTS (T3=ZCONV)
        DO IPLAN=1,NPLAN
          DO I= (IPLAN-1)*NPOIN2+1,IPLAN*NPOIN2
            T3%R(I)=ZSTAR%R(IPLAN)
          ENDDO
        ENDDO 
!       IN 4D, STARTING F OF POINTS (T9=FCONV)
        IF(AYA4D) THEN
          CALL OV('X=C     ',T9%R,T9%R,T9%R,FREQ%R(JF),NPOIN2*NPLAN)
        ENDIF   
        CALL GTSH41(SHP%R,SHZ%R,SHF%R,WCONV%R,FRCONV%R,
     &              ELT,ETA,FRE,IKLE2%I,MESH%ELTCAR%I,
     &              NPOIN2,NELMAX2,NPLAN,JF,NF,AYA4D)
        DIM1F=NPOIN2
      ELSE
        WRITE(LU,*) 'ELEMENT NOT IMPLEMENTED IN CHARAC: ',IELM
        CALL PLANTE(1)
        STOP  
      ENDIF        
!        
      CALL SCARACT(FN,FTILD,UCONV%R,VCONV%R,WCONV%R,FRCONV%R,
     &             MESH%X%R,MESH%Y%R,ZSTAR%R,FREQ%R,
!                  XCONV YCONV ZCONV FCONV DX   DY   DZ   DF
     &             T1%R ,T2%R ,T3%R ,T9%R ,T4%R,T5%R,T6%R,T8%R,
     &             MESH%Z%R,SHP%R,SHZ%R,SHF%R,
     &             SURDET2%R,DT,IKLE2%I,IFA,ELT,ETA,FRE,IT3,ISUB,
     &             IELM,IELMU,NELEM2,NELMAX2,NOMB,NPOIN,NPOIN2,
     &             3,NPLAN,NF,MESH,NPT,DIM1F,-1,
     &             MESH%M%X%R,T7%R,T10%R,FREBUF,SIZEBUF,
     &             APOST,APERIO,AYA4D,ASIGMA,ASTOCHA,AVISC)  
! 
!     PARALLEL COMMUNICATION
!    
      IF(NCSIZE.GT.1.AND.NOMB.GT.0) THEN
        IF(FTILD%TYPE.EQ.2) THEN 
          CALL PARCOM(FTILD,1,MESH)               
        ELSEIF(FTILD%TYPE.EQ.4) THEN 
          DO I=1,NOMB          
            CALL PARCOM(FTILD%ADR(I)%P,1,MESH) 
          ENDDO 
        ENDIF 
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
