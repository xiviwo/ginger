%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GStreamer Good Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality code, correct functionality, and the preferred license (LGPL for the plug-in code, LGPL or LGPL-compatible for the supporting library). A wide range of video and audio decoders, encoders, and filters are included. 
Name:       gst-plugins-good
Version:    1.0.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gst-plugins-base
Requires:  cairo
Requires:  flac
Requires:  gdk-pixbuf
Requires:  libjpeg-turbo
Requires:  libpng
Requires:  libsoup
Requires:  libvpx
Requires:  xorg-libraries
Source0:    http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.0.10.tar.xz
URL:        http://gstreamer.freedesktop.org/src/gst-plugins-good
%description
 The GStreamer Good Plug-ins is a set of plug-ins considered by the GStreamer developers to have good quality code, correct functionality, and the preferred license (LGPL for the plug-in code, LGPL or LGPL-compatible for the supporting library). A wide range of video and audio decoders, encoders, and filters are included. 
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
./configure --prefix=/usr --with-package-name="GStreamer Good Plugins 1.0.10 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/"  
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