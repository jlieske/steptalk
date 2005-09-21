#!/bin/sh

check_result() {
   if [ ${1} -ne 0 ]; then
      echo "failed to install ${2}"
      exit 1
   fi
}

install() {
   PRODUCT=${1}
   if [ -z "${PRODUCT}" ]; then
      echo "no product to install"
      exit 1
   fi

   TARGET_DIR=${2}
   if [ -z "${TARGET_DIR}" ]; then
      echo "no target directory"
      exit 1
   fi
   
   mkdir -p ${TARGET_DIR}
   rm -rf ${TARGET_DIR}/${PRODUCT}
   cp -r ${PRODUCT} ${TARGET_DIR}
   check_result $? "${PRODUCT}"
}

install StepTalk.framework ~/Library/Frameworks
cd Modules
install AppKit.bundle ~/Library/StepTalk/Modules
install Foundation.bundle ~/Library/StepTalk/Modules
install ObjectiveC.bundle ~/Library/StepTalk/Modules
install SimpleTranscript.bundle ~/Library/StepTalk/Modules
cd ../Languages
install Smalltalk.stlanguage ~/Library/StepTalk/Languages
cd ../Tools
install stexec ~/Library/StepTalk/Tools
install stshell ~/Library/StepTalk/Tools

