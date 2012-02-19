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

startCluster() {

  # first, the coordinators
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    if [ ! -f "${COORDINATOR_DIR}/coord-${i}/data/neo4j-coordinator.pid" ]; then 
      ${COORDINATOR_DIR}/coord-${i}/bin/neo4j-coordinator start; 
    fi 
  done

  # then the neo4j cluster
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    if [ ! -f "${NEO4J_DIR}/neo4j-${i}/data/neo4j-service.pid" ]; then 
      ${NEO4J_DIR}/neo4j-${i}/bin/neo4j start; 
    fi 
  done
}

stopCluster() {

  # first the neo4j cluster
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do 
    ${NEO4J_DIR}/neo4j-${i}/bin/neo4j stop; 
  done

  # then the coordinators
  for (( i=1; i<=${COORDINATOR_COUNT}; i++ )); do 
    ${COORDINATOR_DIR}/coord-${i}/bin/neo4j-coordinator stop; 
  done
}

. "${KOAN_CONFIG}"

case "${1}" in
  start)
    startCluster
    ;;

  stop)
    stopCluster
    ;;

  restart)
    stopCluster
    startCluster
    ;;

  *)
    echo "Usage: cluster { start | stop | restart }"
    exit 1;;

esac

exit $?


