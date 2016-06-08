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

module M_LEC_GEOM_V3P0_I
!***********************************************************************
! PROGICIEL : MASCARET        S. MANDELKERN
!                             D. POIZAT
!
! VERSION : 8.1.0              EDF-CEREMA
!***********************************************************************
   interface

   subroutine LEC_GEOM_V3P0( &
                        Profil , & ! Tableau des profils geometriques
           FrottParoiVerticale , & ! Flag
                       Fichier , & ! Fichier contenant les profils
                    FormatGeom , & ! Format du fichier
                  UniteListing , & ! Unite logique fichier listing
                        Erreur & ! Erreur
                               )

   ! .....................................................................
   !  FONCTION : LECTURE DES FICHIERS DE DONNEES HYDRAULIQUE
   !  --------   ET FUSION DES TABLEAUX AVEC CEUX ENTREES EN
   !             ARGUMENT
   !
   !----------------------------------------------------------------------------
   !
   !   FICHIERS ENTREE/SORTIE :       - Fichier listing
   !   ----------------------         - Fichier des profils
   !
   !   SOUS-PROGRAMME(S) APPELANT(S) : LEC_GEOM
   !   -----------------------------
   !   SOUS-PROGRAMME(S) APPELE(S)   : - LIRE_CHAINE_S (module)
   !   ---------------------------     - DECODER_GEOM_V3P0
   !   COMMENTAIRES :
   !   ------------
   !
   !   DOCUMENTATION EXTERNE :
   !   ---------------------
   !
   !***********************************************************************

   !============================= Declarations ============================
   use M_PRECISION
   use M_PARAMETRE_C
   use M_FICHIER_T            ! Definition du type FICHIER_T
   use M_PROFIL_T             ! Definition du type PROFIL_T
   use M_ERREUR_T             ! Definition du type ERREUR_T
   use M_MESSAGE_C            ! Definition des messages d'erreur
   use M_TRAITER_ERREUR_I     ! Inteface generique de gestion des erreurs
   use M_DECODER_GEOM_I       ! Interface de  sous-programme
   use M_LIRE_CHAINE_S        ! lecture de lignes de commentaire

   !.. Declarations explicites ..
   implicit none

   !.. Arguments ..
   type(PROFIL_T) , dimension(:), pointer       :: Profil
   type(FICHIER_T)              , intent(in   ) :: fichier
   logical                      , intent(in   ) :: FrottParoiVerticale
                                                   ! test de frottement
   integer                      , intent(in   ) :: FormatGeom
   integer                      , intent(in   ) :: UniteListing
   type(ERREUR_T)               , intent(inout) :: Erreur

   end subroutine LEC_GEOM_V3P0

   end interface

end module M_LEC_GEOM_V3P0_I

