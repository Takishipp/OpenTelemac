!                    *******************
                     SUBROUTINE SET_MESH
!                    *******************
!
     &(FFORMAT,FILE_ID,MESH_DIM,TYPELM,NDP,NPTFR,
     & NPTIR,NELEM,NPOIN,IKLE,IPOBO,
     & KNOLG,X,Y,NPLAN,DATE,TIME,IERR,Z)
!
!***********************************************************************
! HERMES   V7P0                                               01/05/2014
!***********************************************************************
!
!brief    Writes the mesh geometry in the file
!
!history  Y AUDOUIN (LNHE)
!+        24/03/2014
!+        V7P0
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| FFORMAT        |-->| FORMAT OF THE FILE
!| FILE_ID        |-->| FILE DESCRIPTOR
!| MESH_DIM       |-->| DIMENSION OF THE MESH
!| TYPELM         |-->| TYPE OF THE MESH ELEMENTS
!| NDP            |-->| NUMBER OF POINTS PER ELEMENT
!| NPTFR          |-->| NUMBER OF BOUNDARY POINT
!| NPTIR          |-->| NUMBER OF INTERFACE POINT
!| NELEM          |-->| NUMBER OF ELEMENT IN THE MESH
!| NPOIN          |-->| NUMBER OF POINTS IN THE MESH
!| IKLE           |-->| CONNECTIVITY ARRAY FOR THE MAIN ELEMENT
!| IPOBO          |-->| IS A BOUNDARY POINT ? ARRAY
!| KNOLG          |-->| LOCAL TO GLOBAL NUMBERING ARRAY
!| X              |-->| X COORDINATES OF THE MESH POINTS
!| Y              |-->| Y COORDINATES OF THE MESH POINTS
!| NPLAN          |-->| NUMBER OF PLANES
!| DATE           |-->| DATE OF THE CREATION OF THE MESH
!| TIME           |-->| TIME OF THE CREATION OF THE MESH
!| IERR           |<--| 0 IF NO ERROR DURING THE EXECUTION
!| Z  (OPTIONAL)  |-->| Z COORDINATES OF THE MESH POINTS
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE UTILS_SERAFIN
      USE UTILS_MED
      IMPLICIT NONE
      INTEGER     LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CHARACTER(LEN=8), INTENT(IN)  :: FFORMAT
      INTEGER,          INTENT(IN)  :: FILE_ID,NPLAN
      INTEGER,          INTENT(IN)  :: DATE(3)
      INTEGER,          INTENT(IN)  :: TIME(3)
      INTEGER,          INTENT(IN)  :: MESH_DIM
      INTEGER,          INTENT(IN)  :: TYPELM
      INTEGER,          INTENT(IN)  :: NDP
      INTEGER,          INTENT(IN)  :: NPTFR
      INTEGER,          INTENT(IN)  :: NPTIR
      INTEGER,          INTENT(IN)  :: NELEM
      INTEGER,          INTENT(IN)  :: NPOIN
      INTEGER,          INTENT(IN)  :: IKLE(NELEM*NDP)
      INTEGER,          INTENT(IN)  :: IPOBO(*)
      INTEGER,          INTENT(IN)  :: KNOLG(*)
      DOUBLE PRECISION, INTENT(IN)  :: X(NPOIN),Y(NPOIN)
      INTEGER,          INTENT(OUT) :: IERR
      DOUBLE PRECISION, INTENT(IN), OPTIONAL :: Z(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION, DIMENSION(MESH_DIM*NPOIN) :: COORD
      INTEGER :: I
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      SELECT CASE (FFORMAT)
        CASE ('SERAFIN ','SERAFIND')
          CALL SET_MESH_SRF(FFORMAT,FILE_ID,MESH_DIM,TYPELM,NDP,NPTFR,
     &                      NPTIR,NELEM,NPOIN,IKLE,IPOBO,
     &                      KNOLG,X,Y,NPLAN,DATE,TIME,IERR)
        CASE ('MED     ')
!         STORE COORDINATES
          DO I=1,NPOIN
            COORD(I) = X(I)
            COORD(I+NPOIN) = Y(I)
            IF (PRESENT(Z)) COORD(I+2*NPOIN) = Z(I)
          ENDDO
!
          CALL SET_MESH_MED(FILE_ID,MESH_DIM,MESH_DIM,TYPELM,NDP,NPTFR,
     &      NPTIR,NELEM,NPOIN,IKLE,IPOBO,KNOLG,COORD,IERR)

        CASE DEFAULT
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'SET_MESH : MAUVAIS FORMAT : ',FFORMAT
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'SET_MESH: BAD FILE FORMAT: ',FFORMAT
          ENDIF
          CALL PLANTE(1)
          STOP
      END SELECT
!
!-----------------------------------------------------------------------
!
      RETURN
      END

