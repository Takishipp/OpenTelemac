//== Copyright (C) 2000-2013 EDF-CETMEF ==
//
//   This file is part of MASCARET.
//
//   MASCARET is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.
//
//   MASCARET is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with MASCARET.  If not, see <http://www.gnu.org/licenses/>
//

// *********************************************************************
// PROGICIEL : MASCARET       J.-M. LACOMBE
//
// VERSION : 8.0.0              EDF-CETMEF
// *********************************************************************

// Accesseur permettant d'acceder aux valeurs chaines de caracteres des variables d'une instance du modele ou de l'etat
// Arguments en entree :
//      Identifiant : Identifiant de l'instance Mascaret retourne par "CREATE_MASCARET"
//      NomVar      : Nom de la variable (notation pointe), la liste des variables est retournee par GetDescVarMascaret
//      index1      : valeur du 1er indice
//      index2      : valeur du 2e indice
//      index3      : valeur du 3e indice
// Argument en sortie :
//      valeur       : valeur chaine de caractere de la variable pour les indexes specifies
function [erreur,valeur]=getStringMASCARET(id,nomVar,index1,index2,index3)
    tailleNomVar=40
    nomVarComplete=fillString(nomVar,tailleNomVar)
    [erreur,valeurFortran]=fort("get_string_mascaret",id,2,"i",nomVarComplete,3,"c",index1,4,"i",index2,5,"i",index3,6,"i","out",[1,1],1,"i",[256,1],7,"c");
	valeur = stripblanks(valeurFortran)
    return
endfunction