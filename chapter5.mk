
General_Compilation_Instructions:
	
echo $LFS

Binutils_2_23_2_Pass_1:
	
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo	
mkdir -v ../binutils-build
cd ../binutils-build	
../binutils-2.23.2/configure   \
    --prefix=/tools            \
    --with-sysroot=$LFS        \
    --with-lib-path=/tools/lib \
    --target=$LFS_TGT          \
    --disable-nls              \
    --disable-werror	
make	
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac	
make install

GCC_4_8_1_Pass_1:
	
tar -Jxf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -Jxf ../gmp-5.1.2.tar.xz
mv -v gmp-5.1.2 gmp
tar -zxf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc	
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done	
sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure	
mkdir -v ../gcc-build
cd ../gcc-build	
../gcc-4.8.1/configure                               \
    --target=$LFS_TGT                                \
    --prefix=/tools                                  \
    --with-sysroot=$LFS                              \
    --with-newlib                                    \
    --without-headers                                \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --disable-nls                                    \
    --disable-shared                                 \
    --disable-multilib                               \
    --disable-decimal-float                          \
    --disable-threads                                \
    --disable-libatomic                              \
    --disable-libgomp                                \
    --disable-libitm                                 \
    --disable-libmudflap                             \
    --disable-libquadmath                            \
    --disable-libsanitizer                           \
    --disable-libssp                                 \
    --disable-libstdc++-v3                           \
    --enable-languages=c,c++                         \
    --with-mpfr-include=$(pwd)/../gcc-4.8.1/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs	
make	
make install	
ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

Linux_3_9_6_API_Headers:
	
make mrproper	
make headers_check
make INSTALL_HDR_PATH=dest headers_install
	
cp -rv dest/include/* /tools/include

Glibc_2_17:
	
if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -p /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi	
mkdir -v ../glibc-build
cd ../glibc-build	
../glibc-2.17/configure                             \
      --prefix=/tools                               \
      --host=$LFS_TGT                               \
      --build=$(../glibc-2.17/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.25                        \
      --with-headers=/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes	
make	
make install	
echo 'main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'	
rm -v dummy.c a.out

Libstdc_4_8_1:
	
	mkdir -pv ../gcc-build
	cd ../gcc-build	
	../gcc-4.8.1/libstdc++-v3/configure \
	    --host=$LFS_TGT                      \
	    --prefix=/tools                      \
	    --disable-multilib                   \
	    --disable-shared                     \
	    --disable-nls                        \
	    --disable-libstdcxx-threads          \
	    --disable-libstdcxx-pch              \
	    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/4.8.1	
	make	
	make install

Binutils_2_23_2_Pass_2:
	
	sed -i -e 's/@colophon/@@colophon/' \
	       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo	
	mkdir -v ../binutils-build
	cd ../binutils-build	
	CC=$LFS_TGT-gcc                \
	AR=$LFS_TGT-ar                 \
	RANLIB=$LFS_TGT-ranlib         \
	../binutils-2.23.2/configure   \
	    --prefix=/tools            \
	    --disable-nls              \
	    --with-lib-path=/tools/lib \
	    --with-sysroot	
	make	
	make install	
	make -C ld clean
	make -C ld LIB_PATH=/usr/lib:/lib
	cp -v ld/ld-new /tools/bin

GCC_4_8_1_Pass_2:
	
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h	
cp -v gcc/Makefile.in{,.tmp}
sed 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp \
  > gcc/Makefile.in	
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
  -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done	
tar -Jxf ../mpfr-3.1.2.tar.xz
mv -v mpfr-3.1.2 mpfr
tar -Jxf ../gmp-5.1.2.tar.xz
mv -v gmp-5.1.2 gmp
tar -zxf ../mpc-1.0.1.tar.gz
mv -v mpc-1.0.1 mpc	
mkdir -v ../gcc-build
cd ../gcc-build	

CC=$LFS_TGT-gcc                                      \
CXX=$LFS_TGT-g++                                     \
AR=$LFS_TGT-ar                                       \
RANLIB=$LFS_TGT-ranlib                               \
../gcc-4.8.1/configure                               \
    --prefix=/tools                                  \
    --with-local-prefix=/tools                       \
    --with-native-system-header-dir=/tools/include   \
    --enable-clocale=gnu                             \
    --enable-shared                                  \
    --enable-threads=posix                           \
    --enable-__cxa_atexit                            \
    --enable-languages=c,c++                         \
    --disable-libstdcxx-pch                          \
    --disable-multilib                               \
    --disable-bootstrap                              \
    --disable-libgomp                                \
    --with-mpfr-include=$(pwd)/../gcc-4.8.1/mpfr/src \
    --with-mpfr-lib=$(pwd)/mpfr/src/.libs	
make	
make install	
ln -sv gcc /tools/bin/cc	
echo 'main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'	
rm -v dummy.c a.out

Tcl_8_6_0:
	
sed -i s/500/5000/ generic/regc_nfa.c	
cd unix
./configure --prefix=/tools	
make	
TZ=UTC make test	
make install	
chmod -v u+w /tools/lib/libtcl8.6.so	
make install-private-headers	
ln -sv tclsh8.6 /tools/bin/tclsh

Expect_5_45:
	
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure	
./configure --prefix=/tools --with-tcl=/tools/lib \
  --with-tclinclude=/tools/include	
make	
make test	
make SCRIPTS="" install

DejaGNU_1_5_1:
	
./configure --prefix=/tools	
make install	
make check

Check_0_9_10:
	
./configure --prefix=/tools	
make	
make check	
make install

Ncurses_5_9:
	
./configure --prefix=/tools --with-shared \
    --without-debug --without-ada --enable-overwrite	
make	
make install

Bash_4_2:
	
patch -Np1 -i ../bash-4.2-fixes-12.patch	
./configure --prefix=/tools --without-bash-malloc	
make	
make tests	
make install	
ln -sv bash /tools/bin/sh

Bzip2_1_0_6:
	
make	
make PREFIX=/tools install

Coreutils_8_21:
	
./configure --prefix=/tools --enable-install-program=hostname	
make	
make RUN_EXPENSIVE_TESTS=yes check	
make install

Diffutils_3_3:
	
./configure --prefix=/tools	
make	
make check	
make install

File_5_14:
	
./configure --prefix=/tools	
make	
make check	
make install

Findutils_4_4_2:
	
./configure --prefix=/tools	
make	
make check	
make install

Gawk_4_1_0:
	
./configure --prefix=/tools	
make	
make check	
make install

Gettext_0_18_2_1:
	
cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared	
make -C gnulib-lib
make -C src msgfmt	
cp -v src/msgfmt /tools/bin

Grep_2_14:
	
./configure --prefix=/tools	
make	
make check	
make install

Gzip_1_6:
	
./configure --prefix=/tools	
make	
make check	
make install

M4_1_4_16:
	
sed -i -e '/gets is a/d' lib/stdio.in.h	
./configure --prefix=/tools	
make	
make check	
make install

Make_3_82:
	
./configure --prefix=/tools	
make	
make check	
make install

Patch_2_7_1:
	
./configure --prefix=/tools	
make	
make check	
make install

Perl_5_18_0:
	
patch -Np1 -i ../perl-5.18.0-libc-1.patch	
sh Configure -des -Dprefix=/tools	
make	
cp -v perl cpan/podlators/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.18.0
cp -Rv lib/* /tools/lib/perl5/5.18.0

Sed_4_2_2:
	
./configure --prefix=/tools	
make	
make check
make install

Tar_1_26:
	
sed -i -e '/gets is a/d' gnu/stdio.in.h	
./configure --prefix=/tools	
make	
make check	
make install

Texinfo_5_1:
	
./configure --prefix=/tools	
make	
make check	
make install

Xz_5_0_4:
	
./configure --prefix=/tools	
make	
make check	
make install

Stripping:
	
strip --strip-debug /tools/lib/*
strip --strip-unneeded /tools/{,s}bin/*	
rm -rf /tools/{,share}/{info,man,doc}

Changing_Ownership:
	
chown -R root:root $LFS/tools
ConstructingaTemporarySystem : General_Compilation_Instructions Binutils_2_23_2_Pass_1 GCC_4_8_1_Pass_1 Linux_3_9_6_API_Headers Glibc_2_17 Libstdc_4_8_1 Binutils_2_23_2_Pass_2 GCC_4_8_1_Pass_2 Tcl_8_6_0 Expect_5_45 DejaGNU_1_5_1 Check_0_9_10 Ncurses_5_9 Bash_4_2 Bzip2_1_0_6 Coreutils_8_21 Diffutils_3_3 File_5_14 Findutils_4_4_2 Gawk_4_1_0 Gettext_0_18_2_1 Grep_2_14 Gzip_1_6 M4_1_4_16 Make_3_82 Patch_2_7_1 Perl_5_18_0 Sed_4_2_2 Tar_1_26 Texinfo_5_1 Xz_5_0_4 Stripping Changing_Ownership 
