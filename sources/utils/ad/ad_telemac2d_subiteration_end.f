      SUBROUTINE AD_TELEMAC2D_SUBITERATION_END
  
        USE DECLARATIONS_TELEMAC2D
        
        IMPLICIT NONE

        INTEGER     LNG,LU
        COMMON/INFO/LNG,LU
        
!!        WRITE(LU,*) 'AD_TELEMAC2D_SUBITERATION_END [lib]'
        IF(DEBUG.GT.0) WRITE(LU,*) 'AD_TELEMAC2D_SUBITERATION_END [lib]'

      END SUBROUTINE AD_TELEMAC2D_SUBITERATION_END