%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     XChat is an IRC chat program. It allows you to join multiple IRC channels (chat rooms) at the same time, talk publicly, have private one-on-one conversations, etc. File transfers are also possible. 
Name:       xchat
Version:    2.8.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  gtk
Source0:    http://www.xchat.org/files/source/2.8/xchat-2.8.8.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xchat-2.8.8.tar.bz2
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/xchat-2.8.8-glib-2.31-1.patch
URL:        http://www.xchat.org/files/source/2.8
%description
 XChat is an IRC chat program. It allows you to join multiple IRC channels (chat rooms) at the same time, talk publicly, have private one-on-one conversations, etc. File transfers are also possible. 
%pre
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
patch -Np1 -i %_sourcedir/xchat-2.8.8-glib-2.31-1.patch &&
LIBS+="-lgmodule-2.0" ./configure --prefix=/usr --sysconfdir=/etc --enable-shm &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/xchat-2.8.8 &&

install -v -m644    README faq.html ${RPM_BUILD_ROOT}/usr/share/doc/xchat-2.8.8


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog