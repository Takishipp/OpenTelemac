!                    ***************************
                     SUBROUTINE READ_FIC_SOURCES
!                    ***************************
!
     &( Q , WHAT , AT , NFIC , LISTIN , STAT )
!
!***********************************************************************
! TELEMAC2D   V6P2                                   07/10/2011
!***********************************************************************
!
!brief    READS AND INTERPOLATES VALUES IN THE SOURCE FILE.
!
!note     IMPORTANT: THIS SUBROUTINE IS A COPY OF
!+            SUBROUTINE READ_FIC_FRLIQ BECAUSE IT USES THE SAME
!+            FILE FORMAT (LISTING MESSAGES ONLY ARE CHANGED).
!+            THE ONLY DIFFERENCE IS THAT
!+            THE ALLOCATABLE ARRAYS TIME AND INFIC WILL HERE
!+            STORE DIFFERENT DATA.
!+
!note     THE PROBLEM IS : WHERE TO STORE THESE DATA BECAUSE
!+            THESE ROUTINES MAY BE CALLED BY TELEMAC-2D OR 3D
!+            A SPECIFIC MODULE COULD BE DONE
!
!history  J-M HERVOUET (LNHE)
!+        17/03/2004
!+        V5P9
!+
!
!history  J-M HERVOUET (LNHE)
!+        28/06/2010
!+        V6P0
!+   SIZE OF LINE PARAMETERIZED (SEE SIZELIGN)
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
!history  C. COULET (ARTELIA GROUP)
!+        07/10/2011
!+        V6P2
!+   Modification size WHAT and CHOIX due to modification of TRACER
!+    numbering TRACER is now identified by 2 values (Isource, Itracer)
!+   So MAXVAL is now equal to MAXSCE+MAXSCE*MAXTRA
!
!history  U.H.Merkel
!+        17/07/2012
!+        V6P2 + NAG: MAXVAL intrinsic! -> MAXVALUE
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AT             |-->| TIME IN SECONDS
!| LISTIN         |-->| IF YES, PRINTS INFORMATION
!| NFIC           |-->| LOGICAL UNIT OF FILE
!| Q              |<--| VARIABLE READ AND INTERPOLATED
!| STAT           |<--| IF FALSE: VARIABLE NOT FOUND
!| WHAT           |-->| VARIABLE TO LOOK FOR IN 9 CHARACTERS
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      CHARACTER*9     , INTENT(IN)       :: WHAT
      DOUBLE PRECISION, INTENT(IN)       :: AT
      DOUBLE PRECISION, INTENT(INOUT)    :: Q
      INTEGER         , INTENT(IN)       :: NFIC
      LOGICAL         , INTENT(IN)       :: LISTIN
      LOGICAL         , INTENT(OUT)      :: STAT
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      LOGICAL, SAVE :: DEJA=.FALSE.
!
!     MAXIMUM NUMBER OF CHARACTERS PER LIGN (MAY BE CHANGED)
!
      INTEGER, PARAMETER :: SIZELIGN = 3000
!
      INTEGER IVALUE,NVALUE,ILIG,NLIG,OK,J,IWHAT,IDEB,IFIN,IL1,IL2
      INTEGER, PARAMETER :: MAXVALUE=2100
      DOUBLE PRECISION TL1,TL2,TETA,TOL,LASTAT
!
      CHARACTER(LEN=SIZELIGN) :: LIGNE
      CHARACTER*9 CHOIX(MAXVALUE),LASTWHAT
!
      DATA TOL /1.D-3/
!
      DOUBLE PRECISION, DIMENSION(:,:), ALLOCATABLE :: INFIC
      DOUBLE PRECISION, DIMENSION(:)  , ALLOCATABLE :: TIME
!
      SAVE INFIC,TIME,CHOIX,IL1,IL2,TL1,TL2,NVALUE,LASTWHAT,LASTAT,NLIG
!
      INTRINSIC ABS
!
!-----------------------------------------------------------------------
!
!     1) (AT FIRST CALL)
!        READS THE SOURCE FILE
!        INITIALISES CURRENT LINES AND INTERVAL OF TIME
!
      IF(.NOT.DEJA) THEN
        REWIND(NFIC)
!       SKIPS COMMENTS
1       READ(NFIC,FMT='(A)') LIGNE
        IF(LIGNE(1:1).EQ.'#') GO TO 1
!
!       FINDS OUT WHAT AND HOW MANY VALUES ARE GIVEN IN THE FILE
!
        NVALUE = -1
        IFIN = 1
40      IDEB = IFIN
!
!       IDENTIFIES FIRST CHARACTER OF NAME
50      IF(LIGNE(IDEB:IDEB).EQ.' '.AND.IDEB.LT.SIZELIGN) THEN
          IDEB=IDEB+1
          GO TO 50
        ENDIF
!       IDENTIFIES LAST CHARACTER OF NAME
        IFIN = IDEB
60      IF(LIGNE(IFIN:IFIN).NE.' '.AND.IFIN.LT.SIZELIGN) THEN
          IFIN=IFIN+1
          GO TO 60
        ENDIF
!
        IF(IDEB.EQ.IFIN) GO TO 4
!
        NVALUE = NVALUE + 1
        IF(NVALUE.EQ.0) THEN
          IF(LIGNE(IDEB:IFIN-1).NE.'T') THEN
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'LA PREMIERE VARIABLE DOIT ETRE LE TEMPS T'
            WRITE(LU,*) 'DANS LE FICHIER DES SOURCES'
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'FIRST VALUE MUST BE TIME, DENOTED T'
            WRITE(LU,*) 'IN SOURCES FILE'
          ENDIF
          CALL PLANTE(1)
          STOP
          ENDIF
        ELSEIF(NVALUE.LE.MAXVALUE) THEN
          CHOIX(NVALUE)='         '
          CHOIX(NVALUE)(1:IFIN-IDEB+1)=LIGNE(IDEB:IFIN-1)
        ELSE
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'AUGMENTER MAXVALUE DANS READ_FIC_SOURCES'
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'INCREASE MAXVALUE IN READ_FIC_SOURCES'
          ENDIF
          CALL PLANTE(1)
          STOP
        ENDIF
        IF(IFIN.LT.SIZELIGN) GO TO 40
!
!       SKIPS THE LINE WITH UNITS OR NAMES
4       READ(NFIC,FMT='(A)') LIGNE
        IF(LIGNE(1:1).EQ.'#') GO TO 4
!
!       COUNTS LINES OF DATA
        NLIG = 0
998     READ(NFIC,*,END=1000,ERR=999) LIGNE
        IF(LIGNE(1:1).NE.'#') NLIG=NLIG+1
        GO TO 998
999     CONTINUE
        IF(LNG.EQ.1) THEN
          WRITE(LU,*) 'ERREUR DE LECTURE SUR LE FICHIER DES SOURCES'
          WRITE(LU,*) 'LIQUIDES A LA LIGNE DE DONNEES : ',NLIG
          WRITE(LU,*) '(COMMENTAIRES NON COMPTES)'
        ENDIF
        IF(LNG.EQ.2) THEN
          WRITE(LU,*) 'READING ERROR ON THE SOURCES FILE'
          WRITE(LU,*) 'AT LINE OF DATA : ',NLIG
          WRITE(LU,*) '(COMMENTS EXCLUDED)'
        ENDIF
        CALL PLANTE(1)
        STOP
1000    CONTINUE
!
!       DYNAMICALLY ALLOCATES TIME AND INFIC
!
        ALLOCATE(TIME(NLIG),STAT=OK)
        IF(OK.NE.0) WRITE(LU,*) 'MEMORY ALLOCATION ERROR FOR TIME'
        ALLOCATE(INFIC(NVALUE,NLIG),STAT=OK)
        IF(OK.NE.0) WRITE(LU,*) 'MEMORY ALLOCATION ERROR FOR INFIC'
!
!       FINAL READ OF TIME AND INFIC
!
        REWIND(NFIC)
!       SKIPS COMMENTS AND FIRST TWO MANDATORY LINES
2       READ(NFIC,FMT='(A)') LIGNE
        IF(LIGNE(1:1).EQ.'#') GO TO 2
        READ(NFIC,FMT='(A)') LIGNE
!
        DO ILIG=1,NLIG
3         READ(NFIC,FMT='(A)') LIGNE
          IF(LIGNE(1:1).EQ.'#') THEN
            GO TO 3
          ELSE
            BACKSPACE(NFIC)
            READ(NFIC,*) TIME(ILIG),(INFIC(IVALUE,ILIG),IVALUE=1,NVALUE)
          ENDIF
        ENDDO
!
        CLOSE(NFIC)
        DEJA = .TRUE.
!
        IL1 = 1
        IL2 = 2
        TL1 = TIME(1)
        TL2 = TIME(2)
!
      ENDIF
!
!-----------------------------------------------------------------------
!
!     2) INTERPOLATES THE DATA TO GET THE CORRECT TIME
!
!     2.A) FINDS THE ADDRESS IN THE ARRAY OF STORED DATA
!
!     2.B) INTERPOLATES DATA OF THE ARRAY INFIC
!
!-----------------------------------------------------------------------
!
!
!     WHICH VARIABLE ?
      IWHAT = 0
      DO J=1,NVALUE
        IF(WHAT.EQ.CHOIX(J)) IWHAT=J
      ENDDO
      IF(IWHAT.EQ.0) THEN
        STAT=.FALSE.
        RETURN
      ENDIF
!
70    IF(AT.GE.TL1-TOL.AND.AT.LE.TL2+TOL) THEN
        TETA = (AT-TL1)/(TL2-TL1)
      ELSE
         DO J=1,NLIG-1
            IF(AT.GE.TIME(J)-TOL.AND.AT.LE.TIME(J+1)+TOL) THEN
               TL1=TIME(J)
               TL2=TIME(J+1)
               IL1=J
               IL2=J+1
               GO TO 70
            ENDIF
         ENDDO
         IL1=IL2
         IL2=IL2+1
        IF(IL2.GT.NLIG) THEN
          IF(LNG.EQ.1) THEN
            WRITE(LU,*) 'T=',AT,' HORS LIMITES'
            WRITE(LU,*) 'DU FICHIER DES SOURCES'
          ENDIF
          IF(LNG.EQ.2) THEN
            WRITE(LU,*) 'T=',AT,' OUT OF RANGE'
            WRITE(LU,*) 'OF THE SOURCES FILE'
          ENDIF
          CALL PLANTE(1)
          STOP
        ENDIF
        TL1=TIME(IL1)
        TL2=TIME(IL2)
        GO TO 70
      ENDIF
!
      Q = (1.D0-TETA)*INFIC(IWHAT,IL1)
     &  +       TETA *INFIC(IWHAT,IL2)
!
      STAT=.TRUE.
!
!     PRINTS ONLY IF NEW TIME OR NEW VALUE IS ASKED
!
      IF(LISTIN) THEN
        IF(ABS(AT-LASTAT).GT.TOL.OR.LASTWHAT.NE.WHAT) THEN
          WRITE(LU,*) 'SOURCES : ',WHAT,'=',Q
        ENDIF
      ENDIF
      LASTAT=AT
      LASTWHAT=WHAT
!
!-----------------------------------------------------------------------
!
      RETURN
      END
