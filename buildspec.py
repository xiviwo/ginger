#!/bin/env  python
# Version 1.02
# fix version 
#

import urllib2,os,binascii,re,string,subprocess
try:
	from collections import OrderedDict
except ImportError:
	from ordereddict import OrderedDict

try:
	from BeautifulSoup import BeautifulSoup
except ImportError:
	from bs4 import BeautifulSoup
#homedir=os.path.expanduser('~')
IP="192.168.136.13"
GATEWAY="192.168.136.2"
BROADCAST="192.168.136.255"
domain="ibm.com"
nameserver1 ="192.168.136.2"
nameserver2 ="192.168.136.1"
hostname= "alfs"
guestdev1="sda1"
guestdev2="sda2"
guestfs="ext3"

homepage="http://www.linuxfromscratch.org/lfs/view/stable"
CWD=os.path.dirname(os.path.realpath(__file__))
lfspage=CWD + "/www.linuxfromscratch.org/lfs/view/development/index.html"
blfspage=CWD +	"/www.linuxfromscratch.org/blfs/view/svn/index.html"
lfslocaldir=os.path.dirname(lfspage)
blfslocaldir=os.path.dirname(blfspage)
wget_list="/mnt/lfs/sources/wget-list"


funcstrip= re.compile("\\b&nbsp;\\b|[ \~\:\+\?'\$\(\)\/\n\t\r]+",re.MULTILINE)
#header =  re.compile("^[a-zA-Z0-9]+(_[a-zA-Z]+)?")
#chstrip= re.compile("[0-9\. ]+")
descstrip= re.compile("[\n\t\r]*",re.MULTILINE)
chstrip= re.compile("[0-9\.\-\/\n\t\r\(\) ]+",re.MULTILINE)
endstrip = re.compile("#.*$")
orstrip = re.compile("[ \t,\n\r]+",re.MULTILINE)

if not os.path.exists(lfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent www.linuxfromscratch.org/lfs/view/stable/")
#soup = BeautifulSoup(urllib2.urlopen(homepage).read())
if not os.path.exists(blfslocaldir):
	os.system("wget --recursive  --no-clobber --html-extension  --convert-links  --restrict-file-names=windows  --domains www.linuxfromscratch.org   --no-parent www.linuxfromscratch.org/blfs/view/svn/")


def replacem(str):
	if str !=None:
		return str.replace('&gt;','>').replace('&lt;','<').replace('&amp;','&')
	else:
		return 'REPLACEME'


def grep1(filestr,searchstr):
	#print searchstr
	try:
	   with open(filestr,'r') as readfile: 
		#print readfile
		for line in readfile:
			 
			if searchstr.lower() in line:
	   			 
				return line
	except IOError:
	   print 'IO error'

def grep2(filename, arg):
	#print arg
	process = subprocess.Popen(['grep','-Ei', arg, filename], stdout=subprocess.PIPE)
	stdout, stderr = process.communicate()
	print stdout
	return stdout, stderr

def grep(pattern,fileObj):
	
	for line in open(fileObj,'r'):
		
		if re.search(pattern,line):
			return line

def lineadd(lst,block):
	if block:
		for cmdstr in block.splitlines():
			if cmdstr and cmdstr !="\n":
				#cmdstr = addtarget(cmdstr)
				lst.append(cmdstr)

globalreplace = [
		
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
		("export LANG=<ll>_<CC>.<charmap><@modifiers>",	"export LANG=en_US.utf8"),
		('DISTRIB_CODENAME="<your name here>"',			'DISTRIB_CODENAME="MAO"'),
		("cat > /",						"cat > $RPM_BUILD_ROOT/"),
		("cat >> /",						"cat >> $RPM_BUILD_ROOT/"),
		("ln -sv /run /var/run",				"ln -sv ../../run $RPM_BUILD_ROOT/var/run"),
		("ln -sv /run/lock /var/lock",				"ln -sv ../../run/lock $RPM_BUILD_ROOT/var/lock"),
		("set root=(hd0,2)",					"set root=(hd0,1)"),
		("root=/dev/sda2 ro",					"root=/dev/" + guestdev1 + " ro"),
		("./configure --prefix=/usr --enable-cxx",		"ABI=32 ./configure --prefix=/usr --enable-cxx"),
		('echo "127.0.0.1 localhost $(hostname)" > /etc/hosts',	'mkdir -pv $RPM_BUILD_ROOT/etc/\necho "127.0.0.1 localhost ' + hostname + '" > $RPM_BUILD_ROOT/etc/hosts'),
		("f ../",						"f ~/rpmbuild/SOURCES/"),
		("chgrp -v utmp /var/log/lastlog",			"sudo chgrp -v utmp $RPM_BUILD_ROOT/var/log/lastlog"),
		("mkdir /",						"mkdir -pv /"),
		('sed -i s/\\"1\\"/\\"8\\"/1 /usr/share/man/man8/chroot.8', 	'sed -i s/\\"1\\"/\\"8\\"/1 $RPM_BUILD_ROOT/usr/share/man/man8/chroot.8'),	
		('sed -i \'s/find:=${BINDIR}/find:=\/bin/\' /usr/bin/updatedb', 'sed -i \'s/find:=${BINDIR}/find:=\/bin/\' $RPM_BUILD_ROOT/usr/bin/updatedb'),
		('sed -i \'s/yes/no/\' /etc/default/useradd',		'sed -i \'s/yes/no/\' $RPM_BUILD_ROOT/etc/default/useradd'),
		("$LFS",						"$RPM_BUILD_ROOT"),
		("mknod -m",						"sudo mknod -m"),		
		("mkdir -v",						"mkdir -pv"),
		("mkdir -pv /var/lib/hwclock",				"mkdir -pv  $RPM_BUILD_ROOT/var/lib/hwclock"),
		("PAGE=<paper_size>",					"PAGE=A4"),
		("./configure --sysconfdir=/etc",			"./configure --sysconfdir=/etc --with-libpam=no"),
		("make LANG=<host_LANG_value> LC_ALL= menuconfig",	'yes "" | make oldconfig'),
		("passwd root",					"echo 'root:ping' | chpasswd"),
		("build/udevadm hwdb --update",				"$(type -pa udevadm) hwdb --update"),
		("grub-install /dev/sda",				"grub-install /dev/sdb"),
		('cat > $RPM_BUILD_ROOT/boot/grub/grub.cfg << "EOF"',			'mkdir -pv $RPM_BUILD_ROOT/dev\nsudo umount -v $RPM_BUILD_ROOT/dev || true\nsudo mount -v --bind /dev $RPM_BUILD_ROOT/dev\ncat > $RPM_BUILD_ROOT/boot/grub/device.map << \"EOF\"\n(hd0)	/dev/sda\n(hd1)	/dev/sdb\nEOF\ncat > $RPM_BUILD_ROOT/boot/grub/grub.cfg << \"EOF\"'),
		("bash udev-lfs-197-2/init-net-rules.sh",		'sudo rm -f /etc/udev/rules.d/70-persistent-net.rules\nsudo bash udev-lfs-197-2/init-net-rules.sh DESTDIR=\nmkdir -pv $RPM_BUILD_ROOT/etc/udev/rules.d/\nsudo cp -v /etc/udev/rules.d/70-persistent-net.rules $RPM_BUILD_ROOT/etc/udev/rules.d/\nsed -i \'s/\"00:0c:29:[^\\".]*\"/\"00:0c:29:*:*:*\"/\' $RPM_BUILD_ROOT/etc/udev/rules.d/70-persistent-net.rules'),
		("DESTDIR=",						"DESTDIR=$RPM_BUILD_ROOT")
		
]
OrderedDict(globalreplace)

def massreplace(string):
	for k, v in OrderedDict(globalreplace).iteritems():
		#print "from: ",k,"to: ",v
		#if "make LANG=<host_LANG_value>" in string and "host_LANG_value" in k:

			#print k,"============",v
   		string = string.replace(k, v)
		#if "grub/grub.cfg" in string:

			#print string
	return string

def replaceall(string):

	#if "grub/grub.cfg" in string:

	#	print string
	string = massreplace(string)

	
	if "=/" in string and not containsAny(string,['vmlinuz','configure','sed -i','Configure']):
		string = string.replace("=/","=$RPM_BUILD_ROOT/")

	if containsAll(string, [' /']) and not containsAny(string,['#','vimrc','ehci_hcd','pri=1','/dev/','/proc','/sys ','devpts','tmpfs','exec','/etc/ld.so.conf.d/*.conf','sed -i','-e \"s|']):
		
		string = string.replace(" /"," $RPM_BUILD_ROOT/")
	
	if containsAll(string,['make','install']):
		if "make modules_install" in string:
			string = string + " INSTALL_MOD_PATH=$RPM_BUILD_ROOT"
		if "make BINDIR=$RPM_BUILD_ROOT/sbin install" in string: 
			string = string + " install prefix=$RPM_BUILD_ROOT"
			
		if "make -C src install" in string:
			string = string + " ROOT=$RPM_BUILD_ROOT "
		else:
			
			string = string + " DESTDIR=$RPM_BUILD_ROOT"
		
	return string +"\n"

def removefromlist(lst,string):
	filtered = [ v for v in lst if string not in v ]
	return filtered

def containsAny(str, set):
    """Check whether 'str' contains ANY of the chars in 'set'"""
    return 1 in [c in str for c in set]

def containsAll(str, set):
    """Check whether 'str' contains ALL of the chars in 'set'"""
    return 0 not in [c in str for c in set]

def foldername(str):
	if os.path.isdir(str):
		return str
	else:
		 return os.path.dirname(str)
def findfolder(rest):
	folders = []
	for r in rest:
		folderrest = re.findall('[ ](/[^ {},]*)',r)
		if folderrest:
			for fr in folderrest:
				folders.append(foldername(fr))
	return folders
				#print "match:" +  + "\n "
def parsepage(link,pack,name,version):
	soupsub = BeautifulSoup(open(link).read())
	cmds=soupsub.findAll("kbd",{'class':'command'})
	if cmds:
		print pack + "\n"
		summary = soupsub.findAll("div",attrs={'class':'package'})
		if summary:
			summ = descstrip.sub("",summary[0].p.text)
		else:
			summ = ""
		#print summ
		if  "Headers" in name:
			packlink = grep('/linux[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,wget_list)
		elif "Udev" in pack:
			packlink = grep('/systemd[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,wget_list)
		else:
			packlink = grep('/' + name.lower() + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,wget_list)
	
		#print packlink
		sources=[]
		patchs = []
		configure = []
		buildstr=[]
		buildfolder=""
		makestr=[]
		makeinstallstr=[]
		postconfig = []
		sedstr= []
		postrun=[]
		rest= []
		folders= [] 
		junks = []
		config = soupsub.findAll('h2',{'class':'sect2'})
		for cmd in cmds:
			entrystr = cmd.text.encode('utf-8').strip()
			if  containsAny(entrystr,['dummy','mount -v','libfoo','--login','make check','localedef','tzselect','dumpspecs','spawn ls','ulimit','chown -Rv',':options','logout','shutdown -r','grub-img.iso','hdparm','video4linux/','check-','TESTS','make -k check','make -k test','make test','udevadm test','test_summary','83-cdrom-symlinks.rules','cat /etc/udev/rules.d/70-persistent-net.rules','/tools/bin',' /tools/lib','s/tools/usr/','/tools/$(gcc ','ABI=32 ./','locale -a','LC_ALL=<locale name> locale','init-net-rules.sh']):
				junks.append(entrystr) #pass
			elif containsAny(entrystr, ['sed -i','echo \'','echo \"127.0.0.1 localhost $(hostname)\" > /etc/hosts']) and not containsAny(entrystr,['testsuite','Cracklib','test','mv -v','/etc/default/useradd']):
				#print pack
				
				lineadd(sedstr,entrystr)
					
				
			elif ".patch" in entrystr:
				patchmatch = re.search('/([^/]+\.patch$)',entrystr)
				patchs.append(patchmatch.group(1))

			elif containsAny(entrystr, ['pwconv','grpconv','passwd root','grub-install ','build/udevadm hwdb --update']) :
				postrun.append(entrystr)

			elif re.search('udev-lfs-' + version + '.*\.tar\..*$',entrystr):
				#containsAny(entrystr,['udev-lfs-' + version ]):
				#print entrystr
				versionmat = re.search("-([0-9.]+-[0-9]+)",entrystr)
				udevversion = versionmat.group(1)
				#print udevversion
				sources.append(entrystr.replace("f ../","f ~/rpmbuild/SOURCES/"))
				sources.append("sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-" + udevversion + "/init-net-rules.sh")
			elif re.search('((\.\./\w*-)*build$)',entrystr):
			# deal with build folder,ex binutils-build 
				lineadd(buildstr,entrystr)
				buildmatch = re.search('((\.\./\w*-)*build$)',entrystr)
				try:
					buildfolder = buildmatch.group(1)
				except AttributeError:
					buildfolder = ""
			elif containsAny(entrystr, ['configure','Configure']) :
				
				configure.append(entrystr)
			
			elif "make" in entrystr and not containsAny(entrystr, ['install','check','test']) :
				#print entrystr

				lineadd(makestr,entrystr)

			elif  containsAll(entrystr, ['install','make']) and not containsAny(entrystr,['makeinfo']) :
				#print entrystr
				if "Sysklogd" in pack:
					makeinstallstr.append("for i in `seq 1 10`")
					makeinstallstr.append("do\n	mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man$i\ndone")
					makeinstallstr.append("\nmkdir -pv $RPM_BUILD_ROOT/sbin")
				lineadd(makeinstallstr,entrystr)
				if "Udev" in pack:
					makeinstallstr.append("sudo rm -f /etc/udev/rules.d/70-persistent-net.rules")
					makeinstallstr.append("sudo bash udev-lfs-" + udevversion + "/init-net-rules.sh DESTDIR=")
					makeinstallstr.append("mkdir -pv $RPM_BUILD_ROOT/etc/udev/rules.d/")
					makeinstallstr.append("sudo cp -v /etc/udev/rules.d/70-persistent-net.rules $RPM_BUILD_ROOT/etc/udev/rules.d/")
					makeinstallstr.append("sed -i 's/\\\"00:0c:29:[^\\\\\".]*\\\"/\\\"00:0c:29:*:*:*\\\"/' $RPM_BUILD_ROOT/etc/udev/rules.d/70-persistent-net.rules")
			else:
				#print entrystr				
				lineadd(rest,entrystr)
		if "Sysklogd" in pack:		
				sedstr.append("sed -i \"s/MAN_USER = root/MAN_USER = $(whoami)/\" Makefile")
				sedstr.append("sed -i \"s/MAN_GROUP = root/MAN_GROUP = $(groups | cut -d' ' -f1)/\" Makefile")
		
		folders = findfolder(rest)
		folders += findfolder(makeinstallstr)
		#print sources
		text = "Name:           " + name.lower() + "\n"
		if version:
	
			text += "Version:	"  + version + "\n"
		else:
			text += "Version:	1.0\n"
		text += "Release:        1%{?dist}\n"	
		if summ:
			text += "Summary:	" + summ + "\n"
		else:
			text += "Summary:	" + name.lower() + "\n"
		text += "\n"
		text += "Group:		Development/System\n"
		text += "License:        GPL\n"
		text += "URL:            " + link.replace(CWD,"http:/") + "\n"
		if packlink:
			text += "Source0:        " + packlink + "\n"
		#if sources:
		#	i=1
		#	for source in sources:
		#		text += "Source" + str(i) + ":        " + source + "\n"
		if patchs:
			i=0
			for patch in patchs:
				text += "Patch" + str(i) + ":        " + patch + "\n"
				i=i+1

		text += "BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)\n"
		text += "\n\n"

		text += "%description\n"
		if summary:
			text +=  summ + "\n\n"
		else:
			text += pack + "\n\n"
		text += "%prep\n"	

		if packlink:
			
			if  "Headers" in name:
				
				text += "%setup -q -n linux-%{version}\n"
				#print text
			elif "Udev" in pack:
				text += "%setup -q -n systemd-%{version}\n"
			elif "Sysvinit" in pack:
				text += "%setup -q -n sysvinit-%{version}dsf\n"
			elif "Vim" in pack:
				text += "%setup -q -n vim73\n"
			else:
				text += "%setup -q \n"
		if sources:
			#i=1
			for source in sources:
				#print source
				text += source + "\n"
			
		if patchs:
			i=0
		
			for patch in patchs:
				text += "%patch" + str(i) + " -p1 " + "\n"
				i=i+1
			text += "\n"

		text +="\n\n"

		text += "%build\n"
		if sedstr:
			for seds in sedstr:				
				text += replaceall(seds) 
		if buildstr:
			text +="rm -rf " + buildfolder + "\n"
			for bstr in buildstr:
				text += bstr + "\n"
		if configure:
			#for conf in configure:
			text += replaceall(configure[0])
		if makestr:
			for make in makestr:
				text += replaceall(make).rstrip('\n') + " %{?_smp_mflags}\n\n"
		#else:
		
			#text += "make %{?_smp_mflags}\n\n"
		text +="\n\n"

		text += "%install\n"
		
		text += "rm -rf $RPM_BUILD_ROOT\n"

		if buildstr:
			text +="cd " + buildfolder + "\n"
		if folders:
			for f in set(folders):
				text += "mkdir -pv $RPM_BUILD_ROOT" + f + "\n"
		if "Util-linux" in pack:
				
			text +="sed -i 's/chgrp tty/sudo &/' Makefile\n"

		if makeinstallstr:
			for string in makeinstallstr:		
				text += replaceall(string)
		


		if rest:
			for res in rest:
				
				text += replaceall(res)
				#print replaceall(res)
		text += "cd $RPM_BUILD_ROOT/usr/share/info\n"
		text +=  "rm -v dir\n"


		text += "\n\n%post\n"
		if postrun:
			
			for prun in postrun:
				text += replaceall(prun)
		text += "cd /usr/share/info\n"
		text +=  "for f in *\n"
		text +=  "do install-info $f dir 2>/dev/null\n"
		text +=  "done\n"

		text += "\n\n%clean\n"
		
		if "Using-GRUB-to-Set-Up-the-Boot-Process" in pack:
			text += "sudo umount -v $RPM_BUILD_ROOT/dev || true\n"
		text += "rm -rf $RPM_BUILD_ROOT\n"	
		text += "\n\n%files\n"
		text += "%defattr(-,root,root,-)\n"
		text += "%doc\n"
		text += "/*\n"
		text += "\n%changelog\n"
		text = text.encode('utf-8').strip()
		#print text
		if  rest or  makeinstallstr:
			#print pack
			output=os.path.expanduser("~/rpmbuild/SPECS/") +  name.lower() + ".spec"
			file = open(output, 'wb')
			file.write(text)
			file.close


def parseindex(index):
	match = re.search('/([a-z]*lfs)/',index)
	try:
		book = match.group(1).upper()
	except AttributeError:
		book = ""
	soup = BeautifulSoup(open(index).read())
	#chapters ="export " + book + "CHAPTERS=\""
	#chapter =""

	
	#file.write("BLFS_Boot_Scripts_C2(){\n: \n} \n\n")
	titles=soup.findAll("h4")
	counter=0
	#print titles
	for title in titles:
		
		cha = chstrip.sub("",title.text.strip())
		#chapters = chapters + "C" + str(counter) + "_" + cha + " "
		
	
		#chapter="export " + "C" + str(counter) + "_" +  cha + "=\""
		uls=title.findNextSiblings()
		for ul in uls:
			links= ul.findAll("a")
		
			for link in links:	
				pack =  funcstrip.sub("-",link.string)  
				namematch = re.search("^[a-zA-Z0-9]+(-[a-zA-Z]+)*",pack)
				versionmatch = re.search("-([0-9.]+)",pack)
				name = namematch.group()
				
				try:
					version = versionmatch.group(1)
				except AttributeError:
					version = ""
				#print version
	
				#chapter=chapter + func + " "
	
				if link.has_key('href'):
					#print link['href']
					sublink=os.path.dirname(index) + "/"+link['href']
					#print sublink
					#if "Wget" in func or "OpenSSH" in func or "OpenSSL" in func or "BLFS_Boot" in func:
					if counter > 5:
						#print name
						#print version
						#print pack
						if "Headers" in pack:
							#pass#file.write(parseperl(sublink))
							parsepage(sublink,"linux-" + version ,"Linux-API-Headers",version)
						
						else:
						
							parsepage(sublink,pack,name,version)
	
			#chapter = chapter + "\"\n"
			
			if "XWindowSystemEnvironment" in cha:
				#chapter=chapter +  cha + "(){\n"
				for link in links:
					func =  funcstrip.sub("",link.string) #+ "_C" + str(counter)
					#chapter=chapter + func + "\n"
				#chapter = chapter + "\n}\n"

			#file.write(chapter + "\n\n")
			
		counter = counter + 1

	#file.write(chapters+"\"\n")

#file.write("#!/bin/bash\n")
parseindex(lfspage)
#parseindex(blfspage)

