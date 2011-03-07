!                    ****************
                     SUBROUTINE GOUP1
!                    ****************
!
     &(X, A,B ,DITR,MESH,COPY)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    SOLVES THE SYSTEM U X = B (ELEMENT BY ELEMENT).
!code
!+            THE MATRIX L IS HERE THE RESULT OF A DECOMPOSITION
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
!code
!+-----------------------------------------------------------------------
!+  MEANING OF IELM :
!+
!+  TYPE OF ELEMENT      NUMBER OF POINTS      CODED IN THIS SUBROUTINE
!+
!+  11 : P1 TRIANGLE            3                       YES
!+  12 : QUASI-BUBBLE TRIANGLE  4                       YES
!+  21 : Q1 QUADRILATERAL       4                       YES
!+  41 : TELEMAC-3D PRISMS      6                       YES
!+
!+-----------------------------------------------------------------------
!
!history  J-M HERVOUET (LNH)
!+        26/02/04
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
!| A              |<--| MATRICE A SOUS FORME LDU
!| B              |<--| SECOND MEMBRE DU SYSTEME A RESOUDRE.
!| COPY           |-->| SI .TRUE. B EST RECOPIE SUR X.
!|                |   | AU PREALABLE.
!| DITR           |-->| CARACTERE  'D' : ON CALCULE AVEC A
!|                |   | 'T' : ON CALCULE AVEC A TRANSPOSEE
!| MESH           |-->| BLOC DES TABLEAUX D'ENTIERS DU MAILLAGE.
!| X              |<--| SOLUTION DU SYSTEME AX = B
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_GOUP1 => GOUP1
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      TYPE(BIEF_OBJ), INTENT(INOUT) :: X
      TYPE(BIEF_OBJ), INTENT(IN) :: B
      TYPE(BIEF_OBJ), INTENT(IN) :: A
      TYPE(BIEF_MESH), INTENT(IN)   :: MESH
      CHARACTER(LEN=1), INTENT(IN)  :: DITR
      LOGICAL, INTENT(IN) :: COPY
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELM,NPOIN,NELEM,NELMAX
!
      CHARACTER*1 TYPX
!
!-----------------------------------------------------------------------
!
      TYPX  = A%TYPEXT
      NPOIN = A%D%DIM1
      IELM  = A%ELMLIN
      NELEM = MESH%NELEM
      NELMAX= MESH%NELMAX
      CALL CPSTVC(B,X)
!
!-----------------------------------------------------------------------
!
! 1) DESCENT WITH COPY OF B IN X
!
      IF(A%STO.EQ.1) THEN
        CALL REMONT(X%R, A%X%R,TYPX,
     &       B%R,MESH%IKLE%I,NELEM,NELMAX,NPOIN,IELM,DITR,COPY,MESH%LV)
      ELSEIF(A%STO.EQ.3) THEN
        CALL REMSEG(X%R, A%X%R,TYPX,
     &       B%R,MESH%GLOSEG%I,MESH%NSEG,NPOIN,DITR,COPY)
      ELSE
        WRITE(LU,*) 'GOUP1, CASE NOT IMPLEMENTED'
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END