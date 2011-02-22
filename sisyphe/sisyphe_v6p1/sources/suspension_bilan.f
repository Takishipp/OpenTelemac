C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       MASS-BALANCE FOR THE SUSPENSION.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Use(s)
!><br>BIEF, INTERFACE_SISYPHE
!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> AGGLOT, CSF, CST, DT, ENTET, FLBORTRA, HN, IELMT, ITRA, LT, MASDEP, MASDEPT, MASED0, MASFIN, MASINI, MASKEL, MASSOU, MASTEN, MASTOU, MESH, MSK, NFRLIQ, NIT, NPTFR, NUMLIQ, T2, T3, VOLU2D, ZFCL_S
!>   </td></tr>
!>     <tr><th> Use(s)
!>    </th><td>
!> BIEF_DEF :<br>
!> @link BIEF_DEF::NCSIZE NCSIZE@endlink
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> ERREUR, FLT_BOUND, FLUXT, I, IFRLIQ, PERDUE, P_DSUM, RELATI
!>   </td></tr>
!>     <tr><th> Alias(es)
!>    </th><td> EX_SUSPENSION_BILAN
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> BIEF_SUM(), DOTS(), OS(), VECTOR()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>SUSPENSION_COMPUTATION()

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
!>      <td><center>                                           </center>
!> </td><td> 10/06/2008
!> </td><td>
!> </td><td> TRACER FLUX GIVEN BY FLBORTRA (FROM CVDFTR)
!> <br>      DELETED 13 ARGUMENTS
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> 28/05/2008
!> </td><td>
!> </td><td> FLUX GIVEN BY BOUNDARIES
!> </td></tr>
!>      <tr>
!>      <td><center>                                           </center>
!> </td><td> 05/05/2008
!> </td><td>
!> </td><td> COMPUTES THE MASS ACCOUNTING FOR MASS-LUMPING
!> </td></tr>
!>      <tr>
!>      <td><center> 5.8                                       </center>
!> </td><td> 29/10/2007
!> </td><td> J-M HERVOUET
!> </td><td> CORRECTIONS IN PARALLEL MODE
!> </td></tr>
!>      <tr>
!>      <td><center> 5.6                                       </center>
!> </td><td> 22/12/2004
!> </td><td> F. HUVELIN
!> </td><td>
!> </td></tr>
!>      <tr>
!>      <td><center> 5.4                                       </center>
!> </td><td> **/05/2003
!> </td><td> M. GONZALES DE LINARES
!> </td><td>
!> </td></tr>
!>      <tr>
!>      <td><center> 5.1                                       </center>
!> </td><td> 13/12/2000
!> </td><td> C. MOULIN (LNH) 01 30 87 83 81
!> </td><td>
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>AGGLOT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>CSF
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>CST
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>DISP_C
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>DT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ENTET
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>FLBORTRA
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>HN
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>HPROP
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IELMT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ITRA
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>LT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASDEP
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASDEPT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASED0
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASFIN
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASINI
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASKEL
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASSOU
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASTEN
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MASTOU
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MESH
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>MSK
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NFRLIQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NIT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NUMLIQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>T2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>T3
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>VOLU2D
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>ZFCL_S
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
        SUBROUTINE SUSPENSION_BILAN
     &(MESH,CST,HN,ZFCL_S,MASKEL,
     & IELMT,ITRA,LT,NIT,DT,CSF,
     & MASSOU,MASED0,MSK,ENTET,MASTEN,MASTOU,MASINI,T2,
     & T3,MASFIN,MASDEPT,MASDEP,AGGLOT,
     & VOLU2D,NUMLIQ,NFRLIQ,NPTFR,FLBORTRA)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| AGGLOT         |---| 
C| CSF            |---| 
C| CST            |---| 
C| DISP_C         |---| 
C| DT             |---| 
C| ENTET          |---| 
C| FLBORTRA       |---| 
C| HN             |---| 
C| HPROP          |---| 
C| IELMT          |---| 
C| ITRA           |---| 
C| LT             |---| 
C| MASDEP         |---| 
C| MASDEPT        |---| 
C| MASED0         |---| 
C| MASFIN         |---| 
C| MASINI         |---| 
C| MASKEL         |---| 
C| MASSOU         |---| 
C| MASTEN         |---| 
C| MASTOU         |---| 
C| MESH           |---| 
C| MSK            |---| 
C| NFRLIQ         |---| 
C| NIT            |---| 
C| NPTFR          |---| 
C| NUMLIQ         |---| 
C| T2             |---| 
C| T3             |---| 
C| VOLU2D         |---| 
C| ZFCL_S         |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      USE INTERFACE_SISYPHE,EX_SUSPENSION_BILAN => SUSPENSION_BILAN
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU

      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE(BIEF_MESH),  INTENT(INOUT) :: MESH
      TYPE(BIEF_OBJ),   INTENT(IN)    :: CST,HN,VOLU2D
      TYPE(BIEF_OBJ),   INTENT(IN)    :: ZFCL_S,MASKEL,FLBORTRA
      INTEGER,          INTENT(IN)    :: IELMT,ITRA,LT,NIT,NFRLIQ,NPTFR
      INTEGER,          INTENT(IN)    :: NUMLIQ(NFRLIQ)
      DOUBLE PRECISION, INTENT(IN)    :: DT,CSF
      DOUBLE PRECISION, INTENT(IN)    :: MASSOU,MASED0,AGGLOT
      LOGICAL,          INTENT(IN)    :: MSK,ENTET
      DOUBLE PRECISION, INTENT(INOUT) :: MASTEN,MASTOU,MASINI
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: T2,T3
      DOUBLE PRECISION, INTENT(INOUT) :: MASFIN,MASDEPT,MASDEP

      ! 3/ LOCAL VARIABLES
      ! ------------------
      INTEGER IFRLIQ,I
      DOUBLE PRECISION            :: ERREUR, PERDUE, RELATI, FLUXT
C     HERE 300 IS MAXFRO, THE MAXIMUM NUMBER OF LIQUID BOUNDARIES
      DOUBLE PRECISION FLT_BOUND(300)

      ! 4/ EXTERNAL FUNCTION
      ! --------------------
      DOUBLE PRECISION, EXTERNAL :: P_DSUM

!======================================================================!
!======================================================================!
C                               PROGRAM                                !
!======================================================================!
!======================================================================!

      ! ************************************** !
      ! I - QUANTITY OF SEDIMENT IN SUSPENSION !
      ! ************************************** !
!
      IF(AGGLOT.GT.0.999999D0) THEN
C       ASSUMES HERE THAT AGGLOT=1.D0
        CALL OS('X=YZ    ',X=T2,Y=VOLU2D,Z=CST)
      ELSE
        CALL VECTOR(T2,'=','MASVEC          ',IELMT,
     &              1.D0-AGGLOT,CST,T3,T3,T3,T3,T3,MESH,MSK,MASKEL)
        CALL VECTOR(T3,'=','MASBAS          ',IELMT,
     &                   AGGLOT,T2,T2,T2,T2,T2,T2,MESH,MSK,MASKEL)
        CALL OS('X=X+YZ  ',X=T2,Y=T3,Z=CST)
      ENDIF
C
      MASFIN = DOTS(T2,HN)
      IF(NCSIZE.GT.1) MASFIN=P_DSUM(MASFIN)

      ! ************************** !
      ! II - TOTAL MASS OF DEPOSIT !
      ! ************************** !

      CALL VECTOR(T2, '=', 'MASVEC          ', IELMT, CSF, ZFCL_S, HN,
     &            HN, HN, HN, HN, MESH, MSK, MASKEL)
      MASDEPT = BIEF_SUM(T2)
      IF(NCSIZE.GT.1) MASDEPT = P_DSUM(MASDEPT)

      ! *************************************************** !
      ! III - TOTAL MASS OF DEPOSITED (OR ERODED) SEDIMENTS !
      ! *************************************************** !

      MASDEP = MASDEP + MASDEPT
C
C=======================================================================
C
C   COMPUTES THE FLUXES (NO DIFFUSIVE FLUX,...TO INVESTIGATE)
C
C=======================================================================
C
      FLUXT=0.D0
C
      IF(NFRLIQ.GT.0) THEN
        DO IFRLIQ=1,NFRLIQ
          FLT_BOUND(IFRLIQ)=0.D0
        ENDDO
        IF(NPTFR.GT.0) THEN
          DO I=1,NPTFR
C           NOTE: FLUX_BOUNDARIES COULD BE DEFINED BETWEEN 0 AND NFRLIQ
            IFRLIQ=NUMLIQ(I)
            IF(IFRLIQ.GT.0) THEN
              FLT_BOUND(IFRLIQ)=FLT_BOUND(IFRLIQ)+FLBORTRA%R(I)
            ENDIF
          ENDDO
        ENDIF
        IF(NCSIZE.GT.1) THEN
          DO IFRLIQ=1,NFRLIQ
            FLT_BOUND(IFRLIQ)=P_DSUM(FLT_BOUND(IFRLIQ))
          ENDDO
        ENDIF
        DO IFRLIQ=1,NFRLIQ
          FLUXT=FLUXT+FLT_BOUND(IFRLIQ)
        ENDDO
      ENDIF

      ! ********************************************** !
      ! VII - QUANTITY ENTERED THROUGH LIQUID BOUNDARY !
      ! ********************************************** !

      MASTEN = MASTEN - FLUXT * DT

      ! ************************************** !
      ! VIII - QUANTITY CREATED BY SOURCE TERM !
      ! ************************************** !

      MASTOU = MASTOU + MASSOU

      ! ***************************** !
      ! IX - RELATIVE ERROR ON VOLUME !
      ! ***************************** !
!
C CORRECTION JMH 17/03/05 : MISSING TERM
C                                         - MASDEPT
      ERREUR = MASINI + MASSOU - DT*FLUXT - MASDEPT - MASFIN
!
      IF (MASFIN > 1.D-8) ERREUR = ERREUR / MASFIN

      ! *********** !
      ! X - LISTING !
      ! *********** !

      IF(ENTET) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,1005) ITRA,MASINI
          WRITE(LU,1100) ITRA,MASFIN
          IF(NFRLIQ.GT.0) THEN
            DO IFRLIQ=1,NFRLIQ
              WRITE(LU,1110) IFRLIQ,ITRA,-FLT_BOUND(IFRLIQ)
            ENDDO
          ENDIF
          IF (ABS(MASDEPT) > 1.D-8) WRITE(LU,1115) MASDEPT
          IF (ABS(MASSOU ) > 1.D-8) WRITE(LU,1116) MASSOU
          WRITE(LU,1120) ERREUR
        ELSEIF(LNG.EQ.2) THEN
          WRITE(LU,2005) ITRA,MASINI
          WRITE(LU,2100) ITRA,MASFIN
          IF(NFRLIQ.GT.0) THEN
            DO IFRLIQ=1,NFRLIQ
              WRITE(LU,2110) IFRLIQ,ITRA,-FLT_BOUND(IFRLIQ)
            ENDDO
          ENDIF
          IF(ABS(MASDEPT) > 1.D-8) WRITE(LU,2115) MASDEPT
          IF(ABS(MASSOU ) > 1.D-8) WRITE(LU,2116) MASSOU
          WRITE(LU,2120) ERREUR
        ENDIF
      ENDIF

      ! ************************************** !
      ! XI - LISTING OF THE FINAL MASS-BALANCE !
      ! ************************************** !

      IF(LT.EQ.NIT.AND.ENTET) THEN

         PERDUE = MASED0 + MASTEN + MASTOU - MASFIN - MASDEP
         RELATI = PERDUE
         IF(MAX(MASED0,MASFIN) > 1.D-10) THEN
           RELATI = RELATI / MAX(MASED0,MASFIN)
         ENDIF

         IF(LNG.EQ.1) THEN
            WRITE(LU,3000) ITRA
            WRITE(LU,1140) RELATI
            WRITE(LU,1160) ITRA, MASED0, MASFIN
            IF(ABS(MASTEN) > 1.D-8) WRITE(LU,1161) MASTEN
            IF(ABS(MASTOU) > 1.D-8) WRITE(LU,1164) MASTOU
            IF(ABS(MASDEP) > 1.D-8) WRITE(LU,1167) MASDEP
            WRITE(LU,1166) PERDUE
         ELSEIF(LNG.EQ.2) THEN
            WRITE(LU,3100) ITRA
            WRITE(LU,2140) RELATI
            WRITE(LU,2160) ITRA,MASED0, MASFIN
            IF(ABS(MASTEN) > 1.D-8) WRITE(LU,2161) MASTEN
            IF(ABS(MASTOU) > 1.D-8) WRITE(LU,2164) MASTOU
            IF(ABS(MASDEP) > 1.D-8) WRITE(LU,2167) MASDEP
            WRITE(LU,2166) PERDUE
         ENDIF
      ENDIF

      ! *************************** !
      ! XII - UPDATES INITIAL MASS  !
      ! *************************** !

      MASINI = MASFIN

      !----------------------------------------------------------------!
1005  FORMAT(1X,'QUANTITE DE LA CLASSE    ',I2
     &         ,' EN SUSPENSION AU TEMPS T    : ',G16.7,' M3')
1100  FORMAT(1X,'QUANTITE DE LA CLASSE    ',I2
     &         ,' EN SUSPENSION AU TEMPS T+DT : ',G16.7,' M3')
1110  FORMAT(1X,'FRONTIERE ',1I3,' FLUX TRACEUR ',1I2,' = ',G16.7,
     &          ' ( >0 : ENTRANT  <0 : SORTANT )')
1112  FORMAT(1X,'FLUX IMPOSE DE LA CLASSE ',I2
     &         ,'                             : ',G16.7,' M3/S')
1113  FORMAT(1X,'FLUX LIBRE  DE LA CLASSE ',I2
     &         ,'                             : ',G16.7,' M3/S')
1114  FORMAT(1X,'FLUX DE LA CLASSE        ',I2
     &         ,' PAR ONDE INCIDENTE          : ',G16.7,' M3/S')
1115  FORMAT(1X,'VOLUME DEPOSE SUR LE FOND  '
     &         ,'                             : ',G16.7,' M3')
1116  FORMAT(1X,'VOLUME CREE PAR TERME SOURCE  '
     &         ,   '                          : ',G16.7,' M3')
1120  FORMAT(1X,'ERREUR RELATIVE SUR LE VOLUME  '
     &         ,    '                         : ', G16.7)
1140  FORMAT(1X,'ERREUR RELATIVE CUMULEE SUR LE VOLUME : ', G16.7)
1160  FORMAT(1X,'QUANTITE INITIALE DE ',I2,'               : ',G16.7
     &         ,' M3',
     &     /,1X,'QUANTITE FINALE                       : ', G16.7,' M3')
1161  FORMAT(1X,'QUANTITE ENTREE AUX FRONT. LIQUID.    : ', G16.7,' M3')
1164  FORMAT(1X,'QUANTITE CREEE PAR TERME SOURCE       : ', G16.7,' M3')
1166  FORMAT(1X,'QUANTITE TOTALE PERDUE                : ', G16.7,' M3')
1167  FORMAT(1X,'VOLUME TOTAL DEPOSE SUR LE FOND       : ', G16.7,' M3')
3000  FORMAT(/,1X,'        *** ','BILAN FINAL DE LA CLASSE ',I2,' ***')
      !----------------------------------------------------------------!
2005  FORMAT(1X,'QUANTITY OF CLASS                 ',I2
     &         ,' IN SUSPENSION AT TIME T    : ',G16.7,' M3')
2100  FORMAT(1X,'QUANTITY OF CLASS                 ',I2
     &         ,' IN SUSPENSION AT TIME T+DT : ',G16.7,' M3')
2110  FORMAT(1X,'BOUNDARY ',1I3,' FLUX TRACER ',1I2,' = ',G16.7,
     &          ' ( >0 : ENTERING  <0 : EXITING )')
2112  FORMAT(1X,'PRESCRIBED SEDIMENT FLUX OF CLASS ',I2
     &         ,'                            : ',G16.7,' M3/S')
2113  FORMAT(1X,'FREE FLUX OF CLASS                ',I2
     &         ,'                            : ',G16.7,' M3/S')
2114  FORMAT(1X,'FLUX OF SEDIMENT CLASS            ',I2
     &         ,' ADDED BY INCIDENT WAVE     : ',G16.7,' M3/S')
2115  FORMAT(1X,'VOLUME OF DEPOSIT                   '
     &         ,'                            : ',G16.7, ' M3')
2116  FORMAT(1X,'VOLUME CREATED BY SOURCE TERM       '
     &         ,'                            : ',G16.7, ' M3')
2120  FORMAT(1X,'RELATIVE ERROR ON VOLUME            '
     &         ,'                            : ',G16.7)
2140  FORMAT(1X,'RELATIVE ERROR CUMULATED ON VOLUME : ', G16.7       )
2160  FORMAT(1X,'INITIAL QUANTITY OF ',I2,'           : '  , G16.7
     &         ,' M3',
     &     /,1X,'FINAL QUANTITY                     : ', G16.7, ' M3')
2161  FORMAT(1X,'QUANTITY ENTERED THROUGH LIQ. BND. : ', G16.7, ' M3')
2164  FORMAT(1X,'QUANTITY CREATED BY SOURCE TERM    : ', G16.7, ' M3')
2166  FORMAT(1X,'TOTAL QUANTITY LOST                : ', G16.7, ' M3')
2167  FORMAT(1X,'TOTAL MASS OF DEPOSIT              : ', G16.7, ' M3')
3100  FORMAT(/,1X,'      *** ','FINAL BALANCE FOR TRACER',I2,' ***')
      !----------------------------------------------------------------!

!======================================================================!
!======================================================================!

      RETURN
      END
C
C#######################################################################
C