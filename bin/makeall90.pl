#!perl
#____________________________________________________________
#
# Generation a scalar version of the TELEMAC system
# See makeallpar90.pl for parallel version
#
# Mis a jour pour TELEMAC V6P1 - F. Decung - 23/02/2010
# Update for scalar version only - P. LANG - 01/07/2010
#
# Original version : DeltaCAD/SA - Mars 1999
#____________________________________________________________


#--------------------Tableau de description des repertoires

@dirs=(
#Libs : Bief, Damocles, Paravoid, Special, MumpsVoid
        "special|special_v6p2|sources",
	"damocles|damo_v6p2|sources",
	"mumpsvoid|mumpsvoid_v6p2|sources",
	"paravoid|paravoid_v6p2|sources",
	"bief|bief_v6p2|sources",
#Sisyphe
	"sisyphe|sisyphe_v6p2|sources",
#Tomawac
	"tomawac|toma_v6p2|sources",
#T2d
	"telemac2d|tel2d_v6p2|sources",
#T3d
	"telemac3d|tel3d_v6p2|sources",
#Artemis
	"artemis|arte_v6p2|sources",
#Estel2d
	"estel2d|estel2d_v6p2|sources",
#Estel3d
	"estel3d|estel3d_v6p2|sources",
#Postel3d
	"postel3d|postel3d_v6p2|sources",
#Stbtel
	"stbtel|stbtel_v6p2|sources",

#Spartacus2d
	"spartacus2d|spartacus2d_v6p2|sources",

);

#--------------------Usage----------------------------

sub usage
{   printf "\n\nUsage: makeall90 [-y]\n";
    printf "       -y : user confirm mode\n\n";
    exit;
}

#--------------------RunMake---------------------------

sub RunMake
{
    $curdir=$_[0];
    $make=0;

    if($askUser==0)                              #Pas de demande au user
	{   printf "===== Making : $curdir\n";
	    $make=1;
	}
    else
	{    printf "\nDo you confirm making $curdir [y(yes)/s(skip)]  ";
	    if(<STDIN>=~/y/)
	    {                                    #Confirmation par le user.
		printf "Making : $curdir\n";
		$make=1;
	    }
	    else                                 #ne confirm pas: on saute
	    {	printf "Skipping : $curdir\n";
		$make=0;
	    }
	}

#Si OK on lance le traitement du makefile
    if($make==1)
    	{
 	system ("maktel menage");
 	system ("maktel install");
        printf "===== $curdir : maktel install\n";
#
# Pour les libs faire en plus les libs Debug et Profile
# Commente, peu utilise...
#       	if  ( ! ( $curdir =~ /share/ ) )
#       	{
#                   printf "===== $curdir : maktel libdebug menage\n";
#                   system ("maktel libdebug");
#                   system ("maktel menage");
#                   printf "===== $curdir : maktel libprofile menage\n";
#                   system ("maktel libprofile");
#                   system ("maktel menage");
#		}
	printf "\n\n";
    	}
}

#--------------------Programme principal--------------

    printf "\n\n\n";
    printf "Ready for  making System TELEMAC90\n";

    $host=`gethosttype`;

#separateur Unix/NT
    $ps="/";
    if($host eq "win")     { $ps="\\";}

#Option interactif/automatique
    $askUser=0;
    if($ARGV[0])
    {
	if($ARGV[0] eq "-y")  { printf "User confirm mode.\n\n";
	                        $askUser=1;
                              }
	else                  { printf "Invalid switch.\n\n";
	                        usage();
	                      }
    }
    else    { printf "Automatic mode.\n\n"; }


    $project=`getproject`;
    chdir($project);

#Traitement de tous les repertoires listes

    foreach $path (@dirs)
    {
        $path =~ s/\|/$ps/g;                      # mettre le separateur de path
        $default_path = $path;
#~~~> SBO@HRW: sources are now within $ps.sources, not $ps."sources_"."$host"
#        $path = "$path"."_"."$host";
        $path = "$path";
#~~~<

        if ( ! chdir("$path") )
           {
           printf "Repertoire '$path' inexistant \n";

           if ( ! chdir("$default_path") )
              {
           	printf "Repertoire '$default_path' inexistant ! (Ignore)\n";
              }
           else
              {
           	printf "\n\n             ========== $default_path :\n\n";
	        RunMake($project.$ps.$default_path);
	        chdir($project);
              }
           }
        else
           {
           	printf "\n\n             ========== $path :\n\n";
	        RunMake($project.$ps.$path);      #Traite le repertoire courant
	        chdir($project);
	   }
    }

#Fin
    printf "\n\nEnd of make\n";

