C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       ASSEMBLES MATRICES EXTRA-DIAGONAL TERMS
!>                IN THE CASE OF EDGE-BASED STORAGE.
!><br>            CASE OF LINEAR-QUASIBUBBLE ELEMENT.
!>  @code
!>            THE EXTRA-DIAGONAL TERMS OF THIS RECTANGULAR MATRIX ARE :
!>
!>            ... 1-2 1-3 1-4
!>            2-1 ... 2-3 2-4
!>            3-1 3-2 ... 3-4
!>
!>            AND ARE STORED LIKE A SQUARE LINEAR MATRIX + 3 TERMS
!>            WHICH GIVES 2*NSEG11 + (NSEG12-NSEG11) TERMS
!>            OR NSEG11 + NSEG12, HENCE THE DIMENSION OF XM
!>  @endcode

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> ELTSEG1, ELTSEG2, ELTSEG3, ELTSEG4, ELTSEG5, ELTSEG6, NELEM, NELMAX, NSEG11, NSEG12, ORISEG1, ORISEG2, ORISEG3, XM, XMT
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> IELEM, ISEG
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>ASSEX3()

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
!> </td><td> 29/12/05
!> </td><td> J-M HERVOUET (LNH) 01 30 87 80 18
!> </td><td>
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>ELTSEG1
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ELTSEG2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ELTSEG3
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ELTSEG4
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ELTSEG5
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ELTSEG6
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NELEM
!></td><td>--></td><td>NOMBRE D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>--></td><td>PREMIERE DIMENSION DE IKLE ET W.
!>                  (CAS D'UN MAILLAGE ADAPTATIF)
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>--></td><td>NOMBRE DE POINTS FRONTIERES.
!>    </td></tr>
!>          <tr><td>NSEG11
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NSEG12
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ORISEG1
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ORISEG2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ORISEG3
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>TR
!></td><td>--></td><td>TABLEAU DE TRAVAIL DE TAILLE > NPTFR
!>    </td></tr>
!>          <tr><td>XM
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>XM2
!></td><td>--></td><td>TERMES EXTRA-DIAGONAUX XA21,32,31
!>    </td></tr>
!>          <tr><td>XMAS
!></td><td><--</td><td>TERMES EXTRA-DIAGONAUX ASSEMBLES XA12,23,31
!>    </td></tr>
!>          <tr><td>XMT
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE AS3_1112
     &(XM,NSEG11,NSEG12,XMT,NELMAX,NELEM,ELTSEG1,ELTSEG2,ELTSEG3,
     &                                   ELTSEG4,ELTSEG5,ELTSEG6,
     &                                   ORISEG1,ORISEG2,ORISEG3)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| ELTSEG1        |---| 
C| ELTSEG2        |---| 
C| ELTSEG3        |---| 
C| ELTSEG4        |---| 
C| ELTSEG5        |---| 
C| ELTSEG6        |---| 
C| NELEM          |-->| NOMBRE D'ELEMENTS DANS LE MAILLAGE.
C| NELMAX         |-->| PREMIERE DIMENSION DE IKLE ET W.
C|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
C| NPTFR          |-->| NOMBRE DE POINTS FRONTIERES.
C| NSEG11         |---| 
C| NSEG12         |---| 
C| ORISEG1        |---| 
C| ORISEG2        |---| 
C| ORISEG3        |---| 
C| TR             |-->| TABLEAU DE TRAVAIL DE TAILLE > NPTFR
C| XM             |---| 
C| XM2            |-->| TERMES EXTRA-DIAGONAUX XA21,32,31
C| XMAS           |<--| TERMES EXTRA-DIAGONAUX ASSEMBLES XA12,23,31
C| XMT            |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER         , INTENT(IN)    :: NELMAX,NELEM,NSEG11,NSEG12
      INTEGER         , INTENT(IN)    :: ELTSEG1(NELMAX)
      INTEGER         , INTENT(IN)    :: ELTSEG2(NELMAX)
      INTEGER         , INTENT(IN)    :: ELTSEG3(NELMAX)
      INTEGER         , INTENT(IN)    :: ELTSEG4(NELMAX)
      INTEGER         , INTENT(IN)    :: ELTSEG5(NELMAX)
      INTEGER         , INTENT(IN)    :: ELTSEG6(NELMAX)
      INTEGER         , INTENT(IN)    :: ORISEG1(NELMAX)
      INTEGER         , INTENT(IN)    :: ORISEG2(NELMAX)
      INTEGER         , INTENT(IN)    :: ORISEG3(NELMAX)
      DOUBLE PRECISION, INTENT(IN)    :: XMT(NELMAX,*)
      DOUBLE PRECISION, INTENT(INOUT) :: XM(NSEG11+NSEG12)
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER ISEG,IELEM
C
C-----------------------------------------------------------------------
C
C  INITIALISES
C
      DO ISEG = 1 , 2*NSEG11
        XM(ISEG) = 0.D0
      ENDDO
C
C  ASSEMBLES THE LINEAR PART (BETWEEN 1 AND 2*NSEG11)
C
C  THE SHIFT NSEG11*(...) PLACES THE TERM IN THE HIGHER OR LOWER
C  OFF-DIAGONAL TERMS, DEPENDING ON THE ORIENTATION OF THE SEGMENT
C
      DO IELEM = 1,NELEM
C         TERM 12
          XM(ELTSEG1(IELEM)+NSEG11*(ORISEG1(IELEM)-1))
     &  = XM(ELTSEG1(IELEM)+NSEG11*(ORISEG1(IELEM)-1)) + XMT(IELEM,01)
C         TERM 23
          XM(ELTSEG2(IELEM)+NSEG11*(ORISEG2(IELEM)-1))
     &  = XM(ELTSEG2(IELEM)+NSEG11*(ORISEG2(IELEM)-1)) + XMT(IELEM,05)
C         TERM 31
          XM(ELTSEG3(IELEM)+NSEG11*(ORISEG3(IELEM)-1))
     &  = XM(ELTSEG3(IELEM)+NSEG11*(ORISEG3(IELEM)-1)) + XMT(IELEM,07)
C         TERM 21
          XM(ELTSEG1(IELEM)+NSEG11*(2-ORISEG1(IELEM)))
     &  = XM(ELTSEG1(IELEM)+NSEG11*(2-ORISEG1(IELEM))) + XMT(IELEM,04)
C         TERM 32
          XM(ELTSEG2(IELEM)+NSEG11*(2-ORISEG2(IELEM)))
     &  = XM(ELTSEG2(IELEM)+NSEG11*(2-ORISEG2(IELEM))) + XMT(IELEM,08)
C         TERM 13
          XM(ELTSEG3(IELEM)+NSEG11*(2-ORISEG3(IELEM)))
     &  = XM(ELTSEG3(IELEM)+NSEG11*(2-ORISEG3(IELEM))) + XMT(IELEM,02)
      ENDDO
C
C  ASSEMBLES THE QUASI-BUBBLE PART
C  BETWEEN XM(2*NSEG11+1) AND XM(NSEG11+NSEG12)
C  SEE IN STOSEG HOW ELTSEG4,5,6 ARE BUILT
C
      DO IELEM = 1,NELEM
C       TERM 14
        XM(ELTSEG4(IELEM)+NSEG11) = XMT(IELEM,03)
C       TERM 24
        XM(ELTSEG5(IELEM)+NSEG11) = XMT(IELEM,06)
C       TERM 34
        XM(ELTSEG6(IELEM)+NSEG11) = XMT(IELEM,09)
      ENDDO
C
C-----------------------------------------------------------------------
C
      RETURN
      END
C
C#######################################################################
C