Name:           pkg-config
Version:	0.28
Release:        1%{?dist}
Summary:	The pkg-config package contains a tool for passing the include path          and/or library paths to build tools during the configure and make          file execution.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/pkg-config.html
Source0:        http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The pkg-config package contains a tool for passing the include path          and/or library paths to build tools during the configure and make          file execution.

%prep
%setup -q

%build

./configure --prefix=/usr         \
            --with-internal-glib  \
            --disable-host-tool   \
            --docdir=/usr/share/doc/pkg-config-0.28
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog
