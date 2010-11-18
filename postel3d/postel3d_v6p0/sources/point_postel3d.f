C                       *************************
                        SUBROUTINE POINT_POSTEL3D
C                       *************************
C
C***********************************************************************
C POSTEL3D VERSION 5.1   01/09/99   T. DENOT (LNH) 01 30 87 74 89
C FORTRAN90
C***********************************************************************
C
      USE BIEF
      USE DECLARATIONS_TELEMAC
      USE DECLARATIONS_POSTEL3D
C 
      IMPLICIT NONE
      INTEGER LNG,LU
      COMMON/INFO/LNG,LU
C
C
C***********************************************************************
!
      INTEGER CFG(2),NGEO
      NGEO=POS_FILES(POSGEO)%LU
!
!-----------------------------------------------------------------------
!
         if(lng.eq.1) write(lu,20)
         if(lng.eq.2) write(lu,21)
 20   format(1x,/,1X,'POINT_TELEMAC3D: ALLOCATION DE LA MEMOIRE',/)
 21   format(1x,/,1X,'POINT_TELEMAC3D: MEMORY ALLOCATION',/)
!
!-----------------------------------------------------------------------
! discretisation types are declared here

      ielm0 = 10*(ielmh/10) ! for Telemac2D
      ielm1 = ielm0 + 1     ! for Telemac2D
!
! Telemac3D discretisation types: 3D, 2D horizontal boundary,
! 2D vertical boundary
!
      ielm3  = 41     ! Telemac3D prisms
      ielm2h = 11     ! prism triangular bottom and surface
      ielm2v = 21     ! prism quadrilateral lateral boundaries
!
      ielmx=max(ielmu,ielm2h,ielmh) ! it will be max. discr. in 2D
!
      cfg(1) = 1 
      cfg(2) = 1
!
!=======================================================================
!
!                     *********************
!                     *  MESH - GEOMETRY  *
!                     *********************
!
! TWO meshes are allocated: (1) 2D base mesh, (2) 3D sigma-mesh
!
! allocation of the 2D mesh structure for Telemac2D
! discretisation ielmh given in lecdon
! ielmx = ielmu if quasi-bubble element required, otherwise ielmh
!
      equa = 'NO_EQUATION_IS_GIVEN'
!
      call ALMESH(mesh2D,'MESH2D',ielmx,spheri,cfg,ngeo,equa,nplan=1)
!
! aliases for certain components of the 2D mesh structure
!
      x2      => mesh2d%x
      y2      => mesh2d%y
      z2      => mesh2d%z
      xnebor2 => mesh2d%xnebor
      ynebor2 => mesh2d%ynebor
      xsgbor2 => mesh2d%xsgbor
      ysgbor2 => mesh2d%ysgbor
      ikle2   => mesh2d%ikle
      nbor2   => mesh2d%nbor   ! prev. simply nbor
!
!
      nelem2  => mesh2d%nelem
      nelmax2 => mesh2d%nelmax  ! previously nelma2 (adaptivity outlook)
      nptfr2  => mesh2d%nptfr   ! previously simply nptfr
      nptfrx2 => mesh2d%nptfrx
      dim2    => mesh2d%dim
      typelm2 => mesh2d%typelm
      npoin2  => mesh2d%npoin
      npmax2  => mesh2d%npmax
      mxptvs2 => mesh2d%mxptvs
      mxelvs2 => mesh2d%mxelvs
!
!-----------------------------------------------------------------------
! allocation of the 3D mesh structure (equa=empty) (read again?)
!
      equa = 'NO_EQUATION_IS_GIVEN'
!
      call ALMESH(mesh3D,'MESH3D',ielm3,spheri,cfg,ngeo,equa,
     *            nplan=nplan)
!
! alias for certain components of the 3D mesh structure
! they are defined in declarations
!
      x       => mesh3d%x%r  ! real value!!!
      y       => mesh3d%y%r
      z       => mesh3d%z%r
      x3      => mesh3d%x    ! pointers
      y3      => mesh3d%y
      z3      => mesh3d%z
      xnebor3 => mesh3d%xnebor
      ynebor3 => mesh3d%ynebor
      znebor3 => mesh3d%znebor
      xsgbor3 => mesh3d%xsgbor
      ysgbor3 => mesh3d%ysgbor
      zsgbor3 => mesh3d%zsgbor
      ikle3   => mesh3d%ikle
      nbor3   => mesh3d%nbor
!
      nelem3  => mesh3d%nelem
      nelmax3 => mesh3d%nelmax   ! previously nelma3 (adaptivity?)
      neleb   => mesh3d%neleb
      nelebx  => mesh3d%nelebx
      nptfr3  => mesh3d%nptfr
      nptfrx3 => mesh3d%nptfrx
      dim3    => mesh3d%dim
      typelm3 => mesh3d%typelm
      npoin3  => mesh3d%npoin
      npmax3  => mesh3d%npmax
      mxptvs3 => mesh3d%mxptvs
      mxelvs3 => mesh3d%mxelvs
!
!
        if (lng.eq.1) write(lu,31)
     &             typelm2,npoin2,nelem2,nptfr2,typelm3,npoin3,nelem3,
     &             nplan,neleb,nptfr3+2*npoin2,nptfr3,npoin2,npoin2
        if (lng.eq.2) write(lu,32)
     &             typelm2,npoin2,nelem2,nptfr2,typelm3,npoin3,nelem3,
     &             nplan,neleb,nptfr3+2*npoin2,nptfr3,npoin2,npoin2
!
 31   format(/,' MAILLAGE 2D',/,                                        
     &         ' -----------',//,                                       
     &         ' 2D element type                : ',i8,/,               
     &         ' nombre de points 2D            : ',i8,/,               
     &         ' nombre d''elements 2D           : ',i8,/,              
     &         ' nombre de points de bord 2D    : ',i8,///,             
     &         ' MAILLAGE 3D',/,                                        
     &         ' -----------',//,                                       
     &         ' 3D element type                : ',i8,/,               
     &         ' nombre de points 3D            : ',i8,/,               
     &         ' nombre d''elements 3D           : ',i8,/,              
     &         ' nombre de plans                : ',i8,/,               
     &         ' nombre d''elements de bord      : ',i8,/,              
     &         ' nombre total de points de bord : ',i8,/,               
     &         ' dont            cotes lateraux : ',i8,/,               
     &         '                        surface : ',i8,/,               
     &         '                           fond : ',i8,/)
!
 32   format(/,' 2D MESH',/,                                            
     &         ' -------',//,                                           
     &         ' 2D element type                : ',i8,/,               
     &         ' number of 2D nodes             : ',i8,/,               
     &         ' number of 2D elements          : ',i8,/,               
     &         ' number of 2D boundary nodes    : ',i8,///,             
     &         ' 3D MESH',/,                                            
     &         ' -------',//,                                           
     &         ' 3D element type                : ',i8,/,               
     &         ' number of 3D nodes             : ',i8,/,               
     &         ' number of 3D elements          : ',i8,/,               
     &         ' number of levels               : ',i8,/,               
     &         ' number of boundary elements    : ',i8,/,               
     &         ' total number of boundary nodes : ',i8,/,               
     &         ' including   lateral boundaries : ',i8,/,               
     &         '                        surface : ',i8,/,               
     &         '                         bottom : ',i8,/)
!
C
C DEFINITION DES POINTEURS
C
         call ALLVEC(1, u,      'U     ', ielm3,  1,1)
         call ALLVEC(1, v,      'V     ', ielm3,  1,1)
         call ALLVEC(1, w,      'W     ', ielm3,  1,1)
C
c      if (varsub) then
c        call ALLVEC(1, fluin2 ,'FLUIN2', 40, 6, 1)
c        call ALLVEC(1, ws,        'WS    ', ielm3,  1, 1)
c        call ALLVEC(1, wscon2,    'WSCON2', ielm3, 1, 1)
c        call ALLVEC(1, hn,     'HN    ', ielm2h, 1, 1)
c      else
c        call ALLVEC(1, fluin2 ,'FLUIN2', 0, 1, 0)
c        call ALLVEC(1, ws,        'WS    ', 0,  1, 0)
c        call ALLVEC(1, wscon2,    'WSCON2', 0, 1, 0)
c        call ALLVEC(1, hn,     'HN    ', 0, 1, 0)
c      endif
c
      call allblo(tab,'TAB   ')
      if (nva3.gt.4) then
      call ALLVEC_IN_BLOCK(tab,    nva3-4, 1, 'TAB   ', ielm3, 1, 1)
      endif
C
C=======================================================================
C
C IMPRESSIONS :
C
      IF(LNG.EQ.1) WRITE(LU,22)
      IF(LNG.EQ.2) WRITE(LU,23)
22    FORMAT(1X,///,21X,'****************************************',/,
     *21X,              '* FIN DE L''ALLOCATION DE LA MEMOIRE  : *',/,
     *21X,              '****************************************',/)
23    FORMAT(1X,///,21X,'*************************************',/,
     *21X,              '*    END OF MEMORY ORGANIZATION:    *',/,
     *21X,              '*************************************',/)
C
C-----------------------------------------------------------------------
C
      RETURN
      END
