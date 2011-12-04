"""@author Sebastien E. Bourban
"""
"""@note ... this work is based on a collaboration effort between
  .________.                                                          ,--.
  |        |                                                      .  (  (
  |,-.    /   HR Wallingford                EDF - LNHE           / \_ \_/ .--.
  /   \  /    Howbery Park,                 6, quai Watier       \   )   /_   )
   ,.  `'     Wallingford, Oxfordshire      78401 Cedex           `-'_  __ `--
  /  \   /    OX10 8BA, United Kingdom      Chatou, France        __/ \ \ `.
 /    `-'|    www.hrwallingford.com         innovation.edf.com   |    )  )  )
!________!                                                        `--'   `--
"""
"""@history 11/11/2011 -- Sebastien E. Bourban
      An accuracy has been introduced because Python does not seem
      to be accurate with sums and multiplications
"""
"""@brief
      Tools for trivial geometrical operations
"""

# _____          ___________________________________________________
# ____/ Imports /__________________________________________________/
#
# ~~> dependencies towards standard python
import sys
import numpy as np

# _____                   __________________________________________
# ____/ Global Variables /_________________________________________/
#
"""@brief
   Returns the coordinate of the point at the intersection
      of two segments, defined by (p1,p2) and (p3,p4)
"""
def getSegmentIntersection( (x1,y1),(x2,y2),(x3,y3),(x4,y4) ):

   det = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4)
   if det == 0: return []
   x0 = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/det
   y0 = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/det
   accuracy = np.power(10.0, -5+np.floor(np.log10(x1+x2+x3+x4)))
   if ( min(x1,x2)-x0 ) > accuracy or ( x0-max(x1,x2) ) > accuracy: return []
   if ( min(x3,x4)-x0 ) > accuracy or ( x0-max(x3,x4) ) > accuracy: return []
   accuracy = np.power(10.0, -5+np.floor(np.log10(y1+y2+y3+y4)))
   if ( min(y1,y2)-y0 ) > accuracy or ( y0-max(y1,y2) ) > accuracy: return []
   if ( min(y3,y4)-y0 ) > accuracy or ( y0-max(y3,y4) ) > accuracy: return []

   return [[x0,y0]]

def getBarycentricWeights( (xo,yo),(x1,y1),(x2,y2),(x3,y3) ):

   det = ( y2-y3 ) * ( x1-x3 ) - ( y1-y3 ) * ( x2-x3 )
   l1 = ( ( y2-y3 ) * ( xo-x3 ) + ( yo-y3 ) * ( x3-x2 ) )/det
   l2 = ( ( y3-y1 ) * ( xo-x3 ) + ( yo-y3 ) * ( x1-x3 ) )/det

   return l1, l2, 1.0 - l2 - l1

def isInsideTriangle( (xo,yo),(x1,y1),(x2,y2),(x3,y3) ):

   l1,l2,l3 = getBarycentricWeights( (xo,yo),(x1,y1),(x2,y2),(x3,y3) )
   if l1 >= 0.0 and l1 <= 1.0 and l2 >= 0.0 and l2 <= 1.0 and l3 >= 0.0 and l3 <= 1.0 : return [ l1, l2, l3 ]
   return []

# _____             ________________________________________________
# ____/ MAIN CALL  /_______________________________________________/
#

__author__="Sebastien E. Bourban"
__date__ ="$15-Nov-2011 08:51:29$"

if __name__ == "__main__":

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# ~~~~ Jenkins' success message ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   print '\n\nMy work is done\n\n'

   sys.exit()
