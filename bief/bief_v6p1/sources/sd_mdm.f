!                    *****************
                     SUBROUTINE SD_MDM
!                    *****************
!
     &(VK,TAIL,V,L,LAST,NEXT,MARK)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    FORMS ELEMENT FROM UNELIMINATED NEIGHBOURS OF VK.
!
!note     IMPORTANT : INSPIRED FROM PACKAGE CMLIB3 - YALE UNIVERSITE-YSMP
!
!history  E. RAZAFINDRAKOTO (LNH)
!+        20/11/06
!+        V5P7
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
!| L              |---|
!| LAST           |---|
!| MARK           |---|
!| NEXT           |---|
!| TAIL           |---|
!| V              |---|
!| VK             |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_SD_MDM => SD_MDM
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: VK,LAST(*),NEXT(*),V(*)
      INTEGER, INTENT(INOUT) :: TAIL,L(*),MARK(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER TAG,S,LS,VS,ES,B,LB,VB,BLP,BLPMAX
      EQUIVALENCE (VS,ES)
!
!----INITIALISES TAG AND LIST OF UNELIMINATED NEIGHBOURS
!
      TAG = MARK(VK)
      TAIL = VK
!
!----FOR EACH VERTEX/ELEMENT VS/ES IN ELEMENT LIST OF VK
!
      LS = L(VK)
1     S = LS
      IF(S.EQ.0)  GO TO 5
      LS = L(S)
      VS = V(S)
      IF(NEXT(VS).LT.0)  GO TO 2
!
!------IF VS IS UNELIMINATED VERTEX, THEN TAGS AND APPENDS TO LIST OF
!------UNELIMINATED NEIGHBOURS
!
      MARK(VS) = TAG
      L(TAIL) = S
      TAIL = S
      GO TO 4
!
!------IF ES IS ACTIVE ELEMENT, THEN ...
!--------FOR EACH VERTEX VB IN BOUNDARY LIST OF ELEMENT ES
!
2     LB = L(ES)
      BLPMAX = LAST(ES)
      DO 3 BLP=1,BLPMAX
        B = LB
        LB = L(B)
        VB = V(B)
!
!----------IF VB IS UNTAGGED VERTEX, THEN TAGS AND APPENDS TO LIST OF
!----------UNELIMINATED NEIGHBOURS
!
        IF(MARK(VB).GE.TAG)  GO TO 3
        MARK(VB) = TAG
        L(TAIL) = B
        TAIL = B
3     CONTINUE
!
!--------MARKS ES INACTIVE
!
      MARK(ES) = TAG
!
4     GO TO 1
!
!----TERMINATES LIST OF UNELIMINATED NEIGHBOURS
!
5     L(TAIL) = 0
!
!-----------------------------------------------------------------------
!
      RETURN
      END