!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!brief module handling all the instance function
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
!history R-S MOURADI (EDF R&D, LNHE)
!+       17/03/2016
!+       V7P1
!+       Creation of the file
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      MODULE API_INSTANCE_SIS
!
      USE API_HANDLE_ERROR
      USE BIEF
      USE BIEF_DEF
      USE DECLARATIONS_SISYPHE
      USE INTERFACE_SISYPHE
      IMPLICIT NONE

      PRIVATE

      PUBLIC :: CREATE_INSTANCE_SIS
      PUBLIC :: DELETE_INSTANCE_SIS
      PUBLIC :: CHECK_INSTANCE_SIS
      PUBLIC :: GET_INSTANCE_ERROR_SIS
      PUBLIC :: INSTANCE_SIS
      PUBLIC :: INSTANCE_LIST_SIS
!
      ! TYPE FOR API COUPLED CALL
      TYPE TELEMAC_CPL
        INTEGER, POINTER :: LOOPCOUNT, GRAPHCOUNT, LISTCOUNT
        INTEGER, POINTER :: NIT
        TYPE(BIEF_OBJ), POINTER :: U, V
        TYPE(BIEF_OBJ), POINTER :: H, HN, HPROP
        TYPE(BIEF_OBJ), POINTER :: ZF, UETCAR, CF, KS
        TYPE(API_CPL) :: SIS_CPL
        CHARACTER(LEN=24) :: CODE
        INTEGER, POINTER :: PERICOU
        TYPE(BIEF_OBJ), POINTER :: U3D, V3D
        DOUBLE PRECISION :: T
        DOUBLE PRECISION :: DT
        TYPE(BIEF_OBJ), POINTER :: VISC
        TYPE(BIEF_OBJ), POINTER :: FLBOR,DM1
        INTEGER :: SOLSYS
        TYPE(BIEF_OBJ), POINTER :: UCONV, VCONV, ZCONV
        TYPE(BIEF_OBJ), POINTER :: THETAW, HW, TW, UW
      END TYPE TELEMAC_CPL

      TYPE INSTANCE_SIS
        ! RUN POSITION
        INTEGER MYPOSITION
        ! ERROR MESSAGE
        CHARACTER(LEN=200) :: ERROR_MESSAGE
        ! LIST OF ALL THE VARIABLE FOR MODEL
c$$$        TYPE(BIEF_OBJ), POINTER :: H !TELEMAC
c$$$        TYPE(BIEF_OBJ), POINTER :: U !TELEMAC
c$$$        TYPE(BIEF_OBJ), POINTER :: V !TELEMAC
        TYPE(BIEF_OBJ), POINTER :: Q !FLOW RATE
        TYPE(BIEF_OBJ), POINTER :: E !EVOLUTION
        TYPE(BIEF_OBJ), POINTER :: TOB !SHEAR STRESS
        TYPE(BIEF_OBJ), POINTER :: Z !FREE SURFACE ELEVATION
        TYPE(BIEF_OBJ), POINTER :: ZF !BOTTOM ELEVATION
        TYPE(BIEF_OBJ), POINTER :: ZF_C !EVOLUTION DUE TO BEDLOAD
        ! LIST OF ALL THE IMPOSED VALUES AT THE BOUNDARY
c$$$        TYPE(BIEF_OBJ), POINTER :: HBOR !TELEMAC
c$$$        TYPE(BIEF_OBJ), POINTER :: UBOR !TELEMAC
c$$$        TYPE(BIEF_OBJ), POINTER :: VBOR !TELEMAC
        TYPE(BIEF_OBJ), POINTER :: QBOR !IMPOSED SOLID TRANSPORT
        TYPE(BIEF_OBJ), POINTER :: EBOR !IMPOSED BED EVOLUTION
        TYPE(BIEF_OBJ), POINTER :: FLBOR !IMPOSED BED ELEVATION

        TYPE(BIEF_OBJ), POINTER :: CHESTR !BOTTOM FRICTION COEFF
        TYPE(BIEF_OBJ), POINTER :: FLBOR_SIS !FLUX AT THE BOUNDARIES
c$$$        DOUBLE PRECISION, POINTER :: COTE(:)
c$$$        DOUBLE PRECISION, POINTER :: DEBIT(:)
!
        TYPE(BIEF_MESH), POINTER :: MESH
!
        TYPE(BIEF_OBJ), POINTER :: LIHBOR
        TYPE(BIEF_OBJ), POINTER :: CLU !MODIFIED LIUBOR
        TYPE(BIEF_OBJ), POINTER :: CLV !MODIFIED LIVBOR
        TYPE(BIEF_OBJ), POINTER :: LIQBOR
        TYPE(BIEF_OBJ), POINTER :: LIEBOR
        TYPE(BIEF_OBJ), POINTER :: NUMLIQ !LIQUID BOUNDARY NUMBERING
!
        INTEGER, POINTER :: NIT !NUMBER OF ITERATIONS
        INTEGER,        POINTER :: LT !CURRENT ITERATION
        DOUBLE PRECISION, POINTER :: DT !TIME STEP
!
        !FILES
        TYPE(BIEF_FILE), POINTER :: SIS_FILES(:)
        INTEGER :: MAXLU_SIS !MAX RANK OF LOGIAL UNITS
c$$$        INTEGER :: MAXKEY
        INTEGER, POINTER :: SISRES
        INTEGER, POINTER :: SISGEO
        INTEGER, POINTER :: SISCLI

        !OTHER SIMULATION PARAMETES
c$$$  INTEGER, POINTER :: DEBUG


        !PARAMETERS OF INTEREST FOR UNCERTAINTY SUDY
        DOUBLE PRECISION, POINTER :: D50(:) !MEAN SEDIMENT DIAMETER
        DOUBLE PRECISION, POINTER :: MPM !MEYER-PETER AND MULLER COEFFICIENT
        TYPE(BIEF_OBJ),   POINTER :: MPM_ARAY !MPM COEFFICIENT
        DOUBLE PRECISION, POINTER :: AC(:) !CRITICAL SHIELDS PARAMETER
        DOUBLE PRECISION, POINTER :: XKV !COEFFICIENT FUNCTION OF THE POROSITY
        DOUBLE PRECISION, POINTER :: CSF_SABLE !1 - POROSITY
        DOUBLE PRECISION, POINTER :: KSPRATIO ! SKIN FRICTION / MEAN DIAMETER
        DOUBLE PRECISION, POINTER :: PHISED ! FRICTION ANGLE OF THE SEDIMENT
        DOUBLE PRECISION, POINTER :: BETA2 ! PARAMETER FOR DEVIATION
        DOUBLE PRECISION, POINTER :: ALPHA ! SECONDARY CURRENTS COEFFICIENT
!
        !VARIABLES FOR SISYPHE CALL, NECESSARY FOR THE COUPLING
        TYPE(TELEMAC_CPL) :: TEL

      END TYPE

!!!!!!!!!!!!!!!!!!!!!!!!!!!!MODULE BEGINS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      INTEGER, PARAMETER :: MAX_INSTANCES=10
      TYPE(INSTANCE_SIS), POINTER, SAVE :: INSTANCE_LIST_SIS(:)
      LOGICAL, ALLOCATABLE, SAVE :: USED_INSTANCE(:)
!
      CONTAINS
!
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !brief creates a sisysphe instance
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !
      !history R-S MOURADI (EDF R&D, LNHE)
      !+       17/03/2016
      !+       V7P1
      !+       Creation of the file
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !param id   [out]    id of the new instance
      !param ierr [out]    0 if subroutine successfull,
      !+                   error id otherwise
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE CREATE_INSTANCE_SIS(ID,IERR)
      ! initialise instance for sysiphe
        INTEGER, INTENT(OUT) :: ID
        INTEGER, INTENT(OUT) :: IERR
!
        INTEGER :: I
        ID = 0
        IERR = 0
        ! If first time creating an instance allocating the instance array
        IF(.NOT. ALLOCATED(USED_INSTANCE)) THEN
          ALLOCATE(USED_INSTANCE(MAX_INSTANCES),STAT=IERR)
          IF(IERR.NE.0) THEN
            ERR_MESS = 'ERROR WHILE ALLOCATING USED INSTANCE ARRAY'
            RETURN
          ENDIF
          USED_INSTANCE = .FALSE.
          ALLOCATE(INSTANCE_LIST_SIS(MAX_INSTANCES),STAT=IERR)
          IF(IERR.NE.0) THEN
            ERR_MESS = 'ERROR WHILE ALLOCATING INSTANCE ARRAY'
            RETURN
          ENDIF
        ENDIF
!
        ! look for the first instance available
        I = 1
        DO WHILE(USED_INSTANCE(I).AND.I.LE.MAX_INSTANCES)
          I = I + 1
        ENDDO
        ID = I
        USED_INSTANCE(ID) = .TRUE.
!
        ! if still equals 0 no available instance was found then we crash
        IF(ID.EQ.(MAX_INSTANCES+1))THEN
          IERR = MAX_INSTANCE_ERROR
          ERR_MESS = "MAX INSTANCE REACHED "
          RETURN
        ENDIF
!
        INSTANCE_LIST_SIS(ID)%MYPOSITION = NO_POSITION
c$$$        INSTANCE_LIST_SIS(ID)%H => H
c$$$        INSTANCE_LIST_SIS(ID)%U => U
c$$$        INSTANCE_LIST_SIS(ID)%V => V
        INSTANCE_LIST_SIS(ID)%Q => Q
        INSTANCE_LIST_SIS(ID)%E => E
        INSTANCE_LIST_SIS(ID)%TOB => TOB
        INSTANCE_LIST_SIS(ID)%Z => Z
        INSTANCE_LIST_SIS(ID)%ZF => ZF
        INSTANCE_LIST_SIS(ID)%ZF_C => ZF_C
c$$$        INSTANCE_LIST_SIS(ID)%HBOR => HBOR
c$$$        INSTANCE_LIST_SIS(ID)%UBOR => UBOR
c$$$        INSTANCE_LIST_SIS(ID)%VBOR => VBOR
        INSTANCE_LIST_SIS(ID)%QBOR => QBOR
        INSTANCE_LIST_SIS(ID)%EBOR => EBOR
        INSTANCE_LIST_SIS(ID)%FLBOR => FLBOR
        INSTANCE_LIST_SIS(ID)%CHESTR => CHESTR
        INSTANCE_LIST_SIS(ID)%FLBOR_SIS => FLBOR_SIS
        INSTANCE_LIST_SIS(ID)%MESH => MESH
        INSTANCE_LIST_SIS(ID)%LIHBOR => LIHBOR
        INSTANCE_LIST_SIS(ID)%CLU => CLU
        INSTANCE_LIST_SIS(ID)%CLV => CLV
        INSTANCE_LIST_SIS(ID)%LIQBOR => LIQBOR
        INSTANCE_LIST_SIS(ID)%LIEBOR => LIEBOR
        INSTANCE_LIST_SIS(ID)%NUMLIQ => NUMLIQ
c$$$  INSTANCE_LIST_SIS(ID)%NIT => NIT
        INSTANCE_LIST_SIS(ID)%NIT => NPAS
        INSTANCE_LIST_SIS(ID)%LT => LT
        INSTANCE_LIST_SIS(ID)%DT => DELT
        INSTANCE_LIST_SIS(ID)%SIS_FILES => SIS_FILES
        INSTANCE_LIST_SIS(ID)%MAXLU_SIS = MAXLU_SIS
c$$$        INSTANCE_LIST_SIS(ID)%MAXKEY = MAXKEY
        INSTANCE_LIST_SIS(ID)%SISRES => SISRES
        INSTANCE_LIST_SIS(ID)%SISGEO => SISGEO
        INSTANCE_LIST_SIS(ID)%SISCLI => SISCLI
c$$$        INSTANCE_LIST_SIS(ID)%DEBUG => DEBUG
        !Incertainty variables
        INSTANCE_LIST_SIS(ID)%D50 => FDM
        INSTANCE_LIST_SIS(ID)%MPM => MPM
        INSTANCE_LIST_SIS(ID)%MPM_ARAY => MPM_ARAY
        INSTANCE_LIST_SIS(ID)%AC => AC
        INSTANCE_LIST_SIS(ID)%XKV => XKV
        INSTANCE_LIST_SIS(ID)%CSF_SABLE => CSF_SABLE
        INSTANCE_LIST_SIS(ID)%KSPRATIO => KSPRATIO
        INSTANCE_LIST_SIS(ID)%PHISED => PHISED
        INSTANCE_LIST_SIS(ID)%BETA2 => BETA2
        INSTANCE_LIST_SIS(ID)%ALPHA => ALPHA

        ! INITIALISATIONS POUR UN CAS SANS COUPLAGE
        INSTANCE_LIST_SIS(ID)%TEL%LOOPCOUNT => LT
        INSTANCE_LIST_SIS(ID)%TEL%GRAPHCOUNT => LEOPR
        INSTANCE_LIST_SIS(ID)%TEL%LISTCOUNT => LISPR
        INSTANCE_LIST_SIS(ID)%TEL%NIT => NPAS
        INSTANCE_LIST_SIS(ID)%TEL%U => T1
        INSTANCE_LIST_SIS(ID)%TEL%V => T1
        INSTANCE_LIST_SIS(ID)%TEL%H => T1
        INSTANCE_LIST_SIS(ID)%TEL%HN => T1
        INSTANCE_LIST_SIS(ID)%TEL%HPROP => T1
        INSTANCE_LIST_SIS(ID)%TEL%ZF => T1
        INSTANCE_LIST_SIS(ID)%TEL%UETCAR => T1
        INSTANCE_LIST_SIS(ID)%TEL%CF => T1
        INSTANCE_LIST_SIS(ID)%TEL%KS => T1
        INSTANCE_LIST_SIS(ID)%TEL%SIS_CPL%NSIS_CFD = 1
        INSTANCE_LIST_SIS(ID)%TEL%SIS_CPL%SISYPHE_CFD = .FALSE.
        INSTANCE_LIST_SIS(ID)%TEL%SIS_CPL%CONSTFLOW = .FALSE.
        INSTANCE_LIST_SIS(ID)%TEL%SIS_CPL%CHARR = .FALSE.
        INSTANCE_LIST_SIS(ID)%TEL%SIS_CPL%SUSP = .FALSE.
        INSTANCE_LIST_SIS(ID)%TEL%CODE = 'SISYPHE                 '
        INSTANCE_LIST_SIS(ID)%TEL%PERICOU => PERCOU
        INSTANCE_LIST_SIS(ID)%TEL%U3D => T1
        INSTANCE_LIST_SIS(ID)%TEL%V3D => T1
        INSTANCE_LIST_SIS(ID)%TEL%T = 0.D0
        INSTANCE_LIST_SIS(ID)%TEL%VISC => T1
        INSTANCE_LIST_SIS(ID)%TEL%DT = DELT
        INSTANCE_LIST_SIS(ID)%TEL%FLBOR => T1
        INSTANCE_LIST_SIS(ID)%TEL%SOLSYS = 1  !Not existant in sisyphe
        INSTANCE_LIST_SIS(ID)%TEL%DM1 => T1
        INSTANCE_LIST_SIS(ID)%TEL%UCONV => T1
        INSTANCE_LIST_SIS(ID)%TEL%VCONV => T1
        INSTANCE_LIST_SIS(ID)%TEL%ZCONV => T1
        INSTANCE_LIST_SIS(ID)%TEL%THETAW => T1
        INSTANCE_LIST_SIS(ID)%TEL%HW => T1
        INSTANCE_LIST_SIS(ID)%TEL%TW => T1
        INSTANCE_LIST_SIS(ID)%TEL%UW => T1

        !TEMPORAIRES
        END SUBROUTINE CREATE_INSTANCE_SIS
!
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !brief deletes a sisyphe instance
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !
      !history R-S MOURADI (edf r&d, lnhe)
      !+       17/03/2016
      !+       V7P1
      !+       creation of the file
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !param id    [in]    id of the instance
      !param ierr [out]    0 if subroutine successfull,
      !+                   error id otherwise
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE DELETE_INSTANCE_SIS(ID,IERR)
        INTEGER, INTENT(IN) :: ID
        INTEGER, INTENT(OUT) :: IERR
!
        IERR = 0
        !
        CALL CHECK_INSTANCE_SIS(ID,IERR)
        IF(IERR.NE.0) RETURN
        USED_INSTANCE(ID) = .FALSE.
      END SUBROUTINE DELETE_INSTANCE_SIS

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !brief check if the id is following convention
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !
      !history R-S MOURADI (edf r&d, lnhe)
      !+       17/03/2016
      !+       V7P1
      !+       creation of the file
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !param id    [in]    id of the instance
      !param ierr [out]    0 if subroutine successfull,
      !+                   error id otherwise
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE CHECK_INSTANCE_SIS(ID,IERR)
        INTEGER, INTENT(IN) :: ID
        INTEGER, INTENT(OUT) :: IERR
!
        IERR = 0
        IF(ID.LE.0 .OR. ID.GT.MAX_INSTANCES) THEN
          IERR = INVALID_INSTANCE_NUM_ERROR
          ERR_MESS = 'INVALID INSTANCE NUMBER'
          RETURN
        ENDIF
        IF(.NOT.USED_INSTANCE(ID)) THEN
          IERR = UNUSED_INSTANCE_ERROR
          ERR_MESS = 'INSTANCE NUMBER WAS NOT CREATED'
          RETURN
        ENDIF
        END SUBROUTINE CHECK_INSTANCE_SIS

!
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !brief Returns the error message of the instance
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !
      !history R-S MOURADI (edf r&d, lnhe)
      !+       17/03/2016
      !+       V7P1
      !+       creation of the file
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !param id    [in]    id of the instance
      !param mess  [out]   The erro message
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE GET_INSTANCE_ERROR_SIS(ID,MESS)
        INTEGER, INTENT(IN) :: ID
        CHARACTER(LEN=200), INTENT(OUT) :: MESS
!
        MESS = INSTANCE_LIST_SIS(ID)%ERROR_MESSAGE
!
      END SUBROUTINE GET_INSTANCE_ERROR_SIS
      END MODULE API_INSTANCE_SIS

