!                       ***********************
                        PROGRAM HOMERE_DAMOCLES
!                       ***********************
      USE DICO_DATA
      USE UTILS_LATEX
      USE UTILS_CATA
      IMPLICIT NONE
!
!-----------------------------------------------------------------------
!
      CHARACTER(LEN=144) :: DICTIONARY
      CHARACTER(LEN=144) :: LATEX_FILE
      CHARACTER(LEN=5) :: TODO
      INTEGER LNG
      LOGICAL :: FILE_EXIST
!
      WRITE(6,*) 'ENTER ACTION [LATEX,CATA,DUMP]'
      READ(5,'(A)') TODO

      IF(TODO.EQ.'LATEX') THEN
        WRITE(6,*) 'ENTER DICTIONARY FILE: '
        READ(5,'(A)') DICTIONARY
        WRITE(6,*) 'DICTIONARY: ',TRIM(DICTIONARY)
        WRITE(6,*) 'ENTER LATEX FILE: '
        READ(5,'(A)') LATEX_FILE
        WRITE(6,*) 'LATEX_FILE: ',TRIM(LATEX_FILE)
        WRITE(6,*) 'ENTER LANGUAGE [1: FRENCH, 2: ENGLISH]: '
        READ(5,'(I1)') LNG
        WRITE(6,*) 'LANGUAGE: ',LNG
        ! Checking that the two file exist and that lng is 1 or 2
        INQUIRE(FILE=DICTIONARY,EXIST=FILE_EXIST)
        IF(.NOT.FILE_EXIST) THEN
          WRITE(6,*) 'ERROR FILE: ',TRIM(DICTIONARY),' DOES NOT EXIST'
          CALL PLANTE(1)
          STOP
        ENDIF
        IF(LNG.LE.0.OR.LNG.GT.2) THEN
          WRITE(6,*) 'WRONG LANGUAGE: ',LNG
        ENDIF
        ! Reading dictionary
        CALL READ_DICTIONARY(DICTIONARY)
        ! Writing Latex file
        CALL WRITE2LATEX(LATEX_FILE,LNG)
      ELSE IF(TODO(1:4).EQ.'CATA') THEN
        WRITE(6,*) 'ENTER DICTIONARY FILE: '
        READ(5,'(A)') DICTIONARY
        WRITE(6,*) 'DICTIONARY: ',TRIM(DICTIONARY)
        WRITE(6,*) 'ENTER CATA FILE: '
        READ(5,'(A)') LATEX_FILE
        WRITE(6,*) 'CATA: ',TRIM(LATEX_FILE)
        ! Checking that the two file exist and that lng is 1 or 2
        INQUIRE(FILE=DICTIONARY,EXIST=FILE_EXIST)
        IF(.NOT.FILE_EXIST) THEN
          WRITE(6,*) 'ERROR FILE: ',TRIM(DICTIONARY),' DOES NOT EXIST'
          CALL PLANTE(1)
          STOP
        ENDIF
        ! Reading dictionary
        CALL READ_DICTIONARY(DICTIONARY)
        ! Writing Latex file
        CALL WRITE2CATA(LATEX_FILE)
      ELSE IF(TODO(1:5).EQ.'DUMP2') THEN
        WRITE(6,*) 'ENTER DICTIONARY FILE: '
        READ(5,'(A)') DICTIONARY
        WRITE(6,*) 'DICTIONARY: ',TRIM(DICTIONARY)
        WRITE(6,*) 'ENTER OUTPUT FILE: '
        READ(5,'(A)') LATEX_FILE
        WRITE(6,*) 'CATA: ',TRIM(LATEX_FILE)
        ! Checking that the two file exist and that lng is 1 or 2
        INQUIRE(FILE=DICTIONARY,EXIST=FILE_EXIST)
        IF(.NOT.FILE_EXIST) THEN
          WRITE(6,*) 'ERROR FILE: ',TRIM(DICTIONARY),' DOES NOT EXIST'
          CALL PLANTE(1)
          STOP
        ENDIF
        ! Reading dictionary
        CALL READ_DICTIONARY(DICTIONARY)
        ! Writing Latex file
        CALL DUMP_DICTIONARY_INDEX(LATEX_FILE)
      ELSE IF(TODO(1:4).EQ.'DUMP') THEN
        WRITE(6,*) 'ENTER DICTIONARY FILE: '
        READ(5,'(A)') DICTIONARY
        WRITE(6,*) 'DICTIONARY: ',TRIM(DICTIONARY)
        WRITE(6,*) 'ENTER OUTPUT FILE: '
        READ(5,'(A)') LATEX_FILE
        WRITE(6,*) 'CATA: ',TRIM(LATEX_FILE)
        ! Checking that the two file exist and that lng is 1 or 2
        INQUIRE(FILE=DICTIONARY,EXIST=FILE_EXIST)
        IF(.NOT.FILE_EXIST) THEN
          WRITE(6,*) 'ERROR FILE: ',TRIM(DICTIONARY),' DOES NOT EXIST'
          CALL PLANTE(1)
          STOP
        ENDIF
        ! Reading dictionary
        CALL READ_DICTIONARY(DICTIONARY)
        ! Writing Latex file
        CALL DUMP_DICTIONARY_RUB(LATEX_FILE)
      ELSE
        WRITE(6,*) 'UNKNOWN ACTION',TODO
        CALL PLANTE(1)
        STOP
      ENDIF
      STOP 0
      END

