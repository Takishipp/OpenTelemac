// This file is released under the 3-clause BSD license. See COPYING-BSD.
//=================================
toolbox_dir=getenv("toolbox_dir");
c = filesep();

// creation du modele
[erreur, id] = createMASCARET();
assert_checkequal(id,1);

// importation du modele
path_xml = "file://"+toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0.xcas";
TabNomFichier = [
                 strsubst(path_xml,'\','/'), ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0.geo", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0.casier", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0_0.loi", ..
                 toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0_1.loi", ..
                 toolbox_dir+c+"mascaret0.lis", ..
                 toolbox_dir+c+"mascaret0.cas_lis", ..
                 toolbox_dir+c+"mascaret0.liai_lis", ..
                 toolbox_dir+c+"mascaret0_ecr.opt", ..
                 toolbox_dir+c+"mascaret0_ecr.cas_opt", ..
                 toolbox_dir+c+"mascaret0_ecr.liai_opt"];
 
TypeNomFichier = ["xcas","geo","casier","loi","loi","listing","listing_casier","listing_liaison","res","res_casier","res_liaison"];
impression = 0;
erreur = importModelMASCARET(id,TabNomFichier,TypeNomFichier,impression);
assert_checkequal(erreur,0);

// initialisation
erreur = initStateNameMASCARET(id,toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"data"+c+"xml"+c+"mascaret0.lig",impression);
assert_checkequal(erreur,0);

// acces aux pas de temps de simulation
[erreur,pasTps] = getDoubleMASCARET(id,"Model.DT",0,0,0);
assert_checkequal(erreur,0);
[erreur,T0] = getDoubleMASCARET(id,"Model.InitTime",0,0,0);
assert_checkequal(erreur,0);
[erreur,TF] = getDoubleMASCARET(id,"Model.MaxCompTime",0,0,0);
assert_checkequal(erreur,0);
pasTps = 10.0;
TF = 10000.0;

// recuperation nombre de sections
[erreur,nbSec,taille2,taille3] = getSizeVarMASCARET(id,"Model.X", 0);
assert_checkequal(erreur,0);


ZC1 = zeros(1001,1); // evolution temporelle de la cote du casier 1
ZC2 = zeros(1001,1); // evolution temporelle de la cote du casier 2
ZC3 = zeros(1001,1); // evolution temporelle de la cote du casier 3
QL1 = zeros(1001,1); // evolution temporelle du debit dans la liaison 1
QL2 = zeros(1001,1); // evolution temporelle du debit dans la liaison 2
QL3 = zeros(1001,1); // evolution temporelle du debit dans la liaison 3
QL4 = zeros(1001,1); // evolution temporelle du debit dans la liaison 4
QL5 = zeros(1001,1); // evolution temporelle du debit dans la liaison 5

[erreur,ZC1(1)] = getDoubleMASCARET(id,"State.StoArea.Level",1,0,0);
assert_checkequal(erreur,0);
[erreur,ZC2(1)] = getDoubleMASCARET(id,"State.StoArea.Level",2,0,0);
assert_checkequal(erreur,0);
[erreur,ZC3(1)] = getDoubleMASCARET(id,"State.StoArea.Level",3,0,0);
assert_checkequal(erreur,0);
[erreur,QL1(1)] = getDoubleMASCARET(id,"State.Link.Discharge",1,0,0);
assert_checkequal(erreur,0);
[erreur,QL2(1)] = getDoubleMASCARET(id,"State.Link.Discharge",2,0,0);
assert_checkequal(erreur,0);
[erreur,QL3(1)] = getDoubleMASCARET(id,"State.Link.Discharge",3,0,0);
assert_checkequal(erreur,0);
[erreur,QL4(1)] = getDoubleMASCARET(id,"State.Link.Discharge",4,0,0);
assert_checkequal(erreur,0);
[erreur,QL5(1)] = getDoubleMASCARET(id,"State.Link.Discharge",5,0,0);
assert_checkequal(erreur,0);

tpsCalcul = pasTps;
i = 2;
// calcul
while (tpsCalcul <= TF)
  erreur = computeMASCARET(id,T0,tpsCalcul,pasTps,impression);
  assert_checkequal(erreur,0);
  T0 = tpsCalcul;
  tpsCalcul = tpsCalcul + pasTps;
  [erreur,ZC1(i)] = getDoubleMASCARET(id,"State.StoArea.Level",1,0,0);
  assert_checkequal(erreur,0);
  [erreur,ZC2(i)] = getDoubleMASCARET(id,"State.StoArea.Level",2,0,0);
  assert_checkequal(erreur,0);
  [erreur,ZC3(i)] = getDoubleMASCARET(id,"State.StoArea.Level",3,0,0);
  assert_checkequal(erreur,0);
  [erreur,QL1(i)] = getDoubleMASCARET(id,"State.Link.Discharge",1,0,0);
  assert_checkequal(erreur,0);
  [erreur,QL2(i)] = getDoubleMASCARET(id,"State.Link.Discharge",2,0,0);
  assert_checkequal(erreur,0);
  [erreur,QL3(i)] = getDoubleMASCARET(id,"State.Link.Discharge",3,0,0);
  assert_checkequal(erreur,0);
  [erreur,QL4(i)] = getDoubleMASCARET(id,"State.Link.Discharge",4,0,0);
  assert_checkequal(erreur,0);
  [erreur,QL5(i)] = getDoubleMASCARET(id,"State.Link.Discharge",5,0,0);
  assert_checkequal(erreur,0);
  i = i + 1;
end

ResRef = read(toolbox_dir+c+".."+c+"test"+c+"Test_Plan"+c+"Test26"+c+"ref"+c+"resV7P1P7.txt",1001,9);

// test sur l'evolution de la cote des casiers au cours de la simulation
code_retour = assert_checkalmostequal(ZC1,ResRef(:,2),1.D-3);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(ZC2,ResRef(:,3),1.D-3);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(ZC3,ResRef(:,4),1.D-3);
assert_checktrue(code_retour);

// test sur l'evolution des debits echanges dans les liaisons
code_retour = assert_checkalmostequal(QL1,ResRef(:,5),1.D-2);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(QL2,ResRef(:,6),1.D-2);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(QL3,ResRef(:,7),5.D-2);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(QL4,ResRef(:,8),%eps,25.D0);
assert_checktrue(code_retour);
code_retour = assert_checkalmostequal(QL5,ResRef(:,9),%eps,30.D0);
assert_checktrue(code_retour);

// destruction du modele
erreur=deleteMASCARET(id);
assert_checkequal(erreur,0);
