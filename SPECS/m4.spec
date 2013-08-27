Name:           m4
Version:	1.4.16
Release:        1%{?dist}
Summary:	The M4 package contains a macro processor.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/m4.html
Source0:        http://ftp.gnu.org/gnu/m4/m4-1.4.16.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The M4 package contains a macro processor.

%prep
%setup -q

%build

sed -i -e '/gets is a/d' lib/stdio.in.h

./configure --prefix=/usr
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
