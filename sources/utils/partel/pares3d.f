!                       ******************
                        SUBROUTINE PARES3D
!                       ******************

     *(NAMEINP,LI,IO_PARTEL_PAR)
!
!**********************************************************************
!  12/11/2009 CHRISTOPHE DENIS SINETICS/I23 
!  NEW VERSION TO DECREASE THE PARES3D COMPUTING TIME BY IMPROVING 
!
!   - THE TETRA-TRIA CONNECTION
!   - THE POSTPROCESSING 
!
! COMMENTS ON THIS NEW VERSION ->  CD 
! *********************************************************************
!***********************************************************************
! PARTEL VERSION 5.6        08/06/06   O.BOITEAU/F.DECUNG(SINETICS/LNHE)
! PARTEL VERSION 5.8        02/07/07   F.DECUNG(LNHE)
! VERSION DE DEVELOPPEMENT POUR PRISE EN COMPTE PB DECOUPAGE
! F.DECUNG/O.BOITEAU (JANV 2008)
! COPYRIGHT 2006
!***********************************************************************
!
!    CONSTRUCTIONS DES FICHIERS POUR ALIMENTER LE FLOT DE DONNEES
!    PARALLELE LORS D'UN CALCUL ESTEL3D PARALLELE EN ECOULEMENT
! 
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .________________.____.______________________________________________.
! |      NOM       |MODE|                   ROLE                       |
! |________________|____|______________________________________________|
! |    NAMEINP     | -->| NOM DU FICHIER DE GEOMETRIE ESTEL3D
! |    LI          | -->| UNITE LOGIQUE D'ECRITURE POUR MONITORING 
! |________________|____|______________________________________________|
!  MODE: -->(DONNEE NON MODIFIEE),<--(RESULTAT),<-->(DONNEE MODIFIEE)
!
!-----------------------------------------------------------------------
!
! APPELE PAR :  PARTEL
!
! SOUS-PROGRAMME APPELE :
!        PARTEL_ALLOER, PARTEL_ALLOER2 (GESTION MSGS)
!        METIS_PARTMESHDUAL (FROM METIS LIBRARY)
!***********************************************************************
!
      IMPLICIT NONE
!     INTEGER, PARAMETER :: MAXNPROC = 1000  ! MAX PARTITION NUMBER [000..999]
      INTEGER, PARAMETER :: MAXNPROC = 100000 ! MAX PARTITION NUMBER [00000..99999]
      INTEGER, PARAMETER :: MAXLENHARD = 250 ! HARD MAX FILE NAME LENGTH
      INTEGER, PARAMETER :: MAXLENSOFT = 144 ! SOFT MAX FILE NAME LENGTH
!
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
! PARAMETRES D'APPEL DE LA ROUTINE
      CHARACTER(LEN=MAXLENHARD), INTENT(IN) :: NAMEINP
      INTEGER,                   INTENT(IN) :: LI
      LOGICAL,                   INTENT(IN) :: IO_PARTEL_PAR ! (True if partel.par is found...)
! VARIABLES LOCALES
      CHARACTER(LEN=MAXLENHARD) :: NAMELOG,NAMEINP2,NAMELOG2
      INTEGER :: NINP=10,NLOG=11,NINP2=12,NLOG2=13
      INTEGER :: NPARTS,I_S,I_SP,I,I_LEN,I_LENINP,IERR,J,K,COMPT,
     &           N,NUMTET,NUMTRI,NUMTRIG,I_LENLOG,L,NI,NF,NT,IBID,IDD,
     &           COMPT1,COMPT2,COMPT3,NBTRIIDD,M,COLOR1,
     &           COLOR2,PR1,PR2,NBTETJ,IDDNT,NIT,NFT,MT,
     &           NUMTRIB,NUMTETB,IBIDC,NBRETOUCHE
      LOGICAL :: IS,LINTER
      CHARACTER(LEN=300) :: TEXTERROR  ! TEXTE MSG D'ERREUR
      CHARACTER(LEN=8)   :: STR8       ! TEXTE MSG D'ERREUR
      CHARACTER(LEN=300) :: STR26      ! TEXTE MSG D'ERREUR
      CHARACTER(LEN=80)  :: TITRE      ! MESH TITLE IN THE FILE
      CHARACTER(LEN=2)   :: MOINS1     ! "-1"
      CHARACTER(LEN=4)   :: BLANC      ! WHITE SPACE

      ! ADDITION JP RENAUD 15/02/2007
      CHARACTER(LEN=200) :: LINE       ! ONE LINE, 200 CHARACTERS MAXADDCH
      INTEGER            :: POS        ! POSITION OF A CHARACTER IN THE LINE
      INTEGER            :: IOS        ! STATUS INTEGER
      ! END ADDITION JP RENAUD
      CHARACTER(LEN=72) :: THEFORMAT
      
      CHARACTER(LEN=80), ALLOCATABLE :: LOGFAMILY(:)  ! LOG INFORMATIONS
      INTEGER            :: NSEC       ! TYPE OF THE SECTION READ
      INTEGER, PARAMETER :: NSEC1=151  ! MESH TITLE SECTION ID 
      INTEGER, PARAMETER :: NSEC2=2411 ! NODES COORDINATES SECTION ID
      INTEGER, PARAMETER :: NSEC3=2412 ! CONNECTIVITY SECTION ID
      INTEGER, PARAMETER :: NSEC4=2435 ! POUR CLORE PROPREMENT LA LECTURE
                                       ! DU UNV DANS ESTEL3D      
      LOGICAL            :: READ_SEC1  ! FLAG FOR READING SECTION 1
      LOGICAL            :: READ_SEC2  ! FLAG FOR READING SECTION 2
      LOGICAL            :: READ_SEC3  ! FLAG FOR READING SECTION 3
      INTEGER            :: NELEMTOTAL ! TOTAL NUMBER OF UNV ELEMENTS
      INTEGER            :: NPOINT     ! TOTAL NUMBER OF NODES 
      INTEGER            :: NBFAMILY   ! TOTAL NUMBER OF FAMILY
      INTEGER            :: NELIN      ! TOTAL NUMBER OF INNER TRIANGLES
      INTEGER            :: SIZE_FLUX  !  TOTAL NUMBER OF INNER SURFACES
      INTEGER, DIMENSION(:), ALLOCATABLE :: VECTNB  ! VECTEUR AUX POUR NACHB
!
      DOUBLE PRECISION, ALLOCATABLE :: X1(:),Y1(:),Z1(:) ! COORD NODES
      INTEGER,          ALLOCATABLE :: NCOLOR(:) ! NODES' COLOUR
      INTEGER,          ALLOCATABLE :: ECOLOR(:) ! ELEMENTS' COLOUR
      INTEGER            :: ELEM       ! TYPE OF THE ELEMENT 
      INTEGER            :: IKLE1,IKLE2,IKLE3,IKLE4,IKLEB   ! NODES
      INTEGER, DIMENSION(:), ALLOCATABLE :: IKLESTET ! CONNECTIVITE EN
                   ! RENUMEROTATION GLOBAL DE LA BIEF POUR LES TETRAEDRES
      INTEGER, DIMENSION(:), ALLOCATABLE :: IKLESTRI ! CONNECTIVITE EN
                   ! RENUMEROTATION GLOBAL DE LA BIEF POUR LES TRIANGLES
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: IKLESTRIN ! CONNECTIVITE EN
                   ! RENUMEROTATION GLOBAL DE LA BIEF POUR LES TRIANGLES
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: IKLEIN ! COPIE AJUSTEE DE IKLESTRIN
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: TYPELEM ! TYPE D'ELT
      INTEGER            :: NBTET,NBTRI  ! NBRE DE TETRA, TRIANGLE BORD
      INTEGER, DIMENSION(:), ALLOCATABLE :: TETTRI, TETTRI2 ! JOINTURE
                                               !  TETRA/TRIANGLE DE BORD
      INTEGER, DIMENSION(:), ALLOCATABLE :: EPART ! NUMERO DE PARTITION
                                                  ! PAR ELEMENT
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPART ! NUMERO DE PARTITION
                                                  ! PAR NOEUDS
      INTEGER, DIMENSION(:), ALLOCATABLE :: CONVTRI,CONVTET ! CONVERTISSEUR 
         ! NUMERO LOCAL TRIA/TETRA NUMERO GLOBAL; INVERSE DE TYPELEM(:,2)
      INTEGER            ::  PARSEC  ! RUNTIME
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPOINTSD, NELEMSD ! NBRE
                            ! DE POINTS ET D'ELEMENTS PAR SOUS-DOMAINE
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPOINTISD  ! NBRE
                            ! DE POINTS D'INTERFACE PAR SOUS-DOMAINE
                   ! VECTEURS LIES AUX CONNECTIVITEES NODALES INVERSES
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODES1,NODES2,NODES3,NODES4
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODES1T,NODES2T,NODES3T
      INTEGER, DIMENSION(:), ALLOCATABLE :: TRIUNV ! BUFFER POUR ECRIRE
                 ! DANS LES .UNV, D'ABORD LES TETRAS PUIS LES TRIA
! POUR TRAITEMENT DES DIRICHLETS CONFONDUS AVEC L'INTERFACE
      INTEGER  :: NBCOLOR ! NBRE DE COULEUR DE MAILLES EXTERNES
      INTEGER, DIMENSION(:), ALLOCATABLE :: PRIORITY
      INTEGER, DIMENSION(:), ALLOCATABLE :: NCOLOR2
! POUR TRAITEMENT DES DIRICHLETS SUR LES NOEUDS DE TETRA
      LOGICAL, DIMENSION(:,:), ALLOCATABLE :: TETCOLOR
      LOGICAL, DIMENSION(:), ALLOCATABLE :: DEJA_TROUVE
! INDISPENSABLE POUR PARALLELISME TELEMAC
      INTEGER, DIMENSION(:), ALLOCATABLE :: KNOLG 
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: NACHB
      LOGICAL :: NACHBLOG
!     MAXIMUM GEOMETRICAL MULTIPLICITY OF A NODE (VARIABLE AUSSI
!     PRESENTE DANS LA BIEF, NE PAS CHANGER L'UNE SANS L'AUTRE)
      INTEGER, PARAMETER :: NBMAXNSHARE =  10
! CETTE VARIABLE EST LIEE A LA PRECEDENTE ET DIMENSIONNE DIFFERENTS
! VECTEURS
! NOTE SIZE OF NACHB WILL BE HERE 2 MORE THAN IN BIEF, BUT THE EXTRA 2 ARE
! LOCAL WORK ARRAYS
      INTEGER :: NBSDOMVOIS = NBMAXNSHARE + 2
!
      INTEGER, PARAMETER :: MAX_SIZE_FLUX = 200
! NUMBER OF INNER SURFACE (SAME AS SIZE_FLUX AT THE END)
      INTEGER, DIMENSION(MAX_SIZE_FLUX) :: SIZE_FLUXIN
! VECTEUR POUR PROFILING
      INTEGER  TEMPS_SC(20)
!
!F.D
      INTEGER, DIMENSION(:  ), ALLOCATABLE  :: TEMPO,GLOB_2_LOC
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: IKLES,IKLE,IFABOR
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: NULONE,IKLBOR
      INTEGER                               :: N1,N2,N3,IKL
      INTEGER                               :: NSOLS,NSOLS_OLD
      INTEGER                               :: IELEM,IPTFR,IELEB
      LOGICAL, DIMENSION(:), ALLOCATABLE    :: FACE_CHECK
      INTEGER, PARAMETER                    :: NCOL = 256
      INTEGER, DIMENSION(NCOL  )            :: COLOR_PRIO
      INTEGER                               :: PRIO_NEW,NPTFR
      INTEGER, DIMENSION(:), ALLOCATABLE    :: NBOR2,NBOR
      INTEGER, DIMENSION(:), ALLOCATABLE    :: NELBOR,LIHBOR
!D******************************************************    ADDED BY CHRISTOPHE DENIS
      INTEGER, DIMENSION(:), ALLOCATABLE     :: NELEM_P
!     SIZE NPARTS, NELEM_P(I) IS THE NUMBER OF FINITE ELEMENTS ASSIGNED TO SUBDOMAIN I
      INTEGER, DIMENSION(:), ALLOCATABLE     :: NPOIN_P
!     SIZE NPARTS, NPOIN_P(I) IS THE NUMBER OF NODES  ASSIGNED TO SUBDOMAIN I
      INTEGER :: NODE
!     ONE NODE ...
      INTEGER ::  POS_NODE 
!     POSITION OF ONE ONE NODE
      INTEGER :: MAX_NELEM_P
!     MAXIMUM NUMBER OF FINITE ELEMENTS ASSIGNED AMONG SUBDOMAINS
      INTEGER :: MAX_NPOIN_P
!     MAXIMUM NUMBER OF NODES ASSIGNED AMONG SUBDOMAINS
      INTEGER :: MAX_TRIA
!     MAXIMUM NUMBER OF TRIANGLE SHARING A NODE 
      INTEGER :: THE_TRI
!     ONE TRIANGLE 
      INTEGER :: JJ
!     INDEX COUNTER
      INTEGER, DIMENSION(:), ALLOCATABLE :: NUMBER_TRIA
!     MAXIMUM NUMBER OF TRIANGLE SHARING A SAME NODE  
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: ELEGL
!     SIZE MAX_NELEM_P,NPARTS, ELEGL(J,I) IS THE GLOBAL NUMBER OF LOCAL FINITE ELEMENT J IN SUBDOMAIN I
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: NODEGL
!     SIZE MAX_NPOIN_P,NPARTS, NODEGL(J,I) IS THE GLOBAL NUMBER OF LOCAL NODE J IN SUBDOMAIN I
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODELG
!     SIZE NPOINT, NODELG(I)=J, J IS THE LOCAL NUMBER OF GLOBAL NODE I ON ONE SUBDOMAIN
      INTEGER,  DIMENSION(:,:), ALLOCATABLE :: TRI_REF
!     SIZE NPOINT*MAX_TRIA
!     EXTENS
      CHARACTER(len=11) :: EXTENS
      EXTERNAL EXTENS
!D********************************************************     
      INTEGER SOMFAC(3,4)
      DATA SOMFAC / 1,2,3 , 4,1,2 , 2,3,4 , 3,4,1  /
!
!-------------
! 1. PREAMBULE
!-------------
!
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(1),COUNT_RATE=PARSEC)
      ALLOCATE (VECTNB(NBSDOMVOIS-3))
      WRITE(LU,*)' '
      WRITE(LU,*)'+-------------------------------------------------+'
      WRITE(LU,*)'  PARTEL: TELEMAC ESTEL3D PARTITIONER'
      WRITE(LU,*)'+-------------------------------------------------+'
      WRITE(LU,*)' READING UNV AND LOG FILES'
!     NAMES OF THE INPUT FILES:
!
!     Geometry file
      IF (NAMEINP.EQ.' ') THEN
        GOTO 149 
      ELSE
        WRITE(LU,89)NAMEINP
      ENDIF
      INQUIRE (FILE=NAMEINP,EXIST=IS)
      IF (.NOT.IS) GOTO 140
!     
!     Complementary file
      DO
        IF( IO_PARTEL_PAR ) THEN               
           READ(72,*) NAMELOG         
        ELSE                          
           WRITE(LU, ADVANCE='NO', FMT=
     &           '(/,'' BOUNDARY CONDITIONS FILE NAME : '')')
           READ(LI,'(A)') NAMELOG
        ENDIF                         
        IF (NAMELOG.EQ.' ') THEN
          WRITE (LU,'('' NO FILENAME'')') 
        ELSE
          WRITE(LU,*) 'INPUT: ',NAMELOG
          EXIT
        END IF
      END DO
      INQUIRE(FILE=NAMELOG,EXIST=IS)
      IF (.NOT.IS) GOTO 141   
!
!     Number of sub-domains asked
      DO 
        IF( IO_PARTEL_PAR ) THEN                      !###> SEB@HRW
           READ(72,*) NPARTS                  !###> SEB@HRW
        ELSE                                  !###> SEB@HRW
           WRITE(LU, ADVANCE='NO',FMT=
     &    '(/,'' NUMBER OF PARTITIONS <NPARTS> [2 -'',I6,'']: '')') 
     &        MAXNPROC
           READ(LI,*) NPARTS
        ENDIF                                 !###> SEB@HRW
        IF ( (NPARTS > MAXNPROC) .OR. (NPARTS < 2) ) THEN
          WRITE(LU,
     &    '('' NUMBER OF PARTITIONS MUST BE IN [2 -'',I6,'']'')') 
     &      MAXNPROC
        ELSE
          WRITE(LU,'('' SUB DOMAINS: '',I4)') NPARTS
          EXIT
        END IF 
      END DO
!
      WRITE(LU,FMT='(/,'' PARTITIONING OPTIONS: '')')
!      WRITE(LU,*) '  1: DUAL  GRAPH', 
!     & ' (EACH ELEMENT OF THE MESH BECOMES A VERTEX OF THE GRAPH)'
!      WRITE(LU,*) '  2: NODAL GRAPH', 
!     & ' (EACH NODE OF THE MESH BECOMES A VERTEX OF THE GRAPH)'
      
! FIND THE INPUT FILES CORE NAME LENGTH
      I_S  = LEN(NAMEINP)
      I_SP = I_S + 1
      DO I=1,I_S
        IF (NAMEINP(I_SP-I:I_SP-I) .NE. ' ') EXIT
      ENDDO
      I_LEN=I_SP - I
      I_LENINP = I_LEN
      IF (I_LENINP > MAXLENSOFT) GOTO 144
!
      I_S  = LEN(NAMELOG)
      I_SP = I_S + 1
      DO I=1,I_S
        IF (NAMELOG(I_SP-I:I_SP-I) .NE. ' ') EXIT
      ENDDO
      I_LEN=I_SP - I
      I_LENLOG = I_LEN
      IF (I_LENLOG > MAXLENSOFT) GOTO 145
!
      OPEN(NINP,FILE=NAMEINP,STATUS='OLD',FORM='FORMATTED',ERR=131)
      REWIND(NINP)
      OPEN(NLOG,FILE=NAMELOG,STATUS='OLD',FORM='FORMATTED',ERR=130)
      REWIND(NLOG)
   
!----------------------------------------------------------------------
! 2A. LECTURE DU FICHIER .LOG
!---------------
! The first line contains the number of nodes after a text descriptor.
! We read a line, locate the colon ':' to then read the number.
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
         WRITE(LU, *) 'Error reading the mesh complementary file.'
         CALL PLANTE(1)
      endif
      POS =INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:),FMT=*, IOSTAT=IOS) NPOINT
      IF (IOS .NE. 0) THEN
         WRITE(LU,*) 'FORMAT ERROR READING THE MESH COMPLEMENTARY FILE.'
         CALL PLANTE(1)
      ENDIF

! The second line contains the number of elements after a text descriptor.
! We read a line, locate the colon ':' and then read the number.
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
         WRITE(LU,*)'ERROR READING THE MESH COMPLEMENTARY FILE.'
         CALL PLANTE(1)
      ENDIF
      POS =INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:),FMT=*, IOSTAT=IOS) NELEMTOTAL
      IF (IOS .NE. 0) THEN
         WRITE(LU,*)'FORMAT ERROR READING THE MESH COMPLEMENTARY FILE.'
         CALL PLANTE(1)
      ENDIF    
!     
!     The third line contains the number of families after a text descripto.
!     We read a line, locate the colon ':' and then read the number.
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
         WRITE(LU,*)'ERROR READING THE MESH COMPLEMENTARY FILE.'
         CALL PLANTE(1)
      ENDIF
      POS =INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:),FMT=*, IOSTAT=IOS) NBFAMILY
      IF (IOS .NE. 0) THEN
         WRITE(LU,*)'FORMAT ERROR READING THE MESH COMPLEMENTARY FILE.'
         CALL PLANTE(1)
      ENDIF

      NBFAMILY=NBFAMILY+1       ! POUR TITRE DU BLOC
      ALLOCATE(LOGFAMILY(NBFAMILY),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' LOGFAMILY')
      DO I=1,NBFAMILY
         READ(NLOG,50,ERR=111,END=120)LOGFAMILY(I)
      ENDDO
      NBCOLOR=0
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
         !         '!----------------------------------!'
         WRITE(LU,*)'! PROBLEM WITH THE NUMBER OF COLOR !'
         CALL PLANTE(-1)
      ENDIF
      POS = INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:), FMT=*, IOSTAT=IOS) NBCOLOR
      IF (IOS .NE. 0) THEN
         !         '!-------------------------------!'
         WRITE(LU,*)'! PROBLEM WITH THE NUMBER COLOR !'
      ENDIF

      ALLOCATE(PRIORITY(NBCOLOR),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' PRIORITY')
      WRITE(LU,92) NPOINT
      WRITE(LU,93) NELEMTOTAL
      WRITE(LU,94) NBCOLOR
      IF (NBCOLOR.EQ.0) THEN
        WRITE(LU,*) 'VOUS AVEZ OUBLIE DE REMPLIR LE FICHIER LOG...'
        CALL PLANTE(-1)
        STOP
      ENDIF

      ! MODIFICATION JP RENAUD 15/02/2007
      ! SOME TEXT HAS BEEN ADDED BEFORE THE LIOST OF PRIORITIES.
      ! READ A 200 CHARACTER LINE, FIND THE ':' AND THEN
      ! READ THE VALUES AFTER THE ':'
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
        !         '!------------------------------------------!'
        WRITE(LU,*)'! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
        CALL PLANTE(-1)
      ENDIF
      POS = INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:), FMT=*, IOSTAT=IOS) (PRIORITY(J),J=1,NBCOLOR)
      IF (IOS .NE. 0) THEN
        !         '!------------------------------------------!'
        WRITE(LU,*)'! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
        CALL PLANTE(-1)
      ENDIF
      ! END MODIFICATION JP RENAUD
      WRITE(LU,*) (PRIORITY(J),J=1,NBCOLOR)
      CLOSE(NLOG)
!
! 2B. ALLOCATIONS MEMOIRES ASSOCIEES
!--------------- 

!D    ****************************** ALLOCATION MEMORY ADDED BY CD
      ALLOCATE(NELEM_P(NPARTS),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'NELEM_P')
      ALLOCATE(NPOIN_P(NPARTS),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'NPOIN_P')
      ALLOCATE(NODELG(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'NODELG')
!D    *******************************      
      
      ALLOCATE(X1(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' X1')
      ALLOCATE(Y1(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' Y1')
      ALLOCATE(Z1(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' Z1')
      ALLOCATE(NCOLOR(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NCOLOR')
      ALLOCATE(NCOLOR2(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NCOLOR2')
      ALLOCATE(ECOLOR(NELEMTOTAL),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' ECOLOR')
      ALLOCATE(IKLESTET(4*NELEMTOTAL),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLESTET')
      ALLOCATE(IKLESTRI(3*NELEMTOTAL),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLESTRI')
      ALLOCATE(IKLESTRIN(NELEMTOTAL,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLESTRIN')
      ALLOCATE(TYPELEM(NELEMTOTAL,2),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TYPELEM')
      ALLOCATE(CONVTRI(NELEMTOTAL),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' CONVTRI')
      ALLOCATE(CONVTET(NELEMTOTAL),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' CONVTET')
      ALLOCATE(NPOINTSD(NPARTS),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NPOINTSD')
      ALLOCATE(NELEMSD(NPARTS),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NELEMSD')
      ALLOCATE(NPOINTISD(NPARTS),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NPOINTISD')

!F.D
      ALLOCATE(NBOR2(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NBOR2')
      ALLOCATE(TEMPO(2*NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TEMPO')
      ALLOCATE(FACE_CHECK(NBFAMILY),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' FACE_CHECK')      
      ALLOCATE(GLOB_2_LOC(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' GLOB_2_LOC')
      ALLOCATE(IKLES(NELEMTOTAL,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLES')


      READ_SEC1 = .TRUE.
      READ_SEC2 = .TRUE.
      READ_SEC3 = .TRUE.

      DO WHILE ( READ_SEC1 .OR. READ_SEC2 .OR. READ_SEC3 )

          MOINS1 = '  '
          BLANC  = '1111'
          DO WHILE (MOINS1/='-1' .OR. BLANC/='    ')
              READ(NINP,2000, ERR=1100, END=1200) BLANC, MOINS1
          END DO

 2000     FORMAT(A4,A2)

          NSEC = -1

          DO WHILE (NSEC == -1)
              READ(NINP,*, ERR=1100, END=1200) NSEC
          END DO

 2100     FORMAT(I10)

          SELECT CASE (NSEC)

          CASE ( NSEC1 )

              READ_SEC1 = .FALSE.

              READ(NINP,25,ERR=1100, END=1200) TITRE

 25           FORMAT(A80)

          CASE ( NSEC2 )

              READ_SEC2 = .FALSE.
              NCOLOR(:) = -1
              TEMPO(:)  =  0

              DO IELEM = 1, NPOINT
                 READ(NINP,*,ERR=1100,END=1200) N, N1, N2, NCOLOR(IELEM)
          READ(NINP,*,ERR=1100,END=1200) X1(IELEM), Y1(IELEM), Z1(IELEM)
                 TEMPO(N) = IELEM
              ENDDO

          CASE (NSEC3 )

             READ_SEC3 = .FALSE.
                         
             NBTET         = 0  ! NUMBER OF TETRA ELEMENTS TO 0
             NBTRI         = 0  ! NUMBER OF BORDER ELEMENTS TO 0
             NPTFR         = 0  ! NUMBER OF BORDER NODES TO 0.
             NELIN         = 0  ! NUMBER OF INNER SURFACES TO 0.
             SIZE_FLUX     = 0  ! NUMBER OF USER SURFACES TO 0.
             NBOR2(:)      = 0  ! LOCAL TO GLOBAL NUMBERING
             GLOB_2_LOC(:) = 0  ! GLOBAL TO LOCAL NUMBERING

!OB'S STUFF
             ECOLOR(:)    = -1
             IKLESTET(:)  = -1
             IKLESTRI(:)  = -1
             TYPELEM(:,:) = -1
             CONVTRI(:)   = -1
             CONVTET(:)   = -1
!
             IKLESTRIN(:,:) = -1
                       
             FACE_CHECK(:) = .FALSE.
             !
             COLOR_PRIO(:)  = 0
             SIZE_FLUXIN(:) = 0
             !
             DO K = 1, NBCOLOR
                COLOR_PRIO(PRIORITY(K)) = K
             END DO

             DO IELEM = 1, NELEMTOTAL

            READ(NINP,*,ERR=1100,END=1200) NSEC,ELEM,N1,N2,NSOLS,N3
            
                IF (NSEC == -1) EXIT

                SELECT CASE ( ELEM )

                CASE ( 111 )

                   NBTET        = NBTET + 1

                   ECOLOR(IELEM) = NSOLS

               READ(NINP,*, ERR=1100, END=1200) IKLE1,IKLE2,IKLE3,IKLE4

                   IKLES(IELEM, 1) = TEMPO(IKLE1)
                   IKLES(IELEM, 2) = TEMPO(IKLE2)
                   IKLES(IELEM, 3) = TEMPO(IKLE3)
                   IKLES(IELEM, 4) = TEMPO(IKLE4)

!OB'S STUFF
                   N=4*(NBTET-1)+1                       
                   IKLESTET(N)=IKLE1    ! VECTEUR DE CONNECTIVITE
                   IKLESTET(N+1)=IKLE2
                   IKLESTET(N+2)=IKLE3
                   IKLESTET(N+3)=IKLE4
                   TYPELEM(IELEM,1)=ELEM    ! POUR TYPER LES ELTS
                   TYPELEM(IELEM,2)=NBTET   ! POUR CONVERSION NUM ELT> NUM TETRA
                   CONVTET(NBTET)=IELEM     ! L'INVERSE
                   
                CASE ( 91 )
             
                   IF (NSOLS.GT.0.AND.NSOLS.LT.100) THEN

                      IF ( NSOLS > NCOL ) THEN
                         WRITE(LU,*) 'COLOR ID POUR SURFACES EXTERNES ',
     &                        ' TROP GRAND. LA LIMITE EST : ',NCOL
                      END IF

                      PRIO_NEW = COLOR_PRIO(NSOLS)

                      IF ( PRIO_NEW .EQ. 0 ) THEN
                         WRITE(LU,*) ' NUMERO DE FACE NON DECLARE',
     &                        'DANS LE TABLEAU UTILISATEUR LOGFAMILY ',
     &                        'VOIR LE FICHIER DES PARAMETRES '
                         CALL PLANTE(1)
                      END IF
                     
                      FACE_CHECK(PRIO_NEW) = .TRUE.

                      NBTRI = NBTRI + 1

                      ECOLOR(IELEM) = NSOLS

                     READ(NINP,*, ERR=1100, END=1200) IKLE1, IKLE2,IKLE3
                     !
                     PRIO_NEW = SIZE_FLUXIN(NSOLS)
                     !
                     IF(PRIO_NEW.EQ.0) THEN 
                        SIZE_FLUX = SIZE_FLUX + 1
                        SIZE_FLUXIN(NSOLS) = 1
                     ENDIF

                      IKLES(IELEM, 1) = TEMPO(IKLE1)
                      IKLES(IELEM, 2) = TEMPO(IKLE2)
                      IKLES(IELEM, 3) = TEMPO(IKLE3)

!OB'S STUFF
                      N=3*(NBTRI-1)+1
                      IKLESTRI(N)=IKLE1
                      IKLESTRI(N+1)=IKLE2
                      IKLESTRI(N+2)=IKLE3
                      TYPELEM(IELEM,1)=ELEM    ! IDEM QUE POUR TETRA
                      TYPELEM(IELEM,2)=NBTRI
                      CONVTRI(NBTRI)=IELEM

                      DO J=1,3
                                               
                         IKL = IKLES(IELEM,J)
                      
                         IPTFR = GLOB_2_LOC(IKL)

                         IF ( IPTFR .EQ. 0 ) THEN
                            
                            NPTFR           = NPTFR+1
                            NBOR2(NPTFR)    = IKL
                            GLOB_2_LOC(IKL) = NPTFR        
                            IPTFR           = NPTFR

                         END IF
                         
                    ENDDO  ! LOOP OVER THE NODES OF THE ELEMENT

                 ELSE IF (NSOLS.GT.100) THEN
                    !
                    ! USER-DEFINED SURFACE FOR FLUXES COMPUTATION
                    !                      
                    ! NELIN IS THE COUNTER FOR THE INTERNAL ELEMENTS.
                    ! ACTUALLY, WE ARE READING THE NEXT INTERNAL ELEMENT.

                    ! NSOLS_OLD IS USED FOR SAVING USE OF A NEW VARIABLE
                    NSOLS_OLD = NSOLS
                    !
                    ! PRIO_NEW IS USED FOR SAVING USE OF A NEW VARIABLE
                    PRIO_NEW = SIZE_FLUXIN(NSOLS_OLD)
                    !
                    IF (PRIO_NEW.EQ.0) THEN
                       SIZE_FLUX = SIZE_FLUX + 1
                       SIZE_FLUXIN(NSOLS_OLD) = 1
                    ENDIF
                    !
                    NELIN = NELIN + 1
                    !
                    READ(NINP,*, ERR=1100, END=1200) IKLE1, IKLE2,IKLE3
                    !
                         IKLESTRIN(NELIN,1) = NSOLS
                         IKLESTRIN(NELIN,2) = TEMPO(IKLE1)
                         IKLESTRIN(NELIN,3) = TEMPO(IKLE2)
                         IKLESTRIN(NELIN,4) = TEMPO(IKLE3)
                    !
                 ELSE           ! THIS IS AN INNER SURFACE, JUST READ THE LINE.

                    READ(NINP,*, ERR=1100, END=1200) IKLE1, IKLE2,IKLE3
                    
                 END IF
                                  
              CASE DEFAULT      ! THIS IS AN UNKNOWN ELEMENT.
                 
                 WRITE(LU,*) 'ELEMENT INCONNU DANS LE MAILLAGE'
                 
              END SELECT        ! THE TYPE OF THE MESH ELEMENT
              
           END DO               ! LOOP OVER ELEMENTS TO READ.

           DO K=1,NBCOLOR
              IF ( .NOT. FACE_CHECK(K)) THEN
                 WRITE(LU,*) ' LA COULEUR DE FACE ',LOGFAMILY(K),
     &                ' N''APPARAIT PAS DANS LE MAILLAGE.'
              END IF
           END DO
           
!-----------------------------------------------------------------------

      END SELECT                ! TYPE OF THE SECTION
      
      END DO                    ! WHILE LOOP OVER SECTIONS TO READ

!------------------------------------------------------- FIN VERSION F.D

! CORRECTION DU NOMBRE D'ELEMENTS TOTAL CAR CELUI DANS LE .LOG EST
! COMPORTE DES ELEMENTS NON PRIS EN COMPTE DANS UNE ETUDE ESTEL
      NELEMTOTAL=NBTET+NBTRI

      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(2),COUNT_RATE=PARSEC)
      WRITE(LU,*)' TEMPS DE LECTURE FICHIERS LOG & UNV',
     &           (1.0*(TEMPS_SC(2)-TEMPS_SC(1)))/(1.0*PARSEC),' SECONDS'
!----------------------------------------------------------------------
! 3A. CONSTRUCTION DE TETTRI/TETTRI2: CORRESPONDANCE TETRA > TRIA
!---------------

      ALLOCATE(NELBOR(NBTRI),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NELBOR')
      ALLOCATE(NULONE(NBTRI,3),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NULONE')
      ALLOCATE(IKLBOR(NBTRI,3),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLBOR')
      ALLOCATE(IKLE(NBTET,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLE')
      ALLOCATE(IFABOR(NBTET,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IFABOR')
!
!------------------------------------------------------- DEBUT VERSION O. BOITEAU
! RECHERCHE DE LA CORRESPONDANCE TETRAEDRE <--> TRIANGLES DE BORDS
!      ALLOCATE(TETTRI(4*NBTET),STAT=IERR)
!      CALL CHECK_ALLOCATE(IERR,' TETTRI')
!      ALLOCATE(TETTRI2(NBTET),STAT=IERR)
!      CALL CHECK_ALLOCATE(IERR,' TETTRI2')
!      TETTRI(:)=-1
!      TETTRI2(:)=0
!      DO I=1,NBTRI
!        N=3*(I-1)+1
!        IKLE1=IKLESTRI(N)
!        IKLE2=IKLESTRI(N+1)
!        IKLE3=IKLESTRI(N+2)
!        DO J=1,NBTET
!          COMPT=0
!          DO K=1,4
!            IKLEB=IKLESTET(4*(J-1)+K)
!            IF (IKLEB.EQ.IKLE1) COMPT=COMPT+1
!            IF (IKLEB.EQ.IKLE2) COMPT=COMPT+10
!            IF (IKLEB.EQ.IKLE3) COMPT=COMPT+100 
!          ENDDO ! BOUCLE SUR LES NOEUDS DU TETRAEDRE J
!          IF (COMPT.EQ.111) THEN   ! TETRAEDRE J ASSOCIE AU TRIANGLE I
!            NI=TETTRI2(J)
!            IF (NI==4) THEN   ! TETRA LIE A PLUS DE 4 TRIA, EXIT             
!              GOTO 153
!            ELSE              ! PROCHAIN EMPLACEMENT DE LIBRE
!              M=4*(J-1)+NI+1  ! DANS TETTRI
!              TETTRI2(J)=NI+1
!              TETTRI(M)=I     ! EN NUMEROTATION LOCALE
!            ENDIF
!            EXIT
!          ENDIF
!          IF (J.EQ.NBTET) GOTO 143  ! ERREUR CAR TRIANGLE SOLITAIRE
!        ENDDO  ! SUR LA BOUCLE EN TETRAEDRES
!      ENDDO ! SUR LA BOUCLE EN TRIANGLES DE BORDS
!------------------------------------------------------- FIN VERSION O. BOITEAU

!------------------------------------------------------- DEBUT VERSION F.D
      ALLOCATE(TETTRI(4*NBTET),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TETTRI')
      ALLOCATE(TETTRI2(NBTET),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TETTRI2')
!
      TETTRI (:) =-1
      TETTRI2(:) =0
!      
      DO IELEM = 1, NBTET
         DO I = 1,4
            IKLE(IELEM,I ) = IKLES (IELEM, I)
         END DO
      END DO
!
      DEALLOCATE(IKLES)
!
      ALLOCATE(IKLEIN(NELIN,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' IKLEIN')
!
      DO IELEM = 1, NELIN
         DO I = 1,4
            IKLEIN(IELEM,I ) = IKLESTRIN (IELEM, I)
         END DO
      END DO
!      
      DEALLOCATE(IKLESTRIN)
!
      WRITE(LU,*) 'FIN DE LA COPIE DE LA CONNECTIVITE INITIALE'
!      
      ALLOCATE(NBOR(NPTFR),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NBOR')
!
      DO IELEM = 1, NPTFR
            NBOR(IELEM) = NBOR2(IELEM)
      END DO
!
      DEALLOCATE(NBOR2)
!
      WRITE(LU,*) 'PARTEL_VOISIN31'
!
      CALL VOISIN31 (IFABOR, NBTET, NBTET,31,
     &  IKLE,NBTET,NPOINT,NBOR,NPTFR,
     &  LIHBOR,2,0,IKLESTRI,NBTRI)
!
      WRITE(LU,*) 'FIN DE PARTEL_VOISIN31'
!      
      ALLOCATE(LIHBOR(NPTFR),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'LIHBOR')
!
      CALL ELEBD31( NELBOR, NULONE, IKLBOR,    
     &              IFABOR, NBOR, IKLE,         
     &              NBTET, NBTRI, NBTET, NPOINT, 
     &              NPTFR,31)
!
      DEALLOCATE(LIHBOR)
!
      WRITE(LU,*) 'FIN DE PARTEL_ELEBD31'
      ALLOCATE(NUMBER_TRIA(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'NUMBER_TRIA')
      NUMBER_TRIA = 0
!
      MAX_TRIA=0
      DO J = 1, NBTRI
         K = 3*(J-1)+1  
         IKLE1 = IKLESTRI(K)
         IKLE2 = IKLESTRI(K+1)
         IKLE3 = IKLESTRI(K+2)
         THE_TRI=IKLE1
         IF (IKLE2 < THE_TRI) THE_TRI=IKLE2 
         IF (IKLE3< THE_TRI)  THE_TRI=IKLE3
         NUMBER_TRIA(THE_TRI)=NUMBER_TRIA(THE_TRI)+1
      END DO
      MAX_TRIA=MAXVAL(NUMBER_TRIA)
!    
      DEALLOCATE(NUMBER_TRIA)
!
      ALLOCATE(TRI_REF(NPOINT,0:MAX_TRIA),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TRI_REF')
       TRI_REF=0 
       DO J = 1, NBTRI
         K = 3*(J-1)+1  
         IKLE1 = IKLESTRI(K)
         IKLE2 = IKLESTRI(K+1)
         IKLE3 = IKLESTRI(K+2)
         THE_TRI=IKLE1
         IF (IKLE2 < THE_TRI) THE_TRI=IKLE2 
         IF (IKLE3< THE_TRI)  THE_TRI=IKLE3
         TRI_REF(THE_TRI,0)=TRI_REF(THE_TRI,0)+1
         POS=TRI_REF(THE_TRI,0)
         TRI_REF(THE_TRI,POS)=J
      END DO
      

      DO IELEB = 1,NBTRI
         IELEM = NELBOR(IELEB)
         IKLE1 = NBOR(IKLBOR(IELEB,1))
         IKLE2 = NBOR(IKLBOR(IELEB,2))
         IKLE3 = NBOR(IKLBOR(IELEB,3))
         THE_TRI=IKLE1
         IF (IKLE2 < THE_TRI) THE_TRI=IKLE2 
         IF (IKLE3<THE_TRI)  THE_TRI=IKLE3
         POS=TRI_REF(THE_TRI,0)
         IS = .FALSE.
          M  = -1
         DO JJ = 1, POS
            J=TRI_REF(THE_TRI,JJ)
            K = 3*(J-1)+1            
            IF ((IKLE1.EQ.IKLESTRI(K)).AND.
     &          (IKLE2.EQ.IKLESTRI(K+1)).AND.
     &          (IKLE3.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.
            ELSE IF ((IKLE1.EQ.IKLESTRI(K)).AND.
     &          (IKLE3.EQ.IKLESTRI(K+1)).AND.
     &          (IKLE2.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.
            ELSE IF ((IKLE2.EQ.IKLESTRI(K)).AND.
     &          (IKLE1.EQ.IKLESTRI(K+1)).AND.
     &              (IKLE3.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.
            ELSE IF ((IKLE2.EQ.IKLESTRI(K)).AND.
     &          (IKLE3.EQ.IKLESTRI(K+1)).AND.
     &          (IKLE1.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.
            ELSE IF ((IKLE3.EQ.IKLESTRI(K)).AND.
     &          (IKLE1.EQ.IKLESTRI(K+1)).AND.
     &          (IKLE2.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.
            ELSE IF ((IKLE3.EQ.IKLESTRI(K)).AND.
     &          (IKLE2.EQ.IKLESTRI(K+1)).AND.
     &          (IKLE1.EQ.IKLESTRI(K+2))) THEN
               IS = .TRUE.         
            ENDIF
            IF (IS) THEN
               M = J
               EXIT
            ENDIF
         ENDDO
         DO I = 1,4
            IF (IFABOR(IELEM,I).EQ.0) THEN
               IF ((IKLE1.EQ.(IKLE(NELBOR(IELEB),SOMFAC(1,I))))
     &         .AND.(IKLE2.EQ.(IKLE(NELBOR(IELEB),SOMFAC(2,I))))  
     &         .AND. (IKLE3.EQ.(IKLE(NELBOR(IELEB),SOMFAC(3,I)))))
     &         THEN
                  NI = TETTRI2(IELEM)
                  N  = 4*(IELEM-1)+NI+1
                  TETTRI(N) = M
!                  WRITE(*,*) N, '---> ',M
                  TETTRI2(IELEM) = NI + 1
               ENDIF
            ENDIF
         END DO
      ENDDO
!
      DEALLOCATE(TRI_REF)
!
!
!
!
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(3),COUNT_RATE=PARSEC)
!------------------------------------------------------- FIN VERSION F.D


! 3B. CONSTRUCTION DE NODES1/NODES2/NODES3: CONNECTIVITE INVERSE NOEUD > TETRA
!     POUR L'ECRITURE A LA VOLEE DES UNV LOCAUX
!---------------
! PARCOURS DES MAILLES POUR CONNAITRE LE NOMBRE DE MAILLES QUI 
! LES REFERENCE
      ALLOCATE(NODES1(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES1')
      NODES1(:)=0
      DO I=1,NBTET
        DO K=1,4
          IKLEB=IKLESTET(4*(I-1)+K)
          NODES1(IKLEB)=NODES1(IKLEB)+1
        ENDDO
      ENDDO
! NOMBRE DE REFERENCEMENT DE POINTS ET POINTEUR NODES2 VERS NODES3
! LE IEME POINT A SA LISTE DE TETRA (EN NUMEROTATION LOCALE TETRA)
! DE NODES3(NODES2(I)) A NODES3(NODES2(I)+NODES1(I)-1)
      ALLOCATE(NODES2(NPOINT+1),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES2')
      COMPT=0
      NODES2(1)=1
      DO I=1,NPOINT
        COMPT=COMPT+NODES1(I)
        NODES2(I+1)=COMPT+1
      ENDDO
! POUR UN NOEUDS DONNE, QU'ELLES SONT LES MAILLES QUI LE CONCERNENT
      ALLOCATE(NODES3(COMPT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES3')
      NODES3(:)=-1
      DO I=1,NBTET
        DO K=1,4
          IKLEB=IKLESTET(4*(I-1)+K)
          NI=NODES2(IKLEB)
          NF=NI+NODES1(IKLEB)-1
          NT=-999
          DO N=NI,NF ! ON CHERCHE LE PREMIER INDICE DE LIBRE DE NODES3
            IF (NODES3(N)==-1) THEN
              NT=N
              EXIT
            ENDIF
          ENDDO ! EN N
          IF (NT==-999) THEN
            GOTO 146  ! PB DE DIMENSIONNEMENT DE VECTEURS NODESI
          ELSE
            NODES3(NT)=I  ! NUMERO LOCAL DU TETRA I ASSOCIE AU NOEUD NT
          ENDIF
        ENDDO
      ENDDO

! 3C. CONSTRUCTION DE NODES1T/NODES2T/NODES3T: CONNECTIVITE INVERSE NOEUD > TRIA
!     POUR LA COULEUR DES NOEUDS (DIRICHLET SUR L'INTERFACE)
!---------------
      ALLOCATE(NODES1T(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES1T')
      NODES1T(:)=0
      DO I=1,NBTRI
        DO K=1,3
          IKLEB=IKLESTRI(3*(I-1)+K)
          NODES1T(IKLEB)=NODES1T(IKLEB)+1
        ENDDO
      ENDDO
      ALLOCATE(NODES2T(NPOINT+1),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES2T')
      COMPT=0
      NODES2T(1)=1
      DO I=1,NPOINT
        COMPT=COMPT+NODES1T(I)
        NODES2T(I+1)=COMPT+1
      ENDDO
      ALLOCATE(NODES3T(COMPT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES3T')
      NODES3T(:)=-1
      DO I=1,NBTRI
        DO K=1,3
          IKLEB=IKLESTRI(3*(I-1)+K)
          NI=NODES2T(IKLEB)
          NF=NI+NODES1T(IKLEB)-1
          NT=-999
          DO N=NI,NF ! ON CHERCHE LE PREMIER INDICE DE LIBRE DE NODES3T
            IF (NODES3T(N)==-1) THEN
              NT=N
              EXIT
            ENDIF
          ENDDO ! EN N
          IF (NT==-999) THEN
            GOTO 146  ! PB DE DIMENSIONNEMENT DE VECTEURS NODESI
          ELSE
            NODES3T(NT)=I  ! NUMERO LOCAL DU TETRA I ASSOCIE AU NOEUD NT
          ENDIF
        ENDDO
      ENDDO
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(4),COUNT_RATE=PARSEC)
      WRITE(LU,*)' TEMPS CONNECTIVITE INVERSE PART1/ PART2',
     &          (1.0*(TEMPS_SC(3)-TEMPS_SC(2)))/(1.0*PARSEC),'/',
     &          (1.0*(TEMPS_SC(4)-TEMPS_SC(3)))/(1.0*PARSEC),' SECONDS'
         
!----------------------------------------------------------------------
! 4. PARTITIONING
!---------------

!        DO I=1,4*NBTET
!                WRITE(LU,*) 'TETTRIALPHA',TETTRI(I)       
!        ENDDO
!        DO I=1,NBTET
!                WRITE(LU,*) 'TETTRIBETA',TETTRI2(I)
!        ENDDO
!
!----------------------------------------------------------------------
!     NEW METIS INTERFACE (>= VERSION 5) :
!
      ALLOCATE(EPART(NBTET),STAT=IERR)
      CALL CHECK_ALLOCATE (IERR, 'EPART')
      ALLOCATE (NPART(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE (IERR, 'NPART')
!
!----------------------------------------------------------------------
!    CALL METIS : MESH PARTITIONNING
!
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(5),COUNT_RATE=PARSEC)
!
      WRITE(LU,*)' '
      WRITE(LU,*)' STARTING METIS MESH PARTITIONING------------------+'
!
      CALL PARTITIONER(1, NBTET, NPOINT, 4, NPARTS, IKLESTET,
     &                 EPART, NPART)
!
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(6),COUNT_RATE=PARSEC)
!
      WRITE(LU,*)' '
      WRITE(LU,*)' END METIS MESH PARTITIONING------------------+'
      WRITE(LU,*)' TEMPS CONSOMME PAR  METIS ',
     &           (1.0*(TEMPS_SC(6)-TEMPS_SC(5)))/(1.0*PARSEC),' SECONDS'
      WRITE(LU,80) NELEMTOTAL,NPOINT
      WRITE(LU,81) NBTET,NBTRI
      WRITE(LU,82) NPARTS
      WRITE(LU,*) 'SORTIE DE METIS CORRECTE'
!
      EPART = EPART+1
!
!D ******************************************************
!D     LOOP OVER THE TETRA TO COMPUTER THE NUMBER AND THE LABEL
!D     OF FINITE ELEMENTS ASSIGNED TO  EACH SUBDOMAIN
!D ******************************************************
!D     COMPUTATION OF THE MAXIMUM NUMBER OF FINITE ELEMENTS ASSIGNED TO ONE SUBDOMAIN
      NELEM_P(:)=0
      NPOIN_P(:)=0
       DO I=1,NBTET
         NELEM_P(EPART(I))=NELEM_P(EPART(I))+1
      END DO
      MAX_NELEM_P=MAXVAL(NELEM_P)
      WRITE(LU,*) 'NB MAX OF TETRAS PER SUBDOMAIN : ',MAX_NELEM_P
      NELEM_P(:)=0
!D     ALLOCATION OF THE ELEGL ARRAY 
      ALLOCATE(ELEGL(MAX_NELEM_P,NPARTS),STAT=IERR)
!D     ELEGL IS THE FILLED 
      CALL CHECK_ALLOCATE(IERR,'ELEGL')
      DO I=1,NBTET
         NELEM_P(EPART(I))=NELEM_P(EPART(I))+1
         ELEGL(NELEM_P(EPART(I)),EPART(I))=I
       END DO
!D     COMPUTE THE MAXIMUM OF NODES ASSIGNED TO ONE SUBDOMAIN
       NODELG(:)=0
!D     FOR EACH SUBDOMAIN IDD
       DO IDD=1,NPARTS  
          NODELG(:)=0
!D         LOOP ON THE FINITE ELEMENTS IELEM ASSIGNED TO SUBDOMAIN IDD
          DO POS=1,NELEM_P(IDD)
            IELEM=ELEGL(POS,IDD)
            N=4*(IELEM-1)+1
!D          LOOP OF THE NODE CONTAINED IN IELEM            
            DO K=0,3
               NODE=IKLESTET(N+K)
               IF (NODELG(NODE) .EQ. 0) THEN
                  NPOIN_P(IDD)=NPOIN_P(IDD)+1
                  NODELG(NODE)=NPOIN_P(IDD)
               END IF
            END DO
         END DO
      END DO
!D    ALLOCATION AND FILLING OF  THE NODEGL ARRAY      
      MAX_NPOIN_P=MAXVAL(NPOIN_P)
      NPOIN_P(:)=0
      NODELG(:)=0
!
      ALLOCATE(NODEGL(MAX_NPOIN_P,NPARTS),STAT=IERR)
       CALL CHECK_ALLOCATE(IERR,'NODEGL')
       DO IDD=1,NPARTS
          NODELG(:)=0
          DO POS=1,NELEM_P(IDD)
             IELEM=ELEGL(POS,IDD)
             N=4*(IELEM-1)+1
             DO K=0,3
                NODE=IKLESTET(N+K)
                IF (NODELG(NODE) .EQ. 0) THEN
                   NPOIN_P(IDD)=NPOIN_P(IDD)+1
                   NODELG(NODE)=NPOIN_P(IDD)
                   NODEGL(NPOIN_P(IDD),IDD)=NODE
                END IF
             END DO
          END DO
       END DO
!            
!----------------------------------------------------------------------
! 5A. ALLOCATIONS POUR ECRITURE DES FICHIERS .UNV/.LOG ASSOCIANT UN SOUS-DOMAINE
!     PAR PROC
!------------

      NAMEINP2=NAMEINP
      NAMELOG2=NAMELOG
      BLANC='    '
      MOINS1='-1'
      ALLOCATE(NODES4(NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NODES4')
!$$$      NODES4(:)=-1
      ALLOCATE(KNOLG(NPOINT),STAT=IERR)      ! C'EST SOUS-OPTIMAL EN
      CALL CHECK_ALLOCATE(IERR,' KNOLG')! TERME DE DIMENSIONNEMENT
      KNOLG(:)=-1      ! MAIS PLUS RAPIDE POUR LE REMPLISSAGE ULTERIEUR
! 
! PARAMETRE NBSDOMVOIS (NOMBRE DE SOUS DOMAINES VOISINS+2)
!      
      ALLOCATE(NACHB(NBSDOMVOIS,NPOINT),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' NACHB')
      NACHB(1,:)=0
      DO J=2,NBSDOMVOIS-1
        NACHB(J,:)=-1
      ENDDO
      ALLOCATE(TRIUNV(4*NBTRI),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR, 'TRIUNV')
!
!
! 5B. RECHERCHE DE LA VRAI COULEUR AUX NOEUDS POUR EVITER LES PBS DE DIRICHLET
!     AUX INTERFACES
!---------------
      NCOLOR2(:)=-1
      DO J=1,NPOINT      ! BOUCLE SUR TOUS LES POINTS DU MAILLAGES
        NI=NODES2T(J)
        NF=NI+NODES1T(J)-1
        DO N=NI,NF       ! BOUCLE SUR LES TETRA CONTENANT LE POINT J
          NUMTET=NODES3T(N)   ! TRIA DE NUMERO LOCAL NUMTET
          NUMTRIG=CONVTRI(NUMTET)  ! NUMERO GLOBAL DU TRIANGLE
          COLOR1=ECOLOR(NUMTRIG)   ! COULEUR DU NOEUD AVEC CE TRIA
          COLOR2=NCOLOR2(J)
          IF (COLOR2 > 0) THEN   ! ON PRIORISE LES COULEURS
            PR1=0
            PR2=0
            DO L=1,NBCOLOR
              IF (PRIORITY(L)==COLOR1) THEN
                PR1=L
 1           ENDIF
              IF (PRIORITY(L)==COLOR2) THEN
                PR2=L
              ENDIF
            ENDDO
            IF ((PR1==0).OR.(PR2==0)) GOTO 154
            IF (PR1<PR2) NCOLOR2(J)=COLOR1  ! ON CHANGE DE COULEUR
          ELSE        ! PREMIERE FOIS QUE CE NOEUD EST TRAITE
            NCOLOR2(J)=COLOR1
          ENDIF
        ENDDO
      ENDDO

      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(7),COUNT_RATE=PARSEC)

!      DO IELEM = 1, NPOINT
!         WRITE(LU,*) 'NCOLOR2',NCOLOR2(IELEM)
!      ENDDO

!      DO IELEM = 1, NBCOLOR
!         WRITE(LU,*) 'PRIOR',PRIORITY(IELEM)
!      ENDDO
!      
! OB D
!--------------
! RAJOUT POUR TENIR COMPTE DES COULEURS DES NOEUDS DE TETRAS LIES
! AU TRIA DE BORD ET SITUES DANS D'AUTRES SD
!--------------
!
      ALLOCATE(TETCOLOR(NBTET,4),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,' TETCOLOR')
      TETCOLOR(:,:)=.FALSE.
      NBRETOUCHE=0
      DO IPTFR=1,NPTFR      ! BOUCLE SUR TOUS LES POINTS DE BORD
        J=NBOR(IPTFR)
!       ON NE FAIT QQE CHOSE (EVENTUELLEMENT) QUE SI IL Y A UN TRIA
!       DE BORD (ECOLOR>0 ET NCOLOR2 !=-1). GRACE AU TRAITEMENT PRECEDENT
!       ON S'EN REND COMPTE DIRECTEMENT VIA NCOLOR2.
        LINTER=.FALSE.
        NBTETJ=NODES1(J) ! NBRE DE TETRA RATTACHES A CE NOEUD
        NI=NODES2(J)     ! ADRESSE DANS NODES3 DU PREMIER
        NF=NI+NBTETJ-1
        IF (NCOLOR2(J) > 0) THEN
!         ON CHERCHE A SAVOIR SI LE NOEUD EST A L'INTERFACE LINTER=.TRUE.
          DO N=NI,NF       ! BOUCLE SUR LES TETRA CONTENANT LE POINT J
            NT=NODES3(N)   ! TETRA DE NUMERO LOCAL NT
            IF (N.EQ.NI) THEN
              IDDNT=EPART(NT)
            ELSE
              IF (EPART(NT) /= IDDNT) THEN
                LINTER=.TRUE.
                GOTO 20     ! ON A LE RENSEIGNEMENT DEMANDE, ON SORT
              ENDIF
            ENDIF
          ENDDO	          ! FIN BOUCLE SUR LES TETRAS
   20     CONTINUE
!         LE NOEUD J EST UN NOEUD D'INTERFACE. ON VA COMMUNIQUER AU NOEUD
!         CORRESPONDANT DES TETRAS (SI UN TRIA DE BORD N'EST PAS SUR CETTE
!         FACE AUXQUEL CAS LE PB EST DEJA REGLE), LA BONNE COULEUR.
          IF (LINTER) THEN  
            DO N=NI,NF       ! BOUCLE SUR LES TETRA CONTENANT LE POINT J
              NT=NODES3(N)   ! TETRA DE NUMERO LOCAL NT
!         ON VA TRIER LES CAS NON PATHOLOGIQUES ET TRES COURANT DE TETRA
!         DONT UNE FACE COINCIDE AVEC CE TRIANGLE
              IF (TETTRI2(NT)>0) THEN   !TETRA CONCERNE PAR UN TRIA
                NIT=4*(NT-1)+1
                NFT=NIT+TETTRI2(NT)-1
                DO MT=NIT,NFT           ! BOUCLE SUR LES TRIA DU TETRA
                  NUMTRI=TETTRI(MT)     ! NUM LOCAL DU TRIA
                  NUMTRIB=3*(NUMTRI-1)+1
                  IKLE1=IKLESTRI(NUMTRIB) ! NUMERO GLOBAUX DES NOEUDS DU TRIA
                  IKLE2=IKLESTRI(NUMTRIB+1)
                  IKLE3=IKLESTRI(NUMTRIB+2)
!                 CE POINT J APPARTIENT DEJA A UN TRIA ACOLLE AU TETRA
!                 ON SAUTE LE TETRA NT
                  IF ((IKLE1==J).OR.(IKLE2==J).OR.(IKLE3==J)) THEN
! POUR TESTS
!                    WRITE(LU,*)'JE SAUTE LE TETRA ',NT,EPART(NT),
!     &                          TETTRI2(NT),' NODES ',J
                    GOTO 21
                  ENDIF	
                ENDDO
              ENDIF            ! FIN SI TETTRI
!             LE TETRA NT EST POTENTIELLEMENT OUBLIE, ON LE TRAITE AU CAS OU
!             LE PARTAGE SE FERA DANS ESTEL3D/READ_CONNECTIVITY
              NUMTETB=4*(NT-1)+1
              DO L=1,4
                IKLE1=IKLESTET(NUMTETB+L-1) ! NUMERO GLOBAUX DES NOEUDS DU TETRA
                IF (IKLE1==J) THEN
                  TETCOLOR(NT,L)=(TETCOLOR(NT,L).OR..TRUE.)
                  NBRETOUCHE=NBRETOUCHE+1
                ENDIF
              ENDDO  ! EN L
   21        CONTINUE
             ENDDO   ! FIN BOUCLE SUR LES TETRAS	    		    
          ENDIF   ! FIN SI LINTER   
        ENDIF             ! FIN SI SUR NCOLOR2
      ENDDO              ! FIN BOUCLE SUR LES POINTS DE BORD     
! OB F
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(8),COUNT_RATE=PARSEC)
      WRITE(LU,*)' NOMBRE DE RETOUCHE DU PARTITIONNEMENT (PART2): ',
     &           NBRETOUCHE
      WRITE(LU,*)' TEMPS DE RETOUCHE DU PARTITIONNEMENT PART1/PART2',
     &            (1.0*(TEMPS_SC(7)-TEMPS_SC(6)))/(1.0*PARSEC),'/',
     &           (1.0*(TEMPS_SC(8)-TEMPS_SC(7)))/(1.0*PARSEC),' SECONDS'
!$$$      WRITE(LU,*)'IDEM VERSION DE REFERENCE'

! 5C. REMPLISSAGE EFFECTIF DU UNV PAR SD
!---------------
      IBID = 1
!
      ALLOCATE(DEJA_TROUVE(NELIN),STAT=IERR)
      CALL CHECK_ALLOCATE(IERR,'DEJA_TROUVE')
      DEJA_TROUVE(:)=.FALSE.
!      
      DO IDD=1,NPARTS  ! BOUCLE SUR LES SOUS-DOMAINES

! NOMBRE DE TRIANGLES POUR CE SOUS-DOMAINE
        NBTRIIDD=0
! NOM DU FICHIER UNV PAR SOUS-DOMAINE
        NAMEINP2(I_LENINP+1:I_LENINP+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NINP2,FILE=NAMEINP2,STATUS='UNKNOWN',FORM='FORMATTED',
     &       ERR=132)
        REWIND(NINP2)

! NOM DU FICHIER LOG PAR SOUS-DOMAINE
        NAMELOG2(I_LENLOG+1:I_LENLOG+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NLOG2,FILE=NAMELOG2,STATUS='UNKNOWN',FORM='FORMATTED',
     &       ERR=133)
        REWIND(NLOG2)

! TITRE (UNV PAR SD)
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
        WRITE(NINP2,61,ERR=112)NSEC1
        WRITE(NINP2,62,ERR=112)TITRE
        TITRE = ' ' 
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,62,ERR=112)TITRE
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
!
! BLOC SUR LES COORDONNEES/COULEURS DES NOEUDS (UNV PAR SD)
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
        WRITE(NINP2,61,ERR=112)NSEC2
        COMPT=1
        NODES4(:)=-1
!D      NEW VERSION OF THE LOOP TO REDUCE THE COMPUTING TIME
        DO POS_NODE=1,NPOIN_P(IDD) ! BOUCLE SUR TOUS LES POINTS DU MAILLAGES
           J=NODEGL(POS_NODE,IDD)
!D       PREVIOUS VERSION OF THE LOOP
!D       NI=NODES2(J)
!D       NF=NI+NODES1(J)-1
!D       DO N=NI,NF       ! BOUCLE SUR LES TETRA CONTENANT LE POINT J
!D           NT=NODES3(N)   ! TETRA DE NUMERO LOCAL NT 
!D           IF (EPART(NT)==IDD) THEN     ! C'EST UNE MAILLE DU SOUS-DOMAINE
              WRITE(NINP2,63,ERR=112)COMPT,IBID,IBID,NCOLOR2(J)
              WRITE(NINP2,64,ERR=112)X1(J),Y1(J),Z1(J)
              NODES4(J)=COMPT   ! LE NOEUD J A LE NUMERO COMPT
                                ! POUR LE SOUS-DOMAINE IDD
! POUR PARALLELISME TELEMAC
              KNOLG(COMPT)=J ! CONVERSION SD (LOCAL)-->MAILLAGE ENTIER (GLOBAL)
              K=NACHB(1,J)   ! NBRE DE SD CONTENANT LE NOEUD J
              NACHBLOG=.TRUE.       
              DO L=1,K     ! NOEUD DEJA CONCERNE PAR CE SD ?
                IF (NACHB(1+L,J)==IDD) NACHBLOG=.FALSE.  ! OUI      
              ENDDO
              IF (NACHBLOG) THEN                         ! NON
                K=NACHB(1,J)+1
                IF (K.GT.NBSDOMVOIS-2) GOTO 151
                NACHB(K+1,J)=IDD  ! NOEUD GLOBAL J CONCERNE PAR IDD
                NACHB(1,J)=K      ! SA MULTIPLICITE
              ENDIF 
              COMPT=COMPT+1
!              GOTO 10 ! ON PASSE AU NOEUD SUIVANT           
!            ENDIF  ! EN EPART
!          ENDDO ! EN N
!   10     CONTINUE
        ENDDO   ! EN J
! POUR TESTS
!      DO I=1,NPOINT
!        WRITE(LU,*)'GLOBAL NUMERO POINT: ',I,' LOCAL: ',NODES4(I)
!      ENDDO
        NPOINTSD(IDD)=COMPT-1  ! NOMBRE DE NOEUDS DU SOUS-DOMAINE IDD
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1

! BLOC SUR LES CONNECTIVITES/COULEURS DES MAILLES (UNV PAR SD)
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
        WRITE(NINP2,61,ERR=112)NSEC3
        COMPT=1
        IBID = 1
!D      PREVIOUS VERSION OF THE LOOP
!D      DO J=1,NELEMTOTAL
!D      IF (TYPELEM(J,1)==111) THEN ! C'EST UN TETRAEDRE
!D        NUMTET=TYPELEM(J,2) ! NUM LOCAL DU TETRA DANS LA LISTE DES TETRAS
!D            IF (EPART(NUMTET)==IDD) THEN 
        DO POS=1,NELEM_P(IDD)
                                ! BOUCLE SUR TETRA ET TRIA POUR ECOLOR
           J=ELEGL(POS,IDD)
           NUMTET=TYPELEM(J,2)  ! NUM LOCAL DU TETRA DANS LA LISTE DES TETRAS 
           ELEM=111
! OB D
! PRETRAITEMENT POUR LES EVENTUELS PB DE COULEURS DES NOEUDS DE TETRAS
! A L'INTERFACE
              IBIDC=0
              IF (TETCOLOR(NUMTET,1)) IBIDC=IBIDC+1000
              IF (TETCOLOR(NUMTET,2)) IBIDC=IBIDC+ 200
              IF (TETCOLOR(NUMTET,3)) IBIDC=IBIDC+  30
              IF (TETCOLOR(NUMTET,4)) IBIDC=IBIDC+   4
! POUR MONITORING
!              IF (IBIDC/=0) WRITE(6,*)'IDD',IDD,'PARTEL',J,COMPT,IBIDC
! IDEM VERSION DE REFERENCE
!	      IBIDC=0
! OB F
              WRITE(NINP2,65,ERR=112)COMPT,ELEM,-IBIDC,IBID,ECOLOR(J),4
              COMPT=COMPT+1
              N=4*(NUMTET-1)+1
              IKLE1=NODES4(IKLESTET(N))
              IKLE2=NODES4(IKLESTET(N+1))
              IKLE3=NODES4(IKLESTET(N+2))
              IKLE4=NODES4(IKLESTET(N+3))
              WRITE(NINP2,66,ERR=112)IKLE1,IKLE2,IKLE3,IKLE4
       IF ((IKLE1.LT.0).OR.(IKLE2.LT.0).OR.(IKLE3.LT.0).OR.(IKLE4.LT.0))
     &          GOTO 147
              IF (TETTRI2(NUMTET).NE.0) THEN
                NI=4*(NUMTET-1)+1
                NF=NI+TETTRI2(NUMTET)-1
                DO M=NI,NF   ! ON PARCOURT LES TRIANGLES DE BORD ASSOCIES
                  NUMTRI=TETTRI(M)  ! AU NUMTET TETRAEDRE; NUM LOCAL DU TRIA
                  NUMTRIG=CONVTRI(NUMTRI)  ! NUMERO GLOBAL DU TRIANGLE
                  ELEM=91
                  TRIUNV(4*NBTRIIDD+1)=ECOLOR(NUMTRIG)
                  N=3*(NUMTRI-1)+1
                  IKLE1=NODES4(IKLESTRI(N))
                  IKLE2=NODES4(IKLESTRI(N+1))
                  IKLE3=NODES4(IKLESTRI(N+2))
                  TRIUNV(4*NBTRIIDD+2)=IKLE1
                  TRIUNV(4*NBTRIIDD+3)=IKLE2
                  TRIUNV(4*NBTRIIDD+4)=IKLE3
                  NBTRIIDD=NBTRIIDD+1
!
              IF ((IKLE1.LT.0).OR.(IKLE2.LT.0).OR.(IKLE3.LT.0)) GOTO 147
!
                ENDDO  ! EN M
              ENDIF  ! EN TETTRI2
        !    ENDIF  ! EN EPART
      !    ENDIF  ! EN TYPELEM
        ENDDO ! EN J

! MAINTENANT ON PEUX RECOPIER LE BLOC DES TRIANGLES !
        ELEM=91
        DO J=1,NBTRIIDD
          WRITE(NINP2,65,ERR=112)COMPT,ELEM,IBID,IBID,
     &                           TRIUNV(4*(J-1)+1),3
          IKLE1=TRIUNV(4*(J-1)+2)
          IKLE2=TRIUNV(4*(J-1)+3)
          IKLE3=TRIUNV(4*(J-1)+4)
          WRITE(NINP2,67,ERR=112)IKLE1,IKLE2,IKLE3        
          COMPT=COMPT+1
        ENDDO  ! EN J
!
        ELEM=91
! BOUCLE SURDIMENSIONNEE, ON BOUCLE SUR LE NOMBRE DE SURFACE INTERNE DU MAILLAGE GLOBAL...                                
        DO J=1,NELIN
           IF (DEJA_TROUVE(J)) CYCLE
           IKLE1=NODES4(IKLEIN(J,2))
           IKLE2=NODES4(IKLEIN(J,3))
           IKLE3=NODES4(IKLEIN(J,4))
           IF ((IKLE1.EQ.-1).OR.(IKLE2.EQ.-1).OR.(IKLE3.EQ.-1)) CYCLE
           WRITE(NINP2,65,ERR=112) COMPT,ELEM,IBID,IBID,IKLEIN(J,1),3
           WRITE(NINP2,67,ERR=112) IKLE1,IKLE2,IKLE3
           COMPT = COMPT+1
           DEJA_TROUVE(J) = .TRUE.
        ENDDO ! EN J
!
!$$$        WRITE(LU,*) 'SUBDOMAIN',IDD,'INNERTRI',COMPT
!        
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
!        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
!        WRITE(NINP2,61,ERR=112)NSEC4
!        WRITE(NINP2,68,ERR=112) 1,0,0,0,0,0,0,0
        CLOSE(NINP2)
        NELEMSD(IDD)=COMPT-1  ! NOMBRE DE MAILLES DU SOUS-DOMAINE IDD

! 5D. REMPLISSAGE EFFECTIF DU LOG PAR SD
!---------------
! ELEMENT STANDARD DU FICHIER LOG (LOG PAR SD)
        WRITE(NLOG2,51 ,ERR=113) NPOINTSD(IDD)      
        WRITE(NLOG2,52 ,ERR=113) NELEMSD(IDD)
        WRITE(NLOG2,523,ERR=113) SIZE_FLUX
        WRITE(NLOG2,53 ,ERR=113) NBFAMILY-1
        DO J=1,NBFAMILY
          WRITE(NLOG2,50,ERR=113)LOGFAMILY(J)
        ENDDO

        ! ADDITION BY JP RENAUD ON 15/02/2007
        ! AS THE LIST OF PRIORITIES HAS MOVED IN ESTEL-3D FROM
        ! THE STEERING FILE TO THE LOG FILE, WE NEED TO WRITE "A"
        ! NUMBER OF EXTERNAL FACES + PRIORITY LIST HERE. AS THESE
        ! ARE NOT USED IN PARALLEL MODE, WE MERELY COPY THE LIST
        ! FROM THE ORIGINAL LOG FILE.

        WRITE(NLOG2,531,ERR=113) NBCOLOR
        WRITE(UNIT=THEFORMAT,FMT=1000) NBCOLOR
1000    FORMAT('(''PRIORITY :'',',I3,'(X,I3,))')
        THEFORMAT=TRIM(THEFORMAT)
!        WRITE(LU,*) 'FORMATT =',THEFORMAT
        WRITE (NLOG2,FMT=THEFORMAT(1:LEN(THEFORMAT)-1))
     &  (PRIORITY(I), I=1, NBCOLOR)

        ! END ADDITION BY JP RENAUD

! KNOLG (LOG PAR SD)
        NT=NPOINTSD(IDD)
        NI=NT/6
        NF=NT-6*NI
        WRITE(NLOG2,54,ERR=113)NI,NF
        DO J=1,NI
          WRITE(NLOG2,540,ERR=113)(KNOLG(6*(J-1)+K),K=1,6)
        ENDDO
        IF (NF.EQ.1) THEN
          WRITE(NLOG2,541,ERR=113)KNOLG(6*NI+1)
        ELSE IF (NF.EQ.2) THEN
          WRITE(NLOG2,542,ERR=113)(KNOLG(6*NI+K),K=1,2)
        ELSE IF (NF.EQ.3) THEN
          WRITE(NLOG2,543,ERR=113)(KNOLG(6*NI+K),K=1,3)
        ELSE IF (NF.EQ.4) THEN
          WRITE(NLOG2,544,ERR=113)(KNOLG(6*NI+K),K=1,4)
        ELSE IF (NF.EQ.5) THEN
          WRITE(NLOG2,545,ERR=113)(KNOLG(6*NI+K),K=1,5)
        ENDIF
        WRITE(NLOG2,55,ERR=113)NPOINT  ! NOMBRE DE NOEUD DU MAILLAGE
                    ! INITIAL POUR ALLOCATION KNOGL DANS ESTEL
!
      ENDDO  ! BOUCLE SUR LES SOUS-DOMAINES

! 5E. TRAVAUX SUPPLEMENTAIRES POUR DETERMINER LE NACHB AVANT DE L'ECRIRE
!      DANS LE LOG
!---------------
      DO IDD=1,NPARTS  ! BOUCLE SUR LES SOUS-DOMAINES
! CONSTRUCTION ET DIMENSIONNEMENT DU NACHB PROPRE A CHAQUE SD
        COMPT=0
        NACHB(NBSDOMVOIS,:)=-1
        DO J=1,NPOINT      ! BOUCLE SUR TOUS LES POINTS DU MAILLAGE
          N=NACHB(1,J)
          IF (N>1) THEN    ! POINT D'INTERFACE
            N=N+1
            DO K=2,N
              IF (NACHB(K,J)==IDD) THEN ! IL CONCERNE IDD
                COMPT=COMPT+1   ! "COMPT"IEME POINT D'INTERFACE DE IDD
                NACHB(NBSDOMVOIS,J)=COMPT  ! A RETENIR COMME POINT D'INTERFACE
              ENDIF
            ENDDO            ! FIN BOUCLE SUR LES SD DU POINT J
          ENDIF   
        ENDDO              ! FIN BOUCLE POINTS
        NPOINTISD(IDD)=COMPT ! NOMBRE DE POINTS D'INTERFACE DE IDD

! 5F. ON CONTINUE L'ECRITURE DU .LOG
!-------------
        NAMELOG2(I_LENLOG+1:I_LENLOG+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NLOG2,FILE=NAMELOG2,STATUS='OLD',FORM='FORMATTED',
     &       POSITION='APPEND',ERR=133)
        WRITE(NLOG2,56,ERR=113) NPOINTISD(IDD)
        DO J=1,NPOINT
          IF (NACHB(NBSDOMVOIS,J)>0) THEN  ! C'EST UN POINT D'INTERFACE DE IDD
            COMPT=0
            VECTNB(:)=-1
            DO K=1,NBSDOMVOIS-2    ! ON PREPARE L'INFO POUR LE NACHB TELEMAC
              IF (NACHB(K+1,J)/= IDD) THEN
                COMPT=COMPT+1
! ATTENTION A CELUI-CI, SUREMENT LIE AU NUMERO DE POINTS...
! OB D
                IF (COMPT.GT.NBSDOMVOIS-3) GOTO 152
! OB F
                IF (NACHB(K+1,J)>0) THEN
! ON STOCKE LE NUMERO DE PROC ET NON LE NUMERO DE SOUS-DOMAINE
! D'OU LA CONTRAINTE, UN PROC PAR SOUS-DOMAINE
                  VECTNB(COMPT)=NACHB(K+1,J)-1
                ENDIF
              ENDIF 
            ENDDO  ! EN K
!            WRITE(NLOG2,561,ERR=113)J,(VECTNB(K),K=1,NBSDOMVOIS-3)
             NT = NBSDOMVOIS-3
             NI=NT/6
             NF=NT-6*NI+1
             WRITE(NLOG2,640,ERR=113)J,(VECTNB(K),K=1,5)
             DO L=2,NI
               WRITE(NLOG2,640,ERR=113)(VECTNB(6*(L-1)+K),K=0,5)
             ENDDO
             IF (NF.EQ.1) THEN
               WRITE(NLOG2,641,ERR=113)VECTNB(6*NI)
             ELSEIF (NF.EQ.2) THEN
               WRITE(NLOG2,642,ERR=113)(VECTNB(6*NI+K),K=0,1)
             ELSEIF (NF.EQ.3) THEN
               WRITE(NLOG2,643,ERR=113)(VECTNB(6*NI+K),K=0,2)
             ELSEIF (NF.EQ.4) THEN
               WRITE(NLOG2,644,ERR=113)(VECTNB(6*NI+K),K=0,3)
             ELSEIF (NF.EQ.5) THEN
               WRITE(NLOG2,645,ERR=113)(VECTNB(6*NI+K),K=0,4)
             ENDIF
          ENDIF
        ENDDO  ! FIN BOUCLE EN J
        WRITE(NLOG2,57,ERR=113)        
        CLOSE(NLOG2)    
      ENDDO  ! BOUCLE SUR LES SOUS-DOMAINES
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(9),COUNT_RATE=PARSEC)
      WRITE(LU,*)' REMPLISSAGE DES FICHIERS UNV ET LOG',
     &           (1.0*(TEMPS_SC(9)-TEMPS_SC(8)))/(1.0*PARSEC),' SECONDS'
!----------------------------------------------------------------------
! 6. AFFICHAGES DANS PARTEL.LOG ET TEST DE COMPLETUDE DU PARTITIONNEMENT
!------------
 
      WRITE(LU,*)' '
      COMPT1=0
      COMPT2=0
      COMPT3=0
      DO IDD=1,NPARTS
        WRITE(LU,86)IDD,NELEMSD(IDD),NPOINTSD(IDD),NPOINTISD(IDD)
        COMPT3=COMPT3+NPOINTISD(IDD)
        COMPT2=COMPT2+NPOINTSD(IDD)
        COMPT1=COMPT1+NELEMSD(IDD)
      ENDDO
      WRITE(LU,*)' ------------------------------------'
      WRITE(LU,87)COMPT1,COMPT2,COMPT3
      WRITE(LU,88)COMPT1/NPARTS,COMPT2/NPARTS,COMPT3/NPARTS
      WRITE(LU,*)' '
      WRITE(LU,83)(1.0*(TEMPS_SC(9)-TEMPS_SC(1)))/(1.0*PARSEC)
      WRITE(LU,*)' ENDING METIS MESH PARTITIONING--------------------+'
      WRITE(LU,*)' '
      WRITE(LU,*)' WRITING GEOMETRY FILE FOR EACH PROCESSOR'
      WRITE(LU,*)' WRITING LOG FILE FOR EACH PROCESSOR'

!----------------------------------------------------------------------
! 7. DIVERS
!---------------

! 7.A FORMAT DU LOG
!---------------
   50 FORMAT(A80)         ! LES AUTRES LIGNES
!             1234567890123456789012345678901234567890123456789
   51 FORMAT(' TOTAL NO. OF NODES                   :    ',I10)
   52 FORMAT(' TOTAL NO. OF ELEMENTS                :    ',I10)
  523 FORMAT(' TOTAL NO. OF USER-FLUX               :    ',I10)
   53 FORMAT(' TOTAL NO. OF FAMILIES                :    ',I10)
  531 FORMAT(' TOTAL NUMBER OF EXTERNAL FACES       :    ',I10)
   54 FORMAT(' DEBUT DE KNOLG: ',I10,' ',I10)

 5401 FORMAT(6I5)              ! PRIORITY
 5411 FORMAT(I5)               ! 
 5421 FORMAT(2I5)              ! 
 5431 FORMAT(3I5)              ! 
 5441 FORMAT(4I5)              ! 
 5451 FORMAT(5I5)              ! 

  540 FORMAT(6I10)        ! LIGNE DE BLOC KNOLG ET PRIORITY
  541 FORMAT(I10)         ! DERNIERE LIGNE DE BLOC KNOLG
  542 FORMAT(2I10)        ! DERNIERE LIGNE DE BLOC KNOLG
  543 FORMAT(3I10)        ! DERNIERE LIGNE DE BLOC KNOLG
  544 FORMAT(4I10)        ! DERNIERE LIGNE DE BLOC KNOLG
  545 FORMAT(5I10)        ! DERNIERE LIGNE DE BLOC KNOLG

  641 FORMAT(I9)         ! DERNIERE LIGNE DE BLOC NACHB
  642 FORMAT(2I9)        ! DERNIERE LIGNE DE BLOC NACHB
  643 FORMAT(3I9)        ! DERNIERE LIGNE DE BLOC NACHB
  644 FORMAT(4I9)        ! DERNIERE LIGNE DE BLOC NACHB
  645 FORMAT(5I9)        ! DERNIERE LIGNE DE BLOC NACHB
  640 FORMAT(6I9)        ! DERNIERE LIGNE DE BLOC NACHB


  
   55 FORMAT(' FIN DE KNOLG: ',I10)
   56 FORMAT(' DEBUT DE NACHB: ',I10)
  561 FORMAT(10I10)        ! LIGNE DE BLOC NACHB
   57 FORMAT(' FIN DE NACHB: ')

! 7B. FORMAT DU UNV
!---------------
   60 FORMAT(A4,A2)       ! '    -1'   
   61 FORMAT(I9)          ! LECTURE NSEC
   62 FORMAT(A80)         ! LECTURE TITRE      
   63 FORMAT(4I10)        ! LIGNE 1 BLOC COORD      
   64 FORMAT(3D25.16)     ! LIGNE 2 BLOC COORD      
   65 FORMAT(6I10)        ! LIGNE 1 BLOC CONNECTIVITE      
   66 FORMAT(4I10)        ! LIGNE 2 BLOC CONNECTIVITE SI TETRA      
   67 FORMAT(3I10)        ! LIGNE 2 BLOC CONNECTIVITE SI TRIANGLE
   68 FORMAT(8I10)        ! BLOC FANTOCHE POUR MARQUER LA FIN DU BLOC
                          ! CONNECTIVITEE
      
! 7.C AFFICHAGES DANS PARTEL.LOG
!---------------
   80 FORMAT(' #NUMBER TOTAL OF ELEMENTS: ',I8,
     &       ' #NODES                 : ',I8)
   81 FORMAT(' #TETRAHEDRONS            : ',I8,
     &       ' #TRIANGLE MESH BORDER  : ',I8)
   82 FORMAT(' #NPARTS                : ',I8)   
   83 FORMAT('  RUNTIME                 : ',F10.2,' S')
   86 FORMAT('  DOMAIN: ',I3,' #ELEMENTS:   ',I8,' #NODES:   ',I8,
     &       ' #INTERFACENODES:   ',I8)
   87 FORMAT('  TOTAL VALUES OF ELEMENTS: ',I10,'  NODES: ',I10,
     &       '  INTERFACENODES: ',I10)
   88 FORMAT('  MEAN VALUES OF ELEMENTS :   ',I8,'  NODES:   ',I8,
     &       '  INTERFACENODES:   ',I8)
   89 FORMAT('  INPUT UNV FILE      :',A50)
   90 FORMAT('  INPUT LOG FILE      :',A50)
   91 FORMAT('  NUMBER OF PARTITIONS:',I5)
   92 FORMAT('  NUMBER OF NODES:',I10)
   93 FORMAT('  NUMBER OF ELEMENTS:',I10)
   94 FORMAT('  NUMBER OF COLORS:',I5)

! 7.D DEALLOCATE
!---------------
      DEALLOCATE(X1,Y1,Z1)
      DEALLOCATE(NCOLOR,ECOLOR)
      DEALLOCATE(IKLESTET,IKLESTRI,TYPELEM,CONVTRI,TETTRI,TETTRI2)
      DEALLOCATE(EPART,NPART)
      DEALLOCATE(NELEMSD,NPOINTSD,NPOINTISD)
      DEALLOCATE(NODES1,NODES2,NODES3,NODES4,TRIUNV)
      DEALLOCATE(NODES1T,NODES2T,NODES3T)
      DEALLOCATE(KNOLG,NACHB,PRIORITY,NCOLOR2)
      DEALLOCATE(ELEGL)
      DEALLOCATE(NODEGL)
      DEALLOCATE(NODELG)
      DEALLOCATE(NELEM_P)
      DEALLOCATE(NPOIN_P)
      RETURN

! 7.E MESSAGES D'ERREURS
!---------------
 
  111 TEXTERROR='! UNEXPECTED FILE FORMAT2: '//NAMEINP//' !'
      GOTO 999
  112 TEXTERROR='! UNEXPECTED FILE FORMAT3: '//NAMEINP2//' !'
      GOTO 999
  113 TEXTERROR='! UNEXPECTED FILE FORMAT4: '//NAMELOG2//' !'
      GOTO 999
  120 TEXTERROR='! UNEXPECTED EOF WHILE READING: '//NAMELOG//' !'
      GOTO 999
  130 TEXTERROR='! PROBLEM WHILE OPENING: '//NAMELOG//' !'
      GOTO 999
  131 TEXTERROR='! PROBLEM WHILE OPENING: '//NAMEINP//' !'
      GOTO 999
  132 TEXTERROR='! PROBLEM WHILE OPENING: '//NAMEINP2//' !'
      GOTO 999
  133 TEXTERROR='! PROBLEM WHILE OPENING: '//NAMELOG2//' !'
      GOTO 999
  140 TEXTERROR='! FILE DOES NOT EXIST: '//NAMEINP//' !'
      GOTO 999
  141 TEXTERROR='! FILE DOES NOT EXIST: '//NAMELOG//' !'
      GOTO 999
  143 DO J = 1,NELEMTOTAL
        IF (TYPELEM(J,2)==I) WRITE(UNIT=STR8,FMT='(I8)')J
      ENDDO
      WRITE(UNIT=STR26,FMT='(I8,1X,I8,1X,I8)')IKLE1,IKLE2,IKLE3
      TEXTERROR='! BORDER SURFACE OF NUMBER '//STR8//' AND OF NODES '//
     &          STR26//' NOT LINK TO A TETRAHEDRON !'
      GOTO 999
  144 WRITE(UNIT=STR8,FMT='(I8)')MAXLENSOFT
      TEXTERROR='! NAME OF INPUT FILE '//NAMEINP//' IS LONGER THAN '//
     &           STR8(1:3)//' CHARACTERS !'
      GOTO 999
  145 WRITE(UNIT=STR8,FMT='(I8)')MAXLENSOFT
      TEXTERROR='! NAME OF INPUT FILE '//NAMELOG//' IS LONGER THAN '//
     &           STR8(1:3)//' CHARACTERS !'
      GOTO 999
  146 TEXTERROR='! PROBLEM WITH CONSTRUCTION OF INVERSE CONNECTIVITY !'
      GOTO 999
  147 TEXTERROR='! PROBLEM WHILE WRITING: '//NAMEINP2//' !'
      GOTO 999
  149 TEXTERROR='! NO INPUT UNV FILE !' 
      GOTO 999
  151 WRITE(UNIT=STR8,FMT='(I8)')J
      WRITE(UNIT=STR26,FMT='(I3,1X,I3,1X,I3,1X,I3,1X,I3,1X,I3)')
     &                 (NACHB(K,J),K=2,NBSDOMVOIS-1),IDD
      TEXTERROR='! NODE '//STR8//' BELONGS TO DOMAINS '//STR26(1:23)
     &                 //' !' 
      GOTO 999
  152 TEXTERROR='! PROBLEM WITH CONSTRUCTION OF VECTNB FOR NACHB !' 
      GOTO 999
  153 WRITE(UNIT=STR8,FMT='(I8)') CONVTET(J)
      TEXTERROR='! TETRAHEDRON '//STR8//
     &          ' LINKS TO SEVERAL BORDER TRIANGLES !'
      GOTO 999
  154 TEXTERROR='! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
      GOTO 999
! END OF FILE AND FORMAT ERRORS :
 1100 TEXTERROR='ERREUR DE LECTURE DU FICHIER UNV '//
     &  'VIA MESH_CONNECTIVITY'
      GOTO 999
 1200 TEXTERROR='ERREUR DE FIN DE LECTURE DU FICHIER UNV '//
     &  'VIA MESH_CONNECTIVITY'
      GOTO 999

  999 WRITE(LU,*) TEXTERROR
!
      END SUBROUTINE PARES3D

