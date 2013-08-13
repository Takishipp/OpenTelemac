!                    ********************
                     SUBROUTINE LOI_W_INC
!                    ********************
!
     &(YAM,YAV,YS1,YS2,WIDTH,PHI,DEB,G)
!
!***********************************************************************
! TELEMAC2D   V6P3                                   13/06/2013
!***********************************************************************
!
!brief    DISCHARGE LAW FOR AN INCLINATED WEIR.
!
!history  C. COULET (ARTELIA)
!+        13/06/2013
!+ Inspired from CARIMA program
!+
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| DEB            |<--| DISCHARGE OF WEIR
!| G              |-->| GRAVITY.
!| PHI            |-->| DISCHARGE COEFFICIENT OF WEIR.
!| WIDTH          |-->| WIDTH OF WEIR
!| YAM            |-->| UPSTREAM ELEVATION
!| YAV            |-->| DOWNSTREAM ELEVATION
!| YS1            |-->| ELEVATION OF WEIR (SIDE1)
!| YS2            |-->| ELEVATION OF WEIR (SIDE2)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      DOUBLE PRECISION, INTENT(INOUT) :: DEB
      DOUBLE PRECISION, INTENT(IN)    :: G,YAM,YAV,PHI,YS1,YS2,WIDTH
!
      DOUBLE PRECISION :: SLOPE,XPD,XD,XPN,XN,QD,QN
      DOUBLE PRECISION :: AUX0,AUX1,AUX2,AUX3,AUX4
      DOUBLE PRECISION :: YSmin
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      SLOPE = DABS(YS1-YS2)/WIDTH
!      
      IF (SLOPE.GT.1.D-4) THEN
        YSmin = DMIN1(YS1,YS2)
        XPD = (YAM-YSmin)/SLOPE
      ELSE
        YSmin = YS1
        XPD = WIDTH
      ENDIF
      IF (XPD.GE.WIDTH) THEN
        XD = WIDTH
      ELSE
        XD = XPD
      ENDIF
!
      XPN = 3.D0*YAV - 2.D0*YAM - YSmin
      IF (XPN.LE.0.D0) THEN
        XN = 0.D0
      ELSEIF (XPN.LE.WIDTH*SLOPE) THEN
        XN = XPN / SLOPE
      ELSE
        XN = WIDTH
      ENDIF
!
      IF(YAM.LT.YSmin.AND.YAV.LT.YSmin) THEN
        DEB=0.D0
      ELSE
        QN = ((YAV-YSmin)*XN - 0.5D0*SLOPE*XN**2)*SQRT(YAM-YAV)
        IF (SLOPE.GT.1.D-4) THEN
          AUX0 = YAM-YSmin
          AUX1 = MAX(YAM-YSmin-XD*SLOPE, 0.D0)
          AUX2 = MAX(YAM-YSmin-XN*SLOPE, 0.D0)
          AUX3 = AUX1**1.5D0 - AUX2**1.5D0
          AUX4 = XD*AUX1**1.5D0 + 2.D0/(5.D0*SLOPE)*AUX1**2.5D0 -
     &           XN*AUX2**1.5D0 - 2.D0/(5.D0*SLOPE)*AUX2**2.5D0
          QD = PHI * 2.D0/(3.D0*SLOPE) * (SLOPE*AUX4-AUX0*AUX3)
        ELSE
          QD = PHI * (YAM-YSmin) * SQRT(YAM-YSmin) * (XD-XN)
        ENDIF
!
        DEB=SQRT(2.D0*G)*(QN+QD)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
