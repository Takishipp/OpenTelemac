!                    *****************
                     SUBROUTINE GTSH11
!                    *****************
!
     &(U,V,X,Y,SHP,ELT,IKLE,INDIC,NLOC,NPOIN,NELEM,NELMAX,LV,MSK,MASKEL)
!
!***********************************************************************
! BIEF   V6P0                                   21/08/2010
!***********************************************************************
!
!brief    FIXES THE BARYCENTRIC COORDINATES OF ALL THE MESH
!+                NODES IN THE ELEMENT TOWARDS WHICH POINTS THE
!+                CHARACTERISTIC CURVE, FOR THE TELEMAC-2D P1 TRIANGLES
!+                AND BEFORE TRACING BACK IN TIME THE CHARACTERISTIC
!+                CURVES.
!
!history  J-M HERVOUET (LNHE)
!+        19/08/2008
!+        V5P9
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
!| ELT            |<--| NUMEROS DES ELEMENTS CHOISIS POUR CHAQUE
!|                |   | NOEUD.
!| IKLE           |-->| TRANSITION ENTRE LES NUMEROTATIONS LOCALE
!|                |   | ET GLOBALE.
!| INDIC          |---|
!| LV             |---|
!| MASKEL         |-->| TABLEAU DE MASQUAGE DES ELEMENTS
!|                |   | =1. : NORMAL   =0. : ELEMENT MASQUE.
!| MSK            |-->| SI OUI, PRESENCE D'ELEMENTS MASQUES.
!| NELEM          |-->| NOMBRE D'ELEMENTS.
!| NELMAX         |-->| NOMBRE MAXIMAL D'ELEMENTS DANS LE MAILLAGE 2D
!| NLOC           |---|
!| NPOIN          |-->| NOMBRE DE POINTS.
!| SHP            |<--| COORDONNEES BARYCENTRIQUES DES NOEUDS DANS
!|                |   | LEURS ELEMENTS "ELT" ASSOCIES.
!| U,V            |-->| COMPOSANTES DE LA VITESSE
!| X,Y            |-->| COORDONNEES DES POINTS DU MAILLAGE.
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER, INTENT(IN)    :: NPOIN,NELEM,NELMAX,LV
      INTEGER, INTENT(IN)    :: IKLE(NELMAX,3)
      INTEGER, INTENT(INOUT) :: ELT(NPOIN),INDIC(NPOIN),NLOC(NPOIN)
!
      DOUBLE PRECISION, INTENT(IN)    :: U(NPOIN),V(NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: X(NPOIN),Y(NPOIN)
      DOUBLE PRECISION, INTENT(INOUT) :: SHP(3,NPOIN)
      DOUBLE PRECISION, INTENT(IN)    :: MASKEL(NELMAX)
!
      LOGICAL, INTENT(IN) :: MSK
!
!+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
!
      INTEGER IELEM,N1,N2,N3
!
!***********************************************************************
!
!     FIRST LOOP: GETS AN ELEMENT FOR ALL POINTS
!
      DO IELEM = 1,NELEM
        N1=IKLE(IELEM,1)
        ELT(N1)=IELEM
        SHP(1,N1)=1.D0
        SHP(2,N1)=0.D0
        SHP(3,N1)=0.D0
        N2=IKLE(IELEM,2)
        ELT(N2)=IELEM
        SHP(1,N2)=0.D0
        SHP(2,N2)=1.D0
        SHP(3,N2)=0.D0
        N3=IKLE(IELEM,3)
        ELT(N3)=IELEM
        SHP(1,N3)=0.D0
        SHP(2,N3)=0.D0
        SHP(3,N3)=1.D0
      ENDDO
!
!     SECOND LOOP IF MASKING: GETS AN ELEMENT WHICH IS NOT MASKED,
!                             IF THERE IS ONE
!
      IF(MSK) THEN
        DO IELEM = 1,NELEM
          IF(MASKEL(IELEM).GT.0.5D0) THEN
            N1=IKLE(IELEM,1)
            ELT(N1)=IELEM
            SHP(1,N1)=1.D0
            SHP(2,N1)=0.D0
            SHP(3,N1)=0.D0
            N2=IKLE(IELEM,2)
            ELT(N2)=IELEM
            SHP(1,N2)=0.D0
            SHP(2,N2)=1.D0
            SHP(3,N2)=0.D0
            N3=IKLE(IELEM,3)
            ELT(N3)=IELEM
            SHP(1,N3)=0.D0
            SHP(2,N3)=0.D0
            SHP(3,N3)=1.D0
          ENDIF
        ENDDO
      ENDIF
!
!-----------------------------------------------------------------------
!
      RETURN
      END