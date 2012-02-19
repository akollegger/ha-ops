#! /bin/sh
# file: answers/enlighten.sh

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
BASE_DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG="${BASE_DIR}/koan.cfg"

# set up "-i" for sed, os-dependent way
dashi=(-i "")  # default is version of sed that works on Mac OS X
os=`uname`
os_lwr=$(echo "$os" | sed 's/^\(\w\{5\}\).*/\1/' | tr '[A-Z]' '[a-z]')
case "$os_lwr" in
    "linux" )  dashi=(-i) ;;
    "cygwi" )  dashi=(-i) ;;
    "mingw" )  dashi=(-i) ;;
esac


# prepare workspace
enlightenment_01() {
  NEO4J_VERSION="1.6"
  KOAN_WORKSPACE="${BASE_DIR}/workspace"
  COORDINATOR_DIR="${KOAN_WORKSPACE}/coordinators"
  COORDINATOR_COUNT=3
  NEO4J_DIR="${KOAN_WORKSPACE}/neo4j"

  # create the koan.cfg file
  echo "# Neo4j HA-OPS Enlightened Koan Configuration" > ${KOAN_CONFIG}
  echo "NEO4J_VERSION=\"${NEO4J_VERSION}\"" >> ${KOAN_CONFIG}
  echo "KOAN_WORKSPACE=\"${KOAN_WORKSPACE}\"" >> ${KOAN_CONFIG}
  echo "COORDINATOR_DIR=\"${COORDINATOR_DIR}\"" >> ${KOAN_CONFIG}
  echo "COORDINATOR_COUNT=\"${COORDINATOR_COUNT}\"" >> ${KOAN_CONFIG}
  echo "NEO4J_DIR=\"${NEO4J_DIR}\"" >> ${KOAN_CONFIG}

  # prepare the workspace
  mkdir -p "${KOAN_WORKSPACE}"
  mkdir -p "${COORDINATOR_DIR}"
  mkdir -p "${NEO4J_DIR}"

  # download neo4j into workspace, if not already there
  NEO4J_ARCHIVE="neo4j-enterprise-${NEO4J_VERSION}-unix.tar.gz"
  
  if [[ ! -f "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}" ]]; then 
    curl http://dist.neo4j.org/${NEO4J_ARCHIVE} --output "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}"; 
  fi
}

# create and configure coordinators
enlightenment_02() {
  if [[ ! -d "${KOAN_WORKSPACE}/neo4j-enterprise-${NEO4J_VERSION}" ]]; then
    tar xzf "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}" -C "${KOAN_WORKSPACE}"
  fi
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    cp -rn "${KOAN_WORKSPACE}/neo4j-enterprise-${NEO4J_VERSION}/" "${COORDINATOR_DIR}/coord-${i}" 2>&1; 
  done

  # modify coord.cfg
  # strip existing server.n and clientPort settings
  find "${COORDINATOR_DIR}" -name coord.cfg -print | \
    xargs sed -e '/server\.[0-9]/d' -e '/clientPort=/d' "${dashi[@]}"

  # append local server settings
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    echo "server.1=localhost:2888:3888" >>  "${COORDINATOR_DIR}/coord-${i}/conf/coord.cfg"
    echo "server.2=localhost:2889:3889" >>  "${COORDINATOR_DIR}/coord-${i}/conf/coord.cfg"
    echo "server.3=localhost:2890:3890" >>  "${COORDINATOR_DIR}/coord-${i}/conf/coord.cfg"
  done
  
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    echo "clientPort=218${i}" >>  "${COORDINATOR_DIR}/coord-${i}/conf/coord.cfg"
  done

  # set zookeeper instance ids
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    echo ${i} > $COORDINATOR_DIR/coord-${i}/data/coordinator/myid; 
  done
  

}

enlightenment_01
enlightenment_02

echo ${KOAN_CONFIG}
