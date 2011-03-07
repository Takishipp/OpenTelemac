!                    *****************
                     SUBROUTINE ROTNE0
!                    *****************
!
     &(MESH,M1,A11,A12,A21,A22,SMU,SMV,UN,VN,H0,MSK,MASKEL,S,DT)
!
!***********************************************************************
! TELEMAC2D   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    COMPUTES THE MATRICES SOLVING HELMHOLTZ EQUATIONS
!+               (STEPS 1 AND 3 OF BOUSSINESQ ALGORITHM).
!
!note     A11 IS THE MATRIX WHICH MULTIPLIES U IN THE EQUATION FOR U
!note     A12 IS THE MATRIX WHICH MULTIPLIES V IN THE EQUATION FOR U
!note     A21 IS THE MATRIX WHICH MULTIPLIES U IN THE EQUATION FOR V
!note     A22 IS THE MATRIX WHICH MULTIPLIES V IN THE EQUATION FOR V
!note     SMU IS THE SECOND MEMBER IN THE EQUATION FOR U
!note     SMV IS THE SECOND MEMBER IN THE EQUATION FOR V
!
!history  J-M HERVOUET (LNH)     ; C MOULIN (LNH)
!+        17/08/1994
!+        V5P2
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
!| A11            |---| 
!| A12            |---| 
!| A21            |---| 
!| A22            |---| 
!| H0             |---| 
!| M1             |---| 
!| MASKEL         |---| 
!| MESH           |---| 
!| MSK            |---| 
!| S              |---| 
!| SMU,SMV        |<--| SECONDS MEMBRES DU SYSTEME.
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
      LOGICAL, INTENT(IN) :: MSK
      DOUBLE PRECISION, INTENT(IN)   :: DT
      TYPE(BIEF_OBJ), INTENT(IN)     :: MASKEL,H0,S,UN,VN
      TYPE(BIEF_OBJ), INTENT(INOUT)  :: SMU,SMV
      TYPE(BIEF_OBJ), INTENT(INOUT)  :: A11,A12,A21,A22,M1
      TYPE(BIEF_MESH), INTENT(INOUT) :: MESH
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELMU,IELMH
!
      DOUBLE PRECISION SL11,C,SURDT
!
      CHARACTER*16 FORMUL
!
!-----------------------------------------------------------------------
!
      IELMH=H0%ELM
      IELMU=UN%ELM
!
!------------------------------------------------------------------
!
      SURDT = 1.D0 / DT
!
!     MATRIX FOR U IN THE EQUATION FOR U (INITIALLY STORED IN M1)
!
      FORMUL='FFBT        0XX0'
      SL11 = SURDT / 6.D0
      CALL MATRIX(M1,'M=N     ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        XX00'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
!     FORMUL='FFBT        0X0X'
      FORMUL='FFBT        0XX0'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+TN  ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        00XX'
      SL11 = SURDT / 3.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
!     ADDITION TO A11 MATRIX
!
      IF(A11%TYPEXT.EQ.'S') CALL OM( 'M=X(M)  ' ,A11,A11,S,C,MESH)
      CALL OM( 'M=M+N   ' , A11 , M1 , S , C , MESH )
!
!     SECOND MEMBER SMU
!
      CALL MATVEC( 'X=X+AY  ',SMU,M1,UN,C,MESH)
!
!------------------------------------------------------------------
!
!     MATRIX FOR V IN THE EQUATION FOR U (INITIALLY STORED IN M1)
!
      FORMUL='FFBT        0Y0X'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=N     ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        XY00'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        00XY'
      SL11 = SURDT / 3.D0
      CALL MATRIX(M1,'M=M+TN  ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        0X0Y'
      SL11 = SURDT / 6.D0
      CALL MATRIX(M1,'M=M+TN  ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      CALL OM( 'M=N     ' , A12 , M1 , S , C , MESH )
!
!     SECOND MEMBER SMU
!
      CALL MATVEC( 'X=X+AY  ',SMU,M1,VN,C,MESH)
!
!------------------------------------------------------------------
!
!     MATRIX FOR V IN THE EQUATION FOR V (INITIALLY STORED IN M1)
!
      FORMUL='FFBT        0YY0'
      SL11 = SURDT / 6.D0
      CALL MATRIX(M1,'M=N     ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        YY00'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        0YY0'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+TN  ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        00YY'
      SL11 = SURDT / 3.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
!     ADDITION TO A22 MATRIX
!
      IF(A22%TYPEXT.EQ.'S') CALL OM( 'M=X(M)  ' ,A22,A22,S,C,MESH)
      CALL OM( 'M=M+N   ' , A22 , M1 , S , C , MESH )
!
!     SECOND MEMBER SMV
!
      CALL MATVEC( 'X=X+AY  ',SMV,M1,VN,C,MESH)
!
!------------------------------------------------------------------
!
!     MATRIX FOR U IN THE EQUATION FOR V (INITIALLY STORED IN M1)
!
      FORMUL='FFBT        0X0Y'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=N     ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        00XY'
      SL11 = SURDT / 3.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        XY00'
      SL11 = SURDT / 2.D0
      CALL MATRIX(M1,'M=M+N   ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      FORMUL='FFBT        0Y0X'
      SL11 = SURDT / 6.D0
      CALL MATRIX(M1,'M=M+TN  ',FORMUL,IELMU,IELMU,
     &            SL11,H0,S,S,S,S,S,MESH,MSK,MASKEL)
!
      CALL OM( 'M=N     ' , A21 , M1 , S , C , MESH )
!
!     SECOND MEMBER SMV
!
      CALL MATVEC( 'X=X+AY  ',SMV,M1,UN,C,MESH)
!
!------------------------------------------------------------------
!
      RETURN
      END