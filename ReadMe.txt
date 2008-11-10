=== GNU ARM TOOLCHAIN INSTALLER ===

This latest version works with: 

 * binutils-2.19
 * gcc-4.3.2.tar
 * newlib-1.16.0
 * insight-6.8


To install

1. Download the latest installer gnu-arm-installer-v0.1.tar.gz and then extract by typing:

tar xzf gnu-arm-installer-v0.1.tar.gz

2. Download the following source files to gnu-arm-installer/src

http://gnuarm.org/binutils-2.19.tar.bz2
http://gnuarm.org/gcc-4.3.2.tar.bz2
http://gnuarm.org/newlib-1.16.0.tar.gz
http://gnuarm.org/insight-6.8.tar.bz2

and type these commands:

cd gnu-arm-installer
./gnu-arm-installer.sh


The installer will extract and compile all of the source files automatically. If it is successful, you will get the toolchain in install/ directory.

Support forum:
http://forum.mcuprogramming.com/arm/gnu-arm-toolchain-installer/0/

License: 
GPL v3 (http://www.gnu.org/copyleft/gpl.html)

Maintained by: Waipot Ngamsaad (waipot@ngamsaad.name)

