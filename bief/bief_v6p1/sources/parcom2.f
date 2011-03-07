!                    ******************
                     SUBROUTINE PARCOM2
!                    ******************
!
     &( X1 , X2 , X3 , NPOIN , NPLAN , ICOM , IAN , MESH )
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPLEMENTS A VECTOR AT THE INTERFACES BETWEEN
!+                SUB-DOMAINS.
!+
!+            X CAN BE A BLOCK OF VECTORS. IN THIS CASE, ALL THE
!+                VECTORS IN THE BLOCK ARE TREATED.
!
!note     IMPORTANT : FROM RELEASE 5.9 ON, IDENTICAL VALUES ARE
!+                     ENSURED AT INTERFACE POINTS SO THAT DIFFERENT
!+                     PROCESSORS WILL ALWAYS MAKE THE SAME DECISION
!+                     IN TESTS ON REAL NUMBERS.
!
!warning  IF THE VECTORS HAVE A SECOND DIMENSION, IT IS
!+            IGNORED FOR THE TIME BEING
!
!history  J-M HERVOUET (LNHE)
!+        13/08/08
!+        V5P9
!+   AFTER REINHARD HINKELMANN (HANNOVER UNI.)
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
!| IAN            |---|
!| ICOM           |-->| COMMUNICATION MODE
!|                |   | = 1 : VALUE WITH MAXIMUM ABSOLUTE VALUE TAKEN
!|                |   | = 2 : CONTRIBUTIONS ADDED
!|                |   | = 3 : MAXIMUM CONTRIBUTION RETAINED
!|                |   | = 4 : MINIMUM CONTRIBUTION RETAINED
!| MESH           |-->| MAILLAGE.
!| NPLAN          |---|
!| NPOIN          |---|
!| X1             |---|
!| X2             |---|
!| X3             |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_PARCOM2 => PARCOM2
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!-----------------------------------------------------------------------
!
      INTEGER, INTENT(IN) :: ICOM,NPOIN,NPLAN,IAN
!
!     STRUCTURES: VECTORS OR BLOCKS
!
      TYPE(BIEF_MESH) , INTENT(INOUT) :: MESH
      DOUBLE PRECISION, INTENT(INOUT) :: X1(NPOIN,NPLAN)
      DOUBLE PRECISION, INTENT(INOUT) :: X2(NPOIN,NPLAN)
      DOUBLE PRECISION, INTENT(INOUT) :: X3(NPOIN,NPLAN)
!
!-----------------------------------------------------------------------
!
      CALL PARACO(X1,X2,X3,NPOIN,ICOM,IAN,NPLAN,
     &            MESH%NB_NEIGHB,MESH%NB_NEIGHB_PT%I,MESH%LIST_SEND%I,
     &            MESH%NH_COM%I,MESH%NH_COM%DIM1,MESH%BUF_SEND%R,
     &            MESH%BUF_RECV%R,MESH%BUF_SEND%DIM1)
!
!     RELEASE 5.9 : ENSURES SAME VALUES AT INTERFACE POINTS
!                   SHARED BY SEVERAL SUB-DOMAINS
!
      IF(ICOM.EQ.2.AND.NCSIZE.GT.2) THEN
!
      CALL PARACO(X1,X2,X3,NPOIN,1,IAN,NPLAN,
     &            MESH%NB_NEIGHB,MESH%NB_NEIGHB_PT%I,MESH%LIST_SEND%I,
     &            MESH%NH_COM%I,MESH%NH_COM%DIM1,MESH%BUF_SEND%R,
     &            MESH%BUF_RECV%R,MESH%BUF_SEND%DIM1)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END