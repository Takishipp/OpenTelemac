      SUBROUTINE AD_SISYPHE_END
  
        USE DECLARATIONS_SISYPHE
        
        IMPLICIT NONE

        INTEGER     LNG,LU
        COMMON/INFO/LNG,LU
        
!!        WRITE(LU,*) 'AD_SISYPHE_END [lib]'
        IF(DEBUG.GT.0) WRITE(LU,*) 'AD_SISYPHE_END [lib]'

      END SUBROUTINE AD_SISYPHE_END