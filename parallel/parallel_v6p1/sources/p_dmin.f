C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       MINIMUM VALUE FROM ALL THE PROCESSORS.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> MYPART
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> IER
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Unknown(s)
!>    </th><td> MPI_ALLREDUCE, MPI_COMM_WORLD, MPI_DOUBLE_PRECISION, MPI_MIN
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>CVTRVF(), CVTRVF_POS(), FLUXPR(), FLUXPR_SISYPHE(), FLUXPR_TELEMAC2D(), MURD3D(), POSITIVE_DEPTHS(), PRERES_TELEMAC2D(), SISYPHE(), SPECTRE(), SUSPENSION_LISTING(), TELEMAC2D()

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
!>  <tr>
!>    <td><center>                                        </center></td>
!>    <td> 28/12/1999                                              </td>
!>    <td> J.A. JANKOWSKI (BAW KARLSRUHE)                          </td>
!>    <td> RELEASE 5.0 MODIFIED                                    </td>
!>  <tr>
!>    <td><center>                                        </center></td>
!>    <td> **/10/1999                                              </td>
!>    <td> RAINER JOHANNI (SGI MUNICH)                             </td>
!>    <td> ADAPTED FOR MPI                                         </td>
!>  <tr>
!>    <td><center>                                        </center></td>
!>    <td> 08/01/1997                                              </td>
!>    <td> J-M HERVOUET (LNHE)                                     </td>
!>    <td>                                                         </td>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>MYPART
!></td><td>--></td><td>CONTRIBUTION DU PROCESSEUR APPELANT.
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        DOUBLE PRECISION FUNCTION P_DMIN
     &(MYPART)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| MYPART         |-->| CONTRIBUTION DU PROCESSEUR APPELANT.
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INCLUDE 'mpif.h'
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      DOUBLE PRECISION, INTENT(IN) :: MYPART
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER IER
C
C-----------------------------------------------------------------------
C
      CALL MPI_ALLREDUCE(MYPART,P_DMIN,1,MPI_DOUBLE_PRECISION,MPI_MIN,
     &                   MPI_COMM_WORLD,IER)
C
      IF(IER.NE.0) THEN
        IF(LNG.EQ.1) WRITE(LU,*) 'P_DMIN: ERREUR DANS MPI_ALLREDUCE'
        IF(LNG.EQ.2) WRITE(LU,*) 'P_DMIN: ERROR IN MPI_ALLREDUCE'
        WRITE(LU,*) 'MPI ERROR ',IER
        STOP
      ENDIF
C
C-----------------------------------------------------------------------
C
      RETURN
      END
C
C#######################################################################
C