#!/bin/sh

ROOT=`pwd`
SRCDIR=$ROOT/src
BUILDDIR=$ROOT/build
PREFIX=$ROOT/install

GCC_URL=http://mirror-fpt-telecom.fpt.net/gcc/releases/gcc-4.2.2/gcc-core-4.2.2.tar.bz2
GCC_VERSION=4.2.2
GCC_DIR=gcc-$GCC_VERSION

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/binutils-2.18.tar.bz2
BINUTILS_VERSION=2.18
BINUTILS_DIR=binutils-$BINUTILS_VERSION

NEWLIB_URL=ftp://sources.redhat.com/pub/newlib/newlib-1.15.0.tar.gz
NEWLIB_VERSION=1.15.0
NEWLIB_DIR=newlib-$NEWLIB_VERSION

INSIGHT_URL=http://mirror-fpt-telecom.fpt.net/sourceware/insight/releases/insight-6.8.tar.bz2
INSIGHT_VERSION=6.8
INSIGHT_DIR=insight-$INSIGHT_VERSION

echo "I will build an arm-elf cross-compiler:

  Prefix: $PREFIX
  Sources: $SRCDIR
  Build files: $BUILDDIR

Press ^C now if you do NOT want to do this."
read IGNORE

#
# Helper functions.
#
ensure_source()
{
    URL=$1
    FILE=$(basename $1)

    if [ ! -e $FILE ]; then
	wget -O$FILE $URL
    fi
}

unpack_source()
{
(
    cd $SRCDIR
    ARCHIVE_SUFFIX=${1##*.}
    if [ "$ARCHIVE_SUFFIX" = "gz" ]; then
      tar zxvf $1
    elif [ "$ARCHIVE_SUFFIX" = "bz2" ]; then
      tar jxvf $1
    else
      echo "Unknown archive format for $1"
      exit 1
    fi
)
}

# Create all the directories we need.
#mkdir -p $SRCDIR $BUILDDIR $PREFIX

(
cd $SRCDIR

# First grab all the source files...
ensure_source $GCC_URL
ensure_source $BINUTILS_URL
ensure_source $NEWLIB_URL
ensure_source $INSIGHT_URL

# ... And unpack the sources.
unpack_source $(basename $GCC_URL)
unpack_source $(basename $BINUTILS_URL)
unpack_source $(basename $NEWLIB_URL)
unpack_source $(basename $INSIGHT_URL)
)

# Set the PATH to include the binaries we're going to build.
OLD_PATH=$PATH
export PATH=$PREFIX/bin:$PATH

#
# Stage 1: Build binutils
#
(
(
# First we need to patch binutils, because makeinfo 4.11 fails the
# autoconf check.
cd $SRCDIR/$BINUTILS_DIR
patch -p0 <<"EOF"
--- configure~ 2007-10-10 22:14:56.000000000 +1300
+++ configure 2007-10-10 22:14:56.000000000 +1300
@@ -3680,7 +3680,7 @@
     # For an installed makeinfo, we require it to be from texinfo 4.4 or
     # higher, else we use the "missing" dummy.
     if ${MAKEINFO} --version \
-       | egrep 'texinfo[^0-9]*([1-3][0-9]|4\.[4-9]|[5-9])' >/dev/null 2>&1; then
+       | egrep 'texinfo[^0-9]*([1-3][0-9]|4\.([4-9]|[1-9][0-9])|[5-9])' >/dev/null 2>&1; then
       :
     else
       MAKEINFO="$MISSING makeinfo"
EOF
) || exit 1

# Now, build it.
mkdir -p $BUILDDIR/$BINUTILS_DIR
cd $BUILDDIR/$BINUTILS_DIR

$SRCDIR/$BINUTILS_DIR/configure --target=arm-elf --prefix=$PREFIX \
    --enable-interwork --enable-multilib \
    && make all install
) || exit 1

#
# Stage 2: Patch the GCC multilib rules, then build the gcc compiler only
#
(
MULTILIB_CONFIG=$SRCDIR/$GCC_DIR/gcc/config/arm/t-arm-elf

echo "

MULTILIB_OPTIONS += mno-thumb-interwork/mthumb-interwork
MULTILIB_DIRNAMES += normal interwork

" >> $MULTILIB_CONFIG

mkdir -p $BUILDDIR/$GCC_DIR
cd $BUILDDIR/$GCC_DIR

$SRCDIR/$GCC_DIR/configure --target=arm-elf --prefix=$PREFIX \
    --enable-interwork --enable-multilib \
    --enable-languages="c" --with-newlib \
    --with-headers=$SRCDIR/$NEWLIB_DIR/newlib/libc/include \
    && make all-gcc install-gcc
) || exit 1

#
# Stage 3: Build and install newlib
#
(
(
# Same issue, we have to patch to support makeinfo >= 4.11.
cd $SRCDIR/$NEWLIB_DIR
patch -p0 <<"EOF"
--- configure~ 2007-10-10 22:14:56.000000000 +1300
+++ configure 2007-10-10 22:14:56.000000000 +1300
@@ -3680,7 +3680,7 @@
     # For an installed makeinfo, we require it to be from texinfo 4.4 or
     # higher, else we use the "missing" dummy.
     if ${MAKEINFO} --version \
-       | egrep 'texinfo[^0-9]*([1-3][0-9]|4\.[4-9]|[5-9])' >/dev/null 2>&1; then
+       | egrep 'texinfo[^0-9]*([1-3][0-9]|4\.([4-9]|[1-9][0-9])|[5-9])' >/dev/null 2>&1; then
       :
     else
       MAKEINFO="$MISSING makeinfo"
EOF
) || exit 1

# And now we can build it.
mkdir -p $BUILDDIR/$NEWLIB_DIR
cd $BUILDDIR/$NEWLIB_DIR

$SRCDIR/$NEWLIB_DIR/configure --target=arm-elf --prefix=$PREFIX \
    --enable-interwork --enable-multilib \
    && make all install
) || exit 1

#
# Stage 4: Build and install the rest of GCC.
#
(
cd $BUILDDIR/$GCC_DIR

make all install
) || exit 1

#
# Stage 5: Build and install INSIGHT.
#

(
# Now, build it.
mkdir -p $BUILDDIR/$INSIGHT_DIR
cd $BUILDDIR/$INSIGHT_DIR

$SRCDIR/$INSIGHT_DIR/configure --target=arm-elf --prefix=$PREFIX \
    --enable-interwork --enable-multilib \
    && make all install
) || exit 1


export PATH=$OLD_PATH

echo "
Build complete! Add $PREFIX/bin to your PATH to make arm-elf-gcc and friends
accessible directly.
"
