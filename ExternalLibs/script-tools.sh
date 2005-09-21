
download() {
   URL=${1}
   OUT_FILE=${2}

   GET_PRG=`which fetch 2>/dev/null`
   if [ -x "${GET_PRG}" ]; then
      GET_CMD="${GET_PRG} -o "
   else 
      GET_PRG=`which wget 2>/dev/null`
      if [ -x "${GET_PRG}" ]; then
         GET_CMD="${GET_PRG} -O "
      else
         GET_PRG=`which curl 2>/dev/null`
         if [ -x "${GET_PRG}" ]; then
            GET_CMD="${GET_PRG} -o "
         else
            echo "No one of wget, fetch and curl was found!"
            echo "You need to have at least one of them on your path."
            return 1
         fi
      fi
   fi

   echo "Downloading ${URL} ..."
   ${GET_CMD} ${OUT_FILE} ${URL}
   return $?
}

get_and_unpack_pkg() {
   PKG_ARCH=${1}
   PKG_DIR=${2}
   PKG_URL=${3}/${PKG_ARCH}
   PKG_ARCH_PATH=`dirname ${PKG_DIR}`/${PKG_ARCH}
   
   if [ ! -d ${PKG_DIR} ]; then
      if [ ! -f ${PKG_ARCH_PATH} ]; then
         download "${PKG_URL}" "${PKG_ARCH_PATH}"
         if [ $? -ne 0 ]; then
            rm -f "${PKG_ARCH_PATH}"
            echo "****************************************************"
            echo "Unable to download ${PKG_URL}!"
            echo -n "You can download ${PKG_ARCH} manually and copy it to "
            TARGET_DIR=`dirname ${PKG_ARCH_PATH}`
            echo -n "`(cd ${TARGET_DIR} && pwd)`"
            echo ". Then try make again."
            echo "****************************************************"
            return 1
         fi
      fi
      
      if [ ! -f ${PKG_ARCH_PATH} ]; then
         echo "${PKG_ARCH_PATH} not found!"
         return 1
      fi
      
      echo "unpacking ${PKG_ARCH_PATH}" 
      (cd `dirname ${PKG_ARCH_PATH}` && gzip -dc ${PKG_ARCH}|tar xf -)
      if [ $? -ne 0 ]; then
         echo "Unable to unpack ${PKG_ARCH_PATH}"
         return 1
      fi
   fi
   return 0
}

