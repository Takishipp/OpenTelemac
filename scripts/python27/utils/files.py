"""@author Sebastien E. Bourban, Noemie Durand and Alain Weisgerber
"""
"""@note ... this work is based on a collaborative effort between
  .________.                                                          ,--.
  |        |                                                      .  (  (
  |,-.    /   HR Wallingford                EDF - LNHE           / \_ \_/ .--.
  /   \  /    Howbery Park,                 6, quai Watier       \   )   /_   )
   ,.  `'     Wallingford, Oxfordshire      78401 Cedex           `-'_  __ `--
  /  \   /    OX10 8BA, United Kingdom      Chatou, France        __/ \ \ `.
 /    `-'|    www.hrwallingford.com         innovation.edf.com   |    )  )  )
!________!                                                        `--'   `--
"""
"""@history 15/11/2011 -- Sebastien E. Bourban
         Addition of diffTextFiles, a differential tool, which is
         called in the main.
"""
"""@history 15/11/2011 -- Sebastien E. Bourban
         Addition of moveFile.
"""
"""@history 15/11/2011 -- Sebastien E. Bourban
         Addition of a progress bar to the putFileContent and addFileContent
         methods -- had to write by line, instead of just one.
"""
"""@history 04/06/2012 -- Fabien Decung
         Extension of getTheseFiles to include subdirectories of source/.
"""
"""@history 31/05/2012 -- Sebastien E. Bourban
         Addition of a simple unzipping method (unzip)
"""
"""@brief
"""

# _____          ___________________________________________________
# ____/ Imports /__________________________________________________/
#
# ~~> dependencies towards standard python
import sys
import shutil
import time
import difflib
from os import path,walk,mkdir,getcwd,chdir,remove,rmdir,listdir,stat,makedirs
from fnmatch import fnmatch #,translate
from zipfile import ZipFile as zipfile
from distutils.archive_util import make_archive
from distutils.dep_util import newer
# ~~> dependencies towards other modules
sys.path.append( path.join( path.dirname(sys.argv[0]), '..' ) ) # clever you !
from utils.progressbar import ProgressBar
# _____                   __________________________________________
# ____/ Global Variables /_________________________________________/
#

# _____                  ___________________________________________
# ____/ General Toolbox /__________________________________________/
#

def addToList(list,name,value):
   if list.get(name) != None:
      if value not in list[name]:
         list[name].append(value)
   else:
      list.update({name:[value]})
   return list

"""@brief Make a list of all files in root that have
   the extension in [ext]
   -- Return the list
"""
def getTheseFiles(root,exts):
   root = root.strip()
   files = []
   if path.exists(root) :
      #@note FD@EDF : allow scan of subdirectories...
      for dirpath,dirnames,filenames in walk(root) : #break
         if path.basename(dirpath)[0] == '.': continue
         for file in filenames :
            for ext in exts :
               head,tail = path.splitext(file)
               if tail.lower() == ext.lower() : files.append(path.join(dirpath,file))
   return files

"""
   Evaluate whether one file is more recent than the other
   Return 1 is ofile exists and is more recent than nfile, 0 otherwise
"""
def isNewer(nfile,ofile):
   if newer(nfile,ofile): return 0
   return 1

"""

"""
def getFileContent(file):
   ilines = []
   SrcF = open(file,'r')
   for line in SrcF:
      ilines.append(line)
   SrcF.close()
   return ilines

"""

"""
def putFileContent(file,lines):
   if path.exists(file): remove(file)
   SrcF = open(file,'wb')
   if len(lines)>0:
      ibar = 0; pbar = ProgressBar(maxval=len(lines)).start()
      SrcF.write((lines[0].rstrip()).replace('\r','').replace('\n\n','\n'))
      for line in lines[1:]:
         pbar.update(ibar); ibar += 1
         SrcF.write('\n'+(line.rstrip()).replace('\r','').replace('\n\n','\n'))
      pbar.finish()
   SrcF.close()
   return
"""

"""
def addFileContent(file,lines):
   SrcF = open(file,'ab')
   ibar = 0; pbar = ProgressBar(maxval=len(lines)).start()
   for line in lines[0:]:
      ibar += 1; pbar.update(ibar)
      SrcF.write('\n'+(line.rstrip()).replace('\r','').replace('\n\n','\n'))
   pbar.finish()
   SrcF.close()
   return

"""

"""
def createDirectories(po):
   pr = po; pd = []
   while not path.isdir(pr):
      pd.append(path.basename(pr))
      pr = path.dirname(pr)
   while pd != []:
      pr = path.join(pr,pd.pop())
      mkdir(pr)
   return

"""
"""
def copyFiles(pi,po):
   ld = listdir(pi)
   ibar = 0; pbar = ProgressBar(maxval=len(ld)).start()
   for f in ld:
      if path.isfile(path.join(pi,f)): shutil.copy(path.join(pi,f),po)
      pbar.update(ibar); ibar += 1
   pbar.finish()
   return
"""
"""
def copyFile(fi,po):
   if path.exists(path.join(po,path.basename(fi))): remove(path.join(po,path.basename(fi)))
   if path.isfile(fi): shutil.copy(fi,po)
   return
"""
"""
def copyFile2File(fi,fo):
   if path.exists(path.join(path.dirname(fo),path.basename(fi))): remove(path.join(path.dirname(fo),path.basename(fi)))
   if path.isfile(fi): shutil.copy(fi,fo)
   return
"""
"""
def moveFile(fi,po):
   if path.exists(path.join(po,path.basename(fi))):
      remove(path.join(po,path.basename(fi)))
      time.sleep(5) # /!\ addition for windows operating system
   if path.exists(fi): shutil.move(fi,po)
   return

"""
   Walk through the directory structure available from the root
   and removes everything in it, including the root
"""
def removeDirectories(root):
   for p, pdirs, pfiles in walk(root, topdown=False):
      for f in pfiles: remove(path.join(p,f))
      for d in pdirs:
         try:
            rmdir(path.join(p,d))
         except:
            time.sleep(5) # /!\ addition for windows operating system
            rmdir(path.join(p,d))
   try:
      rmdir(root)
   except:
      time.sleep(5) # /!\ addition for windows operating system
      rmdir(root)
   return

"""
"""
def checkSafe(fi,safe,ck):
   fo = path.join(safe,path.basename(fi))
   if not path.exists(fo): return True
   if isNewer(fi,fo) == 1 and ck < 2: return False
   remove(fo)
   return True
"""
"""
def matchSafe(fi,ex,safe,ck):
   # ~~> list all entries
   for dp,dn,filenames in walk(safe): break
   if filenames == []: return True
   # ~~> match expression
   exnames = []
   for fo in filenames:
      if fnmatch(fo,ex):
         if ck > 1:  #TODO: try except if file access not granted
            remove(path.join(dp,fo))
            continue
         exnames.append(path.join(dp,fo))
   if exnames == []: return True
   # ~~> check if newer files
   found = False
   for fo in exnames:
      if isNewer(fi,fo) == 0: found = True
   if not found: return False
   # ~~> remove all if one older
   for fo in exnames: remove(fo)
   return True

# _____                  ___________________________________________
# ____/ Archive Toolbox /__________________________________________/
#
"""
    bname is a the root directory to be archived --
    Return the name of the archive, zname, with its full path --
    form can be either 'zip', 'gztar' ... read from the config file
"""
def zip(zname,bname,form):
   cpath = getcwd()
   chdir(path.dirname(bname))
   zipfile = make_archive(zname,form,base_dir=path.basename(bname))
   chdir(cpath)
   return zipfile
"""
    bname is a the root directory where the archive is to be extracted --
"""
def unzip(zipName,bname):
   z = zipfile(path.realpath(zipName))
   cpath = getcwd()
   chdir(bname)
   for f in z.namelist():
      if f.endswith('/'):
         if not path.exists(f): makedirs(f)
      else: z.extract(f)
   chdir(cpath)
   return

# _____               ______________________________________________
# ____/ Diff Toolbox /_____________________________________________/
#
""" Command line interface to provide diffs in four formats:

* ndiff:    lists every line and highlights interline changes.
* context:  highlights clusters of changes in a before/after format.
* unified:  highlights clusters of changes in an inline format.
* html:     generates side by side comparison with change highlights.

"""

def diffTextFiles(fFile,tFile,options):

   # we're passing these as arguments to the diff function
   fDate = time.ctime(stat(fFile).st_mtime)
   tDate = time.ctime(stat(tFile).st_mtime)
   fLines = getFileContent(fFile)
   tLines = getFileContent(tFile)

   if options.unified:
      return difflib.unified_diff(fLines, tLines,
         fFile, tFile, fDate, tDate, n=options.ablines)
   elif options.ndiff:
      return difflib.ndiff(fLines, tLines)
   elif options.html:
      return difflib.HtmlDiff().make_file(fLines, tLines,
         fFile, tFile, context=options.context, numlines=options.ablines)
   else:
      return difflib.context_diff(fLines, tLines,
         fFile, tFile, fDate, tDate, n=options.ablines)

   return

# _____             ________________________________________________
# ____/ MAIN CALL  /_______________________________________________/
#

__author__="Sebastien Bourban"
__date__ ="$19-Jul-2010 08:51:29$"

if __name__ == "__main__":
   debug = False

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# ~~~~ Jenkins' success message ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   print '\n\nMy work is done\n\n'

   sys.exit()
