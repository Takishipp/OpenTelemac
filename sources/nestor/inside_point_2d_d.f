      SUBROUTINE  inside_point_2d_d              !*******************************************
!**                                               ********************************************
!**                                               ********************************************
     & ( YP, XP, NYX, YX, LRINC, LFIT )  
!                                        
!                                        
!     R = RUECKGABEPARAMETER, DIE NICHT ALS KONSTANTE ODER AUSDRUECKE
!     ----------------------  UEBERGEBEN WERDEN DUERFEN
!                                        
!     DIESE ROUTINE PRUEFT, OB DER PUNKT  Y P / X P  INNERHALB DES BELIEBI-
!     GEN  N - ECKES  Y X  VON  N Y X  PUNKTEN LIEGT. ANFANGSINDEX IST = 1.
!                                        
!     ZU DEN KOORDINATEN IN FELD  Y X  GILT ------>
!     YX(1,I) = RECHTSWERT IN EINEM BELIEBIGEN RECHTW. KOORDINATENSYSTEM
!     YX(2,I) = HOCHWERT                 
!                                        
!     DIE  N  ECKPUNKTE MUESSEN IN FELD  Y X  -  UMFAHRUNGSSINN BELIEBIG -
!     IN DER STRENGEN FOLGE DER PERIPHERIE ABGELEGT SEIN.
!     DIE SEITEN DES N-ECKES DUERFEN SICH NICHT SCHNEIDEN. ANFANGS- UND
!     ENDPUNKT KOENNEN, MUESSEN ABER NICHT IDENTISCH SEIN. DIE GLEICHSET-
!     ZUNG DES 1. UND LETZTEN PUNKTES ERFOLGT IN DIESER ROUTINE AUTOMATISCH,
!     JEDOCH UNSCHAEDLICH FUER DEN FALL, DASS DIE GLEICHHEIT VON 1. UND
!     LETZTEM PUNKT SCHON GEGEBEN WAERE. 
!                                        
!                                        
!     DAS PRUEFERGEBNIS WIRD WIE FOLGT ZURUECKGEGEBEN:
!     ================================================
!                                        
!     N P = NUMMER DES ECKPUNKTES, WENN  Y P / X P  IN IHM LIEGT, FALLS
!           NICHT AUF ECKPUNKT, WIRD  N P  MIT NULL ZURUECKGEGEBEN.
!                                        
!     N S = NUMMER DER SEITE ALS NUMMER DES AM ANFANG DER SEITE LIEGENDEN
!           ECKPUNKTES, WENN DER PUNKT  Y P / X P  AUF EINER SEITE LIEGT.
!           LIEGT DER PUNKT NICHT AUF EINER SEITE, WIRD  N S  MIT NULL ZU-
!           RUECKGEGEBEN.                
!                                        
!     LIEGT DER PUNKT  Y P / X P  INNERHALB DES N-ECKES, SO WIRD
!                                        
!          --------->    N P > 0  UND  N S > 0    <----------
!                                        
!     ZURUECKGEGEBEN. DEMNACH IST BEI NP = 0 UND NS = 0 PUNKTLAGE AUSSER-
!     HALB.                              
!                                        
!     VERFAHREN:                         
!     ==========                         
!                                        
!     DER PUNKT  Y P / X P  LIEGT INNERHALB DES  N - ECKES, WENN DIE WAAG-
!     RECHTE GERADE ODER DIE SENKRECHTE GERADE DURCH IHN LINKS ODER RECHTS
!     ODER UNTER- ODER OBERHALB DES PUNKTES  Y P / X P  MIT DEN SEITEN DES
!     N - ECKES ZU JE EINER UNGERADEN ANZAHL VON SCHNITTPUNKTEN FUEHRT.
!                                        
!     ES WIRD HIER DER FALL MIT SCHNITTPUNKTANZAHL RECHTS VON YP/XP UNTER-
!     SUCHT. BEZUG IST ALSO DIE WAAGRECHTE GERADE DURCH PUNKT  YP/XP.
!                                        
!                                        
!     IMPLICIT NONE                      
!                                        
      INTEGER            :: NYX,NA,NP,NS,I,J,K,N
      LOGICAL            :: TRIN,TQXIJ,TQXI,TQYJ,TQXJ,LFIT, LRINC
      REAL (KIND=8)      :: YX(2,NYX), XP, YP
      REAL (KIND=8)      :: DXP, DYP, DYX1J,DYX2J,DYX1I,DYX2I,DYX1NA
     &                     ,DYX2NA,DYS   
!                                        
!     PROGRAMMBEGINN                     
!     ==============                     
!                                        
!     Debug-gl      WRITE(6,*)' Start SR: inside_point_2d_d'
!     Debug-gl                           
!     Debug-gl      WRITE(6,*)'poygon first Pkt-x  = ', YX(2,1)
!     Debug-gl      WRITE(6,*)'poygon first Pkt-y  = ', YX(1,1)
!     Debug-gl      WRITE(6,*)'poygon Pkt-x        = ', YX(2,2)
!     Debug-gl      WRITE(6,*)'poygon Pkt-y        = ', YX(1,2)
!     Debug-gl      WRITE(6,*)'poygon Pkt-x        = ', YX(2,3)
!     Debug-gl      WRITE(6,*)'poygon Pkt-y        = ', YX(1,3)
!     Debug-gl      WRITE(6,*)'poygon last Pkt-x   = ', YX(2,NYX)
!     Debug-gl      WRITE(6,*)'poygon last Pkt-y   = ', YX(1,NYX)
!     Debug-gl                           
!     Debug-gl      WRITE(6,*)'  TestPunkt x  = ', XP
!     Debug-gl      WRITE(6,*)'  TestPunkt y  = ', YP
!                                        
      DXP=XP                             
      DYP=YP                             
      !                                  
      TRIN =.FALSE.                      
      NA=1                               
      NP=0                               
      NS=0                               
      IF(NYX.LT.1)GOTO 10                
      NP=NA                              
      DYX1NA=YX(1,NA)                    
      DYX2NA=YX(2,NA)                    
      IF(DYX1NA.EQ.DYP.AND.DYX2NA.EQ.DXP)GOTO 10
      !                                  
      !     GLEICHE PUNKTE AM ENDE NICHT GELTEN LASSEN
      !     ------------------------------------------
      !                                  
      DO 15 I=NYX,NA+1,-1                
         DYX1NA=YX(1,NA)                 
         DYX2NA=YX(2,NA)                 
         DYX1I=YX(1,I)                   
         DYX2I=YX(2,I)                   
         IF (DYX1I.NE.DYX1NA.OR.DYX2I.NE.DYX2NA) GOTO 20
15    CONTINUE                           
      !                                  
      NP=0                               
      GOTO 10                            
      !                                  
20    N=I                                
      I=NA                               
      !               <--- INDEX LAUFENDER PUNKT, DER NUR BEI NICHT
      !                    IDENTISCHEN PUNKTEN WEITERLAEUFT
      !                                  
      !     DURCHLAUF N-ECK              
      !     ---------------              
      !                                  
      DO 25 K=NA,N                       
         J=K+1                           
         IF(K.EQ.N)J=NA                  
         !                               
         !                               
         !     MIT VORGAENGER IDENTISCHE ECKPUNKTE UEBERGEHEN
         !     ----------------------------------------------
         !                               
         DYX1I=YX(1,I)                   
         DYX2I=YX(2,I)                   
         DYX1J=YX(1,J)                   
         DYX2J=YX(2,J)                   
         IF(DYX1J.EQ.DYX1I.AND.DYX2J.EQ.DYX2I)GOTO 25
         !                               
         !                               
         !     ALLE  N-ECK-SEITEN  MIT ECKPUNKTKOORDINATEN < YP
         !     ODER < XP HABEN KEINEN EINFLUSS AUF DAS ERGEBNIS
         !     ------------------------------------------------
         !                               
         DYX1I=YX(1,I)                   
         DYX2I=YX(2,I)                   
         DYX1J=YX(1,J)                   
         DYX2J=YX(2,J)                   
         IF(DYX1I.LT.DYP.AND.DYX1J.LT.DYP.OR.
     &      DYX2I.LT.DXP.AND.DYX2J.LT.DXP)GOTO 35
         !                               
         !                               
         !     IDENTITAET MIT PUNKT  YP/XP  FESTSTELLEN
         !     ----------------------------------------
         !                               
         NP=J                            
         NS=0                            
         DYX1J=YX(1,J)                   
         DYX2J=YX(2,J)                   
         TQYJ=DYX1J.EQ.DYP               
         TQXJ=DYX2J.EQ.DXP               
         IF(TQYJ.AND.TQXJ)GOTO 10        
         !                               
         !                               
         !     ALLE SEITEN MIT ECK-PUNKTKOORDINATEN = UND > XP ODER <
         !     HABEN  AB  HIER  KEINEN EINFLUSS MEHR AUF DAS ERGEBNIS
         !     ------------------------------------------------------
         !                               
         DYX1I=YX(1,I)                   
         DYX2I=YX(2,I)                   
         DYX1J=YX(1,J)                   
         DYX2J=YX(2,J)                   
         IF(DYX2I.GE.DXP.AND.DYX2J.GT.DXP.OR.
     &      DYX2I.GT.DXP.AND.DYX2J.GE.DXP)GOTO 35
         NP=0                            
         NS=K                            
         DYX2J=YX(2,I)                   
         TQXI=DYX2I.EQ.DXP               
         TQXIJ=TQXI.AND.TQXJ             
         !                               
         !                               
         !     ECKPUNKT-SEITE  I - J  LIEGT IN WAAGRECHTER GERADE  XP
         !     ------------------------------------------------------
         !                               
         IF(.NOT.(TQXI.OR.TQXJ))GOTO 45  
         DYX1I=YX(1,I)                   
         DYX1J=YX(1,J)                   
         IF(TQXIJ.AND.(DYX1I.LT.DYP.OR.DYX1J.LT.DYP))GOTO 10
         IF(TQXIJ)GOTO 35                
         !                               
         !                               
         !     UNGERADENANZAHL VON ECKPUNKTEN AUF GERADE  XP  FESTSTELLEN
         !     ----------------------------------------------------------
         !                               
         DYX1I=YX(1,I)                   
         DYX1J=YX(1,J)                   
         IF(TQXI.AND.DYX1I.GT.DYP.OR.TQXJ.AND.DYX1J.GT.DYP)GOTO 40
         GOTO 35                         
         !                               
         !                               
         !     ECKPUNKTSEITE  I - J  KREUZT DIE GERADE  XP
         !     -------------------------------------------
         !                               
45       CONTINUE                        
         DYX1I=YX(1,I)                   
         IF(DYX1I.EQ.DYP.AND.TQYJ)GOTO 10
         !                                        <--- ECKPUNKTSEITE LIEGT IN YP
         !                               
         DYX1I=YX(1,I)                   
         DYX2I=YX(2,I)                   
         DYX1J=YX(1,J)                   
         DYX2J=YX(2,J)                   
         DYS=(DYX1J*(DXP-DYX2I)+DYX1I*(DYX2J-DXP))/(DYX2J-DYX2I)
         IF(DYS.EQ.DYP)GOTO 10           
         IF(DYS.LT.DYP)GOTO 35           
         !                               
40       TRIN=.NOT.TRIN                  
         !                               
35       I=J                             
         !               <------- LAUFINDEX I FORTSCHALTEN, BLEIBT
         !                        BEI IDENTISCHEN PUNKTEN STEHEN
25    CONTINUE                           
      !                                  
      IF(TRIN)THEN                       
         NP=1                            
         NS=1                            
      ELSE                               
         NP=0                            
         NS=0                            
      END IF                             
      !                                  
10    LFIT=.FALSE.                       
      IF(LRINC) THEN                     
         IF(NP.GT.0.OR.NS.GT.0) LFIT=.TRUE.
      ELSE                               
         IF(NP.GT.0.AND.NS.GT.0) LFIT=.TRUE.
      ENDIF                              
!     Debug-gl      WRITE(6,*)'END SR: inside_point_2d_d'
      END SUBROUTINE inside_point_2d_d   
!**                                         ********************************************
!**                                         ********************************************
                                           !********************************************
!**                                         ********************************************
!**                                         ********************************************
!***************************************************************************************
!***************************************************************************************
        
!*********************************************************************************************
!*********************************************************************************************
!**                                               ********************************************
!**                                               ********************************************