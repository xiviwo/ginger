#!/bin/env  python
# Version 1.01
# 
# 
# 
# 

import urllib2,os,binascii,re,sys,platform
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict
try:
	from BeautifulSoup import BeautifulSoup
except ImportError:
	from bs4 import BeautifulSoup
#homedir=os.path.expanduser('~')

reload(sys) 
sys.setdefaultencoding('utf8')
homepage="http://www.linuxfromscratch.org/lfs/view/stable"
lfsloc="www.linuxfromscratch.org/lfs/view/stable/index.html"
blfsloc="www.linuxfromscratch.org/blfs/view/svn/index.html"

CWD=os.path.dirname(os.path.realpath(__file__))
output=CWD + "/cmds.sh"
LFS="/mnt/lfs"
#lfspage=CWD + "/" + lfsloc
lfspage=CWD + "/" + lfsloc
blfspage=CWD +	"/" + blfsloc
lfslocaldir=os.path.dirname(lfspage)
blfslocaldir=os.path.dirname(blfspage)

IP="192.168.136.13"
GATEWAY="192.168.136.2"
BROADCAST="192.168.136.255"
domain="ibm.com"
nameserver1 ="192.168.136.2"
nameserver2 ="192.168.136.1"
hostname= "alfs"
guestdev1="vda1"
guestdev2="vda2"
guestfs="ext3"
guestdev="mapper/loop0"
newuser = "mao"
passwd = "ping" 
udevversion=197
hostdev1="mapper/loop0p1"
hostdev2="mapper/loop0p2"
arch=platform.machine()
if arch == 'i686':
	ABI=32
elif arch == 'x86_64':
	ABI=64
else:	
	print "Unknown platform error"
	raise 
REMOTE_HOSTNAME = "192.168.136.1"
wget_list=lfslocaldir + "/wget-list"
funcstrip= re.compile("\\b&nbsp;\\b|[ \~\:\+\.\-\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
#chstrip= re.compile("[0-9\.\-\/\n\t\r\(\) ]+",re.MULTILINE)
#endstrip = re.compile("#.*$")
#orstrip = re.compile("[ \t,\n\r]+",re.MULTILINE)
lastpkg = ""
makefiledir=LFS + "/makefiles"
scriptfolder = makefiledir + "/scripts"
logfolder = makefiledir + "/logs"
if not os.path.exists(makefiledir):
	os.makedirs(makefiledir)	

if not os.path.exists(scriptfolder):
	os.makedirs(scriptfolder)

if not os.path.exists(logfolder):
	os.makedirs(logfolder)

if not os.path.exists(lfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent " + lfsloc)
#soup = BeautifulSoup(urllib2.urlopen(homepage).read())
if not os.path.exists(blfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent" + blfsloc)

globalreplace = [
		('&gt;',						'>'),
		('&lt;',						'<'),
		('&amp;',						'&'),
		("IP=192.168.1.1",					"IP="+IP),
		("GATEWAY=192.168.1.2",					"GATEWAY=" + GATEWAY),
		("BROADCAST=192.168.1.255",				"BROADCAST=" + BROADCAST),
		("domain <Your Domain Name>",				"domain " + domain),
		("nameserver <IP address of your primary nameserver>",	"nameserver " + nameserver1),
		("nameserver <IP address of your secondary nameserver>","nameserver " + nameserver2),
		("127.0.0.1 <HOSTNAME.example.org> <HOSTNAME> localhost","127.0.0.1 localhost\n" + IP + "	alfs"),
		('echo "HOSTNAME=<lfs>" > /etc/sysconfig/network',	'echo "HOSTNAME=' + hostname + '" > /etc/sysconfig/network'),
		('KEYMAP="de-latin1"',					'KEYMAP="us"'),
		('KEYMAP_CORRECTIONS="euro2"',				''),
		('LEGACY_CHARSET="iso-8859-15"',			''),
		('FONT="LatArCyrHeb-16 -m 8859-15"',			''),
		('/dev/<xxx>     /            <fff>    ',		'/dev/' + guestdev1 + '     /            ' + guestfs + '    '),
		('/dev/<yyy>     swap         swap     ',		'/dev/' + guestdev2 + '    swap         swap     '),
		("zoneinfo/<xxx>",					"zoneinfo/Asia/Shanghai"),
		("PAGE=<paper_size>",					"PAGE=A4"),
		("chown -v",						"chown -Rv"),
		("export LANG=<ll>_<CC>.<charmap><@modifiers>",	"export LANG=en_US.utf8"),
		('DISTRIB_CODENAME="<your name here>"',			'DISTRIB_CODENAME="MAO"'),
		("passwd lfs",						"echo 'lfs:ping' | chpasswd"),
		("passwd root",					"echo 'root:ping' | chpasswd"),
		("make test",						""),
		("exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash",		"source /home/lfs/.bashrc"),
		("set root=(hd0,2)",					"set root=(hd0,1)"),
		("root=/dev/sda2 ro",					"root=/dev/" + guestdev1 + " ro"),
		("./configure --prefix=/usr --enable-cxx",		"ABI=" + str(ABI) +" \n\t./configure --prefix=/usr --enable-cxx"),
		("--with-libpam=no",					""),
		("./configure --sysconfdir=/etc",			"./configure --sysconfdir=/etc --with-libpam=no"),
		("make LANG=<host_LANG_value> LC_ALL= menuconfig",	'yes "" | make oldconfig'),
		("mkdir -v",						"mkdir -pv"),
		("mkdir /",						"mkdir -pv /"),
		("grub-install /dev/sda",				"grub-install /dev/" + guestdev ),
		("mount -v -t ext3 /dev/<xxx> $LFS",			'mount -v -t ext3 /dev/' + hostdev1 + ' $LFS'),
		("/sbin/swapon -v /dev/<zzz>",				"/sbin/swapon -v /dev/" + hostdev2),
		("build/udevadm hwdb --update", 			"sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh\nbuild/udevadm hwdb --update"),
		("bash udev-lfs-197-2/init-net-rules.sh",		'bash udev-lfs-197-2/init-net-rules.sh\nsed -i "s/\\"00:0c:29:[^\\".]*\\"/\\"00:0c:29:*:*:*\\"/" /etc/udev/rules.d/70-persistent-net.rules'),
		("useradd -m <newuser>",				'useradd -m ' + newuser),
		("<username>",						newuser),
		("<password>",						passwd),
		('export PATH="$PATH',					'export PATH=$PATH'),
		('<PREFIX>',						'/opt'),
		('dhclient <eth0>',					'dhclient eth0'),
		('--docdir=/usr/share/doc/<udev-Installed LFS Version> &&', '--docdir=/usr/share/doc/' + str(udevversion) + ' &&'),
		('REMOTE_HOSTNAME',					REMOTE_HOSTNAME),
		('mkdir build',						'mkdir -pv build'),
		('mkdir ../',						'mkdir -pv ../'),
		('groupadd lfs',					'groupadd lfs || true'),
		('useradd -s /bin/bash -g lfs -m -k /dev/null lfs',	'useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true'),
		('cat > ~/.bash_profile << "EOF"',			'cat > /home/lfs/.bash_profile << "EOF"'),
		('cat > ~/.bashrc << "EOF"',				'cat > /home/lfs/.bashrc << "EOF"'),
		('source ~/.bash_profile',				'source /home/lfs/.bash_profile')
	 
	
		
]


ignorelist = ['dummy',
	'libfoo',
	'make check',
	'localedef',
	'tzselect',
	'spawn ls',
	'ulimit',
	':options',
	'logout',
	'exit',
	'shutdown -r',
	'grub-img.iso',
	'hdparm -I /dev/sda | grep NCQ',
	'video4linux/',
	'make -k check',
	'make -k test',
	'make test',
	'udevadm test',
	'test_summary',
	'83-cdrom-symlinks.rules',
	'cat /etc/udev/rules.d/70-persistent-net.rules',
	'locale -a',
	'locale name',
	'glibc-check-log',
	'su - lfs',
	'bash -e',
	'grep FATAL check.log',
	'<report-name.twr>',
	'readelf',
	'ABI=32 ./configure ...',
	'make NON_ROOT_USERNAME=nobody check-root',
	'su nobody -s /bin/bash ',
         '-c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"',
	'gmp-check-log',
	'mkdir -v $LFS/usr',
	'mount -v -t ext3 /dev/<yyy> $LFS/usr',
	'make RUN_EXPENSIVE_TESTS=yes check',
	'convmv',
	'</path/to/unzipped/files>',
	'lp -o number-up=2 <filename>',
	'gpg --verify ',
	'gpg gpg --keyserver pgp.mit.edu --recv-keys 0xF376813D',
	'cd /tmp &&',
	'exec /tools/bin/bash --login +h',
	'sed -i \'s/if ignore_if; then continue; fi/#&/\' udev-lfs-197-2/init-net-rules.sh',
	' /etc/udev/rules.d/70-persistent-net.rules',
	'chown -Rv nobody .',
	'exec /bin/bash --login +h',
	'/tools/bin/bash --login',
	'unset pathremove pathprepend pathappend',
	'mkdir -pv /etc/pam.d/',
	'patch -Np1 -i ../Python-2.7.3-bsddb_fix-1.patch &&',
	'tar xvf krb5-1.11.2.tar.gz',
	'cd krb5-1.11.2',
	"ABI=" + str(ABI),
	'install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat \\',
	'    /etc/sgml/sgml-docbook.cat',
	'sshfs THINGY:~ ~/MOUNTPATH',
	'fusermount -u ~/MOUNTPATH',
	'tripwire --init',
	"egrep '^flags.*(vmx|svm)' /proc/cpuinfo",
	'export LIBRARY_PATH=/opt/xorg/lib',
	"echo '",
	"export MAKEFLAGS='-j 2'",
	"make -j2"
	]

def massreplaceline(string):
	for k, v in OrderedDict(globalreplace).iteritems():

		if k in string:
			print "Replacing :",k," with :",v,"\n"

   			string = string.replace(k, v)

	return string


def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]

def replacem(str):
	if str !=None:
		return str.replace('&gt;','>').replace('&lt;','<').replace('&amp;','&')
	else:
		return 'REPLACEME'

def findchild(tag,tagname="kbd"):
	cmdline=""

	if tag.string!=None:
		tmpstr = replacem(tag.string)
		cmdline = cmdline + "\n" + tmpstr

	else:
		cmdline = cmdline + "\n"
		for code in tag.contents:
			#L2
			if code.string != None:
				cmdline = cmdline + replacem(code.string)
			else:
			
				for em in code.contents:
					#L3
					if em.string != None:
						cmdline = cmdline + "\t" +  replacem(em.string)
					
		cmdline = cmdline + "\n"						
	return cmdline

def grep(pattern,fileObj):
	
	for line in open(fileObj,'r'):
		
		if re.search(pattern,line):
			return line

def lineadd(lst,block):

	if block:
		for i,line in enumerate(block.splitlines()):
			if line and line !="\n":
 
			 	if  containsAny(line,ignorelist):
					print "Delete line:",i,":",line
					pass
		   		else:
					#print line
					lst.append(massreplaceline(line) + "\n")
					


def parsecmds(soupsub,link,fullname):

	#print func
	namematch = re.search("^([a-zA-Z0-9]+(-[a-zA-Z]+)*)",fullname)
	shortname = namematch.group(1).lower()
	versionmatch = re.search("-([0-9.]+)",fullname)
	#print shortname
	#targetname =  funcstrip.sub("-",fullname) #+ "-C" + chapternum
	try:
		version = versionmatch.group(1)
	except AttributeError:
		version = ""
	#print version
	if  not os.path.exists(wget_list):
		print "Can' not find " + wget_list
		sys.exit(1)
	if  "libstdc" in shortname:
		shortname = "gcc"
	packlink = grep('/' + shortname + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,wget_list)

	if packlink:
		packmat = re.search("/(" + shortname + "[^/]*\.tar\.((bz2)|(xz)|(gz))$)",packlink)
		packname = packmat.group(1)
	
	#shortname = "libstdc" # Restore
	cmds=soupsub.findAll("kbd",{'class':'command'})
	cmdstr = []
	
	if  cmds:
		cmdstr.append("pkgname=" + shortname + "\n")
		cmdstr.append("version=" + version + "\n")
		cmdstr.append("export MAKEFLAGS='-j 4'\n")
		cmdstr.append("env\n")
		#print cmdstr
		if packlink:

			cmdstr.append("cd ${SOURCES}\n")
			cmdstr.append("rm -rf ${pkgname}-${version} \n")
			cmdstr.append("rm -rf ${pkgname}-build" + "\n")
			cmdstr.append("mkdir -pv ${pkgname}-${version}  \n")
			cmdstr.append("tar xf " + packname + " -C ${pkgname}-${version} --strip-components 1\n")
			cmdstr.append("cd ${pkgname}-${version} \n")
		for cmd in cmds:
			
			lineadd(cmdstr,findchild(cmd)) # cmd.text.encode('utf-8').strip() + "\n" #

		cmdstr.append("exit\n")

		
	return cmdstr



def parsepage(link,fullname):
		

		soupsub = BeautifulSoup(open(link).read())
		page=[]
		page = parsecmds(soupsub,link,fullname.lower())
		return page	

def genscript(links,ccounter,rules,subtarget):

	pcounter = 0
	global lastpkg 
	for link in links:	
		func =  funcstrip.sub("-",link.string).lower()
		
		namematch = re.search("^([a-zA-Z0-9]+(-[a-zA-Z]+)*)",func)
		shortname = namematch.group(1).lower()
		pkg = str(ccounter) + str(pcounter).zfill(2) + "-" + shortname
		print "Parseing: ",func
		page= []
		subsect = []

		if link.has_key('href') and not containsAny(func, ['chroot','package-management','cleaning-up','strip','rebooting','about-lfs','about-sbus']) :
			#print link['href']
			sublink=os.path.dirname(lfspage) + "/"+link['href']

			page = parsepage(sublink,link.string)
		if page:
			packmkfile= scriptfolder + "/" + pkg + ".sh"
			file = open(packmkfile,'wb')	
			file.write("#/bin/bash\n")
			file.write("set +h\n")
			file.write("set -e\n\n\n")	
			file.write("LFS=" + LFS + "\n" )
			file.write("SOURCES=$LFS/sources\n" )
			for pag in page:
				file.write(pag)

			#print "--------------" + lastfunc,func
			subsect += "\n" + pkg + " : " + lastpkg +"\n"
			subsect += "\t@$(call echo_message, Building)\n"
			subsect += "\t@$(USERENV)  && $(SHELL) $(D) $(SCRIPTDIR)/$@.sh $(REDIRECT) \n"
			#trap 'echo kill $$$;kill -- -$$$;exit 2'  1 2 3 15 17 18 23 &&
			subsect += "\t@touch $@\n"
			lastpkg = pkg 
			if "preparing-virtual-kernel-file-systems" not in func:
				subtarget += pkg + " "
			if "changing-ownership" in func:
				subtarget += "601-preparing-virtual-kernel-file-systems"
			rules.extend(subsect)
			file.close
		pcounter +=1
	
	subtarget += "\n"
	return subtarget

def parseindex():


	soup = BeautifulSoup(open(lfspage).read())
	chapters =""
	chapter =""
	
	ccounter=0
	#pcounter=0
	rules = []
	titles=soup.findAll("h4")
	mkfile= makefiledir + "/Makefile"
	mainfile = open(mkfile,'wb')	
	mainfile.write("LFS=" + LFS + "\n" )
	mainfile.write("BUILDDIR=  " + makefiledir + "\n")
	s='''\
D	= -x
SHELL 	= /bin/bash
SOURCES = $(LFS)/sources
LOGDIR	= $(BUILDDIR)/logs
SCRIPTDIR = $(BUILDDIR)/scripts
REDIRECT= > $(LOGDIR)/$@.log 2>&1
USERENV = source ~/.bashrc
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
CHROOT1= /usr/sbin/chroot $(LFS) /tools/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin /tools/bin/bash --login +h -c

CHROOT2= /usr/sbin/chroot $(LFS) /usr/bin/env -i HOME=/root TERM="$$TERM" PS1='\u:\w\$$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login -c

define echo_message
  @echo -e $(BOLD)--------------------------------------------------------------------------------
  @echo -e $(BOLD)$(1) target $(BLUE)$@$(BOLD)$(WHITE)
endef
all : mk_env mk_tools mk_chroot mk_config mk_boot mk_end 

mk_env :
	@$(call echo_message, Building)
	@make chapter4
	@touch $@

chown_logdir:
	$(call echo_message, Building)
	@chown  lfs.lfs $(BUILDDIR)
	@chown -R  lfs.lfs $(LOGDIR)
	@touch $@

mk_tools: chown_logdir
	@$(call echo_message, Building)
	@su - lfs -c "source ~/.bashrc && cd $(BUILDDIR) && make chapter5"
	@touch $@

mk_chroot :
	@$(call echo_message, Building)
	$(CHROOT1) "cd $(BUILDDIR) && make chapter6"
	@touch $@

mk_config :
	@$(call echo_message, Building)
	$(CHROOT2) "cd $(BUILDDIR) && make chapter7"
	@touch $@

mk_boot :
	@$(call echo_message, Building)
	$(CHROOT2) "cd $(BUILDDIR) && make chapter8"
	@touch $@

mk_end :
	@$(call echo_message, Building)
	$(CHROOT2) "cd $(BUILDDIR) && make chapter9"
	@touch $@

'''
	mainfile.write(s)
	#target = "all : mk_env mk_tools mk_chroot mk_config mk_boot mk_end "
	subtarget = ""
	#print titles
	once = 0 
	for title in titles:
		if ccounter > 3 :
			#cha = chstrip.sub("",title.text.strip())
			chapters = "chapter" + str(ccounter) 
			#chaptermkfile = CWD+"/makefiles/" + chapters

			#pkg =  funcstrip.sub("-",link.string).lower()
			#target += " chapter" + str(ccounter) 
			subtarget +=  chapters + " : " 
			uls=title.findNextSiblings()
			for ul in uls:
				links= ul.findAll("a")
				
				subtarget  = genscript(links,ccounter,rules,subtarget)
				#print subtarget
				if "chapter5" in subtarget and not once :
					subtarget += "chapter6 : SHELL=/tools/bin/bash \n"
					once = 1

		ccounter += 1

	if rules:

			#mainfile.write(target + "\n")
			mainfile.write(subtarget)
			for rule in rules:
				mainfile.write(rule)
	mainfile.close


def rmblock(path,block):
	lines = open(path).readlines()
	#for a in lines:
	#	print a
	for k, v in OrderedDict(block).iteritems():
		
		try:                     
			blockstart = lines.index(k  + "\n")  
		except (ValueError,TypeError) as e:
			blockstart = ""
		try:
			blockend = lines.index(v + "\n",blockstart)
			
		except (ValueError,TypeError) as e:
			blockend = ""
		#print blockstart,blockend
		if blockend and blockstart:
			print "Removing Block:",k,v," between ",blockstart," and ",blockend
			del(lines[blockstart:blockend+1])  
		#return lines  
	#print "-------------------------------------"
	#for a in lines:
	#	print a           
	open(path, 'w+').writelines(lines)  


def massreplaceall(fileobj):
	
	#lines = open(fileobj)
	#print type(lines)
	retlines= []

	for i,line in enumerate(open(fileobj)):
		#print line
		if  containsAny(line,ignorelist):
			print "Delete line:",i,":",line
			pass
   		else:
			#print line
			line = massreplaceline(line)
			#print line
			retlines.append(line)
			 # sys.stdout is redirected to the file
	open(fileobj, 'w+').writelines(retlines)  
			#sys.stdout.write(line)
'''
def parseandwrite():
	file = open(output, 'wb')
	file.write("#!/bin/bash\n")
	parseindex(lfspage,file)
	#parseindex(blfspage,file)
	file.close

if  os.path.exists(output):
	var = raw_input(output + " already existed, regenerate?[y/n]: ")
	if 'y' in var or 'Y' in var:
		parseandwrite()
	elif 'n' in var or 'N' in var:
		pass
	else:
		print "Invalid Input, exit"
		sys.exit(1)
else:
	parseandwrite()
'''

parseindex()
#parseindex(blfspage,file)





