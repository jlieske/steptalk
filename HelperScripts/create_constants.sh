#!/bin/sh

if [ -z "${1}" ]; then
   echo "usage: create_constants.sh basename [Cocoa]"
   exit 1
fi

LIST=${1}.list
if [ ! -z "${2}" ]; then
   LIST=${2}${LIST}
fi

SRC=${1}.m

echo "Creating ${1}"
cat header.m | sed "s/@@NAME@@/${1}/g" > ${SRC}; \
cat ${LIST} | awk -f create_constants.awk >> ${SRC}; \
cat footer.m >> ${SRC};
exit $?
