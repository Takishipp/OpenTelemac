!
!  CHANGES VS SOURCE FILES:
!  IN NOMVAR_2D_IN_3D : TEXTPR(1,2 AND 4) PUT IN FRENCH
!  BECAUSE THE COMPUTATION CONTINUED IS DONE WITH A FILE IN FRENCH
!  IN FLOT3D
!
!                    **************************
                     SUBROUTINE NOMVAR_2D_IN_3D
!                    **************************
!
     &(TEXTE,TEXTPR,MNEMO,NTRAC,MAXTRA,
     & NAMETRAC,N_NAMES_PRIV2D,NAMES_PRIVE2D)
!
!***********************************************************************
! TELEMAC3D   V7P1
!***********************************************************************
!
!brief    GIVES THE VARIABLE NAMES FOR THE RESULTS AND GEOMETRY
!+                FILES (IN TEXTE) AND FOR THE PREVIOUS COMPUTATION
!+                RESULTS FILE (IN TEXTPR).
!
!note     TEXTE AND TEXTPR ARE GENERALLY THE SAME EXCEPT IF THE
!+         PREVIOUS COMPUTATION COMES FROM ANOTHER SOFTWARE.
!
!history  J-M HERVOUET (LNH)
!+        15/09/06
!+        V5P7
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
!| MAXTRA         |-->| MAXIMUM NUMBER OF TRACERS
!| MNEMO          |<->| MNEMOTECHNIC NAME
!| NAMETRAC       |-->| NAME OF TRACERS
!| NTRAC          |-->| NUMBER OF ACTIVE TRACERS
!| TEXTE          |<->| SEE ABOVE
!| TEXTPR         |<->| SEE ABOVE
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE DECLARATIONS_TELEMAC3D, ONLY: NCOUCH, NLAYMAX, MIXTE
!
      USE DECLARATIONS_SPECIAL
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER          , INTENT(IN)    :: NTRAC,N_NAMES_PRIV2D,MAXTRA
      CHARACTER(LEN=32), INTENT(INOUT) :: TEXTE(*),TEXTPR(*)
      CHARACTER(LEN=8) , INTENT(INOUT) :: MNEMO(*)
      CHARACTER(LEN=32), INTENT(IN)    :: NAMETRAC(MAXTRA)
      CHARACTER(LEN=32), INTENT(IN)    :: NAMES_PRIVE2D(4)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CHARACTER(LEN=2) I_IN_2_LETTERS(32)
      DATA I_IN_2_LETTERS /'1 ','2 ','3 ','4 ','5 ','6 ','7 ','8 ','9 ',
     &                     '10','11','12','13','14','15','16','17','18',
     &                     '19','20','21','22','23','24','25','26','27',
     &                     '28','29','30','31','32'/
!
      CHARACTER(LEN=32) TEXTE_ES(NLAYMAX)
      CHARACTER(LEN=8)  MNEMO_ES(NLAYMAX)
      CHARACTER(LEN=2)  LAY
!
      INTEGER I,NEXT,K
!
!-----------------------------------------------------------------------
!
!  ENGLISH
!
      IF(LNG.EQ.2) THEN
!
      TEXTE (1 ) = 'VELOCITY U      M/S             '
      TEXTE (2 ) = 'VELOCITY V      M/S             '
      TEXTE (3 ) = 'CELERITY        M/S             '
      TEXTE (4 ) = 'WATER DEPTH     M               '
      TEXTE (5 ) = 'FREE SURFACE    M               '
      TEXTE (6 ) = 'BOTTOM          M               '
      TEXTE (7 ) = 'FROUDE NUMBER                   '
      TEXTE (8 ) = 'SCALAR FLOWRATE M2/S            '
      TEXTE (9 ) = 'TRACER                          '
      TEXTE (10) = 'TURBULENT ENERG.JOULE/KG        '
      TEXTE (11) = 'DISSIPATION     WATT/KG         '
      TEXTE (12) = 'VISCOSITY       M2/S            '
      TEXTE (13) = 'FLOWRATE ALONG XM2/S            '
      TEXTE (14) = 'FLOWRATE ALONG YM2/S            '
      TEXTE (15) = 'SCALAR VELOCITY M/S             '
      TEXTE (16) = 'WIND ALONG X    M/S             '
      TEXTE (17) = 'WIND ALONG Y    M/S             '
      TEXTE (18) = 'AIR PRESSURE    PASCAL          '
      TEXTE (19) = 'BOTTOM FRICTION                 '
      TEXTE (20) = 'DRIFT ALONG X   M               '
      TEXTE (21) = 'DRIFT ALONG Y   M               '
      TEXTE (22) = 'COURANT NUMBER                  '
      TEXTE (23) = 'RIGID BED       M               '
      TEXTE (24) = 'BED THICKNESS   M               '
      TEXTE (25) = 'EROSION FLUX    KG/M2/S         '
      TEXTE (26) = 'DEPOSITION FLUX KG/M2/S         '
      TEXTE (27) = 'PRIVE 1         ??              '
      TEXTE (28) = 'PRIVE 2         ??              '
      TEXTE (29) = 'PRIVE 3         ??              '
      TEXTE (30) = 'PRIVE 4         ??              '
      TEXTE (31) = 'FRICTION VELOCITM/S             '
      TEXTE (32) = 'SOLID DISCHARGE M2/S            '
      TEXTE (33) = 'SOLID DIS IN X  M2/S            '
      TEXTE (34) = 'SOLID DIS IN Y  M2/S            '
      TEXTE (35) = 'HIGH WATER MARK M               '
      TEXTE (36) = 'HIGH WATER TIME S               '
      TEXTE (37) = 'BED EVOLUTION   M               '
      TEXTE (38) = 'AIR TEMPERATURE DEGREE          '
!
! TEXTPR IS USED TO READ PREVIOUS COMPUTATION FILES.
! IN GENERAL TEXTPR=TEXTE BUT YOU CAN FOLLOW UP A COMPUTATION
! FROM ANOTHER CODE WITH DIFFERENT VARIABLE NAMES, WHICH MUST
! BE GIVEN HERE:
!
! BEGIN OF PART SPECIFIC TO THIS CASE
!     TEXTPR (1 ) = 'VELOCITY U      M/S             '
!     TEXTPR (2 ) = 'VELOCITY V      M/S             '
!     TEXTPR (3 ) = 'CELERITY        M/S             '
!     TEXTPR (4 ) = 'WATER DEPTH     M               '
!     NEXT LINE MODIFIED
      TEXTPR (1 ) = 'VITESSE U       M/S             '
!     NEXT LINE MODIFIED
      TEXTPR (2 ) = 'VITESSE V       M/S             '
      TEXTPR (3 ) = 'CELERITY        M/S             '
!     NEXT LINE MODIFIED
      TEXTPR (4 ) = 'HAUTEUR D''EAU   M               '
! END OF PART SPECIFIC TO THIS CASE
      TEXTPR (5 ) = 'FREE SURFACE    M               '
      TEXTPR (6 ) = 'BOTTOM          M               '
      TEXTPR (7 ) = 'FROUDE NUMBER                   '
      TEXTPR (8 ) = 'SCALAR FLOWRATE M2/S            '
      TEXTPR (9 ) = 'TRACER                          '
      TEXTPR (10) = 'TURBULENT ENERG.JOULE/KG        '
      TEXTPR (11) = 'DISSIPATION     WATT/KG         '
      TEXTPR (12) = 'VISCOSITY       M2/S            '
      TEXTPR (13) = 'FLOWRATE ALONG XM2/S            '
      TEXTPR (14) = 'FLOWRATE ALONG YM2/S            '
      TEXTPR (15) = 'SCALAR VELOCITY M/S             '
      TEXTPR (16) = 'WIND ALONG X    M/S             '
      TEXTPR (17) = 'WIND ALONG Y    M/S             '
      TEXTPR (18) = 'AIR PRESSURE    PASCAL          '
      TEXTPR (19) = 'BOTTOM FRICTION                 '
      TEXTPR (20) = 'DRIFT ALONG X   M               '
      TEXTPR (21) = 'DRIFT ALONG Y   M               '
      TEXTPR (22) = 'COURANT NUMBER                  '
      TEXTPR (23) = 'RIGID BED       M               '
      TEXTPR (24) = 'BED THICKNESS   M               '
      TEXTPR (25) = 'EROSION FLUX    KG/M2/S         '
      TEXTPR (26) = 'DEPOSITION FLUX KG/M2/S         '
      TEXTPR (27) = 'PRIVE 1         ??              '
      TEXTPR (28) = 'PRIVE 2         ??              '
      TEXTPR (29) = 'PRIVE 3         ??              '
      TEXTPR (30) = 'PRIVE 4         ??              '
      TEXTPR (31) = 'FRICTION VELOCITM/S             '
      TEXTPR (32) = 'SOLID DISCHARGE M2/S            '
      TEXTPR (33) = 'SOLID DIS IN X  M2/S            '
      TEXTPR (34) = 'SOLID DIS IN Y  M2/S            '
      TEXTPR (35) = 'HIGH WATER MARK M               '
      TEXTPR (36) = 'HIGH WATER TIME S               '
      TEXTPR (37) = 'BED EVOLUTION   M               '
      TEXTPR (38) = 'AIR TEMPERATURE DEGREE          '
!
!-----------------------------------------------------------------------
!
!  FRANCAIS OU AUTRE
!
      ELSE
!
      TEXTE (1 ) = 'VITESSE U       M/S             '
      TEXTE (2 ) = 'VITESSE V       M/S             '
      TEXTE (3 ) = 'CELERITE        M/S             '
      TEXTE (4 ) = 'HAUTEUR D''EAU   M               '
      TEXTE (5 ) = 'SURFACE LIBRE   M               '
      TEXTE (6 ) = 'FOND            M               '
      TEXTE (7 ) = 'FROUDE                          '
      TEXTE (8 ) = 'DEBIT SCALAIRE  M2/S            '
      TEXTE (9 ) = 'TRACEUR                         '
      TEXTE (10) = 'ENERGIE TURBUL. JOULE/KG        '
      TEXTE (11) = 'DISSIPATION     WATT/KG         '
      TEXTE (12) = 'VISCOSITE TURB. M2/S            '
      TEXTE (13) = 'DEBIT SUIVANT X M2/S            '
      TEXTE (14) = 'DEBIT SUIVANT Y M2/S            '
      TEXTE (15) = 'VITESSE SCALAIREM/S             '
      TEXTE (16) = 'VENT X          M/S             '
      TEXTE (17) = 'VENT Y          M/S             '
      TEXTE (18) = 'PRESSION ATMOS. PASCAL          '
      TEXTE (19) = 'FROTTEMENT                      '
      TEXTE (20) = 'DERIVE EN X     M               '
      TEXTE (21) = 'DERIVE EN Y     M               '
      TEXTE (22) = 'NBRE DE COURANT                 '
      TEXTE (23) = 'FOND RIGIDE     M               '
      TEXTE (24) = 'EPAISSEUR DU LITM               '
      TEXTE (25) = 'FLUX D''EROSION KG/M2/S         '
      TEXTE (26) = 'FLUX DE DEPOT   KG/M2/S         '
      TEXTE (27) = 'PRIVE 1         ??              '
      TEXTE (28) = 'PRIVE 2         ??              '
      TEXTE (29) = 'PRIVE 3         ??              '
      TEXTE (30) = 'PRIVE 4         ??              '
      TEXTE (31) = 'VITESSE FROT    M/S             '
      TEXTE (32) = 'DEBIT SOLIDE    M2/S            '
      TEXTE (33) = 'DEBIT SOL EN X  M2/S            '
      TEXTE (34) = 'DEBIT SOL EN Y  M2/S            '
      TEXTE (35) = 'COTE MAXIMUM    M               '
      TEXTE (36) = 'TEMPS COTE MAXI S               '
      TEXTE (37) = 'EVOLUTION FOND  M               '
      TEXTE (38) = 'TEMPERATURE AIR DEGREE          '
!
! TEXTPR SERT A LA LECTURE DES FICHIERS DE CALCULS PRECEDENTS
! A PRIORI TEXTPR=TEXTE MAIS ON PEUT ESSAYER DE FAIRE UNE SUITE
! DE CALCUL A PARTIR D'UN AUTRE CODE.
!
      TEXTPR (1 ) = 'VITESSE U       M/S             '
      TEXTPR (2 ) = 'VITESSE V       M/S             '
      TEXTPR (3 ) = 'CELERITE        M/S             '
      TEXTPR (4 ) = 'HAUTEUR D''EAU   M               '
      TEXTPR (5 ) = 'SURFACE LIBRE   M               '
      TEXTPR (6 ) = 'FOND            M               '
      TEXTPR (7 ) = 'FROUDE                          '
      TEXTPR (8 ) = 'DEBIT SCALAIRE  M2/S            '
      TEXTPR (9 ) = 'TRACEUR                         '
      TEXTPR (10) = 'ENERGIE TURBUL. JOULE/KG        '
      TEXTPR (11) = 'DISSIPATION     WATT/KG         '
      TEXTPR (12) = 'VISCOSITE TURB. M2/S            '
      TEXTPR (13) = 'DEBIT SUIVANT X M2/S            '
      TEXTPR (14) = 'DEBIT SUIVANT Y M2/S            '
      TEXTPR (15) = 'VITESSE SCALAIREM/S             '
      TEXTPR (16) = 'VENT X          M/S             '
      TEXTPR (17) = 'VENT Y          M/S             '
      TEXTPR (18) = 'PRESSION ATMOS. PASCAL          '
      TEXTPR (19) = 'FROTTEMENT                      '
      TEXTPR (20) = 'DERIVE EN X     M               '
      TEXTPR (21) = 'DERIVE EN Y     M               '
      TEXTPR (22) = 'NBRE DE COURANT                 '
      TEXTPR (23) = 'FOND RIGIDE     M               '
      TEXTPR (24) = 'EPAISSEUR DU LITM               '
      TEXTPR (25) = 'FLUX D''EROSION KG/M2/S         '
      TEXTPR (26) = 'FLUX DE DEPOT   KG/M2/S         '
      TEXTPR (27) = 'PRIVE 1         ??              '
      TEXTPR (28) = 'PRIVE 2         ??              '
      TEXTPR (29) = 'PRIVE 3         ??              '
      TEXTPR (30) = 'PRIVE 4         ??              '
      TEXTPR (31) = 'VITESSE FROT    M/S             '
      TEXTPR (32) = 'DEBIT SOLIDE    M2/S            '
      TEXTPR (33) = 'DEBIT SOL EN X  M2/S            '
      TEXTPR (34) = 'DEBIT SOL EN Y  M2/S            '
      TEXTPR (35) = 'COTE MAXIMUM    M               '
      TEXTPR (36) = 'TEMPS COTE MAXI S               '
      TEXTPR (37) = 'EVOLUTION FOND  M               '
      TEXTPR (38) = 'TEMPERATURE AIR DEGREE          '
!
!-----------------------------------------------------------------------
!
      ENDIF
!
!     NAMES OF 2D PRIVATE VARIABLES
!
      IF(N_NAMES_PRIV2D.GT.0) THEN
        DO I=1,N_NAMES_PRIV2D
          TEXTE(26+I)  = NAMES_PRIVE2D(I)
          TEXTPR(26+I) = NAMES_PRIVE2D(I)
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
!   ALIASES FOR THE VARIABLES IN THE STEERING FILE
!
!     UVCHSBFQTKEDIJMXYPWAGLNORZ
!     VELOCITY COMPONENT U
      MNEMO(1)   = 'U       '
!     VELOCITY COMPONENT V
      MNEMO(2)   = 'V       '
!     CELERITY
      MNEMO(3)   = 'C       '
!     WATER DEPTH
      MNEMO(4)   = 'H       '
!     FREE SURFACE ELEVATION
      MNEMO(5)   = 'S       '
!     BOTTOM ELEVATION
      MNEMO(6)   = 'B       '
!     FROUDE
      MNEMO(7)   = 'F       '
!     FLOW RATE
      MNEMO(8)   = 'Q       '
!     TRACER
      MNEMO(9)   = 'T       '
!     TURBULENT ENERGY
      MNEMO(10)   = 'K       '
!     DISSIPATION
      MNEMO(11)   = 'E       '
!     TURBULENT VISCOSITY
      MNEMO(12)   = 'D       '
!     FLOWRATE ALONG X
      MNEMO(13)   = 'I       '
!     FLOWRATE ALONG Y
      MNEMO(14)   = 'J       '
!     SPEED
      MNEMO(15)   = 'M       '
!     WIND COMPONENT X
      MNEMO(16)   = 'X       '
!     WIND COMPONENT Y
      MNEMO(17)   = 'Y       '
!     ATMOSPHERIC PRESSURE
      MNEMO(18)   = 'P       '
!     FRICTION
      MNEMO(19)   = 'W       '
!     DRIFT IN X
      MNEMO(20)   = 'A       '
!     DRIFT IN Y
      MNEMO(21)   = 'G       '
!     COURANT NUMBER
      MNEMO(22)   = 'L       '
!     RIGID BOTTOM
      MNEMO(23)   = 'RB      '
!     SEDIMENT LAYER THICKNESS
      MNEMO(24)   = 'HD      '
!     EROSION FLUX
      MNEMO(25)   = 'EF      '
!     DEPOSITION FLUX
      MNEMO(26)   = 'DF      '
!     VARIABLE 27
      MNEMO(27)   = 'PRIVE1  '
!     VARIABLE 28
      MNEMO(28)   = 'PRIVE2  '
!     VARIABLE 29
      MNEMO(29)   = 'PRIVE3  '
!     VARIABLE 30
      MNEMO(30)   = 'PRIVE4  '
!     FRICTION VELOCITY
      MNEMO(31)   = 'US      '
!     SOLID DISCHARGE
      MNEMO(32)   = 'QS      '
!     SOLID DISCHARGE ALONG X
      MNEMO(33)   = 'QSX     '
!     SOLID DISCHARGE ALONG Y
      MNEMO(34)   = 'QSY     '
!     HIGH WATER MARK
      MNEMO(35)   = 'MAXZ    '
!     HIGH WATER TIME
      MNEMO(36)   = 'TMXZ    '
!     BED EVOLUTION
      MNEMO(37)   = 'DZF     '
!     AIR TEMPERATURE
      MNEMO(38)   = 'TAIR    '
!
!-----------------------------------------------------------------------
!
!     TRACERS
!
      NEXT = 38+1
!
      IF(NTRAC.GT.0) THEN
        DO I=1,NTRAC
          TEXTE(NEXT+I-1) = NAMETRAC(I)
          MNEMO(NEXT+I-1) = 'TA'//I_IN_2_LETTERS(I)//'    '
        ENDDO
      ENDIF
!
      IF(NEXT+NTRAC-1.GT.100) THEN
        IF(LNG.EQ.1) WRITE(LU,98)
98      FORMAT(1X,'NOMVAR_2D_IN_3D : MAXVAR=100 TROP PETIT')
        IF(LNG.EQ.2) WRITE(LU,99)
99      FORMAT(1X,'NOMVAR_2D_IN_3D : MAXVAR=100 TOO SMALL')
      ENDIF
!
! CV LAYER THICKNESS PRINTOUT
!
      DO K=1,NCOUCH
        IF(K.LT.10) THEN
          WRITE(LAY,'(I1)') K
          MNEMO_ES(K) = TRIM(LAY)//'ES     '
        ELSEIF(K.LT.100) THEN
          WRITE(LAY,'(I2)') K
          MNEMO_ES(K) = TRIM(LAY)//'ES    '
        ELSE
          WRITE (LU,*) 'NOMVAR_2D: NOT IMPLEMENTED FOR ',NCOUCH
          WRITE (LU,*) '                LAYERS'
          CALL PLANTE(1)
          STOP
        ENDIF
        TEXTE_ES(K)(1:16)  = 'LAYER'//LAY//' THICKNESS'
        TEXTE_ES(K)(17:32) = 'M               '
      ENDDO
!
      NEXT=NEXT+NTRAC
!
!
      DO I=1,NCOUCH
!
        TEXTE(NEXT+I-1) = TEXTE_ES(I)
        MNEMO(NEXT+I-1) = MNEMO_ES(I)
!
      ENDDO
!
      NEXT = NEXT + NCOUCH
!
      IF(MIXTE) THEN
!       PERCENTAGE OF MUD IN THE BED
        IF(LNG.EQ.1) THEN
          TEXTE(NEXT) = 'POURCENTAGE VASE                '
        ENDIF
        IF(LNG.EQ.2) THEN
          TEXTE(NEXT) = 'MUD PERCENTAGE                  '
        ENDIF
        MNEMO(NEXT) = 'PVSCO   '
!       PERCENTAGE OF SAND IN THE BED
        IF(LNG.EQ.1) THEN
          TEXTE(NEXT+1) = 'POURCENT. SABLE                 '
        ENDIF
        IF(LNG.EQ.2) THEN
          TEXTE(NEXT+1) = 'SAND PERCENTAGE                 '
        ENDIF
        MNEMO(NEXT+1) = 'PVSNCO  '
      ENDIF
!
      DO I=38,100
        TEXTPR(I)=TEXTE(I)
      ENDDO
!
!-----------------------------------------------------------------------
!
      RETURN
      END
!                    *****************
                     SUBROUTINE FLOT3D
!                    *****************
!
     &(XFLOT,YFLOT,ZFLOT,NFLOT,NFLOT_MAX,X,Y,Z,IKLE,NELEM,NELMAX,NPOIN,
     & NPLAN,TAGFLO,SHPFLO,SHZFLO,ELTFLO,ETAFLO,MESH3D,LT,NIT,AT)
!
!***********************************************************************
! TELEMAC3D   V6P3                                   21/08/2010
!***********************************************************************
!
!brief    This subroutine is called at every time step, and the user can
!+        add or remove particles as in the example given
!
!history  J-M HERVOUET (EDF R&D, LNHE)
!+        26/02/2013
!+        V6P3
!+    First version.
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AT             |-->| TIME
!| ELTFLO         |<->| NUMBERS OF ELEMENTS WHERE ARE THE FLOATS
!| ETAFLO         |<->| LEVELS WHERE ARE THE FLOATS
!| LT             |-->| CURRENT TIME STEP
!| MESH3D         |<->| 3D MESH STRUCTURE
!| NFLOT          |-->| NUMBER OF FLOATS
!| NFLOT_MAX      |-->| MAXIMUM NUMBER OF FLOATS
!| NIT            |-->| NUMBER OF TIME STEPS
!| NPLAN          |-->| NUMBER OF PLANES
!| NPOIN          |-->| NUMBER OF POINTS IN THE MESH
!| SHPFLO         |<->| BARYCENTRIC COORDINATES OF FLOATS IN THEIR
!|                |   | ELEMENTS.
!| SHZFLO         |<->| BARYCENTRIC COORDINATES OF FLOATS IN THEIR LEVEL
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!| Z              |-->| ELEVATIONS OF POINTS IN THE MESH
!| XFLOT          |<->| ABSCISSAE OF FLOATING BODIES
!| YFLOT          |<->| ORDINATES OF FLOATING BODIES
!| ZFLOT          |<->| ELEVATIONS OF FLOATING BODIES
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF
      USE STREAMLINE, ONLY : ADD_PARTICLE,DEL_PARTICLE
!
      USE DECLARATIONS_SPECIAL
      IMPLICIT NONE
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)             :: NPOIN,NIT,NFLOT_MAX,LT,NPLAN
      INTEGER, INTENT(IN)             :: NELEM,NELMAX
      INTEGER, INTENT(IN)             :: IKLE(NELMAX,*)
      INTEGER, INTENT(INOUT)          :: NFLOT
      INTEGER, INTENT(INOUT)          :: TAGFLO(NFLOT_MAX)
      INTEGER, INTENT(INOUT)          :: ELTFLO(NFLOT_MAX)
      INTEGER, INTENT(INOUT)          :: ETAFLO(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(IN)    :: X(NPOIN),Y(NPOIN),Z(NPOIN),AT
      DOUBLE PRECISION, INTENT(INOUT) :: XFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: YFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: ZFLOT(NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: SHPFLO(3,NFLOT_MAX)
      DOUBLE PRECISION, INTENT(INOUT) :: SHZFLO(NFLOT_MAX)
      TYPE(BIEF_MESH) , INTENT(INOUT) :: MESH3D
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      IF(LT.LE.600.AND.(10*(LT/10).EQ.LT.OR.LT.EQ.1)) THEN
        CALL ADD_PARTICLE(-220.D0,400.D0+LT/3.D0,259.D0+LT/100.D0,
     &                    LT,NFLOT,
     &                    NFLOT_MAX,XFLOT,YFLOT,ZFLOT,TAGFLO,
     &                    SHPFLO,SHZFLO,ELTFLO,ETAFLO,MESH3D,NPLAN,
     &                    0.D0,0.D0,0.D0,0.D0,0,0)
      ENDIF
!
!     IF(LT.EQ.600) THEN
!        CALL DEL_PARTICLE(20,NFLOT,NFLOT_MAX,
!    &                     XFLOT,YFLOT,ZFLOT,TAGFLO,SHPFLO,SHZFLO,
!    &                     ELTFLO,ETAFLO,MESH%TYPELM)
!     ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END
