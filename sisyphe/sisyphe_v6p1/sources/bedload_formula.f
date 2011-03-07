!                    **************************
                     SUBROUTINE BEDLOAD_FORMULA
!                    **************************
!
     &(U2D,V2D,UCMOY,HN,CF,MU,TOB,TOBW,UW,TW,THETAW,FW,
     & ACLADM, UNLADM,KSP,KSR,AVA,NPOIN,ICF,HIDFAC,XMVS,XMVE,
     & DM,GRAV,VCE,XKV,HMIN,XWC,D90,KARMAN,ZERO,
     & PI,SUSP, AC, HIDING, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10,
     & T11,TETAP, QSC, QSS,IELMT,SECCURRENT,SLOPEFF,
     & COEFPN,BIJK,HOULE)
!
!***********************************************************************
! SISYPHE   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE BED-LOAD TRANSPORT.
!
!history  BUI MINH DUC
!+        **/01/2002
!+        V5P2
!+
!
!history  C. VILLARET
!+        **/10/2003
!+        V5P4
!+
!
!history  F. HUVELIN
!+        12/01/2005
!+        V5P6
!+
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        13/07/2010
!+        V6P0
!+   Translation of French comments within the FORTRAN sources into
!+   English comments
!
!history  N.DURAND (HRW), S.E.BOURBAN (HRW)
!+        21/08/2010
!+        V6P0
!+   Creation of DOXYGEN tags for automated documentation and
!+   cross-referencing of the FORTRAN sources
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AC             |---|
!| ACLADM         |---|
!| AVA            |---|
!| BIJK           |---|
!| CF             |---|
!| COEFPN         |---|
!| D90            |---|
!| DM             |---|
!| FW             |---|
!| GRAV           |---|
!| HIDFAC         |---|
!| HIDING         |---|
!| HMIN           |---|
!| HN             |---|
!| HOULE          |---|
!| ICF            |---|
!| IELMT          |---|
!| KARMAN         |---|
!| KSP            |---|
!| KSR            |---|
!| MU             |---|
!| NPOIN          |---|
!| PI             |---|
!| QSC            |---|
!| QSS            |---|
!| SECCURRENT     |---|
!| SLOPEFF        |---|
!| SUSP           |---|
!| T1             |---|
!| T10            |---|
!| T11            |---|
!| T2             |---|
!| T3             |---|
!| T4             |---|
!| T5             |---|
!| T6             |---|
!| T7             |---|
!| T8             |---|
!| T9             |---|
!| TETAP          |---|
!| THETAW         |---|
!| TOB            |---|
!| TOBW           |---|
!| TW             |---|
!| U2D            |---|
!| UCMOY          |---|
!| UNLADM         |---|
!| UW             |---|
!| V2D            |---|
!| VCE            |---|
!| XKV            |---|
!| XMVE           |---|
!| XMVS           |---|
!| XWC            |---|
!| ZERO           |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE INTERFACE_SISYPHE,EX_BEDLOAD_FORMULA => BEDLOAD_FORMULA
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE(BIEF_OBJ),   INTENT(IN)    :: U2D, V2D, UCMOY,HN, CF, TOB
      TYPE(BIEF_OBJ),   INTENT(IN)    :: MU,TOBW, UW, TW, THETAW, FW
      TYPE(BIEF_OBJ),   INTENT(IN)    :: ACLADM,UNLADM,KSR,KSP
      INTEGER,          INTENT(IN)    :: NPOIN, ICF, HIDFAC,IELMT
      DOUBLE PRECISION, INTENT(IN)    :: XMVS, XMVE, DM, GRAV, VCE
      DOUBLE PRECISION, INTENT(IN)    :: XKV, HMIN, XWC, D90
      DOUBLE PRECISION, INTENT(IN)    :: KARMAN, ZERO, PI
      LOGICAL,          INTENT(IN)    :: SUSP,SECCURRENT,HOULE
      DOUBLE PRECISION, INTENT(INOUT) :: AC
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: HIDING
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: T1, T2, T3, T4, T5, T6, T7
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: T8, T9, T10,T11
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: TETAP ! WORK ARRAY T12
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: QSC, QSS
      TYPE(BIEF_OBJ),   INTENT(INOUT) ::  COEFPN
      INTEGER,          INTENT(IN)    :: SLOPEFF
!
      DOUBLE PRECISION, INTENT (IN) :: BIJK,AVA(NPOIN)
      ! 3/ LOCAL VARIABLES
      ! ------------------
      INTEGER                     :: I
      DOUBLE PRECISION            :: DENS,DSTAR,ALPHA
      DOUBLE PRECISION, PARAMETER :: ZERO_LOCAL = 1.D-6
      DOUBLE PRECISION            :: C1
!
!======================================================================!
!======================================================================!
!                               PROGRAM                                !
!======================================================================!
!======================================================================!
!
      ! *************************** !
      ! I - ADIMENSIONAL PARAMETERS !
      ! *************************** !
      DENS  = (XMVS - XMVE )/ XMVE
      DSTAR = DM*(GRAV*DENS/VCE**2)**(1.D0/3.D0)
      ! ************************ !
      ! II -  SKIN FRICTION      !
      ! ************************ !
!
      C1 = 1.D0/(DENS*XMVE*GRAV*DM)
      CALL OS('X=CYZ   ', X=TETAP, Y=TOB,Z=MU,  C=C1)
      CALL OS('X=+(Y,C)', X= TETAP,Y=TETAP, C=ZERO_LOCAL)
!
      ! *********************************************** !
      ! III - CRITICAL SHIELDS NUMBER FOR ENTRAINMENT   !
      !       VAN RIJN FORMULATION                      !
      ! *********************************************** !
! MOVED TO INIT_SEDIMENT.F
!
!      IF(ICF.EQ.7.OR.ICF.EQ.6.OR.AC.LE.0.D0) THEN
!         IF (DSTAR
!            AC = 0.24*DSTAR**(-1.0D0)
!         ELSEIF (DSTAR
!            AC = 0.14D0*DSTAR**(-0.64D0)
!         ELSEIF (DSTAR
!            AC = 0.04D0*DSTAR**(-0.1D0)
!         ELSEIF (DSTAR
!            AC = 0.013D0*DSTAR**(0.29D0)
!         ELSE
!            AC = 0.055D0
!         ENDIF
!      ENDIF
      IF(SECCURRENT) CALL BEDLOAD_SECCURRENT(IELMT)
      ! ****************************************** !
      ! IV - COMPUTES 2 TRANSPORT TERMS            !
      !      QSS : SUSPENSION                      !
      !      QSC : BEDLOAD                         !
      ! ****************************************** !
      ! ===================================== !
      ! IV(1) - MEYER-PETER-MULLER FORMULATION!
      !         FOR BEDLOAD ONLY              !
      ! ===================================== !
      IF(ICF == 1) THEN
          CALL BEDLOAD_MEYER(TETAP,HIDING,HIDFAC,DENS,GRAV,DM,AC,
     &                       T1,QSC,SLOPEFF,COEFPN)
          DO I=1,NPOIN
            QSC%R(I)=XKV*QSC%R(I)*AVA(I)
          ENDDO
          ALPHA = -3.D0
      ! =========================== !
      ! IV(2) - EINSTEIN FORMULATION!
      !         FOR BEDLOAD ONLY    !
      ! =========================== !
      ELSEIF(ICF == 2) THEN
         CALL BEDLOAD_EINST(TETAP,NPOIN,DENS,GRAV,DM,DSTAR,QSC)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -6.D0
      ! =================================== !
      ! IV(30) - ENGELUND-HANSEN FORMULATION!
      !          FOR TOTAL TRANSPORT        !
      ! =================================== !
      ELSEIF(ICF == 30) THEN
! V6P0 MU IS USED INSTEAD OF CF
! BEWARE: DIFFERENCES
!         CALL BEDLOAD_ENGEL(TETAP,DENS,GRAV,DM,QSC)
! BACK TO EARLIER VERSION OF BEDLOAD_ENGEL
         CALL BEDLOAD_ENGEL(TOB,CF,DENS,GRAV,DM,XMVE,T1,QSC)
!        ARBITRARY DISTRIBUTION
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -5.D0
      ! ======================================== !
      ! IV(3) - ENGELUND-HANSEN FORMULATION      !
      !         MODIFIED: CHOLLET ET CUNGE       !
      !         FOR TOTAL TRANSPORT              !
      ! ======================================== !
      ELSEIF(ICF == 3) THEN
!        KSP IS USED INSTEAD OF CFP
         CALL BEDLOAD_ENGEL_OLD
     &        (TETAP,CF,NPOIN,GRAV,DM,DENS,T1,QSC)
!        ARBITRARY DISTRIBUTION
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -5.D0
      ! ============================== !
      ! IV(4) - BIJKER FORMULATION     !
      !         FOR BEDLOAD + SUSPENSION !
      ! ============================== !
      ELSEIF (ICF == 4) THEN
         CALL BEDLOAD_BIJKER
     &    (TOBW,TOB,MU,KSP,KSR,HN,NPOIN,DM,DENS,XMVE,GRAV,
     &     XWC,KARMAN,ZERO,T4,T7,T8,T9,QSC,QSS,BIJK,HOULE)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
           QSS%R(I)=XKV*QSS%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -1.D0
      ! ============================== !
      ! IV(5) - SOULSBY FORMULATION    !
      !         FOR BEDLOAD + SUSPENSION !
      ! ============================== !
      ELSEIF (ICF == 5) THEN
         CALL BEDLOAD_SOULSBY
     &        (UCMOY,HN,UW,NPOIN,DENS,GRAV,DM,DSTAR,HMIN,
     &         D90,QSC,QSS)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
           QSS%R(I)=XKV*QSS%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -4.6D0
      ! ================================================== !
      ! IV(6) - HUNZIKER / MEYER-PETER & MULLER FORMULATION!
      !         FOR BEDLOAD ONLY                           !
      ! ================================================== !
      ELSEIF (ICF == 6) THEN
         CALL BEDLOAD_HUNZ_MEYER
     &        (TOB, MU, ACLADM, UNLADM, NPOIN, DENS, XMVE, GRAV,
     &         DM, AC, T1, T2, T3, HIDING, QSC)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)
         ENDDO
         ALPHA = -3.D0
      ! =========================== !
      ! IV(7) - VAN RIJN FORMULATION!
      !         FOR BEDLOAD ONLY    !
      ! =========================== !
      ELSEIF (ICF == 7) THEN
!
         CALL BEDLOAD_VANRIJN
!     &        (TOB,MU,NPOIN,DM,DENS,GRAV,DSTAR,AC,QSC)
     &        (TETAP,MU,NPOIN,DM,DENS,GRAV,DSTAR,AC,QSC)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -4.2D0
      ! ============================== !
      ! IV(8) - BAILARD FORMULATION    !
      !         FOR BEDLOAD + SUSPENSION !
      ! ============================== !
      ELSEIF (ICF == 8) THEN
!
         CALL BEDLOAD_BAILARD
     &        (U2D,V2D,UCMOY,TOB,TOBW,THETAW,UW,FW,CF,NPOIN,
     &         PI,XMVE,GRAV,DENS,XWC,T1,T2,T3,T4,T5,T6,T7,
     &         T8,T9,T10,T11,QSC,QSS,HOULE)
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
           QSS%R(I)=XKV*QSS%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -3.D0
      ! ======================================= !
      ! IV(9) - DIBAJNIA AND WATANABE FORMULATION!
      !         FOR TOTAL TRANSPORT             !
      ! ======================================= !
      ELSEIF(ICF == 9) THEN
!
         CALL BEDLOAD_DIBWAT
     &        (U2D,V2D,UCMOY, CF, TOB, TOBW, UW, TW, FW, THETAW,
     &         NPOIN, XMVE, DENS, GRAV, DM, XWC, PI, T1, T2, T3, T4,
     &         T5, T6, T7, T8, T9, T10, T11, QSC,HOULE)
!        ARBITRARY DISTRIBUTION
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
         ALPHA = -3.D0
      ! ============================================ !
      ! IV(0) - USER-DEFINED FORMULATION             !
      ! ============================================ !
      ELSEIF (ICF == 0) THEN
         ALPHA = -1.D0 ! INITIALISES ALPHA
         CALL QSFORM
         DO I=1,NPOIN
           QSC%R(I)=XKV*QSC%R(I)*AVA(I)*HIDING%R(I)
           QSS%R(I)=XKV*QSS%R(I)*AVA(I)*HIDING%R(I)
         ENDDO
      ! ================= !
      ! IV(ELSE) - ERROR  !
      ! ================= !
      ELSE
        IF(LNG == 1) WRITE(LU,200) ICF
        IF(LNG == 2) WRITE(LU,201) ICF
200     FORMAT(1X,'TRANSP : FORMULE DE TRANSPORT INCONNUE :',1I6)
201     FORMAT(1X,'TRANSP : TRANSPORT FORMULA UNKNOWN:',1I6)
        CALL PLANTE(1)
        STOP
      ENDIF
!
!-----------------------------------------------------------------------
!
!     WHEN SUSPENSION IS NOT ASKED SPECIFICALLY, SOME BEDLOAD TRANSPORT
!     FORMULAS GIVE A VALUE
!
      IF(.NOT.SUSP) THEN
        IF(ICF.EQ.4.OR.ICF.EQ.5.OR.ICF.EQ.8.OR.ICF.EQ.0) THEN
          DO I = 1,NPOIN
            QSC%R(I) = QSC%R(I) + QSS%R(I)
          ENDDO
        ELSE
!         NOTE JMH: IS THIS REALLY USEFUL ???
          DO I = 1,NPOIN
            QSS%R(I) = 0.D0
          ENDDO
        ENDIF
      ENDIF
!
!=======================================================================
!=======================================================================
!
      RETURN
      END