C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       PARTITIONING PROGRAM FOR TELEMAC'S BASE MESH OF TRIANGLES.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @note         PARTEL (C) 2000 COPYRIGHT BUNDESANSTALT FUER WASSERBAU, KARLSRUHE
!>  @note         METIS 4.0.1 COPYRIGHT 1998, REGENTS OF THE UNIVERSITY OF MINNESOTA
!>  @note         BIEF (C) 2000 ELECTRICITE DE FRANCE

!>  @note         COMPILER-CHECK: SGI MIPSPRO FORTRAN 90 COMPILER RELEASE 7.3.1.2M
!>                AND NAGWARE FORTRAN 95 COMPILER RELEASE 4.1(345)

!>  @note         FORTRAN-90; REQUIRES LINKING A C SUBROUTINE.
!>                USES SUBROUTINE METIS_PARTMESHDUAL FROM METIS LIBRARY
!>                AVAILABLE FROM HTTP://WWW-USERS.CS.UMN.EDU/~KARYPIS/METIS/

!>  @bug  JMH,08/08/2007 : THERE IS A CALL EXIT(ICODE) WHICH IS A
!>        FORTRAN EXTENSION. IT WILL NOT WORK WITH SOME COMPILERS,
!>        LIKE NAG

!>  @warning  NO MORE THAN MAXNPROC PROCESSORS

!>  @warning  NO CHECK OF THE SUBDOMAIN TOPOLOGY.
!>            LOG MUST BE CAREFULLY STUDIED FOR METIS MESSAGES

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> ALLVAR, AREA, ATBOR, AUBOR, BAL, BTBOR, CHCH, CHECK, CUT, CUT_P, DATE, DEBLIQ, DEBSOL, DEJAVU, EDGECUT, EF, EF_I, EF_II, ELEGL, ELELG, EPART, ERR, ETYPE, F, FINLIQ, FINSOL, FMT1, FMT2, FMT3, FMT4, FOUND, FRONTIERE, F_P, GELEGL, HALO, HBOR, I, IB, IDUM, IELEM_P, IFABOR, IFALOC, IFANUM, IFAPAR, II, IKLBOR, IKLE, IKLES, IKLES3D, IKLES3D_P, IKLES_P, ILOOP, INTERFACE, IPOIN_P, IPTFR_P, IRAND, IRAND_P, IS, ISEG, ISEGF, ISO, ISTART, ISTOP, IT1, IT2, IT3, I_LEN, I_LENCLI, I_LENINP, I_S, I_SP, J, K, KNOGL, KNOLG, KP1BOR, L, LI, LIHBOR, LITBOR, LIUBOR, LIVBOR, M, MAXADDCH, MAXALLVARLENGTH, MAXFRO, MAXLENHARD, MAXLENSOFT, MAXNPROC, MAXVAR, MAX_NELEM_P, MAX_NPOIN_P, MAX_N_NEIGH, MIN_NELEM_P, N, NAMECLI, NAMECLM, NAMEEPART, NAMEINP, NAMEMET, NAMENINPFORMAT, NAMENPART, NAMEOUT, NAMEOUTFORMA, NBMAXHALO, NBMAXNSHARE, NBOR, NBOR_P, NBRE_EF, NBRE_EF_I, NBRE_EF_LOC, NBRE_NOEUD_INTERF, NBRE_NOEUD_INTERNE, NCLI, NCLM, NDP, NDP_2D, NDP_3D, NDUM, NELBOR, NELEM, NELEM2, NELEM_P, NEPART, NFRLIQ, NFRSOL, NHALO, NINP, NINPFORMAT, NMET, NNPART, NOEUD, NOUT, NPART, NPARTS, NPLAN, NPOIN, NPOIN2, NPOIN_P, NPOIN_TOT, NPTFR, NPTFRMAX, NPTFR_P, NPTIR, NPTIR_P, NREC, NULONE, NUMFLAG, NUMLIQ, NUMSOL, NVAR, P, PARSEC, PART, PART_P, PMETHOD, POS, RDUM, SORT, TAB_TMP, TBOR, TDEB, TDEBP, TDEB_GLOB, TEMPS, TFIN, TFINP, TFIN_GLOB, TIME, TIMECOUNT, TIMED, TIMES, TITLE, TROUVE, UBOR, VARI, VARIABLE, VBOR, WRT, X1, X2, X3, XSEG, Y1, Y2, Y3, YSEG
!>   </td></tr>
!>     </table>

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
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 29/01/2009
!> </td><td> CHRISTOPHE DENIS (EDF SINETICS)
!> </td><td> DECREASES THE COMPUTING TIME.
!>           THIS RELEASE REQUIRES MORE RAM BUT A PARALLEL PARTEL RELEASE
!>           IS BEING DESIGNED TO DECREASE THE AMOUNT OF MEMORY REQUIRED
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 12/08/2008
!> </td><td> JAJ
!> </td><td> APPENDING PARTITIONED BC FILES WITH ELEMENTAL INTERFACE DESCRIPTION
!>           REQUIRED FOR PARALLEL CHARACTERISTICS.
!>           EXPLANATIONS IN THE CODE, FOLLOW THE //// MARKER (4 SLASHES).
!> JAJ NOTES: THIS PROGRAM HAS GONE TOO UGLY, NEEDS REWRITING!
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 03/07/2008
!> </td><td> JAJ PINXIT
!> </td><td> HALO ELEMENTS NEIGHBOURHOOD DESCRIPTION ADDED.
!>           FOR PARALLEL CHARACTERISTICS, FOLLOW 4 SLASHES ////
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 16/06/2008
!> </td><td> JEAN-MICHEL HERVOUET (LNHE)
!> </td><td> ADAPTING VOISIN_PARTEL FOR MESHES WHICH ARE NOT REALLY
!>           FINITE ELEMENT MESHES (THIS IS THE CASE OF SUB-DOMAINS)
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 15/05/2008
!> </td><td> PASCAL VEZOLLE (IBM)
!> </td><td> INCREASED THE NUMBER OF MAXIMAL PARTITIONS FROM 1000 TO 100000
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 19/02/2008
!> </td><td> OLIVIER BOITEAU (SINETICS)
!> </td><td> PARAMETERISATION OF ARRAY DIMENSIONS LIKE NACHB
!>           SEE NBSDOMVOIS AND NBMAXNSHARE, THE LATTER MUST
!>           BE EQUAL TO ITS VALUE IN BIEF.F
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td> 05/12/2006
!> </td><td> CHARLES MOULINEC
!> </td><td> MODIFIED TO AVOID THE PATHOLOGICAL CASE
!>           OF A BOUNDARY POINT WITHOUT FOLLOWING AND PRECEDING POINT IN
!>           THE SAME SUBDOMAIN.
!>           ALSO DIMENSION OF NBOR CHANGED TO NPTFRMAX*2.
!>           LOOK FOR "MOULINEC"
!> </td></tr>
!>  <tr>
!>      <td><center> 8TH RELEASE                            </center></td>
!>      <td> **/09/2003
!> </td><td> J-M HERVOUET
!> </td><td> UBOR AND VBOR INVERTED LINE 613 WHEN READING THE CLI FILE
!> </td></tr>
!>  <tr>
!>      <td><center> 7TH RELEASE                            </center></td>
!>      <td> 12/03/2003
!> </td><td> J-M HERVOUET
!> </td><td> ALGORITHM CHANGED : A SEGMENT IS IN A SUBDOMAIN IF IT BELONGS
!>                               TO AN ELEMENT IN THE SUBDOMAIN NOT IF THE
!>                               2 POINTS OF THE SEGMENT BELONG TO THE SUBDOMAIN.
!>      SPECIFIC ELEBD INCLUDED, ALL REFERENCE TO MPI OR BIEF REMOVED
!> </td></tr>
!>  <tr>
!>      <td><center> 6TH RELEASE                            </center></td>
!>      <td> 17/01/2003
!> </td><td> JAJ; MATTHIEU GONZALES DE LINARES
!> </td><td> CORRECTED A WRONG DIMENSION OF THE ARRAY ALLVAR
!>           CORRECTED FOR 1000 PROCESSORS (JAJ, 19/02/2003)
!> </td></tr>
!>  <tr>
!>      <td><center> 5TH RELEASE                            </center></td>
!>      <td> 21/01/2002
!> </td><td> JMH
!> </td><td> CORRECTED A WRONG DIMENSION OF THE ARRAY CUT, AN ERROR
!>           OCCURING BY A LARGER NUMBER OF PROCESSORS
!> </td></tr>
!>  <tr>
!>      <td><center> 4TH RELEASE                            </center></td>
!>      <td> 17/04/2002
!> </td><td>
!> </td><td> PARTITIONING FOR 3D RESULT FILES DONE BY JMH.
!>           INCLUDING BOTH PARTITIONING METHODS AND BEAUTIFYING BY JAJ
!> </td></tr>
!>  <tr>
!>      <td><center> 3RD RELEASE                            </center></td>
!>      <td> 22/02/2002
!> </td><td> JAJ PINXIT
!> </td><td> ERRORS IN BC VALUES IN DECOMPOSED BC FILES REMOVED.
!>           ERRONEOUS TREATMENT OF ISLANDS DEBUGGED
!> </td></tr>
!>  <tr>
!>      <td><center> 2ND RELEASE                            </center></td>
!>      <td> 12/12/2000
!> </td><td> JAJ PINXIT
!> </td><td> PARTITIONING OF GEOMETRY AND 2D RESULT FILES POSSIBLE
!> </td></tr>
!>  <tr>
!>      <td><center> 1ST RELEASE                            </center></td>
!>      <td> 01-03/2000
!> </td><td> RK
!> </td><td> SEL_METIS & METIS_SEL
!> </td></tr>
!>  <tr>
!>      <td><center> 5.1 - 5.2                              </center></td>
!>      <td>
!> </td><td> REBEKKA KOPMANN REBEKKA.KOPMANN@BAW.DE;
!>           JACEK A. JANKOWSKI JACEK.JANKOWSKI@BAW.DE;
!>           JEAN-MICHEL HERVOUET J-M.HERVOUET@EDF.FR
!> </td><td>
!> </td></tr>
!>  <tr>
!>      <td><center>                                        </center></td>
!>      <td>
!> </td><td>
!> </td><td> PARTIALLY BASED ON PROGRAM HANSEL, DATED 12TH JULY 1995,
!>           BY REINHARD HINKELMANN ET AL., (C) UNIVERSITY OF HANNOVER
!> </td></tr>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>     </table>
C
C#######################################################################
C
                        PROGRAM PARTEL
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
!
C     MAXIMUM GEOMETRICAL MULTIPLICITY OF A NODE (VARIABLE ALSO
C     PRESENT IN BIEF, DO NOT MODIFY ONE AND NOT THE OTHER)
      INTEGER, PARAMETER :: NBMAXNSHARE =  10
C     MAXIMUM NUMBER OF HALO, IN THE PARALLEL RELEASE THE NUMBER OF HALO WILL BE DIRECTLY COMPUTED
      INTEGER, PARAMETER :: NBMAXHALO=100000
!
      INTEGER, PARAMETER :: MAXNPROC = 100000 ! MAX PARTITION NUMBER [00000..99999]
      INTEGER, PARAMETER :: MAXLENSOFT = 144 ! SOFT MAX FILE NAME LENGTH
      INTEGER, PARAMETER :: MAXLENHARD = 250 ! HARD MAX FILE NAME LENGTH
      INTEGER, PARAMETER :: MAXADDCH = 10 ! MAX ADDED SUFFIX LENGTH
      INTEGER, PARAMETER :: MAXVAR = 100  ! MAX NUMBER OF VARIABLES
      INTEGER, PARAMETER :: MAXALLVARLENGTH = 3200 ! MAXVAR*32 FOR ALLVAR
!
      INTEGER PMETHOD
      INTEGER NVAR, NREC, NPLAN, NPTFR, NPTIR, NPTFRMAX
      INTEGER NELEM, NPOIN, NDP, NELEM2, NPOIN2, NDUM
      INTEGER IB(10)
!
      INTEGER, ALLOCATABLE :: IKLES(:), IKLES_P(:)
      INTEGER, ALLOCATABLE :: IKLES3D(:),IKLES3D_P(:,:,:)
      INTEGER, ALLOCATABLE :: IRAND(:), IRAND_P(:)
      INTEGER, ALLOCATABLE :: LIHBOR(:), LIUBOR(:), LIVBOR(:)
      INTEGER, ALLOCATABLE :: LITBOR(:)
      INTEGER, ALLOCATABLE :: NPOIN_P(:), NELEM_P(:), NPTFR_P(:)
      INTEGER, ALLOCATABLE :: NBOR(:), NBOR_P(:), NPTIR_P(:)
      INTEGER, ALLOCATABLE :: NUMLIQ(:), NUMSOL(:)
      INTEGER, ALLOCATABLE :: KNOLG(:,:), KNOGL(:,:),CHECK(:)
      INTEGER, ALLOCATABLE :: ELELG(:,:), ELEGL(:)
      INTEGER, ALLOCATABLE :: CUT(:), CUT_P(:,:), SORT(:)
      INTEGER, ALLOCATABLE :: PART_P(:,:), PART(:)
!
      REAL, ALLOCATABLE    :: F(:,:), F_P(:,:,:)
      REAL, ALLOCATABLE    :: HBOR(:)
      REAL, ALLOCATABLE    :: UBOR(:), VBOR(:), AUBOR(:)
      REAL, ALLOCATABLE    :: TBOR(:), ATBOR(:), BTBOR(:)
!
      REAL TIMES, TIMED
!
      INTEGER :: NINP=10, NCLI=11, NMET=12,NINPFORMAT=52
      INTEGER :: NEPART=15, NNPART=16, NOUT=17, NCLM=18
      INTEGER TIME(3), DATE(3)
!
      CHARACTER(LEN=80)  :: TITLE
      CHARACTER(LEN=32)  :: VARI, VARIABLE(MAXVAR)
      CHARACTER(LEN=MAXALLVARLENGTH) :: ALLVAR
      CHARACTER(LEN=MAXLENHARD)  :: NAMEINP, NAMECLI, NAMEOUT, NAMECLM
      CHARACTER(LEN=MAXLENHARD)  :: NAMEMET,NAMEEPART,NAMENPART,
     &     NAMENINPFORMAT,NAMEOUTFORMA
      CHARACTER(LEN=5)   :: CHCH
      CHARACTER(LEN=12)  :: FMT4
!
      INTEGER MAX_NELEM_P, MIN_NELEM_P
      INTEGER  MAX_NPOIN_P,MAX_N_NEIGH
      INTEGER I, J, K, L , M, N, P, ERR, ISO, IDUM
      INTEGER ISTOP, ISTART, ISEG, II, ILOOP
      INTEGER I_LEN, I_S, I_SP, I_LENCLI, I_LENINP
      INTEGER IELEM_P, IPOIN_P, IPTFR_P
!
      REAL XSEG, YSEG, BAL, RDUM
      DOUBLE PRECISION AREA, X1, X2, X3, Y1, Y2, Y3
      LOGICAL IS, WRT, TIMECOUNT
!
C METISOLOGY
!
      INTEGER NPARTS, ETYPE, NUMFLAG, EDGECUT
      INTEGER, ALLOCATABLE :: EPART(:), NPART(:)
      CHARACTER(LEN=10) FMT1, FMT2, FMT3
!
C TO CALL FRONT2
!
      INTEGER, PARAMETER :: MAXFRO = 300   ! MAX NUMBER OF BOUNDARIES
      INTEGER NFRLIQ, NFRSOL, DEBLIQ(MAXFRO), FINLIQ(MAXFRO)
      INTEGER DEBSOL(MAXFRO), FINSOL(MAXFRO)
      INTEGER, ALLOCATABLE :: DEJAVU(:), KP1BOR(:,:)
!
C TO CALL BIEF MESH SUBROUTINES (TO BE OPTIMISED SOON):
      INTEGER, ALLOCATABLE :: IFABOR(:,:), IFANUM(:,:), NELBOR(:)
      INTEGER, ALLOCATABLE :: NULONE(:,:)
      INTEGER, ALLOCATABLE :: IKLE(:,:), IKLBOR(:,:), ISEGF(:)
      INTEGER, ALLOCATABLE :: IT1(:), IT2(:), IT3(:)

      INTEGER NPOIN_TOT

      INTEGER LNG,LU,LI
      COMMON /INFO/ LNG,LU
!
C TIME MEASURING
!
      INTEGER  TDEB, TFIN, TDEBP, TFINP, TEMPS, PARSEC
      INTEGER  TDEB_GLOB, TFIN_GLOB
      INTEGER  TIME_IN_SECONDS
      EXTERNAL TIME_IN_SECONDS
!
C EXTENS FUNCTION
!
      CHARACTER(LEN=11) :: EXTENS
      EXTERNAL EXTENS
!
!----------------------------------------------------------------------
!
CJAJ NEW FOR PARALLEL CHARACTERISTICS ////
C HALO ELEMENTS: THESE ADJACENT TO THE INTERFACE EDGES HAVING
C NEIGHBOURS BEHIND A BOUNDARY
!
      ! THE ELEMENTAL GLOBAL->LOCAL NUMBERING TRANSLATION TABLE
      ! THIS IS ELEGL SAVED FROM ALL PARTITIONS FOR FURTHER USE
      INTEGER, ALLOCATABLE :: GELEGL(:,:)
!
      ! THE HALO ELEMENTS NEIGHBOURHOOD DESCRIPTION FOR A HALO CELL
      INTEGER, ALLOCATABLE :: IFAPAR(:,:,:)
!
      ! THE NUMBER OF HALO CELLS PRO PARTITION
      INTEGER, ALLOCATABLE :: NHALO(:)
!
      ! WORK VARIABLES
      INTEGER IFALOC(3)
      LOGICAL FOUND
      INTEGER NDP_2D,NDP_3D
      INTEGER EF,POS
      INTEGER, ALLOCATABLE :: NBRE_EF(:),NBRE_EF_LOC(:),EF_I(:),
     &     TAB_TMP(:),EF_II(:)
      LOGICAL TROUVE,HALO
      INTEGER NOEUD,NBRE_NOEUD_INTERNE
      INTEGER NBRE_NOEUD_INTERF
      INTEGER FRONTIERE,NBRE_EF_I
      LOGICAL INTERFACE

C #### FOR SECTIONS

      TYPE CHAIN_TYPE
        INTEGER :: NPAIR(2)
        DOUBLE PRECISION :: XYBEG(2), XYEND(2)
        CHARACTER(LEN=24) :: DESCR
        INTEGER :: NSEG
        INTEGER, POINTER :: LISTE(:,:)
      END TYPE
      TYPE (CHAIN_TYPE), ALLOCATABLE :: CHAIN(:)
      INTEGER, PARAMETER :: NSEMAX=500 ! MAX NUMBER OF SEGMENTS IN A SECTION
      INTEGER, ALLOCATABLE :: LISTE(:,:), ANPBEG(:),ANPEND(:)
      INTEGER :: NSEC, IHOWSEC, ISEC, IELEM, IM(1), IN(1), NPBEG, NPEND
      INTEGER :: NCP, PT, I1,I2,I3, ARR,DEP, ILPREC,ILBEST,ELBEST,IGBEST
      DOUBLE PRECISION :: XA, YA, DISTB, DISTE, DMINB, DMINE
      DOUBLE PRECISION :: DIST1, DIST2, DIST3, DIST
      CHARACTER(LEN=MAXLENHARD) :: NAMESEC
      LOGICAL :: WITH_SECTIONS=.FALSE.

!
!----------------------------------------------------------------------
!
      NDP_2D=3
      NDP_3D=6

      CALL SYSTEM_CLOCK (COUNT=TEMPS, COUNT_RATE=PARSEC)
      TIMECOUNT = .TRUE.
      IF (PARSEC==0) TIMECOUNT = .FALSE.  ! COUNT_RATE == 0 : NO CLOCK
      IF (TIMECOUNT) TDEB = TEMPS
!
      LNG=2 ! I DO NOT SPEAK FRENCH, I AM BARBARIEN
      LU=6  ! FORTRAN STANDARD OUPUT CHANNEL
      LI=5  ! FORTRAN STANDARD INPUT CHANNEL


!----------------------------------------------------------------------
C NAMES OF THE INPUT FILE TO EVENTUALLY GUIDE TO PARES3D
C IF PARALLEL COMPUTATION WITH ESTEL3D
!
!
C=>FABS
C      DO
C        READ(LI,'(A)')NAMEINP
C        IF (NAMEINP /= ' ') EXITABOUT:
C      ENDDO
C      IF (NAMEINP(1:3)=='ES3') THEN
C PARTEL ADAPTED TO ESTEL3D CODE
C        CALL PARES3D(NAMEINP,LI)
C BACK TO THE END OF PARTELABOUT:
C        GOTO 299
C      ELSE
C CONTINUE WITH TELEMAC CODES
C        REWIND LI
C      ENDIF
C<=FABS
!
!----------------------------------------------------------------------
C INTRODUCE YOURSELF
!
      WRITE(LU,*) ' '
      WRITE(LU,*) '+-------------------------------------------------+'
      WRITE(LU,*) '  PARTEL: TELEMAC SELAFIN METISOLOGIC PARTITIONER'
      WRITE(LU,*) '                                                   '
      WRITE(LU,*) '  REBEKKA KOPMANN & JACEK A. JANKOWSKI (BAW)'
      WRITE(LU,*) '                 JEAN-MICHEL HERVOUET (LNHE)'
      WRITE(LU,*) '                 CHRISTOPHE DENIS     (SINETICS) '
      WRITE(LU,*) '  PARTEL (C) COPYRIGHT 2000-2002 '
      WRITE(LU,*) '  BUNDESANSTALT FUER WASSERBAU, KARLSRUHE'
      WRITE(LU,*) ' '
      WRITE(LU,*) '  METIS 4.0.1 (C) COPYRIGHT 1998 '
      WRITE(LU,*) '  REGENTS OF THE UNIVERSITY OF MINNESOTA '
      WRITE(LU,*) ' '
      WRITE(LU,*) '  BIEF 5.9 (C) COPYRIGHT 2008 EDF'
      WRITE(LU,*) '+-------------------------------------------------+'
      WRITE(LU,*) ' '
CJAJ ////
      WRITE(LU,*) '  => THIS IS A PRELIMINARY DEVELOPMENT RELEASE '
      WRITE(LU,*) '     DATED:  TUE JAN 27 11:11:20 CET 2009'
      WRITE(LU,*) ' '
      WRITE(LU,*) '  MAXIMUM NUMBER OF PARTITIONS: ',MAXNPROC
      WRITE(LU,*) ' '
      WRITE(LU,*) '+--------------------------------------------------+'
      WRITE(LU,*) ' '
!
!----------------------------------------------------------------------
C NAMES OF THE INPUT FILES:
!
      DO
        WRITE(LU, ADVANCE='NO', FMT=
     &         '(/,'' SELAFIN INPUT NAME <INPUT_NAME>: '')')
        READ(LI,'(A)') NAMEINP
        IF (NAMEINP.EQ.' ') THEN
          WRITE (LU,'('' NO FILENAME'')')
        ELSE
C=>FABS
          IF (NAMEINP(1:3)=='ES3') THEN
C PARTEL ADAPTED TO ESTEL3D CODE
            CALL PARES3D(NAMEINP,LI)
            GOTO 299
          ELSE
C<=FABS
C CONTINUE WITH TELEMAC CODES
            WRITE(LU,*) 'INPUT: ',NAMEINP
            EXIT
C=>FABS
          ENDIF
C<=FABS
        END IF
      END DO

      INQUIRE (FILE=NAMEINP,EXIST=IS)
      IF (.NOT.IS) THEN
        WRITE (LU,'('' FILE DOES NOT EXIST: '',A30)') NAMEINP
        CALL PLANTE2(-1)
        STOP
      END IF
!
      DO
        WRITE(LU, ADVANCE='NO', FMT=
     &           '(/,'' BOUNDARY CONDITIONS FILE NAME : '')')
        READ(LI,'(A)') NAMECLI
        IF (NAMECLI.EQ.' ') THEN
          WRITE (LU,'('' NO FILENAME'')')
        ELSE
          WRITE(LU,*) 'INPUT: ',NAMECLI
          EXIT
        END IF
      END DO
!
      INQUIRE (FILE=NAMECLI,EXIST=IS)
      IF (.NOT.IS) THEN
        WRITE (LU,'('' FILE DOES NOT EXIST: '',A30)') NAMECLI
        CALL PLANTE2(-1)
        STOP
      END IF
!
      DO
        WRITE(LU, ADVANCE='NO',FMT=
     &    '(/,'' NUMBER OF PARTITIONS <NPARTS> [2 -'',I6,'']: '')')
     &        MAXNPROC
        READ(LI,*) NPARTS
        IF ( (NPARTS > MAXNPROC) .OR. (NPARTS < 2) ) THEN
          WRITE(LU,
     &    '('' NUMBER OF PARTITIONS MUST BE IN [2 -'',I6,'']'')')
     &      MAXNPROC
        ELSE
          WRITE(LU,'('' INPUT: '',I4)') NPARTS
          EXIT
        END IF
      END DO
!
      WRITE(LU,FMT='(/,'' PARTITIONING OPTIONS: '')')
C      WRITE(LU,*) '  1: DUAL  GRAPH',
C     & ' (EACH ELEMENT OF THE MESH BECOMES A VERTEX OF THE GRAPH)'
C      WRITE(LU,*) '  2: NODAL GRAPH',
C     & ' (EACH NODE OF THE MESH BECOMES A VERTEX OF THE GRAPH)'

      DO
        WRITE(LU, ADVANCE='NO',FMT=
     &    '(/,'' PARTITIONING METHOD <PMETHOD> [1 OR 2]: '')')
        READ(LI,*) PMETHOD
        IF ( (PMETHOD > 2) .OR. (PMETHOD < 1) ) THEN
          WRITE(LU,
     &    '('' PARTITIONING METHOD MUST BE 1 OR 2'')')
        ELSE
          WRITE(LU,'('' INPUT: '',I3)') PMETHOD
          EXIT
        END IF
      END DO
!
C #### THE SECTIONS FILE NAME

      DO
        WRITE(LU, ADVANCE='NO',FMT=
     &    '(/,'' WITH SECTIONS? [1:YES 0:NO]: '')')
        READ(LI,*) I
        IF ( I<0 .OR. I>1 ) THEN
          WRITE(LU,
     &    '('' PLEASE ANSWER 1:YES OR 0:NO '')')
        ELSE
          WRITE(LU,'('' INPUT: '',I4)') I
          EXIT
        END IF
      END DO
      IF (I==1) WITH_SECTIONS=.TRUE.


      IF (WITH_SECTIONS) THEN
        DO
          WRITE(LU, ADVANCE='NO', FMT=
     &      '(/,'' CONTROL SECTIONS FILE NAME (OR RETURN) : '')')
          READ(LI,'(A)') NAMESEC
          IF (NAMESEC.EQ.' ') THEN
            WRITE (LU,'('' NO FILENAME '')')
          ELSE
            WRITE(LU,*) 'INPUT: ',NAMESEC
            EXIT
          ENDIF
        END DO
!
        INQUIRE (FILE=NAMESEC,EXIST=IS)
        IF (.NOT.IS) THEN
          WRITE (LU,'('' FILE DOES NOT EXIST: '',A30)') NAMESEC
          CALL PLANTE2(-1)
          STOP
        ENDIF
      ENDIF
!
C FINDS THE INPUT FILE CORE NAME LENGTH
!
      I_S  = LEN(NAMEINP)
      I_SP = I_S + 1
      DO I=1,I_S
        IF (NAMEINP(I_SP-I:I_SP-I) .NE. ' ') EXIT
      ENDDO
      I_LEN=I_SP - I
      I_LENINP = I_LEN
!
      IF (I_LENINP > MAXLENSOFT) THEN
        WRITE(LU,*) ' '
        WRITE(LU,*) 'ATTENTION:'
        WRITE(LU,*) 'THE NAME OF THE INPUT FILE:'
        WRITE(LU,*) NAMEINP
        WRITE(LU,*) 'IS LONGER THAN ',MAXLENSOFT,' CHARACTERS'
        WRITE(LU,*) 'WHICH IS THE LONGEST APPLICABLE NAME FOR TELEMAC '
        WRITE(LU,*) 'INPUT AND OUTPUT FILES. STOPPED. '
        CALL PLANTE2(-1)
        STOP
      ENDIF
!
      NAMEMET = NAMEINP(1:I_LENINP)//'.MET'
!
      OPEN(NINP,FILE=NAMEINP,STATUS='OLD',FORM='UNFORMATTED')
      REWIND NINP
!
!----------------------------------------------------------------------
C STARTS READING THE GEOMETRY OR RESULT FILE
!
!
      READ (NINP) TITLE
      READ (NINP) I, J
      NVAR = I + J

      ALLVAR(1:41) = 'X-COORDINATE----M---,Y-COORDINATE----M---'
      ISTART = 42
!
      WRITE (LU,*) 'VARIABLES ARE: '
      DO I=1,NVAR
        READ(NINP) VARI

        VARIABLE(I) = VARI

        DO J=1,32
          IF(VARI(J:J).EQ.' ') VARI(J:J) = '-'
        END DO
        ISTOP = ISTART+20
        IF (ISTOP.GT.MAXALLVARLENGTH) THEN
          WRITE(LU,*) 'VARIABLE NAMES TOO LONG FOR STRING ALLVAR'
          WRITE(LU,*) 'STOPPED.'
          CALL PLANTE2(-1)
          STOP
        ENDIF
        ALLVAR(ISTART:ISTART) = ','
        ALLVAR(ISTART+1:ISTOP) = VARI
        ISTART=ISTOP+1
      ENDDO
!
C READS THE REST OF THE SELAFIN FILE
C 10 INTEGERS, THE FIRST IS THE NUMBER OF RECORDS (TIMESTEPS)
!
      READ (NINP) (IB(I), I=1,10)
      IF (IB(8).NE.0.OR.IB(9).NE.0) THEN
        WRITE(LU,*) 'THIS IS A PARTIAL OUTPUT FILE'
        WRITE(LU,*) 'MAYBE MEET GRETEL BEFORE...'
      ENDIF
      NREC  = IB(1)
      NPLAN = IB(7)
      IF (IB(10).EQ.1) THEN
        READ(NINP) DATE(1), DATE(2), DATE(3), TIME(1), TIME(2), TIME(3)

      ENDIF
!
      READ (NINP) NELEM,NPOIN,NDP,NDUM
      NPOIN_TOT=NPOIN
      IF (NPLAN.GT.1) THEN
        WRITE(LU,*) ' '
        WRITE(LU,*) '3D MESH DETECTED.'
        NPOIN2 = NPOIN/NPLAN
        NELEM2 = NELEM/(NPLAN-1)
        WRITE(LU,*) 'NDP NODES PER ELEMENT:             ',NDP
        WRITE(LU,*) 'NPLAN NUMBER OF MESH LEVELS:       ',NPLAN
        WRITE(LU,*) 'NPOIN2 NUMBER OF 2D MESH NODES:    ',NPOIN2
        WRITE(LU,*) 'NPOIN NUMBER OF 3D MESH NODES:     ',NPOIN
        WRITE(LU,*) 'NELEM2 NUMBER OF 2D MESH ELEMENTS: ',NELEM2
        WRITE(LU,*) 'NELEM NUMBER OF 3D MESH ELEMENTS:  ',NELEM
        IF (MOD(NPOIN,NPLAN).NE.0) THEN
          WRITE (LU,*) 'BUT NPOIN2 /= NPOIN3/NPLAN!'
          CALL PLANTE2(-1)
          STOP
        ENDIF
        IF (MOD(NELEM,(NPLAN-1)).NE.0) THEN
          WRITE (LU,*) 'BUT NELEM2 /= NELEM3/NPLAN!'
          CALL PLANTE2(-1)
          STOP
        ENDIF
        WRITE(LU,*) ' '
      ELSE
        WRITE(LU,*) ' '
        WRITE(LU,*) 'ONE-LEVEL MESH.'
        WRITE(LU,*) 'NDP NODES PER ELEMENT:         ',NDP
        WRITE(LU,*) 'NPOIN NUMBER OF MESH NODES:    ',NPOIN
        WRITE(LU,*) 'NELEM NUMBER OF MESH ELEMENTS: ',NELEM
        WRITE(LU,*) ' '
        NPOIN2 = NPOIN
        NELEM2 = NELEM
      ENDIF
!
      IF (NDP.EQ.3) THEN
        WRITE(LU,*) 'THE INPUT FILE ASSUMED TO BE 2D SELAFIN'
      ELSEIF (NDP.EQ.6) THEN
        WRITE(LU,*) 'THE INPUT FILE ASSUMED TO BE 3D SELAFIN'
      ELSE
        WRITE(LU,*) 'THE ELEMENTS ARE NEITHER TRIANGLES NOR PRISMS!'
        WRITE(LU,*) 'NDP = ',NDP
        CALL PLANTE2(-1)
        STOP
      ENDIF
!
C NOW LET US ALLOCATE
!
      ALLOCATE (IKLES(NELEM2*3),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IKLES')
      IF(NPLAN.GT.1) THEN
        ALLOCATE (IKLES3D(NELEM*NDP),STAT=ERR)
        IF (ERR.NE.0) CALL ALLOER (LU, 'IKLES3D')
      ENDIF
      ALLOCATE (IRAND(NPOIN),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IRAND')
C     NVAR+2 : FIRST TWO FUNCTIONS ARE X AND Y
C     NPOIN IS 3D HERE IN 3D
      ALLOCATE (F(NPOIN,NVAR+2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'F')
!
C CONNECTIVITY TABLE:
!
      IF(NPLAN.LE.1) THEN
        READ(NINP) ((IKLES((K-1)*NDP+J),J=1,NDP),K=1,NELEM)

      ELSE
        READ(NINP) ((IKLES3D((K-1)*NDP+J),J=1,NDP),K=1,NELEM)
C       BUILDS IKLES
        DO J=1,3
          DO K=1,NELEM2
            IKLES((K-1)*3+J)=IKLES3D((K-1)*6+J)
          ENDDO
        ENDDO
      ENDIF
!
C BOUNDARY NODES INDICATIONS
!
      READ(NINP) (IRAND(J),J=1,NPOIN)
C COMPUTATION OF NPTFR DONE LATER WITH THE BOUNDARY CONDITIONS FILE
C (MODIFICATION BY J-M HERVOUET ON 10/04/02)
C IRAND IS NOT ALWAYS CORRECT AND MAY LEAD TO ERRORS
!
C NUMBER OF BOUNDARY POINTS IN 2D MESH
C      NPTFR = 0
C      DO J=1,NPOIN2
C        IF(IRAND(J).NE.0) NPTFR = NPTFR+1
C      END DO
C      WRITE (LU,*) ' '
C      WRITE (LU,*) 'NPTFR NUMBER OF BOUNDARY NODES IN 2D MESH',NPTFR
C      WRITE (LU,*) ' '
!
C X-, Y-COORDINATES
!
      READ(NINP) (F(J,1),J=1,NPOIN)
      READ(NINP) (F(J,2),J=1,NPOIN)
!
C NOW THE LOOP OVER ALL RECORDS (TIMESTEPS) - FOR AN INITIAL
C CONDITIONS FILE AUTOMATICALLY THE LAST TIME STEP VALUES ARE
C TAKEN (!)
!
      ILOOP = 0
      DO
!
C READS THE TIME STEP
!
        READ(NINP, END=111, ERR=300) TIMES
        ILOOP = ILOOP + 1
!
        TIMED = TIMES/3600
        WRITE(LU,*) 'TIMESTEP: ',TIMES,'S = ',TIMED,'H'
!
C READS THE TIME VARIABLES; NO 1 AND 2 ARE X,Y
!
        DO K=3,NVAR+2
C          WRITE(LU,*) 'NOW READING VARIABLE',K-2
          READ(NINP, END=300, ERR=300) (F(J,K), J=1,NPOIN)
C          WRITE(LU,*) 'READING VARIABLE',K-2,' SUCCESSFUL'
        END DO
      END DO
 111  CLOSE (NINP)
 !     WRITE(LU,*) ' '
 !     WRITE(LU,*) 'THERE HAS BEEN ',ILOOP,' TIME-DEPENDENT RECORDINGS'
 !     WRITE(LU,*) 'ONLY THE LAST ONE TAKEN INTO CONSIDERATION'
 !     WRITE(LU,*) ' '
!
!-----------------------------------------------------------------------
C ...CHECKS IF THE AREA OF THE ELEMENTS IS NEGATIVE...
C ... AREA = 0.5*ABS(X1*Y2 - Y1*X2 + Y1*X3 - X1*Y3 + X2*Y3 - Y2*X3)
C NOTE: AREA AND X1, Y1, X2, Y2, X3, Y3 MUST BE DOUBLE PRECISION
!
C        DO J=1,NELEM
C          X1 = F(IKLES((J-1)*3+1),1)
C          Y1 = F(IKLES((J-1)*3+1),2)
C          X2 = F(IKLES((J-1)*3+2),1)
C          Y2 = F(IKLES((J-1)*3+2),2)
C          X3 = F(IKLES((J-1)*3+3),1)
C          Y3 = F(IKLES((J-1)*3+3),2)
C          AREA = X1*Y2-Y1*X2+Y1*X3-X1*Y3+X2*Y3-Y2*X3
C          IF ( AREA
C            WRITE(LU,*) 'GLOBAL DOMAIN'
C            WRITE(LU,*) 'DETERMINANT OF ELEMENT',J,' IS NEGATIVE'
C            WRITE(LU,*) '(LOCAL NODE ORIENTATION IS CLOCKWISE!)'
C            WRITE(LU,*) 'DET-VALUE: ',AREA
C            WRITE(LU,*) 'NODE NR 1, X1,Y1: ',IKLES((J-1)*3+1),X1,Y1
C            WRITE(LU,*) 'NODE NR 2, X2,Y2: ',IKLES((J-1)*3+2),X2,Y2
C            WRITE(LU,*) 'NODE NR 3, X3,Y3: ',IKLES((J-1)*3+3),X3,Y3
C            CALL PLANTE2(-1)
C            STOP
C          ENDIF
C        END DO
!
!----------------------------------------------------------------------
C READS THE BOUNDARY CONDITIONS FILE
!
C      WRITE(LU,*) ' '
!      WRITE(LU,*) '--------------------------'
C      WRITE(LU,*) '  BC FILE: ',NAMECLI
!      WRITE(LU,*) '--------------------------'
C      WRITE(LU,*) ' '
!
C BUT ALLOCATES FIRST
!
      NPTFRMAX = NPOIN2   ! BETTER IDEA ?
!
      ALLOCATE (LIHBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'LIHBOR')
      ALLOCATE (LIUBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'LIUBOR')
      ALLOCATE (LIVBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'LIVBOR')
      ALLOCATE (HBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'HBOR')
      ALLOCATE (UBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'UBOR')
      ALLOCATE (VBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'VBOR')
      ALLOCATE (AUBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'AUBOR')
      ALLOCATE (TBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'TBOR')
      ALLOCATE (ATBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'ATBOR')
      ALLOCATE (BTBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'BTBOR')
      ALLOCATE (LITBOR(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'LITBOR')
      ALLOCATE (NBOR(2*NPTFRMAX),STAT=ERR)  ! FOR FRONT2
      IF (ERR.NE.0) CALL ALLOER (LU, 'NBOR')
      ALLOCATE (NUMLIQ(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NUMLIQ')
      ALLOCATE (NUMSOL(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NUMSOL')
      ALLOCATE (CHECK(NPTFRMAX),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'CHECK')
!
C CORE NAME LENGTH
!
      I_S  = LEN(NAMECLI)
      I_SP = I_S + 1
      DO I=1,I_S
         IF (NAMECLI(I_SP-I:I_SP-I) .NE. ' ') EXIT
      ENDDO
      I_LEN=I_SP - I
      I_LENCLI = I_LEN
!
      IF (I_LENINP > MAXLENSOFT) THEN
        WRITE(LU,*) ' '
        WRITE(LU,*) 'ATTENTION:'
        WRITE(LU,*) 'THE NAME OF THE BOUNDARY CONDITIONS FILE:'
        WRITE(LU,*) NAMECLI
        WRITE(LU,*) 'IS LONGER THAN ',MAXLENSOFT,' CHARACTERS'
        WRITE(LU,*) 'WHICH IS THE LONGEST APPLICABLE NAME FOR TELEMAC '
        WRITE(LU,*) 'INPUT AND OUTPUT FILES. STOPPED. '
        CALL PLANTE2(-1)
        STOP
      ENDIF
!
      OPEN(NCLI,FILE=NAMECLI,STATUS='OLD',FORM='FORMATTED')
      REWIND NCLI
!
C     READS BOUNDARY FILE AND COUNTS BOUNDARY POINTS
!
      K=1
 900  CONTINUE
      READ(NCLI,*,END=901,ERR=901) LIHBOR(K),LIUBOR(K),
     &                             LIVBOR(K),
     &             HBOR(K),UBOR(K),VBOR(K),AUBOR(K),LITBOR(K),
     &             TBOR(K),ATBOR(K),BTBOR(K),NBOR(K),CHECK(K)
!
C     NOW CHECK IS THE BOUNDARY NODE COLOUR
C     IF(CHECK(K).NE.K) THEN
C       WRITE(LU,*) 'ERROR IN BOUNDARY CONDITIONS FILE AT LINE ',K
C       CALL PLANTE2(-1)
C       STOP
C     ENDIF
      K=K+1
      GOTO 900
 901  CONTINUE
      NPTFR = K-1
C      WRITE (LU,*) ' '
C      WRITE (LU,*) 'NUMBER OF BOUNDARY NODES IN 2D MESH: ',NPTFR
C      WRITE (LU,*) ' '
      CLOSE(NCLI)
!
!----------------------------------------------------------------------
C NUMBERING OF OPEN BOUNDARIES
C NUMBERING OF LIQUID BOUNDARY, IF 0 = SOLID
C OPN: NUMBER OF OPEN BOUNDARY
C IN ORDER TO DO IT IN THE SAME WAY AS TELEMAC DOES,
C IT IS BEST TO CALL FRONT2 HERE
!
C TO CALL BIEF MESH SUBROUTINES
C CAN BE OPTIMISED / USES A LOT OF MEMORY
C THE ONLY REASON IS TO OBTAIN KP1BOR AND NUMLIQ
!
      ALLOCATE (DEJAVU(NPTFR),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'DEJAVU')
      ALLOCATE (KP1BOR(NPTFR,2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'KP1BOR')
!JAJ----------V ////
C     CHANGED NELEM TO NELEM2, NDP TO 3 HUH!
C     CAUSING ERRORS WHEN 3D RESTART/REFERENCE FILES ARE PARTITIONED
C     AND BC FILE IS WRITTEN AGAIN (WHAT FOR, ACTUALLY???)
C     CAUSE: CALLING VOISIN WITH NELEM2 BUT IFABOR(NELEM=NELEM3,NDP=6)
      ALLOCATE (IFABOR(NELEM2,3),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IFABOR')
      ALLOCATE (IFANUM(NELEM2,3),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IFANUM')
      ALLOCATE (IKLBOR(NPTFR,2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IKLBOR')
      ALLOCATE (NELBOR(NPTFR),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NELBOR')
      ALLOCATE (NULONE(NPTFR,2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NULONE')
      ALLOCATE (ISEGF(NPTFR),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'ISEGF')
      ALLOCATE (IKLE(NELEM2,3),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IKLE')
      ALLOCATE (IT1(NPOIN),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IT1')
      ALLOCATE (IT2(NPOIN),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IT2')
      ALLOCATE (IT3(NPOIN),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'IT3')
!
C TRANSFORMS IKLES--> IKLE FOR 2D ROUTINES  (AN OLD TELEMAC DISEASE)
!
      DO I = 1,3
        DO J  = 1,NELEM2
          IKLE(J,I) = IKLES((J-1)*3+I)
        ENDDO
      ENDDO
!
      CALL VOISIN_PARTEL(IFABOR, NELEM2, NELEM2, 11, IKLE, NELEM2,
     &                   NPOIN2, IT1, IT2)
!
C      WRITE(LU,'(/,'' CALLING ELEBD'')')
!
      CALL ELEBD_PARTEL (NELBOR, NULONE, KP1BOR, IFABOR, NBOR, IKLE,
     &                   NELEM2, IKLBOR, NELEM2, NELEM2, NPTFRMAX,
     &                   NPOIN2, NPTFR, 11, LIHBOR, 2, IFANUM,
     &                   1, ISEGF, IT1, IT2, IT3,NPOIN_TOT )
!
C      WRITE(LU,'(/,'' BOUNDARY TYPE NUMBERING USING FRONT2'')')
!
      IF (NAMEINP(1:3)== 'ART') THEN
         OPEN(UNIT=89,FILE='FRONT_GLOB.DAT')
         WRITE(89,*) NPOIN_TOT
         WRITE(89,*) NPTFR
         DO K=1,NPTFR
            WRITE(89,*) NBOR(K)
         END DO
         DO K=1,NPTFR
            WRITE(89,*) KP1BOR(K,1)
         END DO
         DO K=1,NPTFR
            WRITE(89,*) KP1BOR(K,2)
         END DO
         CALL FLUSH(89)
         CLOSE(89)
      END IF
      CALL FRONT2_PARTEL (NFRLIQ,NFRSOL,DEBLIQ,FINLIQ,DEBSOL,FINSOL,
     &             LIHBOR,LIUBOR,F(1:NPOIN2,1),F(1:NPOIN2,2),
     &             NBOR,KP1BOR(1:NPTFR,1),DEJAVU,NPOIN2,NPTFR,
     &             2,.TRUE.,NUMLIQ,NUMSOL,NPTFRMAX)
!
      DEALLOCATE (DEJAVU)
CJAJ //// IFABOR APPLIED LATER FOR FINDING HALO CELL NEIGHBOURHOODS
C!!!      DEALLOCATE (IFABOR)
      DEALLOCATE (IFANUM)
      DEALLOCATE (IKLBOR)
C     DEALLOCATE (NELBOR)
      DEALLOCATE (NULONE)
      DEALLOCATE (ISEGF)
C      DEALLOCATE (IKLE) !JAJ #### NEEDED FOR SECTIONS
      DEALLOCATE (IT1)
      DEALLOCATE (IT2)
      DEALLOCATE (IT3)
C    COMMENTED BY CD

!----------------------------------------------------------------------
C OPENS AND REWRITES METIS SOFTWARE INPUT FILES
C NOT NECESSARY IF VISUALISATION OR MANUAL DECOMPOSITIONS
C ARE NOT REQUIRED
!
C$$$      WRITE(LU,*) ' '
C$$$      WRITE(LU,*) '---------------------------'
C$$$      WRITE(LU,*) ' METIS & PMVIS INPUT FILES '
C$$$      WRITE(LU,*) '---------------------------'
C$$$      WRITE(LU,*) ' '
C$$$!
C$$$      OPEN(NMET,FILE=NAMEMET,STATUS='UNKNOWN',FORM='FORMATTED')
C$$$      REWIND NMET
C$$$      WRITE(LU,*) 'INPUT FILE FOR PARTITIONING: ', NAMEMET
C$$$!
C$$$! THE FIRST LINE IS NOT NECESSARY IN THE LATEST RELEASE
C$$$! WE WRITE THE FILES USING C CONVENTION
C$$$!
C$$$! HERE THE IKLE 2D IS WRITTEN, EVEN IN 3D (HENCE NDP CONSIDERED TO BE 3)
C$$$!
C$$$      WRITE(NMET,*) NELEM2,'1'
C$$$      DO K=1,NELEM2
C$$$        WRITE(NMET,'(3(I7,1X))') (IKLES((K-1)*3+J)-1, J=1,3)
C$$$      END DO
C$$$      CLOSE(NMET)
C$$$!
C WRITES THE NODE COORDINATES FOR VISUALISATION
C A CHECK FIRST...
!
C$$$      WRITE (LU,'(/,'' AS COORDINATES FOR VISUALISATION TAKEN: '')')
C$$$      WRITE (*,'(1X,A20)') ALLVAR(1:20)
C$$$      WRITE (*,'(1X,A20)') ALLVAR(22:41)
C$$$      WRITE (*,'(1X,A20)') ALLVAR(43:62)
!
!======================================================================
C PARTITIONING
!
!

      !======================================================================
C STEP 2 : PARTITIONS THE MESH
!
C OTHER PARTITIONING METHODS SHOULD BE USED (SCOTCH FOR EXAMPLE)
C     ALL PROCESSORS PERFORM THIS TASK TO AVOID COMMUNICATION
C     THE USE OF PARMETIS OR PTSCOTCH COULD BE USED FOR LARGER MESHES
C     IF THERE WILL BE SOME MEMORY ALLOCATION PROBLEM
!======================================================================

      ALLOCATE (EPART(NELEM2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'EPART')
      ALLOCATE (NPART(NPOIN2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NPART')
!
      IF (NDP==3.OR.NDP==6) THEN
         ETYPE = 1
      ELSE
         WRITE(LU,*) 'METIS: IMPLEMENTED FOR TRIANGLES OR PRISMS ONLY'
         CALL PLANTE2(-1)
         STOP
      ENDIF

C WE ONLY USE METIS_PARTMESHDUAL AS ONLY THE FINITE ELEMENTS PARTITION
C     IS RELEVANT HERE.
!
C     IMPORTANT: WE USE FORTRAN-LIKE FIELD ELEMENTS NUMBERING 1...N
C     IN C RELEASE, 0...N-1 NUMBERING IS APPLIED!!!
!
      NUMFLAG = 1
!
      WRITE(LU,*) 'USING ONLY METIS_PARTMESHDUAL SUBROUTINE'

      WRITE(LU,*) ' THE MESH PARTITIONING STEP METIS STARTS'
      IF (TIMECOUNT) THEN
         CALL SYSTEM_CLOCK (COUNT=TEMPS, COUNT_RATE=PARSEC)
         TDEBP = TEMPS
      ENDIF
      CALL METIS_PARTMESHDUAL
     &     (NELEM2, NPOIN2, IKLES, ETYPE, NUMFLAG,
     &     NPARTS, EDGECUT, EPART, NPART)

      WRITE(LU,*) ' THE MESH PARTITIONING STEP HAS FINISHED'
      IF (TIMECOUNT) THEN
        CALL SYSTEM_CLOCK (COUNT=TEMPS, COUNT_RATE=PARSEC)
        TFINP = TEMPS
        WRITE(LU,*) ' RUNTIME OF METIS ',
     &            (1.0*(TFINP-TDEBP))/(1.0*PARSEC),' SECONDS'
      ENDIF


!======================================================================
C STEP 3 : ALLOCATES THE GLOBAL ARRAYS NOT DEPENDING OF THE PARTITION
!
!======================================================================

C      WRITE(LU,*) 'HERE '
C     KNOGL(I) =>  GLOBAL LABEL OF THE LOCAL POINT I
      ALLOCATE (KNOGL(NPOIN2,NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'KNOGL')
      KNOGL(:,:)=0

C     NBRE_EF(I) => NUMBER OF FINITE ELEMENT CONTAINING I
C     I IS A GLOBAL LABEL
      ALLOCATE (NBRE_EF(NPOIN2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NBRE_EF')

      IF(NPLAN.EQ.0) THEN
         ALLOCATE (F_P(NPOIN2,NVAR+2,NPARTS),STAT=ERR)
      ELSE
         ALLOCATE (F_P(NPOIN2,NVAR+2,NPARTS),STAT=ERR)
      ENDIF
      IF (ERR.NE.0) CALL ALLOER (LU, 'F_P')

      ALLOCATE (PART_P(NPOIN2,0:NBMAXNSHARE),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'PART_P')
      PART_P(:,:)=0

      ALLOCATE (CUT_P(NPOIN2,NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'CUT_P')

      ALLOCATE (GELEGL(NELEM2,NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'GELEGL')

      ALLOCATE (SORT(NPOIN2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'CUT_P')

      ALLOCATE (CUT(NPOIN2),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'CUT_P')

      ALLOCATE (NELEM_P(NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NELEM_P')

      ALLOCATE (NPOIN_P(NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NPOIN_P')

      ALLOCATE (NPTFR_P(NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NPTFR_P')

      ALLOCATE (NPTIR_P(NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NPTIR_P')

      ALLOCATE (NHALO(NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NHALO')

      ALLOCATE(TAB_TMP( NBMAXNSHARE),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'TAB_TMP')

      ALLOCATE(IFAPAR(NPARTS,7,NBMAXHALO),STAT=ERR)
         IF (ERR.NE.0) CALL ALLOER (LU, 'IFAPAR')
         IFAPAR(:,:,:)=0

!======================================================================
C STEP 4 : COMPUTES THE NUMBER OF FINITE ELEMENTS AND POINTS
C     BELONGING TO SUBMESH I
!
!======================================================================


C     FIRSTLY, ALL MPI PROCESSES  WORK ON THE WHOLE MESH
!     ----------------------------------------------
!
C     LOOP OVER THE FINITE ELEMENT OF THE MESH
C     TO COMPUTE THE NUMBER OF FINITE ELEMENTS CONTAINING EACH POINT NOEUD
         IF (NAMEINP(1:3) == 'ART') THEN
            DO EF=1,NELEM2
               DO K=1,NDP_2D
                  NOEUD=IKLES((EF-1)*3+K)
                  IF (IRAND(NOEUD) .NE. 0) THEN
                     EPART(EF)=1
                  END IF
               END DO
            END DO
         END IF

         NBRE_EF(:)=0
      DO EF=1,NELEM2
         DO K=1,NDP_2D
            NOEUD=IKLES((EF-1)*3+K)
            NBRE_EF(NOEUD)=NBRE_EF(NOEUD)+1
         END DO
      END DO
      DO I=1,NPARTS



C     LOOP OVER THE FINITE ELEMENT OF THE MESH TO COMPUTE
C     THE NUMBER OF THE FINITE ELEMENT AND POINTS BELONGING
C     TO SUBMESH I

         NELEM_P(I)=0
         NPOIN_P(I)=0
         DO EF=1,NELEM2
            IF (EPART(EF) .EQ. I) THEN
               NELEM_P(I)=NELEM_P(I)+1
               DO K=1,NDP_2D
                  NOEUD=IKLES((EF-1)*3+K)
                  IF (KNOGL(NOEUD,I) .EQ. 0) THEN
                     NPOIN_P(I)=NPOIN_P(I)+1
                     KNOGL(NOEUD,I)=NPOIN_P(I)
                  END IF
               END DO
            END IF
         END DO
      END DO

!======================================================================
C     STEP 4 : ALLOCATES LOCAL ARRAYS NEEDED BY MPI PROCESSUS ID
C              WORKING ON SUBMESH ID+1
!======================================================================
 !     WRITE(LU,*) 'AFTER THE FIRST LOOP'
      MAX_NELEM_P=MAXVAL(NELEM_P)
      MAX_NPOIN_P=MAXVAL(NPOIN_P)


C     ELEGL(E) => GLOBAL LABEL OF THE FINITE ELEMENT E
C     E IS THE LOCAL LABEL ON SUBMESH I
      ALLOCATE (ELELG(MAX_NELEM_P,NPARTS),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'ELELG')
      ELELG(:,:)=0
C     KNOLG(I) => GLOBAL LABEL OF THE POINT I
C     I IS THE LOCAL LABEL ON SUBDOMAIN I
      IF(NPLAN.EQ.0) THEN
         ALLOCATE (KNOLG(MAX_NELEM_P,NPARTS),STAT=ERR)
      ELSE
         ALLOCATE (KNOLG(MAX_NPOIN_P*NPLAN,NPARTS),STAT=ERR)
      ENDIF
      IF (ERR.NE.0) CALL ALLOER (LU, 'KNOLG')
      KNOLG(:,:)=0
C     NBRE_EF_LOC(I) : NUMBER OF FINITE ELEMENTS CONTAINING THE POINT I
C                      ON SUBMESH I
C     I IS THE LOCAL LABEL ON SUBMESH I
      ALLOCATE (NBRE_EF_LOC(MAX_NELEM_P),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'NBRE_EF_LOC')

C     EF_I(E) IS THE GLOBAL LABEL OF THE INTERFACE FINITE ELEMENT NUMBER E
      ALLOCATE (EF_I(MAX_NELEM_P),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'EF_I')
C     EF_II(E) IS THE LOCAL LABEL OF THE INTERFACE FINITE ELEMENT NUMBER E
      ALLOCATE (EF_II(MAX_NELEM_P),STAT=ERR)
      IF (ERR.NE.0) CALL ALLOER (LU, 'EF_II')



!======================================================================
C     STEP 5 : INITIALISES LOCAL ARRAYS
C                  (GELELG AND ELELG, NBRE_EF_LOC)
!
!======================================================================
      DO I=1,NPARTS
         NELEM_P(I)=0
         DO EF=1,NELEM2
            IF (EPART(EF) .EQ. I) THEN
               NELEM_P(I)=NELEM_P(I)+1
               ELELG(NELEM_P(I),I)=EF
               GELEGL(EF,I)=NELEM_P(I)
            END IF
         END DO
         DO J=1,NPOIN_P(I)
            NBRE_EF_LOC(J)=0
         END DO

!======================================================================
C     STEP 5 : COMPUTES THE NUMBER OF BOUNDARY AND INTERFACE POINTS
C              INITIALISES NBRE_EF_LOC AND F_P
!======================================================================

         NPOIN_P(I)=0
         NPTFR_P(I)=0
         NBRE_NOEUD_INTERNE=0
         NBRE_NOEUD_INTERF=0

         DO J=1,NELEM_P(I)
            EF=ELELG(J,I)
            DO K=1,3
               NOEUD=IKLES((EF-1)*3+K)
               NBRE_EF_LOC(KNOGL(NOEUD,I))=
     &              NBRE_EF_LOC(KNOGL(NOEUD,I))+1
               IF (NBRE_EF_LOC(KNOGL(NOEUD,I)) .EQ. 1) THEN
C     THE POINT NOEUD IS ENCOUNTERED FOR THE FIRST TIME
                  NPOIN_P(I)=NPOIN_P(I)+1
C     IS NOEUD A BOUNDARY POINT ?
                  IF (IRAND(NOEUD) .NE. 0) THEN
                     NPTFR_P(I)= NPTFR_P(I)+1
                  END IF
C     MODIFIES KNOGL AND F_P
                  KNOLG(NPOIN_P(I),I)=NOEUD
                  DO L=1,NVAR+2
                     F_P(NPOIN_P(I),L,I)=F(NOEUD,L)
                  END DO
               END IF
!
C     NOEUD IS A INTERNAL POINT IF ALL FINITE ELEMENTS
C     CONTAINING IT BELONGS TO THE SAME SUBMESH
               IF (NBRE_EF_LOC(KNOGL(NOEUD,I)) .EQ. NBRE_EF(NOEUD)) THEN
                  NBRE_NOEUD_INTERNE=NBRE_NOEUD_INTERNE+1
               END IF
            END DO
         END DO

         NBRE_NOEUD_INTERF=NPOIN_P(I)-NBRE_NOEUD_INTERNE
         NPTIR_P(I)=0
C     NUMBER OF NODES AT THE INTERFACE OF SDI
         NBRE_EF_I=0            ! NUMBER OF FINITE ELEMENTS AT THE INTERFACES OF SDI
         DO J=1,NELEM_P(I)      ! GOES THOUGH THE FINITE ELEMENTS OF SDI AGAIN
            INTERFACE=.FALSE.
            EF=ELELG(J,I)
            DO K=1,NDP_2D
               NOEUD=IKLES((EF-1)*3+K)
               IF (ABS(NBRE_EF_LOC(KNOGL(NOEUD,I))) .NE. NBRE_EF(NOEUD))
     &          THEN
                  INTERFACE=.TRUE.
               END IF
               IF (NBRE_EF_LOC(KNOGL(NOEUD,I)) .NE.  NBRE_EF(NOEUD).AND.
     &              NBRE_EF_LOC(KNOGL(NOEUD,I)) .GT. 0) THEN
C     NOEUD IS INTERFACE BECAUSE THERE ARE FINITE ELEMENTS OUTSIDE OF SDI INCLUDING IT
                  INTERFACE=.TRUE.
                  NPTIR_P(I)=NPTIR_P(I)+1
                  CUT_P(NPTIR_P(I),I)=NOEUD
                   PART_P(NOEUD,0)=PART_P(NOEUD,0)+1
                   POS=PART_P(NOEUD,0)
                   IF (POS > NBMAXNSHARE-1) THEN
                     WRITE(LU,*)  'ERROR : AN INTERFACE NODE BELONGS TO
     &                     MORE THAN NBMAXNSHARE-1 SUBDOMAINS'
                      CALL PLANTE2(-1)
                      STOP
                   ENDIF
                   PART_P(NOEUD,POS)=I
                   NBRE_EF_LOC(KNOGL(NOEUD,I))=
     &                  -1*NBRE_EF_LOC(KNOGL(NOEUD,I))
               END IF
            END DO
            IF (INTERFACE .EQV. .TRUE.) THEN
               NBRE_EF_I=NBRE_EF_I+1 ! THE FINITE ELEMENT IS THEREFORE ALSO INTERFACE
               EF_I(NBRE_EF_I)=EF
               EF_II(NBRE_EF_I)=J
            END IF
         END DO

 ! FIRST LOOP TO COMPUTE THE NUMBER OF HALO TO ALLOCATE IFAPAR


C     FILLS IFAPAR
         NHALO(I)=0
         DO J=1,NBRE_EF_I       ! ONLY GOES THRU INTERFACIAL FINITE ELEMENTS TO DETERMINE HALO
            EF=EF_I(J)
            HALO=.FALSE.
            IFALOC(:)=IFABOR(EF,:)



            WHERE (IFALOC .GT. 0)
               IFALOC=EPART(IFALOC)
            END WHERE
            HALO=ANY(IFALOC .GT. 0 .AND. IFALOC .NE. I)
            IF (HALO .EQV. .TRUE.) THEN
               NHALO(I)=NHALO(I)+1
               IF (NHALO(I) > NBMAXHALO) THEN
                  WRITE(LU,*)  'ERROR : NBMAXHALO TOO SMALL'
                  CALL PLANTE2(-1)
                  STOP
               ENDIF
               IFAPAR(I,1,NHALO(I))=EF_II(J)
               IFAPAR(I,2:4,NHALO(I))=IFALOC(:)
               IFAPAR(I,5:7,NHALO(I))=IFABOR(EF_I(J),:)
            END IF
         END DO


                                !
C       WRITE(LU,*) 'SOUS DOMAINE ',I,'NBRE POINTS',NPOIN_P(I),
C     C        'NBRE NOEUD INTE',NBRE_NOEUD_INTERNE,'INTERFACE',
C     C        NPTIR_P(I),'NBRE FRONT',NPTFR_P(I), 'HALO',NHALO(I),
C     C        'NBRE_EFRONT',NBRE_EF_I

C        IF (.NOT. ALLOCATED(NBOR_P)) THEN
C            ALLOCATE(NBOR_P(NPOIN2),STAT=ERR)
C           IF (ERR.NE.0) CALL ALLOER (LU, 'NBOR_P')
C        END IF
      END DO
C      DEALLOCATE(IFABOR)
C      DEALLOCATE(NBRE_EF)
C     DEALLOCATE(NBRE_EF_LOC)
C      DEALLOCATE(EF_I)
C      DEALLOCATE(EF_II)

      MAX_N_NEIGH=MAXVAL(PART_P(:,0))
      IF ( MAX_N_NEIGH > NBMAXNSHARE-1 ) THEN
         WRITE(LU,*) 'SERIOUS WARNING: '
         WRITE(LU,*)
     &        'AN INTERFACE NODE BELONGS TO ',
     &        'MORE THAN NBMAXNSHARE-1 SUBDOMAINS'
         WRITE(LU,*) 'TELEMAC MAY PROTEST!'
      END IF
      IF (MAX_N_NEIGH > MAXNPROC) THEN
         WRITE (LU,*) 'THERE IS A NODE WHICH BELONGS TO MORE THAN ',
     &        MAXNPROC,' PROCESSORS, HOW COME?'
         CALL PLANTE2(-1)
          STOP
       ENDIF
       IF (MAX_N_NEIGH < NBMAXNSHARE-1) MAX_N_NEIGH = NBMAXNSHARE-1

      DO I=1,NPARTS
!-----------------------------------------------------------------------
C THE CORE NAMES FOR THE OUTPUT BC FILES ACCORDING TO THE NUMBER OF PROCS
!
      NAMECLM = NAMECLI    ! CORE NAME LENGTH IS I_LENCLI
      NAMEOUT = NAMEINP    ! CORE NAME LENGTH IS I_LENINP
!
!----------------------------------------------------------------------

!----------------------------------------------------------------------
C     WORKS ON THE BOUNDARIES; WRITES THE BC FILES SIMULTANEOUSLY...
!
         NAMECLM(I_LENCLI+1:I_LENCLI+11) = EXTENS(NPARTS-1,I-1)
C         WRITE (LU,*) 'WORKING ON BC FILE ',NAMECLM

         OPEN(NCLM,FILE=NAMECLM,
     &        STATUS='UNKNOWN',FORM='FORMATTED')
         REWIND(NCLM)
!
C FILE OPENED, NOW WORKS ON BOUNDARIES
! -----------------------------------
!
C THE BOUNDARY NODE WILL BE TAKEN IF IT BELONGS TO THIS SUB-DOMAIN
C J IS THE RUNNING BOUNDARY NODE NUMBER
!
C        NPTIR = 0
         J = 0
!
         DO K=1,NPTFR
!
C BOUNDARY NODES BELONGING TO THIS PARTITION
!
            IF ( KNOGL(NBOR(K),I) /= 0) THEN
               J = J + 1
C               NBOR_P(J) = NBOR(K)
               ISEG = 0
               XSEG = 0.0
               YSEG = 0.0
!
C     IF THE ORIGINAL (GLOBAL) BOUNDARY LEADS FURTHER INTO
C     ANOTHER PARTITION THEN ISEG IS SET NOT EQUAL TO ZERO
C     THE NEXT NODE ALONG THE GLOBAL BOUNDARY HAS IPTFR = M
C     (BUT CHECK THE CASE THE CIRCLE CLOSES)
!
               M = KP1BOR(K,1)
!
C NBOR_P CANNOT BE USED, IT IS NOT FULLY FILLED WITH DATA
!
               ISO = 0
C     MODIFICATION JMH 10/03/2003 : CHECKS IF THE ADJACENT ELEMENT IS
C                                   NOT IN THE SUB-DOMAIN
               IF (EPART(NELBOR(K)).NE.I) THEN
C     THIS WAS A TEST : IF NEXT BOUNDARY POINT NOT IN THE SUB-DOMAIN
C     BUT IT CAN BE IN WHEREAS THE SEGMENT IS NOT.
C     IF ( KNOGL(NBOR(M)) == 0 ) THEN
C                  WRITE(LU,*)
C     &                 'GLOBAL BOUNDARY LEAVES @NODE (#G,#L): ',
C     &                 NBOR(K), KNOGL(NBOR(K),I),
C     &                 ' --> (#G) ', NBOR(M)
!
                  ISEG = NBOR(M)
                  XSEG = F(ISEG,1)
                  YSEG = F(ISEG,2)
C                  NPTIR = NPTIR + 1
C                  CUT(NPTIR) = IRAND_P(KNOGL(NBOR(K)))
                  ISO = ISO + 1
            ENDIF
!
            M = KP1BOR(K,2)
!
C     MODIFICATION JMH 10/03/2003 : SAME AS ABOVE, BUT PREVIOUS SEGMENT ,THUS M, NOT K
            IF (EPART(NELBOR(M)).NE.I) THEN
C     IF ( KNOGL(NBOR(M) ) == 0 ) THEN
C               WRITE(LU,*)
C     &              'GLOBAL BOUNDARY ENTERS @NODE (#G,#L): ',
C     &              NBOR(K), KNOGL(NBOR(K),I),
C     &              '
!
               ISEG = -NBOR(M)
               XSEG = F(-ISEG,1)
               YSEG = F(-ISEG,2)
               ISO = ISO + 1
C               NPTIR = NPTIR + 1
C               CUT(NPTIR) = IRAND_P(KNOGL(NBOR(K)))
            ENDIF
!
C     WHEN BOTH NEIGHBOURS BOUNDARY NODES BELONG TO ANOTHER PARTITION
!
            IF (ISO == 2) THEN
               ISEG = -9999
               ISO = 0
               WRITE(LU,*) 'ISOLATED BOUNDARY POINT',
     &              NBOR(K), KNOGL(NBOR(K),I)
            ENDIF
!
C            NBOR_P(J) = IRAND_P(KNOGL(NBOR(K)))
!
C     WRITES A LINE OF THE FIRST (CLASSICAL) PART OF THE BOUNDARY FILE
C     RE: THE NODE WHICH HAS BEEN RESEARCHED
!
            WRITE (NCLM,4000)
     &           LIHBOR(K), LIUBOR(K), LIVBOR(K),
     &           HBOR(K), UBOR(K), VBOR(K),
     &            AUBOR(K), LITBOR(K), TBOR(K), ATBOR(K), BTBOR(K),
C     JMH 16/06/2008: INITIAL LINE NUMBER OR COLOUR
     &           NBOR(K),CHECK(K), ISEG, XSEG, YSEG, NUMLIQ(K)
C     &            NBOR(K),    J   , ISEG, XSEG, YSEG, NUMLIQ(K)

C     19/10/2007 ER+JMH, RECOMMENDED BY CHARLES MOULINEC
C     BUT XSEG AND YSEG ARE NO LONGER USED
 4000       FORMAT (1X,I2,1X,2(I1,1X),3(F24.12,1X),1X,
     &           F24.12,3X,I1,1X,3(F24.12,1X),1I6,1X,1I6,
     &           1X,I7,1X,2(F27.15,1X),I6)
         ENDIF
!
      END DO

      FMT4='(I6)'
      WRITE (NCLM,*) NPTIR_P(I)
       IF (MAX_N_NEIGH < NBMAXNSHARE-1) MAX_N_NEIGH = NBMAXNSHARE-1
       FMT4='(   (I6,1X))'
       WRITE (FMT4(2:4),'(I3)') MAX_N_NEIGH+1

C SORTS NODE NUMBERS TO SORT(J) SO THAT CUT_P(SORT(J)) IS ORDERED
C CUT IS OVERWRITTEN NOW
!
         DO J=1,NPTIR_P(I)
           CUT(J)=CUT_P(J,I)
         END DO
!
C IF A NODE HAS ALREADY BEEN FOUND AS MIN, CUT(NODE) GETS 0
!
         DO J=1,NPTIR_P(I)
           IDUM = NPOIN2+1  ! LARGEST POSSIBLE NODE NUMBER + 1
           K=0
 401       CONTINUE
           K = K + 1
           IF ( CUT(K) /= 0 .AND. CUT_P(K,I) < IDUM ) THEN
             SORT(J) = K
             IDUM = CUT_P(K,I)
           ENDIF
           IF ( K < NPTIR_P(I) ) THEN
             GOTO 401
           ELSE
             CUT(SORT(J)) = 0
           ENDIF
         END DO
!
         DO J=1,NPTIR_P(I)
            TAB_TMP=0
            L=0
            DO K=1,MAX_N_NEIGH

               IF (PART_P(CUT_P(SORT(J),I),K) .NE. I .AND.
     &        PART_P(CUT_P(SORT(J),I),K) .NE. 0) THEN
                  L=L+1
               TAB_TMP(L)=PART_P(CUT_P(SORT(J),I),K)
            END IF
         END DO
         WRITE(NCLM,FMT=FMT4) CUT_P(SORT(J),I),
     &                  (TAB_TMP(K)-1, K=1,MAX_N_NEIGH)
         END DO
                                 !
         DO J=1,NHALO(I)
            DO M=0,2
               IF (IFAPAR(I,2+M,J)>0) THEN
                  IFAPAR(I,5+M,J)=GELEGL(IFAPAR(I,5+M,J),
     &                 IFAPAR(I,2+M,J))
               END IF
            END DO
         END DO
          DO J=1,NHALO(I)
           DO M=0,2
              IF (IFAPAR(I,2+M,J)>0) THEN
                 IFAPAR(I,2+M,J)=IFAPAR(I,2+M,J)-1
              END IF
           END DO
        END DO

!
      WRITE(NCLM,'(I9)') NHALO(I)
      DO K=1,NHALO(I)
         WRITE (NCLM,'(7(I9,1X))') IFAPAR(I,:,K)
      END DO

      CLOSE(NCLM)
      END DO

      DEALLOCATE(IFAPAR)
      DEALLOCATE(PART_P)
      DEALLOCATE(LIHBOR)
      DEALLOCATE(LIUBOR)
      DEALLOCATE(LIVBOR)
      DEALLOCATE(HBOR)
      DEALLOCATE(UBOR)
      DEALLOCATE(VBOR)
      DEALLOCATE(AUBOR)
      DEALLOCATE(LITBOR)
      DEALLOCATE(TBOR)
      DEALLOCATE(ATBOR)
      DEALLOCATE(BTBOR)
      DEALLOCATE(NBOR)
      DEALLOCATE(NUMLIQ)
      DEALLOCATE(TAB_TMP)
      DEALLOCATE(NUMSOL)
      DEALLOCATE(CHECK)
      DEALLOCATE(GELEGL)
      DEALLOCATE(CUT)
      DEALLOCATE(CUT_P)
      DEALLOCATE(SORT)


      IF (ERR.NE.0) CALL ALLOER (LU, 'F_P')
      ALLOCATE(IKLES_P(MAX_NELEM_P*3),STAT=ERR)
      IF(NPLAN.GT.1) THEN
         ALLOCATE(IKLES3D_P(6,MAX_NELEM_P,NPLAN-1),STAT=ERR)
       ENDIF
      IF (ERR.NE.0) CALL ALLOER (LU, 'IKLES3D_P')
!

      DO I=1,NPARTS
!     ***************************************************************
C     WRITES GEOMETRY FILES FOR ALL PARTS/PROCESSORS
!
      NAMEOUT(I_LENINP+1:I_LENINP+11) = EXTENS(NPARTS-1,I-1)
C      WRITE(LU,*) 'WRITING GEOMETRY FILE: ',NAMEOUT
      OPEN(NOUT,FILE=NAMEOUT,FORM='UNFORMATTED'
     &     ,STATUS='UNKNOWN')

      REWIND(NOUT)
!
C     TITLE, THE NUMBER OF VARIABLES
!
      WRITE(NOUT) TITLE
      WRITE(NOUT) NVAR,0
      DO K=1,NVAR
         WRITE(NOUT) VARIABLE(K)
      END DO
!
C     10 INTEGERS...
C 1.  IS THE NUMBER OF RECORDS IN FILES
C 8.  IS THE NUMBER OF BOUNDARY POINTS (NPTFR_P)
C 9.  IS THE NUMBER OF INTERFACE POINTS (NPTIR_P)
C 10. IS 0 WHEN NO DATE PASSED; 1 IF A DATE/TIME RECORD FOLLOWS
!
C       IB(7) = NPLAN   (ALREADY DONE)
        IB(8) = NPTFR_P(I)
        IB(9) = NPTIR_P(I)
        WRITE(NOUT) (IB(K), K=1,10)
        IF (IB(10).EQ.1) THEN
           WRITE(NOUT) DATE(1), DATE(2), DATE(3),
     &                TIME(1), TIME(2), TIME(3)

        ENDIF

        IF(NPLAN.LE.1) THEN
          WRITE(NOUT) NELEM_P(I), NPOIN_P(I), NDP, NDUM
        ELSE
           WRITE(NOUT) NELEM_P(I)*(NPLAN-1),
     &          NPOIN_P(I)*NPLAN, NDP, NDUM
        ENDIF
!
        DO J=1,NELEM_P(I)
           EF=ELELG(J,I)
           DO K=1,3
              IKLES_P((J-1)*3+K) = KNOGL(IKLES((EF-1)*3+K),I)
           END DO
        END DO
        IF(NPLAN > 1) THEN
           DO K = 1,NPLAN-1
                                  DO J = 1,NELEM_P(I)
                IKLES3D_P(1,J,K) = IKLES_P(1+(J-1)*3) + (K-1)*NPOIN_P(I)
                IKLES3D_P(2,J,K) = IKLES_P(2+(J-1)*3) + (K-1)*NPOIN_P(I)
                IKLES3D_P(3,J,K) = IKLES_P(3+(J-1)*3) + (K-1)*NPOIN_P(I)
                IKLES3D_P(4,J,K) = IKLES_P(1+(J-1)*3) +  K   *NPOIN_P(I)
                IKLES3D_P(5,J,K) = IKLES_P(2+(J-1)*3) +  K   *NPOIN_P(I)
                IKLES3D_P(6,J,K) = IKLES_P(3+(J-1)*3) +  K   *NPOIN_P(I)
              ENDDO
           ENDDO
        ENDIF
!
        IF (NPLAN.EQ.0) THEN
           WRITE(NOUT)
     &          ((IKLES_P((J-1)*3+K),K=1,3),J=1,NELEM_P(I))
        ELSE


           WRITE(NOUT)
     &         (((IKLES3D_P(L,J,K),L=1,6),J=1,NELEM_P(I)),K=1,NPLAN-1)
        ENDIF
!
C INSTEAD OF IRAND, KNOLG IS WRITTEN !!!
C I.E. THE TABLE PROCESSOR-LOCAL -> PROCESSOR-GLOBAL NODE NUMBERS
!
        IF (NPLAN.EQ.0) THEN
          WRITE(NOUT) (KNOLG(J,I), J=1,NPOIN_P(I))
        ELSE
C     BEYOND NPOIN_P(I) : DUMMY VALUES IN KNOLG, NEVER USED
           WRITE(NOUT) (KNOLG(J,I), J=1,NPOIN_P(I)*NPLAN)
        ENDIF
!

C NODE COORDINATES X AND Y
!
        IF (NPLAN.EQ.0) THEN
          WRITE(NOUT) (F_P(J,1,I),J=1,NPOIN_P(I))
          WRITE(NOUT) (F_P(J,2,I),J=1,NPOIN_P(I))
        ELSE


          WRITE(NOUT) ((F(KNOLG(J,I)+(L-1)*NPOIN2,1),J=1,NPOIN_P(I)),
     &          L=1,NPLAN)
          WRITE(NOUT) ((F(KNOLG(J,I)+(L-1)*NPOIN2,2),J=1,NPOIN_P(I)),
     &          L=1,NPLAN)
        ENDIF
!
C TIME STAMP (SECONDS)
!
        WRITE(NOUT) TIMES
!
C NOW THE TIME-DEPENDENT VARIABLES
!
        DO K=3,NVAR+2
          IF(NPLAN.EQ.0) THEN
             WRITE(NOUT) (F_P(J,K,I),J=1,NPOIN_P(I))
          ELSE

             WRITE(NOUT) ((F(KNOLG(J,I)+(L-1)*NPOIN2,K),J=1,NPOIN_P(I)),
     &            L=1,NPLAN)



          ENDIF
        END DO
!
        CLOSE (NOUT)
        WRITE(LU,*) 'FINISHED SUBDOMAIN ',I

      END DO

C CD I HAVE COMMENTED THIS ... AVOIDING MULTIPLE FILES CREATING A BUG ON SGI
!
!======================================================================
C WRITES EPART AND NPART
!
C$$$      CHCH='00000'
C$$$      IF (NPARTS
C$$$        WRITE (CHCH(5:5),'(I1)') NPARTS
C$$$        NAMEEPART=NAMEINP(1:I_LENINP) // '.EPART.' // CHCH(5:5)
C$$$        NAMENPART=NAMEINP(1:I_LENINP) // '.NPART.' // CHCH(5:5)
C$$$      ELSEIF (NPARTS
C$$$        WRITE (CHCH(4:5),'(I2)') NPARTS
C$$$        NAMEEPART=NAMEINP(1:I_LENINP) // '.EPART.' // CHCH(4:5)
C$$$        NAMENPART=NAMEINP(1:I_LENINP) // '.NPART.' // CHCH(4:5)
C$$$      ELSEIF (NPARTS
C$$$        WRITE (CHCH(3:5),'(I3)') NPARTS
C$$$        NAMEEPART=NAMEINP(1:I_LENINP) // '.EPART.' // CHCH(3:5)
C$$$        NAMENPART=NAMEINP(1:I_LENINP) // '.NPART.' // CHCH(3:5)
C$$$      ELSEIF (NPARTS
C$$$        WRITE (CHCH(2:5),'(I4)') NPARTS
C$$$        NAMEEPART=NAMEINP(1:I_LENINP) // '.EPART.' // CHCH(2:5)
C$$$        NAMENPART=NAMEINP(1:I_LENINP) // '.NPART.' // CHCH(2:5)
C$$$      ELSE
C$$$        WRITE (CHCH(1:5),'(I5)') NPARTS
C$$$        NAMEEPART=NAMEINP(1:I_LENINP) // '.EPART.' // CHCH(1:5)
C$$$        NAMENPART=NAMEINP(1:I_LENINP) // '.NPART.' // CHCH(1:5)
C$$$      ENDIF
C$$$!
C$$$      WRITE(LU,*) ' '
C$$$      WRITE(LU,*) '------------------'
C$$$      WRITE(LU,*) ' PARTITION FILES  '
C$$$      WRITE(LU,*) '------------------'
C$$$      WRITE(LU,*) ' '
C$$$!
C$$$      OPEN(NEPART,FILE=NAMEEPART,STATUS='UNKNOWN',FORM='FORMATTED')
C$$$      REWIND NEPART
C$$$      WRITE(LU,*) 'ELEMENT PARTITION FILE: ', NAMEEPART
C$$$!
C$$$      OPEN(NNPART,FILE=NAMENPART,STATUS='UNKNOWN',FORM='FORMATTED')
C$$$      REWIND NNPART
C$$$      WRITE(LU,*) 'NODE PARTITION FILE: ', NAMENPART
C$$$!
C$$$! OUTPUT IS STRICTLY THE SAME AS FROM PARTDNMESH (A C-PROGRAM)
C$$$! THAT'S WHY 1 SUBSTRACTED AND THE FORMATS
C$$$!
C$$$      FMT1 = '(I1)'
C$$$      FMT2 = '(I2)'
C$$$      FMT3 = '(I3)'
C$$$!
C$$$      DO J=1,NELEM2
C$$$         K = EPART(J) - 1
C$$$         IF (K
C$$$           WRITE (NEPART,FMT=FMT1) K
C$$$         ELSEIF (K
C$$$           WRITE (NEPART,FMT=FMT2) K
C$$$         ELSE
C$$$           WRITE (NEPART,FMT=FMT3) K
C$$$         ENDIF
C$$$      END DO
C$$$      CLOSE(NEPART)
C$$$!
C$$$      DO J=1,NPOIN2
C$$$         K = NPART(J) - 1
C$$$         IF (K
C$$$           WRITE (NNPART,FMT=FMT1) K
C$$$         ELSEIF (K
C$$$           WRITE (NNPART,FMT=FMT2) K
C$$$         ELSE
C$$$           WRITE (NNPART,FMT=FMT3) K
C$$$         ENDIF
C$$$      END DO
C$$$      CLOSE(NNPART)

!
C //// JAJ: "LA FINITA COMMEDIA" FOR PARALLEL CHARACTERISTICS, BYE!
!----------------------------------------------------------------------
C !JAJ #### DEALS WITH SECTIONS
!
      IF (NPLAN/=0) WITH_SECTIONS=.FALSE.
      IF (WITH_SECTIONS) THEN ! PRESENTLY, FOR TELEMAC2D, EV. SISYPHE

      WRITE(LU,*) 'DEALING WITH SECTIONS'
      OPEN (NINP,FILE=TRIM(NAMESEC),FORM='FORMATTED',STATUS='OLD')
      READ (NINP,*) ! COMMENT LINE
      READ (NINP,*) NSEC, IHOWSEC
      IF (.NOT.ALLOCATED(CHAIN)) ALLOCATE (CHAIN(NSEC))
      IF (IHOWSEC<0) THEN
        DO ISEC=1,NSEC
          READ (NINP,*) CHAIN(ISEC)%DESCR
          READ (NINP,*) CHAIN(ISEC)%NPAIR(:)
          CHAIN(ISEC)%XYBEG(:)= (/F(CHAIN(ISEC)%NPAIR(1),1),
     &                            F(CHAIN(ISEC)%NPAIR(1),2)/)
          CHAIN(ISEC)%XYEND(:)= (/F(CHAIN(ISEC)%NPAIR(2),1),
     &                            F(CHAIN(ISEC)%NPAIR(2),2)/)
        END DO
      ELSE
        DO ISEC=1,NSEC
          READ (NINP,*) CHAIN(ISEC)%DESCR
          READ (NINP,*) CHAIN(ISEC)%XYBEG(:), CHAIN(ISEC)%XYEND(:)
          CHAIN(ISEC)%NPAIR(:)=0
        END DO
      ENDIF
      CLOSE(NINP)

      ! IF END POINTS ARE GIVEN BY COORDINATES, FINDS NEAREST NODES FIRST

      WRITE(LU,*) 'NPOIN:',NPOIN
      IF (IHOWSEC>=0) THEN
        DO ISEC=1,NSEC
          XA=F(1,1)
          YA=F(1,2)
          DMINB = (CHAIN(ISEC)%XYBEG(1)-XA)**2
     &          + (CHAIN(ISEC)%XYBEG(2)-YA)**2
          DMINE = (CHAIN(ISEC)%XYEND(1)-XA)**2
     &          + (CHAIN(ISEC)%XYEND(2)-YA)**2
          CHAIN(ISEC)%NPAIR(1)=1
          CHAIN(ISEC)%NPAIR(2)=1
          DO I=2,NPOIN ! COMPUTATIONALLY INTENSIVE
            XA=F(I,1)
            YA=F(I,2)
            DISTB = (CHAIN(ISEC)%XYBEG(1)-XA)**2
     &            + (CHAIN(ISEC)%XYBEG(2)-YA)**2
            DISTE = (CHAIN(ISEC)%XYEND(1)-XA)**2
     &            + (CHAIN(ISEC)%XYEND(2)-YA)**2
            IF ( DISTB < DMINB ) THEN
              CHAIN(ISEC)%NPAIR(1)=I
              DMINB=DISTB
            ENDIF
            IF ( DISTE < DMINE ) THEN
              CHAIN(ISEC)%NPAIR(2)=I
              DMINE=DISTE
            ENDIF
          END DO
          WRITE(LU,'(A,3(1X,I9))')
     &          ' -> SECTION, TERMINAL NODES: ',
     &          ISEC, CHAIN(ISEC)%NPAIR(:)
        END DO
      ELSE
        DO ISEC=1,NSEC
          WRITE(LU,'(A,1X,I9,4(1X,1PG13.6))')
     &          ' -> SECTION, TERMINAL COORDINATES: ', ISEC,
     &          CHAIN(ISEC)%XYBEG, CHAIN(ISEC)%XYEND
        END DO
      ENDIF

      WRITE(LU,*) 'NSEC,IHOWSEC: ',NSEC,IHOWSEC
      WRITE(LU,*) 'ANTICIPATED SECTIONS SUMMARY:'
      DO ISEC=1,NSEC
        WRITE(LU,*) CHAIN(ISEC)%DESCR
        WRITE(LU,*) CHAIN(ISEC)%XYBEG(:), CHAIN(ISEC)%XYEND(:)
        WRITE(LU,*) CHAIN(ISEC)%NPAIR(:)
      END DO

C NOW FOLLOWS THE FLUSEC SUBROUTINE IN BIEF TO FIND SECTIONS
C IN THE GLOBAL MESH -> FILLS THE FIELD LISTE

      NCP = 2*NSEC
      ALLOCATE(LISTE(NSEMAX,2),STAT=ERR) ! WORKHORSE
      IF (ERR.NE.0) CALL ALLOER (LU, 'LISTE')

      DO ISEC =1,NSEC

        DEP = CHAIN(ISEC)%NPAIR(1)
        ARR = CHAIN(ISEC)%NPAIR(2)

        PT = DEP
        ISEG = 0
        DIST=(F(DEP,1)-F(ARR,1))**2+(F(DEP,2)-F(ARR,2))**2

 1010   CONTINUE ! A JUMP POINT

        DO IELEM =1,NELEM
          I1 = IKLE(IELEM,1)
          I2 = IKLE(IELEM,2)
          I3 = IKLE(IELEM,3)
          IF (PT.EQ.I1.OR.PT.EQ.I2.OR.PT.EQ.I3) THEN
            DIST1 = (F(I1,1)-F(ARR,1))**2 + (F(I1,2)-F(ARR,2))**2
            DIST2 = (F(I2,1)-F(ARR,1))**2 + (F(I2,2)-F(ARR,2))**2
            DIST3 = (F(I3,1)-F(ARR,1))**2 + (F(I3,2)-F(ARR,2))**2
            IF (DIST1.LT.DIST) THEN
              DIST = DIST1
              ELBEST = IELEM
              IGBEST = I1
              ILBEST = 1
              IF(I1.EQ.PT) ILPREC = 1
              IF(I2.EQ.PT) ILPREC = 2
              IF(I3.EQ.PT) ILPREC = 3
            ENDIF
            IF (DIST2.LT.DIST) THEN
              DIST = DIST2
              ELBEST = IELEM
              IGBEST = I2
              ILBEST = 2
              IF(I1.EQ.PT) ILPREC = 1
              IF(I2.EQ.PT) ILPREC = 2
              IF(I3.EQ.PT) ILPREC = 3
            ENDIF
            IF(DIST3.LT.DIST) THEN
              DIST = DIST3
              ELBEST = IELEM
              IGBEST = I3
              ILBEST = 3
              IF(I1.EQ.PT) ILPREC = 1
              IF(I2.EQ.PT) ILPREC = 2
              IF(I3.EQ.PT) ILPREC = 3
            ENDIF
          ENDIF

        END DO ! OVER ELEMENTS

        IF (IGBEST.EQ.PT) THEN
          WRITE(LU,*)'FLUSEC : ALGORITHM FAILED'
          CALL PLANTE2(-1)
          STOP
        ELSE
          PT = IGBEST
          ISEG = ISEG + 1
          IF (ISEG.GT.NSEMAX) THEN
            WRITE(LU,*) 'TOO MANY SEGMENTS IN A   '
            WRITE(LU,*) 'SECTION. INCREASE  NSEMAX'
            CALL PLANTE2(-1)
            STOP
          ENDIF
          LISTE(ISEG,1) = IKLE(ELBEST,ILPREC)
          LISTE(ISEG,2) = IKLE(ELBEST,ILBEST)
          IF (IGBEST.NE.ARR) GOTO 1010
        ENDIF
        CHAIN(ISEC)%NSEG = ISEG
        ALLOCATE (CHAIN(ISEC)%LISTE(CHAIN(ISEC)%NSEG,3), STAT=ERR)
        IF (ERR/=0) CALL ALLOER (LU, 'CHAIN(ISEC)%LISTE')
        DO ISEG=1,CHAIN(ISEC)%NSEG
          CHAIN(ISEC)%LISTE(ISEG,1)=LISTE(ISEG,1)
          CHAIN(ISEC)%LISTE(ISEG,2)=LISTE(ISEG,2)
          CHAIN(ISEC)%LISTE(ISEG,3)=-1 ! INITIALISES... FOR DEVEL
        END DO
      END DO ! OVER SECTIONS
      DEALLOCATE (LISTE)

C CAN NOW INDICATE THE PARTITIONS THE SECTIONS GO THROUGH
C PROCEED SEGMENT-WISE, USING 2D KNOLG / KNOGL

C      DO I=1,NPOIN
C        WRITE(LU,*) I,KNOGL(I,:)
C      END DO

      ALLOCATE (ANPBEG(NBMAXNSHARE), STAT=ERR)
      IF (ERR/=0) CALL ALLOER (LU, 'ANPBEG')
      ALLOCATE (ANPEND(NBMAXNSHARE), STAT=ERR)
      IF (ERR/=0) CALL ALLOER (LU, 'ANPEND')

      DO ISEC=1,NSEC
        DO ISEG=1,CHAIN(ISEC)%NSEG

          NPBEG=COUNT( KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),:)>0 )
          NPEND=COUNT( KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),:)>0 )

          IF (NPBEG>NBMAXNSHARE .OR. NPEND>NBMAXNSHARE) THEN
            WRITE(LU,*) 'NPBEG OR NPEND: ',NPBEG,NPEND
            WRITE(LU,*) 'ARE LARGER THAN NBMAXNSHARE: ',NBMAXNSHARE
            CALL PLANTE2(-1)
            STOP
          ENDIF

          ! THE NICE AND USUAL CASE WHEN BOTH SEGMENT ENDS
          ! BELONG TO ONE SUBDOMAIN - ONLY ONE POSITION IN KNOGL
          IF ( NPBEG==1 .AND. NPEND==1) THEN
             IM(:) = MAXLOC ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),:) )
             IN(:) = MAXLOC ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),:) )
             IF (IM(1)==IN(1)) THEN
               CHAIN(ISEC)%LISTE(ISEG,3)=IM(1)
             ELSE ! THEY BELONG TO DIFFERENT SUBDOMAINS? HOW COME?
               WRITE(LU,*) 'IMPOSSIBLE CASE (1) BY SECTIONS???'
               CALL PLANTE2(-1)
               STOP
             ENDIF
          ! AT LEAST ONE OF THE END NODES IS ON THE INTERFACE
          ! TAKES THE LARGEST COMMON PARTITION NUMBER THEY BOTH BELONG TO
          ELSE
            IF (NPBEG==1 .AND. NPEND>1) THEN ! THE SEGMENT END TOUCHES THE INTERFACE
              IM(:) = MAXLOC ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),:) )
              IF ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),IM(1))>0 ) THEN
                CHAIN(ISEC)%LISTE(ISEG,3) = IM(1)
              ELSE
                WRITE(LU,*) 'IMPOSSIBLE CASE (2) BY SECTIONS???'
                CALL PLANTE2(-1)
                STOP
              ENDIF
            ELSE IF (NPBEG>1 .AND. NPEND==1) THEN ! THE SEGMENT BEG. TOUCHES THE INTERFACE
              IN(:) = MAXLOC ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),:) )
              IF ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),IN(1))>0 ) THEN
                CHAIN(ISEC)%LISTE(ISEG,3) = IN(1)
              ELSE
                WRITE(LU,*) 'IMPOSSIBLE CASE (3) BY SECTIONS???'
                CALL PLANTE2(-1)
                STOP
              ENDIF
            ELSE ! I.E. (NPBEG>1 .AND. NPEND>1) - LIES JUST ON THE INTERFACE OR "A SHORTCUT"
              ANPBEG=0
              ANPEND=0
              I=0
              DO N=1,NPARTS
                IF ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),N)>0 ) THEN
                  I=I+1
                  ANPBEG(I)=N
                ENDIF
              END DO
              IF (I/=NPBEG) WRITE(LU,*) 'OH! I/=NPBEG'
              I=0
              DO N=1,NPARTS
                IF ( KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),N)>0 ) THEN
                  I=I+1
                  ANPEND(I)=N
                ENDIF
              END DO
              IF (I/=NPEND) WRITE(LU,*) 'OH! I/=NPEND'

              WRITE(LU,*) 'ANPBEG: ',ANPBEG
              WRITE(LU,*) 'ANPEND: ',ANPEND

              FOUND=.FALSE.
              DO I=NPBEG,1,-1
                DO J=NPEND,1,-1
                  IF (ANPBEG(I)==ANPEND(J)) THEN
                     CHAIN(ISEC)%LISTE(ISEG,3) = ANPBEG(I)
                    FOUND=.TRUE.
                    EXIT
                  ENDIF
                END DO
                IF (FOUND) EXIT
              END DO
              IF (.NOT.FOUND) THEN
                WRITE(LU,*) 'BY SECTION WITH NODES: ',
     &            CHAIN(ISEC)%LISTE(ISEG,1),CHAIN(ISEC)%LISTE(ISEG,2)
                WRITE(LU,*) 'IMPOSSIBLE CASE (4) BY SECTIONS???'
                CALL PLANTE2(-1)
                STOP
              ENDIF

            ENDIF
          ENDIF

        END DO
      END DO

      DEALLOCATE (ANPBEG,ANPEND)

C DEVEL PRINTOUT

C      WRITE(LU,*) 'SUMMARY OF SECTION CHAINS PARTITIONING'
C      DO ISEC=1,NSEC
C        WRITE(LU,*) 'ISEC, NSEG: ',ISEC,CHAIN(ISEC)%NSEG
C        WRITE(LU,*) 'DESCR: ',TRIM(CHAIN(ISEC)%DESCR)
C        DO ISEG=1,CHAIN(ISEC)%NSEG
C          WRITE(LU,*) CHAIN(ISEC)%LISTE(ISEG,1),
C     &                CHAIN(ISEC)%LISTE(ISEG,2),
C     &                CHAIN(ISEC)%LISTE(ISEG,3)
C        END DO
C      END DO

C WRITES FILES

      DO N=1,NPARTS
        NAMEOUT=TRIM(NAMESEC)//EXTENS(NPARTS-1,N-1)

        WRITE(LU,*) 'WRITING: ', TRIM(NAMEOUT)

        OPEN (NOUT,FILE=TRIM(NAMEOUT),FORM='FORMATTED',STATUS='UNKNOWN')
        REWIND(NOUT)
        WRITE(NOUT,*) '# SECTIONS PARTITIONED FOR ',EXTENS(NPARTS-1,N-1)
        WRITE(NOUT,*) NSEC, 1
        DO ISEC=1,NSEC
          WRITE(NOUT,*) TRIM(CHAIN(ISEC)%DESCR)
          I=COUNT(CHAIN(ISEC)%LISTE(:,3)==N)
          WRITE(NOUT,*) I
          DO ISEG=1,CHAIN(ISEC)%NSEG
            IF (CHAIN(ISEC)%LISTE(ISEG,3)==N) THEN
              WRITE(NOUT,*)
     &          KNOGL(CHAIN(ISEC)%LISTE(ISEG,1),N),
     &          KNOGL(CHAIN(ISEC)%LISTE(ISEG,2),N)
            ENDIF
          END DO
        END DO
        CLOSE(NOUT)
      END DO

      WRITE(LU,*) 'FINISHED DEALING WITH SECTIONS'
      ENDIF ! NPLAN==0
!
!----------------------------------------------------------------------
!
C     NOTE BY J-M HERVOUET : DEALLOCATE CAUSES ERRORS ON HP
C     (POSSIBLE REMAINING BUG ?)
C     NOTE BY JAJ: DEALLOCATE(HP) ,^)
!
       DEALLOCATE (IKLE) ! #### MOVED FROM FAR ABOVE
       DEALLOCATE(NPART)
       DEALLOCATE(EPART)
       DEALLOCATE(NPOIN_P)
       DEALLOCATE(NELEM_P)
       DEALLOCATE(NPTFR_P)
       DEALLOCATE(NPTIR_P)
!
       DEALLOCATE(IKLES)
      IF(NPLAN.GT.1) THEN
         DEALLOCATE(IKLES3D)
         DEALLOCATE(IKLES3D_P)
      ENDIF
      DEALLOCATE(IKLES_P)
      DEALLOCATE(IRAND)
      DEALLOCATE(F)
      DEALLOCATE(F_P)

      DEALLOCATE(KNOLG)
      DEALLOCATE(KNOGL)
      DEALLOCATE(ELELG)
      DEALLOCATE(KP1BOR)

!
!----------------------------------------------------------------------
!
 299  IF (TIMECOUNT) THEN
        CALL SYSTEM_CLOCK (COUNT=TEMPS, COUNT_RATE=PARSEC)
        TFIN = TEMPS
        WRITE(LU,*) 'OVERALL TIMING: ',
     &    (1.0*(TFIN-TDEB))/(1.0*PARSEC),' SECONDS'
        WRITE(LU,*) ' '
      ENDIF
      WRITE(LU,*) '+---- PARTEL: NORMAL TERMINATION ----+'
      WRITE(LU,*) ' '
!
      GO TO 999

 300  WRITE(LU,*) 'ERROR BY READING. '
      CALL PLANTE2(-1)

 999  STOP
      END PROGRAM PARTEL



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       {text}

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> CHFILE, N
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>GREDELHYD(), GREDELMET(), GREDELPTS(), GREDELSEG(), PARES3D(), RECOMPOSITION_DECOMP_DOMAINE(), RECOMPOSITION_PARTICULAIRE()

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
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>CHFILE
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>N
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
      SUBROUTINE ALLOER (N, CHFILE)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| CHFILE         |---| 
C| N             |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: N
      CHARACTER*(*), INTENT(IN) :: CHFILE
      WRITE(N,*) 'ERROR BY ALLOCATION OF ',CHFILE
      CALL PLANTE2(-1)
      STOP
      END SUBROUTINE ALLOER



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       {text}

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> CHFILE, N
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>PARES3D()

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
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>CHFILE
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>N
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
      SUBROUTINE ALLOER2(N,CHFILE)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| CHFILE         |---| 
C| N             |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: N
      CHARACTER*(*), INTENT(IN) :: CHFILE
      WRITE(N,*)TRIM(CHFILE)
      CALL PLANTE2(-1)
      STOP
      END SUBROUTINE ALLOER2



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       {text}

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IVAL
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> ICODE
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Unknown(s)
!>    </th><td> EXIT
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>ALLOER(), ALLOER2(), ELEBD31_PARTEL(), ELEBD_PARTEL(), FRONT2_PARTEL(), PARES3D(), VOISIN31_PARTEL(), VOISIN_PARTEL()

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
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>IVAL
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
      SUBROUTINE PLANTE2 (IVAL)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| IVAL           |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: IVAL
      INTEGER ICODE
      IF (IVAL < 0) THEN ! THIS INDICATES A CONTROLLED ERROR
        ICODE = 1
      ELSE IF (IVAL==0) THEN  ! THIS INDICATES A PROGRAM FAILURE
        ICODE = -1
      ELSE                    ! THIS INDICATES A NORMAL STOP
        ICODE = 0
      ENDIF
      !!! WRITE(*,*) 'RETURNING EXIT CODE: ', ICODE
      CALL EXIT(ICODE)
      STOP    ! WHICH IS USUALLY EQUIVALENT TO CALL EXIT(0)
      END SUBROUTINE PLANTE2



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       EXTENSION OF THE FILES ON EACH PROCESSOR.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IPID, N
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>BIEF_OPEN_FILES(), DREDGESIM_INTERFACE(), GREDELHYD(), GREDELMET(), GREDELPTS(), GREDELSEG(), RECOMPOSITION_DECOMP_DOMAINE(), RECOMPOSITION_PARTICULAIRE()

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
!>  <tr>
!>    <th> 4.0                                                     </th>
!>    <th> 08/01/1997                                              </th>
!>    <th> J-M HERVOUET (LNH)                                      </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>IPID
!></td><td>--></td><td>NUMERO DU PROCESSEUR
!>    </td></tr>
!>          <tr><td>N
!></td><td>--></td><td>NOMBRE DE PROCESSEURS MOINS UN = NCSIZE-1
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        CHARACTER(LEN=11) FUNCTION EXTENS
     &(N,IPID)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| IPID           |-->| NUMERO DU PROCESSEUR
C| N             |-->| NOMBRE DE PROCESSEURS MOINS UN = NCSIZE-1
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INTEGER IPID,N
C
C-----------------------------------------------------------------------
C
      IF(N.GT.0) THEN
C
        EXTENS='00000-00000'
C
        IF(N.LT.10) THEN
          WRITE(EXTENS(05:05),'(I1)') N
        ELSEIF(N.LT.100) THEN
          WRITE(EXTENS(04:05),'(I2)') N
        ELSEIF(N.LT.1000) THEN
          WRITE(EXTENS(03:05),'(I3)') N
        ELSEIF(N.LT.10000) THEN
          WRITE(EXTENS(02:05),'(I4)') N
        ELSE
          WRITE(EXTENS(01:05),'(I5)') N
        ENDIF
C
        IF(IPID.LT.10) THEN
          WRITE(EXTENS(11:11),'(I1)') IPID
        ELSEIF(IPID.LT.100) THEN
          WRITE(EXTENS(10:11),'(I2)') IPID
        ELSEIF(IPID.LT.1000) THEN
          WRITE(EXTENS(09:11),'(I3)') IPID
        ELSEIF(IPID.LT.10000) THEN
          WRITE(EXTENS(08:11),'(I4)') IPID
        ELSE
          WRITE(EXTENS(07:11),'(I5)') IPID
        ENDIF
C
      ELSE
C
        EXTENS='       '
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
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       LOCATES AND NUMBERS THE LIQUID AND SOLID BOUNDARIES.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @warning  SOLID BOUNDARIES ARE IDENTIFIED BY LIHBOR(K) = KLOG
!>            FOR A BOUNDARY NODE WITH NUMBER K.
!>            A SEGMENT BETWEEN A LIQUID NODE AND A SOLID NODE IS
!>            CONSIDERED SOLID

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> DEBLIQ, DEBSOL, DEJAVU, FINLIQ, FINSOL, KLOG, KP1BOR, LIHBOR, LISTIN, LIUBOR, NBOR, NFRLIQ, NFRSOL, NPOIN, NPTFR, NPTFRMAX, NUMLIQ, NUMSOL, X, Y
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> EPS, IDEP, K, KPREV, L1, L2, L3, LIQ1, LIQD, LIQF, MAXNS, MINNS, NILE, NS, SOL1, SOLD, SOLF, YMIN
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

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
!>  <tr>
!>    <th> 5.5                                                     </th>
!>    <th> 04/05/2004                                              </th>
!>    <th> J-M HERVOUET (LNH)                                      </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>DEBLIQ
!></td><td><--</td><td>DEBUTS DES FRONTIERES LIQUIDES
!>    </td></tr>
!>          <tr><td>DEBSOL
!></td><td><--</td><td>DEBUTS DES FRONTIERES SOLIDES
!>    </td></tr>
!>          <tr><td>DEJAVU
!></td><td>---</td><td>TABLEAU DE TRAVAIL
!>    </td></tr>
!>          <tr><td>FINLIQ
!></td><td><--</td><td>FINS DES FRONTIERES LIQUIDES
!>    </td></tr>
!>          <tr><td>FINSOL
!></td><td><--</td><td>FINS DES FRONTIERES SOLIDES
!>    </td></tr>
!>          <tr><td>KLOG
!></td><td>--></td><td>LIHBOR(K)=KLOG : FRONTIERE SOLIDE
!>    </td></tr>
!>          <tr><td>KP1BOR
!></td><td>--></td><td>NUMEROS DES EXTREMITES DES SEGMENTS DE BORD
!>                  DANS LA NUMEROTATION DES POINTS DE BORD
!>    </td></tr>
!>          <tr><td>LIHBOR
!></td><td>--></td><td>CONDITIONS AUX LIMITES SUR H
!>    </td></tr>
!>          <tr><td>LISTIN
!></td><td>--></td><td>IMPRESSIONS SUR LISTING (OU NON)
!>    </td></tr>
!>          <tr><td>LIUBOR
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NBOR
!></td><td>--></td><td>NUMEROS GLOBAUX DES POINTS DE BORD
!>    </td></tr>
!>          <tr><td>NFRLIQ
!></td><td><--</td><td>NOMBRE DE FRONTIERES LIQUIDES
!>    </td></tr>
!>          <tr><td>NFRSOL
!></td><td><--</td><td>NOMBRE DE FRONTIERES SOLIDES
!>    </td></tr>
!>          <tr><td>NPOIN
!></td><td>--></td><td>NOMBRE DE POINTS DU MAILLAGE
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>--></td><td>NOMBRE DE POINTS FRONTIERE
!>    </td></tr>
!>          <tr><td>NPTFRMAX
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NUMLIQ
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NUMSOL
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>X , Y
!></td><td>--></td><td>COORDONNEES DU MAILLAGE.
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE FRONT2_PARTEL
     &(NFRLIQ,NFRSOL,DEBLIQ,FINLIQ,DEBSOL,FINSOL,LIHBOR,LIUBOR,
     & X,Y,NBOR,KP1BOR,DEJAVU,NPOIN,NPTFR,KLOG,LISTIN,NUMLIQ,NUMSOL,
     & NPTFRMAX)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| DEBLIQ         |<--| DEBUTS DES FRONTIERES LIQUIDES
C| DEBSOL         |<--| DEBUTS DES FRONTIERES SOLIDES
C| DEJAVU         |---| TABLEAU DE TRAVAIL
C| FINLIQ         |<--| FINS DES FRONTIERES LIQUIDES
C| FINSOL         |<--| FINS DES FRONTIERES SOLIDES
C| KLOG           |-->| LIHBOR(K)=KLOG : FRONTIERE SOLIDE
C| KP1BOR         |-->| NUMEROS DES EXTREMITES DES SEGMENTS DE BORD
C|                |   | DANS LA NUMEROTATION DES POINTS DE BORD
C| LIHBOR         |-->| CONDITIONS AUX LIMITES SUR H
C| LISTIN         |-->| IMPRESSIONS SUR LISTING (OU NON)
C| LIUBOR         |---| 
C| NBOR           |-->| NUMEROS GLOBAUX DES POINTS DE BORD
C| NFRLIQ         |<--| NOMBRE DE FRONTIERES LIQUIDES
C| NFRSOL         |<--| NOMBRE DE FRONTIERES SOLIDES
C| NPOIN          |-->| NOMBRE DE POINTS DU MAILLAGE
C| NPTFR          |-->| NOMBRE DE POINTS FRONTIERE
C| NPTFRMAX       |---| 
C| NUMLIQ         |---| 
C| NUMSOL         |---| 
C| X , Y          |-->| COORDONNEES DU MAILLAGE.
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER, INTENT(IN) :: NPOIN,NPTFR,KLOG,NPTFRMAX
      INTEGER, INTENT(OUT) :: NFRLIQ,NFRSOL
C                                    *=MAXFRO (300 IN TELEMAC-2D)
      INTEGER, INTENT(OUT) :: DEBLIQ(*),FINLIQ(*),DEBSOL(*),FINSOL(*)
CCCCCCMOULINEC BEGIN
      INTEGER , INTENT(IN) :: LIHBOR(NPTFRMAX),LIUBOR(NPTFRMAX)
C      INTEGER , INTENT(IN) :: LIHBOR(NPTFR),LIUBOR(NPTFR)
CCCCCCMOULINEC END
      REAL, INTENT(IN) :: X(NPOIN) , Y(NPOIN)
CCCCCCMOULINEC BEGIN
      INTEGER, INTENT(IN) :: NBOR(2*NPTFRMAX),KP1BOR(NPTFR)
C      INTEGER, INTENT(IN) :: NBOR(NPTFR),KP1BOR(NPTFR)
CCCCCCMOULINEC END
      INTEGER, INTENT(OUT) :: DEJAVU(NPTFR)
      LOGICAL, INTENT(IN) :: LISTIN
CCCCCCMOULINEC BEGIN
      INTEGER, INTENT(OUT) :: NUMLIQ(NPTFRMAX)
      INTEGER, INTENT(OUT) :: NUMSOL(NPTFRMAX)
C      INTEGER, INTENT(OUT) :: NUMLIQ(NPTFR)
C      INTEGER, INTENT(OUT) :: NUMSOL(NPTFR)
CCCCCCMOULINEC END
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER K,KPREV,IDEP,SOL1,LIQ1,L1,L2,L3,NILE
C
      LOGICAL SOLF,LIQF,SOLD,LIQD
C
      REAL MINNS,MAXNS,EPS,YMIN,NS
C
      INTRINSIC ABS
C
C-----------------------------------------------------------------------
C
C  INITIALISES
C
C  DEJAVU : THE NODES THAT HAVE ALREADY BEEN TREATED ARE MARKED WITH 1
C  NILE   : NUMBER OF ISLANDS
C
      DO 10 K=1,NPTFR
        DEJAVU(K) = 0
        NUMLIQ(K) = 0
        NUMSOL(K) = 0
10    CONTINUE
C
      NILE = 0
      IDEP = 1
      NFRLIQ = 0
      NFRSOL = 0
C
C-----------------------------------------------------------------------
C
C  WILL GO TO LABEL 20 IF THERE IS AT LEAST ONE ISLAND
C
20    CONTINUE
C
C  LOOKS FOR THE SOUTH-WESTERNMOST NODE (CAN EXIST MORE THAN ONE)
C
      MINNS = X(NBOR(IDEP)) + Y(NBOR(IDEP))
      MAXNS = MINNS
      YMIN  = Y(NBOR(IDEP))
C
      DO 30 K = 1 , NPTFR
      IF(DEJAVU(K).EQ.0) THEN
        NS = X(NBOR(K)) + Y(NBOR(K))
        IF(NS.LT.MINNS) THEN
         IDEP = K
         MINNS = NS
         YMIN = Y(NBOR(K))
        ENDIF
        IF(NS.GT.MAXNS) MAXNS = NS
      ENDIF
30    CONTINUE
C
      EPS = (MAXNS-MINNS) * 1.D-4
C
C  SELECTS THE SOUTHERNMOST NODE FROM THE SOUTH-WESTERNMOST CANDIDATES
C
      DO 40 K = 1 , NPTFR
      IF(DEJAVU(K).EQ.0) THEN
        NS = X(NBOR(K)) + Y(NBOR(K))
        IF(ABS(MINNS-NS).LT.EPS) THEN
          IF(Y(NBOR(K)).LT.YMIN) THEN
           IDEP = K
           YMIN = Y(NBOR(K))
          ENDIF
        ENDIF
      ENDIF
40    CONTINUE
C
C-----------------------------------------------------------------------
C
C  NUMBERS AND LOCATES THE DOMAIN BOUNDARIES, STARTING
C  AT POINT IDEP
C
C  SOLD = .TRUE. : THE FIRST BOUNDARY SEGMENT (FROM IDEP) IS SOLID
C  LIQD = .TRUE. : THE FIRST BOUNDARY SEGMENT (FROM IDEP) IS LIQUID
C  SOLF = .TRUE. : THE LAST BOUNDARY SEGMENT (TO IDEP) IS SOLID
C  LIQF = .TRUE. : THE LAST BOUNDARY SEGMENT (TO IDEP) IS LIQUID
C  LIQ1 : NUMBER OF THE 1ST LIQUID BOUNDARY
C  SOL1 : NUMBER OF THE 1ST SOLID BOUNDARY
C
      K = IDEP
C
      SOL1 = 0
      LIQ1 = 0
      LIQF = .FALSE.
      SOLF = .FALSE.
C
C NATURE OF THE FIRST SEGMENT
C
C     PREDOMINANCE OF SOLID OVER LIQUID BOUNDARY
      IF(LIHBOR(K).EQ.KLOG.OR.LIHBOR(KP1BOR(K)).EQ.KLOG) THEN
C       THE FIRST SEGMENT IS SOLID
        NFRSOL = NFRSOL + 1
        SOL1 = NFRSOL
        SOLD = .TRUE.
        LIQD = .FALSE.
      ELSE
C       THE FIRST SEGMENT IS LIQUID
        NFRLIQ = NFRLIQ + 1
        LIQ1 = NFRLIQ
        LIQD = .TRUE.
        SOLD = .FALSE.
      ENDIF
C
      DEJAVU(K) = 1
      KPREV = K
      K = KP1BOR(K)
C
50    CONTINUE
C
C LOOKS FOR TRANSITION POINTS, FROM THE POINT FOLLOWING IDEB
C
C ALSO LOOKS FOR ISOLATED POINTS TO DETECT ERRORS IN THE DATA
C
C
      L1 = LIHBOR(KPREV)
      L2 = LIHBOR(K)
      L3 = LIHBOR(KP1BOR(K))
C
      IF(L1.EQ.KLOG.AND.L2.NE.KLOG.AND.L3.NE.KLOG) THEN
C     SOLID-LIQUID TRANSITION AT POINT K
        NFRLIQ = NFRLIQ + 1
        FINSOL(NFRSOL) = K
        DEBLIQ(NFRLIQ) = K
        LIQF = .TRUE.
        SOLF = .FALSE.
      ELSEIF(L1.NE.KLOG.AND.L2.NE.KLOG.AND.L3.EQ.KLOG) THEN
C     LIQUID-SOLID TRANSITION AT POINT K
        NFRSOL = NFRSOL + 1
        FINLIQ(NFRLIQ) = K
        DEBSOL(NFRSOL) = K
        LIQF = .FALSE.
        SOLF = .TRUE.
      ELSEIF(L1.NE.KLOG.AND.L2.NE.KLOG.AND.L3.NE.KLOG) THEN
C     LIQUID-LIQUID TRANSITION AT POINT K
        IF(L2.NE.L3.OR.LIUBOR(K).NE.LIUBOR(KP1BOR(K))) THEN
          FINLIQ(NFRLIQ) = K
          NFRLIQ = NFRLIQ + 1
          DEBLIQ(NFRLIQ) = KP1BOR(K)
        ENDIF
      ELSEIF(L1.EQ.KLOG.AND.L2.NE.KLOG.AND.L3.EQ.KLOG) THEN
C     ERROR IN THE DATA
        IF(LNG.EQ.1) WRITE(LU,102) K
        IF(LNG.EQ.2) WRITE(LU,103) K
        CALL PLANTE2(-1)
        STOP
      ELSEIF(L1.NE.KLOG.AND.L2.EQ.KLOG.AND.L3.NE.KLOG) THEN
C     ERROR IN THE DATA
        IF(LNG.EQ.1) WRITE(LU,104) K
        IF(LNG.EQ.2) WRITE(LU,105) K
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
      DEJAVU(K) = 1
      KPREV = K
      K = KP1BOR(K)
      IF(K.NE.IDEP) GO TO 50
C
C  CHANGE OF BOUNDARY TYPE AT STARTING POINT IDEP
C
      IF(SOLF) THEN
C       THE LAST BOUNDARY WAS SOLID
        IF(SOLD) THEN
C         THE FIRST BOUNDARY WAS SOLID
          DEBSOL(SOL1) = DEBSOL(NFRSOL)
          NFRSOL = NFRSOL - 1
        ELSEIF(LIQD) THEN
C         THE FIRST BOUNDARY WAS LIQUID
          DEBLIQ(LIQ1) = IDEP
          FINSOL(NFRSOL) = IDEP
        ENDIF
C
      ELSEIF(LIQF) THEN
C       THE LAST BOUNDARY OF CONTOUR WAS LIQUID
        IF(LIQD) THEN
C         THE FIRST BOUNDARY OF CONTOUR WAS LIQUID
          DEBLIQ(LIQ1) = DEBLIQ(NFRLIQ)
          NFRLIQ = NFRLIQ - 1
        ELSEIF(SOLD) THEN
C         THE FIRST BOUNDARY OF CONTOUR WAS SOLID
          DEBSOL(SOL1) = IDEP
          FINLIQ(NFRLIQ) = IDEP
        ENDIF
C
      ELSE
C     CASE WHERE THE WHOLE CONTOUR HAS THE SAME TYPE
        IF(SOL1.NE.0) THEN
          DEBSOL(SOL1) = IDEP
          FINSOL(SOL1) = IDEP
        ELSEIF(LIQ1.NE.0) THEN
          DEBLIQ(LIQ1) = IDEP
          FINLIQ(LIQ1) = IDEP
        ELSE
          IF(LISTIN.AND.LNG.EQ.1) THEN
           WRITE(LU,'(1X,A)') 'CAS IMPOSSIBLE DANS FRONT2'
          ENDIF
          IF(LISTIN.AND.LNG.EQ.2) THEN
           WRITE(LU,'(1X,A)') 'IMPOSSIBLE CASE IN FRONT2'
          ENDIF
          CALL PLANTE2(-1)
          STOP
        ENDIF
      ENDIF
C
C-----------------------------------------------------------------------
C
C  IDENTIFIES REMAINING CONTOURS
C
      DO 60 K = 1 , NPTFR
        IF(DEJAVU(K).EQ.0) THEN
          IDEP = K
          NILE = NILE + 1
          GO TO 20
        ENDIF
60    CONTINUE
C
C-----------------------------------------------------------------------
C
      DO 79 K=1,NPTFR
        NUMLIQ(K)=0
79    CONTINUE
C
C  WRITES OUT THE RESULTS AND COMPUTES NUMLIQ
C
      IF(NILE.NE.0.AND.LISTIN.AND.LNG.EQ.1) WRITE(LU,69) NILE
      IF(NILE.NE.0.AND.LISTIN.AND.LNG.EQ.2) WRITE(LU,169) NILE
C
      IF(NFRLIQ.NE.0) THEN
        IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,70) NFRLIQ
        IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,170) NFRLIQ

        DO 80 K = 1, NFRLIQ
C
C  LIQUID BOUNDARIES ARE NUMBERED
C
          L1=DEBLIQ(K)
          NUMLIQ(L1)=K
707       L1=KP1BOR(L1)
          NUMLIQ(L1)=K
          IF(L1.NE.FINLIQ(K)) GO TO 707
C
C  END OF MARKING / NUMBERING
C
          IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,90)
     &                            K,DEBLIQ(K),NBOR(DEBLIQ(K)),
     &                            X(NBOR(DEBLIQ(K))),Y(NBOR(DEBLIQ(K))),
     &                            FINLIQ(K),NBOR(FINLIQ(K)),
     &                            X(NBOR(FINLIQ(K))),Y(NBOR(FINLIQ(K)))
          IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,190)
     &                            K,DEBLIQ(K),NBOR(DEBLIQ(K)),
     &                            X(NBOR(DEBLIQ(K))),Y(NBOR(DEBLIQ(K))),
     &                            FINLIQ(K),NBOR(FINLIQ(K)),
     &                            X(NBOR(FINLIQ(K))),Y(NBOR(FINLIQ(K)))
80      CONTINUE
      ENDIF
C
      IF(NFRSOL.NE.0) THEN
        IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,100) NFRSOL
        IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,101) NFRSOL

        DO 110 K = 1, NFRSOL
!
C  MARKS SOLID BOUNDARIES (WHY NOT?)
C  THEY GET NEXT BOUNDARY NUMBERS
!
          L1=DEBSOL(K)
          NUMSOL(L1)=K+NFRLIQ
708       L1=KP1BOR(L1)
          NUMSOL(L1)=K+NFRLIQ
          IF(L1.NE.FINSOL(K)) GO TO 708
!
C  END OD FMARKING
!
          IF(LISTIN.AND.LNG.EQ.1) WRITE(LU,90)
     &                            K,DEBSOL(K),NBOR(DEBSOL(K)),
     &                            X(NBOR(DEBSOL(K))),Y(NBOR(DEBSOL(K))),
     &                            FINSOL(K),NBOR(FINSOL(K)),
     &                            X(NBOR(FINSOL(K))),Y(NBOR(FINSOL(K)))
          IF(LISTIN.AND.LNG.EQ.2) WRITE(LU,190)
     &                            K,DEBSOL(K),NBOR(DEBSOL(K)),
     &                            X(NBOR(DEBSOL(K))),Y(NBOR(DEBSOL(K))),
     &                            FINSOL(K),NBOR(FINSOL(K)),
     &                            X(NBOR(FINSOL(K))),Y(NBOR(FINSOL(K)))
110     CONTINUE
      ENDIF
C
C-----------------------------------------------------------------------
C
C  FORMATS
C
69    FORMAT(/,1X,'IL Y A ',1I3,' ILE(S) DANS LE DOMAINE')
169   FORMAT(/,1X,'THERE IS ',1I3,' ISLAND(S) IN THE DOMAIN')
70    FORMAT(/,1X,'IL Y A ',1I3,' FRONTIERE(S) LIQUIDE(S) :')
170   FORMAT(/,1X,'THERE IS ',1I3,' LIQUID BOUNDARIES:')
100   FORMAT(/,1X,'IL Y A ',1I3,' FRONTIERE(S) SOLIDE(S) :')
101   FORMAT(/,1X,'THERE IS ',1I3,' SOLID BOUNDARIES:')
102   FORMAT(/,1X,'FRONT2 : ERREUR AU POINT DE BORD ',1I5,
     &       /,1X,'         POINT LIQUIDE ENTRE DEUX POINTS SOLIDES')
103   FORMAT(/,1X,'FRONT2 : ERROR AT BOUNDARY POINT ',1I5,
     &       /,1X,'         LIQUID POINT BETWEEN TWO SOLID POINTS')
104   FORMAT(/,1X,'FRONT2 : ERREUR AU POINT DE BORD ',1I5,
     &       /,1X,'         POINT SOLIDE ENTRE DEUX POINTS LIQUIDES')
105   FORMAT(/,1X,'FRONT2 : ERROR AT BOUNDARY POINT ',1I5,
     &       /,1X,'         SOLID POINT BETWEEN TWO LIQUID POINTS')
90    FORMAT(/,1X,'FRONTIERE ',1I3,' : ',/,1X,
     &            ' DEBUT AU POINT DE BORD ',1I4,
     &            ' , DE NUMERO GLOBAL ',1I6,/,1X,
     &            ' ET DE COORDONNEES : ',G16.7,3X,G16.7,
     &       /,1X,' FIN AU POINT DE BORD ',1I4,
     &            ' , DE NUMERO GLOBAL ',1I6,/,1X,
     &            ' ET DE COORDONNEES : ',G16.7,3X,G16.7)
190   FORMAT(/,1X,'BOUNDARY ',1I3,' : ',/,1X,
     &            ' BEGINS AT BOUNDARY POINT: ',1I4,
     &            ' , WITH GLOBAL NUMBER: ',1I6,/,1X,
     &            ' AND COORDINATES: ',G16.7,3X,G16.7,
     &       /,1X,' ENDS AT BOUNDARY POINT: ',1I4,
     &            ' , WITH GLOBAL NUMBER: ',1I6,/,1X,
     &            ' AND COORDINATES: ',G16.7,3X,G16.7)
C
C-----------------------------------------------------------------------
C
      IF(NILE.GT.300.OR.NFRSOL.GT.300.OR.NFRLIQ.GT.300) THEN
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'FRONT2 : DEPASSEMENT DE TABLEAUX'
          WRITE(LU,*) '         AUGMENTER MAXFRO DANS LE CODE APPELANT'
          WRITE(LU,*) '         A LA VALEUR ',MAX(NILE,NFRSOL,NFRLIQ)
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'FRONT2: SIZE OF ARRAYS EXCEEDED'
          WRITE(LU,*) '        INCREASE MAXFRO IN THE CALLING PROGRAM'
          WRITE(LU,*) '        UP TO THE VALUE ',MAX(NILE,NFRSOL,NFRLIQ)
        ENDIF
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
C-----------------------------------------------------------------------
C
      RETURN
      END



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       BUILDS THE ARRAY IFABOR, WHERE IFABOR(IELEM, IFACE)
!>                IS THE GLOBAL NUMBER OF THE NEIGHBOUR OF SIDE IFACE
!>                OF ELEMENT IELEM (IF THIS NEIGHBOUR EXISTS) AND 0 IF
!>                THE SIDE IS ON THE DOMAIN BOUNDARY.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IADR, IELM, IFABOR, IKLE, NELEM, NELMAX, NPOIN, NVOIS, SIZIKL
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> ERR, I, I1, I2, IDIMAT, IELEM, IELEM2, IFACE, IFACE2, IMAX, IR1, IR2, IR3, IR4, IV, J, KEL, M1, M2, MAT1, MAT2, MAT3, NDP, NFACE, SOMFAC
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

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
!>  <tr>
!>    <th> 5.9                                                     </th>
!>    <th> 16/06/2008                                              </th>
!>    <th> J-M HERVOUET (LNH)                                      </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>IADR
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IELM
!></td><td>--></td><td>11: TRIANGLES
!>                  21: QUADRILATERES
!>    </td></tr>
!>          <tr><td>IFABOR
!></td><td><--</td><td>TABLEAU DES VOISINS DES FACES.
!>    </td></tr>
!>          <tr><td>IKLE
!></td><td>--></td><td>NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT
!>    </td></tr>
!>          <tr><td>NELEM
!></td><td>--></td><td>NOMBRE D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>--></td><td>NOMBRE MAXIMUM D'ELEMENTS DANS LE MAILLAGE.
!>                  (CAS DES MAILLAGES ADAPTATIFS)
!>    </td></tr>
!>          <tr><td>NPOIN
!></td><td>--></td><td>NOMBRE TOTAL DE POINTS DU DOMAINE
!>    </td></tr>
!>          <tr><td>NVOIS
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>SIZIKL
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE VOISIN_PARTEL
     &(IFABOR,NELEM,NELMAX,IELM,IKLE,SIZIKL,NPOIN,IADR,NVOIS)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| IADR           |---| 
C| IELM           |-->| 11: TRIANGLES
C|                |   | 21: QUADRILATERES
C| IFABOR         |<--| TABLEAU DES VOISINS DES FACES.
C| IKLE           |-->| NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT
C| NELEM          |-->| NOMBRE D'ELEMENTS DANS LE MAILLAGE.
C| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DANS LE MAILLAGE.
C|                |   | (CAS DES MAILLAGES ADAPTATIFS)
C| NPOIN          |-->| NOMBRE TOTAL DE POINTS DU DOMAINE
C| NVOIS          |---| 
C| SIZIKL         |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
      INTEGER IR1,IR2,IR3,IR4,SIZIKL
C
      INTEGER NELEM,NELMAX,IELM,IDIMAT,NPOIN,I,J,ERR,NDP
      INTEGER NFACE,KEL,I1,I2,IMAX,IFACE,IELEM,M1,M2,IV,IELEM2,IFACE2
      INTEGER IFABOR(NELMAX,*),IKLE(SIZIKL,*),NVOIS(NPOIN),IADR(NPOIN)
C
      INTEGER SOMFAC(2,4,2)
      DATA SOMFAC / 1,2 , 2,3 , 3,1 , 0,0   ,  1,2 , 2,3 , 3,4 , 4,1 /
C
C     DYNAMICALLY ALLOCATES THE WORKING ARRAYS
C
      INTEGER, DIMENSION(:), ALLOCATABLE :: MAT1,MAT2,MAT3
C
C-----------------------------------------------------------------------
C
      IF(IELM.EQ.21) THEN
C       QUADRILATERALS
        NFACE = 4
        NDP = 4
        KEL = 2
      ELSEIF(IELM.EQ.11.OR.IELM.EQ.41) THEN
C       TRIANGLES
        NFACE = 3
        NDP = 3
        KEL = 1
      ELSE
        IF(LNG.EQ.1) WRITE(LU,98) IELM
        IF(LNG.EQ.2) WRITE(LU,99) IELM
98      FORMAT(1X,'VOISIN: IELM=',1I6,' TYPE D''ELEMENT NON PREVU')
99      FORMAT(1X,'VOISIN: IELM=',1I6,' TYPE OF ELEMENT NOT AVAILABLE')
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
C-----------------------------------------------------------------------
C
C     IDIMAT IS BIGGER THAN THE SUM OF THE NUMBER OF NEIGHBOURS OF
C     ALL THE POINTS
C
      IDIMAT = 2*NDP*NELEM
C
      ALLOCATE(MAT1(IDIMAT),STAT=ERR)
      ALLOCATE(MAT2(IDIMAT),STAT=ERR)
      ALLOCATE(MAT3(IDIMAT),STAT=ERR)
C
      IF(ERR.NE.0) THEN
        IF(LNG.EQ.1) WRITE(LU,1000) ERR
        IF(LNG.EQ.2) WRITE(LU,2000) ERR
1000    FORMAT(1X,'VOISIN : ERREUR A L''ALLOCATION DE MEMOIRE : ',/,1X,
     &            'CODE D''ERREUR : ',1I6)
2000    FORMAT(1X,'VOISIN: ERROR DURING ALLOCATION OF MEMORY: ',/,1X,
     &            'ERROR CODE: ',1I6)
      ENDIF
C
C-----------------------------------------------------------------------
C
C  ARRAY NVOIS FOR EACH POINT
C  BEWARE : NVOIS IS BIGGER THAN THE ACTUAL NUMBER OF NEIGHBOURS
C           IT RESERVES MEMORY FOR ARRAYS MAT1,2,3
C
      DO 10 I=1,NPOIN
        NVOIS(I) = 0
10    CONTINUE
C
      DO 20 IFACE = 1,NFACE
        DO 30 IELEM=1,NELEM
          I1 = IKLE( IELEM , SOMFAC(1,IFACE,KEL) )
          I2 = IKLE( IELEM , SOMFAC(2,IFACE,KEL) )
          NVOIS(I1) = NVOIS(I1) + 1
          NVOIS(I2) = NVOIS(I2) + 1
30      CONTINUE
20    CONTINUE
C
C-----------------------------------------------------------------------
C
C  ADDRESSES OF EACH POINT IN A STRUCTURE OF TYPE COMPACT MATRIX
C
C
      IADR(1) = 1
      DO 50 I= 2,NPOIN
        IADR(I) = IADR(I-1) + NVOIS(I-1)
50    CONTINUE
C
      IMAX = IADR(NPOIN) + NVOIS(NPOIN) - 1
      IF(IMAX.GT.IDIMAT) THEN
        IF(LNG.EQ.1) WRITE(LU,51) IDIMAT,IMAX
        IF(LNG.EQ.2) WRITE(LU,52) IDIMAT,IMAX
51      FORMAT(1X,'VOISIN: TAILLE DE MAT1,2,3 (',1I6,') INSUFFISANTE',/,
     &         1X,'IL FAUT AU MOINS : ',1I6)
52      FORMAT(1X,'VOISIN: SIZE OF MAT1,2,3 (',1I6,') TOO SHORT',/,
     &         1X,'MINIMUM SIZE: ',1I6)
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
C-----------------------------------------------------------------------
C
C  INITIALISES THE COMPACT MATRIX TO 0
C
      DO 53 I=1,IMAX
        MAT1(I) = 0
53    CONTINUE
C
C-----------------------------------------------------------------------
C
C  LOOP ON THE SIDES OF EACH ELEMENT:
C
      DO 60 IFACE = 1 , NFACE
      DO 70 IELEM = 1 , NELEM
C
      IFABOR(IELEM,IFACE) = -1
C
C        GLOBAL NODE NUMBERS FOR THE SIDE:
C
         I1 = IKLE( IELEM , SOMFAC(1,IFACE,KEL) )
         I2 = IKLE( IELEM , SOMFAC(2,IFACE,KEL) )
C
C        ORDERED GLOBAL NUMBERS:
C
         M1 = MIN0(I1,I2)
         M2 = MAX0(I1,I2)
C
         DO 80 IV = 1,NVOIS(M1)
C
           IF(MAT1(IADR(M1)+IV-1).EQ.0) THEN
              MAT1(IADR(M1)+IV-1)=M2
              MAT2(IADR(M1)+IV-1)=IELEM
              MAT3(IADR(M1)+IV-1)=IFACE
              GO TO 81
           ELSEIF(MAT1(IADR(M1)+IV-1).EQ.M2) THEN
              IELEM2 = MAT2(IADR(M1)+IV-1)
              IFACE2 = MAT3(IADR(M1)+IV-1)
              IFABOR(IELEM,IFACE) = IELEM2
              IFABOR(IELEM2,IFACE2) = IELEM
              GO TO 81
           ENDIF
C
80       CONTINUE
C
         IF(LNG.EQ.1) WRITE(LU,82)
         IF(LNG.EQ.2) WRITE(LU,83)
82       FORMAT(1X,'VOISIN : ERREUR DANS LE MAILLAGE       ',/,1X,
     &             '         PEUT-ETRE DES POINTS CONFONDUS')
83       FORMAT(1X,'VOISIN : ERROR IN THE MESH             ',/,1X,
     &             '         MAYBE SUPERIMPOSED POINTS     ')
         CALL PLANTE2(-1)
         STOP
C
81       CONTINUE
C
70    CONTINUE
60    CONTINUE
C
C-----------------------------------------------------------------------
C
      DEALLOCATE(MAT1)
      DEALLOCATE(MAT2)
      DEALLOCATE(MAT3)
C
C-----------------------------------------------------------------------
C
      RETURN
      END



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       PRISMS SPLIT IN TETRAHEDRONS :<br>
!><br>           1) BUILDS ARRAYS NELBOR AND NULONE,
!><br>           2) BUILDS ARRAY KP1BOR,
!><br>           3) DISTINGUISHES IN IFABOR BETWEEN SOLID BOUNDARY SIDES AND LIQUID SIDES,
!><br>           4) COMPLEMENTS NBOR.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IELM, IFABOR, IFANUM, IKLBOR, IKLE, ISEG, KLOG, KP1BOR, LIHBOR, NBOR, NELBOR, NELEM, NELMAX, NPOIN, NPOIN_TOT, NPTFR, NPTFRMAX, NULONE, OPTASS, SIZIKL, T1, T2, T3
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> I, I1, I2, IEL, IELEM, IFACE, IPOIN, IPT, K, K1, K2, KEL, N1, N2, NFACE, NPT, SOMFAC
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

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
!>  <tr>
!>    <th> 5.3                                                     </th>
!>    <th> 23/08/1999                                              </th>
!>    <th> J-M HERVOUET (LNH)                                      </th>
!>    <th> TAKEN FROM BIEF AND ADAPTED : USE BIEF REMOVED, CALL PLANTE
!>         REMOVED, ALL ACTIONS UNDER IF(NCSIZE.GT.1) REMOVED      </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>IELM
!></td><td>--></td><td>TYPE D'ELEMENT.
!>                  11 : TRIANGLES.
!>                  21 : QUADRILATERES.
!>    </td></tr>
!>          <tr><td>IFABOR
!></td><td>--></td><td>TABLEAU DES VOISINS DES FACES.
!>    </td></tr>
!>          <tr><td>IFANUM
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IKLBOR
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>IKLE
!></td><td>--></td><td>NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT.
!>    </td></tr>
!>          <tr><td>ISEG
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>KLOG
!></td><td>--></td><td>CONVENTION POUR LA CONDITION LIMITE DE PAROI
!>    </td></tr>
!>          <tr><td>KP1BOR
!></td><td><--</td><td>NUMERO DU POINT SUIVANT LE POINT DE BORD K.
!>    </td></tr>
!>          <tr><td>LIHBOR
!></td><td>--></td><td>TYPES DE CONDITIONS AUX LIMITES SUR H
!>    </td></tr>
!>          <tr><td>MXELVS
!></td><td>--></td><td>NOMBRE MAXIMUM D'ELEMENTS AUTOUR D'UN POINT
!>    </td></tr>
!>          <tr><td>MXPTVS
!></td><td>--></td><td>NOMBRE MAXIMUM DE VOISINS D'UN POINT
!>    </td></tr>
!>          <tr><td>NBOR
!></td><td>--></td><td>NUMERO GLOBAL DU POINT DE BORD K.
!>    </td></tr>
!>          <tr><td>NELBOR
!></td><td><--</td><td>NUMERO DE L'ELEMENT ADJACENT AU KIEME SEGMENT
!>    </td></tr>
!>          <tr><td>NELEM
!></td><td>--></td><td>NOMBRE TOTAL D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NPOIN
!></td><td>--></td><td>NOMBRE TOTAL DE POINTS DU DOMAINE.
!>    </td></tr>
!>          <tr><td>NPOIN_TOT
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>--></td><td>NOMBRE DE POINTS FRONTIERES.
!>    </td></tr>
!>          <tr><td>NPTFRMAX
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NULONE
!></td><td><--</td><td>NUMERO LOCAL D'UN POINT DE BORD DANS
!>                  L'ELEMENT ADJACENT DONNE PAR NELBOR
!>    </td></tr>
!>          <tr><td>OPTASS
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>SIZIKL
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>T1,2,3
!></td><td>--></td><td>TABLEAUX DE TRAVAIL ENTIERS.
!>    </td></tr>
!>          <tr><td>T2
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>T3
!></td><td>---</td><td>
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE ELEBD_PARTEL
     &(NELBOR,NULONE,KP1BOR,IFABOR,NBOR,IKLE,SIZIKL,
     & IKLBOR,NELEM,NELMAX,NPTFRMAX,
     & NPOIN,NPTFR,IELM,LIHBOR,KLOG,IFANUM,OPTASS,ISEG,T1,T2,T3,
     &     NPOIN_TOT)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| IELM           |-->| TYPE D'ELEMENT.
C|                |   | 11 : TRIANGLES.
C|                |   | 21 : QUADRILATERES.
C| IFABOR         |-->| TABLEAU DES VOISINS DES FACES.
C| IFANUM         |---| 
C| IKLBOR         |---| 
C| IKLE           |-->| NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT.
C| ISEG           |---| 
C| KLOG           |-->| CONVENTION POUR LA CONDITION LIMITE DE PAROI
C| KP1BOR         |<--| NUMERO DU POINT SUIVANT LE POINT DE BORD K.
C| LIHBOR         |-->| TYPES DE CONDITIONS AUX LIMITES SUR H
C| MXELVS         |-->| NOMBRE MAXIMUM D'ELEMENTS AUTOUR D'UN POINT
C| MXPTVS         |-->| NOMBRE MAXIMUM DE VOISINS D'UN POINT
C| NBOR           |-->| NUMERO GLOBAL DU POINT DE BORD K.
C| NELBOR         |<--| NUMERO DE L'ELEMENT ADJACENT AU KIEME SEGMENT
C| NELEM          |-->| NOMBRE TOTAL D'ELEMENTS DANS LE MAILLAGE.
C| NELMAX         |---| 
C| NPOIN          |-->| NOMBRE TOTAL DE POINTS DU DOMAINE.
C| NPOIN_TOT      |---| 
C| NPTFR          |-->| NOMBRE DE POINTS FRONTIERES.
C| NPTFRMAX       |---| 
C| NULONE         |<--| NUMERO LOCAL D'UN POINT DE BORD DANS
C|                |   | L'ELEMENT ADJACENT DONNE PAR NELBOR
C| OPTASS         |---| 
C| SIZIKL         |---| 
C| T1,2,3         |-->| TABLEAUX DE TRAVAIL ENTIERS.
C| T2             |---| 
C| T3             |---| 
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER, INTENT(IN)    :: KLOG,NELMAX,NELEM,SIZIKL
      INTEGER, INTENT(IN)    :: NPOIN,NPTFR,IELM,OPTASS,NPTFRMAX
      INTEGER, INTENT(OUT)   :: NELBOR(NPTFR),NULONE(NPTFR,2)
      INTEGER, INTENT(OUT)   :: KP1BOR(NPTFR,2)
      INTEGER, INTENT(INOUT) :: NBOR(2*NPTFRMAX)
      INTEGER, INTENT(INOUT) :: IFABOR(NELMAX,*)
      INTEGER, INTENT(IN)    :: IKLE(SIZIKL,*)
      INTEGER, INTENT(IN)    :: LIHBOR(NPTFRMAX)
      INTEGER, INTENT(OUT)   :: IKLBOR(NPTFR,2)
      INTEGER, INTENT(INOUT) :: IFANUM(NELMAX,*)
      INTEGER, INTENT(IN)    :: ISEG(NPTFR)
      INTEGER, INTENT(OUT)   :: T1(NPOIN),T2(NPOIN),T3(NPOIN)
      INTEGER, INTENT(IN)    :: NPOIN_TOT
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER IELEM,NFACE,NPT,KEL,IPOIN
      INTEGER K,IFACE,I1,I2,N1,N2,IPT,IEL,I,K1,K2
C
      INTEGER SOMFAC(2,4,2)
C
      DATA SOMFAC / 1,2 , 2,3 , 3,1 , 0,0   ,  1,2 , 2,3 , 3,4 , 4,1 /
C
C-----------------------------------------------------------------------
C
      IF(IELM.EQ.11.OR.IELM.EQ.41.OR.IELM.EQ.51) THEN
C       TRIANGLES
        NFACE = 3
        NPT = 3
        KEL = 1
      ELSE
        IF(LNG.EQ.1) WRITE(LU,900) IELM
        IF(LNG.EQ.2) WRITE(LU,901) IELM
900     FORMAT(1X,'ELEBD : IELM=',1I6,' TYPE D''ELEMENT INCONNU')
901     FORMAT(1X,'ELEBD: IELM=',1I6,' UNKNOWN TYPE OF ELEMENT')
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
C  INITIALISES T1,2,3 AT 0
C
      DO IPOIN=1,NPOIN
        T1(IPOIN) = 0
        T2(IPOIN) = 0
        T3(IPOIN) = 0
      ENDDO
C
C  STORES K IN TRAV(*,3) WITH ADDRESS NBOR(K)
C  (ALLOWS TO GO FROM GLOBAL NODE NUMBER TO BOUNDARY NUMBER)
C
      DO K = 1, NPTFR
         T3(NBOR(K)) = K
      ENDDO
C
C  LOOP ON ALL THE SIDES OF ALL THE ELEMENTS:
C
      DO 20 IFACE = 1 , NFACE
      DO 10 IELEM = 1 , NELEM
C
      IF(IFABOR(IELEM,IFACE).EQ.-1) THEN
C
C      THIS IS A TRUE BOUNDARY SIDE (IN PARALLEL MODE INTERNAL SIDES
C                                    ARE INDICATED WITH -2)
C      GLOBAL NODE NUMBERS FOR THE SIDE:
C
       I1 = IKLE( IELEM , SOMFAC(1,IFACE,KEL) )
       I2 = IKLE( IELEM , SOMFAC(2,IFACE,KEL) )
C
C      STORES IN T1 AND T2 AT ADDRESS I1: I2 AND IELEM
C
       T1(I1) = I2
       T2(I1) = IELEM
C
C      A LIQUID FACE IS IDENTIFIED WITH BOUNDARY CONDITION ON H
C
C      07/02/03 IF(NPTFR...  COURTESY OLIVER GOETHEL, HANNOVER UNIVERSITY
       IF(NPTFR.GT.0) THEN
       IF(LIHBOR(T3(I1)).NE.KLOG.AND.LIHBOR(T3(I2)).NE.KLOG) THEN
C        LIQUID SIDE: IFABOR=0  SOLID SIDE: IFABOR=-1
         IFABOR(IELEM,IFACE)=0
       ENDIF
       ENDIF
C
      ENDIF
C
10    CONTINUE
20    CONTINUE
C
C  LOOP ON ALL THE POINTS:
C
C     07/02/03 IF(NPTFR...  CORRECTION BY OLIVER GOETHELS, HANNOVER
      IF(NPTFR.GT.0) THEN
      DO I = 1 , NPOIN
         IF(T1(I).NE.0) THEN
C          FOLLOWING POINT
           KP1BOR(T3(I),1)=T3(T1(I))
C          PRECEDING POINT
           KP1BOR(T3(T1(I)),2)=T3(I)
           NELBOR(T3(I))=T2(I)
         ENDIF
      ENDDO
      ENDIF
C
C COMPUTES ARRAY NULONE
C
      DO 50 K1=1,NPTFR
C
      K2=KP1BOR(K1,1)
      IEL = NELBOR(K1)
      N1  = NBOR(K1)
      N2  = NBOR(K2)
C
      I1 = 0
      I2 = 0
C
      DO 60 IPT=1,NPT
C
        IF(IKLE(IEL,IPT).EQ.N1) THEN
          NULONE(K1,1) = IPT
          I1 = 1
        ENDIF
        IF(IKLE(IEL,IPT).EQ.N2) THEN
          NULONE(K1,2) = IPT
          I2 = 1
        ENDIF
C
60    CONTINUE
C
      IF(I1.EQ.0.OR.I2.EQ.0) THEN
        IF(LNG.EQ.1) WRITE(LU,810) IEL
        IF(LNG.EQ.2) WRITE(LU,811) IEL
810     FORMAT(1X,'ELEBD: ERREUR DE NUMEROTATION DANS L''ELEMENT:',I6,/,
     &         1X,'       CAUSE POSSIBLE :                       '   ,/,
     &         1X,'       LE FICHIER DES CONDITIONS AUX LIMITES NE'  ,/,
     &         1X,'       CORRESPOND PAS AU FICHIER DE GEOMETRIE  ')
811     FORMAT(1X,'ELEBD: ERROR OF NUMBERING IN THE ELEMENT:',I6,
     &         1X,'       POSSIBLE REASON:                       '   ,/,
     &         1X,'       THE BOUNDARY CONDITION FILE IS NOT      '  ,/,
     &         1X,'       RELEVANT TO THE GEOMETRY FILE           ')
        CALL PLANTE2(-1)
        STOP
      ENDIF
C
50    CONTINUE
C
C  COMPLEMENTS ARRAY NBOR
C
C -----
C FD : BAW ONLY ?
C
C      OPEN(UNIT=89,FILE='FRONT_GLOB.DAT')
C      WRITE(89,*) NPOIN_TOT
C      WRITE(89,*) NPTFR
C      DO K=1,NPTFR
C         WRITE(89,*) NBOR(K)
C      END DO
C -----
C
      DO 80 K=1,NPTFR
C
        NBOR(K+NPTFR) = NBOR(KP1BOR(K,1))
C
        IKLBOR(K,1) = K
        IKLBOR(K,2) = KP1BOR(K,1)
C
80    CONTINUE



C
C -----
C      DO K=1,NPTFR
C         WRITE(89,*) KP1BOR(K,1)
C      END DO
C        DO K=1,NPTFR
C         WRITE(89,*) KP1BOR(K,2)
C      END DO
C ------
C
C ------
C      CALL FLUSH(89)
C      CLOSE(89)
C ------
C-----------------------------------------------------------------------
C
      RETURN
      END



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       CREATES THE FILES TO FEED THE PARALLEL DATA
!>                IN A PARALLEL ESTEL3D FLOW COMPUTATION.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> LI, NAMEINP
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> BLANC, COLOR1, COLOR2, COLOR_PRIO, COMPT, COMPT1, COMPT2, COMPT3, CONVTET, CONVTRI, DEJA_TROUVE, ECOLOR, EDGECUT, ELEGL, ELEM, EPART, EXTENS, FACE_CHECK, GLOB_2_LOC, I, IBID, IBID1, IBIDC, IDD, IDDBIS, IDDNT, IDDTERCE, IELEB, IELEM, IELEMBIS, IERR, IFABOR, IFACE, IFACEBIS, IKL, IKLBOR, IKLE, IKLE1, IKLE2, IKLE3, IKLE4, IKLEB, IKLEIN, IKLES, IKLESTET, IKLESTRI, IKLESTRIN, IOS, IPOBO, IPOIN, IPTFR, IS, ISBIS, ISTERCE, I_LEN, I_LENINP, I_LENLOG, I_S, I_SP, J, JJ, K, KNOLG, L, LINE, LINTER, LOGFAMILY, M, MAXLENHARD, MAXLENSOFT, MAXNPROC, MAX_NELEM_P, MAX_NPOIN_P, MAX_SIZE_FLUX, MAX_TRIA, MOINS1, MT, N, N1, N2, N3, NACHB, NACHBLOG, NAMEINP2, NAMELOG, NAMELOG2, NBCOLOR, NBFAMILY, NBMAXNSHARE, NBOR, NBOR2, NBRETOUCHE, NBSDOMVOIS, NBTET, NBTETJ, NBTRI, NBTRIIDD, NCOL, NCOLOR, NCOLOR2, NELBOR, NELEMSD, NELEMTOTAL, NELEM_P, NELIN, NF, NF1, NFT, NI, NI1, NINP, NINP2, NIT, NLOG, NLOG2, NODE, NODEGL, NODELG, NODES1, NODES1T, NODES2, NODES2T, NODES3, NODES3T, NODES4, NPART, NPARTS, NPOINT, NPOINTISD, NPOINTSD, NPOIN_P, NPTFR, NSEC, NSEC1, NSEC2, NSEC3, NSEC4, NSOLS, NSOLS_OLD, NT, NULONE, NUMBER_TRIA, NUMTET, NUMTETB, NUMTRI, NUMTRIB, NUMTRIG, PARSEC, POS, POS_NODE, PR1, PR2, PRIORITY, PRIO_NEW, READ_SEC1, READ_SEC2, READ_SEC3, SIZE_FLUX, SIZE_FLUXIN, SOMFAC, STR26, STR8, TDEB, TEMPO, TEMPS, TEMPS_SC, TETCOLOR, TETTRI, TETTRI2, TEXTERROR, TFIN, THEFORMAT, THE_TRI, TITRE, TRIUNV, TRI_REF, TYPELEM, VECTNB, X1, Y1, Z1
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> ALLOER(), ALLOER2(), ELEBD31_PARTEL(), PLANTE2(), VOISIN31_PARTEL()
!>   </td></tr>
!>     <tr><th> Unknown(s)
!>    </th><td> METIS_PARTMESHDUAL, SYSTEM_CLOCK, color1, j, ncolor2, pr2
!>   </td></tr>
!>     </table>

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
!>  <tr>
!>    <th>                                                         </th>
!>    <th> 12/11/2009                                              </th>
!>    <th> CHRISTOPHE DENIS SINETICS/I23                           </th>
!>    <th> DECREASES THE PARES3D COMPUTING TIME BY IMPROVING
!>         THE TETRA-TRIA CONNECTION AND THE POSTPROCESSING        </th>
!>  <tr>
!>    <th> DEVELOPMENT RELEASE                                     </th>
!>    <th> **/01/2008                                              </th>
!>    <th> F.DECUNG/O.BOITEAU                                      </th>
!>    <th> TAKES INTO ACCOUNT THE SPLITTING PROBLEM                </th>
!>  <tr>
!>    <th> 5.8                                                     </th>
!>    <th> 02/07/2007                                              </th>
!>    <th> F.DECUNG(LNHE)                                          </th>
!>    <th>                                                         </th>
!>  <tr>
!>    <th> 5.6                                                     </th>
!>    <th> 08/06/2006                                              </th>
!>    <th> O.BOITEAU/F.DECUNG(SINETICS/LNHE)                       </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>LI
!></td><td>--></td><td>UNITE LOGIQUE D'ECRITURE POUR MONITORING
!>    </td></tr>
!>          <tr><td>NAMEINP
!></td><td>--></td><td>NOM DU FICHIER DE GEOMETRIE ESTEL3D
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE PARES3D
     &(NAMEINP,LI)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| LI             |-->| UNITE LOGIQUE D'ECRITURE POUR MONITORING
C| NAMEINP        |-->| NOM DU FICHIER DE GEOMETRIE ESTEL3D
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
C     INTEGER, PARAMETER :: MAXNPROC = 1000  ! MAX PARTITION NUMBER [000..999]
      INTEGER, PARAMETER :: MAXNPROC = 100000 ! MAX PARTITION NUMBER [00000..99999]
      INTEGER, PARAMETER :: MAXLENHARD = 250 ! HARD MAX FILENAME LENGTH
      INTEGER, PARAMETER :: MAXLENSOFT = 144 ! SOFT MAX FILENAME LENGTH
!
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C SUBROUTINE CALL PARAMETERS
      CHARACTER(LEN=MAXLENHARD), INTENT(IN) :: NAMEINP
      INTEGER,                   INTENT(IN) :: LI
C LOCAL VARIABLES
      CHARACTER(LEN=MAXLENHARD) :: NAMELOG,NAMEINP2,NAMELOG2
      INTEGER :: NINP=10,NLOG=11,NINP2=12,NLOG2=13
      INTEGER :: NPARTS,I_S,I_SP,I,I_LEN,I_LENINP,IERR,J,K,COMPT,
     &           N,NUMTET,NUMTRI,NUMTRIG,I_LENLOG,L,NI,NF,NT,IBID,IDD,
     &           COMPT1,COMPT2,COMPT3,NBTRIIDD,IBID1,M,NI1,NF1,COLOR1,
     &           COLOR2,PR1,PR2,IDDBIS,IDDTERCE,NBTETJ,IDDNT,NIT,NFT,MT,
     &           NUMTRIB,NUMTETB,IBIDC,NBRETOUCHE
      LOGICAL :: IS,ISBIS,ISTERCE,LINTER
      CHARACTER(LEN=300) :: TEXTERROR  ! ERROR MESSAGE TEXT
      CHARACTER(LEN=8)   :: STR8       ! ERROR MESSAGE TEXT
      CHARACTER(LEN=300) :: STR26      ! ERROR MESSAGE TEXT
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
      INTEGER, PARAMETER :: NSEC4=2435 ! DESIGNED TO END NICELY READING
                                       ! UNV IN ESTEL3D
      LOGICAL            :: READ_SEC1  ! FLAG FOR READING SECTION 1
      LOGICAL            :: READ_SEC2  ! FLAG FOR READING SECTION 2
      LOGICAL            :: READ_SEC3  ! FLAG FOR READING SECTION 3
      INTEGER            :: NELEMTOTAL ! TOTAL NUMBER OF UNV ELEMENTS
      INTEGER            :: NPOINT     ! TOTAL NUMBER OF NODES
      INTEGER            :: NBFAMILY   ! TOTAL NUMBER OF FAMILY
      INTEGER            :: NELIN      ! TOTAL NUMBER OF INNER TRIANGLES
      INTEGER            :: SIZE_FLUX  !  TOTAL NUMBER OF INNER SURFACES
      INTEGER, DIMENSION(:), ALLOCATABLE :: VECTNB  ! AUX VECTOR FOR NACHB
!
      DOUBLE PRECISION, ALLOCATABLE :: X1(:),Y1(:),Z1(:) ! NODES' COORD
      INTEGER,          ALLOCATABLE :: NCOLOR(:) ! NODES' COLOUR
      INTEGER,          ALLOCATABLE :: ECOLOR(:) ! ELEMENTS' COLOUR
      INTEGER            :: ELEM       ! TYPE OF THE ELEMENT
      INTEGER            :: IKLE1,IKLE2,IKLE3,IKLE4,IKLEB   ! NODES
      INTEGER, DIMENSION(:), ALLOCATABLE :: IKLESTET ! CONNECTIVITY
                   ! TETRAHEDRONS GLOBAL NUMBERING
      INTEGER, DIMENSION(:), ALLOCATABLE :: IKLESTRI ! CONNECTIVITY
                   ! TRIANGLES GLOBAL NUMBERING
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: IKLESTRIN ! CONNECTIVITY
                   ! TRIANGLES GLOBAL NUMBERING
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: IKLEIN ! ADJUSTED COPY OF IKLESTRIN
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: TYPELEM ! ELEMENT TYPE
      INTEGER            :: NBTET,NBTRI  ! NBR OF TETRA, BOUNDARY TRIANGLE
      INTEGER, DIMENSION(:), ALLOCATABLE :: TETTRI, TETTRI2 ! JOINT
                                               !  TETRA/BOUNDARY TRIANGLE
      INTEGER            ::  EDGECUT ! AUX VARIABLE FOR METIS
      INTEGER, DIMENSION(:), ALLOCATABLE :: EPART ! PARTITION NUMBER
                                                  ! PER ELEMENT
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPART ! PARTITION NUMBER
                                                  ! PER NODE
      INTEGER, DIMENSION(:), ALLOCATABLE :: CONVTRI,CONVTET ! CONVERTER
         ! TRIA LOCAL NUMBER/TETRA GLOBAL NUMBER; REVERSE FROM TYPELEM(:,2)
      INTEGER            ::  TDEB,TFIN,TEMPS,PARSEC  ! RUNTIME
      CHARACTER(LEN=11), EXTERNAL :: EXTENS ! FILENAME EXTENSIONS
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPOINTSD, NELEMSD ! NBR
                            ! OF POINTS AND ELEMENTS PER SUB-DOMAIN
      INTEGER, DIMENSION(:), ALLOCATABLE :: NPOINTISD  ! NBR
                            ! OF INTERFACE POINTS PER SUB-DOMAIN
                   ! VECTORS RELATED TO INVERSE NODE CONNECTIVITIES
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODES1,NODES2,NODES3,NODES4
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODES1T,NODES2T,NODES3T
      INTEGER, DIMENSION(:), ALLOCATABLE :: TRIUNV ! BUFFER TO WRITE
                 ! IN UNV, THE TETRAS FIRST AND THE TRIA AFTER
C TO TREAT THE DIRICHLETS IN THE INTERFACE
      INTEGER  :: NBCOLOR ! NBR OF COLOURS FOR EXTERNAL MESHES
      INTEGER, DIMENSION(:), ALLOCATABLE :: PRIORITY
      INTEGER, DIMENSION(:), ALLOCATABLE :: NCOLOR2
C TO TREAT THE DIRICHLETS FOR TETRA NODES
      LOGICAL, DIMENSION(:,:), ALLOCATABLE :: TETCOLOR
      LOGICAL, DIMENSION(:), ALLOCATABLE :: DEJA_TROUVE
C ESSENTIAL FOR TELEMAC IN PARALLEL MODE
      INTEGER, DIMENSION(:), ALLOCATABLE :: KNOLG
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: NACHB
      LOGICAL :: NACHBLOG
C     MAXIMUM GEOMETRICAL MULTIPLICITY OF A NODE (ALSO EXISTS IN
C     BIEF, DO NOT CHANGE ONE AND NOT THE OTHER)
      INTEGER, PARAMETER :: NBMAXNSHARE =  10
C THIS VARIABLE IS RELATED TO THE PREVIOUS VARIABLE AND GIVES THE SIZE
C OF DIFFERENT VECTORS
C NOTE SIZE OF NACHB WILL BE HERE 2 MORE THAN IN BIEF, BUT THE EXTRA 2 ARE
C LOCAL WORK ARRAYS
      INTEGER :: NBSDOMVOIS = NBMAXNSHARE + 2
!
      INTEGER, PARAMETER :: MAX_SIZE_FLUX = 100
C NUMBER OF INNER SURFACE (SAME AS SIZE_FLUX AT THE END)
      INTEGER, DIMENSION(MAX_SIZE_FLUX) :: SIZE_FLUXIN
C VECTOR FOR PROFILING
      INTEGER  TEMPS_SC(20)
!
CF.D
      INTEGER, DIMENSION(:  ), ALLOCATABLE  :: TEMPO,GLOB_2_LOC
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: IKLES,IKLE,IFABOR
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: NULONE,IKLBOR
      INTEGER                               :: N1,N2,N3,IKL,IFACE
      INTEGER                               :: NSOLS,NSOLS_OLD
      INTEGER                               :: IFACEBIS,IELEMBIS
      INTEGER                               :: IELEM,IPTFR,IELEB,IPOIN
      LOGICAL, DIMENSION(:), ALLOCATABLE    :: FACE_CHECK
      INTEGER, PARAMETER                    :: NCOL = 256
      INTEGER, DIMENSION(NCOL  )            :: COLOR_PRIO
      INTEGER                               :: PRIO_NEW,NPTFR
      INTEGER, DIMENSION(:), ALLOCATABLE    :: NBOR2,NBOR
      INTEGER, DIMENSION(:), ALLOCATABLE    :: NELBOR,IPOBO
CD******************************************************    ADDED BY CHRISTOPHE DENIS
      INTEGER, DIMENSION(:), ALLOCATABLE     :: NELEM_P
C     SIZE NPARTS, NELEM_P(I) IS THE NUMBER OF FINITE ELEMENTS ASSIGNED TO SUBDOMAIN I
      INTEGER, DIMENSION(:), ALLOCATABLE     :: NPOIN_P
C     SIZE NPARTS, NPOIN_P(I) IS THE NUMBER OF NODES  ASSIGNED TO SUBDOMAIN I
      INTEGER :: NODE
C     ONE NODE ...
      INTEGER ::  POS_NODE
C     POSITION OF ONE ONE NODE
      INTEGER :: MAX_NELEM_P
C     MAXIMUM NUMBER OF FINITE ELEMENTS ASSIGNED AMONG SUBDOMAINS
      INTEGER :: MAX_NPOIN_P
C     MAXIMUM NUMBER OF NODES ASSIGNED AMONG SUBDOMAINS
      INTEGER :: MAX_TRIA
C     MAXIMUM NUMBER OF TRIANGLES SHARING A NODE
      INTEGER :: THE_TRI
C     ONE TRIANGLE
      INTEGER :: JJ
C     INDEX COUNTER
      INTEGER, DIMENSION(:), ALLOCATABLE :: NUMBER_TRIA
C     MAXIMUM NUMBER OF TRIANGLES SHARING A SAME NODE
      INTEGER, DIMENSION(:,:), ALLOCATABLE  :: ELEGL
C     SIZE MAX_NELEM_P,NPARTS, ELEGL(J,I) IS THE GLOBAL NUMBER OF LOCAL FINITE ELEMENT J IN SUBDOMAIN I
      INTEGER, DIMENSION(:,:), ALLOCATABLE :: NODEGL
C     SIZE MAX_NPOIN_P,NPARTS, NODEGL(J,I) IS THE GLOBAL NUMBER OF LOCAL NODE J IN SUBDOMAIN I
      INTEGER, DIMENSION(:), ALLOCATABLE :: NODELG
C     SIZE NPOINT, NODELG(I)=J, J IS THE LOCAL NUMBER OF GLOBAL NODE I ON ONE SUBDOMAIN
      INTEGER,  DIMENSION(:,:), ALLOCATABLE :: TRI_REF
C     SIZE NPOINT*MAX_TRIA
CD********************************************************
      INTEGER SOMFAC(3,4)
      DATA SOMFAC / 1,2,3 , 4,1,2 , 2,3,4 , 3,4,1  /


!-----------------------------------------------------------------------
C 1. PREAMBLE
!---------------
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(1),COUNT_RATE=PARSEC)
      ALLOCATE (VECTNB(NBSDOMVOIS-3))
      WRITE(LU,*)' '
      WRITE(LU,*)'+-------------------------------------------------+'
      WRITE(LU,*)'  PARTEL: TELEMAC ESTEL3D PARTITIONER'
      WRITE(LU,*)'+-------------------------------------------------+'
      WRITE(LU,*)' READING UNV AND LOG FILES'
C NAMES OF THE INPUT FILES:
      IF (NAMEINP.EQ.' ') THEN
        GOTO 149
      ELSE
        WRITE(LU,89)NAMEINP
      ENDIF
      INQUIRE (FILE=NAMEINP,EXIST=IS)
      IF (.NOT.IS) GOTO 140
      DO
        READ(LI,'(A)')NAMELOG
        IF (NAMELOG.EQ.' ') THEN
          GOTO 150
        ELSE
          WRITE(LU,90)NAMELOG
          EXIT
        ENDIF
      END DO
      INQUIRE(FILE=NAMELOG,EXIST=IS)
      IF (.NOT.IS) GOTO 141
      DO
        READ(LI,*)NPARTS
        IF ( (NPARTS > MAXNPROC) .OR. (NPARTS < 2) ) THEN
          WRITE(LU,
     &    '('' NUMBER OF PARTITIONS MUST BE IN [2 -'',I6,'']'')')
     &      MAXNPROC
        ELSE
          WRITE(LU,91)NPARTS
          EXIT
        ENDIF
      ENDDO


C FINDS THE INPUT FILES CORE NAME LENGTH
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
C 2A. READS .LOG FILE
!---------------
      READ(NLOG,51,ERR=110,END=120)NPOINT
      READ(NLOG,52,ERR=110,END=120)NELEMTOTAL
      READ(NLOG,53,ERR=110,END=120)NBFAMILY
      NBFAMILY=NBFAMILY+1            ! BLOCK TITLE
      ALLOCATE(LOGFAMILY(NBFAMILY),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' LOGFAMILY')
      DO I=1,NBFAMILY
        READ(NLOG,50,ERR=111,END=120)LOGFAMILY(I)
      ENDDO
      NBCOLOR=0

C      READ(NLOG,531,ERR=110,END=120)NBCOLOR

      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
         !         '!----------------------------------!'
         TEXTERROR='! PROBLEM WITH THE NUMBER OF COLOR !'
         CALL ALLOER2(LU,TEXTERROR)
         CALL PLANTE2(-1)
      ENDIF
      POS = INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:), FMT=*, IOSTAT=IOS) NBCOLOR
      IF (IOS .NE. 0) THEN
         !         '!-------------------------------!'
         TEXTERROR='! PROBLEM WITH THE NUMBER COLOR !'
      ENDIF

      ALLOCATE(PRIORITY(NBCOLOR),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' PRIORITY')
      WRITE(LU,92) NPOINT
      WRITE(LU,93) NELEMTOTAL
      WRITE(LU,94) NBCOLOR
      IF (NBCOLOR.EQ.0) THEN
        WRITE(LU,*) 'VOUS AVEZ OUBLIE DE REMPLIR LE FICHIER LOG...'
        CALL PLANTE2(-1)
        STOP
      ENDIF

      ! MODIFICATION JP RENAUD 15/02/2007
      ! SOME TEXT HAS BEEN ADDED BEFORE THE LIOST OF PRIORITIES.
      ! READS A 200 CHARACTER LINE, FINDS THE ':' AND THEN
      ! READS THE VALUES AFTER THE ':'
      READ(UNIT=NLOG, FMT='(A200)', IOSTAT=IOS) LINE
      IF (IOS .NE. 0) THEN
        !         '!------------------------------------------!'
        TEXTERROR='! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
        CALL ALLOER2(LU,TEXTERROR)
        CALL PLANTE2(-1)
      ENDIF
      POS = INDEX(LINE,':') + 1
      READ(UNIT=LINE(POS:), FMT=*, IOSTAT=IOS) (PRIORITY(J),J=1,NBCOLOR)
      IF (IOS .NE. 0) THEN
        !         '!------------------------------------------!'
        TEXTERROR='! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
        CALL ALLOER2(LU,TEXTERROR)
        CALL PLANTE2(-1)
      ENDIF
      ! END MODIFICATION JP RENAUD
      WRITE(LU,*) (PRIORITY(J),J=1,NBCOLOR)
      CLOSE(NLOG)
!
C 2B. ALLOCATES ASSOCIATED MEMORY
!---------------

CD    ****************************** ALLOCATION MEMORY ADDED BY CD
      ALLOCATE(NELEM_P(NPARTS),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'NELEM_P')
      ALLOCATE(NPOIN_P(NPARTS),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'NPOIN_P')
      ALLOCATE(NODELG(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'NODELG')
CD    *******************************

      ALLOCATE(X1(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' X1')
      ALLOCATE(Y1(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' Y1')
      ALLOCATE(Z1(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' Z1')
      ALLOCATE(NCOLOR(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NCOLOR')
      ALLOCATE(NCOLOR2(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NCOLOR2')
      ALLOCATE(ECOLOR(NELEMTOTAL),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' ECOLOR')
      ALLOCATE(IKLESTET(4*NELEMTOTAL),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLESTET')
      ALLOCATE(IKLESTRI(3*NELEMTOTAL),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLESTRI')
      ALLOCATE(IKLESTRIN(NELEMTOTAL,4),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLESTRIN')
      ALLOCATE(TYPELEM(NELEMTOTAL,2),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' TYPELEM')
      ALLOCATE(CONVTRI(NELEMTOTAL),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' CONVTRI')
      ALLOCATE(CONVTET(NELEMTOTAL),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' CONVTET')
      ALLOCATE(NPOINTSD(NPARTS),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NPOINTSD')
      ALLOCATE(NELEMSD(NPARTS),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NELEMSD')
      ALLOCATE(NPOINTISD(NPARTS),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NPOINTISD')

CF.D
      ALLOCATE(NBOR2(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NBOR2')
      ALLOCATE(TEMPO(2*NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' TEMPO')
      ALLOCATE(FACE_CHECK(NBFAMILY),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' FACE_CHECK')
      ALLOCATE(GLOB_2_LOC(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' GLOB_2_LOC')
      ALLOCATE(IKLES(NELEMTOTAL,4),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLES')


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
              END DO

          CASE (NSEC3 )

             READ_SEC3 = .FALSE.

             NBTET         = 0  ! NUMBER OF TETRA ELEMENTS TO 0
             NBTRI         = 0  ! NUMBER OF BORDER ELEMENTS TO 0
             NPTFR         = 0  ! NUMBER OF BORDER NODES TO 0
             NELIN         = 0  ! NUMBER OF INNER SURFACES TO 0
             SIZE_FLUX     = 0  ! NUMBER OF USER SURFACES TO 0
             NBOR2(:)      = 0  ! LOCAL TO GLOBAL NUMBERING
             GLOB_2_LOC(:) = 0  ! GLOBAL TO LOCAL NUMBERING

COB'S STUFF
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

COB'S STUFF
                   N=4*(NBTET-1)+1
                   IKLESTET(N)=IKLE1    ! CONNECTIVITY VECTOR
                   IKLESTET(N+1)=IKLE2
                   IKLESTET(N+2)=IKLE3
                   IKLESTET(N+3)=IKLE4
                   TYPELEM(IELEM,1)=ELEM    ! TO SORT THE ELEMENTS
                   TYPELEM(IELEM,2)=NBTET   ! POUR CONRELEASE NUM ELT> NUM TETRA
                   CONVTET(NBTET)=IELEM     ! THE OPPOSITE

                CASE ( 91 )

                   IF (NSOLS.GT.0) THEN

                      IF ( NSOLS > NCOL ) THEN
                         WRITE(LU,*) 'COLOR ID POUR SURFACES EXTERNES ',
     &                        ' TROP GRAND. LA LIMITE EST : ',NCOL
                      END IF

                      PRIO_NEW = COLOR_PRIO(NSOLS)

                      IF ( PRIO_NEW .EQ. 0 ) THEN
                         WRITE(LU,*) ' NUMERO DE FACE NON DECLARE',
     &                        'DANS LE TABLEAU UTILISATEUR LOGFAMILY ',
     &                        'VOIR LE FICHIER DES PARAMETRES '
                         CALL PLANTE2(1)
                      END IF

                      FACE_CHECK(PRIO_NEW) = .TRUE.

                      NBTRI = NBTRI + 1

                      ECOLOR(IELEM) = NSOLS

                     READ(NINP,*, ERR=1100, END=1200) IKLE1, IKLE2,IKLE3

                      IKLES(IELEM, 1) = TEMPO(IKLE1)
                      IKLES(IELEM, 2) = TEMPO(IKLE2)
                      IKLES(IELEM, 3) = TEMPO(IKLE3)

COB'S STUFF
                      N=3*(NBTRI-1)+1
                      IKLESTRI(N)=IKLE1
                      IKLESTRI(N+1)=IKLE2
                      IKLESTRI(N+2)=IKLE3
                      TYPELEM(IELEM,1)=ELEM    ! SAME AS FOR TETRA
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

                 ELSE IF (NSOLS.LT.0) THEN
                    !
                    ! USER-DEFINED SURFACE FOR FLUXES COMPUTATION
                    !
                    ! NELIN IS THE COUNTER FOR THE INTERNAL ELEMENTS.
                    ! ACTUALLY, WE ARE READING THE NEXT INTERNAL ELEMENT.

                    ! NSOLS_OLD IS USED FOR SAVING USE OF A NEW VARIABLE
                    NSOLS_OLD = -NSOLS
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
                 ELSE           ! THIS IS AN INNER SURFACE, JUST READS THE LINE

                    READ(NINP,*, ERR=1100, END=1200) IKLE1, IKLE2,IKLE3

                 END IF

              CASE DEFAULT      ! THIS IS AN UNKNOWN ELEMENT

                 WRITE(LU,*) 'ELEMENT INCONNU DANS LE MAILLAGE'

              END SELECT        ! THE TYPE OF THE MESH ELEMENT

           END DO               ! LOOP OVER ELEMENTS TO READ

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

C CORRECTS THE TOTAL NUMBER OF ELEMENTS BECAUSE THAT IN THE .LOG
C INCLUDES ELEMENTS NOT TAKEN INTO ACCOUNT IN AN ESTEL STUDY
      NELEMTOTAL=NBTET+NBTRI

      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(2),COUNT_RATE=PARSEC)
      WRITE(LU,*)' TEMPS DE LECTURE FICHIERS LOG & UNV',
     &           (1.0*(TEMPS_SC(2)-TEMPS_SC(1)))/(1.0*PARSEC),' SECONDS'
!----------------------------------------------------------------------
C 3A. BUILDS TETTRI/TETTRI2: CORRESPONDENCE TETRA > TRIA
!---------------

      ALLOCATE(NELBOR(NBTRI),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NELBOR')
      ALLOCATE(NULONE(NBTRI,3),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NULONE')
      ALLOCATE(IKLBOR(NBTRI,3),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLBOR')
      ALLOCATE(IKLE(NBTET,4),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLE')
      ALLOCATE(IFABOR(NBTET,4),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' IFABOR')
!
!------------------------------------------------------- DEBUT VERSION O. BOITEAU
C LOOKS FOR CORRESPONDENCE TETRAHEDRON - BOUNDARY TRIANGLES
C      ALLOCATE(TETTRI(4*NBTET),STAT=IERR)
C      IF (IERR.NE.0) CALL ALLOER(LU,' TETTRI')
C      ALLOCATE(TETTRI2(NBTET),STAT=IERR)
C      IF (IERR.NE.0) CALL ALLOER(LU,' TETTRI2')
C      TETTRI(:)=-1
C      TETTRI2(:)=0
C      DO I=1,NBTRI
C        N=3*(I-1)+1
C        IKLE1=IKLESTRI(N)
C        IKLE2=IKLESTRI(N+1)
C        IKLE3=IKLESTRI(N+2)
C        DO J=1,NBTET
C          COMPT=0
C          DO K=1,4
C            IKLEB=IKLESTET(4*(J-1)+K)
C            IF (IKLEB.EQ.IKLE1) COMPT=COMPT+1
C            IF (IKLEB.EQ.IKLE2) COMPT=COMPT+10
C            IF (IKLEB.EQ.IKLE3) COMPT=COMPT+100
C          ENDDO ! TETRAHEDRON J NODES
C          IF (COMPT.EQ.111) THEN   ! TETRAHEDRON J ASSOCIATED TO TRIANGLE I
C            NI=TETTRI2(J)
C            IF (NI==4) THEN   ! TETRA IS LINKED TO MORE THAN 4 TRIA, EXIT
C              GOTO 153
C            ELSE              ! NEXT AVAILABLE SLOT
C              M=4*(J-1)+NI+1  ! IN TETTRI
C              TETTRI2(J)=NI+1
C              TETTRI(M)=I     ! LOCAL NUMBERING
C            ENDIF
C            EXIT
C          ENDIF
C          IF (J.EQ.NBTET) GOTO 143  ! ERROR: LONE TRIANGLE
C        ENDDO  ! TETRAHEDRONS LOOP
C      ENDDO ! BOUNDARY TRIANGLES LOOP
!------------------------------------------------------- FIN VERSION O. BOITEAU

!------------------------------------------------------- DEBUT VERSION F.D
      ALLOCATE(TETTRI(4*NBTET),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' TETTRI')
      ALLOCATE(TETTRI2(NBTET),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' TETTRI2')
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
      IF (IERR.NE.0) CALL ALLOER(LU,' IKLEIN')
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
      IF (IERR.NE.0) CALL ALLOER(LU,' NBOR')
!
      DO IELEM = 1, NPTFR
            NBOR(IELEM) = NBOR2(IELEM)
      END DO
!
      DEALLOCATE(NBOR2)
!
      WRITE(LU,*) 'VOISIN31'

      CALL VOISIN31_PARTEL (IFABOR, NBTET, NBTET,
     &              IKLE,NBTET,NPOINT,NBOR,NPTFR)

      WRITE(LU,*) 'FIN DE VOISIN31'

      ALLOCATE(IPOBO(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'IPOBO')

      CALL ELEBD31_PARTEL( NELBOR, NULONE, IKLBOR,
     &              IFABOR, NBOR, IKLE,
     &              NBTET, NBTRI, NBTET, NPOINT,
     &              NPTFR,IPOBO)

      DEALLOCATE(IPOBO)

      WRITE(LU,*) 'FIN DE ELEBD31'
      ALLOCATE(NUMBER_TRIA(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'NUMBER_TRIA')
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
      IF (IERR.NE.0) CALL ALLOER(LU,' TRI_REF')
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
C                  WRITE(*,*) N, '---> ',M
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




C 3B. BUILDS NODES1/NODES2/NODES3: REVERSE CONNECTIVITY NODE > TETRA
C     TO WRITE ON THE FLY IN LOCAL UNV
!---------------
C GOES THROUGH THE CELLS TO KNOW HOW MANY CELLS REFERENCE
C THEM
      ALLOCATE(NODES1(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES1')
      NODES1(:)=0
      DO I=1,NBTET
        DO K=1,4
          IKLEB=IKLESTET(4*(I-1)+K)
          NODES1(IKLEB)=NODES1(IKLEB)+1
        ENDDO
      ENDDO
C NUMBER OF REFERENCES OF POINTS AND POINTER NODES2 TOWARDS NODES3
C THE ITH POINT HAS ITS TETRA LIST (IN LOCAL TETRA NUMBERING)
C FROM NODES3(NODES2(I)) TO NODES3(NODES2(I)+NODES1(I)-1)
      ALLOCATE(NODES2(NPOINT+1),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES2')
      COMPT=0
      NODES2(1)=1
      DO I=1,NPOINT
        COMPT=COMPT+NODES1(I)
        NODES2(I+1)=COMPT+1
      ENDDO
C FOR A GIVEN NODE, WHICH CELLS RELATE TO IT
      ALLOCATE(NODES3(COMPT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES3')
      NODES3(:)=-1
      DO I=1,NBTET
        DO K=1,4
          IKLEB=IKLESTET(4*(I-1)+K)
          NI=NODES2(IKLEB)
          NF=NI+NODES1(IKLEB)-1
          NT=-999
          DO N=NI,NF ! LOOKS FOR THE FIRST FREE INDEX FOR NODES3
            IF (NODES3(N)==-1) THEN
              NT=N
              EXIT
            ENDIF
          ENDDO ! OVER N
          IF (NT==-999) THEN
            GOTO 146  ! PB OF SIZE: VECTORS NODESI
          ELSE
            NODES3(NT)=I  ! LOCAL NUMBER OF THE TETRA I ASSOCIATED WITH NODE NT
          ENDIF
        ENDDO
      ENDDO

C 3C. BUILDS NODES1T/NODES2T/NODES3T: REVERSE CONNECTIVITY NODE > TRIA
C     FOR THE NODE COLOUR (DIRICHLET ON THE INTERFACE)
!---------------
      ALLOCATE(NODES1T(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES1T')
      NODES1T(:)=0
      DO I=1,NBTRI
        DO K=1,3
          IKLEB=IKLESTRI(3*(I-1)+K)
          NODES1T(IKLEB)=NODES1T(IKLEB)+1
        ENDDO
      ENDDO
      ALLOCATE(NODES2T(NPOINT+1),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES2T')
      COMPT=0
      NODES2T(1)=1
      DO I=1,NPOINT
        COMPT=COMPT+NODES1T(I)
        NODES2T(I+1)=COMPT+1
      ENDDO
      ALLOCATE(NODES3T(COMPT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES3T')
      NODES3T(:)=-1
      DO I=1,NBTRI
        DO K=1,3
          IKLEB=IKLESTRI(3*(I-1)+K)
          NI=NODES2T(IKLEB)
          NF=NI+NODES1T(IKLEB)-1
          NT=-999
          DO N=NI,NF ! LOOKS FOR THE FIRST FREE INDEX FOR NODES3T
            IF (NODES3T(N)==-1) THEN
              NT=N
              EXIT
            ENDIF
          ENDDO ! OVER N
          IF (NT==-999) THEN
            GOTO 146  ! PB OF SIZE: VECTORS NODESI
          ELSE
            NODES3T(NT)=I  ! LOCAL NUMBER OF TETRA I ASSOCIATED WITH NODE NT
          ENDIF
        ENDDO
      ENDDO
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(4),COUNT_RATE=PARSEC)
      WRITE(LU,*)' TEMPS CONNECTIVITE INVERSE PART1/ PART2',
     &          (1.0*(TEMPS_SC(3)-TEMPS_SC(2)))/(1.0*PARSEC),'/',
     &          (1.0*(TEMPS_SC(4)-TEMPS_SC(3)))/(1.0*PARSEC),' SECONDS'

!----------------------------------------------------------------------
C 4. PARTITIONS
!---------------

C        DO I=1,4*NBTET
C                WRITE(LU,*) 'TETTRIALPHA',TETTRI(I)
C        ENDDO
C        DO I=1,NBTET
C                WRITE(LU,*) 'TETTRIBETA',TETTRI2(I)
C        ENDDO

      WRITE(LU,*)' '
      WRITE(LU,*)' STARTING METIS MESH PARTITIONING------------------+'
      ALLOCATE(EPART(NBTET),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER (LU, 'EPART')
      ALLOCATE (NPART(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER (LU, 'NPART')
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(5),COUNT_RATE=PARSEC)
C PARTITIONS THE MESHES
      CALL METIS_PARTMESHDUAL(NBTET,NPOINT,IKLESTET,2,1,NPARTS,EDGECUT,
     &    EPART,NPART)
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(6),COUNT_RATE=PARSEC)
      WRITE(LU,*)' '
      WRITE(LU,*)' END METIS MESH PARTITIONING------------------+'
      WRITE(LU,*)' TEMPS CONSOMME PAR  METIS ',
     &           (1.0*(TEMPS_SC(6)-TEMPS_SC(5)))/(1.0*PARSEC),' SECONDS'
      WRITE(LU,80) NELEMTOTAL,NPOINT
      WRITE(LU,81) NBTET,NBTRI
      WRITE(LU,82) EDGECUT,NPARTS
      WRITE(LU,*) 'SORTIE DE METIS CORRECTE'
CD ******************************************************
CD     LOOP OVER THE TETRA TO COMPUTE THE NUMBER AND THE LABEL
CD     OF FINITE ELEMENTS ASSIGNED TO EACH SUBDOMAIN
CD ******************************************************
CD     COMPUTES THE MAXIMUM NUMBER OF FINITE ELEMENTS ASSIGNED TO ONE SUBDOMAIN
      NELEM_P(:)=0
      NPOIN_P(:)=0
       DO I=1,NBTET
         NELEM_P(EPART(I))=NELEM_P(EPART(I))+1
      END DO
      MAX_NELEM_P=MAXVAL(NELEM_P)
      NELEM_P(:)=0
CD     ALLOCATES ARRAY ELEGL
      ALLOCATE(ELEGL(MAX_NELEM_P,NPARTS),STAT=IERR)
CD     ELEGL IS THE FILLED
      IF (IERR.NE.0) CALL ALLOER(LU,'ELEGL')
      DO I=1,NBTET
         NELEM_P(EPART(I))=NELEM_P(EPART(I))+1
         ELEGL(NELEM_P(EPART(I)),EPART(I))=I
       END DO
CD     COMPUTES THE MAXIMUM OF NODES ASSIGNED TO ONE SUBDOMAIN
       NODELG(:)=0
CD     FOR EACH SUBDOMAIN IDD
       DO IDD=1,NPARTS
          NODELG(:)=0
CD         LOOP ON THE FINITE ELEMENTS IELEM ASSIGNED TO SUBDOMAIN IDD
          DO POS=1,NELEM_P(IDD)
            IELEM=ELEGL(POS,IDD)
            N=4*(IELEM-1)+1
CD          LOOP OF THE NODE CONTAINED IN IELEM
            DO K=0,3
               NODE=IKLESTET(N+K)
               IF (NODELG(NODE) .EQ. 0) THEN
                  NPOIN_P(IDD)=NPOIN_P(IDD)+1
                  NODELG(NODE)=NPOIN_P(IDD)
               END IF
            END DO
         END DO
      END DO
CD    ALLOCATES AND FILLS ARRAY NODEGL
      MAX_NPOIN_P=MAXVAL(NPOIN_P)
      NPOIN_P(:)=0
      NODELG(:)=0
!
      ALLOCATE(NODEGL(MAX_NPOIN_P,NPARTS),STAT=IERR)
       IF (IERR.NE.0) CALL ALLOER(LU,'NODEGL')
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
C 5A. ALLOCATIONS TO WRITE THE FILES .UNV/.LOG ASSOCIATING A
C     SUB-DOMAIN BY PROC
!------------

      NAMEINP2=NAMEINP
      NAMELOG2=NAMELOG
      BLANC='    '
      MOINS1='-1'
      ALLOCATE(NODES4(NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NODES4')
C$$$      NODES4(:)=-1
      ALLOCATE(KNOLG(NPOINT),STAT=IERR)      ! THIS IS FAR FROM OPTIMAL
      IF (IERR.NE.0) CALL ALLOER(LU,' KNOLG')! AS FAR AS SIZE GOES BUT
      KNOLG(:)=-1      ! QUICKER WHEN IT WILL COME TO FILL IT IN IN THE FUTURE
!
C PARAMETER NBSDOMVOIS (NUMBER OF NEIGHBOURING SUBDOMAINS +2)
!
      ALLOCATE(NACHB(NBSDOMVOIS,NPOINT),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' NACHB')
      NACHB(1,:)=0
      DO J=2,NBSDOMVOIS-1
        NACHB(J,:)=-1
      ENDDO
      ALLOCATE(TRIUNV(4*NBTRI),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER (LU, 'TRIUNV')
!
!
C 5B. LOOKS FOR THE TRUE COLOUR OF THE NODES TO AVOID DIRICHLET PBS
C     AT THE INTERFACES
!---------------
      NCOLOR2(:)=-1
      DO J=1,NPOINT      ! LOOP ON ALL THE POINTS OF THE MESHES
        NI=NODES2T(J)
        NF=NI+NODES1T(J)-1
        DO N=NI,NF       ! LOOP ON THE TETRA CONTAINING POINT J
          NUMTET=NODES3T(N)   ! TRIA WITH LOCAL NUMBER NUMTET
          NUMTRIG=CONVTRI(NUMTET)  ! GLOBAL NUMBER OF THE TRIANGLE
          COLOR1=ECOLOR(NUMTRIG)   ! NODE COLOUR WITH THIS TRIA
          COLOR2=NCOLOR2(J)
          IF (COLOR2 > 0) THEN   ! PRIORITISES COLOURS
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
            IF (PR1<pr2) ncolor2(j)=color1  ! CHANGES COLOUR
          ELSE        ! 1ST TIME THIS NODE IS TREATED
            NCOLOR2(J)=COLOR1
          ENDIF
        ENDDO
      ENDDO

      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(7),COUNT_RATE=PARSEC)

C      DO IELEM = 1, NPOINT
C         WRITE(LU,*) 'NCOLOR2',NCOLOR2(IELEM)
C      ENDDO

C      DO IELEM = 1, NBCOLOR
C         WRITE(LU,*) 'PRIOR',PRIORITY(IELEM)
C      ENDDO

C OB START
!--------------
C ADDITION TO TAKE THE NODE COLOURS FOR THE TETRAS LINKED TO
C THE BOUNDARY TRIA AND IN OTHER SUB-DOMAINS INTO ACCOUNT
!--------------
      ALLOCATE(TETCOLOR(NBTET,4),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,' TETCOLOR')
      TETCOLOR(:,:)=.FALSE.
      NBRETOUCHE=0
      DO IPTFR=1,NPTFR      ! LOOP ON ALL THE BOUNDARY POINTS
        J=NBOR(IPTFR)
C       DOES SOMETHING (POSSIBLY) ONLY IF THERE IS ONE BOUNDARY TRIA
C       (ECOLOR>0 AND NCOLOR2!=-1). USING THE PREVIOUS TREATMENT
C       IT'S EASILY IDENTIFIABLE VIA NCOLOR2.
	       LINTER=.FALSE.
        NBTETJ=NODES1(J) ! NBR OF TETRA LINKED TO THIS NODE
        NI=NODES2(J)     ! ADDRESS OF THE 1ST ONE IN NODES3
        NF=NI+NBTETJ-1
	       IF (NCOLOR2(J) > 0) THEN
  ! WANTS TO KNOW IF THE NODE IS AT THE INTERFACE LINTER=.TRUE.
          DO N=NI,NF       ! LOOP ON THE TETRA CONTAINING POINT J
            NT=NODES3(N)   ! TETRA WITH LOCAL NUMBER NT
	           IF (N == NI) THEN
	             IDDNT=EPART(NT)
	           ELSE
	      IF (EPART(NT) /= IDDNT) THEN
	        LINTER=.TRUE.
       GOTO 20     ! HAS THE REQUIRED INFORMATION, EXITS
	      ENDIF
	      ENDIF
         ENDDO           ! END OF LOOP ON THE TETRAS
   20     CONTINUE
C         NODE J IS AN INTERFACE NODE. THE RIGHT COLOUR WILL BE COMMUNICATED
C         TO THE CORRESPONDING TETRA NODE (IF A BOUNDARY TRIA IS NOT ON THIS
C         SIDE, IN WHICH CASE THE PB HAS ALREADY BEEN TAKEN CARE OF).
	     IF (LINTER) THEN
            DO N=NI,NF       ! LOOP ON THE TETRA CONTAINING POINT J
              NT=NODES3(N)   ! TETRA WITH LOCAL NUMBER NT
C         SORTS THE NON PATHOLOGICAL AND VERY COMMON CASES WHERE ONE SIDE
C         OF THE TETRA COINCIDES WITH THIS TRIANGLE
              IF (TETTRI2(NT)>0) THEN   !TETRA CONCERNED BY A TRIA
	         NIT=4*(NT-1)+1
		    NFT=NIT+TETTRI2(NT)-1
           DO MT=NIT,NFT           ! LOOP ON THE TRIA OF THE TETRA
                  NUMTRI=TETTRI(MT)     ! LOCAL NUMBER OF THE TRIA
                  NUMTRIB=3*(NUMTRI-1)+1
                  IKLE1=IKLESTRI(NUMTRIB) ! GLOBAL NODE NUMBERS OF THE TRIA
                  IKLE2=IKLESTRI(NUMTRIB+1)
                  IKLE3=IKLESTRI(NUMTRIB+2)
C                 THIS POINT J ALREADY BELONGS TO A TRIA NEXT TO THE TETRA
C                 SKIPS TETRA NT
		     IF ((IKLE1==J).OR.(IKLE2==J).OR.(IKLE3==J)) THEN
C FOR TESTING PURPOSES
C                    WRITE(LU,*)'JE SAUTE LE TETRA ',NT,EPART(NT),
C     &                          TETTRI2(NT),' NODES ',J
                    GOTO 21
                  ENDIF
		         ENDDO
      ENDIF            ! END IF TETTRI
C             TETRA NT IS POTENTIALLY FORGOTTEN, IS TREATED IN CASE THE
C             SPLIT WILL BE MADE IN ESTEL3D/READ_CONNECTIVITY
	      NUMTETB=4*(NT-1)+1
	      DO L=1,4
                IKLE1=IKLESTET(NUMTETB+L-1) ! GLOBAL NODE NUMBERS OF THE TETRA
		              IF (IKLE1==J) THEN
                  TETCOLOR(NT,L)=(TETCOLOR(NT,L).OR..TRUE.)
                  NBRETOUCHE=NBRETOUCHE+1
                ENDIF
       ENDDO  ! OVER L
   21        CONTINUE
       ENDDO           ! END OF LOOP ON THE TETRAS
       ENDIF            ! END IF LINTER
       ENDIF             ! END IF ON NCOLOR2
      ENDDO              ! END BOUNDARY POINTS LOOP
C OB END
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(8),COUNT_RATE=PARSEC)
      WRITE(LU,*)' NOMBRE DE RETOUCHE DU PARTITIONNEMENT (PART2): ',
     &           NBRETOUCHE
      WRITE(LU,*)' TEMPS DE RETOUCHE DU PARTITIONNEMENT PART1/PART2',
     &            (1.0*(TEMPS_SC(7)-TEMPS_SC(6)))/(1.0*PARSEC),'/',
     &           (1.0*(TEMPS_SC(8)-TEMPS_SC(7)))/(1.0*PARSEC),' SECONDS'
C$$$      WRITE(LU,*)'IDEM RELEASE DE REFERENCE'

C 5C. EFFECTIVELY FILLS IN UNV BY SD
!---------------
      IBID = 1
!
      ALLOCATE(DEJA_TROUVE(NELIN),STAT=IERR)
      IF (IERR.NE.0) CALL ALLOER(LU,'DEJA_TROUVE')
      DEJA_TROUVE(:)=.FALSE.
!
      DO IDD=1,NPARTS  ! LOOP ON THE SUB-DOMAINS

C NUMBER OF TRIANGLES FOR THIS SUBDOMAIN
        NBTRIIDD=0
C NAME OF UNV FILE BY SUBDOMAIN
        NAMEINP2(I_LENINP+1:I_LENINP+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NINP2,FILE=NAMEINP2,STATUS='UNKNOWN',FORM='FORMATTED',
     &       ERR=132)
        REWIND(NINP2)

C NAME OF THE LOG FILE BY SUBDOMAIN
        NAMELOG2(I_LENLOG+1:I_LENLOG+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NLOG2,FILE=NAMELOG2,STATUS='UNKNOWN',FORM='FORMATTED',
     &       ERR=133)
        REWIND(NLOG2)

C TITLE (UNV BY SD)
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
C BLOCK WITH COORDINATES/NODE COLOURS (UNV BY SD)
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
        WRITE(NINP2,61,ERR=112)NSEC2
        COMPT=1
        NODES4(:)=-1
CD      NEW RELEASE OF THE LOOP TO REDUCE THE COMPUTING TIME
        DO POS_NODE=1,NPOIN_P(IDD) ! LOOP ON ALL THE POINTS OF THE MESHES
           J=NODEGL(POS_NODE,IDD)
CD       PREVIOUS RELEASE OF THE LOOP
CD       NI=NODES2(J)
CD       NF=NI+NODES1(J)-1
CD       DO N=NI,NF       ! LOOP ON THE TETRA CONTAINING POINT J
CD           NT=NODES3(N)   ! TETRA WITH LOCAL NUMBER NT
CD           IF (EPART(NT)==IDD) THEN     ! IT'S A CELL FROM THE SUBDOMAIN
              WRITE(NINP2,63,ERR=112)COMPT,IBID,IBID,NCOLOR2(J)
              WRITE(NINP2,64,ERR=112)X1(J),Y1(J),Z1(J)
              NODES4(J)=COMPT   ! NODE J HAS NUMBER COMPT
                                ! IN SUBDOMAIN IDD
C IN PARALLEL MODE (TELEMAC)
              KNOLG(COMPT)=J ! CONRELEASE SD (LOCAL)-->WHOLE MESH (GLOBAL)
              K=NACHB(1,J)   ! NBR OF SUBDOMAINS CONTAINING NODE J
              NACHBLOG=.TRUE.
              DO L=1,K     ! NODE ALREADY CONCERNED BY THIS SD ?
                IF (NACHB(1+L,J)==IDD) NACHBLOG=.FALSE.  ! YES
              ENDDO
              IF (NACHBLOG) THEN                         ! NO
                K=NACHB(1,J)+1
                IF (K.GT.NBSDOMVOIS-2) GOTO 151
                NACHB(K+1,J)=IDD  ! GLOBAL NODE J CONCERNED BY IDD
                NACHB(1,J)=K      ! ITS MULTIPLICITY
              ENDIF
              COMPT=COMPT+1
C              GOTO 10 ! GOES TO NEXT NODE
C            ENDIF  ! OVER EPART
C          ENDDO ! OVER N
C   10     CONTINUE
        ENDDO   ! OVER J
C FOR TESTING PURPOSES
C      DO I=1,NPOINT
C        WRITE(LU,*)'GLOBAL NUMERO POINT: ',I,' LOCAL: ',NODES4(I)
C      ENDDO
        NPOINTSD(IDD)=COMPT-1  ! NUMBER OF NODES IN SUBDOMAIN IDD
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1

C BLOCK CONNECTIVITIES/MESH COLOUR (UNV BY SD)
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
        WRITE(NINP2,61,ERR=112)NSEC3
        COMPT=1
        IBID = 1
CD      PREVIOUS RELEASE OF THE LOOP
CD      DO J=1,NELEMTOTAL
CD      IF (TYPELEM(J,1)==111) THEN ! IT'S A TETRAHEDRON
CD        NUMTET=TYPELEM(J,2) ! LOCAL NUMBER OF THE TETRA IN THE TETRAS LIST
CD            IF (EPART(NUMTET)==IDD) THEN
        DO POS=1,NELEM_P(IDD)
                                ! LOOP ON TETRA AND TRIA FOR ECOLOR
           J=ELEGL(POS,IDD)
           NUMTET=TYPELEM(J,2)  ! LOCAL NUMBER OF THE TETRA IN THE TETRAS LIST
           ELEM=111
C OB START
C PRETREATMENT FOR POSSIBLE NODE COLOUR PB FOR THE TETRAS AT THE
C INTERFACE
              IBIDC=0
	      IF (TETCOLOR(NUMTET,1)) IBIDC=IBIDC+1000
	      IF (TETCOLOR(NUMTET,2)) IBIDC=IBIDC+ 200
	      IF (TETCOLOR(NUMTET,3)) IBIDC=IBIDC+  30
	      IF (TETCOLOR(NUMTET,4)) IBIDC=IBIDC+   4
C FOR MONITORING PURPOSES
C              IF (IBIDC/=0) WRITE(6,*)'IDD',IDD,'PARTEL',J,COMPT,IBIDC
C IDEM REFERENCE RELEASE
C       IBIDC=0
C OB END
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
                DO M=NI,NF   ! GOES THRU THE BOUNDARY TRIANGLES ASSOCIATED
                  NUMTRI=TETTRI(M)  ! TO THE TETRA NUMTET; LOCAL NB OF THE TRIA
                  NUMTRIG=CONVTRI(NUMTRI)  ! GLOBAL NUMBER OF THE TRIANGLE
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
                ENDDO  ! OVER M
              ENDIF  ! OVER TETTRI2
        !    ENDIF  ! OVER EPART
      !    ENDIF  ! OVER TYPELEM
        ENDDO ! OVER J

C CAN NOW RECOPY THE BLOCK OF TRIANGLES
        ELEM=91
        DO J=1,NBTRIIDD
          WRITE(NINP2,65,ERR=112)COMPT,ELEM,IBID,IBID,
     &                           TRIUNV(4*(J-1)+1),3
          IKLE1=TRIUNV(4*(J-1)+2)
          IKLE2=TRIUNV(4*(J-1)+3)
          IKLE3=TRIUNV(4*(J-1)+4)
          WRITE(NINP2,67,ERR=112)IKLE1,IKLE2,IKLE3
          COMPT=COMPT+1
        ENDDO  ! OVER J
!
        ELEM=91
C OVERSIZE LOOP, LOOP ON THE NUMBER OF SURFACES INTERNAL TO THE GLOBAL MESH...
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
        ENDDO ! OVER J
!
C$$$        WRITE(LU,*) 'SUBDOMAIN',IDD,'INNERTRI',COMPT
!
        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
C        WRITE(NINP2,60,ERR=112)BLANC,MOINS1
C        WRITE(NINP2,61,ERR=112)NSEC4
C        WRITE(NINP2,68,ERR=112) 1,0,0,0,0,0,0,0
        CLOSE(NINP2)
        NELEMSD(IDD)=COMPT-1  ! NUMBER OF CELLS IN SUBDOMAIN IDD

C 5D. EFFECTIVELY FILLS IN LOG BY SD
!---------------
C STANDARD ELEMENT OF THE LOG FILE (LOG BY SD)
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
C        WRITE(LU,*) 'FORMATT =',THEFORMAT
        WRITE (NLOG2,FMT=THEFORMAT(1:LEN(THEFORMAT)-1))
     &  (PRIORITY(I), I=1, NBCOLOR)

        ! END ADDITION BY JP RENAUD

C KNOLG (LOG BY SD)
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
        WRITE(NLOG2,55,ERR=113)NPOINT  ! NUMBER OF NODES IN THE INITIAL
                    ! MESH TO ALLOCATE KNOGL IN ESTEL
!
      ENDDO  ! LOOP ON THE SUB-DOMAINS

C 5E. ADDITIONAL WORK TO DETERMINE NACHB BEFORE IT IS WRITTEN
C      TO THE LOG
!---------------
      DO IDD=1,NPARTS  ! LOOP ON THE SUB-DOMAINS
C BUILDS AND DETERMINES SIZE OF NACHB SPECIFIC TO EACH SUB-DOMAIN
        COMPT=0
        NACHB(NBSDOMVOIS,:)=-1
        DO J=1,NPOINT      ! LOOP ON ALL THE POINTS OF THE MESH
          N=NACHB(1,J)
          IF (N>1) THEN    ! INTERFACE POINT
            N=N+1
            DO K=2,N
              IF (NACHB(K,J)==IDD) THEN ! CONCERNS IDD
                COMPT=COMPT+1   ! "COMPT"TH INTERFACE POINT OF IDD
                NACHB(NBSDOMVOIS,J)=COMPT  ! REMEMBER AS INTERFACE POINT
              ENDIF
            ENDDO            ! END OF LOOP ON THE SUB-DOMAINS FOR POINT J
          ENDIF
        ENDDO              ! END LOOP OVER POINTS
        NPOINTISD(IDD)=COMPT ! NUMBER OF INTERFACE POINTS FOR IDD

C 5F. RESUMES WRITING TO THE .LOG FILE
!-------------
        NAMELOG2(I_LENLOG+1:I_LENLOG+11) = EXTENS(NPARTS-1,IDD-1)
        OPEN(NLOG2,FILE=NAMELOG2,STATUS='OLD',FORM='FORMATTED',
     &       POSITION='APPEND',ERR=133)
        WRITE(NLOG2,56,ERR=113) NPOINTISD(IDD)
        DO J=1,NPOINT
          IF (NACHB(NBSDOMVOIS,J)>0) THEN  ! THIS IS AN INTERFACE POINT FOR IDD
            COMPT=0
            VECTNB(:)=-1
            DO K=1,NBSDOMVOIS-2    ! PREPARES THE INFORMATION FOR NACHB TELEMAC
              IF (NACHB(K+1,J)/= IDD) THEN
                COMPT=COMPT+1
C BEWARE THIS ONE, MUST BE LINKED TO THE NUMBER OF POINTS...
C OB START
                IF (COMPT.GT.NBSDOMVOIS-3) GOTO 152
C OB END
                IF (NACHB(K+1,J)>0) THEN
C STORES THE PROC NUMBER AND NOT THE SUB-DOMAIN NUMBER
C HENCE THE CONSTRAINT, A PROC BY SUB-DOMAIN
                  VECTNB(COMPT)=NACHB(K+1,J)-1
                ENDIF
              ENDIF
            ENDDO  ! OVER K
C            WRITE(NLOG2,561,ERR=113)J,(VECTNB(K),K=1,NBSDOMVOIS-3)
             NT = NBSDOMVOIS-3
             NI=NT/6
             NF=NT-6*NI+1
	     WRITE(NLOG2,640,ERR=113)J,(VECTNB(K),K=1,5)
	     DO L=2,NI
	       WRITE(NLOG2,640,ERR=113)(VECTNB(6*(L-1)+K),K=0,5)
	     ENDDO
	     IF (NF.EQ.1) THEN
	       WRITE(NLOG2,641,ERR=113)VECTNB(6*NI)
	     ELSE IF (NF.EQ.2) THEN
               WRITE(NLOG2,642,ERR=113)(VECTNB(6*NI+K),K=0,1)
	     ELSE IF (NF.EQ.3) THEN
	       WRITE(NLOG2,643,ERR=113)(VECTNB(6*NI+K),K=0,2)
	     ELSE IF (NF.EQ.4) THEN
	       WRITE(NLOG2,644,ERR=113)(VECTNB(6*NI+K),K=0,3)
	     ELSE IF (NF.EQ.5) THEN
               WRITE(NLOG2,645,ERR=113)(VECTNB(6*NI+K),K=0,4)
             ENDIF
          ENDIF
        ENDDO  ! END LOOP OVER J
        WRITE(NLOG2,57,ERR=113)
        CLOSE(NLOG2)
      ENDDO  ! LOOP OVER THE SUB-DOMAINS
      CALL SYSTEM_CLOCK(COUNT=TEMPS_SC(9),COUNT_RATE=PARSEC)
      WRITE(LU,*)' REMPLISSAGE DES FICHIERS UNV ET LOG',
     &           (1.0*(TEMPS_SC(9)-TEMPS_SC(8)))/(1.0*PARSEC),' SECONDS'
!----------------------------------------------------------------------
C 6. PRINTS OUT TO PARTEL.LOG AND TESTS COMPLETION OF PARTITIONING
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
C 7. MISCELLANEOUS
!---------------

C 7.A LOG FORMAT
!---------------
   50 FORMAT(A80)         ! OTHER LINES
C             1234567890123456789012345678901234567890123456789
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

  540 FORMAT(6I10)        ! LINE OF BLOCK KNOLG AND PRIORITY
  541 FORMAT(I10)         ! LAST LINE OF BLOCK KNOLG
  542 FORMAT(2I10)        ! LAST LINE OF BLOCK KNOLG
  543 FORMAT(3I10)        ! LAST LINE OF BLOCK KNOLG
  544 FORMAT(4I10)        ! LAST LINE OF BLOCK KNOLG
  545 FORMAT(5I10)        ! LAST LINE OF BLOCK KNOLG

  641 FORMAT(I7)         ! LAST LINE OF BLOCK NACHB
  642 FORMAT(2I7)        ! LAST LINE OF BLOCK NACHB
  643 FORMAT(3I7)        ! LAST LINE OF BLOCK NACHB
  644 FORMAT(4I7)        ! LAST LINE OF BLOCK NACHB
  645 FORMAT(5I7)        ! LAST LINE OF BLOCK NACHB
  640 FORMAT(6I7)        ! LAST LINE OF BLOCK NACHB



   55 FORMAT(' FIN DE KNOLG: ',I10)
   56 FORMAT(' DEBUT DE NACHB: ',I10)
  561 FORMAT(10I10)        ! LINE OF BLOCK NACHB
   57 FORMAT(' FIN DE NACHB: ')

C 7B. UNV FORMAT
!---------------
   60 FORMAT(A4,A2)       ! '    -1'
   61 FORMAT(I6)          ! READS NSEC
   62 FORMAT(A80)         ! READS TITLE
   63 FORMAT(4I10)        ! LINE 1 OF BLOCK COORD
   64 FORMAT(3D25.16)     ! LINE 2 OF BLOCK COORD
   65 FORMAT(6I10)        ! LINE 1 OF BLOCK CONNECTIVITY
   66 FORMAT(4I10)        ! LINE 2 OF BLOCK CONNECTIVITY IF TETRA
   67 FORMAT(3I10)        ! LINE 2 OF BLOCK CONNECTIVITY IF TRIANGLE
   68 FORMAT(8I10)        ! DUMMY BLOCK TO INDICATE END OF BLOCK
                          ! CONNECTIVITY

C 7.C PRINTOUTS TO PARTEL.LOG
!---------------
   80 FORMAT(' #NUMBER TOTAL OF ELEMENTS: ',I8,
     &       ' #NODES                 : ',I8)
   81 FORMAT(' #TETRAHEDRONS            : ',I8,
     &       ' #TRIANGLE MESH BORDER  : ',I8)
   82 FORMAT(' #EDGECUTS                : ',I8,
     &       ' #NPARTS                : ',I8)
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

C 7.D DEALLOCATES
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

C 7.E ERROR MESSAGES
!---------------
  110 TEXTERROR='! UNEXPECTED FILE FORMAT: '//NAMELOG//' !'
      GOTO 999
  111 TEXTERROR='! UNEXPECTED FILE FORMAT: '//NAMEINP//' !'
      GOTO 999
  112 TEXTERROR='! UNEXPECTED FILE FORMAT: '//NAMEINP2//' !'
      GOTO 999
  113 TEXTERROR='! UNEXPECTED FILE FORMAT: '//NAMELOG2//' !'
      GOTO 999
  120 TEXTERROR='! UNEXPECTED EOF WHILE READING: '//NAMELOG//' !'
      GOTO 999
  121 TEXTERROR='! UNEXPECTED EOF WHILE READING: '//NAMEINP//' !'
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
  142 TEXTERROR='! UNKNOWN TYPE OF ELEMENT IN THE MESH !'
      GOTO 999
  143 DO J = 1,NELEMTOTAL
        IF (TYPELEM(J,2)==I) WRITE(UNIT=STR8,FMT='(I8)')J
      ENDDO
      WRITE(UNIT=STR26,FMT='(I8,X,I8,X,I8)')IKLE1,IKLE2,IKLE3
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
  148 TEXTERROR='! SEVERAL ELEMENTS MAY BE FORGOTTEN BY PARTITIONNING !'
      GOTO 999
  149 TEXTERROR='! NO INPUT UNV FILE !'
      GOTO 999
  150 TEXTERROR='! NO INPUT LOG FILE !'
      GOTO 999
C  151 WRITE(UNIT=STR8,FMT='(I8)')J
C      WRITE(UNIT=STR26,FMT='(I3,X,I3,X,I3,X,I3,X,I3,X,I3)')
C     &                 (NACHB(K,J),K=2,6),IDD
  151 WRITE(UNIT=STR8,FMT='(I8)')J
      WRITE(UNIT=STR26,FMT='(I3,X,I3,X,I3,X,I3,X,I3,X,I3)')
     &                 (NACHB(K,J),K=2,NBSDOMVOIS-1),IDD
      TEXTERROR='! NODE '//STR8//' BELONGS TO DOMAINS '//STR26(1:23)
     &                 //' !'
      GOTO 999
  152 TEXTERROR='! PROBLEM WITH CONSTRUCTION OF VECTNB FOR NACHB !'
      GOTO 999
  153 WRITE(UNIT=STR8,FMT='(I8)')CONVTET(J)
      TEXTERROR='! TETRAHEDRON '//STR8//
     &          ' LINKS TO SEVERAL BORDER TRIANGLES !'
      GOTO 999
  154 TEXTERROR='! PROBLEM WITH THE PRIORITY OF COLOR NODES !'
      GOTO 999
C END OF FILE AND FORMAT ERRORS :
 1100 TEXTERROR='ERREUR DE LECTURE DU FICHIER UNV '//
     &  'VIA MESH_CONNECTIVITY'
      GOTO 999
 1200 TEXTERROR='ERREUR DE FIN DE LECTURE DU FICHIER UNV '//
     &  'VIA MESH_CONNECTIVITY'
      GOTO 999

  999 CALL ALLOER2(LU,TEXTERROR)
!
      END SUBROUTINE PARES3D



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       BUILDS NELBOR, NULONE, IKLBORD.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IFABOR, IKLBOR, IKLE, IPOBO, NBOR, NBTET, NBTRI, NELBOR, NELMAX, NPOINT, NPTFR, NULONE
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> IELEB, IELEM, IPOIN, J, K, SOMFAC
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>PARES3D()

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
!>  <tr>
!>    <th> 5.5                                                     </th>
!>    <th> 09/04/2004                                              </th>
!>    <th> J-M HERVOUET (LNH); LAM MINH-PHUONG ORIGINALLY          </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>31
!></td><td>--></td><td>TYPE D'ELEMENT.
!>    </td></tr>
!>          <tr><td>IFABOR
!></td><td>--></td><td>TABLEAU DES VOISINS DES FACES.
!>    </td></tr>
!>          <tr><td>IKLBOR
!></td><td><--</td><td>NUMERO LOCAL DES NOEUDS A PARTIR D'UN ELEMENT
!>                  DE BORD
!>    </td></tr>
!>          <tr><td>IKLE
!></td><td>--></td><td>NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT.
!>    </td></tr>
!>          <tr><td>IPOBO
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NBOR
!></td><td>--></td><td>NUMERO GLOBAL D'UN NOEUD A PARTIR DU NUMERO LOCAL
!>    </td></tr>
!>          <tr><td>NBTET
!></td><td>--></td><td>NOMBRE TOTAL D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NBTRI
!></td><td>--></td><td>NOMBRE D'ELEMENTS DE BORD.
!>    </td></tr>
!>          <tr><td>NELBOR
!></td><td><--</td><td>NUMERO DE L'ELEMENT ADJACENT AU KIEME SEGMENT
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>NPOINT
!></td><td>--></td><td>NOMBRE TOTAL DE POINTS DU DOMAINE.
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>--></td><td>NOMBRE DE POINTS FRONTIERES.
!>    </td></tr>
!>          <tr><td>NULONE
!></td><td><--</td><td>NUMERO LOCAL D'UN POINT DE BORD DANS
!>                  L'ELEMENT ADJACENT DONNE PAR NELBOR
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE ELEBD31_PARTEL
     &(NELBOR,NULONE,IKLBOR,IFABOR,NBOR,IKLE,
     & NBTET,NBTRI,NELMAX,NPOINT,NPTFR,IPOBO)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| 31             |-->| TYPE D'ELEMENT.
C| IFABOR         |-->| TABLEAU DES VOISINS DES FACES.
C| IKLBOR         |<--| NUMERO LOCAL DES NOEUDS A PARTIR D'UN ELEMENT
C|                |   | DE BORD
C| IKLE           |-->| NUMEROS GLOBAUX DES POINTS DE CHAQUE ELEMENT.
C| IPOBO          |---| 
C| NBOR           |-->| NUMERO GLOBAL D'UN NOEUD A PARTIR DU NUMERO LOCAL
C| NBTET          |-->| NOMBRE TOTAL D'ELEMENTS DANS LE MAILLAGE.
C| NBTRI          |-->| NOMBRE D'ELEMENTS DE BORD.
C| NELBOR         |<--| NUMERO DE L'ELEMENT ADJACENT AU KIEME SEGMENT
C| NELMAX         |---| 
C| NPOINT         |-->| NOMBRE TOTAL DE POINTS DU DOMAINE.
C| NPTFR          |-->| NOMBRE DE POINTS FRONTIERES.
C| NULONE         |<--| NUMERO LOCAL D'UN POINT DE BORD DANS
C|                |   | L'ELEMENT ADJACENT DONNE PAR NELBOR
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: NBTET,NBTRI,NELMAX
      INTEGER, INTENT(IN)    :: NPOINT,NPTFR
      INTEGER, INTENT(IN)    :: NBOR(NPTFR)
      INTEGER, INTENT(IN)    :: IFABOR(NELMAX,4)
      INTEGER, INTENT(IN)    :: IKLE(NBTET,4)
      INTEGER, INTENT(OUT)   :: NELBOR(NBTRI),NULONE(NBTRI,3)
      INTEGER, INTENT(OUT)   :: IKLBOR(NBTRI,3),IPOBO(NPOINT)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER   :: IELEM, IELEB, J,K,IPOIN
C      INTEGER   :: IPOBO(NPOINT)
!
      INTEGER SOMFAC(3,4)
      DATA SOMFAC / 1,2,3 , 4,1,2 , 2,3,4 , 3,4,1  /
C     FACE NUMBER:    1       2       3       4
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!

C CREATES IPOBO, WHICH MAKES IT POSSIBLE TO GO FROM GLOBAL TO LOCAL NUMBER

      DO IPOIN=1,NPOINT
        IPOBO(IPOIN) = 0
      ENDDO

      DO K = 1, NPTFR
         IPOBO(NBOR(K)) = K
      ENDDO


C BUILDS NELBOR, NULONE, IKLBORD
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      IELEB = 0

      DO IELEM = 1,NBTET
         DO J = 1,4
            IF (IFABOR(IELEM,J)== 0) THEN
               IELEB           = IELEB +1
               IF ( IELEB .GT. NBTRI ) THEN
                 IF(LNG.EQ.1) WRITE(LU,101)
                 IF(LNG.EQ.2) WRITE(LU,102)
101              FORMAT(1X,'ELEBD31_PARTEL : ERREUR DANS LE MAILLAGE ')
102              FORMAT(1X,'ELEBD31_PARTEL : ERROR IN MESH. BYE.')
                 CALL PLANTE2(1)
                 STOP
               END IF
               NELBOR(IELEB)   = IELEM
               NULONE(IELEB,1) = SOMFAC(1,J)
               NULONE(IELEB,2) = SOMFAC(2,J)
               NULONE(IELEB,3) = SOMFAC(3,J)
               IKLBOR(IELEB,1) = IPOBO(IKLE(NELBOR(IELEB),SOMFAC(1,J)))
               IKLBOR(IELEB,2) = IPOBO(IKLE(NELBOR(IELEB),SOMFAC(2,J)))
               IKLBOR(IELEB,3) = IPOBO(IKLE(NELBOR(IELEB),SOMFAC(3,J)))

            END IF
         END DO
      END DO

!
!-----------------------------------------------------------------------
!
      RETURN
      END SUBROUTINE ELEBD31_PARTEL



C
C#######################################################################
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @brief       BUILDS THE ARRAY IFABOR, WHERE IFABOR (IELEM, IFACE)
!>                IS THE GLOBAL NUMBER OF THE NEIGHBOUR OF SIDE IFACE
!>                OF ELEMENT IELEM (IF THIS NEIGHBOUR EXISTS) AND 0 IF
!>                THE SIDE IS ON THE DOMAIN BOUNDARY.

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Variable(s)
!>  <br><table>
!>     <tr><th> Argument(s)
!>    </th><td> IFABOR, IKLE, NBOR, NBTET, NELMAX, NPOIN, NPTFR, SIZIKL
!>   </td></tr>
!>     <tr><th> Common(s)
!>    </th><td>
!> INFO : LNG, LU
!>   </td></tr>
!>     <tr><th> Internal(s)
!>    </th><td> ADR, BORD, COMPT, ERR, FOUND, I, I1, I2, I3, IADR, IELEM, IELEM2, IFACE, IFACE2, IKLE_TRI, IMAX, INOEUD, IPOIN, IR1, IR2, IR3, IR4, IR5, IR6, ITRI, IVOIS, J, K, M1, M2, M3, NB_TRI, NEIGH, NFACE, NMXVOISIN, NV, NVOIS, SOMFAC, VOIS_TRI
!>   </td></tr>
!>     </table>

!>  @par Call(s)
!>  <br><table>
!>     <tr><th> Known(s)
!>    </th><td> PLANTE2()
!>   </td></tr>
!>     </table>

!>  @par Called by
!><br>PARES3D()

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
!>  <tr>
!>    <th> 5.6                                                     </th>
!>    <th> 02/03/2006                                              </th>
!>    <th> REGINA NEBAUER (LNHE) 01 30 87 83 93                    </th>
!>    <th>                                                         </th>
!>  </table>

C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!>  @par Details of primary variable(s)
!>  <br><table>
!>
!>     <tr><th>Name(s)</th><th>(in-out)</th><th>Description</th></tr>
!>          <tr><td>IELM
!></td><td>--></td><td>31: TETRAEDRES NON STRUCTURES
!>    </td></tr>
!>          <tr><td>IFABOR
!></td><td><--</td><td>TABLEAU DES VOISINS DES FACES.
!>                  (CAS DES MAILLAGES ADAPTATIFS)
!>    </td></tr>
!>          <tr><td>IKLE
!></td><td>--></td><td>TABLE DE CONNECTIVITE DOMAINE
!>    </td></tr>
!>          <tr><td>IKLETR,NBTRI
!></td><td>---</td><td>-->/ CONNECTIVITE DES TRIA DE BORD POUR ESTEL3D
!>    </td></tr>
!>          <tr><td>NACHB
!></td><td>--></td><td>TABLEAU DE VOISINAGE POUR PARALLELISME
!>    </td></tr>
!>          <tr><td>NBOR
!></td><td>--></td><td>CORRESPONDANCE NO NOEUD DE BORD/NO GLOBAL
!>    </td></tr>
!>          <tr><td>NBTET
!></td><td>--></td><td>NOMBRE D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NELMAX
!></td><td>--></td><td>NOMBRE MAXIMUM D'ELEMENTS DANS LE MAILLAGE.
!>    </td></tr>
!>          <tr><td>NPOIN
!></td><td>--></td><td>NOMBRE TOTAL DE POINTS DU DOMAINE
!>    </td></tr>
!>          <tr><td>NPTFR
!></td><td>--></td><td>NOMBRE DE POINTS DE BORD
!>    </td></tr>
!>          <tr><td>SIZIKL
!></td><td>---</td><td>
!>    </td></tr>
!>          <tr><td>SIZIKLE
!></td><td>--></td><td>??
!>    </td></tr>
!>     </table>
C
C#######################################################################
C
                        SUBROUTINE VOISIN31_PARTEL
     &(IFABOR,NBTET,NELMAX,IKLE,SIZIKL,
     & NPOIN,NBOR,NPTFR)
C
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C| IELM           |-->| 31: TETRAEDRES NON STRUCTURES
C| IFABOR         |<--| TABLEAU DES VOISINS DES FACES.
C|                |   | (CAS DES MAILLAGES ADAPTATIFS)
C| IKLE           |-->| TABLE DE CONNECTIVITE DOMAINE
C| IKLETR,NBTRI   |---| -->/ CONNECTIVITE DES TRIA DE BORD POUR ESTEL3D
C| NACHB          |-->| TABLEAU DE VOISINAGE POUR PARALLELISME
C| NBOR           |-->| CORRESPONDANCE NO NOEUD DE BORD/NO GLOBAL
C| NBTET          |-->| NOMBRE D'ELEMENTS DANS LE MAILLAGE.
C| NELMAX         |-->| NOMBRE MAXIMUM D'ELEMENTS DANS LE MAILLAGE.
C| NPOIN          |-->| NOMBRE TOTAL DE POINTS DU DOMAINE
C| NPTFR          |-->| NOMBRE DE POINTS DE BORD
C| SIZIKL         |---| 
C| SIZIKLE        |-->| ??
C~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
C
      INTEGER, INTENT(IN   ) :: NPTFR
      INTEGER, INTENT(IN   ) :: NBTET
      INTEGER, INTENT(IN   ) :: NELMAX
      INTEGER, INTENT(IN   ) :: NPOIN
      INTEGER, INTENT(IN   ) :: SIZIKL
      INTEGER, INTENT(IN), DIMENSION(NPTFR) :: NBOR
      ! NOTE : EXPLICITLY GIVES THE 2ND DIMENSION OF IFABOR AND
      ! IKLE, BECAUSE THEY WILL ALWAYS BE TETRAHEDRONS!
      INTEGER, INTENT(OUT), DIMENSION(NELMAX,4) :: IFABOR
      INTEGER, INTENT(IN), DIMENSION(SIZIKL,4)  :: IKLE
!
C LOCAL VARIABLES
!-----------------------------------------------------------------------

      ! REVERSE ARRAY FROM NBOR
      ! (FOR EACH DOMAIN NODE, GIVES THE BOUNDARY NODE NUMBER
      ! OR 0 IF THE NODE IS INTERIOR)
C$$$      INTEGER, DIMENSION(NPOIN)            :: NBOR_INV

      ! ARRAY DEFINING THE NUMBER OF ELEMENTS (TETRAHEDRONS)
      ! NEIGHBOURING A NODE
      INTEGER, DIMENSION(:  ), ALLOCATABLE  :: NVOIS
      ! ARRAY DEFINING THE IDENTIFIERS OF THE ELEMENTS NEIGHBOURING
      ! EACH NODE
      INTEGER, DIMENSION(:  ), ALLOCATABLE :: NEIGH

      INTEGER, DIMENSION(:,:), ALLOCATABLE :: IKLE_TRI

      INTEGER, DIMENSION(:,:), ALLOCATABLE :: VOIS_TRI

      ! ARRAY DEFINING THE ADDRESSES OF DIFFERENT ENTRIES IN
      ! ARRAY NEIGH
      INTEGER, DIMENSION(NPOIN)            :: IADR
      ! VALUE OF AN ENTRY IN THIS ARRAY
      INTEGER                              :: ADR

      ! MAXIMUM NUMBER OF ELEMENTS NEIGHBOURING A NODE
      INTEGER :: NMXVOISIN
      INTEGER :: IMAX       ! SIZE OF ARRAY IADR

      INTEGER :: NFACE      ! NUMBER OF ELEMENT SIDES (TETRA: 4)
      INTEGER :: NB_TRI     ! NUMBER OF DEFINED TRIANGLES

      INTEGER :: IELEM      ! ELEMENTS COUNTER
      INTEGER :: IELEM2     ! ELEMENTS COUNTER
      INTEGER :: IPOIN      ! DOMAIN NODES COUNTER
      INTEGER :: INOEUD     ! TETRAS/TRIAS NODES COUNTER
      INTEGER :: IFACE      ! SIDE COUNTER
      INTEGER :: IFACE2     ! SIDE COUNTER
      INTEGER :: ITRI       ! TRIANGLES COUNTER
      INTEGER :: IVOIS      ! NEIGHBOURS COUNTER
      INTEGER :: NV         ! NUMBER OF NEIGHBOURS

      INTEGER :: ERR        ! MEMORY ALLOCATION ERROR CODE

      LOGICAL :: FOUND      ! FOUND OR NOT ...

      INTEGER :: I1, I2, I3 ! THE 3 NODES OF A TRIANGLE
      INTEGER :: M1, M2, M3 ! SAME THING, ORDERED

      INTEGER :: I,J,K      ! ARE USED ...

      !????
      INTEGER :: IR1,IR2,IR3,IR4,IR5,IR6,COMPT
      LOGICAL :: BORD


!   ~~~~~~~~~~~~~~~~~~~~~~~
C     DEFINES THE 4 TRIANGLES OF THE TETRAHEDRON: THE 1ST ARRAY
C     DIMENSION IS THE NUMBER OF THE TRIANGLE; THE 2ND GIVES
C     THE NUMBERS OF THE TETRAHEDRON NODES THAT DEFINE IT.
      INTEGER SOMFAC(3,4)
      DATA SOMFAC /  1,2,3 , 4,1,2 , 2,3,4 , 3,4,1   /
!-----------------------------------------------------------------------
C START
!-----------------------------------------------------------------------
!
!
!-----------------------------------------------------------------------
C STEP 1: COUNTS THE NUMBER OF ELEMENTS NEIGHBOURING A NODE
!-----------------------------------------------------------------------
C COMPUTES THE NUMBER OF ELEMENTS NEIGHBOURING EACH NODE OF THE MESH.
C RESULT: NVOIS(INOEUD) GIVES THE NUMBER OF ELEMENTS NEIGHBOURING
C NODE INOEUD

      ! INITIALISES THE NEIGHBOURING ELEMENT COUNTER TO 0
      !

      NFACE = 4
!
      ALLOCATE(NVOIS(NPOIN),STAT=ERR)
      IF(ERR.NE.0) GOTO 999
!
      DO I = 1, NPOIN
        NVOIS(I) = 0
      ENDDO
      ! COUNTS THE NEIGHBOURING ELEMENTS
      ! USING THE CONNECTIVITY TABLE, THE COUNTER IS INCREMENTED
      ! EACH TIME THAT AN ELEMENT REFERENCES NODE IPOIN

      ! LOOP ON THE 4 NODES OF THE ELEMENT
      DO INOEUD = 1, 4
        ! LOOP ON THE ELEMENTS
        DO IELEM = 1,NBTET
          ! THE ID OF NODE I OF ELEMENT IELEM
          IPOIN        = IKLE( IELEM , INOEUD )
          ! INCREMENTS THE COUNTER
          NVOIS(IPOIN) = NVOIS(IPOIN) + 1
        END DO
      END DO

!-----------------------------------------------------------------------
C STEP 2: DETERMINES THE SIZE OF ARRAY NEIGH() AND OF AUXILIARY
C ARRAY TO INDEX NEIGH. ALLOCATES NEIGH
!-----------------------------------------------------------------------
C CREATES AN ARRAY WHICH WILL CONTAIN THE IDENTIFIERS OF THE ELEMENTS
C NEIGHBOURING EACH NODE. SINCE THE NUMBER OF NEIGHBOURS IS A PRIORI
C DIFFERENT FOR EACH NODE, AND IN AN EFFORT NOT TO CREATE A (TOO) BIG
C ARRAY FOR NO REASON, AN AUXILIARY ARRAY IS REQUIRED THAT GIVES THE
C ADDRESS OF THE ENTRIES FOR A GIVEN NODE. THIS ARRAY HAS AS MANY
C ENTRIES AS THERE ARE NODES.
C WILL ALSO COMPUTE THE MAXIMUM NUMBER OF NEIGHBOURS, SOME TIME.

      ! THE FIRST ENTRY IN THE ID OF THE NEIGHBOURS ARRAY IS 1
      ADR       = 1
      IADR(1)   = ADR
      ! THE MAX NUMBER OF NEIGHBOURING ELEMENTS
      NV        = NVOIS(1)
      NMXVOISIN = NV

      DO IPOIN = 2,NPOIN
          ! ADDRESS FOR THE OTHER ENTRIES:
          ADR         = ADR + NV
          IADR(IPOIN) = ADR
          NV          = NVOIS(IPOIN)
          ! IDENTIFIES THE MAX. NUMBER OF NEIGHBOURS
          NMXVOISIN   = MAX(NMXVOISIN,NV)
      END DO

      ! THE TOTAL NUMBER OF NEIGHBOURING ELEMENTS FOR ALL THE NODES
      ! GIVES THE SIZE OF THE NEIGHBOURS ARRAY:

      IMAX = IADR(NPOIN) + NVOIS(NPOIN)

      ! ALLOCATES THE ARRAY CONTAINING THE IDENTIFIERS OF THE ELEMENTS
      ! NEIGHBOURING EACH NODE
      ALLOCATE(NEIGH(IMAX),STAT=ERR)
      IF(ERR.NE.0) GOTO 999
!
!-----------------------------------------------------------------------
C STEP 3: INITIALISES NEIGH
!-----------------------------------------------------------------------
C NEEDS TO FILL NEIGH NOW THAT IT'S BEEN ALLOCATED: I.E.
C STARTS AGAIN THE LOOP ON THE 4 NODES OF EACH ELEMENT AND THIS
C TIME, ALSO STORES THE IDENTIFIER IN ARRAY NEIGH.
!
!
      ! RE-INITIALISES THE COUNTER OF THE NEIGHBOURING ELEMENTS TO 0,
      ! TO KNOW WHERE WE ARE AT
      NVOIS(:) = 0

      ! FOR EACH NODE OF THE ELEMENTS, STORES THE IDENTIFIER
      DO INOEUD = 1, 4  ! LOOP ON THE ELEMENT NODES
        DO IELEM=1,NBTET ! LOOP ON THE ELEMENTS
          IPOIN     = IKLE( IELEM , INOEUD )
          ! ONE MORE NEIGHBOUR
          NV           = NVOIS(IPOIN) + 1
          NVOIS(IPOIN) = NV
          ! STORES THE IDENTIFIER OF THE NEIGHBOURING ELEMENT IN THE ARRAY
          NEIGH(IADR(IPOIN)+NV) = IELEM
        END DO ! END OF LOOP ELEMENTS
      END DO  ! END OF LOOP NODES

!
!-----------------------------------------------------------------------
C STEP 4: IDENTIFIES COMMON FACES OF THE TETRAHEDRONS AND FILLS IN
C ARRAY IFABOR
!-----------------------------------------------------------------------
C TO IDENTIFY FACES COMMON TO THE ELEMENTS :
C FROM THE ELEMENTS THAT SHARE A NODE, AT LEAST 2 SHARE A FACE
C (IF THE NODE IS NOT A BOUNDARY NODE).
C THE ALGORITHM PRINCIPLE:
C BUILDS THE TRIANGLES OF THE TETRAHEDRON FACES, ONCE HAVE IDENTIFIED
C THOSE THAT SHARE NODE IPOIN.
C IF 2 TRIANGLES SHARE THE SAME NODES, IT MEANS THAT THE TETRAHEDRONS
C DEFINING THEM ARE NEIGHBOURS.
C IF NO NEIGHBOUR CAN BE FOUND, IT MEANS THAT THE TRIANGLE IS A
C BOUNDARY FACE.
C BASED ON THE ASSUMPTION THAT A TRIANGLE CANNOT BE DEFINED BY MORE
C THAN 2 TETRAHEDRONS.
C IF THAT WAS NOT THE CASE, IT WOULD MEAN THAT THERE WAS A PROBLEM WITH
C THE MESH; AND THIS IS NOT CATERED FOR ...
!
C ADVANTAGES:
C SAVES QUITE A BIT OF MEMORY, BY STORING THE TRIANGLES AROUND A NODE.
C DISADVANTAGES:
C COULD BE DOING TOO MANY (USELESS) COMPUTATIONS (TO GET TO THE STAGE
C WHERE THE CONNECTIVITY TABLE FOR THE TRIANGLES IS DEFINED)
C COULD MAYBE SKIP THIS STEP BY CHECKING IF IFABOR ALREADY CONTAINS
C SOMETHING OR NOT ...
!
C BUILDS THE CONNECTIVITY TABLE FOR THE TRIANGLES
C THIS CONNECTIVITY TABLE IS NOT SUPPOSED TO MAKE A LIST OF ALL
C THE TRIANGLES, BUT MERELY THOSE AROUND A NODE.
C THE MAXIMUM NUMBER OF (TETRAHEDRONS) NEIGHBOURS IS KNOWN FOR A
C NODE. IN THE WORST CASE, THE NODE IS A BOUNDARY NODE.
C WILL MAXIMISE (A LOT) BY ASSUMING THAT THE MAXIMUM NUMBER OF
C TRIANGLES AROUND A NODE CAN BE THE NUMBER OF NEIGHBOURING
C TETRAHEDRONS.
C ALSO BUILDS THE ARRAY VOIS_TRI CONTAINING THE ID OF THE TETRAHEDRON
C ELEMENT THAT DEFINED IT FIRST (AND THAT WILL BE NEIGHBOUR TO THE
C TETRAHEDRON THAT WILL FIND THAT ANOTHER ONE ALREADY DEFINES IT)
C THIS ARRAY HAS 2 ENTRIES : THE ID OF THE ELEMENT AND THE ID OF THE SIDE.
!
      NB_TRI = NMXVOISIN * 3
!
      ALLOCATE(IKLE_TRI(NB_TRI,3),STAT=ERR)
      IF(ERR.NE.0) GOTO 999
      ALLOCATE(VOIS_TRI(NB_TRI,2),STAT=ERR)
      IF(ERR.NE.0) GOTO 999

      IFABOR(:,:) = 0
!
      ! LOOP ON ALL THE NODES IN THE MESH
      DO IPOIN = 1, NPOIN
          ! FOR EACH NODE, CHECKS THE NEIGHBOURING TETRAHEDRON ELEMENTS
          ! (MORE PRECISELY: THE TRIANGULAR FACES THAT MAKE IT)
          ! RE-INITIALISES THE CONNECTIVITY TABLE FOR THE TETRAHEDRON
          ! TRIANGLES TO 0, AND THE NUMBER OF TRIANGLES WHICH HAVE BEEN
          ! FOUND:
          !
          IKLE_TRI(:,:) = 0
          ! SAME THING FOR THE ARRAY THAT IDENTIFIES WHICH ELEMENT HAS
          ! ALREADY DEFINED THE TRIANGLE :
          VOIS_TRI(:,:) = 0
          ! STARTS COUNTING THE TRIANGLES AGAIN:
          NB_TRI         = 0
          NV            = NVOIS(IPOIN)
          ADR           = IADR(IPOIN)
          DO IVOIS = 1, NV
              ! THE IDENTIFIER OF THE NEIGHBOURING ELEMENT IVOIS TO
              ! NODE IPOIN:
              IELEM = NEIGH(ADR+IVOIS)
              ! LOOP ON THE 4 SIDES OF THIS ELEMENT
              DO IFACE = 1 , NFACE
                  ! IF THIS SIDE ALREADY HAS A NEIGHBOUR, THAT'S
                  ! ENOUGH AND GOES TO NEXT.
                  ! OTHERWISE, LOOKS FOR IT...
                  IF ( IFABOR(IELEM,IFACE) .EQ. 0 ) THEN
                  ! EACH FACE DEFINES A TRIANGLE. THE TRIANGLE IS
                  ! GIVEN BY 3 NODES.
                  I1 = IKLE(IELEM,SOMFAC(1,IFACE))
                  I2 = IKLE(IELEM,SOMFAC(2,IFACE))
                  I3 = IKLE(IELEM,SOMFAC(3,IFACE))
                  ! THESE 3 NODES ARE ORDERED, M1 IS THE NODE WITH
                  ! THE SMALLEST IDENTIFIER, M3 THAT WITH THE
                  ! LARGEST IDENTIFIER AND M2 IS IN THE MIDDLE:
                  M1 = MAX(I1,(MAX(I2,I3)))
                  M3 = MIN(I1,(MIN(I2,I3)))
                  M2 = I1+I2+I3-M1-M3
                  ! GOES THROUGH THE ARRAY WITH TRIANGLES ALREADY DEFINED
                  ! TO SEE IF ONE OF THEM BEGINS WITH M1.
                  ! IF THAT'S THE CASE, CHECKS THAT IT ALSO HAS NODES
                  ! M2 AND M3. IF THAT'S THE CASE, HAS FOUND A NEIGHBOUR.
                  ! OTHERWISE, A NEW TRIANGLE ENTRY IS CREATED.
                  !

                  FOUND = .FALSE.
                  DO ITRI = 1, NB_TRI
                      IF ( IKLE_TRI(ITRI,1) .EQ. M1 ) THEN
                          IF ( IKLE_TRI(ITRI,2) .EQ. M2 .AND.
     &                         IKLE_TRI(ITRI,3) .EQ. M3 ) THEN
                               ! FOUND IT! ALL IS WELL.
                               ! STORES THE INFORMATION IN VOIS_TRI.
                               ! (I.E. THE ELEMENT THAT HAS ALREADY
                               ! DEFINED THE TRIANGLE AND THE FACE)
                               IELEM2 = VOIS_TRI(ITRI,1)
                               IFACE2 = VOIS_TRI(ITRI,2)
                               IF ( IELEM2 .EQ. IELEM ) THEN
                                  IF(LNG.EQ.1) WRITE(LU,908) 31
                                  IF(LNG.EQ.2) WRITE(LU,909) 31
908                               FORMAT(1X,'VOISIN: IELM=',1I6,',
     &                            PROBLEME DE VOISIN')
909                               FORMAT(1X,'VOISIN: IELM=',1I6,',
     &                            NEIGHBOUR PROBLEM')
                                  CALL PLANTE2(1)
                                  STOP
                               END IF
                               ! TO BE SURE :
                               IF ( IELEM2 .EQ. 0 .OR.
     &                              IFACE2 .EQ. 0 ) THEN
                                IF(LNG.EQ.1) WRITE(LU,918) IELEM2,IFACE2
                                IF(LNG.EQ.2) WRITE(LU,919) IELEM2,IFACE2
918                            FORMAT(1X,'VOISIN31:TRIANGLE NON DEFINI,
     &                         IELEM=',1I6,'IFACE=',1I6)
919                            FORMAT(1X,'VOISIN31:UNDEFINED TRIANGLE,
     &                         IELEM=',1I6,'IFACE=',1I6)
                                CALL PLANTE2(1)
                                STOP
                               END IF
                               ! THE ELEMENT AND ITS NEIGHBOUR : STORES
                               ! THE CONNECTION IN IFABOR.
                               IFABOR(IELEM ,IFACE ) = IELEM2
                               IFABOR(IELEM2,IFACE2) = IELEM
                               FOUND = .TRUE.
                          END IF
                      END IF
                  END DO
                  ! NO, THIS TRIANGLE WAS NOT ALREADY THERE; THEREFORE
                  ! CREATES A NEW ENTRY.
                  IF ( .NOT. FOUND) THEN
                      NB_TRI             = NB_TRI + 1
                      IKLE_TRI(NB_TRI,1) = M1
                      IKLE_TRI(NB_TRI,2) = M2
                      IKLE_TRI(NB_TRI,3) = M3
                      VOIS_TRI(NB_TRI,1) = IELEM
                      VOIS_TRI(NB_TRI,2) = IFACE
                  END IF
              END IF ! IFABOR 0
              END DO ! END OF LOOP ON FACES OF THE NEIGHBOURING ELEMENTS
!
          END DO ! END OF LOOP ON ELEMENTS NEIGHBOURING THE NODE
      END DO ! END OF LOOP ON NODES
!
      DEALLOCATE(NEIGH)
      DEALLOCATE(IKLE_TRI)
      DEALLOCATE(VOIS_TRI)
!
!
!-----------------------------------------------------------------------
!
C  IFABOR DISTINGUISHES BETWEEN THE BOUNDARY FACES AND THE LIQUID FACES
!
C  INITIALISES NBOR_INV TO 0
!
C      DO IPOIN=1,NPOIN
C        NBOR_INV(IPOIN) = 0
C      ENDDO
!
C  CONNECTS GLOBAL NUMBERING TO BOUNDARY NUMBERING
!
C      DO K = 1, NPTFR
C         NBOR_INV(NBOR(K)) = K
C      ENDDO
!
C  LOOP ON ALL THE SIDES OF ALL THE ELEMENTS:
!
C      DO 90 IFACE = 1 , NFACE
C      DO 100 IELEM = 1 , NBTET
!
C      IF(IFABOR(IELEM,IFACE).EQ.-1) THEN
!
C      IT IS A TRUE BOUNDARY SIDE (IN PARALLEL MODE THE INTERNAL SIDES
C                                  ARE INDICATED WITH -2).
C      GLOBAL NUMBERS OF THE NODES OF THE SIDE :
!
C       I1 = IKLE( IELEM , SOMFAC(1,IFACE) )
C       I2 = IKLE( IELEM , SOMFAC(2,IFACE) )
C       I3 = IKLE( IELEM , SOMFAC(3,IFACE) )
!
C      ENDIF
!
C100    CONTINUE
C90    CONTINUE
!
!-----------------------------------------------------------------------
!
      RETURN
!
!-----------------------------------------------------------------------
!
999   IF(LNG.EQ.1) WRITE(LU,1000) ERR
      IF(LNG.EQ.2) WRITE(LU,2000) ERR
1000  FORMAT(1X,'VOISIN31 : ERREUR A L''ALLOCATION DE MEMOIRE :',/,1X,
     &            'CODE D''ERREUR : ',1I6)
2000  FORMAT(1X,'VOISIN31: ERROR DURING ALLOCATION OF MEMORY: ',/,1X,
     &            'ERROR CODE: ',1I6)
      CALL PLANTE2(1)
      STOP
!
!-----------------------------------------------------------------------
!
      END
C
C#######################################################################
C