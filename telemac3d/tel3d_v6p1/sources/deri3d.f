!                    *****************
                     SUBROUTINE DERI3D
!                    *****************
!
     &(U,V,W,DT,X,Y,ZSTAR,Z,IKLE2,IBOR,LT,NPOIN2,NELEM2,NPLAN,NPLINT,
     & SURDET,XFLOT,YFLOT,ZFLOT,ZSFLOT,SHPFLO,SHZFLO,DEBFLO,FINFLO,
     & ELTFLO,ETAFLO,NFLOT,NITFLO,FLOPRD)
!
!***********************************************************************
! TELEMAC3D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    - COMPUTES THE BARYCENTRIC COORDINATES OF A FLOAT
!+                  IN THE MESH, AT THE TIME WHEN IT'S RELEASED.
!+
!+            - COMPUTES THE SUCCESSIVE POSITIONS OF THIS FLOAT,
!+                  CARRIED WITHOUT FRICTION BY THE FLOW, FOR SUBSEQUENT
!+                  TIMESTEPS.
!
!history  JACEK A. JANKOWSKI PINXIT
!+        **/03/1999
!+        
!+   FORTRAN95 VERSION 
!
!history  J-M JANIN (LNH)
!+        10/03/2010
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
!| DEBFLO         |-->| NUMEROS DES PAS DE TEMPS DE LARGAGE DE
!|                |   | CHAQUE FLOTTEUR.
!| DT             |-->| PAS DE TEMPS.
!| ELTFLO         |<->| NUMEROS DES ELEMENTS 2DH DANS LESQUELS SE
!|                |   | TROUVE A CET INSTANT CHACUN DES FLOTTEURS.
!| ETAFLO         |<->| NUMEROS DES PLANS DANS LESQUELS SE
!|                |   | TROUVE A CET INSTANT CHACUN DES FLOTTEURS.
!| FINFLO         |<->| NUMEROS DES PAS DE TEMPS DE FIN DE CALCUL DE
!|                |   | DERIVE POUR CHAQUE FLOTTEUR.
!|                |   | FORCE ICI SI UN FLOTTEUR SORT PAR UNE FR. LIQ.
!| FLOPRD         |-->| NOMBRE DE PAS DE TEMPS ENTRE 2 ENREGITREMENTS
!|                |   | DES POSITIONS SUCCESSIVES DES FLOTTEURS.
!| IBOR           |-->| NUMEROS DES ELEMENTS AYANT UNE FACE COMMUNE
!|                |   | AVEC L'ELEMENT .  SI IBOR
!|                |   | ON A UNE FACE LIQUIDE,SOLIDE,OU PERIODIQUE
!| IKLE2          |-->| TRANSITION ENTRE LES NUMEROTATIONS LOCALE
!|                |   | ET GLOBALE DU MAILLAGE 2D
!| LT             |-->| NUMERO DU PAS DE TEMPS
!| NELEM2         |-->| NOMBRE D'ELEMENTS DU MAILLAGE 2D
!| NFLOT          |-->| NOMBRE DE FLOTTEURS.
!| NITFLO         |-->| NOMBRE MAXIMAL D'ENREGISTREMENTS DES
!|                |   | POSITIONS SUCCESSIVES DES FLOTTEURS.
!| NPLAN          |-->| NOMBRE DE PLANS
!| NPLINT         |-->| NUMERO DU PLAN INTERMEDIAIRE
!| NPOIN2         |-->| NOMBRE DE POINTS DU MAILLAGE 2D
!| SHPFLO         |<->| COORDONNEES BARYCENTRIQUES INSTANTANNEES DES
!|                |   | FLOTTEURS EN 2DH
!| SHZFLO         |<->| COORDONNEES BARYCENTRIQUES INSTANTANNEES DES
!|                |   | FLOTTEURS EN 1DV
!| SURDET         |-->| VARIABLE UTILISEE PAR LA TRANSFORMEE ISOPARAM.
!| U,V,W          |-->| COMPOSANTE DE LA VITESSE
!| X,Y,ZFLOT      |<->| POSITIONS SUCCESSIVES DES FLOTTEURS.
!| X,Y,ZSTAR,Z    |-->| COORDONNEES DES POINTS DU MAILLAGE.
!| XFLOT          |---| 
!| YFLOT          |---| 
!| ZSFLOT         |<->| Z DES FLOTTEURS DANS LE MAILLAGE TRANSFORME
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN) :: NPOIN2,NELEM2,NPLAN,NPLINT,LT
      INTEGER, INTENT(IN) :: NFLOT,NITFLO,FLOPRD
!
      INTEGER, INTENT(IN) :: IKLE2(NELEM2,3),IBOR(NELEM2,5,NPLAN-1)
      INTEGER, INTENT(INOUT) :: DEBFLO(NFLOT), FINFLO(NFLOT)
      INTEGER, INTENT(INOUT) :: ELTFLO(NFLOT), ETAFLO(NFLOT)
!
      DOUBLE PRECISION, INTENT(IN)    :: U(NPOIN2,NPLAN)
      DOUBLE PRECISION, INTENT(IN)    :: V(NPOIN2,NPLAN)
      DOUBLE PRECISION, INTENT(IN)    :: W(NPOIN2,NPLAN)
      DOUBLE PRECISION, INTENT(IN)    :: X(NPOIN2), Y(NPOIN2)
      DOUBLE PRECISION, INTENT(IN)    :: Z(NPOIN2,NPLAN)
      DOUBLE PRECISION, INTENT(IN)    :: ZSTAR(NPLAN)
      DOUBLE PRECISION, INTENT(INOUT) :: XFLOT(NITFLO,NFLOT)
      DOUBLE PRECISION, INTENT(INOUT) :: YFLOT(NITFLO,NFLOT)
      DOUBLE PRECISION, INTENT(INOUT) :: ZFLOT(NITFLO,NFLOT)
      DOUBLE PRECISION, INTENT(INOUT) :: ZSFLOT(NITFLO,NFLOT)
      DOUBLE PRECISION, INTENT(IN)    :: SURDET(NELEM2)
      DOUBLE PRECISION, INTENT(INOUT) :: SHPFLO(3,NFLOT)
      DOUBLE PRECISION, INTENT(INOUT) :: SHZFLO(NFLOT)
      DOUBLE PRECISION, INTENT(IN)    :: DT
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,IPLAN,LTT,NRK,NSP(1),LTP,ISO(1)
      INTEGER IFLOT,N1,N2,N3
      DOUBLE PRECISION DET1,DET2,DET3,ZF,ZI,ZS
!
! LOCAL, AUTOMATIC... (?)
!
      DOUBLE PRECISION DX(NFLOT),DY(NFLOT),DZ(NFLOT),TEST(NFLOT)
!
!-----------------------------------------------------------------------
!
      LTT=(LT-1)/FLOPRD + 1
      LTP=(LT-2)/FLOPRD + 1
!
      FLOTBOUCLE: DO IFLOT=1,NFLOT
!
        IF(LT.EQ.DEBFLO(IFLOT)) THEN
!
!-----------------------------------------------------------------------
!
!   - COMPUTES THE BARYCENTRIC COORDINATES OF A FLOAT IN THE MESH,
!     AT THE TIME WHEN IT'S RELEASED
!
!-----------------------------------------------------------------------
!
          XFLOT(LTT,IFLOT) = XFLOT(1,IFLOT)
          YFLOT(LTT,IFLOT) = YFLOT(1,IFLOT)
!
! P1 PRISMS MESH
! ==============
!
            DO IELEM=1,NELEM2
              N1=IKLE2(IELEM,1)
              N2=IKLE2(IELEM,2)
              N3=IKLE2(IELEM,3)
!
! DET1 = (N2N3,N2FLOT)  DET2 = (N3N1,N3FLOT)  DET3 = (N1N2,N1FLOT)
! ----------------------------------------------------------------
!
              DET1=(X(N3)-X(N2))*(YFLOT(LTT,IFLOT)-Y(N2))
     &            -(Y(N3)-Y(N2))*(XFLOT(LTT,IFLOT)-X(N2))
              DET2=(X(N1)-X(N3))*(YFLOT(LTT,IFLOT)-Y(N3))
     &            -(Y(N1)-Y(N3))*(XFLOT(LTT,IFLOT)-X(N3))
              DET3=(X(N2)-X(N1))*(YFLOT(LTT,IFLOT)-Y(N1))
     &            -(Y(N2)-Y(N1))*(XFLOT(LTT,IFLOT)-X(N1))
              IF(DET1.GE.0.D0.AND.DET2.GE.0.D0.AND.DET3.GE.0.D0) GOTO 30
            ENDDO
!
            IF (LNG.EQ.1) WRITE(LU,101) IFLOT
            IF (LNG.EQ.2) WRITE(LU,102) IFLOT
            CALL PLANTE(1)
            STOP
!
! 2D ELEMENT CONTAINING THE RELEASE POINT, COMPUTES THE SHPFLO
! ---------------------------------------------------------------
!
30          CONTINUE
            SHPFLO(1,IFLOT) = DET1*SURDET(IELEM)
            SHPFLO(2,IFLOT) = DET2*SURDET(IELEM)
            SHPFLO(3,IFLOT) = DET3*SURDET(IELEM)
            ELTFLO (IFLOT)  = IELEM
!
! IDENTIFIES THE LAYER AND SHZFLO
! ----------------------------------
!
            ZF = Z(N1,1)      * SHPFLO(1,IFLOT)
     &         + Z(N2,1)      * SHPFLO(2,IFLOT)
     &         + Z(N3,1)      * SHPFLO(3,IFLOT)
            ZS = Z(N1,NPLAN)  * SHPFLO(1,IFLOT)
     &         + Z(N2,NPLAN)  * SHPFLO(2,IFLOT)
     &         + Z(N3,NPLAN)  * SHPFLO(3,IFLOT)
!
            IF(ZFLOT(1,IFLOT).GT.ZS.OR.ZFLOT(1,IFLOT).LT.ZF) THEN
              IF (LNG.EQ.1) WRITE(LU,101) IFLOT
              IF (LNG.EQ.2) WRITE(LU,102) IFLOT
              CALL PLANTE(1)
              STOP
            ENDIF
!
            ZSFLOT(LTT,IFLOT) = (ZFLOT(1,IFLOT)-ZF) / (ZS-ZF)
            DO IPLAN = 1,NPLAN-1
              IF(ZSFLOT(LTT,IFLOT).GE.ZSTAR(IPLAN)) THEN
                ETAFLO(IFLOT) = IPLAN
                SHZFLO(IFLOT) = (ZSFLOT(LTT,IFLOT)-ZSTAR(IPLAN))
     &                          / (ZSTAR(IPLAN+1)-ZSTAR(IPLAN))
              ENDIF
            ENDDO
!
        ELSEIF(LT.GT.DEBFLO(IFLOT).AND.LT.LE.FINFLO(IFLOT)) THEN
!
!-----------------------------------------------------------------------
!
!   - COMPUTES THE SUCCESSIVE POSITIONS OF THIS FLOAT, CARRIED WITHOUT
!     FRICTION BY THE FLOW, FOR SUBSEQUENT TIMESTEPS
!
!-----------------------------------------------------------------------
!
! NUMBER OF RUNGE-KUTTA SUB-STEPS BY CROSSED ELEMENT
! ==================================================
!
          NRK     =  3
!
          XFLOT(LTT,IFLOT)  = XFLOT(LTP,IFLOT)
          YFLOT(LTT,IFLOT)  = YFLOT(LTP,IFLOT)
          ZSFLOT(LTT,IFLOT) = ZSFLOT(LTP,IFLOT)
!
!  P1 PRISMS
!  =========
!
          CALL CHAR41( U , V , W , DT , NRK , X , Y , ZSTAR , Z ,
     &                 IKLE2 , IBOR , XFLOT(LTT,IFLOT) ,
     &                 YFLOT(LTT,IFLOT) , ZSFLOT(LTT,IFLOT) , DX ,
     &                 DY , DZ , SHPFLO(1,IFLOT) , SHZFLO(IFLOT) ,
     &                 ELTFLO(IFLOT) , ETAFLO(IFLOT) , NSP ,
     &                 1 , NPOIN2 , NELEM2 , NPLAN ,
     &                 SURDET , 1 , ISO, TEST )
!
!  CASE OF LOST FLOATS
!  ===================
!
          IF(ELTFLO(IFLOT).LE.0) FINFLO(IFLOT) = LT
!
        ENDIF
!
!       COMPUTES THE REAL Z COORDINATE
!
        IELEM=ELTFLO(IFLOT)
        N1=IKLE2(IELEM,1)
        N2=IKLE2(IELEM,2)
        N3=IKLE2(IELEM,3)
        ZF = Z(N1,1)     * SHPFLO(1,IFLOT)
     &     + Z(N2,1)     * SHPFLO(2,IFLOT)
     &     + Z(N3,1)     * SHPFLO(3,IFLOT)
        ZS = Z(N1,NPLAN) * SHPFLO(1,IFLOT)
     &     + Z(N2,NPLAN) * SHPFLO(2,IFLOT)
     &     + Z(N3,NPLAN) * SHPFLO(3,IFLOT)
!
        ZFLOT(LTT,IFLOT) = ZF+ZSFLOT(LTT,IFLOT)*(ZS-ZF)
!
      END DO FLOTBOUCLE
!
!-----------------------------------------------------------------------
!
101   FORMAT(' DERI3D: ERREUR D''INTERPOLATION :',/,
     &       ' LARGAGE DU FLOTTEUR',I6,/,
     &       ' EN DEHORS DU DOMAINE DE CALCUL')
102   FORMAT(' DERI3D: INTERPOLATION ERROR :',/,
     &       ' DROP POINT OF FLOAT',I6,/,
     &       ' OUT OF THE DOMAIN')
!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE DERI3D