
import re,sys
from package import Package
from util import *
from lxml import etree
from collections import deque
import urllib2
from consts import *
from mirror import DownMirror
reload(sys) 
sys.setdefaultencoding('utf-8') 

perlcmd= ['perl Makefile.PL && make && make install\n']
counter = 0

#mirrorfile = open(mfile).read()

class Page(object):
	''' Page class to simulate one page of LFS book
		PageNo: page order from LFS book
		pagename: page name 
		pagelink: page link
		chapter: the chapter page belongs to 
		book: the book the chapter belongs to 
		
		use xpath to analyse html page 
	'''
	def __init__(self,pageNo,pagename,pagelink,chapter,book):
		self.no= pageNo
		self.name = pagename
		self._packages = []
		self.book = book
		self.link = self.book.bookdir + "/" + pagelink
		self.chapter = chapter
		self._soup = None
		self._summary = ""
		self.versionlink = baselink + self.book.version + "/"
		self.mirror = DownMirror(mfile)

	def show(self):
		print self.no,self.name,self.link

	@property
	def summary(self):
		if not self._summary:
			summary = str(''.join(re.sub("[ \n]+"," ",''.join(i).encode('utf-8')) 
 						  for i in self.pagesoup.xpath(".//div[@class='package']/p[1]//text()")))
			if summary :
				self._summary = summary
			else:
				self._summary = ""
		return self._summary
	
	def parsedownload(self,subsoup):
		''' parse download link from page, http://www.aaa.com/bbb.tar.gz '''
		download_link = []
		short = shortname(self.name)
		ver = version(self.name)

		if  "libstdc" in short:
				short = "gcc"
		#if "udev" in short:
		#		short = "systemd"
		
		if self.book.wget_file_list:
			# change in 7.6, '-[^/]*\.tar\.((bz2)|(xz)|(gz))$'
			# fail :preparepack glib 2.40.0 glibc-2.20.tar.xz

			link = grep('/' + short + '-{0,1}[^/]*' + ver + '[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.wget_file_list)
			
			if link:
				download_link.append(link)
		if download_link:
			
			return download_link
		else:
			
			uls=subsoup.xpath(".//div[@class='itemizedlist']/ul[@class='compact']")
			counter=0
			if uls:
		
				for ul in uls:
					for alink in ul.xpath(".//a[@class='ulink']"):
						dlink = alink.attrib['href'].strip()
						if str(dlink ).endswith('/') \
							or "certdata" in str(dlink ) \
							or str(dlink ).endswith('.html') \
							or str(dlink ).endswith('dict')  :
							pass  
						else:
							mirrorlink = self.mirror.search(dlink)
							download_link.append(dlink)
							if mirrorlink:
								download_link.append(mirrorlink)
							

			return download_link

	def parsedependency(self,depsoup):
		''' parse dependeies name from page with xpath  '''
		ps=depsoup.xpath(".//p[contains(@class,'required') or contains(@class,'recommended')]")
		noskip = 1 
		if ps:
			dependstr=""

			for p in ps:
				
				for node in p.xpath("./node()"):
					
					try:
						
						
						dname = node.xpath("./@title")[0]
						
						if noskip:
							pkgname = NormName(dname)
							
							if containsAny(pkgname,["x-window-system"]):
								short =  "x-window-system-environment"
							elif containsAny(pkgname,['udev-installed-lfs-version']):
								short = 'udev-extras-from-systemd'
							elif  'xorg-build-environment' in pkgname:
								short = 'introduction-to-xorg-7.7'
							else:
								short = shortname(dname)
							ver = version(dname)	
							if ver:
								dependstr += short + "-"  + ver + " "
							else:
								dependstr += short + " "
							
						noskip = 1
					except (AttributeError,IndexError):
						try:
							dname = node.strip()
							
							if "or" == dname:
								noskip = 0
							continue
						except AttributeError:
							continue
						
							
					
		else:
			dependstr=""

		return dependstr


	def addpack(self,package):
		self._packages.append(package)

	def mirrorsearch(self,link):
		
		mirrorlink = self.mirror.search(link)
						
		if mirrorlink:
						
			return mirrorlink
		else:
			return None

	def parseexternal(self,link):
		''' search the package on cpan.org and get the download link  '''
		
		shortname = re.search(r'/([^/]*)/$',link,re.IGNORECASE).group(1) #like LWP-Protocol-https
		packlink=""
		if self.book.perl_packs:
			packlink = grep('/' + shortname + '-([0-9.]+)[^/]*\.tar\.((bz2)|(xz)|(gz))$' ,self.book.perl_packs)
			
		if packlink:
			return [packlink,self.mirrorsearch(packlink)]
		else:
			soup = etree.HTML(urllib2.urlopen(link).read())
	
			alinks = soup.xpath(".//a/@href")
			for alink in alinks:
				if "tar.gz" in alink:
					packlink = alink.strip()
	
			if packlink:
				match = re.search('(http://[^/]+/)',link) #http://search.cpan.org/
				packlink=match.group(1) +  packlink.strip("/") + "\n"
				file = open(perl_pack_lists,"a")
				file.write(packlink)
				file.close
				return [packlink,self.mirrorsearch(packlink)]
			else:
				return []

	
	def parseperldownload(self,link):
		''' Decide what kind of download link it is , and take relative action '''
		if link:#.attrib['href']:
			#link = str(alink.attrib['href'].strip())
			 
			if link.endswith('/'): 
				#parse external link :http://search.cpan.org/~gaas/LWP-Protocol-https/
			
				return self.parseexternal(link)
				

			elif   ".html" in link:
				# same page no need to parse,
				#ex:# /www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
				#within BLFS, no need to parse
				return []

			else:# otherwises, need to parse all 
				return [link,self.mirrorsearch(link)]

	
	def parseperl(self,plist,i):
		''' For perl package only, parse perl pacakge  '''
		global counter
		#link =  "www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html"
		link = self.book.perl_modules_link
		
		soup = etree.HTML(open(link).read())#BeautifulSoup(open(link).read())

		divs = soup.xpath(".//div[@class='package']/div[@class='itemizedlist']")
		#(findNextSibling(attrs={'class':'itemizedlist'})
		for div in divs:
			if div != None :
				
				
				self.perldepend(div,None,plist,i,[])
				i = counter
	

	
	def perldepend(self,div,link,plist,i,lastdown):

		'''
			For perl package only, parse perl dependencies 
		'''
		'''
		div : next div to parse
		link: next link of div to parse ex: ['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']
		
		'''
		global counter
		nextdown = deque()
		dependency=""			
		downloads=[]					

		lis = div.xpath("./ul/li")
		#encode-locale-1.03  html-form-6.03  http-cookies-6.01  http-negotiate-6.01 
		# net-http-6.06  www-robotrules-6.02  http-daemon-6.01  file-listing-6.04
		print 'link:',link
		for li in lis:
			
			try:
				dependlink = li.xpath("./div/p/a")
				
				dependtext = li.xpath("./div/p/a//text()")[0].strip()

			except :
				dependlink = li.xpath("./p/a")
				if li.xpath("./p/a//text()"):
					dependtext = li.xpath("./p/a//text()")[0].strip()
				else :	
					dependtext = ""
			for a in dependlink:
				
				try:
					url = a.attrib['href'].strip()
				except (KeyError,AttributeError):
					continue

			print 'url=',url
			if link != None and ".html" in url: 
				# /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/general/perl-modules.html#perl-lwp
				# /home/tomwu/www.linuxfromscratch.org/blfs/view/svn/postlfs/openssl.html
				downloads = []
	
			else:#http://www.cpan.org/authors/id/N/NA/NANIS/Crypt-SSLeay-0.64.tar.gz/ TITLE
				downloads = filter(None,self.parseperldownload(url))
			print 'down:',downloads

			if downloads:
				#if download exists, parse its download link as dependency
				packname = parselink(downloads[0]).strip(".tar.gz")
				
				dependency += fullname(packname) + "  "
			else:   # or parse its text as dependency 
				print "dependtext:",dependtext
				print li.xpath(".//a//text()"),dependtext
				dependency += fullname(dependtext) + " "
			print 'depend:',dependency,li.xpath("./div")

			if downloads and len(li.xpath("./div")) == 1:
				# li has not div descendants, mean there is no dependency along with it.
				packname = fullname(packname)
				
				i += 1
				packno = packno = str(self.no) + str(i)
				print 'packname:',packname,packno,downloads
				plist.append(
				Package(packno,packname,perlcmd,downloads,"",self,self.chapter,self.book))
				counter =  i
			elif downloads:
				for down in downloads:
					nextdown.append(down)
		
		if link is not None:
			# previous parents exists,['libwww-perl-6.05']->['HTML::Form']->['HTTP::Message']

			thisdown = lastdown.popleft() 
			packname = fullname(parselink(thisdown).strip(".tar.gz"))
	
			i += 1
			packno = packno = str(self.no) + str(i)

			plist.append(
			Package(packno,packname,perlcmd,[thisdown],dependency,self,self.chapter,self.book))
			counter = i

		nextdiv = div.xpath("./ul/li/div[@class='itemizedlist']")# next div to parse
		for ndiv in nextdiv:  # Iterate over div of class itemizedlist
			
			isnextdiv = ndiv.xpath("./preceding-sibling::*/a/text()")
			# Tiltle of next div need to be iterate, for example, Crypt::SSLeay-0.64
			#print "next link:",isnextdiv
			if ndiv is not None:
				self.perldepend(ndiv,isnextdiv,plist,i,nextdown)

	
	@property
	def pagesoup(self):
		
		if not self._soup:
			self._soup = etree.HTML(open(self.link).read())
		return self._soup

	def parsecmds(self,lines,cmds):
		''' Parse  pacakge command block, cornerstone for this script '''
		for line in lines:
			if line is not None:
				
				prev = ''.join(l.strip() for l in line.xpath("../preceding-sibling::p[1]//text()"))
				thisline = ''.join(str(l) for l in line.xpath(".//text()")) + "\n"
				#make line extend two line into one line
				thisline =  re.compile(r'\s*\\\n\s*',re.MULTILINE).sub(' ',thisline)
				if containsAny(prev, ['doxygen','Doxygen','texlive','TeX Live','Sphinx']) \
				    and not containsAny(prev,['Install Doxygen']):
					
					pass
				elif containsAny(prev, ['documentation','manual']) and \
					 containsAny(prev, ['If you','API','alternate''optional',
										  'Sphinx','DocBook-utils','Additional',
										  'PDF','Postscript']) and  \
					 not containsAny(prev,['If you downloaded',
                                          'Man and info reader programs',
											'The Info documentation system']):
					
					pass
				elif line.xpath("../preceding-sibling::p//a[@title='BLFS Boot Scripts']"):
					bootscript = self.book.search("BLFS")

					
					cmds.append("mkdir /etc\n")
					cmds.append("mkdir  ${SOURCES}/" + bootscript[0].shortname + "\n")
					cmds.append("cd ${SOURCES}/" + bootscript[0].shortname + "\n")
					cmds.append("tar xf ../" + parselink(bootscript[0].downloads[0])+ 
														  "  --strip-components 1\n")

					cmds.append(thisline)

				else:
					cmds.append(thisline)
			else:
				
				cmds.append(line.xpath(".//text()") + "\n")

			
	@property
	
	def packages(self):
		''' instanctiate package class on demand, as it's very costy'''
		print "lazy generating packages :" + shortname(self.name)
		if not self._packages:
			
			pagesoup = self.pagesoup
			string = shortname(self.name)
			
			if string == "python-modules" or string == "xorg-drivers" :
				
				headers = pagesoup.xpath(".//h2[@class='sect2']") 
			else:
				headers = pagesoup.xpath(".//h1[@class='sect1']")
			plist = [] 
			for i,header in enumerate(headers):
			 
				
				parent =header.xpath(".//parent::*")[0]
				lines=parent.xpath(".//kbd[@class='command']")
				cmds =[]
				downs = []
				downs =  self.parsedownload(parent)
				
				self.parsecmds(lines,cmds)
				
				
				if cmds or downs:
					
					packname = ''.join(str(l) for l in header.xpath(".//text()")) 

					#if 'xkeyboardconfig' in string:
					#	packname = 'xkeyboard-config' + "-" + version(self.name)
					# Change in lfs 7.5
					if string == "perl-modules":
						
						self.parseperl(plist,i)
						i = counter
					else:
						packno = str(self.no) + str(i+1)
						
						depends = ""
						
						if "blfs" in self.book.link:
							depends = self.parsedependency(parent)
						plist.append(Package(
											packno,
											packname,
											cmds,
											downs,
											depends,
											self,
											self.chapter,
											self.book))
			self._packages = plist
		return self._packages
						
