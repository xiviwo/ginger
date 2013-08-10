Name:           grep
Version:	2.14
Release:        1%{?dist}
Summary:	The Grep package contains programs for searching through files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/grep.html
Source0:        http://ftp.gnu.org/gnu/grep/grep-2.14.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Grep package contains programs for searching through files.

%prep
%setup -q

%build

./configure --prefix=/usr --bindir=/bin
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

