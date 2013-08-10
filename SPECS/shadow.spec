Name:           shadow
Version:	4.1.5.1
Release:        1%{?dist}
Summary:	The Shadow package contains programs for handling passwords in a          secure way.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/shadow.html
Source0:        http://pkg-shadow.alioth.debian.org/releases/shadow-4.1.5.1.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Shadow package contains programs for handling passwords in a          secure way.

%prep
%setup -q

%build

sed -i 's/groups$(EXEEXT) $RPM_BUILD_ROOT//' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 $RPM_BUILD_ROOT/ $RPM_BUILD_ROOT/' {} \;

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs



./configure --sysconfdir=/etc --with-libpam=no
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/bin
mv -v $RPM_BUILD_ROOT/usr/bin/passwd $RPM_BUILD_ROOT/bin
sed -i 's/yes/no/' $RPM_BUILD_ROOT/etc/default/useradd

%post
pwconv
grpconv
passwd root << "EOF"
ping
ping
EOF


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

