      SUBROUTINE AD_TELEMAC2D_TIMESTEP_BEGIN
  
        USE DECLARATIONS_TELEMAC2D
        
        IMPLICIT NONE

        INTEGER     LNG,LU
        COMMON/INFO/LNG,LU
        
!!        WRITE(LU,*) 'AD_TELEMAC2D_TIMESTEP_BEGIN [lib]'
        IF(DEBUG.GT.0) WRITE(LU,*) 'AD_TELEMAC2D_TIMESTEP_BEGIN [lib]'

      END SUBROUTINE AD_TELEMAC2D_TIMESTEP_BEGIN