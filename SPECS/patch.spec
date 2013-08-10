Name:           patch
Version:	2.7.1
Release:        1%{?dist}
Summary:	The Patch package contains a program for modifying or creating          files by applying a &ldquo;patch&rdquo;          file typically created by thediffprogram.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html
Source0:        http://ftp.gnu.org/gnu/patch/patch-2.7.1.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Patch package contains a program for modifying or creating          files by applying a &ldquo;patch&rdquo;          file typically created by thediffprogram.

%prep
%setup -q

%build

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

