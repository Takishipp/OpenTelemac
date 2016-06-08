!== Copyright (C) 2000-2015 EDF-CEREMA ==
!
!   This file is part of MASCARET.
!
!   MASCARET is free software: you can redistribute it and/or modify
!   it under the terms of the GNU General Public License as published by
!   the Free Software Foundation, either version 3 of the License, or
!   (at your option) any later version.
!
!   MASCARET is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!   GNU General Public License for more details.
!
!   You should have received a copy of the GNU General Public License
!   along with MASCARET.  If not, see <http://www.gnu.org/licenses/>
!

subroutine FROTTE( &
                FROT , &
               NOEUD , &
                SURF , &
                   Q , &
              DEBGEO , &
                SGEO , &
              NMLARG , &
              ERREUR )

!***********************************************************************
! PROGICIEL : MASCARET        N. GOUTAL
!
! VERSION : 8.1.0              EDF-CEREMA
!***********************************************************************
!     FONCTION : CALCUL DU FROTTEMENT A PARTIR DE LA DEBITANCE
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .___________.____.____.______________________________________________.
! !    NOM    !TYPE!MODE!                   ROLE                       !
! !___________!____!____!______________________________________________!
! !  FROT     !  R !  R ! FROTTEMENT                                   !
! !  NOEUD    !  I !  D ! NOEUD CONSIDERE DU MAILLAGE                  !
! !  SURF     !  R !  D ! SURFACE MOUILLEE AU NOEUD                    !
! !  Q        !  R !  D ! DEBIT                                        !
! !  DEBGEO   ! TR !  D ! DEBITANCE SUR LE MAILLAGE DECALE             !
! !  SGEO     ! TR !  D ! SURFACE MOUILLE PLANIMETREE (maillage decale)!
! !  NMLARG   !  I !  D !                                              !
! !___________!____!____!______________________________________________!
!
!     TYPE : I (ENTIER), R (REEL), A (ALPHANUMERIQUE), T (TABLEAU)
!            L (LOGIQUE)   .. ET TYPES COMPOSES (EX : TR TABLEAU REEL)
!     MODE : D (DONNEE NON MODIFIEE), R (RESULTAT), M (DONNEE MODIFIEE)
!            A (AUXILIAIRE MODIFIE)
!
!***********************************************************************
!     SGEO et DEBGEO font partie d'une structure de donnees STRUCTURE_SECTION

   !============================= Declarations ===========================

   !.. Modules importes ..
   !----------------------
   use M_PRECISION
   use M_ERREUR_T   !  Erreur
   use M_DICHO_I    ! Interface du sous-programme DICHO

   !.. Declarations explicites ..
   !-----------------------------
   implicit none

   !.. Arguments ..
   !---------------
   real(DOUBLE),                   intent(  out) :: FROT
   integer     ,                   intent(in)    :: NOEUD
   real(DOUBLE),                   intent(in)    :: SURF,Q
   ! 1ere dimension IM
   real(DOUBLE), dimension(:,:)  , intent(in)    :: DEBGEO,SGEO
   integer     ,                   intent(in)    :: NMLARG
   Type (ERREUR_T)               , intent(inout) :: ERREUR

   !.. Variables locales ..
   !-----------------------
   integer        :: JG,JD
   real(DOUBLE)   :: DEBG,DEBD,SG,SD,DEB
   !character(132) :: !arbredappel_old ! arbre d'appel precedent

   !============================= Instructions ===========================

   ! INITIALISATION
   !===============
   Erreur%Numero = 0
   !   !arbredappel_old    = trim(!Erreur%arbredappel)
   !  !Erreur%arbredappel = trim(!Erreur%arbredappel)//'=>FROTTE'

   call DICHO (JG, JD, SURF, SGEO(NOEUD,:), Erreur)

   if( Erreur%Numero /= 0 ) then
      return
   endif

   ! SECTION MOUILLEE ET DEBITANCE AUX BORNES
   DEBG = DEBGEO(NOEUD,JG)
   DEBD = DEBGEO(NOEUD,JD)
   SG   = SGEO(NOEUD,JG)
   SD   = SGEO(NOEUD,JD)

   ! INTERPOLATION DE LA DEBITANCE
   ! -----------------------------
   DEB  = ( DEBD * ( SURF - SG ) + DEBG * ( SD - SURF ) ) / ( SD - SG )
   FROT = ( Q * dabs( Q ) ) / ( DEB * DEB )

   !------------------
   ! Fin du traitement
   !------------------

   !Erreur%arbredappel = !arbredappel_old

   return

end subroutine FROTTE
