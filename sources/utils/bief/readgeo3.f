!                    *******************
                     SUBROUTINE READGEO3
!                    *******************
!
     &(KNOLG,X,Y,NPOIN,NFIC,IB,FFORMAT,PROJECTION,LATI0,LONGI0,Z)
!
!***********************************************************************
! BIEF   V6P3                                   21/08/2010
!***********************************************************************
!
!brief    READS OR COMPUTES THE VALUES OF NPOIN, NELEM, NPTFR,
!+                MXPTVS, MXELVS IN THE GEOMETRY FILE (CHANNEL NGEO).
!
!warning  USER SUBROUTINE (MAY BE REWRITTEN FOR ANOTHER FILE FORMAT)
!
!history  J-M HERVOUET (LNH)     ; REGINA NEBAUER; LAM MINH PHUONG
!+        19/10/03
!+
!+
!
!history  EMILE RAZAFINDRAKOTO
!+        19/10/05
!+        V5P6
!+
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
!history  J-M HERVOUET (EDF R&D, LNHE)
!+        14/03/2013
!+        V6P3
!+   Treatment of latitude-longitude coordinates.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| FFORMAT        |-->| FILE FORMAT
!| IB             |-->| SERIES OF 10 INTEGERS IN THE SELAFIN FORMAT
!| KNOLG          |-->| GLOBAL NUMBER OF A LOCAL POINT IN PARALLEL
!| LATI0          |-->| LATITUDE OF ORIGIN POINT
!| LONGI0         |-->| LONGITUDE OF ORIGIN POINT
!| NFIC           |-->| LOGICAL UNIT OF SELAFIN FILE
!| NPOIN          |<--| NUMBER OF POINTS IN THE MESH
!| PROJECTION     |<->| SPATIAL PROJECTION TYPE
!| X              |<--| ABSCISSAE OF POINTS IN THE MESH
!| Y              |<--| ORDINATES OF POINTS IN THE MESH
!| Z              |<--| ELEVATIONS OF POINTS IN THE MESH
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_READGEO3 => READGEO3
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)           :: NPOIN,NFIC
      INTEGER, INTENT(INOUT)        :: IB(10),PROJECTION
      INTEGER, INTENT(OUT)          :: KNOLG(NPOIN)
      DOUBLE PRECISION, INTENT(IN)  :: LATI0,LONGI0
      DOUBLE PRECISION, INTENT(OUT) :: X(NPOIN),Y(NPOIN)
      DOUBLE PRECISION, INTENT(OUT), OPTIONAL :: Z(NPOIN)
      CHARACTER(LEN=8), INTENT(IN)  :: FFORMAT
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION XB(2)
      REAL, ALLOCATABLE :: RB(:)
      REAL RBID(1)
      INTEGER ISTAT,ERR,I
      CHARACTER(LEN=1) CB
      CHARACTER(LEN=2) RF
!
      DOUBLE PRECISION, PARAMETER :: R=6.37D6
      DOUBLE PRECISION, PARAMETER :: PI=3.141592653589793D0
      DOUBLE PRECISION PS4
!
      INTRINSIC LOG,TAN
!
!-----------------------------------------------------------------------
!
      IF(FFORMAT.EQ.'SERAFIND') THEN
        RF = 'R8'
      ELSE
        RF = 'R4'
      ENDIF
!
!-----------------------------------------------------------------------
!
!     HAS ALREADY READ THE 1ST PART OF THE FILE IN READGEO1
!
!     REWIND NFIC
!
!     7 : KNOLG REPLACES IPOBO (PARALLEL MODE)
!
      IF(IB(8).NE.0.OR.IB(9).NE.0) THEN
!       PARALLEL MODE,
!       CASE WHERE KNOLG REPLACES IPOBO
        CALL LIT(XB,RBID,KNOLG,CB,NPOIN,'I ',NFIC,'STD',ISTAT)
      ENDIF
!
!     8 AND 9: X AND Y COORDINATES
!
      ALLOCATE(RB(NPOIN),STAT=ERR)
      IF(ERR.NE.0) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'READGEO3 : ALLOCATION DE RB DEFECTUEUSE'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'READGEO3 : WRONG ALLOCATION OF RB'
        ENDIF
        STOP
      ENDIF
!
      CALL LIT(X   ,RB,IB,CB,NPOIN,RF,NFIC,'STD',ISTAT)
      CALL LIT(Y   ,RB,IB,CB,NPOIN,RF,NFIC,'STD',ISTAT)
!
!     SPECIAL FORMAT FOR 3D : Z AFTER X AND Y
!     A RECORD FOR TIME IS PRESENT WITH THE SELAFIN FORMAT
!     WHEN Z IS GIVEN AS VARIABLE IN TIME, BUT THIS IS NEVER USED.
!
      IF(PRESENT(Z)) THEN
!       RECORD FOR TIME
!       CALL LIT(Z,RB,IB,CB,1,RF,NFIC,'STD',ISTAT)
!       RECORD FOR Z (FIRST VARIABLE IN SELAFIN FORMAT)
        CALL LIT(Z,RB,IB,CB,NPOIN,RF,NFIC,'STD',ISTAT)
      ENDIF
!
!-----------------------------------------------------------------------
!
      CALL CORRXY(X,Y,NPOIN)
!
!     LATITUDE-LONGITUDE COORDINATES (RADIAN) 
!     CHANGED INTO MERCATOR PROJECTION
!
      IF(PROJECTION.EQ.3) THEN
        PS4=PI*0.25D0
        DO I=1,NPOIN
          X(I)=R*(X(I)-LONGI0)
          Y(I)=R*(LOG(TAN(0.5D0*Y(I)+PS4))-LOG(TAN(0.5D0*LATI0+PS4)))
        ENDDO 
!       NOW IT IS MERCATOR
        PROJECTION=2
        WRITE(LU,*) ' '
        WRITE(LU,*) 'REAGEO3 :' 
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'COORDONNEES CHANGEES EN PROJECTION DE MERCATOR'
          WRITE(LU,*) 'AVEC LATITUDE DU POINT ORIGINE = ',LATI0
          WRITE(LU,*) 'ET  LONGITUDE DU POINT ORIGINE = ',LONGI0
        ENDIF 
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'COORDINATES CHANGED INTO MERCATOR PROJECTION'
          WRITE(LU,*) 'WITH LATITUDE OF ORIGIN POINT = ',LATI0
          WRITE(LU,*) 'AND LONGITUDE OF ORIGIN POINT = ',LONGI0
        ENDIF
        WRITE(LU,*) ' '      
      ENDIF
!
      DEALLOCATE(RB)
!
!-----------------------------------------------------------------------
!
      RETURN
      END