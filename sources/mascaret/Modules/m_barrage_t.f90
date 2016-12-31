!== Copyright (C) 2000-2016 EDF-CEREMA ==
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

module M_BARRAGE_T
!***********************************************************************
! PROGICIEL : MASCARET        N. GOUTAL
!
! VERSION : 8.1.1              EDF-CEREMA
!***********************************************************************

   !=========================== Declarations ==============================
use M_PRECISION

Type BARRAGE_T
  sequence
  integer      :: NumBranche    ! Numero Branche
  real(DOUBLE) :: AbscisseRel   ! Abscisse relative
  integer      :: Section       ! Section de calcul
  integer      :: TypeRupture   ! Progressive ou instantannee
  real(DOUBLE) :: CoteCrete     ! Cote de crete
end type BARRAGE_T


contains
    ! Retourne les noms des champs du type ainsi qu'une description
    subroutine GET_TAB_VAR_BARRAGE(i, tabNomVar, tabDescriptionVar)
      integer , intent(inout)                                  :: i                 ! indiceTableaux
      character(len= 40), dimension(*)                :: tabNomVar         ! Tableau des noms de variable du modele
      character(len=110), dimension(*)                :: tabDescriptionVar ! Tableau des description de variable du modele

        tabNomVar(i)         ="Model.Dam.ReachNum"
        tabDescriptionVar(i) ="Reach number of the dam"
        i=i+1
        tabNomVar(i)         ="Model.Dam.RelAbscissa"
        tabDescriptionVar(i) ="Relative abscissa of the dam"
        i=i+1
        tabNomVar(i)         ="Model.Dam.Node"
        tabDescriptionVar(i) ="Node number of the dam"
        i=i+1
        tabNomVar(i)         ="Model.Dam.BreakType"
        tabDescriptionVar(i) ="Type of dam breaking"
        i=i+1
        tabNomVar(i)         ="Model.Dam.CrestLevel"
        tabDescriptionVar(i) ="Crest level of the dam"
        i=i+1

      return

    end subroutine GET_TAB_VAR_BARRAGE

	! Retourne une description du champ du type au niveau de static (independant de l'instance du modele ou de l'etat)
    function GET_TYPE_VAR_BARRAGE(NomVar, TypeVar, Categorie, Modifiable, dimVar, MessageErreur)
      implicit none

      integer                          :: GET_TYPE_VAR_BARRAGE     ! different de 0 si erreur
      character(LEN=40), intent(in)    :: NomVar                   ! Nom de la variable (notation pointe)
      character(LEN=10), intent(out)   :: TypeVar                  ! "INT" ou "DOUBLE" ou "BOOL" ou "STRING" ou "TABINT" ou "TABDOUBLE" ou "TABBOOL"
      character(LEN=10), intent(out)   :: Categorie                ! "MODEL" ou "STATE"
      logical          , intent(out)   :: Modifiable               ! Si vrai alors on peut utiliser une fonction SET_XXXX_MASCARET sur la variable
      integer          , intent(out)   :: dimVar                   ! dimension (c'est a dire le nombre d'indexe de 0 a 3)
      character(LEN=256), intent(out)  :: MessageErreur            ! Message d'erreur

      GET_TYPE_VAR_BARRAGE  = 0
      TypeVar               = ""
      Categorie             = "MODEL"
      Modifiable            = .FALSE.
      dimVar                = 0
      MessageErreur         = ""


      if ( NomVar == 'Model.Dam.ReachNum') then
          TypeVar = 'INT'
          dimVar                = 0
       else if ( NomVar == 'Model.Dam.RelAbscissa') then
          TypeVar = 'DOUBLE'
          dimVar                = 0
       else if ( NomVar == 'Model.Dam.Node') then
          TypeVar = 'INT'
          dimVar                = 0
       else if ( NomVar == 'Model.Dam.BreakType') then
          TypeVar = 'INT'
          dimVar                = 0
       else if ( NomVar == 'Model.Dam.CrestLevel') then
          TypeVar = 'DOUBLE'
          dimVar                = 0
      else
        GET_TYPE_VAR_BARRAGE = 1
        TypeVar = "?"
        Categorie             = "MODEL"
        Modifiable            = .FALSE.
        dimVar                = -1
        MessageErreur         = "GET_TYPE_VAR_BARRAGE - Unknown variable name"
      end if


    end function GET_TYPE_VAR_BARRAGE

! .................................................................................................................................
! Permet d'acceder a la taille des valeurs des differents champs du type 
!                     -- Generer automatiquement --
! .................................................................................................................................

   function GET_TAILLE_VAR_BARRAGE(Instance, NomVar, taille1, taille2, taille3, MessageErreur)
      implicit none
      integer                            :: GET_TAILLE_VAR_BARRAGE         ! different de 0 si erreur
      type(BARRAGE_T),        intent(in) :: Instance                       ! Instance du type derive dont on souhaite connaitre la taille des differents champs
      character(len= 40),     intent(in) :: NomVar                         ! Nom de la variable du modele
      integer,                intent(out):: taille1                        ! valeur max du 1er indice
      integer,                intent(out):: taille2                        ! valeur max du 2e  indice
      integer,                intent(out):: taille3                        ! valeur max du 3e  indice
      character(LEN=256),     intent(out):: MessageErreur                  ! Message d'erreur

      GET_TAILLE_VAR_BARRAGE = 0
      taille1                = 0
      taille2                = 0
      taille3                = 0
      MessageErreur          = ""

      if ( NomVar == 'Model.Dam.ReachNum') then
         taille1 = 0
         taille2 = 0
         taille3 = 0
      else if ( NomVar == 'Model.Dam.RelAbscissa') then
         taille1 = 0
         taille2 = 0
         taille3 = 0
      else if ( NomVar == 'Model.Dam.Node') then
         taille1 = 0
         taille2 = 0
         taille3 = 0
      else if ( NomVar == 'Model.Dam.BreakType') then
         taille1 = 0
         taille2 = 0
         taille3 = 0
      else if ( NomVar == 'Model.Dam.CrestLevel') then
         taille1 = 0
         taille2 = 0
         taille3 = 0
      else
         GET_TAILLE_VAR_BARRAGE = 1
         taille1                = -1
         taille2                = -1
         taille3                = -1
         MessageErreur         = "GET_TAILLE_VAR_BARRAGE - Unknown variable name"
      end if
   end function GET_TAILLE_VAR_BARRAGE

! .................................................................................................................................
! Permet de modifier la taille les variables de type pointeurs fortran 
!                     -- Generer automatiquement --
! .................................................................................................................................

   function SET_TAILLE_VAR_BARRAGE(Instance, NomVar, NewT1, NewT2, NewT3, MessageErreur)
      implicit none
      integer                               :: SET_TAILLE_VAR_BARRAGE         ! different de 0 si erreur
      type(BARRAGE_T),        intent(inout) :: Instance                       ! Instance du type derive dont on souhaite connaitre la taille des differents champs
      character(len= 40),     intent(in)    :: NomVar                         ! Nom de la variable du modele
      integer,                intent(in)    :: NewT1                          ! Nouvelle valeur max du 1er indice
      integer,                intent(in)    :: NewT2                          ! Nouvelle valeur max du 2e  indice
      integer,                intent(in)    :: NewT3                          ! Nouvelle valeur max du 3e  indice
      character(LEN=256),     intent(out)   :: MessageErreur                  ! Message d'erreur


      SET_TAILLE_VAR_BARRAGE = 0
      MessageErreur          = ""

   end function SET_TAILLE_VAR_BARRAGE

! .................................................................................................................................
! Accesseurs permettant d'acceder aux valeurs des differents champs du type 
!                     -- Generer automatiquement --
! .................................................................................................................................

   function GET_DOUBLE_BARRAGE(Instance, NomVar, index1, index2, index3, valeur, MessageErreur)
      implicit none
      integer                            :: GET_DOUBLE_BARRAGE         ! different de 0 si erreur
      type(BARRAGE_T),        intent(in) :: Instance                   ! Instance du type derive dont on souhaite recuperer la valeur
      character(len= 40),     intent(in) :: NomVar                     ! Nom de la variable du modele
      integer,                intent(in) :: index1                     ! valeur du 1er indice
      integer,                intent(in) :: index2                     ! valeur du 2e  indice
      integer,                intent(in) :: index3                     ! valeur du 3e  indice
      real(DOUBLE),           intent(out):: valeur                     ! valeur du real(DOUBLE) de l'instance pour les indexes specifies
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      GET_DOUBLE_BARRAGE = 0
      valeur                = -9999999.9999
      MessageErreur          = ""

      if ( NomVar == 'Model.Dam.RelAbscissa') then
         valeur = Instance%AbscisseRel
      else if ( NomVar == 'Model.Dam.CrestLevel') then
         valeur = Instance%CoteCrete
      else
         GET_DOUBLE_BARRAGE = 1
         valeur                = -9999999.9999
         MessageErreur         = "GET_DOUBLE_BARRAGE - Unknown variable name"
      end if
   end function GET_DOUBLE_BARRAGE


   function GET_INT_BARRAGE(Instance, NomVar, index1, index2, index3, valeur, MessageErreur)
      implicit none
      integer                            :: GET_INT_BARRAGE            ! different de 0 si erreur
      type(BARRAGE_T),        intent(in) :: Instance                   ! Instance du type derive dont on souhaite recuperer la valeur
      character(len= 40),     intent(in) :: NomVar                     ! Nom de la variable du modele
      integer,                intent(in) :: index1                     ! valeur du 1er indice
      integer,                intent(in) :: index2                     ! valeur du 2e  indice
      integer,                intent(in) :: index3                     ! valeur du 3e  indice
      integer,                intent(out):: valeur                     ! valeur du integer de l'instance pour les indexes specifies
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      GET_INT_BARRAGE = 0
      valeur                = -9999
      MessageErreur          = ""

      if ( NomVar == 'Model.Dam.ReachNum') then
         valeur = Instance%NumBranche
      else if ( NomVar == 'Model.Dam.Node') then
         valeur = Instance%Section
      else if ( NomVar == 'Model.Dam.BreakType') then
         valeur = Instance%TypeRupture
      else
         GET_INT_BARRAGE = 1
         valeur                = -9999
         MessageErreur         = "GET_INT_BARRAGE - Unknown variable name"
      end if
   end function GET_INT_BARRAGE



! .................................................................................................................................
! Mutateurs permettant de modifier les differents champs du type
!                     -- Generer automatiquement --
! .................................................................................................................................

   function SET_DOUBLE_BARRAGE(Instance, NomVar, index1, index2, index3, valeur, MessageErreur)
      implicit none
      integer                            :: SET_DOUBLE_BARRAGE         ! different de 0 si erreur
      type(BARRAGE_T),        intent(inout) :: Instance                   ! Instance du type derive dont on souhaite recuperer la valeur
      character(len= 40),     intent(in) :: NomVar                     ! Nom de la variable du modele
      integer,                intent(in) :: index1                     ! valeur du 1er indice
      integer,                intent(in) :: index2                     ! valeur du 2e  indice
      integer,                intent(in) :: index3                     ! valeur du 3e  indice
      real(DOUBLE),           intent(in) :: valeur                     ! valeur du real(DOUBLE) de l'instance pour les indexes specifies
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      SET_DOUBLE_BARRAGE = 0
      MessageErreur          = ""

      if ( NomVar == 'Model.Dam.RelAbscissa') then
         Instance%AbscisseRel = valeur
      else if ( NomVar == 'Model.Dam.CrestLevel') then
         Instance%CoteCrete = valeur
      else
         SET_DOUBLE_BARRAGE = 1
         MessageErreur         = "SET_DOUBLE_BARRAGE - Unknown variable name"
      end if
   end function SET_DOUBLE_BARRAGE


   function SET_INT_BARRAGE(Instance, NomVar, index1, index2, index3, valeur, MessageErreur)
      implicit none
      integer                            :: SET_INT_BARRAGE            ! different de 0 si erreur
      type(BARRAGE_T),        intent(inout) :: Instance                   ! Instance du type derive dont on souhaite recuperer la valeur
      character(len= 40),     intent(in) :: NomVar                     ! Nom de la variable du modele
      integer,                intent(in) :: index1                     ! valeur du 1er indice
      integer,                intent(in) :: index2                     ! valeur du 2e  indice
      integer,                intent(in) :: index3                     ! valeur du 3e  indice
      integer,                intent(in) :: valeur                     ! valeur du integer de l'instance pour les indexes specifies
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      SET_INT_BARRAGE = 0
      MessageErreur          = ""

      if ( NomVar == 'Model.Dam.ReachNum') then
         Instance%NumBranche = valeur
      else if ( NomVar == 'Model.Dam.Node') then
         Instance%Section = valeur
      else if ( NomVar == 'Model.Dam.BreakType') then
         Instance%TypeRupture = valeur
      else
         SET_INT_BARRAGE = 1
         MessageErreur         = "SET_INT_BARRAGE - Unknown variable name"
      end if
   end function SET_INT_BARRAGE



! .................................................................................................................................
! Desalloue tous les pointeurs et fait appel aux desalloues des membres
!                     -- Generer automatiquement --
! .................................................................................................................................

   function DESALLOUE_BARRAGE(Instance, MessageErreur)
      implicit none
      integer                            :: DESALLOUE_BARRAGE          ! different de 0 si erreur
      type(BARRAGE_T),        intent(inout) :: Instance                   ! Instance du type derive dont on souhaite desalloue
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      integer                            :: taille
      integer                            :: err
      integer                            :: i
      character(LEN=256)                 :: MessageErreurType
      DESALLOUE_BARRAGE = 0
      MessageErreur          = ""

   end function DESALLOUE_BARRAGE

! .................................................................................................................................
! Rend null tous les pointeurs et fait appel aux desalloues des membres
!                     -- Generer automatiquement --
! .................................................................................................................................

   function NULLIFIER_BARRAGE(Instance, MessageErreur)
      implicit none
      integer                            :: NULLIFIER_BARRAGE          ! different de 0 si erreur
      type(BARRAGE_T),        intent(inout) :: Instance                   ! Instance du type derive dont on souhaite desalloue
      character(LEN=256),     intent(out):: MessageErreur              ! Message d'erreur

      integer                            :: taille
      integer                            :: err
      integer                            :: i
      character(LEN=256)                 :: MessageErreurType
      NULLIFIER_BARRAGE = 0
      MessageErreur          = ""

   end function NULLIFIER_BARRAGE

end module M_BARRAGE_T
