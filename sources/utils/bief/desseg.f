!                    *****************
                     SUBROUTINE DESSEG
!                    *****************
!
     &(X, XA,TYPEXA,B,GLOSEG,NSEG,NPOIN,DITR,COPY)
!
!***********************************************************************
! BIEF   V6P1                                   21/08/2010
!***********************************************************************
!
!brief    SOLVES THE SYSTEM L X = B (SEGMENT BY SEGMENT).
!code
!+            MATRIX L IS HERE THE RESULT OF THE FACTORISATION
!+            PERFORMED IN SUBROUTINE DECLDU.
!+
!+            EACH ELEMENTARY MATRIX IS DECOMPOSED IN THE FORM:
!+
!+            LE X DE X UE
!+
!+            LE : LOWER TRIANGULAR WITH 1S ON THE DIAGONAL
!+            DE : DIAGONAL
!+            UE : UPPER TRIANGULAR WITH 1S ON THE DIAGONAL
!+
!+                                                T
!+            IF THE MATRIX IS SYMMETRICAL : LE =  UE
!
!history  J-M HERVOUET (LNH)
!+        25/02/04
!+        V5P5
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
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| B              |<--| RIGHT-HAND SIDE OF THE LINEAR SYSTEM TO BE SOLVED
!| COPY           |-->| IF .TRUE. B IS COPIED INTO X TO START WITH
!| DITR           |-->| CHARACTER, IF  'D' : DIRECT MATRIX A CONSIDERED
!|                |   |                'T' : TRANSPOSED MATRIX A CONSIDERED
!| GLOSEG         |-->| GLOBAL NUMBERS OF POINTS OF SEGMENTS
!| NPOIN          |-->| NUMBER OF POINTS
!| NSEG           |-->| NUMBER OF SEGMENTS
!| TYPEXA         |-->| TYPE OF OFF-DIAGONAL TERMS IN THE MATRIX
!| X              |<--| SOLUTION OF THE SYSTEM AX = B
!| XA             |<--| OFF-DIAGONAL TERMS OF THE MATRIX
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_DESSEG => DESSEG
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER         , INTENT(IN)    :: NPOIN,NSEG
      INTEGER         , INTENT(IN)    :: GLOSEG(NSEG,2)
      DOUBLE PRECISION, INTENT(INOUT) :: X(NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: XA(NSEG,*),B(NPOIN)
      CHARACTER(LEN=1), INTENT(IN)    :: TYPEXA,DITR
      LOGICAL         , INTENT(IN)    :: COPY
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I
!
!-----------------------------------------------------------------------
!
! 1) INITIALISES : X = SECOND MEMBER
!
      IF(COPY) CALL OV( 'X=Y     ' , X , B , B , 0.D0 , NPOIN )
!
!-----------------------------------------------------------------------
!
! 2) INVERTS THE LOWER TRIANGULAR MATRICES (DESCENT)
!
      IF(TYPEXA(1:1).EQ.'S' .OR.
     &  (TYPEXA(1:1).EQ.'Q'.AND.DITR(1:1).EQ.'T')) THEN
!
        DO I=1,NSEG
          X(GLOSEG(I,2))=X(GLOSEG(I,2))-XA(I,1)*X(GLOSEG(I,1))
        ENDDO
!
      ELSEIF(TYPEXA(1:1).EQ.'Q'.AND.DITR(1:1).EQ.'D') THEN
!
        DO I=1,NSEG
          X(GLOSEG(I,2))=X(GLOSEG(I,2))-XA(I,2)*X(GLOSEG(I,1))
        ENDDO
!
      ELSE
        WRITE(LU,*) 'DESSEG, CASE NOT IMPLEMENTED'
        WRITE(LU,*) '        TYPEXA=',TYPEXA,' DITR=',DITR(1:1)
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
