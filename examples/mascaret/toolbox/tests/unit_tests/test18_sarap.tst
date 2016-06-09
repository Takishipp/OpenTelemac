// This file is released under the 3-clause BSD license. See COPYING-BSD.
//=================================
toolbox_dir=getenv("toolbox_dir");
c = filesep();

// creation du modele
[erreur, id] = createMASCARET();
assert_checkequal(id,1);

// importation du modele
path_xml = "file://"+toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"data"+c+"SARAP"+c+"xml"+c+"mascaret0.xcas";
TabNomFichier = [
                 strsubst(path_xml,'\','/'), ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"data"+c+"SARAP"+c+"xml"+c+"mascaret0.geo", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"data"+c+"SARAP"+c+"xml"+c+"mascaret0_0.loi", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"data"+c+"SARAP"+c+"xml"+c+"mascaret0_1.loi", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"data"+c+"SARAP"+c+"xml"+c+"mascaret0_2.loi", ..
                 toolbox_dir+c+"mascaret0.lis", ..
                 toolbox_dir+c+"mascaret0_ecr.opt"];
 
TypeNomFichier = ["xcas","geo","loi","loi","loi","listing","res"];
impression = 0;
erreur = importModelMASCARET(id,TabNomFichier,TypeNomFichier,impression);
assert_checkequal(erreur,0);

// initialisation
[erreur,nbSec,taille2,taille3] = getSizeVarMASCARET(id,"Model.X", 0);
Qinit = zeros(nbSec,1);
Zinit = 2*ones(nbSec,1);
erreur = initStateMASCARET(id,Qinit,Zinit);
assert_checkequal(erreur,0);

// acces aux pas de temps de simulation
[erreur,pasTps] = getDoubleMASCARET(id,"Model.DT",0,0,0);
assert_checkequal(erreur,0);
[erreur,T0] = getDoubleMASCARET(id,"Model.InitTime",0,0,0);
assert_checkequal(erreur,0);
[erreur,TF] = getDoubleMASCARET(id,"Model.MaxCompTime",0,0,0);
assert_checkequal(erreur,0);
TF = 1.0;

// calcul
erreur = computeMASCARET(id,T0,TF,pasTps,impression);
assert_checkequal(erreur,0);

// recuperation des resultats
Z = zeros(nbSec,1);
Q = zeros(nbSec,1);
for i = 1:nbSec
    [erreur,Z(i)] = getDoubleMASCARET(id,"State.Z",i,0,0);
    assert_checkequal(erreur,0);
    [erreur,Q(i)] = getDoubleMASCARET(id,"State.Q",i,0,0);
    assert_checkequal(erreur,0);
end

ResRef = read(toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test18"+c+"ref"+c+"res.txt",nbSec,7);

// test de la solution sur le debit total / solution anterieure de reference
code_retour = assert_checkalmostequal(Q,ResRef(:,4),1.D-3);
assert_checktrue(code_retour);

// test de la solution sur la cote / solution anterieure de reference
code_retour = assert_checkalmostequal(Z,ResRef(:,2),1.D-3);
assert_checktrue(code_retour);

// destruction du modele
erreur=deleteMASCARET(id);
assert_checkequal(erreur,0);
