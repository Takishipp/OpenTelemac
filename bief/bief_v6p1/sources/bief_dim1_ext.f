!                    ******************************
                     INTEGER FUNCTION BIEF_DIM1_EXT
!                    ******************************
!
     &(IELM1,IELM2,STO,TYPEXT,MESH)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    GIVES THE FIRST DIMENSION OF A MATRICE'S EXTRA-DIAGONAL
!+                TERMS.
!
!history  J-M HERVOUET (LNH)
!+        05/02/2010
!+        V6P0
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
!| IELM1          |-->| TYPE DE L'ELEMENT DE LIGNE
!| IELM2          |-->| TYPE DE L'ELEMENT DE COLONNE
!| STO            |-->| TYPE DE STOCKAGE
!| TYPEXT         |-->| TYPE DES TERMES EXTRA-DIAGONAUX
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_BIEF_DIM1_EXT => BIEF_DIM1_EXT
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER         , INTENT(IN) :: IELM1,IELM2,STO
      CHARACTER(LEN=1), INTENT(IN) :: TYPEXT
      TYPE(BIEF_MESH) , INTENT(IN) :: MESH
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELMX,N
!
!-----------------------------------------------------------------------
!
      IELMX = 10*(IELM1/10)
!
      IF(TYPEXT.EQ.'0') THEN
!
!        NOT 0 TO ENABLE BOUND CHECKING
         BIEF_DIM1_EXT = 1
!
      ELSEIF(STO.EQ.1) THEN
!
!        CLASSICAL EBE STORAGE
!
         BIEF_DIM1_EXT =BIEF_NBMPTS(IELMX,MESH)
!
      ELSEIF(STO.EQ.3) THEN
!
!        EDGE-BASED STORAGE
!
         IF(TYPEXT.EQ.'S') THEN
           BIEF_DIM1_EXT=BIEF_NBSEG(IELM1,MESH)
         ELSE
           BIEF_DIM1_EXT=BIEF_NBSEG(IELM1,MESH)+BIEF_NBSEG(IELM2,MESH)
           N=MAX(BIEF_NBPEL(IELM1,MESH),BIEF_NBPEL(IELM2,MESH))
     &      -MIN(BIEF_NBPEL(IELM1,MESH),BIEF_NBPEL(IELM2,MESH))
           IF(N.GE.2) THEN
!            SOME SEGMENTS LINK ONLY E.G. QUADRATIC POINTS AND
!            WILL NOT BE CONSIDERED IN A RECTANGULAR MATRIX
!            THIS IS THE CASE WITH 3 SEGMENTS IN QUADRATIC TRIANGLE
             BIEF_DIM1_EXT=BIEF_DIM1_EXT
     &                    -N*(N-1)*BIEF_NBMPTS(IELMX,MESH)/2
           ENDIF
         ENDIF
!
      ELSE
!
        IF(LNG.EQ.1) WRITE(LU,100) STO
        IF(LNG.EQ.2) WRITE(LU,101) STO
100     FORMAT(1X,'BIEF_DIM1_EXT : STOCKAGE NON PREVU : ',1I6)
101     FORMAT(1X,'BIEF_DIM1_EXT : UNKNOWN TYPE OF STORAGE: ',1I6)
        CALL PLANTE(1)
        STOP
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END