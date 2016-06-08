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

subroutine LEC_CASIER( &
                       Casier            , & ! tableau des casiers
                       FichierGeomCasier , &
                       document          , & ! Pointeur vers document XML
                       Erreur )              ! erreur

! ******************************************************************
! PROGICIEL : MASCARET             C. RISSOAN
!                                  F. ZAOUI
!
! VERSION : 8.1.0                  EDF-CEREMA
!
! LECTURE DE LA VARIABLE CASIER
! ******************************************************************
!
!   FICHIERS ENTREE/SORTIE :  --
!   ----------------------
!   SOUS PROGRAMMES APPELANTS : - PRETRAIT
!   ---------------------------
!   SOUS PROGRAMMES APPELES :    - LEC_GEOM_CASIER1, LEC_GEOM_CASIER2
!   -------------------------

   !========================== Declarations ==============================
   use M_CASIER_T                 ! type Casier
   use M_ERREUR_T                 ! type Erreur
   use M_PARAMETRE_C
   use M_FICHIER_T
   use M_MESSAGE_CASIER_C         ! messages d erreur propres a Casier
   use M_CONSTANTES_CASIER_C
   use M_TRAITER_ERREUR_CASIER_I  ! traitement des erreurs
   use M_TRAITER_ERREUR_I         ! Traitement de l'errreur
   use M_LEC_GEOM_CASIER2_I
   use M_LEC_GEOM_CASIER1_I
   use Fox_dom                    ! parser XML Fortran

   implicit none

   !.. Arguments ..
   type(CASIER_T) , dimension(:)     , pointer       :: Casier
   type(ERREUR_T)                    , intent(inout) :: Erreur
   type(FICHIER_T)                   , intent(inout) :: FichierGeomCasier
   type(Node), pointer, intent(in)                   :: document 

   !.. Variables locales ..
   integer :: nombre_casier, icasier, icote, option_calcul
   integer :: retour          ! code de retour des fonctions intrinseques
   integer :: option_planim
   type(Node), pointer :: champ1,champ2,champ3
   integer, allocatable :: itab(:)
   real(double), allocatable :: rtab(:)
   !character(132) :: arbredappel_old

   !========================== Instructions ==============================

   ! INITIALISATION
   ! --------------
   Erreur%Numero = 0
   retour        = 0
   !arbredappel_old = trim(Erreur%arbredappel)
   !Erreur%arbredappel = trim(Erreur%arbredappel)//'=>LEC_CASIER'

   ! Nombre de casiers
   !------------------
   champ1 => item(getElementsByTagname(document, "parametresCasier"), 0)
   if(associated(champ1).eqv..false.) then
       print*,"Parse error => parametresCasier"
       call xerror(Erreur)
       return
   endif
   champ2 => item(getElementsByTagname(champ1, "nbCasiers"), 0)
   if(associated(champ2).eqv..false.) then
       print*,"Parse error => nbCasiers"
       call xerror(Erreur)
       return
   endif
   call extractDataContent(champ2,nombre_casier)
   if( nombre_casier == 0 ) then
      Erreur%Numero = 900
      Erreur%ft     = err_900
      Erreur%ft_c   = err_900c
      call TRAITER_ERREUR_CASIER( Erreur , 'Existence de casiers' , 'casiers' )
      return
   end if

   ! Allocation des casiers
   !-----------------------
   if(.not.associated(Casier)) allocate( Casier(nombre_casier) , STAT = retour )
   if( retour /= 0 ) then
      Erreur%Numero = 5
      Erreur%ft     = err_5
      Erreur%ft_c   = err_5c
      call TRAITER_ERREUR_CASIER( Erreur , 'Casier' )
      return
   end if

   allocate( itab(nombre_casier) , STAT = retour )
   if( retour /= 0 ) then
       Erreur%Numero = 5
       Erreur%ft     = err_5
       Erreur%ft_c   = err_5c
       call TRAITER_ERREUR( Erreur , 'itab' )
       return
   end if
   
   allocate( rtab(nombre_casier) , STAT = retour )
   if( retour /= 0 ) then
       Erreur%Numero = 5
       Erreur%ft     = err_5
       Erreur%ft_c   = err_5c
       call TRAITER_ERREUR( Erreur , 'rtab' )
       return
   end if
   
   champ2 => item(getElementsByTagname(champ1, "cotesInitiale"), 0)
   if(associated(champ2).eqv..false.) then
         print*,"Parse error => cotesInitiale"
         call xerror(Erreur)
         return
   endif
   call extractDataContent(champ2,rtab)
   
   do icasier = 1 , nombre_casier
      ! Initialisation des pointeurs pour l'API
      nullify(Casier(icasier)%LiaisonCC)
      nullify(Casier(icasier)%Loi_Z_S)
      nullify(Casier(icasier)%Loi_Z_V)
      nullify(Casier(icasier)%PointFrontiere)
      nullify(Casier(icasier)%PointInterieur)

      Casier(icasier)%Cote = rtab(icasier)
   end do

   champ2 => item(getElementsByTagname(champ1, "optionPlanimetrage"), 0)
   if(associated(champ2).eqv..false.) then
         print*,"Parse error => optionPlanimetrage"
         call xerror(Erreur)
         return
   endif
   call extractDataContent(champ2,itab)
   option_planim = itab(1)
   
   if( option_planim == AUTOMATIQUE ) then
      champ2 => item(getElementsByTagname(champ1, "optionCalcul"), 0)
      if(associated(champ2).eqv..false.) then
         print*,"Parse error => optionCalcul"
         call xerror(Erreur)
         return
      endif
      call extractDataContent(champ2,option_calcul)
   end if

   if( option_planim == AUTOMATIQUE ) then

      champ2 => item(getElementsByTagname(champ1, "pasPlanimetrage"), 0)
      if(associated(champ2).eqv..false.) then
         print*,"Parse error => pasPlanimetrage"
         call xerror(Erreur)
         return
   endif
      call extractDataContent(champ2,rtab) 
       
      champ2 => item(getElementsByTagname(champ1, "nbCotesPlanimetrage"), 0)
      if(associated(champ2).eqv..false.) then
         print*,"Parse error => nbCotesPlanimetrage"
         call xerror(Erreur)
         return
      endif
      call extractDataContent(champ2,itab) 
      
      do icasier = 1, size( Casier )

         Casier(icasier)%PasPlanim = rtab(icasier) 
         if( Casier(icasier)%PasPlanim <= 0._DOUBLE ) then
            Erreur%Numero = 902
            Erreur%ft     = err_902
            Erreur%ft_c   = err_902c
            call TRAITER_ERREUR_CASIER( Erreur , icasier )
            return
         end if

         Casier( icasier )%NbCotePlanim = itab(icasier)
         if( Casier(icasier)%NbCotePlanim <= 0 ) then
            Erreur%Numero = 919
            Erreur%ft     = err_919
            Erreur%ft_c   = err_919c
            call TRAITER_ERREUR_CASIER( Erreur , icasier )
            return
         end if

         ! allocation de la taille des tableaux de loi S(Z) et V(Z) - ajout du 13/04/2004
         if(.not.associated(Casier(icasier)%Loi_Z_S)) &
                   allocate( Casier(icasier)%Loi_Z_S(Casier(icasier)%NbCotePlanim,2) , STAT = retour )
         if( retour /= 0 ) then
            Erreur%Numero = 5
            Erreur%ft     = err_5
            Erreur%ft_c   = err_5c
            call TRAITER_ERREUR_CASIER( Erreur , 'Casier/Loi_Z_S' )
            return
         end if

         if(.not.associated(Casier(icasier)%Loi_Z_V)) &
                    allocate( Casier(icasier)%Loi_Z_V(Casier(icasier)%NbCotePlanim,2) , STAT = retour )
         if( retour /= 0 ) then
            Erreur%Numero = 5
            Erreur%ft     = err_5
            Erreur%ft_c   = err_5c
            call TRAITER_ERREUR_CASIER( Erreur , 'Casier/Loi_Z_V' )
            return
         end if

      end do

      call LEC_GEOM_CASIER2( Casier , FichierGeomCasier , option_calcul , Erreur )
      if( Erreur%Numero /= 0 ) then
         return
      end if

   else

      call LEC_GEOM_CASIER1( Casier , FichierGeomCasier , Erreur )
      if( Erreur%Numero /= 0 ) then
         return
      end if

   end if

   do icasier = 1, size( Casier )

      Casier(icasier)%CoteFond = Casier(icasier)%Loi_Z_S(1,1)
      if( Casier(icasier)%Cote < Casier(icasier)%CoteFond ) then
         Erreur%Numero = 901
         Erreur%ft     = err_901
         Erreur%ft_c   = err_901c
         call TRAITER_ERREUR_CASIER( Erreur , icasier )
         return
      end if

      if( abs(Casier(icasier)%Cote-Casier(icasier)%CoteFond).lt.EPS15 ) then
         Casier(icasier)%Surface = Casier(icasier)%Loi_Z_S(1,2)
         Casier(icasier)%Volume  = 0._DOUBLE
      else

         call SURVOL( Casier(icasier) , icasier , Erreur )
         Casier(icasier)%VolumeIni = Casier(icasier)%Volume
         Casier(icasier)%Bilan     = Casier(icasier)%VolumeIni
         if( Erreur%Numero /= 0 ) then
            return
         end if

      end if

      Casier(icasier)%DzCas    = 0._DOUBLE
      Casier(icasier)%CoteMax  = 0._DOUBLE
      Casier(icasier)%TempsMax = 0._DOUBLE

   end do

   deallocate(itab)
   deallocate(rtab)
   
   !.. Fin des traitements ..
   !Erreur%arbredappel = !arbredappel_old

   return
   
   contains
   
   subroutine xerror(Erreur)
       
       use M_MESSAGE_C
       use M_ERREUR_T            ! Type ERREUR_T
       
       type(ERREUR_T)                   , intent(inout) :: Erreur
       
       Erreur%Numero = 704
       Erreur%ft     = err_704
       Erreur%ft_c   = err_704c
       call TRAITER_ERREUR( Erreur )
       
       return
        
   end subroutine xerror

end subroutine LEC_CASIER
