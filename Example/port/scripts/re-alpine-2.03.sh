#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=re-alpine
version=2.03
export MAKEFLAGS='-j 4'
download()
{
nwget http://sourceforge.net/projects/re-alpine/files/re-alpine-2.03.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" re-alpine-2.03.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --without-ldap --without-krb5 --with-ssl-dir=/usr --with-passfile=.pine-passfile 
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
