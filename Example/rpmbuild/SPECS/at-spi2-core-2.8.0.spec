%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The At-Spi2 Core package is a part of the GNOME Accessibility Project. It provides a Service Provider Interface for the Assistive Technologies available on the GNOME platform and a library against which applications can be linked. 
Name:       at-spi2-core
Version:    2.8.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  d-bus
Requires:  glib
Requires:  intltool
Requires:  xorg-libraries
Source0:    http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.8/at-spi2-core-2.8.0.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.8/at-spi2-core-2.8.0.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.8
%description
 The At-Spi2 Core package is a part of the GNOME Accessibility Project. It provides a Service Provider Interface for the Assistive Technologies available on the GNOME platform and a library against which applications can be linked. 
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
./configure --prefix=/usr --sysconfdir=/etc --libexecdir=/usr/lib/at-spi2-core 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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