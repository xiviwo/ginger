#This file is automatically generated, don't modify anyway 
#Generated at : 2013-09-25 11:24:22
#Current book release : Version 7.4

LFS=/mnt/lfs
MAKEDIR= bootstrap
WGETLIST= /home/mao/www.linuxfromscratch.org/lfs/view/stable/wget-list
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

CHROOT1= exec /usr/sbin/chroot $(LFS) /tools/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin  /tools/bin/bash --login +h -c

CHROOT2= exec /usr/sbin/chroot $(LFS) /usr/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login -c

define echo_message
  @echo -e $(BOLD)--------------------------------------------------------------------------------
  @echo -e $(BOLD)$(1) target $(BLUE)$@$(BOLD)$(WHITE)
endef
all : download chown_dir mk_env mk_tools mk_virt_file mk_chroot mk_config mk_boot mk_end mk_extra mk_blfs umount_all
download:
	@$(call echo_message, Building)
	@wget -nc --no-check-certificate -i $(WGETLIST) -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate http://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate ftp://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/svn/wget-1.14-texi2pod-1.patch -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate http://www.openssl.org/source/openssl-1.0.1e.tar.gz -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate ftp://ftp.openssl.org/source/openssl-1.0.1e.tar.gz -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/svn/openssl-1.0.1e-fix_parallel_build-1.patch -P  $(SOURCES) $(REDIRECT)
	@wget -nc --no-check-certificate http://www.linuxfromscratch.org/patches/blfs/svn/openssl-1.0.1e-fix_pod_syntax-1.patch -P  $(SOURCES) $(REDIRECT)
	@touch $@

chown_dir: FORCE
	$(call echo_message, Building)
	@if id -u $1 >/dev/null 2>&1; then \
	chown  lfs.lfs $(BUILDDIR)  ;\
	chown -R  lfs.lfs $(LOGDIR) ;\
	chown -R lfs.lfs $(SOURCES) ;\
	else	\
	echo 'User: 'lfs' not exits' ;\
	fi
	
mk_env : download
	@$(call echo_message, Building)
	@make final-preparations
	@touch $@

mk_tools: mk_env
	@$(call echo_message, Building)
	@exec env -i HOME=$(LFSHOME) TERM="$$TERM" PS1='\u:\w\$$ ' su lfs -c "source $(LFSHOME)/.bashrc && cd $(BUILDDIR) && make constructing-a-temporary-system"
	@touch $@

mk_virt_file : mk_tools 
	@$(call echo_message, Building)
	@make virtfs
	@touch $@

mk_chroot : mk_virt_file
	@$(call echo_message, Building)
	@$(CHROOT1) "cd $(MAKEDIR) && make installing-basic-system-software"
	@touch $@

mk_config : mk_chroot
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make setting-up-system-bootscripts"
	@touch $@

mk_boot : mk_config 
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make making-the-lfs-system-bootable"
	@touch $@

mk_end : mk_boot
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make the-end"
	@touch $@

mk_extra : mk_end 
	@$(call echo_message, Building)
	@$(CHROOT2) "cd $(MAKEDIR) && make openssl-1.0.1e"
	@$(CHROOT2) "cd $(MAKEDIR) && make wget-1.14"
	@touch $@

openssl-1.0.1e : LFS= 

openssl-1.0.1e  :  
	@$(call echo_message, Building)
	@source /etc/profile && time $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
wget-1.14 : LFS= 

wget-1.14  :  openssl-1.0.1e 
	@$(call echo_message, Building)
	@source /etc/profile && time $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@

mk_blfs : mk_end
	@$(call echo_message, Building)
	@python /home/mao/pen.py $(REDIRECT)
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
	@ -rm -rf $(LFS)/bin $(LFS)/boot $(LFS)/etc $(LFS)/home $(LFS)/lib $(LFS)/media $(LFS)/mnt $(LFS)/opt $(LFS)/root $(LFS)/sbin $(LFS)/srv $(LFS)/tmp $(LFS)/usr $(LFS)/var $(LFS)/sys $(LFS)/proc $(LFS)/run /mnt/lfs/dev/console /mnt/lfs/dev/null
	@ -rm -f $(LFS)/lib64
	@ -rmdir $(LFS)/tools 
	@ -rm -f /tools
endif

FORCE :

.SUFFIXES:

.PHONY: clean FORCE umount_all chown_dir


ALLTGT= 4011-about-lfs 4021-creating-the-lfs-tools-directory 4031-adding-the-lfs-user 4041-setting-up-the-environment 4051-about-sbus 5031-general-compilation-instructions 5041-binutils 5051-gcc 5061-linux 5071-glibc 5081-libstdc 5091-binutils 5101-gcc 5111-tcl 5121-expect 5131-dejagnu 5141-check 5151-ncurses 5161-bash 5171-bzip2 5181-coreutils 5191-diffutils 5201-file 5211-findutils 5221-gawk 5231-gettext 5241-grep 5251-gzip 5261-m4 5271-make 5281-patch 5291-perl 5301-sed 5311-tar 5321-texinfo 5331-xz 5351-changing-ownership 6021-preparing-virtual-kernel-file-systems 6051-creating-directories 6061-creating-essential-files-and-symlinks 6071-linux 6081-man-pages 6091-glibc 6101-adjusting-the-toolchain 6111-zlib 6121-file 6131-binutils 6141-gmp 6151-mpfr 6161-mpc 6171-gcc 6181-sed 6191-bzip2 6201-pkg-config 6211-ncurses 6221-shadow 6231-util-linux 6241-psmisc 6251-procps-ng 6261-e2fsprogs 6271-coreutils 6281-iana-etc 6291-m4 6301-flex 6311-bison 6321-grep 6331-readline 6341-bash 6351-bc 6361-libtool 6371-gdbm 6381-inetutils 6391-perl 6401-autoconf 6411-automake 6421-diffutils 6431-gawk 6441-findutils 6451-gettext 6461-groff 6471-xz 6481-grub 6491-less 6501-gzip 6511-iproute2 6521-kbd 6531-kmod 6541-libpipeline 6551-make 6561-man-db 6571-patch 6581-sysklogd 6591-sysvinit 6601-tar 6611-texinfo 6621-udev 6631-vim 7021-general-network-configuration 7031-customizing-the-etc-hosts-file 7051-creating-custom-symlinks-to-devices 7061-lfs-bootscripts 7071-how-do-these-bootscripts-work 7081-configuring-the-system-hostname 7091-configuring-the-setclock-script 7101-configuring-the-linux-console 7131-the-bash-shell-startup-files 7141-creating-the-etc-inputrc-file 8021-creating-the-etc-fstab-file 8031-linux 8041-using-grub-to-set-up-the-boot-process 9011-the-end  download  mk_env mk_tools mk_virt_file mk_chroot mk_config mk_boot mk_end mk_extra mk_blfs umount_all 4201-openssl 15111-wget 




final-preparations : LFS=/mnt/lfs
final-preparations : 4011-about-lfs 4021-creating-the-lfs-tools-directory 4031-adding-the-lfs-user chown_dir 4041-setting-up-the-environment 4051-about-sbus 

constructing-a-temporary-system : LFS=/mnt/lfs
constructing-a-temporary-system : 5031-general-compilation-instructions 5041-binutils 5051-gcc 5061-linux 5071-glibc 5081-libstdc 5091-binutils 5101-gcc 5111-tcl 5121-expect 5131-dejagnu 5141-check 5151-ncurses 5161-bash 5171-bzip2 5181-coreutils 5191-diffutils 5201-file 5211-findutils 5221-gawk 5231-gettext 5241-grep 5251-gzip 5261-m4 5271-make 5281-patch 5291-perl 5301-sed 5311-tar 5321-texinfo 5331-xz 


virtfs : 5351-changing-ownership  6021-preparing-virtual-kernel-file-systems 

installing-basic-system-software : SHELL=/tools/bin/bash 
installing-basic-system-software : LFS= 
installing-basic-system-software : 6051-creating-directories 6061-creating-essential-files-and-symlinks 6071-linux 6081-man-pages 6091-glibc 6101-adjusting-the-toolchain 6111-zlib 6121-file 6131-binutils 6141-gmp 6151-mpfr 6161-mpc 6171-gcc 6181-sed 6191-bzip2 6201-pkg-config 6211-ncurses 6221-shadow 6231-util-linux 6241-psmisc 6251-procps-ng 6261-e2fsprogs 6271-coreutils 6281-iana-etc 6291-m4 6301-flex 6311-bison 6321-grep 6331-readline 6341-bash 6351-bc 6361-libtool 6371-gdbm 6381-inetutils 6391-perl 6401-autoconf 6411-automake 6421-diffutils 6431-gawk 6441-findutils 6451-gettext 6461-groff 6471-xz 6481-grub 6491-less 6501-gzip 6511-iproute2 6521-kbd 6531-kmod 6541-libpipeline 6551-make 6561-man-db 6571-patch 6581-sysklogd 6591-sysvinit 6601-tar 6611-texinfo 6621-udev 6631-vim 

setting-up-system-bootscripts : LFS= 
setting-up-system-bootscripts : 7021-general-network-configuration 7031-customizing-the-etc-hosts-file 7051-creating-custom-symlinks-to-devices 7061-lfs-bootscripts 7071-how-do-these-bootscripts-work 7081-configuring-the-system-hostname 7091-configuring-the-setclock-script 7101-configuring-the-linux-console 7131-the-bash-shell-startup-files 7141-creating-the-etc-inputrc-file 

making-the-lfs-system-bootable : LFS= 
making-the-lfs-system-bootable : 8021-creating-the-etc-fstab-file 8031-linux 8041-using-grub-to-set-up-the-boot-process 

the-end : LFS= 
the-end : 9011-the-end 


4011-about-lfs   :  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


4021-creating-the-lfs-tools-directory   : 4011-about-lfs  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


4031-adding-the-lfs-user   : 4021-creating-the-lfs-tools-directory  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


4041-setting-up-the-environment   : 4031-adding-the-lfs-user  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


4051-about-sbus   : 4041-setting-up-the-environment  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5031-general-compilation-instructions   : 4051-about-sbus  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5041-binutils   : 5031-general-compilation-instructions  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5051-gcc   : 5041-binutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5061-linux   : 5051-gcc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5071-glibc   : 5061-linux  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5081-libstdc   : 5071-glibc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5091-binutils   : 5081-libstdc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5101-gcc   : 5091-binutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5111-tcl   : 5101-gcc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5121-expect   : 5111-tcl  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5131-dejagnu   : 5121-expect  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5141-check   : 5131-dejagnu  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5151-ncurses   : 5141-check  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5161-bash   : 5151-ncurses  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5171-bzip2   : 5161-bash  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5181-coreutils   : 5171-bzip2  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5191-diffutils   : 5181-coreutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5201-file   : 5191-diffutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5211-findutils   : 5201-file  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5221-gawk   : 5211-findutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5231-gettext   : 5221-gawk  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5241-grep   : 5231-gettext  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5251-gzip   : 5241-grep  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5261-m4   : 5251-gzip  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5271-make   : 5261-m4  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5281-patch   : 5271-make  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5291-perl   : 5281-patch  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5301-sed   : 5291-perl  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5311-tar   : 5301-sed  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5321-texinfo   : 5311-tar  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5331-xz   : 5321-texinfo  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


5351-changing-ownership   : 5331-xz  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6021-preparing-virtual-kernel-file-systems   : 5351-changing-ownership  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6051-creating-directories   : 6021-preparing-virtual-kernel-file-systems  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6061-creating-essential-files-and-symlinks   : 6051-creating-directories  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6071-linux   : 6061-creating-essential-files-and-symlinks  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6081-man-pages   : 6071-linux  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6091-glibc   : 6081-man-pages  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6101-adjusting-the-toolchain   : 6091-glibc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6111-zlib   : 6101-adjusting-the-toolchain  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6121-file   : 6111-zlib  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6131-binutils   : 6121-file  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6141-gmp   : 6131-binutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6151-mpfr   : 6141-gmp  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6161-mpc   : 6151-mpfr  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6171-gcc   : 6161-mpc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6181-sed   : 6171-gcc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6191-bzip2   : 6181-sed  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6201-pkg-config   : 6191-bzip2  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6211-ncurses   : 6201-pkg-config  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6221-shadow   : 6211-ncurses  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6231-util-linux   : 6221-shadow  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6241-psmisc   : 6231-util-linux  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6251-procps-ng   : 6241-psmisc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6261-e2fsprogs   : 6251-procps-ng  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6271-coreutils   : 6261-e2fsprogs  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6281-iana-etc   : 6271-coreutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6291-m4   : 6281-iana-etc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6301-flex   : 6291-m4  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6311-bison   : 6301-flex  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6321-grep   : 6311-bison  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6331-readline   : 6321-grep  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6341-bash   : 6331-readline  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6351-bc   : 6341-bash  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6361-libtool   : 6351-bc  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6371-gdbm   : 6361-libtool  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6381-inetutils   : 6371-gdbm  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6391-perl   : 6381-inetutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6401-autoconf   : 6391-perl  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6411-automake   : 6401-autoconf  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6421-diffutils   : 6411-automake  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6431-gawk   : 6421-diffutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6441-findutils   : 6431-gawk  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6451-gettext   : 6441-findutils  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6461-groff   : 6451-gettext  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6471-xz   : 6461-groff  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6481-grub   : 6471-xz  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6491-less   : 6481-grub  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6501-gzip   : 6491-less  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6511-iproute2   : 6501-gzip  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6521-kbd   : 6511-iproute2  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6531-kmod   : 6521-kbd  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6541-libpipeline   : 6531-kmod  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6551-make   : 6541-libpipeline  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6561-man-db   : 6551-make  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6571-patch   : 6561-man-db  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6581-sysklogd   : 6571-patch  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6591-sysvinit   : 6581-sysklogd  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6601-tar   : 6591-sysvinit  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6611-texinfo   : 6601-tar  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6621-udev   : 6611-texinfo  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


6631-vim   : 6621-udev  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7021-general-network-configuration   : 6631-vim  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7031-customizing-the-etc-hosts-file   : 7021-general-network-configuration  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7051-creating-custom-symlinks-to-devices   : 7031-customizing-the-etc-hosts-file  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7061-lfs-bootscripts   : 7051-creating-custom-symlinks-to-devices  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7071-how-do-these-bootscripts-work   : 7061-lfs-bootscripts  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7081-configuring-the-system-hostname   : 7071-how-do-these-bootscripts-work  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7091-configuring-the-setclock-script   : 7081-configuring-the-system-hostname  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7101-configuring-the-linux-console   : 7091-configuring-the-setclock-script  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7131-the-bash-shell-startup-files   : 7101-configuring-the-linux-console  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


7141-creating-the-etc-inputrc-file   : 7131-the-bash-shell-startup-files  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


8021-creating-the-etc-fstab-file   : 7141-creating-the-etc-inputrc-file  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


8031-linux   : 8021-creating-the-etc-fstab-file  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


8041-using-grub-to-set-up-the-boot-process   : 8031-linux  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@


9011-the-end   : 8041-using-grub-to-set-up-the-boot-process  
	@$(call echo_message, Building)
	@time LFS=$(LFS) $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) 
	@touch $@
