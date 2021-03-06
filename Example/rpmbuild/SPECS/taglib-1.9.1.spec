%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Taglib is a library used for reading, writing and manipulating audio file tags and is used by applications such as Amarok and VLC. 
Name:       taglib
Version:    1.9.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Source0:    https://github.com/taglib/taglib/releases/download/v1.9.1/taglib-1.9.1.tar.gz
URL:        https://github.com/taglib/taglib/releases/download/v1.9.1
%description
 Taglib is a library used for reading, writing and manipulating audio file tags and is used by applications such as Amarok and VLC. 
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
mkdir -pv build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&


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