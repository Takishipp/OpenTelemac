      SUBROUTINE AD_SISYPHE_TIMESTEP_BEGIN
  
        USE DECLARATIONS_SISYPHE
        
        IMPLICIT NONE

        INTEGER     LNG,LU
        COMMON/INFO/LNG,LU
        
!!        WRITE(LU,*) 'AD_SISYPHE_TIMESTEP_BEGIN [lib]'
        IF(DEBUG.GT.0) WRITE(LU,*) 'AD_SISYPHE_TIMESTEP_BEGIN [lib]'

      END SUBROUTINE AD_SISYPHE_TIMESTEP_BEGIN
