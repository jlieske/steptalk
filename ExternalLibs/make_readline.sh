#!/bin/sh

READLINE_VERSION=5.0

# don't modify anything below
echo "-------------------------"
echo " Build readline in place "
echo "-------------------------"
echo "DON'T PANIC: I'M NOT INSTALLING READLINE ON YOUR SYSTEM"

. ./script-tools.sh

READLINE_ARCH=readline-${READLINE_VERSION}.tar.gz
READLINE=src/readline-${READLINE_VERSION}
READLINE_URL="http://ftp.gnu.org/pub/gnu/readline/"

get_and_unpack_pkg ${READLINE_ARCH} ${READLINE} ${READLINE_URL}
if [ $? -ne 0 ]; then
   exit 1
fi

INSTALL=`pwd`/readline
echo "installing readline to ${INSTALL}"

if [ -f ${READLINE}/Makefile ]; then
   (cd ${READLINE} && make distclean)
fi

(cd ${READLINE} && \
 ./configure --prefix=${INSTALL} --disable-shared && \
 make && \
 make install)
RC=$?

if [ ${RC} -eq 0 ]; then
   echo "---------------------------------------"
   echo " readline has been build successfully  "
   echo "---------------------------------------"
else
   echo "BUILD FAILED!"
fi

# add version number to library names to distinguish the self compiled
# readline from the version that is installed on the system
rm -f ${INSTALL}/lib/libreadline-5.0.a
rm -f ${INSTALL}/lib/libhistory-5.0.a
mv ${INSTALL}/lib/libreadline.a ${INSTALL}/lib/libreadline-5.0.a
mv ${INSTALL}/lib/libhistory.a ${INSTALL}/lib/libhistory-5.0.a

exit ${RC}
