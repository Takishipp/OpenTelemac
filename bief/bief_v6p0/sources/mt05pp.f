C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       BUILDS THE MATVGR MATRIX.
!>  @code
!>    COMPUTES THE COEFFICIENTS OF THE FOLLOWING MATRIX:<br><br>
!>                       /           ->  --->
!>       A(I,J) = XMUL  /  PSI1(I) * U . GRAD(PSI2(J)) D(OMEGA)
!>                     /OMEGA<br><br>
!>    BY ELEMENTARY CELL; THE ELEMENT IS THE P1 TRIANGLE<br>
!>    J(X,Y): JACOBIAN OF THE ISOPARAMETRIC TRANSFORMATION
!>  @endcode

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @note  JMH : 09/11/2004  : ACCORDING TO JMJ PRINCIPLE NOTE, SHOULD
!>         BE PERFORMED IN THE TRANSFORMED DOMAIN. VELOCITY W SHOULD HERE
!>         BE DELTA(Z)*WSTAR. DELTAZ IS H1, H2 AND H3 HERE.

!>  @note  IF SPECAD=TRUE, THE VELOCITY FIELD IS U+F*GRAD(G).

!>  @warning  THE JACOBIAN MUST BE POSITIVE

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Use(s)
!><br>BIEF
!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> F, G, H, IKLE, NELEM, NELMAX, SF, SG, SH, SIGMAG, SPECAD, SU, SURFAC, SV, SW, T, U, V, W, X, XM, XMUL, Y, Z
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> DEN, DET, DZ1, DZ2, DZ3, G2, G3, GRADGX, GRADGY, H1, H2, H3, HH1, HH2, HH3, HT, HU1I3S, HU1S3I, HU1SI, HU2I3S, HU2S3I, HU2SI, HU3I3S, HU3S3I, HU3SI, HV1I3S, HV1S3I, HV1SI, HV2I3S, HV2S3I, HV2SI, HV3I3S, HV3S3I, HV3SI, I1, I2, I3, I4, I5, I6, IELEM, IELEM2, IELEM3, INT1, NELEM2, PX1, PX2, PX3, PY1, PY2, PY3, PZ1, Q1, Q2, Q3, SHUI, SHUI1, SHUI2, SHUI3, SHUS, SHUS1, SHUS2, SHUS3, SHVI, SHVI1, SHVI2, SHVI3, SHVS, SHVS1, SHVS2, SHVS3, SUI, SUS, SVI, SVS, U1, U2, U3, U4, U5, U6, V1, V2, V3, V4, V5, V6, X2, X3, Y2, Y3
!>   </td></tr>
!>     <tr><th> Alias(es)
!>    </th><td> EX_MT05PP
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> NBPTS(), PLANTE()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>MATRIY()

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
!>      <td><center> 5.7                                       </center>
!> </td><td> 26/06/06
!> </td><td> J-M HERVOUET (LNHE) 01 30 87 80 18
!> </td><td>
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>A11,A12
!></td><td><--</td><td>ELEMENTS DE LA MATRICE
!>    </td></tr>
!>          <tr><td>F,G,H
!></td><td>--></td><td>FONCTIONS INTERVENANT DANS LE CALCUL DE LA
!>                  MATRICE.
!>    </td></tr>
!>          <tr><td>IKLE
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IKLE1
!></td><td>--></td><td>PASSAGE DE LA NUMEROTATION LOCALE A GLOBALE
!>    </td></tr>
!>          <tr><td>NELEM
!></td><td>--></td><td>NOMBRE D'ELEMENTS DU MAILLAGE
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>--></td><td>NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE
!>                  (CAS D'UN MAILLAGE ADAPTATIF)
!>    </td></tr>
!>          <tr><td>SF,SG,SH
!></td><td>--></td><td>STRUCTURES DE F,G ET H.
!>    </td></tr>
!>          <tr><td>SIGMAG
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>SPECAD
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>SU,SV,SW
!></td><td>--></td><td>STRUCTURES DE U,V ET W.
!>    </td></tr>
!>          <tr><td>SURFAC
!></td><td>--></td><td>SURFACE DES TRIANGLES.
!>    </td></tr>
!>          <tr><td>T
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>U,V,W
!></td><td>--></td><td>COMPOSANTES D'UN VECTEUR INTERVENANT DANS LE
!>                  CALCUL DE LA MATRICE.
!>    </td></tr>
!>          <tr><td>X,Y,Z
!></td><td>--></td><td>COORDONNEES DES POINTS DANS L'ELEMENT
!>    </td></tr>
!>          <tr><td>XM
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>XMUL
!></td><td>--></td><td>FACTEUR MULTIPLICATIF
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE MT05PP
     &(T,XM,XMUL,SU,SV,SW,U,V,W,SF,SG,SH,F,G,H,
     & X,Y,Z,IKLE,NELEM,NELMAX,SURFAC,SIGMAG,SPECAD)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| A11,A12        |<--| ELEMENTS DE LA MATRICE
C| F,G,H          |-->| FONCTIONS INTERVENANT DANS LE CALCUL DE LA
C|                |   | MATRICE.
C| IKLE           |---| 
C| IKLE1          |-->| PASSAGE DE LA NUMEROTATION LOCALE A GLOBALE
C| NELEM          |-->| NOMBRE D'ELEMENTS DU MAILLAGE
C| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DU MAILLAGE
C|                |   | (CAS D'UN MAILLAGE ADAPTATIF)
C| SF,SG,SH       |-->| STRUCTURES DE F,G ET H.
C| SIGMAG         |---| 
C| SPECAD         |---| 
C| SU,SV,SW       |-->| STRUCTURES DE U,V ET W.
C| SURFAC         |-->| SURFACE DES TRIANGLES.
C| T             |---| 
C| U,V,W          |-->| COMPOSANTES D'UN VECTEUR INTERVENANT DANS LE
C|                |   | CALCUL DE LA MATRICE.
C| X,Y,Z          |-->| COORDONNEES DES POINTS DANS L'ELEMENT
C| XM             |---| 
C| XMUL           |-->| FACTEUR MULTIPLICATIF
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE BIEF, EX_MT05PP => MT05PP
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER, INTENT(IN)             :: NELEM,NELMAX
      INTEGER, INTENT(IN)             :: IKLE(NELMAX,6)
C
      DOUBLE PRECISION, INTENT(INOUT) :: T(NELMAX,6),XM(NELMAX,30)
C
      DOUBLE PRECISION, INTENT(IN)    :: XMUL
      DOUBLE PRECISION, INTENT(IN)    :: U(*),V(*),W(*),SURFAC(*)
      DOUBLE PRECISION, INTENT(IN)    :: F(*),G(*),H(*)
C
C     STRUCTURES OF U, V, W
C
      TYPE(BIEF_OBJ), INTENT(IN)      :: SU,SV,SW,SF,SG,SH
C
      DOUBLE PRECISION, INTENT(IN)    :: X(*),Y(*),Z(*)
      LOGICAL, INTENT(IN)             :: SIGMAG,SPECAD
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
C     DECLARATIONS SPECIFIC TO THIS SUBROUTINE
C
      DOUBLE PRECISION INT1,X2,X3,Y2,Y3,DEN,DET,G2,G3,GRADGX,GRADGY
      DOUBLE PRECISION PZ1,PX1,PX2,PX3,PY1,PY2,PY3
      DOUBLE PRECISION U1,U2,U3,U4,U5,U6,V1,V2,V3,V4,V5,V6
      DOUBLE PRECISION Q1,Q2,Q3,H1,H2,H3,HT
      DOUBLE PRECISION SUS,SUI,SHUI,SHUS
      DOUBLE PRECISION SHUI1,SHUS1,SHUI2,SHUS2,SHUI3,SHUS3
      DOUBLE PRECISION HU1S3I,HU1I3S,HU1SI,HU2S3I,HU2I3S,HU2SI
      DOUBLE PRECISION HU3S3I,HU3I3S,HU3SI
      DOUBLE PRECISION SVS,SVI,SHVI,SHVS
      DOUBLE PRECISION SHVI1,SHVS1,SHVI2,SHVS2,SHVI3,SHVS3
      DOUBLE PRECISION HV1S3I,HV1I3S,HV1SI,HV2S3I,HV2I3S,HV2SI
      DOUBLE PRECISION HV3S3I,HV3I3S,HV3SI,HH1,HH2,HH3,DZ1,DZ2,DZ3
C
      INTEGER I1,I2,I3,I4,I5,I6,IELEM,IELEM2,IELEM3,NELEM2
C
C**********************************************************************
C
      IF(SU%ELM.NE.41) THEN
        IF (LNG.EQ.1) WRITE(LU,1000) SU%ELM
        IF (LNG.EQ.2) WRITE(LU,1001) SU%ELM
1000    FORMAT(1X,'MT05PP (BIEF) : TYPE DE U NON PREVU : ',I6)
1001    FORMAT(1X,'MT05PP (BIEF) : TYPE OF U NOT IMPLEMENTED: ',I6)
        CALL PLANTE(1)
        STOP
      ENDIF
      IF(SV%ELM.NE.41) THEN
        IF (LNG.EQ.1) WRITE(LU,2000) SV%ELM
        IF (LNG.EQ.2) WRITE(LU,2001) SV%ELM
2000    FORMAT(1X,'MT05PP (BIEF) : TYPE DE V NON PREVU : ',I6)
2001    FORMAT(1X,'MT05PP (BIEF) : TYPE OF V NOT IMPLEMENTED: ',I6)
        CALL PLANTE(1)
        STOP
      ENDIF
C     IN FACT W DEFINED PER LAYER BUT DECLARED 41
      IF(SW%ELM.NE.41) THEN
        IF (LNG.EQ.1) WRITE(LU,3000) SW%ELM
        IF (LNG.EQ.2) WRITE(LU,3001) SW%ELM
3000    FORMAT(1X,'MT05PP (BIEF) : TYPE DE W NON PREVU : ',I6)
3001    FORMAT(1X,'MT05PP (BIEF) : TYPE OF W NOT IMPLEMENTED: ',I6)
        CALL PLANTE(1)
        STOP
      ENDIF
C
C-----------------------------------------------------------------------
C
C     WITH NORMAL SIGMA TRANSFORMATION
C
      IF(.NOT.SIGMAG) THEN
C
C     LOOP ON THE ELEMENTS
C
C     STANDARD CASE
C
      IF(.NOT.SPECAD) THEN
C
      DO IELEM=1,NELEM
C
         I1 = IKLE(IELEM,1)
         I2 = IKLE(IELEM,2)
         I3 = IKLE(IELEM,3)
         I4 = IKLE(IELEM,4)
         I5 = IKLE(IELEM,5)
         I6 = IKLE(IELEM,6)
C
         X2  =   X(I2) - X(I1)
         X3  =   X(I3) - X(I1)
         Y2  =   Y(I2) - Y(I1)
         Y3  =   Y(I3) - Y(I1)
C
         U1  =  U(I1)
         U2  =  U(I2)
         U3  =  U(I3)
         U4  =  U(I4)
         U5  =  U(I5)
         U6  =  U(I6)
         V1  =  V(I1)
         V2  =  V(I2)
         V3  =  V(I3)
         V4  =  V(I4)
         V5  =  V(I5)
         V6  =  V(I6)
         Q1  =  W(I1)
         Q2  =  W(I2)
         Q3  =  W(I3)
C
         H1  =  Z(I4)-Z(I1)
         H2  =  Z(I5)-Z(I2)
         H3  =  Z(I6)-Z(I3)
C
C    INTERMEDIATE COMPUTATIONS
C
         DEN=XMUL/1440.D0
         PX2=Y3*DEN
         PX3=-Y2*DEN
         PX1=-PX2-PX3
         PY2=-X3*DEN
         PY3=X2*DEN
         PY1=-PY3-PY2
C
         HT = H1+H2+H3
         SUS = U6+U5+U4
         SUI = U3+U2+U1
         SHUI = H3*U3+H2*U2+H1*U1
         SHUS = H3*U6+H2*U5+H1*U4
         SHUS1 = (HT+H1)*(SUS+U4)+SHUS+U4*H1
         SHUI1 = (HT+H1)*(SUI+U1)+SHUI+U1*H1
         SHUS2 = (HT+H2)*(SUS+U5)+SHUS+U5*H2
         SHUI2 = (HT+H2)*(SUI+U2)+SHUI+U2*H2
         SHUS3 = (HT+H3)*(SUS+U6)+SHUS+U6*H3
         SHUI3 = (HT+H3)*(SUI+U3)+SHUI+U3*H3
         HU1S3I = SHUS1+3*SHUI1
         HU1I3S = SHUI1+3*SHUS1
         HU1SI = SHUS1+SHUI1
         HU2S3I = SHUS2+3*SHUI2
         HU2I3S = SHUI2+3*SHUS2
         HU2SI = SHUS2+SHUI2
         HU3S3I = SHUS3+3*SHUI3
         HU3I3S = SHUI3+3*SHUS3
         HU3SI = SHUS3+SHUI3
C
         SVS = V6+V5+V4
         SVI = V3+V2+V1
         SHVI = H3*V3+H2*V2+H1*V1
         SHVS = H3*V6+H2*V5+H1*V4
         SHVS1  = (HT+H1)*(SVS+V4)+SHVS+V4*H1
         SHVI1  = (HT+H1)*(SVI+V1)+SHVI+V1*H1
         SHVS2  = (HT+H2)*(SVS+V5)+SHVS+V5*H2
         SHVI2  = (HT+H2)*(SVI+V2)+SHVI+V2*H2
         SHVS3  = (HT+H3)*(SVS+V6)+SHVS+V6*H3
         SHVI3  = (HT+H3)*(SVI+V3)+SHVI+V3*H3
         HV1S3I = SHVS1+3*SHVI1
         HV1I3S = SHVI1+3*SHVS1
         HV1SI  = SHVS1+  SHVI1
         HV2S3I = SHVS2+3*SHVI2
         HV2I3S = SHVI2+3*SHVS2
         HV2SI  = SHVS2+  SHVI2
         HV3S3I = SHVS3+3*SHVI3
         HV3I3S = SHVI3+3*SHVS3
         HV3SI  = SHVS3+  SHVI3
C
C        OPTION WITH MASS-LUMPING ON VERTICAL VELOCITIES
C        COMPATIBILITY WITH TRIDW2 (LUMPING TO COMPUTE DELTA(Z)*WSTAR)
C
         PZ1=-DEN*(X2*Y3-Y2*X3)*30
C
         T(IELEM,1)=PZ1*2*Q1
         XM(IELEM,3) =-T(IELEM,1)
         XM(IELEM,18)= T(IELEM,1)
         T(IELEM,4)  =-T(IELEM,1)
!
         T(IELEM,2)=PZ1*2*Q2
         XM(IELEM,8) =-T(IELEM,2)
         XM(IELEM,23)= T(IELEM,2)
         T(IELEM,5)  =-T(IELEM,2)
!
         T(IELEM,3)=PZ1*2*Q3
         XM(IELEM,12)=-T(IELEM,3)
         XM(IELEM,27)= T(IELEM,3)
         T(IELEM,6)  =-T(IELEM,3)
!
         XM(IELEM,16)=PZ1*Q1
         XM(IELEM,7) =-XM(IELEM,16)
         XM(IELEM,17)= XM(IELEM,16)
         XM(IELEM,10)=-XM(IELEM,16)
         XM(IELEM,19)= XM(IELEM,16)
         XM(IELEM,28)=-XM(IELEM,16)
         XM(IELEM,20)= XM(IELEM,16)
         XM(IELEM,29)=-XM(IELEM,16)
!
         XM(IELEM,1)=PZ1*Q2
         XM(IELEM,4) =-XM(IELEM,1)
         XM(IELEM,22)= XM(IELEM,1)
         XM(IELEM,13)=-XM(IELEM,1)
         XM(IELEM,21)= XM(IELEM,1)
         XM(IELEM,11)=-XM(IELEM,1)
         XM(IELEM,24)= XM(IELEM,1)
         XM(IELEM,30)=-XM(IELEM,1)
!
         XM(IELEM,2)=PZ1*Q3
         XM(IELEM,5)=-XM(IELEM,2)
         XM(IELEM,25)=XM(IELEM,2)
         XM(IELEM,14)=-XM(IELEM,2)
         XM(IELEM,26)=XM(IELEM,2)
         XM(IELEM,15)=-XM(IELEM,2)
         XM(IELEM,6)=XM(IELEM,2)
         XM(IELEM,9)=-XM(IELEM,2)
C
         T(IELEM,1)=T(IELEM,1)+PX1*HU1S3I+PY1*HV1S3I
         T(IELEM,2)=T(IELEM,2)+PX2*HU2S3I+PY2*HV2S3I
         T(IELEM,3)=T(IELEM,3)+PX3*HU3S3I+PY3*HV3S3I
         T(IELEM,4)=T(IELEM,4)+PX1*HU1I3S+PY1*HV1I3S
         T(IELEM,5)=T(IELEM,5)+PX2*HU2I3S+PY2*HV2I3S
         T(IELEM,6)=T(IELEM,6)+PX3*HU3I3S+PY3*HV3I3S
C
         XM(IELEM,01)=XM(IELEM,01)+PX2*HU1S3I+PY2*HV1S3I
         XM(IELEM,02)=XM(IELEM,02)+PX3*HU1S3I+PY3*HV1S3I
         XM(IELEM,03)=XM(IELEM,03)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,04)=XM(IELEM,04)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,05)=XM(IELEM,05)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,06)=XM(IELEM,06)+PX3*HU2S3I+PY3*HV2S3I
         XM(IELEM,07)=XM(IELEM,07)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,08)=XM(IELEM,08)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,09)=XM(IELEM,09)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,10)=XM(IELEM,10)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,11)=XM(IELEM,11)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,12)=XM(IELEM,12)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,13)=XM(IELEM,13)+PX2*HU1I3S+PY2*HV1I3S
         XM(IELEM,14)=XM(IELEM,14)+PX3*HU1I3S+PY3*HV1I3S
         XM(IELEM,15)=XM(IELEM,15)+PX3*HU2I3S+PY3*HV2I3S
         XM(IELEM,16)=XM(IELEM,16)+PX1*HU2S3I+PY1*HV2S3I
         XM(IELEM,17)=XM(IELEM,17)+PX1*HU3S3I+PY1*HV3S3I
         XM(IELEM,18)=XM(IELEM,18)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,19)=XM(IELEM,19)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,20)=XM(IELEM,20)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,21)=XM(IELEM,21)+PX2*HU3S3I+PY2*HV3S3I
         XM(IELEM,22)=XM(IELEM,22)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,23)=XM(IELEM,23)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,24)=XM(IELEM,24)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,25)=XM(IELEM,25)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,26)=XM(IELEM,26)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,27)=XM(IELEM,27)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,28)=XM(IELEM,28)+PX1*HU2I3S+PY1*HV2I3S
         XM(IELEM,29)=XM(IELEM,29)+PX1*HU3I3S+PY1*HV3I3S
         XM(IELEM,30)=XM(IELEM,30)+PX2*HU3I3S+PY2*HV3I3S
C
      ENDDO
C
      ELSE
C
C     WITH SPECIFIC ADVECTING FIELD
C
      NELEM2 = NBPTS(10)
C
      DO IELEM=1,NELEM
C
         I1 = IKLE(IELEM,1)
         I2 = IKLE(IELEM,2)
         I3 = IKLE(IELEM,3)
         I4 = IKLE(IELEM,4)
         I5 = IKLE(IELEM,5)
         I6 = IKLE(IELEM,6)
C
         X2  =   X(I2) - X(I1)
         X3  =   X(I3) - X(I1)
         Y2  =   Y(I2) - Y(I1)
         Y3  =   Y(I3) - Y(I1)
C
         DET= X2*Y3-X3*Y2
         IELEM2 = MOD(IELEM-1,NELEM2) + 1
C        G IS PIECE-WISE LINEAR
C        IT IS ZCONV IN TELEMAC-3D
         G2 = G(IELEM2+NELEM2)-G(IELEM2)
         G3 = G(IELEM2+2*NELEM2)-G(IELEM2)
         GRADGX=(G2*Y3-G3*Y2)/DET
         GRADGY=(X2*G3-X3*G2)/DET
C
         U1=U(I1)+F(I1)*GRADGX
         U2=U(I2)+F(I2)*GRADGX
         U3=U(I3)+F(I3)*GRADGX
         U4=U(I4)+F(I4)*GRADGX
         U5=U(I5)+F(I5)*GRADGX
         U6=U(I6)+F(I6)*GRADGX
         V1=V(I1)+F(I1)*GRADGY
         V2=V(I2)+F(I2)*GRADGY
         V3=V(I3)+F(I3)*GRADGY
         V4=V(I4)+F(I4)*GRADGY
         V5=V(I5)+F(I5)*GRADGY
         V6=V(I6)+F(I6)*GRADGY
C
         Q1  =  W(I1)
         Q2  =  W(I2)
         Q3  =  W(I3)
C
         H1  =  Z(I4)-Z(I1)
         H2  =  Z(I5)-Z(I2)
         H3  =  Z(I6)-Z(I3)
C
C    INTERMEDIATE COMPUTATIONS
C
         DEN=XMUL/1440.D0
         PX2=Y3*DEN
         PX3=-Y2*DEN
         PX1=-PX2-PX3
         PY2=-X3*DEN
         PY3=X2*DEN
         PY1=-PY3-PY2
C
         HT = H1+H2+H3
         SUS = U6+U5+U4
         SUI = U3+U2+U1
         SHUI = H3*U3+H2*U2+H1*U1
         SHUS = H3*U6+H2*U5+H1*U4
         SHUS1 = (HT+H1)*(SUS+U4)+SHUS+U4*H1
         SHUI1 = (HT+H1)*(SUI+U1)+SHUI+U1*H1
         SHUS2 = (HT+H2)*(SUS+U5)+SHUS+U5*H2
         SHUI2 = (HT+H2)*(SUI+U2)+SHUI+U2*H2
         SHUS3 = (HT+H3)*(SUS+U6)+SHUS+U6*H3
         SHUI3 = (HT+H3)*(SUI+U3)+SHUI+U3*H3
         HU1S3I = SHUS1+3*SHUI1
         HU1I3S = SHUI1+3*SHUS1
         HU1SI = SHUS1+SHUI1
         HU2S3I = SHUS2+3*SHUI2
         HU2I3S = SHUI2+3*SHUS2
         HU2SI = SHUS2+SHUI2
         HU3S3I = SHUS3+3*SHUI3
         HU3I3S = SHUI3+3*SHUS3
         HU3SI = SHUS3+SHUI3
C
         SVS = V6+V5+V4
         SVI = V3+V2+V1
         SHVI = H3*V3+H2*V2+H1*V1
         SHVS = H3*V6+H2*V5+H1*V4
         SHVS1  = (HT+H1)*(SVS+V4)+SHVS+V4*H1
         SHVI1  = (HT+H1)*(SVI+V1)+SHVI+V1*H1
         SHVS2  = (HT+H2)*(SVS+V5)+SHVS+V5*H2
         SHVI2  = (HT+H2)*(SVI+V2)+SHVI+V2*H2
         SHVS3  = (HT+H3)*(SVS+V6)+SHVS+V6*H3
         SHVI3  = (HT+H3)*(SVI+V3)+SHVI+V3*H3
         HV1S3I = SHVS1+3*SHVI1
         HV1I3S = SHVI1+3*SHVS1
         HV1SI  = SHVS1+  SHVI1
         HV2S3I = SHVS2+3*SHVI2
         HV2I3S = SHVI2+3*SHVS2
         HV2SI  = SHVS2+  SHVI2
         HV3S3I = SHVS3+3*SHVI3
         HV3I3S = SHVI3+3*SHVS3
         HV3SI  = SHVS3+  SHVI3
C
C        OPTION WITH MASS-LUMPING ON VERTICAL VELOCITIES
C        COMPATIBILITY WITH TRIDW2 (LUMPING TO COMPUTE DELTA(Z)*WSTAR)
C
         PZ1=-DEN*(X2*Y3-Y2*X3)*30
C
         INT1=PZ1*2*Q1
         T(IELEM,1)=INT1
         XM(IELEM,3)=-INT1
         XM(IELEM,18)=INT1
         T(IELEM,4)=-INT1
!
         INT1=PZ1*2*Q2
         T(IELEM,2)=INT1
         XM(IELEM,8)= -INT1
         XM(IELEM,23)=INT1
         T(IELEM,5)=-INT1
!
         INT1=PZ1*2*Q3
         T(IELEM,3)=INT1
         XM(IELEM,12)=-INT1
         XM(IELEM,27)=INT1
         T(IELEM,6)=-INT1
!
         INT1=PZ1*Q1
         XM(IELEM,16)=INT1
         XM(IELEM,7)=-INT1
         XM(IELEM,17)=INT1
         XM(IELEM,10)=-INT1
         XM(IELEM,19)=INT1
         XM(IELEM,28)=-INT1
         XM(IELEM,20)=INT1
         XM(IELEM,29)=-INT1
!
         INT1=PZ1*Q2
         XM(IELEM,1)=INT1
         XM(IELEM,4)=-INT1
         XM(IELEM,22)=INT1
         XM(IELEM,13)=-INT1
         XM(IELEM,21)=INT1
         XM(IELEM,11)=-INT1
         XM(IELEM,24)=INT1
         XM(IELEM,30)=-INT1
!
         INT1=PZ1*Q3
         XM(IELEM,2)=INT1
         XM(IELEM,5)=-INT1
         XM(IELEM,25)=INT1
         XM(IELEM,14)=-INT1
         XM(IELEM,26)=INT1
         XM(IELEM,15)=-INT1
         XM(IELEM,6)=INT1
         XM(IELEM,9)=-INT1
C
         T(IELEM,1)=T(IELEM,1)+PX1*HU1S3I+PY1*HV1S3I
         T(IELEM,2)=T(IELEM,2)+PX2*HU2S3I+PY2*HV2S3I
         T(IELEM,3)=T(IELEM,3)+PX3*HU3S3I+PY3*HV3S3I
         T(IELEM,4)=T(IELEM,4)+PX1*HU1I3S+PY1*HV1I3S
         T(IELEM,5)=T(IELEM,5)+PX2*HU2I3S+PY2*HV2I3S
         T(IELEM,6)=T(IELEM,6)+PX3*HU3I3S+PY3*HV3I3S
C
         XM(IELEM,01)=XM(IELEM,01)+PX2*HU1S3I+PY2*HV1S3I
         XM(IELEM,02)=XM(IELEM,02)+PX3*HU1S3I+PY3*HV1S3I
         XM(IELEM,03)=XM(IELEM,03)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,04)=XM(IELEM,04)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,05)=XM(IELEM,05)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,06)=XM(IELEM,06)+PX3*HU2S3I+PY3*HV2S3I
         XM(IELEM,07)=XM(IELEM,07)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,08)=XM(IELEM,08)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,09)=XM(IELEM,09)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,10)=XM(IELEM,10)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,11)=XM(IELEM,11)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,12)=XM(IELEM,12)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,13)=XM(IELEM,13)+PX2*HU1I3S+PY2*HV1I3S
         XM(IELEM,14)=XM(IELEM,14)+PX3*HU1I3S+PY3*HV1I3S
         XM(IELEM,15)=XM(IELEM,15)+PX3*HU2I3S+PY3*HV2I3S
         XM(IELEM,16)=XM(IELEM,16)+PX1*HU2S3I+PY1*HV2S3I
         XM(IELEM,17)=XM(IELEM,17)+PX1*HU3S3I+PY1*HV3S3I
         XM(IELEM,18)=XM(IELEM,18)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,19)=XM(IELEM,19)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,20)=XM(IELEM,20)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,21)=XM(IELEM,21)+PX2*HU3S3I+PY2*HV3S3I
         XM(IELEM,22)=XM(IELEM,22)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,23)=XM(IELEM,23)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,24)=XM(IELEM,24)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,25)=XM(IELEM,25)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,26)=XM(IELEM,26)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,27)=XM(IELEM,27)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,28)=XM(IELEM,28)+PX1*HU2I3S+PY1*HV2I3S
         XM(IELEM,29)=XM(IELEM,29)+PX1*HU3I3S+PY1*HV3I3S
         XM(IELEM,30)=XM(IELEM,30)+PX2*HU3I3S+PY2*HV3I3S
C
      ENDDO
C
      ENDIF
C
C-----------------------------------------------------------------------
C
C     WITH GENERALIZED SIGMA TRANSFORMATION
C
      ELSE
C
      IF(SPECAD) THEN
        IF (LNG.EQ.1) WRITE(LU,201)
        IF (LNG.EQ.2) WRITE(LU,202)
201     FORMAT(1X,'MT05PP (BIEF) :',/,
     &         1X,'SIGMAG=T ET SPECAD=T : ',1I6,' CAS NON PREVU',/,
     &         1X,'NOM REEL DE U : ',A6)
202     FORMAT(1X,'MT05PP (BIEF) :',/,
     &         1X,'SIGMAG=T AND SPECAD=T : ',1I6,' NOT IMPLEMENTED',/,
     &         1X,'REAL NAME OF U : ',A6)
        CALL PLANTE(1)
        STOP
      ENDIF
C
      NELEM2 = NBPTS(10)
C
      DO IELEM=1,NELEM
C
         IELEM2 = MOD(IELEM-1,NELEM2) + 1
         IELEM3 = NELEM - NELEM2 + IELEM2
C
         I1 = IKLE(IELEM,1)
         I2 = IKLE(IELEM,2)
         I3 = IKLE(IELEM,3)
         I4 = IKLE(IELEM,4)
         I5 = IKLE(IELEM,5)
         I6 = IKLE(IELEM,6)
C
C        COMPUTES DELTA Z
C
         DZ1 = Z(I4) - Z(I1)
         DZ2 = Z(I5) - Z(I2)
         DZ3 = Z(I6) - Z(I3)
C
C        COMPUTES WATER DEPTH
C
         H1 = Z(IKLE(IELEM3,4))-Z(IKLE(IELEM2,1))
         H2 = Z(IKLE(IELEM3,5))-Z(IKLE(IELEM2,2))
         H3 = Z(IKLE(IELEM3,6))-Z(IKLE(IELEM2,3))
C
         HH1=MAX(H1,1.D-6)
         HH2=MAX(H2,1.D-6)
         HH3=MAX(H3,1.D-6)
C
         X2  =   X(I2) - X(I1)
         X3  =   X(I3) - X(I1)
         Y2  =   Y(I2) - Y(I1)
         Y3  =   Y(I3) - Y(I1)
C
         U1=DZ1*U(I1)/HH1
         U2=DZ2*U(I2)/HH2
         U3=DZ3*U(I3)/HH3
         U4=DZ1*U(I4)/HH1
         U5=DZ2*U(I5)/HH2
         U6=DZ3*U(I6)/HH3
         V1=DZ1*V(I1)/HH1
         V2=DZ2*V(I2)/HH2
         V3=DZ3*V(I3)/HH3
         V4=DZ1*V(I4)/HH1
         V5=DZ2*V(I5)/HH2
         V6=DZ3*V(I6)/HH3
C
         Q1  =  W(I1)
         Q2  =  W(I2)
         Q3  =  W(I3)
C
C    INTERMEDIATE COMPUTATIONS
C
         DEN=XMUL/1440.D0
         PX2=Y3*DEN
         PX3=-Y2*DEN
         PX1=-PX2-PX3
         PY2=-X3*DEN
         PY3=X2*DEN
         PY1=-PY3-PY2
C
         HT = H1+H2+H3
         SUS = U6+U5+U4
         SUI = U3+U2+U1
         SHUI = H3*U3+H2*U2+H1*U1
         SHUS = H3*U6+H2*U5+H1*U4
         SHUS1 = (HT+H1)*(SUS+U4)+SHUS+U4*H1
         SHUI1 = (HT+H1)*(SUI+U1)+SHUI+U1*H1
         SHUS2 = (HT+H2)*(SUS+U5)+SHUS+U5*H2
         SHUI2 = (HT+H2)*(SUI+U2)+SHUI+U2*H2
         SHUS3 = (HT+H3)*(SUS+U6)+SHUS+U6*H3
         SHUI3 = (HT+H3)*(SUI+U3)+SHUI+U3*H3
         HU1S3I = SHUS1+3*SHUI1
         HU1I3S = SHUI1+3*SHUS1
         HU1SI = SHUS1+SHUI1
         HU2S3I = SHUS2+3*SHUI2
         HU2I3S = SHUI2+3*SHUS2
         HU2SI = SHUS2+SHUI2
         HU3S3I = SHUS3+3*SHUI3
         HU3I3S = SHUI3+3*SHUS3
         HU3SI = SHUS3+SHUI3
C
         SVS = V6+V5+V4
         SVI = V3+V2+V1
         SHVI = H3*V3+H2*V2+H1*V1
         SHVS = H3*V6+H2*V5+H1*V4
         SHVS1  = (HT+H1)*(SVS+V4)+SHVS+V4*H1
         SHVI1  = (HT+H1)*(SVI+V1)+SHVI+V1*H1
         SHVS2  = (HT+H2)*(SVS+V5)+SHVS+V5*H2
         SHVI2  = (HT+H2)*(SVI+V2)+SHVI+V2*H2
         SHVS3  = (HT+H3)*(SVS+V6)+SHVS+V6*H3
         SHVI3  = (HT+H3)*(SVI+V3)+SHVI+V3*H3
         HV1S3I = SHVS1+3*SHVI1
         HV1I3S = SHVI1+3*SHVS1
         HV1SI  = SHVS1+  SHVI1
         HV2S3I = SHVS2+3*SHVI2
         HV2I3S = SHVI2+3*SHVS2
         HV2SI  = SHVS2+  SHVI2
         HV3S3I = SHVS3+3*SHVI3
         HV3I3S = SHVI3+3*SHVS3
         HV3SI  = SHVS3+  SHVI3
C
C        OPTION WITH MASS-LUMPING ON VERTICAL VELOCITIES
C        COMPATIBILITY WITH TRIDW2 (LUMPING TO COMPUTE DELTA(Z)*WSTAR)
C
         PZ1=-DEN*(X2*Y3-Y2*X3)*30
C
         INT1=PZ1*2*Q1
         T(IELEM,1)=INT1
         XM(IELEM,3)=-INT1
         XM(IELEM,18)=INT1
         T(IELEM,4)=-INT1
!
         INT1=PZ1*2*Q2
         T(IELEM,2)=INT1
         XM(IELEM,8)= -INT1
         XM(IELEM,23)=INT1
         T(IELEM,5)=-INT1
!
         INT1=PZ1*2*Q3
         T(IELEM,3)=INT1
         XM(IELEM,12)=-INT1
         XM(IELEM,27)=INT1
         T(IELEM,6)=-INT1
!
         INT1=PZ1*Q1
         XM(IELEM,16)=INT1
         XM(IELEM,7)=-INT1
         XM(IELEM,17)=INT1
         XM(IELEM,10)=-INT1
         XM(IELEM,19)=INT1
         XM(IELEM,28)=-INT1
         XM(IELEM,20)=INT1
         XM(IELEM,29)=-INT1
!
         INT1=PZ1*Q2
         XM(IELEM,1)=INT1
         XM(IELEM,4)=-INT1
         XM(IELEM,22)=INT1
         XM(IELEM,13)=-INT1
         XM(IELEM,21)=INT1
         XM(IELEM,11)=-INT1
         XM(IELEM,24)=INT1
         XM(IELEM,30)=-INT1
!
         INT1=PZ1*Q3
         XM(IELEM,2)=INT1
         XM(IELEM,5)=-INT1
         XM(IELEM,25)=INT1
         XM(IELEM,14)=-INT1
         XM(IELEM,26)=INT1
         XM(IELEM,15)=-INT1
         XM(IELEM,6)=INT1
         XM(IELEM,9)=-INT1
C
         T(IELEM,1)=T(IELEM,1)+PX1*HU1S3I+PY1*HV1S3I
         T(IELEM,2)=T(IELEM,2)+PX2*HU2S3I+PY2*HV2S3I
         T(IELEM,3)=T(IELEM,3)+PX3*HU3S3I+PY3*HV3S3I
         T(IELEM,4)=T(IELEM,4)+PX1*HU1I3S+PY1*HV1I3S
         T(IELEM,5)=T(IELEM,5)+PX2*HU2I3S+PY2*HV2I3S
         T(IELEM,6)=T(IELEM,6)+PX3*HU3I3S+PY3*HV3I3S
C
         XM(IELEM,01)=XM(IELEM,01)+PX2*HU1S3I+PY2*HV1S3I
         XM(IELEM,02)=XM(IELEM,02)+PX3*HU1S3I+PY3*HV1S3I
         XM(IELEM,03)=XM(IELEM,03)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,04)=XM(IELEM,04)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,05)=XM(IELEM,05)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,06)=XM(IELEM,06)+PX3*HU2S3I+PY3*HV2S3I
         XM(IELEM,07)=XM(IELEM,07)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,08)=XM(IELEM,08)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,09)=XM(IELEM,09)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,10)=XM(IELEM,10)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,11)=XM(IELEM,11)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,12)=XM(IELEM,12)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,13)=XM(IELEM,13)+PX2*HU1I3S+PY2*HV1I3S
         XM(IELEM,14)=XM(IELEM,14)+PX3*HU1I3S+PY3*HV1I3S
         XM(IELEM,15)=XM(IELEM,15)+PX3*HU2I3S+PY3*HV2I3S
         XM(IELEM,16)=XM(IELEM,16)+PX1*HU2S3I+PY1*HV2S3I
         XM(IELEM,17)=XM(IELEM,17)+PX1*HU3S3I+PY1*HV3S3I
         XM(IELEM,18)=XM(IELEM,18)+PX1*HU1SI +PY1*HV1SI
         XM(IELEM,19)=XM(IELEM,19)+PX1*HU2SI +PY1*HV2SI
         XM(IELEM,20)=XM(IELEM,20)+PX1*HU3SI +PY1*HV3SI
         XM(IELEM,21)=XM(IELEM,21)+PX2*HU3S3I+PY2*HV3S3I
         XM(IELEM,22)=XM(IELEM,22)+PX2*HU1SI +PY2*HV1SI
         XM(IELEM,23)=XM(IELEM,23)+PX2*HU2SI +PY2*HV2SI
         XM(IELEM,24)=XM(IELEM,24)+PX2*HU3SI +PY2*HV3SI
         XM(IELEM,25)=XM(IELEM,25)+PX3*HU1SI +PY3*HV1SI
         XM(IELEM,26)=XM(IELEM,26)+PX3*HU2SI +PY3*HV2SI
         XM(IELEM,27)=XM(IELEM,27)+PX3*HU3SI +PY3*HV3SI
         XM(IELEM,28)=XM(IELEM,28)+PX1*HU2I3S+PY1*HV2I3S
         XM(IELEM,29)=XM(IELEM,29)+PX1*HU3I3S+PY1*HV3I3S
         XM(IELEM,30)=XM(IELEM,30)+PX2*HU3I3S+PY2*HV3I3S
C
      ENDDO
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