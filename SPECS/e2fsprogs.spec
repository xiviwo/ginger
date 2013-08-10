Name:           e2fsprogs
Version:	1.42.7
Release:        1%{?dist}
Summary:	The E2fsprogs package contains the utilities for handling theext2file system. It also supports          theext3andext4journaling file systems.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/e2fsprogs.html
Source0:        http://prdownloads.sourceforge.net/e2fsprogs/e2fsprogs-1.42.7.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The E2fsprogs package contains the utilities for handling theext2file system. It also supports          theext3andext4journaling file systems.

%prep
%setup -q

%build
rm -rf build

mkdir -v build
cd build

../configure --prefix=/usr         \
             --with-root-prefix="" \
             --enable-elf-shlibs   \
             --disable-libblkid    \
             --disable-libuuid     \
             --disable-uuidd       \
             --disable-fsck
make %{?_smp_mflags}

%install
cd build
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
make install-libs DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/share/info
mkdir -pv $RPM_BUILD_ROOT/usr/share
chmod -v u+w $RPM_BUILD_ROOT/usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v $RPM_BUILD_ROOT/usr/share/info/libext2fs.info.gz

install-info --dir-file=/usr/share/info/dir $RPM_BUILD_ROOT/usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo

install -v -m644 doc/com_err.info $RPM_BUILD_ROOT/usr/share/info

install-info --dir-file=/usr/share/info/dir $RPM_BUILD_ROOT/usr/share/info/com_err.info


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

