!                    **********************
                     SUBROUTINE READ_SUBMIT
!                    **********************
!
     &(FILES,NFILES,CODE,SUBMIT,NMOT)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    OPENS THE FILES DECLARED IN THE STEERING FILE.
!
!note     THE STEERING AND DICTIONNARY FILES ARE OPENED AND
!+         CLOSED IN LECDON.
!
!history  J-M HERVOUET (LNHE)
!+        27/03/2009
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
!| CODE           |-->| NAME OF CALLING PROGRAMME
!| FILES          |-->| FILES STRUCTURES
!| NFILES         |-->| NUMBER OF FILES IN ARRAY FILES
!| NMOT           |-->| SECOND DIMENSION OF SUBMIT AND MOTCAR
!| SUBMIT         |-->| CHARACTER STRINGS STEMMING FROM DICTIONARY
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      USE BIEF, EX_READ_SUBMIT => READ_SUBMIT
      USE DECLARATIONS_TELEMAC
!
      IMPLICIT NONE
      INTEGER     LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER           , INTENT(IN) :: NFILES,NMOT
      TYPE(BIEF_FILE), INTENT(INOUT) :: FILES(NFILES)
      CHARACTER(LEN=24) , INTENT(IN) :: CODE
      CHARACTER(LEN=144), INTENT(IN) :: SUBMIT(4,NMOT)
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER I,ICOL,I1,CANAL
!
      CHARACTER(LEN=7) :: NOMCANAL
      CHARACTER(LEN=9) :: LITECR
!
      INTEGER  PREVAL,INTLU
      EXTERNAL PREVAL,INTLU
!
!-----------------------------------------------------------------------
!
      DO I=1,NFILES
        FILES(I)%LU=0
        FILES(I)%TELNAME='      '
        FILES(I)%NAME(1:1)=' '
      ENDDO
!
!-----------------------------------------------------------------------
!
!     DECODES THE SUBMIT STRING FOR THE FILES DECLARED IN THE
!     STEERING FILE
!
      DO I=1,NMOT
!
! EXAMPLE SUBMIT STRING : 'NGEO-READ-01;T2DGEO;OBLIG;BIN;LIT;SELAFIN-GEOM'
!
        IF(     SUBMIT(4,I).NE.' '
!       IF(     SUBMIT(4,I).NE.' '.AND.MOTCAR(I)(1:1).NE.' '
     &     .AND.SUBMIT(4,I)(1:7).NE.'INUTILE'  ) THEN
!         SCANS FOR CHANNEL FORTRAN NAME (FOR EXAMPLE NGEO)
          ICOL=PREVAL(1,SUBMIT(4,I),'-','-','-')
          NOMCANAL=SUBMIT(4,I)(1:ICOL-1)
!         SCANS FOR THE READ OR WRITE OR READWRITE STRING
!         LOCATED BEFORE THE NEXT - SIGN
          I1=ICOL+1
          ICOL=PREVAL(I1,SUBMIT(4,I),'-','-','-')
          LITECR=SUBMIT(4,I)(I1:ICOL-1)
!         READS THE CHANNEL AFTER THE - SIGN
          CANAL=INTLU(ICOL,SUBMIT(4,I))
          IF(CANAL.GT.NFILES) THEN
            IF(LNG.EQ.1) THEN
              WRITE(LU,*) 'READ_SUBMIT : NFILES TROP PETIT : ',NFILES
              WRITE(LU,*) '              IL FAUT AU MOINS ',CANAL
            ENDIF
            IF(LNG.EQ.2) THEN
              WRITE(LU,*) 'READ_SUBMIT: NFILES TOO SMALL : ',NFILES
              WRITE(LU,*) '             IT SHOULD BE AT LEAST ',CANAL
            ENDIF
            CALL PLANTE(1)
            STOP
          ENDIF
          FILES(CANAL)%LU=CANAL
          FILES(CANAL)%ACTION=LITECR
!
          ICOL=PREVAL(ICOL,SUBMIT(4,I),';',';',';')
!         READS THE NAME OF THE FILE TO BE COPIED TO THE TMP FOLDER
          I1=PREVAL(ICOL+1,SUBMIT(4,I),';',';',';')
          FILES(CANAL)%TELNAME=SUBMIT(4,I)(ICOL+1:I1-1)
!         SKIPS ;FACUL; OR ;OBLIG;
          ICOL=PREVAL(I1+1,SUBMIT(4,I),';',';',';')
!         BINARY OR ASCII
          FILES(CANAL)%BINASC=SUBMIT(4,I)(ICOL+1:ICOL+3)
!         NOTE : SUBMIT(4,I)(ICOL+5:ICOL+7) CONTAINS LIT OU ECR
!                NOT USED HERE
!         MODE SELAFIN-GEOM, PARAL, SCAL, ETC.
          FILES(CANAL)%TYPE=TRIM(SUBMIT(4,I)(ICOL+9:MIN(144,ICOL+20)))
!
        ENDIF
!
      ENDDO
!
!-----------------------------------------------------------------------
!
      RETURN
      END