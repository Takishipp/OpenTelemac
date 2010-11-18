C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       COMPUTES THE FOLLOWING VECTOR IN FINITE ELEMENTS:
!>  @code
!>                    /                    DF        DF
!>      V  =  XMUL   /       PSII  * ( G U --  + G V -- )   D(OMEGA)
!>       I          /OMEGA                 DX        DY<br>
!>    PSI(I) IS A BASE OF TYPE P1 TRIANGLE
!>  @endcode

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @warning  THE JACOBIAN MUST BE POSITIVE

!>  @warning  THE RESULT IS IN W IN NOT ASSEMBLED FORM

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Use(s)
!><br>BIEF
!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> F, G, IKLE1, IKLE2, IKLE3, NELEM, NELMAX, SF, SG, SU, SV, U, V, W1, W2, W3, XEL, XMUL, YEL
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> F1, F2, F3, FTX, FTY, G1, G2, G3, IELEM, IELMF, IELMG, IELMU, IELMV, T11, T12, T13, T22, T23, T33, U1, U123, U2, U3, V1, V123, V2, V3, X2, X3, XS120, Y2, Y3
!>   </td></tr>
!>     <tr><th> Alias(es)
!>    </th><td> EX_VC09AA
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>VECTOS()

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
!>      <td><center> 5.1                                       </center>
!> </td><td> 09/12/94
!> </td><td> J-M HERVOUET (LNH) 30 87 80 18
!> </td><td>
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>F,G,H
!></td><td>--></td><td>FONCTIONS INTERVENANT DANS LA FORMULE.
!>    </td></tr>
!>          <tr><td>IKLE1,
!></td><td>--></td><td>PASSAGE DE LA NUMEROTATION LOCALE A GLOBALE.
!>    </td></tr>
!>          <tr><td>IKLE2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IKLE3
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NELEM
!></td><td>--></td><td>NOMBRE D'ELEMENTS DU MAILLAGE.
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>--></td><td>NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
!>                  (CAS D'UN MAILLAGE ADAPTATIF)
!>    </td></tr>
!>          <tr><td>SF,SG,SH
!></td><td>--></td><td>STRUCTURES DES FONCTIONS F,G ET H
!>    </td></tr>
!>          <tr><td>SU,SV,SW
!></td><td>--></td><td>STRUCTURES DES FONCTIONS U,V ET W
!>    </td></tr>
!>          <tr><td>SURFAC
!></td><td>--></td><td>SURFACE DES ELEMENTS.
!>    </td></tr>
!>          <tr><td>U,V,W
!></td><td>--></td><td>COMPOSANTES D'UN VECTEUR
!>                  INTERVENANT DANS LA FORMULE.
!>    </td></tr>
!>          <tr><td>W1,2,3
!></td><td>--></td><td>VECTEUR RESULTAT SOUS FORME NON ASSEMBLEE.
!>    </td></tr>
!>          <tr><td>W2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>W3
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>XEL,YEL,
!></td><td>--></td><td>COORDONNEES DES POINTS DANS L'ELEMENT
!>    </td></tr>
!>          <tr><td>XMUL
!></td><td>--></td><td>COEFFICIENT MULTIPLICATEUR.
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE VC09AA
     &( XMUL,SF,SG,SU,SV,F,G,U,V,
     &  XEL,YEL,IKLE1,IKLE2,IKLE3,NELEM,NELMAX,W1,W2,W3 )
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| F,G,H          |-->| FONCTIONS INTERVENANT DANS LA FORMULE.
C| IKLE1,         |-->| PASSAGE DE LA NUMEROTATION LOCALE A GLOBALE.
C| IKLE2          |---| 
C| IKLE3          |---| 
C| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE.
C| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE.
C|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
C| SF,SG,SH       |-->| STRUCTURES DES FONCTIONS F,G ET H
C| SU,SV,SW       |-->| STRUCTURES DES FONCTIONS U,V ET W
C| SURFAC         |-->| SURFACE DES ELEMENTS.
C| U,V,W          |-->| COMPOSANTES D'UN VECTEUR
C|                |   | INTERVENANT DANS LA FORMULE.
C| W1,2,3         |-->| VECTEUR RESULTAT SOUS FORME NON ASSEMBLEE.
C| W2             |---| 
C| W3             |---| 
C| XEL,YEL,       |-->| COORDONNEES DES POINTS DANS L'ELEMENT
C| XMUL           |-->| COEFFICIENT MULTIPLICATEUR.
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE BIEF, EX_VC09AA => VC09AA
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER, INTENT(IN) :: NELEM,NELMAX
      INTEGER, INTENT(IN) :: IKLE1(NELMAX),IKLE2(NELMAX),IKLE3(NELMAX)
C
      DOUBLE PRECISION, INTENT(IN)    :: XEL(NELMAX,*),YEL(NELMAX,*)
      DOUBLE PRECISION, INTENT(INOUT) ::W1(NELMAX),W2(NELMAX),W3(NELMAX)
      DOUBLE PRECISION, INTENT(IN)    :: XMUL
C
C     STRUCTURES OF F, G, U, V AND REAL DATA
C
      TYPE(BIEF_OBJ), INTENT(IN) :: SF,SG,SU,SV
      DOUBLE PRECISION, INTENT(IN) :: F(*),G(*),U(*),V(*)
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER IELEM,IELMF,IELMU,IELMG,IELMV
C
      DOUBLE PRECISION X2,Y2,X3,Y3,F1,F2,F3,G1,G2,G3,U1,U2,U3,V1,V2,V3
      DOUBLE PRECISION XS120,T11,T12,T13,T22,T23,T33,FTX,FTY
      DOUBLE PRECISION U123,V123
C
C-----------------------------------------------------------------------
C
      XS120 = XMUL / 120.D0
C
C-----------------------------------------------------------------------
C
      IELMF=SF%ELM
      IELMG=SG%ELM
      IELMU=SU%ELM
      IELMV=SV%ELM
C
C-----------------------------------------------------------------------
C
C     FUNCTION F AND G AND VECTOR U ARE LINEAR
C
      IF(      IELMF.EQ.11.AND.IELMG.EQ.11
     &    .AND.IELMU.EQ.11.AND.IELMV.EQ.11  ) THEN
C
      DO 3 IELEM = 1 , NELEM
C
         X2 = XEL(IELEM,2)
         X3 = XEL(IELEM,3)
         Y2 = YEL(IELEM,2)
         Y3 = YEL(IELEM,3)
C
         F1 = F(IKLE1(IELEM))
         F2 = F(IKLE2(IELEM))
         F3 = F(IKLE3(IELEM))
C
         G1 = G(IKLE1(IELEM))
         G2 = G(IKLE2(IELEM))
         G3 = G(IKLE3(IELEM))
C
         U1 = U(IKLE1(IELEM))
         U2 = U(IKLE2(IELEM))
         U3 = U(IKLE3(IELEM))
C
         V1 = V(IKLE1(IELEM))
         V2 = V(IKLE2(IELEM))
         V3 = V(IKLE3(IELEM))
C
         FTX = F1 * (X3-X2) - F2 * X3 + F3*X2
         FTY = F1 * (Y2-Y3) + F2 * Y3 - F3*Y2
C
         U123 = U1 + U2 + U3
         V123 = V1 + V2 + V3
C
         T11 = FTX * ( V123 + V1 + V1 ) + FTY * ( U123 + U1 + U1 )
         T22 = FTX * ( V123 + V2 + V2 ) + FTY * ( U123 + U2 + U2 )
         T33 = FTX * ( V123 + V3 + V3 ) + FTY * ( U123 + U3 + U3 )
C
         T12 = FTX * ( V123 + V123 - V3 ) + FTY * ( U123 + U123 - U3 )
         T13 = FTX * ( V123 + V123 - V2 ) + FTY * ( U123 + U123 - U2 )
         T23 = FTX * ( V123 + V123 - V1 ) + FTY * ( U123 + U123 - U1 )
C
         W1(IELEM) = ( 2 * G1*T11 +     G2*T12 +     G3*T13 ) * XS120
         W2(IELEM) = (     G1*T12 + 2 * G2*T22 +     G3*T23 ) * XS120
         W3(IELEM) = (     G1*T13 +     G2*T23 + 2 * G3*T33 ) * XS120
C
3     CONTINUE
C
C-----------------------------------------------------------------------
C
      ELSE
C
C-----------------------------------------------------------------------
C
       IF (LNG.EQ.1) WRITE(LU,100) IELMF,SF%NAME
       IF (LNG.EQ.1) WRITE(LU,110) IELMG,SG%NAME
       IF (LNG.EQ.1) WRITE(LU,200) IELMU,SU%NAME
       IF (LNG.EQ.1) WRITE(LU,300)
       IF (LNG.EQ.2) WRITE(LU,101) IELMF,SF%NAME
       IF (LNG.EQ.2) WRITE(LU,111) IELMG,SG%NAME
       IF (LNG.EQ.1) WRITE(LU,201) IELMU,SU%NAME
       IF (LNG.EQ.1) WRITE(LU,301)
100    FORMAT(1X,'VC09AA (BIEF) :',/,
     &        1X,'DISCRETISATION DE F : ',1I6,
     &        1X,'NOM REEL : ',A6)
110    FORMAT(1X,'DISCRETISATION DE G : ',1I6,
     &        1X,'NOM REEL : ',A6)
200    FORMAT(1X,'DISCRETISATION DE U : ',1I6,
     &        1X,'NOM REEL : ',A6)
300    FORMAT(1X,'CAS NON PREVU')
101    FORMAT(1X,'VC09AA (BIEF) :',/,
     &        1X,'DISCRETIZATION OF F:',1I6,
     &        1X,'REAL NAME: ',A6)
111    FORMAT(1X,'DISCRETIZATION OF G:',1I6,
     &        1X,'REAL NAME: ',A6)
201    FORMAT(1X,'DISCRETIZATION OF U:',1I6,
     &        1X,'REAL NAME: ',A6)
301    FORMAT(1X,'CASE NOT IMPLEMENTED')
       CALL PLANTE(0)
       STOP
C
      ENDIF
C
C-----------------------------------------------------------------------
C
      RETURN
      END


C
C#######################################################################
C