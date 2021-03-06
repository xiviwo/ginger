#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gtkmm
version=2.24.4
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.4.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gtkmm-2.24.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
