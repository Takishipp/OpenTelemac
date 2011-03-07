!                    *****************
                     SUBROUTINE DECV11
!                    *****************
!
     &(TETA,SL,ZF,IKLE,NELEM,NELMAX)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    IDENTIFIES TIDAL FLATS.
!+
!+            DRYING ELEMENT : TETA = 0,
!+
!+            NORMAL ELEMENT : TETA = 1.
!+
!+            THE CRITERION FOR DRYING ELEMENTS IS THAT OF
!+                J.-M. JANIN : BOTTOM ELEVATION OF A POINT IN AN
!+                ELEMENT BEING HIGHER THAN THE FREE SURFACE
!+                ELEVATION OF ANOTHER.
!
!history  J-M HERVOUET (LNH)
!+        09/12/94
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
!| IKLE           |---|
!| NELEM          |---|
!| NELMAX         |---|
!| SL,ZF          |-->| SURFACE LIBRE ET FOND
!| TETA           |<--| INDICATEUR (PAR ELEMENT)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER         , INTENT(IN)  :: NELEM,NELMAX
      INTEGER         , INTENT(IN)  :: IKLE(NELMAX,*)
      DOUBLE PRECISION, INTENT(OUT) :: TETA(NELEM)
      DOUBLE PRECISION, INTENT(IN)  :: SL(*),ZF(*)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM
!
      DOUBLE PRECISION SL1,SL2,SL3,ZF1,ZF2,ZF3
!
      INTRINSIC MAX,MIN
!
!-----------------------------------------------------------------------
!
      CALL OV( 'X=C     ' , TETA , TETA , TETA , 1.D0 , NELEM )
!
!-----------------------------------------------------------------------
!
         DO 4 IELEM = 1 , NELEM
!
           SL1 = SL(IKLE(IELEM,1))
           SL2 = SL(IKLE(IELEM,2))
           SL3 = SL(IKLE(IELEM,3))
!
           ZF1 = ZF(IKLE(IELEM,1))
           ZF2 = ZF(IKLE(IELEM,2))
           ZF3 = ZF(IKLE(IELEM,3))
!
           IF(MAX(ZF1,ZF2,ZF3).GT.MIN(SL1,SL2,SL3)) THEN
             TETA(IELEM) = 0.D0
           ENDIF
!
4        CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
      END