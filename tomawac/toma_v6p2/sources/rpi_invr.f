!                       *******************
                        SUBROUTINE RPI_INVR
!                       *******************
     &( X     , Y     , NEIGB , NB_CLOSE, RK_D , RX_D , RY_D  , RXX_D ,
     &  RYY_D , NPOIN2, I     , QUO   , AC    , MAXNSP, MINDIST )
!
!***********************************************************************
! TOMAWAC   V6P2                                   25/06/2012
!***********************************************************************
!
!brief    DIFFRACTION
!+         CALCULATION OF THE RADIAL FUNCTION FOR THE
!+         FREE-MESH METHOD
!
!history  E. KRIEZI (LNH)
!+        04/12/2006
!+        V5P5
!+
!
!history  G.MATTAROLO (EDF - LNHE)
!+        23/06/2012
!+        V6P2
!+   Modification for V6P2
!
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| AC             |-->| CONSTANT FOR RADIAL FUNCTION COMPUT.
!| I              |-->| POINT INDEX
!| MAXNSP         |-->| CONSTANT FOR MESHFREE TECHNIQUE
!| MINDIST        |-->| CONSTANT FOR RADIAL FUNCTION COMPUT.
!| NB_CLOSE       |-->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| NEIGB          |-->| NEIGHBOUR POINTS FOR MESHFREE METHOD
!| NPOIN2         |-->| NUMBER OF POINTS IN 2D MESH
!| QUO            |-->| CONSTANT FOR RADIAL FUNCTION COMPUT.
!| RK_D           |<->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| RX_D           |<->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| RXX_D          |<->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| RY_D           |<->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| RYY_D          |<->| ARRAY USED IN THE MESHFREE TECHNIQUE
!| X              |-->| ABSCISSAE OF POINTS IN THE MESH
!| Y              |-->| ORDINATES OF POINTS IN THE MESH
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
      IMPLICIT NONE
!
!.....VARIABLES IN ARGUMENT
!     """"""""""""""""""""
      INTEGER NPOIN2, MAXNSP, I
      INTEGER NEIGB(NPOIN2,MAXNSP), NB_CLOSE(NPOIN2)
      
      DOUBLE PRECISION QUO, AC
      DOUBLE PRECISION X(NPOIN2), Y(NPOIN2)
      DOUBLE PRECISION MINDIST(NPOIN2)       
      DOUBLE PRECISION RK_D(MAXNSP)
      DOUBLE PRECISION RX_D(MAXNSP), RY_D(MAXNSP)  
      DOUBLE PRECISION RXX_D(MAXNSP), RYY_D(MAXNSP)
!
!.....LOCAL VARIABLES
!     """""""""""""""
      INTEGER IP, IPOIN, IP1, IPOIN1, NP

      DOUBLE PRECISION RK_I(MAXNSP,MAXNSP), RN(MAXNSP,MAXNSP)
      DOUBLE PRECISION RX_I(MAXNSP,MAXNSP), RY_I(MAXNSP,MAXNSP)  
      DOUBLE PRECISION RXX_I(MAXNSP,MAXNSP), RYY_I(MAXNSP,MAXNSP)
      DOUBLE PRECISION RAD1(MAXNSP,MAXNSP)
      
      DOUBLE PRECISION DC, WZ, WZX1, WZY1, WZX2, WZY2
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!
       DO IP1 =1,NB_CLOSE(I)
          IP=NEIGB(I,IP1)
        DO IPOIN1 =1,NB_CLOSE(I)
          IPOIN=NEIGB(I,IPOIN1)
          RAD1(IP1,IPOIN1)=(X(IP)-X(IPOIN))**2+(Y(IP)-Y(IPOIN))**2
        ENDDO
       ENDDO
!
       DO IP1 =1,NB_CLOSE(I)
          IP=NEIGB(I,IP1)
          DC=MINDIST(I)
        DO IPOIN1 =1,NB_CLOSE(I)
          IPOIN=NEIGB(I,IPOIN1)
          RK_I(IP1,IPOIN1)=(RAD1(IP1,IPOIN1)+(AC*DC)**2)**QUO
!
!    First derivative 
          RY_I(IP1,IPOIN1)=2.*QUO*(RAD1(IP1,IPOIN1)+
     &     (AC*DC)**2)**(QUO-1.)*(Y(IP)-Y(IPOIN))

          RX_I(IP1,IPOIN1)=2.*QUO*(RAD1(IP1,IPOIN1)+
     &     (AC*DC)**2)**(QUO-1.)*(X(IP)-X(IPOIN))

!    Second derivative 
          RYY_I(IP1,IPOIN1) =2.D0*QUO*(RAD1(IP1,IPOIN1)+
     &    (AC*DC)**2)**(QUO-1.)+4.*QUO*(QUO-1.)*
     &    (RAD1(IP1,IPOIN1)+(AC*DC)**2)**(QUO-2.)*(Y(IP)-Y(IPOIN))**2  

          RXX_I(IP1,IPOIN1)=2.D0*QUO*(RAD1(IP1,IPOIN1)+
     &    (AC*DC)**2)**(QUO-1.)+4.*QUO*(QUO-1)*
     &    (RAD1(IP1,IPOIN1)+(AC*DC)**2)**(QUO-2.)*(X(IP)-X(IPOIN))**2
        ENDDO
       ENDDO        
!
       RN=RK_I  
       NP=NB_CLOSE(I)
!
      CALL INVERT(RN,NP,MAXNSP)
!
       DO IP1 =1,NB_CLOSE(I)
         WZ=0.D0
         WZX1=0.D0
         WZY1=0.D0
         WZX2=0.D0
         WZY2=0.D0                 
        DO IPOIN1 =1,NB_CLOSE(I)
          WZ=WZ+RK_I(1,IPOIN1)*RN(IPOIN1,IP1)
          WZx1=WZx1+RX_I(1,IPOIN1)*RN(IPOIN1,IP1)
          WZy1=WZy1+RY_I(1,IPOIN1)*RN(IPOIN1,IP1)
          WZx2=WZx2+RXX_I(1,IPOIN1)*RN(IPOIN1,IP1)
          WZy2=WZy2+RYY_I(1,IPOIN1)*RN(IPOIN1,IP1)
        ENDDO  
!   write RK etc for the right form for each domain in one row
          RK_D(IP1)=WZ
          RX_D(IP1) = WZX1
          RY_D(IP1) = WZY1
          RXX_D(IP1) = WZX2
          RYY_D(IP1) = WZY2  
       ENDDO
!
      RETURN
      END                  