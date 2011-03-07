!                    *************************
                     SUBROUTINE INIT_TRANSPORT
!                    *************************
!
     &(TROUVE,DEBU,HIDING,NSICLA,NPOIN,
     & T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T14,
     & CHARR,QS_C,QSXC,QSYC,CALFA,SALFA,COEFPN,SLOPEFF,
     & SUSP,QS_S,QS,QSCL,QSCL_C,QSCL_S,QSCLXS,QSCLYS,
     & UNORM,U2D,V2D,HN,CF,MU,TOB,TOBW,UW,TW,THETAW,FW,HOULE,
     & AVAIL,ACLADM,UNLADM,KSP,KSR,KS,
     & ICF,HIDFAC,XMVS,XMVE,GRAV,VCE,XKV,HMIN,KARMAN,
     & ZERO,PI,AC,IMP_INFLOW_C,ZREF,ICQ,CSTAEQ,
     & CMAX,CS,CS0,UCONV,VCONV,CORR_CONV,SECCURRENT,BIJK,
     & IELMT,MESH,FDM,XWC,FD90,SEDCO,VITCE,PARTHENIADES,VITCD,
     * U3D,V3D,CODE)
!
!***********************************************************************
! SISYPHE   V6P0                                   21/08/2010
!***********************************************************************
!
!brief
!
!history  JMH
!+        24/01/2008
!+        
!+   TEST 'IF(CHARR.OR.SUSP)' ADDED AT THE END 
!
!history  JMH
!+        16/09/2009
!+        
!+   AVAIL(NPOIN,10,NSICLA) 
!
!history  JMH
!+        07/12/2009
!+        
!+   MODIFICATIONS FOR RESTART WITH WARNINGS WHEN A VARIABLE 
!
!history  C. VILLARET (LNHE)
!+        
!+        V6P0
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
!| AVAIL          |---| 
!| BIJK           |---| 
!| CALFA          |---| 
!| CF             |---| 
!| CHARR          |-->| 
!| CMAX           |---| 
!| COEFPN         |---| 
!| CORR_CONV      |---| 
!| CS             |---| 
!| CS0            |---| 
!| CSTAEQ         |---| 
!| DEBU           |-->| 
!| FD90           |---| 
!| FDM            |---| 
!| FW             |---| 
!| GRAV           |---| 
!| HIDFAC         |---| 
!| HIDING         |-->| 
!| HMIN           |---| 
!| HN             |-->| WATER DEPTH
!| HOULE          |---| 
!| ICF            |---| 
!| ICQ            |---| 
!| IELMT          |---| 
!| IMP_INFLOW_C   |---| 
!| KARMAN         |---| 
!| KS             |---| 
!| KSP            |---| 
!| KSR            |---| 
!| MESH           |---| 
!| MU             |---| 
!| NPOIN          |---| 
!| NSICLA         |-->| NUMBER OF SEDIMENT CLASSES
!| PARTHENIADES   |---| 
!| PI             |---| 
!| QS             |---| 
!| QSCL           |---| 
!| QSCLXS         |---| 
!| QSCLYS         |---| 
!| QSCL_C         |---| 
!| QSCL_S         |---| 
!| QSXC           |---| 
!| QSYC           |---| 
!| QS_C           |---| 
!| QS_S           |---| 
!| SALFA          |---| 
!| SECCURRENT     |---| 
!| SEDCO          |---| 
!| SLOPEFF        |---| 
!| SUSP           |---| 
!| T1             |---| 
!| T10            |---| 
!| T11            |---| 
!| T12            |---| 
!| T14            |---| 
!| T2             |---| 
!| T3             |---| 
!| T4             |---| 
!| T5             |---| 
!| T6             |---| 
!| T7             |---| 
!| T8             |---| 
!| T9             |---| 
!| THETAW         |---| 
!| TOB            |---| 
!| TOBW           |---| 
!| TROUVE         |-->| 
!| TW             |---| 
!| U2D            |---| 
!| UCONV          |---| 
!| UNLADM         |---| 
!| UNORM          |---| 
!| UW             |---| 
!| V2D            |---| 
!| VCE            |---| 
!| VCONV          |---| 
!| VITCD          |---| 
!| VITCE          |---| 
!| XKV            |---| 
!| XMVE           |---| 
!| XMVS           |---| 
!| XWC            |---| 
!| ZERO           |---| 
!| ZREF           |---| 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE INTERFACE_SISYPHE, EX_INIT_TRANSPORT => INIT_TRANSPORT
!
      USE DECLARATIONS_SISYPHE, ONLY : NOMBLAY
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)              :: NSICLA,NPOIN,TROUVE(*),ICQ
      INTEGER, INTENT(IN)              :: ICF,HIDFAC,IELMT,SLOPEFF
      LOGICAL, INTENT(IN)              :: CHARR,DEBU,SUSP,IMP_INFLOW_C
      LOGICAL, INTENT(IN)              :: CORR_CONV,SECCURRENT,SEDCO(*)
      LOGICAL, INTENT(IN)              :: HOULE
      TYPE(BIEF_OBJ),    INTENT(IN)    :: U2D,V2D,UNORM,HN,CF
      TYPE(BIEF_OBJ),    INTENT(IN)    :: MU,TOB,TOBW,UW,TW,THETAW,FW
      TYPE(BIEF_OBJ),    INTENT(IN)    :: ACLADM,UNLADM,KSP,KSR,KS
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: HIDING
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: QS_C, QSXC, QSYC, CALFA,SALFA
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: T1,T2,T3,T4,T5,T6,T7,T8
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: T9,T10,T11,T12,T14
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: ZREF,CSTAEQ,CS,UCONV,VCONV
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: QS_S,QS,QSCL_C,QSCL_S
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: COEFPN
      TYPE(BIEF_OBJ),    INTENT(INOUT) :: QSCLXS,QSCLYS,QSCL
      TYPE(BIEF_MESH),   INTENT(INOUT) :: MESH
      DOUBLE PRECISION,  INTENT(IN)    :: XMVS,XMVE,GRAV,VCE
      DOUBLE PRECISION,  INTENT(IN)    :: XKV,HMIN,KARMAN,ZERO,PI
      DOUBLE PRECISION,  INTENT(IN)    :: PARTHENIADES,BIJK,XWC(NSICLA)
      DOUBLE PRECISION,  INTENT(IN)    :: FD90(NSICLA),CS0(NSICLA)
      DOUBLE PRECISION,  INTENT(IN)    :: VITCE,VITCD
      DOUBLE PRECISION,  INTENT(INOUT) :: AC(NSICLA),CMAX,FDM(NSICLA)
      DOUBLE PRECISION,  INTENT(INOUT) :: AVAIL(NPOIN,10,NSICLA)
!
!RK
      TYPE(BIEF_OBJ),    INTENT(IN)    :: U3D,V3D
      CHARACTER(LEN=24), INTENT(IN)    :: CODE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I,J
      DOUBLE PRECISION AT0,AAA,USTARP
!
      DOUBLE PRECISION U3DNORM
!
!======================================================================!
!======================================================================!
!                               PROGRAM                                !
!======================================================================!
!======================================================================!
!
! --- START : INITIALISES RATE OF TRANSPORT AND SUSPENSION
!
!     FOR INITIALISATION : SLOPE EFFECT AND DEVIATION ARE CANCELLED
!RK in case of coupling with T3D, the direction should come from the
! bottom velocity
      IF(CODE(1:9).EQ.'TELEMAC3D') THEN
        DO I=1,NPOIN
          u3dnorm=SQRT(U3D%R(I)*U3D%R(I)+V3D%R(I)*V3D%R(I))
          IF(U3DNORM.GE.1.D-12) THEN
            CALFA%R(I)=U3D%R(I)/u3dnorm
            SALFA%R(I)=V3D%R(I)/u3dnorm
          ELSE
            CALFA%R(I)=1.D0
            SALFA%R(I)=0.D0
          ENDIF
        ENDDO
      ELSE
        CALL OS('X=Y/Z   ',CALFA, U2D, UNORM, 0.D0, 2, 1.D0, 1.D-12)
        CALL OS('X=Y/Z   ',SALFA, V2D, UNORM, 0.D0, 2, 0.D0, 1.D-12)
      ENDIF
!
!  appel a effpnt ?
!
      CALL OS('X=C     ',X=COEFPN,C=1.D0)
!
      IF(CHARR) THEN
!
          CALL OS('X=C     ',X=HIDING,C=1.D0)
!
          DO I = 1, NSICLA
!
            IF(SEDCO(I)) THEN
!             IF COHESIVE: NO BEDLOAD TRANSPORT
              CALL OS('X=0     ', QSCL_C%ADR(I)%P)
            ELSE
!             IF NON COHESIVE
              CALL BEDLOAD_FORMULA
     &        (U2D,V2D,UNORM,HN,CF,MU,TOB,TOBW,UW,TW,THETAW,FW,
     &        ACLADM, UNLADM,KSP,KSR,AVAIL(1:NPOIN,1,I),
     &        NPOIN,ICF,HIDFAC,XMVS,XMVE,
     &        FDM(I),GRAV,VCE,XKV,HMIN,XWC(I),FD90(I),KARMAN,ZERO,
     &        PI,SUSP,AC(I),HIDING,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,
     &        T11,T12,QSCL_C%ADR(I)%P,QSCL_S%ADR(I)%P,
     &        IELMT,SECCURRENT,SLOPEFF,COEFPN,BIJK,HOULE)
              CALL OS('X=CX    ', X=QSCL_C%ADR(I)%P,C=1.D0/XKV)
            ENDIF
!           SUM ON ALL CLASSES
            DO J=1,NPOIN
              QS_C%R(J) = QS_C%R(J) + QSCL_C%ADR(I)%P%R(J)
            ENDDO
!
          ENDDO
!
!         COMPUTES THE X AND Y COMPONENTS OF TRANSPORT
!
          CALL OS('X=YZ    ', X=QSXC, Y=QS_C, Z=CALFA)
          CALL OS('X=YZ    ', X=QSYC, Y=QS_C, Z=SALFA)
!
      ENDIF
!
! ... START : COMPUTES THE SUSPENDED TRANSPORT
!
      IF(SUSP) THEN
!
!       COMPUTES THE INITIAL CONCENTRATIONS
!
!       FOR RANK IN TROUVE SEE POINT_SISYPHE, NOMVAR_SISYPHE
!       AND ALIRE IN SISYPHE.F (IT IS THE ADDRESS OF CONCENTRATIONS)
!V errror remplacer par 22?? Error in
       IF(.NOT.DEBU.OR.(TROUVE(22+(NOMBLAY+1)*NSICLA).EQ.0)) THEN
!
          CALL CONDIM_SUSP(CS,CS0,NSICLA,MESH%X%R,MESH%Y%R,AT0,NPOIN)
!
! INITIALISES ZREF
! START MODIFICATIONS (CV) ...
          IF(ICQ.EQ.1) THEN
                  CALL OS('X=Y     ', X=ZREF, Y=KSP)
            ELSEIF(ICQ.EQ.2) THEN
                  CALL OS('X=Y     ', X=ZREF, Y=KSR)
            ELSEIF(ICQ.EQ.3) THEN
                  CALL OS('X=Y     ', X=ZREF, Y=KS)
          ENDIF
! ...END MODIFICATIONS (CV)
!
!         OPTION: IMPOSED INFLOW CONCENTRATIONS ...
!
          IF(IMP_INFLOW_C) THEN
!
!           TAUP IN T8
            CALL OS('X=CYZ   ', X=T8, Y=TOB, Z=MU, C=1.D0)
!           USTAR (TOTAL) IN T9
            CALL OS('X=CY    ', X=T9, Y=TOB, C=1.D0/XMVE)
            CALL OS('X=SQR(Y)', X=T9, Y=T9)
!
!           START: LOOP ON THE CLASSES
!
            DO I=1,NSICLA
!
              IF(.NOT.SEDCO(I)) THEN
!
!             NON COHESIVE SED: INITIALISES CSTAEQ
!
                IF(ICQ.EQ.1) THEN
!V                  CALL OS('X=Y     ', X=ZREF, Y=KS)
                  CALL SUSPENSION_FREDSOE(ACLADM,T8,NPOIN,
     &                GRAV, XMVE, XMVS, ZERO, AC(I),  CSTAEQ )
                ELSEIF(ICQ.EQ.2) THEN
!V                  CALL OS('X=Y     ', X=ZREF, Y=KSR)
                  CALL SUSPENSION_BIJKER(T8,HN,NPOIN,CHARR,QS_C,ZREF,
     &                                   ZERO,HMIN,CSTAEQ,XMVE)
              ELSEIF(ICQ.EQ.3) THEN
                  CALL OS('X=Y     ', X=ZREF, Y=KS)
                CALL SUSPENSION_VANRIJN(ACLADM,T8,NPOIN,
     &                         GRAV,XMVE,XMVS,ZERO,AC(I),CSTAEQ,ZREF)
                ENDIF
!
!            ROUSE CONCENTRATION PROFILE IS ASSUMED BASED ON TOTAL FRICTION
!            VELOCITY
!
             CALL SUSPENSION_ROUSE(T9,HN,NPOIN,
     &                             KARMAN,HMIN,ZERO,XWC(I),ZREF,T12)
!
             DO J=1,NPOIN
               CSTAEQ%R(J)=CSTAEQ%R(J)*AVAIL(J,1,I)
             ENDDO
!            CALL OS( 'X=XY    ',X=CSTAEQ,Y=AVAI%ADR(I)%P)
             CALL OS( 'X=Y/Z   ',X=CS%ADR(I)%P,Y=CSTAEQ,Z=T12)
!
! END NON-COHESIVE
!
              ELSE
!
!               FOR COHESIVE SEDIMENT
!
!               THIS VALUE CAN BE ALSO CHANGED BY THE USER
!               IN SUBROUTINE USER_KRONE_PARTHENIADES
!
                CALL OS('X=Y     ', X=ZREF, Y=KSP)
!
                CMAX = MAX(CMAX,PARTHENIADES/XWC(I))
!
                IF(VITCE.GT.1.D-8.AND.VITCD.GT.1.D-8) THEN
                  DO J = 1, NPOIN
! FLUER
                  USTARP= SQRT(T8%R(J)/XMVE)
                  AAA= PARTHENIADES*
     &                MAX(((USTARP/VITCE)**2-1.D0),ZERO)
! FLUDPT
!                 BBB=XWC(I)*MAX((1.D0-(USTARP/VITCD)**2),ZERO)
!                 IF NO DEPOSITION, THE EQUILIBRIUM CONCENTRATION IS INFINITE!
                  CS%ADR(I)%P%R(J) = AAA/XWC(I)
!
                  ENDDO
                ELSE
                  CALL OS('X=0     ',X=CS%ADR(I)%P)
                ENDIF
!
! CV : 13/11/09
                DO J=1,NPOIN
                  CS%ADR(I)%P%R(J)=CS%ADR(I)%P%R(J)*AVAIL(J,1,I)
                ENDDO
!               CALL OS('X=XY    ',X=CS%ADR(I)%P,Y=AVAI%ADR(I)%P)
!
! END COHESIVE
!
              ENDIF
!
! END OF LOOP ON THE CLASSES
!
            ENDDO
!
! END OF OPTION: IMPOSED INFLOW CONCENTRATION
!
          ENDIF
!
! END OF ?
!
        ENDIF
!
! COMPUTES SUSPENDED TRANSPORT
!
        DO I=1,NPOIN
          UCONV%R(I) = U2D%R(I)
          VCONV%R(I) = V2D%R(I)
        ENDDO
!
        DO I=1,NSICLA
          IF(CORR_CONV.AND.(.NOT.SEDCO(I))) THEN
            CALL SUSPENSION_CONV( TOB, XMVE, CF,NPOIN,ZREF,U2D,V2D,HN,
     &                    HMIN,UCONV,VCONV,KARMAN,ZERO,XWC(I),T12,T14)
          ENDIF
!
          CALL OS('X=YZ    ',X=T11,Y=UCONV, Z=HN)
          CALL OS('X=YZ    ',X=T12,Y=VCONV, Z=HN)
!
          CALL OS('X=YZ    ',X=QSCLXS%ADR(I)%P,Y=CS%ADR(I)%P,Z=T11)
          CALL OS('X=YZ    ',X=QSCLYS%ADR(I)%P,Y=CS%ADR(I)%P,Z=T12)
!
          CALL OS('X=N(Y,Z) ',X=QSCL_S%ADR(I)%P,
     &            Y=QSCLXS%ADR(I)%P, Z=QSCLYS%ADR(I)%P)
!
          DO J=1,NPOIN
            QS_S%R(J) = QS_S%R(J) + QSCL_S%ADR(I)%P%R(J)
          ENDDO
        ENDDO
!
!     IF(SUSP) THEN
      ENDIF
!
!     COMPUTES THE TRANSPORT FOR EACH CLASS (IF NOT RESTART OR IF
!                                              DATA NOT FOUND)
! CV bug : +2
      DO I=1, NSICLA
        IF(.NOT.DEBU.OR.TROUVE(I+22+NOMBLAY*NSICLA).EQ.0) THEN
          IF(DEBU.AND.  TROUVE(I+22+NOMBLAY*NSICLA).EQ.0) THEN
            IF(LNG.EQ.1) THEN
              WRITE(LU,*) 'QSCL REINITIALISE DANS INIT_TRANSPORT'
              WRITE(LU,*) 'POUR LA CLASSE ',I
            ENDIF
            IF(LNG.EQ.2) THEN
              WRITE(LU,*) 'QSCL REINITIALISED IN INIT_TRANSPORT'
              WRITE(LU,*) 'FOR CLASS ',I
            ENDIF
          ENDIF
          IF(CHARR.AND.SUSP) THEN
            CALL OS('X=Y+Z   ', X=QSCL%ADR(I)%P,
     &              Y=QSCL_S%ADR(I)%P, Z=QSCL_C%ADR(I)%P)
          ELSEIF(CHARR) THEN
            CALL OS('X=Y     ',X=QSCL%ADR(I)%P,Y=QSCL_C%ADR(I)%P)
          ELSEIF(SUSP) THEN
            CALL OS('X=Y     ',X=QSCL%ADR(I)%P,Y=QSCL_S%ADR(I)%P)
          ENDIF
        ENDIF
      ENDDO
!
!     COMPUTES TOTAL TRANSPORT QS (IF NOT RESTART OR IF QS NOT FOUND)
!
      IF(.NOT.DEBU.OR.TROUVE(15).EQ.0) THEN
        IF(DEBU.AND.  TROUVE(15).EQ.0) THEN
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'QS REINITIALISE DANS INIT_TRANSPORT'
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'QS REINITIALISED IN INIT_TRANSPORT'
          ENDIF
        ENDIF
        IF(CHARR.AND.SUSP) THEN
          CALL OS('X=Y+Z   ',X=QS,Y=QS_C,Z=QS_S)
        ELSEIF(CHARR) THEN
          CALL OS('X=Y     ',X=QS,Y=QS_C)
        ELSEIF(SUSP) THEN
          CALL OS('X=Y     ',X=QS,Y=QS_S)
        ENDIF
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END