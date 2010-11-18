C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       COMPUTES THE MEAN SPECTRAL FREQUENCY FMOY FOR ALL
!>                THE NODES IN THE 2D MESH. (THIS MEAN FREQUENCY IS
!>                IDENTICAL TO THAT COMPUTED IN FEMEAN - WAM CYCLE 4).
!>  @code
!>                     SOMME(  F(FREQ,TETA) DFREQ DTETA  )
!>             FMOY =  ----------------------------------------
!>                     SOMME(  F(FREQ,TETA)/FREQ DFREQ DTETA  )
!>  @endcode

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @note  THE HIGH-FREQUENCY PART OF THE SPECTRUM IS ONLY CONSIDERED
!>         IF THE TAIL FACTOR (TAILF) IS STRICTLY GREATER THAN 2.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> AUX1, AUX2, DFREQ, F, FMOY, FREQ, NF, NPLAN, NPOIN2, TAILF
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> AUX3, AUX4, DTETAR, IP, JF, JP, SEUIL
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>DUMP2D(), SEMIMP()

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
!>      <td><center> 1.0                                       </center>
!> </td><td> 09/02/95
!> </td><td> P. THELLIER; M. BENOIT
!> </td><td> CREATED
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>AUX1
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>AUX1(
!></td><td><-></td><td>TABLEAU DE TRAVAIL (DIMENSION NPOIN2)
!>    </td></tr>
!>          <tr><td>AUX2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>AUX2(
!></td><td><-></td><td>TABLEAU DE TRAVAIL (DIMENSION NPOIN2)
!>    </td></tr>
!>          <tr><td>DFREQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>DFREQ(
!></td><td>--></td><td>TABLEAU DES PAS DE FREQUENCE
!>    </td></tr>
!>          <tr><td>F
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>F(
!></td><td>--></td><td>SPECTRE DIRECTIONNEL DE VARIANCE
!>    </td></tr>
!>          <tr><td>FMOY
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>FMOY(
!></td><td><--</td><td>TABLEAU DES FREQUENCES MOYENNES F01
!>    </td></tr>
!>          <tr><td>FREQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>FREQ(
!></td><td>--></td><td>TABLEAU DES FREQUENCES DE DISCRETISATION
!>    </td></tr>
!>          <tr><td>NF
!></td><td>--></td><td>NOMBRE DE FREQUENCES DE DISCRETISATION
!>    </td></tr>
!>          <tr><td>NPLAN
!></td><td>--></td><td>NOMBRE DE DIRECTIONS DE DISCRETISATION
!>    </td></tr>
!>          <tr><td>NPOIN2
!></td><td>--></td><td>NOMBRE DE POINTS DU MAILLAGE SPATIAL 2D
!>    </td></tr>
!>          <tr><td>TAILF
!></td><td>--></td><td>FACTEUR DE QUEUE DU SPECTRE
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE FREMOY
     &( FMOY  , F     , FREQ  , DFREQ , TAILF , NF    , NPLAN , NPOIN2,
     &  AUX1  , AUX2  )
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| AUX1           |---| 
C| AUX1(          |<->| TABLEAU DE TRAVAIL (DIMENSION NPOIN2)
C| AUX2           |---| 
C| AUX2(          |<->| TABLEAU DE TRAVAIL (DIMENSION NPOIN2)
C| DFREQ          |---| 
C| DFREQ(         |-->| TABLEAU DES PAS DE FREQUENCE
C| F             |---| 
C| F(             |-->| SPECTRE DIRECTIONNEL DE VARIANCE
C| FMOY           |---| 
C| FMOY(          |<--| TABLEAU DES FREQUENCES MOYENNES F01
C| FREQ           |---| 
C| FREQ(          |-->| TABLEAU DES FREQUENCES DE DISCRETISATION
C| NF             |-->| NOMBRE DE FREQUENCES DE DISCRETISATION
C| NPLAN          |-->| NOMBRE DE DIRECTIONS DE DISCRETISATION
C| NPOIN2         |-->| NOMBRE DE POINTS DU MAILLAGE SPATIAL 2D
C| TAILF          |-->| FACTEUR DE QUEUE DU SPECTRE
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
C
C.....VARIABLES IN ARGUMENT
C     """"""""""""""""""""
      INTEGER  NF    , NPLAN , NPOIN2
      DOUBLE PRECISION TAILF
      DOUBLE PRECISION F(NPOIN2,NPLAN,NF)
      DOUBLE PRECISION FREQ(NF), DFREQ(NF), FMOY(NPOIN2)
      DOUBLE PRECISION AUX1(NPOIN2), AUX2(NPOIN2)
C
C.....LOCAL VARIABLES
C     """""""""""""""""
      INTEGER  JP    , JF    , IP
      DOUBLE PRECISION SEUIL , DTETAR, AUX3  , AUX4
C
C
      SEUIL = 1.D-20
      DTETAR= 2.D0*3.141592654D0/DBLE(NPLAN)
      DO 30 IP = 1,NPOIN2
        AUX1(IP) = 0.D0
        AUX2(IP) = 0.D0
   30 CONTINUE
C
C-----C-------------------------------------------------------C
C-----C SUMS UP THE CONTRIBUTIONS FOR THE DISCRETISED PART OF THE SPECTRUM     C
C-----C-------------------------------------------------------C
      DO 20 JF = 1,NF-1
        AUX3=DTETAR*DFREQ(JF)
        AUX4=AUX3/FREQ(JF)
        DO 10 JP = 1,NPLAN
          DO 5 IP=1,NPOIN2
            AUX1(IP) = AUX1(IP) + F(IP,JP,JF)*AUX3
            AUX2(IP) = AUX2(IP) + F(IP,JP,JF)*AUX4
    5     CONTINUE
   10   CONTINUE
   20 CONTINUE
C
C-----C-------------------------------------------------------------C
C-----C (OPTIONALLY) TAKES INTO ACCOUNT THE HIGH-FREQUENCY PART     C
C-----C-------------------------------------------------------------C
      IF (TAILF.GT.1.D0) THEN
        AUX3=DTETAR*(DFREQ(NF)+FREQ(NF)/(TAILF-1.D0))
        AUX4=DTETAR*(DFREQ(NF)/FREQ(NF)+1.D0/TAILF)
      ELSE
        AUX3=DTETAR*DFREQ(NF)
        AUX4=AUX3/FREQ(NF)
      ENDIF
      DO 40 JP = 1,NPLAN
        DO 45 IP=1,NPOIN2
          AUX1(IP) = AUX1(IP) + F(IP,JP,NF)*AUX3
          AUX2(IP) = AUX2(IP) + F(IP,JP,NF)*AUX4
   45   CONTINUE
   40 CONTINUE
C
C-----C-------------------------------------------------------------C
C-----C COMPUTES THE MEAN FREQUENCY                                 C
C-----C-------------------------------------------------------------C
      DO 50 IP=1,NPOIN2
        IF (AUX1(IP).LT.SEUIL) THEN
          FMOY(IP) = SEUIL
        ELSE
          FMOY(IP) = AUX1(IP)/AUX2(IP)
        ENDIF
   50 CONTINUE
C
      RETURN
      END
C
C#######################################################################
C