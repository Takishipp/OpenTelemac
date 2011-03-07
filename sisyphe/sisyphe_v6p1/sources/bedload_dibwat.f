!                    ***************************
                     SUBROUTINE BEDLOAD_DIBWAT !
!                    ***************************
!
     &  (U2D,V2D,UCMOY, CF, TOB, TOBW, UW, TW, FW, THETAW, NPOIN,
     &   XMVE, DENS, GRAV, DM, XWC, PI, ALPHAW, T2, T3, UCW, UCN,
     &   UW1, UW2, TW1, TW2, THETAC, FCW, QSC,HOULE)
!
!***********************************************************************
! SISYPHE   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    DIBAJNIA & WATANABE FORMULATION (1992).
!
!history  C. VILLARET (LNHE)
!+        15/11/2003
!+
!+
!
!history  JMH
!+        09/05/2007
!+        V5P7
!+   CHECKS FOR GAMMA=0 DIVISION
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
!| ALPHAW         |---|
!| CF             |---|
!| DENS           |---|
!| DM             |---|
!| FCW            |---|
!| FW             |---|
!| GRAV           |---|
!| HOULE          |---|
!| NPOIN          |---|
!| PI             |---|
!| QSC            |---|
!| T2             |---|
!| T3             |---|
!| THETAC         |---|
!| THETAW         |---|
!| TOB            |---|
!| TOBW           |---|
!| TW             |---|
!| TW1            |---|
!| TW2            |---|
!| U2D            |---|
!| UCMOY          |---|
!| UCN            |---|
!| UCW            |---|
!| UW             |---|
!| UW1            |---|
!| UW2            |---|
!| V2D            |---|
!| XMVE           |---|
!| XWC            |---|
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE INTERFACE_SISYPHE,EX_BEDLOAD_DIBWAT => BEDLOAD_DIBWAT
      USE BIEF
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
      ! 2/ GLOBAL VARIABLES
      ! -------------------
      TYPE(BIEF_OBJ),   INTENT(IN)    :: U2D,V2D,UCMOY, CF, TOB, TOBW
      TYPE(BIEF_OBJ),   INTENT(IN)    :: UW, TW, FW
      TYPE(BIEF_OBJ),   INTENT(IN)    :: THETAW
      INTEGER,          INTENT(IN)    :: NPOIN
      LOGICAL,          INTENT(IN)    :: HOULE
      DOUBLE PRECISION, INTENT(IN)    :: XMVE, DENS, GRAV, DM, XWC, PI
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: ALPHAW          ! WORK ARRAY T1
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: T2, T3          !
      TYPE(BIEF_OBJ),   INTENT(INOUT) ::  UCW, UCN ! WORK ARRAY T4, T5, T6
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: UW1, UW2, TW1   ! WORK ARRAY T7, T8, T9
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: TW2, THETAC     ! WORK ARRAY T10, T11
      TYPE(BIEF_OBJ),   INTENT(INOUT) :: FCW, QSC        ! WORK ARRAY T12
!
      ! 3/ LOCAL VARIABLES
      ! ------------------
      INTEGER                     :: I
      DOUBLE PRECISION            :: UCW2, SHIELDS, OMEGACR, OMEGA1
      DOUBLE PRECISION            :: OMEGA2, W1, WP1, W2, WP2, GAMMAW
      DOUBLE PRECISION            :: GAMMAN, GAMMA, QSW, QSN
      DOUBLE PRECISION, PARAMETER :: ZERO  = 1.D-6
      DOUBLE PRECISION, PARAMETER :: ALPHA = 0.0001D0
      DOUBLE PRECISION, PARAMETER :: BETA  = 0.55D0
!
!======================================================================!
!======================================================================!
!                               PROGRAM                                !
!======================================================================!
!======================================================================!
!
!     ANGLE OF VELOCITY WITH OX
!
      CALL BEDLOAD_DIRECTION(U2D,V2D,NPOIN,PI,THETAC)
!
!     PROJECTIONS OF UCMOY IN THE WAVE DIRECTION
!
      CALL OS('X=CY    ', X=ALPHAW, Y=THETAW, C=-PI/180.D0)
      CALL OS('X=X+C   ', X=ALPHAW, C=0.5D0*PI)
      CALL OS('X=Y-Z   ', X=ALPHAW, Y=ALPHAW, Z=THETAC)
      CALL OS('X=COS(Y)', X=T2    , Y=ALPHAW)
      CALL OS('X=SIN(Y)', X=T3    , Y=ALPHAW)
      CALL OS('X=YZ    ', X=UCW   , Y=UCMOY , Z=T2)
      CALL OS('X=CYZ   ', X=UCN   , Y=UCMOY , Z=T3, C= -1.D0)
!
!     QUADRATIC VELOCITIES (UW1=U(T)> 0 AND UW2=U(T)
!
      CALL BEDLOAD_CALCDW(UCW,UW,TW,NPOIN,PI,UW1,UW2,TW1,TW2)
!
!     FRICTION COEFFICIENT
!
      CALL BEDLOAD_INTERACT
     &     (UCMOY,TOBW,TOB,ALPHAW,FW,CF,UW,NPOIN,XMVE,FCW)
!
      DO I = 1, NPOIN
!
!        SHIELDS PARAMETER
         UCW2    = UCMOY%R(I)**2 + 0.5D0 * UW%R(I)**2
         SHIELDS = FCW%R(I)*UCW2/DENS/GRAV/DM
!
!        CRITICAL OMEGA (TEMPERVILLE AND GUIZA,2000)  !
         IF (SHIELDS <= 0.2D0) THEN
            OMEGACR = 0.03D0
         ELSEIF (SHIELDS <= 0.4D0) THEN
            OMEGACR = 1.D0 - SQRT(1.D0-((SHIELDS-0.2D0)/0.58D0)**2)
         ELSEIF (SHIELDS <= 1.5D0) THEN
            OMEGACR = 0.8104D0 * SQRT(SHIELDS) - 0.4225D0
         ELSE
            OMEGACR = 0.7236D0 * SQRT(SHIELDS) - 0.3162D0
         ENDIF
!
!        OMEGA1, OMEGA2  !
         IF(TW1%R(I) > ZERO) THEN
            OMEGA1 = UW1%R(I)**2 / (2.D0*DENS*GRAV*XWC*TW1%R(I))
         ELSE
            OMEGA1 = ZERO
         ENDIF
!
         IF(TW2%R(I) > ZERO) THEN
            OMEGA2 = UW2%R(I)**2 / (2.D0*DENS*GRAV*XWC*TW2%R(I))
         ELSE
            OMEGA2 = ZERO
         ENDIF
!
!        QUANTITIES OF SAND DEPOSITED AND
!        IN SUSPENSION AT EACH PHASE OF THE CYCLE
!
!        PHASE 1
         IF (OMEGA1 <= OMEGACR) THEN
            W1  = 2.D0 * OMEGA1 * XWC * TW1%R(I) / DM
            WP1 = 0.D0
         ELSE
            W1  = 2.D0 * OMEGACR * XWC * TW1%R(I) / DM
            WP1 = 2.D0 * (OMEGA1-OMEGACR) * XWC * TW1%R(I) / DM
         ENDIF
!
!        PHASE 2
         IF (OMEGA2 <= OMEGACR) THEN
            W2  = 2.D0 * OMEGA2 * XWC * TW2%R(I) / DM
            WP2 = 0.D0
         ELSE
            W2  = 2.D0 * OMEGACR * XWC * TW2%R(I) / DM
            WP2 = 2.D0 * (OMEGA2-OMEGACR) * XWC * TW2%R(I) / DM
         ENDIF
!
!        GAMMAW, GAMMAN,GAMMA
         IF ((UW2%R(I)*TW2%R(I) + UW1%R(I)*TW1%R(I)) > 0.D0 ) THEN
            GAMMAW = (  UW1%R(I) * TW1%R(I) * (W1**3+WP2**3)
     &                - UW2%R(I) * TW2%R(I) * (W2**3+WP1**3))
     &             / ( (UW1%R(I)+UW2%R(I)) * TW%R(I) )
! AFTER CAMENEN / ((UW1(I)*TW1(I)+UW2(I)*TW2(I)) ??
         ELSE
            GAMMAW = (2.D0 * UCW%R(I)**2 / DENS / GRAV / DM)**3
         ENDIF
         GAMMAN = (2.D0 * UCN%R(I)**2 / DENS / GRAV / DM)**3
         GAMMA  = MAX(SQRT(GAMMAW**2 + GAMMAN**2),1.D-10)
!
!        SOLID TRANSPORT IN THE WAVE DIRECTION : QSW
!        AND IN THE NORMAL DIRECTION : QSN
!
         QSW      = ALPHA * GAMMAW * XWC * DM / GAMMA**(1.D0-BETA)
         QSN      = ALPHA * GAMMAN * XWC * DM / GAMMA**(1.D0-BETA)
         QSC%R(I) = SQRT(QSW**2 + QSN**2)
!
      ENDDO
!
!----------------------------------------------------------------------
!
      RETURN
      END