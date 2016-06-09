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

function PRESD ( &
             NOEUD , &
              SURF , &
               DZD , &
            PRGEOD , &
             SGEOD , &
            NMLARG , &
            ERREUR &
                   )

!***********************************************************************
! PROGICIEL : MASCARET        N. GOUTAL
!
! VERSION : 8.1.0              EDF-CEREMA
!***********************************************************************
!     FONCTION : CALCUL DU TERME DE PRESSION  EN FONCTION DE LA
!                     SURFACE MOUILLEE AUX INTERFACES DE CELLULES
!
!-----------------------------------------------------------------------
!                             ARGUMENTS
! .___________.____.____.______________________________________________.
! !    NOM    !TYPE!MODE!                   ROLE                       !
! !___________!____!____!______________________________________________!
! !  NOEUD    !  I !  D ! NOEUD CONSIDERE DU MAILLAGE                  !
! !  SURF     !  R !  D ! SURFACE MOUILLEE AU NOEUD                    !
! !  DZD      ! TR !  D ! PAS DE PLANIMETRAGE                          !
! !  PRGEOD   ! TR !  D ! PRESSION PLANIMETRE AUX INTERFACES           !
! !  SGEOD    ! TR !  D ! SURFACE MOUILLE PLANIMETREE AUX INTERFACES   !
! !  NMLARG   !  I !  D !                                              !
! !___________!____!____!______________________________________________!
!
!                             VARIABLES LOCALES
! .___________.____.____.______________________________________________.
! !  JG       !  I !  R ! BORNE GAUCHE DE L'INTERVALLE CONTENANT SURF  !
! !  JD       !  I !  R ! BORNE DROITE DE L'INTERVALLE CONTENANT SURF  !
! !  SG       !  R !  A ! SURFACE MOUILLE POUR LA BORNE GAUCHE         !
! !  SD       !  R !  A ! SURFACE MOUILLE POUR LA BORNE DROITE         !
! !  PRG      !  R !  A ! PRESSION POUR LA BORNE GAUCHE                !
! !___________!____!____!______________________________________________!
!
!     TYPE : E (ENTIER), R (REEL), A (ALPHANUMERIQUE), T (TABLEAU)
!            L (LOGIQUE)   .. ET TYPES COMPOSES (EX : TR TABLEAU REEL)
!     MODE : D (DONNEE NON MODIFIEE), R (RESULTAT), M (DONNEE MODIFIEE)
!            A (AUXILIAIRE MODIFIE)
!
!***********************************************************************
!   PRGEOD et SGEOD structure donnees SECTIONS

   !============================= Declarations ===========================

   !.. Modules importes ..
   !----------------------
   use M_PRECISION
   use M_PARAMETRE_C ! GPES
   use M_ERREUR_T    ! ERREUR
   use M_DICHOD_I    ! Interface du sous-programme DICHOD

   !.. Declarations explicites ..
   !-----------------------------
   implicit none

   !.. Arguments ..
   !---------------
   real(DOUBLE)                                  :: PRESD
   integer     ,                   intent(in)    :: NOEUD
   real(DOUBLE),                   intent(in)    :: SURF
   ! 1ere dimension IM
   real(DOUBLE), dimension(:)    , intent(in)    :: DZD
   real(DOUBLE), dimension(:,:)  , intent(in)    :: PRGEOD,SGEOD
   integer     ,                   intent(in)    :: NMLARG
   Type (ERREUR_T)               , intent(inout) :: ERREUR 

   !.. Variables locales ..
   !-----------------------
   integer        :: JG,JD 
   real(DOUBLE)   :: SG,SD,PRG
   !character(132) :: !arbredappel_old ! arbre d'appel precedent

   !============================= Instructions ===========================

   ! INITIALISATION
   !===============
   Erreur%Numero = 0

   ! RECHERCHE DE L'INTERVALLE CONTENANT SURF PAR DICHOTOMIE
   call DICHOD( JG , JD , SURF , NOEUD , SGEOD , NMLARG , ERREUR )
   if( Erreur%Numero /= 0 ) then
      ! !arbredappel_old    = trim(!Erreur%arbredappel)
      ! !Erreur%arbredappel = trim(!Erreur%arbredappel)//'=>PRESD'
      return
   endif

   ! SECTION MOUILLEE ET PRESSION AUX BORNES
   PRG = PRGEOD(NOEUD,JG)
   SG  = SGEOD(NOEUD,JG)
   SD  = SGEOD(NOEUD,JD)

   ! INTERPOLATION DU TERME DE PRESSION
   ! ----------------------------------
   PRESD = PRG + 0.5_DOUBLE * GPES * DZD(NOEUD) * ( ( SURF * SURF - SG * SG ) / ( SD - SG ) )

   !------------------
   ! Fin du traitement
   !------------------

   !Erreur%arbredappel = !arbredappel_old

  return

end function PRESD