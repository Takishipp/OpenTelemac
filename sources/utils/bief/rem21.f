!                    ****************
                     SUBROUTINE REM21
!                    ****************
!
     &(X, XA1,XA2,XA3,XA4,XA5,XA6 , IKLE1,IKLE2,IKLE3,IKLE4,
     & NELEM,NELMAX,NPOIN,LV)
!
!***********************************************************************
! BIEF   V6P1                                   21/08/2010
!***********************************************************************
!
!brief    PRODUCT X = U B (BEWARE: ELEMENT BY ELEMENT).
!+
!+            DEALS HERE WITH Q1 ELEMENTS OR ELEMENTS WITH 4 POINTS.
!+
!+            REVERSE OPERATION FROM THAT IN SUBROUTINE REMONT,
!+                HENCE THE NAME.
!code
!+            THE MATRIX U IS HERE THE RESULT OF A DECOMPOSITION
!+            DONE IN SUBROUTINE DECLDU
!+
!+            EACH ELEMENTARY MATRIX WAS FACTORISED IN THE FORM:
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
!history  J-M HERVOUET (LNH)    ; F  LEPEINTRE (LNH)
!+        05/02/91
!+        V5P1
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
!| IKLE1          |-->| GLOBAL NUMBER OF THE FIRST POINT OF QUADRILATERALS
!| IKLE2          |-->| GLOBAL NUMBER OF THE SECOND POINT OF QUADRILATERALS
!| IKLE3          |-->| GLOBAL NUMBER OF THE THIRD POINT OF QUADRILATERALS
!| IKLE4          |-->| GLOBAL NUMBER OF THE FOURTH POINT OF QUADRILATERALS
!| LV             |-->| VECTOR LENGTH OF THE MACHINE
!| NELEM          |-->| NUMBER OF ELEMENTS
!| NELMAX         |-->| MAXIMUM NUMBER OF ELEMENTS
!| NPOIN          |-->| NUMBER OF POINTS
!| X              |<->| AT THE BEGINNING : B
!|                |   | AT THE END       : THE RESULT
!| XA1            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!| XA2            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!| XA3            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!| XA4            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!| XA5            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!| XA6            |<--| OFF-DIAGONAL TERMS OF THE LOWER PART OF MATRIX
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NPOIN,NELEM,NELMAX,LV
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX)
      INTEGER, INTENT(IN) :: IKLE3(NELMAX),IKLE4(NELMAX)
!
      DOUBLE PRECISION, INTENT(INOUT) :: X(NPOIN)
      DOUBLE PRECISION, INTENT(IN) :: XA1(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XA2(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XA3(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XA4(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XA5(NELMAX)
      DOUBLE PRECISION, INTENT(IN) :: XA6(NELMAX)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IB
      INTRINSIC MIN
!
!-----------------------------------------------------------------------
!
! RESUMES INVERSIONS OF THE LOWER TRIANGULAR MATRICES
!
!-----------------------------------------------------------------------
! LOOP IN SCALAR MODE (LV=1) OR WITH FORCED VECTORISATION
!-----------------------------------------------------------------------
!
      IF(LV.EQ.1) THEN
!
!  SCALAR MODE
!
      DO 10 IELEM = NELEM , 1 , -1
        X(IKLE3(IELEM))=X(IKLE3(IELEM))-XA6(IELEM)*X(IKLE4(IELEM))
        X(IKLE2(IELEM))=X(IKLE2(IELEM))-XA5(IELEM)*X(IKLE4(IELEM))
     &                                 -XA4(IELEM)*X(IKLE3(IELEM))
        X(IKLE1(IELEM))=X(IKLE1(IELEM))-XA3(IELEM)*X(IKLE4(IELEM))
     &                                 -XA2(IELEM)*X(IKLE3(IELEM))
     &                                 -XA1(IELEM)*X(IKLE2(IELEM))
10    CONTINUE
!
      ELSE
!
!  VECTOR MODE
!
      DO 20 IB = (NELEM+LV-1)/LV , 1 , -1
!VOCL LOOP,NOVREC
!DIR$ IVDEP
      DO 30 IELEM = MIN(NELEM,IB*LV) , 1+(IB-1)*LV , -1
        X(IKLE3(IELEM))=X(IKLE3(IELEM))-XA6(IELEM)*X(IKLE4(IELEM))
        X(IKLE2(IELEM))=X(IKLE2(IELEM))-XA5(IELEM)*X(IKLE4(IELEM))
     &                                 -XA4(IELEM)*X(IKLE3(IELEM))
        X(IKLE1(IELEM))=X(IKLE1(IELEM))-XA3(IELEM)*X(IKLE4(IELEM))
     &                                 -XA2(IELEM)*X(IKLE3(IELEM))
     &                                 -XA1(IELEM)*X(IKLE2(IELEM))
30    CONTINUE
20    CONTINUE
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END