#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "apimascaret.h"
#include "cte_GP.h"

int test26_casier(char *pathTest,int iter)
{
    char fullpath[maxLength];   /* the full path for the local test */
    int              i;   /* loop index */
    int            err;   /* flag error */
    int             id;   /* MASCARET model number */
    int          print;   /* print option for MASCARET */
    /*char    *ErrorMess;   error message */
    char *FileType[] = {"xcas","geo","casier","loi","loi","listing","listing_casier","listing_liaison","res","res_casier","res_liaison"};
    char    **FileName;
    double    dt,t0,tf;   /* simulation times */
        
    /* Initialisations */
    print = 0;
    dt    = 0.;
    t0    = 0.;
    tf    = 0.;
    FileName = (char **) malloc(sizeof(char *)*11);
    if(FileName==NULL) return -1;
    for(i=0;i<11;i++)
    {
        FileName[i] = (char *) malloc(sizeof(char)*maxLength);
        if(FileName[i]==NULL) return -1;
        FileName[i][0] = '\0';
    }
    
    /* Add the final path */
    fullpath[0] = '\0';
    strcpy(fullpath,pathTest);
    strcat(fullpath,"/Test26/data/xml/");
    /* Add files */
    strcat(FileName[1],fullpath);
    strcat(FileName[1],"mascaret0.geo");
    strcat(FileName[2],fullpath);
    strcat(FileName[2],"mascaret0.casier");
    strcat(FileName[3],fullpath);
    strcat(FileName[3],"mascaret0_0.loi");
    strcat(FileName[4],fullpath);
    strcat(FileName[4],"mascaret0_1.loi");
    strcat(FileName[5],"mascaret0.lis");
    strcat(FileName[6],"mascaret0.cas_lis");
    strcat(FileName[7],"mascaret0.liai_lis");
    strcat(FileName[8],"mascaret0_ecr.opt");
    strcat(FileName[9],"mascaret0_ecr.cas_opt");
    strcat(FileName[10],"mascaret0_ecr.liai_opt");
    
    for(i=1;i<=iter;i++)
    {
        FileName[0][0] = '\0';
        strcat(FileName[0],"file:");
        strcat(FileName[0],fullpath);
        strcat(FileName[0],"mascaret0.xcas");
        
        /* MASCARET model creation */
        err = C_CREATE_MASCARET(&id);
        if(err) return err;
        
        /* MASCARET import */
        err = C_IMPORT_MODELE_MASCARET(id,FileName, FileType,11,print);
        if(err) return err;
        
        /* Temporal data */
        err = C_GET_DOUBLE_MASCARET(id, "Model.DT", 0, 0, 0, &dt);
        if(err) return err;
        err = C_GET_DOUBLE_MASCARET(id, "Model.InitTime", 0, 0, 0, &t0);
        if(err) return err;
        err = C_GET_DOUBLE_MASCARET(id, "Model.MaxCompTime", 0, 0, 0, &tf);
        if(err) return err;
        tf = 10000.;
        
        /* MASCARET initialisation */
        FileName[0][0] = '\0';
        strcat(FileName[0],fullpath);
        strcat(FileName[0],"mascaret0.lig");
        
        err= C_INIT_ETAT_MASCARET(id, FileName[0],print);
        if(err) return err;

        /* Compute MASCARET */
        err = C_CALCUL_MASCARET(id,t0,tf,dt,print);
        if(err) return err;
        
        /* MASCARET model deletion */
        err = C_DELETE_MASCARET(id);
        if(err) return err;
    
    }
    
    /* Free FileName table */
    for(i=0;i<11;i++) free(FileName[i]);
    free(FileName);
    
    return 0;
}






