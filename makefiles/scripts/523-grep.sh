#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=grep
version=2.14
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf grep-2.14.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools
make
make install
