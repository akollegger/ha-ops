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
  NEO4J_VERSION=${1}
  KOAN_WORKSPACE="${BASE_DIR}/workspace"
  COORDINATOR_DIR="${KOAN_WORKSPACE}/coordinators"
  COORDINATOR_COUNT=3
  NEO4J_DIR="${KOAN_WORKSPACE}/neo4j"
  NEO4J_COUNT=3

  # create the koan.cfg file
  echo "# Neo4j HA-OPS Enlightened Koan Configuration" > ${KOAN_CONFIG}
  echo "NEO4J_VERSION=\"${NEO4J_VERSION}\"" >> ${KOAN_CONFIG}
  echo "KOAN_WORKSPACE=\"${KOAN_WORKSPACE}\"" >> ${KOAN_CONFIG}
  echo "COORDINATOR_DIR=\"${COORDINATOR_DIR}\"" >> ${KOAN_CONFIG}
  echo "COORDINATOR_COUNT=\"${COORDINATOR_COUNT}\"" >> ${KOAN_CONFIG}
  echo "NEO4J_DIR=\"${NEO4J_DIR}\"" >> ${KOAN_CONFIG}
  echo "NEO4J_COUNT=\"${NEO4J_COUNT}\"" >> ${KOAN_CONFIG}

  # prepare the workspace
  mkdir -p "${KOAN_WORKSPACE}"
  mkdir -p "${COORDINATOR_DIR}"
  mkdir -p "${NEO4J_DIR}"

  # download neo4j into workspace, if not already there
  NEO4J_ARCHIVE="neo4j-enterprise-${NEO4J_VERSION}-unix.tar.gz"
  
  if [[ ! -f "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}" ]]; then 
    curl http://dist.neo4j.org/${NEO4J_ARCHIVE} --output "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}"; 
  fi

  # also untar it, for easier replication by other steps
  if [[ ! -d "${KOAN_WORKSPACE}/neo4j-enterprise-${NEO4J_VERSION}" ]]; then
    tar xzf "${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}" -C "${KOAN_WORKSPACE}"
  fi
}

# create and configure coordinators
enlightenment_02() {
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

# create and configure neo4j cluster
enlightenment_03() {
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    cp -rn "${KOAN_WORKSPACE}/neo4j-enterprise-${NEO4J_VERSION}/" "${NEO4J_DIR}/neo4j-${i}" 2>&1; 
  done

  # modify neo4j-server.properties
  # strip existing settings from neo4j-server.properties
  find "${NEO4J_DIR}" -name neo4j-server.properties -print | \
    xargs sed -e '/org\.neo4j\.server\.webserver\.port/d' -e '/org\.neo4j\.server\.database\.mode/d' "${dashi[@]}"

  # set ha mode
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    echo "org.neo4j.server.database.mode=ha" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j-server.properties"
  done
  
  # configure unique ports
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    echo "org.neo4j.server.webserver.port=747$(($i+3))" >>  "${NEO4J_DIR}/neo4j-${i}/conf/neo4j-server.properties"
  done

  # strip settings from neo4j.properties
  find "${NEO4J_DIR}" -name neo4j.properties -print | \
    xargs sed -e '/ha\.machine_id/d' -e '/ha\.server/d' \
      -e '/ha\.zoo_keeper_servers/d' -e '/enable_remote_shell/d' \
      -e '/ha\.pull_interval/d' "${dashi[@]}"

  # set ha.machine_id, ha.server
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    echo "ha.machine_id = ${i}" >>  "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.properties"
    echo "ha.server = localhost:600${i}" >>  "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.properties"
    echo "ha.zoo_keeper_servers = localhost:2181,localhost:2182,localhost:2183" >>  "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.properties"
    echo "ha.pull_interval = 2" >>  "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.properties"
    echo "enable_remote_shell = port=1331" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.properties"
  done
  
}

enlightenment_01 ${1:-"1.8"}
enlightenment_02
enlightenment_03

echo ${KOAN_CONFIG}
