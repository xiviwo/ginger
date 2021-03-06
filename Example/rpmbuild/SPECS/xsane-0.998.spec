%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     XSane is another front end for SANE-1.0.23. It has additional features to improve the image quality and ease of use compared to xscanimage. 
Name:       xsane
Version:    0.998
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  sane
Requires:  xdg-utils-rc1
Source0:    ftp://ftp2.sane-project.org/pub/sane/xsane/xsane-0.998.tar.gz
URL:        ftp://ftp2.sane-project.org/pub/sane/xsane
%description
 XSane is another front end for SANE-1.0.23. It has additional features to improve the image quality and ease of use compared to xscanimage. 
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
sed -i -e 's/netscape/xdg-open/'                   src/xsane.h      
sed -i -e 's/png_ptr->jmpbuf/png_jmpbuf(png_ptr)/' src/xsane-save.c 
./configure --prefix=/usr                                           
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/gimp/2.0/plug-ins
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/sane/xsane
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make xsanedocdir=${RPM_BUILD_ROOT}/usr/share/doc/xsane-0.998 install  DESTDIR=${RPM_BUILD_ROOT} 

ln -v -s ../../doc/xsane-0.998 ${RPM_BUILD_ROOT}/usr/share/sane/xsane/doc

ln -v -s <browser> ${RPM_BUILD_ROOT}/usr/bin/netscape

ln -v -s ${RPM_BUILD_ROOT}/usr/bin/xsane ${RPM_BUILD_ROOT}/usr/lib/gimp/2.0/plug-ins/


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