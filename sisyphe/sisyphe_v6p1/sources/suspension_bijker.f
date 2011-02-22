C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       COMPUTES THE REFERENCE CONCENTRATION AT Z= 2*D50
!>                USING ZYSERMAN AND FREDSOE FORMULATION (1994).

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Use(s)
!><br>BIEF, INTERFACE_SISYPHE
!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> CHARR, CSTAEQ, HMIN, HN, NPOIN, QSC, TAUP, XMVE, ZERO, ZREF
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> CMAX, I, USTARP
!>   </td></tr>
!>     <tr><th> Alias(es)
!>    </th><td> EX_SUSPENSION_BIJKER
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>INIT_TRANSPORT(), SUSPENSION_EROSION(), SUSPENSION_FLUX_MIXTE()

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Development history
!>   <br><table>
!> <tr><th> Release </th><th> Date </th><th> Author </th><th> Notes </th></tr>
!>  <tr><td><center> 6.0                                       </center>
!>    </td><td> 21/08/2010
!>    </td><td> N.DURAND (HRW), S.E.BOURBAN (HRW)
!>    </td><td> Creation of DOXYGEN tags for automated documentation and cross-referencing of the FORTRAN sources
!>   </td></tr>
!>  <tr><td><center> 6.0                                       </center>
!>    </td><td> 13/07/2010
!>    </td><td> N.DURAND (HRW), S.E.BOURBAN (HRW)
!>    </td><td> Translation of French comments within the FORTRAN sources into English comments
!>   </td></tr>
!>      <tr>
!>      <td><center> 5.6                                       </center>
!> </td><td> 04/01/2005
!> </td><td> F. HUVELIN
!> </td><td>
!> </td></tr>
!>      <tr>
!>      <td><center> 5.5                                       </center>
!> </td><td> 14/04/2004
!> </td><td> C. VILLARET  01 30 87 83 28
!> </td><td>
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>AC
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ACLADM
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>AVA
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>CF
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>CHARR
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>CSTAEQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>FLUER
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>GRAV
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>HCLIP
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>HMIN
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>HN
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>KSPRATIO
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>NPOIN
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>QSC
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>TAUP
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>TOB
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>XMVE
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>XMVS
!></td><td>--></td><td>
!>    </td></tr>
!>          <tr><td>ZERO
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ZREF
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
        SUBROUTINE SUSPENSION_BIJKER      !
     &  (TAUP, HN, NPOIN, CHARR, QSC, ZREF,
     &    ZERO, HMIN, CSTAEQ,XMVE)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| AC             |---| 
C| ACLADM         |-->| 
C| AVA            |-->| 
C| CF             |-->| 
C| CHARR          |-->| 
C| CSTAEQ         |---| 
C| FLUER          |---| 
C| GRAV           |-->| 
C| HCLIP          |-->| 
C| HMIN           |-->| 
C| HN             |---| 
C| KSPRATIO       |-->| 
C| NPOIN          |-->| 
C| QSC            |---| 
C| TAUP           |---| 
C| TOB            |-->| 
C| XMVE           |-->| 
C| XMVS           |-->| 
C| ZERO           |---| 
C| ZREF           |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE INTERFACE_SISYPHE,EX_SUSPENSION_BIJKER => SUSPENSION_BIJKER
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU


      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE(BIEF_OBJ),   INTENT(IN)    :: TAUP,QSC,HN
      TYPE (BIEF_OBJ),  INTENT(IN)    :: ZREF
      INTEGER,          INTENT(IN)    :: NPOIN
      LOGICAL,          INTENT(IN)    :: CHARR
      DOUBLE PRECISION, INTENT(IN)    :: HMIN,ZERO,XMVE
C
      TYPE(BIEF_OBJ),   INTENT(INOUT)   ::  CSTAEQ


      ! 3/ LOCAL VARIABLES
      ! ------------------
      INTEGER                     :: I
      DOUBLE PRECISION            :: USTARP,CMAX
C
C     MAXIMUM CONCENTRATION CORRESPONDING TO DENSE PACKING
C
      DATA CMAX/0.6D0/
C
!======================================================================!
!======================================================================!
C                               PROGRAM                                !
!======================================================================!
!======================================================================!

      IF(.NOT.CHARR) THEN
        WRITE(LU,*) 'SUSPENSION_BIJKER ERROR ON CHARR'
        CALL PLANTE(1)
        STOP
      ENDIF
C
      DO I=1,NPOIN
C
        IF(TAUP%R(I).LE.ZERO) THEN
          CSTAEQ%R(I) = 0.D0
        ELSE
          USTARP=SQRT(TAUP%R(I)/XMVE)
          CSTAEQ%R(I) = QSC%R(I)/(6.34D0*USTARP*ZREF%R(I))
          CSTAEQ%R(I) = MIN(CSTAEQ%R(I),CMAX)
        ENDIF
C
      ENDDO

!======================================================================!
!======================================================================!

      RETURN
      END SUBROUTINE SUSPENSION_BIJKER
C
C#######################################################################
C