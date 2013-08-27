Name:           bison
Version:	2.7
Release:        1%{?dist}
Summary:	The Bison package contains a parser generator.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/bison.html
Source0:        http://ftp.gnu.org/gnu/bison/bison-2.7.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Bison package contains a parser generator.

%prep
%setup -q

%build
echo '#define YYENABLE_NLS 1' >> lib/config.h
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
