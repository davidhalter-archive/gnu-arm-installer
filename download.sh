sudo aptitude install libmpfr-dev
mkdir src/
rm src/*

wget http://ftp.gnu.org/gnu/binutils/binutils-2.19.1.tar.bz2 -O src/binutils-2.19.1.tar.bz2
wget http://ftp.gnu.org/gnu/gcc/gcc-4.3.2/gcc-4.3.2.tar.bz2 -O src/gcc-4.3.2.tar.bz2
wget ftp://sources.redhat.com/pub/newlib/newlib-1.16.0.tar.gz -O src/newlib-1.16.0.tar.gz
wget ftp://sourceware.org/pub/insight/releases/insight-6.8-1a.tar.bz2 -O src/insight-6.8-1.tar.bz2

# not important? patches!
#wget http://openhardware.net/Embedded_ARM/Toolchain/patches/Thumb/gcc-4.3.2_patch.gz -O src/gcc-4.3.2_patch.gz
#wget http://openhardware.net/Embedded_ARM/Toolchain/patches/Thumb/newlib_makefile_patch.gz -O src/newlib_makefile_patch.gz
