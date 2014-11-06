#!/usr/bin/env python
#1.06
# Geneate file and folder layout to build LFS Base system
# 
#
from book import Book
from chapter import Chapter
from page import Page
from package import Package
import time,re,glob,os
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
from settings import *


link = "www.linuxfromscratch.org/lfs/view/stable/index.html"
link2 = "www.linuxfromscratch.org/blfs/view/stable/index.html"
LFS="/mnt/lfs"
SOURCES=LFS + '/sources'

lfs = Book(link)
blfs = Book(link2,lfs)

wget = blfs.search("wget")[0]
ssl = blfs.search("openssl")[0]

adduser = lfs.search("adding the lfs")[0]

changeownership = lfs.search("Ownership")[0]

virtualfs = lfs.search("Virtual")[0]

CWD		=os.path.dirname(os.path.realpath(__file__))
wget_list= CWD + "/" + lfs.wgetlist

makedir = "bootstrap"
builddir = LFS + "/" + makedir
scriptfolder = builddir + "/scripts"
logfolder = builddir + "/logs"
firsttgt="all : download chown_dir mk_env mk_tools mk_virt_file mk_chroot \
mk_config mk_boot mk_end mk_extra mk_blfs umount_all"
comment="#This file is automatically generated, don't modify anyway \n"
comment += "#Generated at : " +  time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + "\n"
comment += "#Current book release : " + lfs.version.replace("\n","") + "\n"
replace_delete_log=""
ckfile = builddir + "/checksum.sh"

def get_down(names):
	dstr = ""
	
	for d in names.downloads:
	
		dstr += "\t@wget -nc --no-check-certificate " + d + " -P  $(SOURCES) $(REDIRECT)\n"
	return dstr

checksumfunc='''
#!/bin/sh
# To check the downloaded files in sources folder, and make it consistent with wget-list.
LFS=''' + LFS + '''
SOURCE=''' + SOURCES + '''
WGETLIST=''' + wget_list + '''
MD5SUM=''' + os.path.dirname(wget_list) + '''/md5sums
 

cd $SOURCE

SAVEIFS=$IFS
IFS=$(echo -en \"\\n\\b\")
for i in {1..5}
do
	missing=$(md5sum -c $MD5SUM  2>/dev/null | grep "FAILED" | cut -d":" -f1)
	if [ ! -z $missing ] ; then

		for d in $missing
			
			do
			echo "$d is missing or broken...download again."
			rm -fv $SOURCE/$d
			miss=$(grep $d $WGETLIST)
			wget -nc --no-check-certificate $miss -P  $SOURCE
		done
		
	else
		break
	fi

done
IFS=$SAVEIFS

'''

header='''\
BUILDDIR=  $(LFS)/$(MAKEDIR)
D	= -x
LFSHOME = /home/lfs
TOOLSDIR= $(LFS)/tools
SHELL 	= /bin/bash
SOURCES = $(LFS)/sources
LOGDIR	= $(BUILDDIR)/logs
SCRIPTDIR = $(BUILDDIR)/scripts
SCRIPTDIR2 = $(MAKEDIR)/scripts
REDIRECT= > $(LOGDIR)/$@.log 2>&1
USERENV = source $(LFSHOME)/.bashrc
BOLD    = "\e[0;1m"
RED     = "\e[1;31m"
GREEN   = "\e[0;32m"
ORANGE  = "\e[0;33m"
BLUE    = "\e[1;34m"
WHITE   = "\e[00m"
YELLOW  = "\e[1;33m"

OFF     = "\e[0m"
REVERSE = "\e[7m"

tab_    = '	'
nl_     = ''

export PATH := ${PATH}:/usr/sbin

CHROOT1= exec /usr/sbin/chroot $(LFS) /tools/bin/env -i HOME=/root TERM="$$TERM" \
PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin  /tools/bin/bash --login +h -c

CHROOT2= exec /usr/sbin/chroot $(LFS) /usr/bin/env -i HOME=/root TERM="$$TERM" \
PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login -c

define echo_message
  @echo -e $(BOLD)--------------------------------------------------------------------------------
  @echo -e $(BOLD)$(1) target $(BLUE)$@$(BOLD)$(WHITE)
endef
''' + firsttgt + '''\

download:
	@$(call echo_message, Building)
	@wget -nc --no-check-certificate -i $(WGETLIST) -P  $(SOURCES) $(REDIRECT)
	@time LFS=$(LFS) $(SHELL) $(D) ''' + ckfile + ''' $(REDIRECT) 
'''     + get_down(wget) + get_down(ssl) + '''\
	@touch $@

chown_dir: FORCE
	$(call echo_message, Building)
	@if  id -u lfs >/dev/null 2>&1 ; then \\
	chown  lfs.lfs $(BUILDDIR)  ; \\
	chown -R  lfs.lfs $(LOGDIR) ; \\
	chown -R lfs.lfs $(SOURCES) ; \\
	else	\\
	echo 'User: 'lfs' not exits' ; \\
	fi;
	
mk_env : download
	@$(call echo_message, Building)
	@make ''' + lfs.chapters[4].name + '''
	@touch $@

mk_tools: mk_env
	@$(call echo_message, Building)
	@exec env -i HOME=$(LFSHOME) TERM="$$TERM" PS1='\u:\w\$$ ' \
	su lfs -c "source $(LFSHOME)/.bashrc && cd $(BUILDDIR) && make ''' + \
    lfs.chapters[5].name + '''"
	@touch $@

mk_virt_file : mk_tools 
	@$(call echo_message, Building)
	@make virtfs
	@touch $@

mk_chroot : mk_virt_file
	@$(call echo_message, Building)
	@$(CHROOT1) "cd $(MAKEDIR) && make ''' + lfs.chapters[6].name + '''"
	@touch $@

mk_config : mk_chroot
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make ''' + lfs.chapters[7].name + '''"
	@touch $@

mk_boot : mk_config 
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make ''' + lfs.chapters[8].name + '''"
	@touch $@

mk_end : mk_boot
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make ''' + lfs.chapters[9].name + '''"
	@touch $@

mk_extra : mk_end 
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make ''' + ssl.fullname + '''"
	@$(CHROOT2) "cd $(MAKEDIR) && make ''' + wget.fullname + '''"
	@touch $@

'''  + ssl.fullname + " : LFS= " + ssl.makeblock() + wget.fullname + " : LFS= "  + wget.makeblock() + '''\

mk_blfs : mk_end
	@$(call echo_message, Building)
	@cd ''' + CWD + ''' && python ''' + DISTNAME + '''.py $(REDIRECT)
	@touch $@

umount_all :
ifndef LFS
	$(error LFS is not set)
else
	@-umount $(LFS)/sys
	@-umount $(LFS)/proc
	@-umount $(LFS)/dev/shm
	@-umount $(LFS)/dev/pts
	@-umount $(LFS)/dev
endif

clean : umount_all	
	@ rm -rf $(TOOLSDIR)/*
	@ rm -rf $(BUILDDIR)/$(ALLTGT)
	#@ rm -rf $(LOGDIR)/*

ifndef LFS
	$(error LFS is not set)
else
	@ -rm -rf $(LFS)/bin $(LFS)/boot $(LFS)/etc $(LFS)/home $(LFS)/lib $(LFS)/media \
    $(LFS)/mnt $(LFS)/opt $(LFS)/root $(LFS)/sbin $(LFS)/srv $(LFS)/tmp $(LFS)/usr \
    $(LFS)/var $(LFS)/sys $(LFS)/proc $(LFS)/run /mnt/lfs/dev/console /mnt/lfs/dev/null
	@ -rm -f $(LFS)/lib64
	@ -rmdir $(LFS)/tools 
	@ -rm -f /tools
	@ -userdel lfs
endif

FORCE :

.SUFFIXES:

.PHONY: clean FORCE umount_all chown_dir


'''

header = "WGETLIST= " + wget_list + "\n" + header
header = "MAKEDIR= " + makedir + "\n" + header 
header = "LFS=" + LFS + "\n" + header
header = comment + "\n" + header

packfunc='''\
	@$(call echo_message, Building)
	@LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
'''


def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]



def base_init():
	""" provision basic folder for later action: builddir, scriptfolder, log folder """
	if not os.path.exists(builddir):
		os.makedirs(builddir)	

	if not os.path.exists(scriptfolder):
		os.makedirs(scriptfolder)
	else :
		filelist = glob.glob(scriptfolder + "/*")
		for f in filelist:
			os.remove(f)

	if not os.path.exists(logfolder):
		os.makedirs(logfolder)

	

def rwreplace_delete_log():
	global replace_delete_log
	replacefile= lfs.version.replace(" ","_") + "_replace_delete.log"
	file = open(replacefile,'wb')	
	file.write(replace_delete_log)
	file.close



def main():
	allstr = "ALLTGT= "
	chapterstr =""
	packstr =""
	lastpkg =""
	global replace_delete_log
	for ch in lfs.chapters:
		
		print ch.name
		chapternum = int(ch.no)

		if chapternum == 6 :
			chapterstr += "\n\nvirtfs : " + changeownership.targetname + " " +  virtualfs.targetname
			chapterstr += "\n\n" + ch.name + " : SHELL=/tools/bin/bash "
		if chapternum > 3 and chapternum < 6:
			chapterstr += "\n" + ch.name + " : LFS=" + LFS
		if chapternum > 5:
			chapterstr += "\n" + ch.name + " : LFS= "
		if chapternum > 3:
			chapterstr += "\n" + ch.name + " : "
		
		for page in ch.pages:
			packs = page.packages
			if packs:
				for pack in packs:
					
					if pack.commands and chapternum > 3 \
						and not containsAny(pack.shortname, 
								['chroot','about-sbus','package-management',
								'cleaning-up','strip','rebooting']):
					
						
						allstr += pack.targetname
						
						if page.no not in changeownership.no and page.no not in virtualfs.no:
						#ignore changing-ownership and preparing-virtual-kernel-file-systems
							chapterstr += pack.targetname
						if page.no in adduser.no:
							
							chapterstr +='chown_dir '
						
						packstr += pack.makeblock(lastpkg)

						lastpkg = pack.targetname
						
						replace_delete_log += pack.delete_log + pack.replace_log
						pack.writescript(pack.targetname,scriptfolder)
						
			
					print "      --------------------------------"
		chapterstr += "\n"
	allstr +=  firsttgt.replace("all :","") + " " + ssl.targetname + wget.targetname
	mkfile= builddir + "/Makefile"
	mainfile = open(mkfile,'wb')
	mainfile.write(header)
	mainfile.write(allstr)
	mainfile.write(chapterstr)
	mainfile.write(packstr)
	mainfile.close
	
	checkfile = open(ckfile,'wb')
	checkfile.write(checksumfunc)
	checkfile.close

def writescript(name,scriptstr):
	scriptfile= scriptfolder + "/" + name.strip() + ".sh"
	file = open(scriptfile,'wb')
	file.write(scriptstr)
	file.close

def extra_pack():

	writescript(wget.fullname,wget.script())
	writescript(ssl.fullname,ssl.script())
def alll():
	base_init()
	main()
	rwreplace_delete_log()
	extra_pack()

alll()

'''
import cProfile
cProfile.run('main()',"testout",4)
import pstats
p = pstats.Stats('testout')
p.strip_dirs().sort_stats('cumulative').print_stats()
'''
