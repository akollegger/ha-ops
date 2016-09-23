#! /bin/sh
# file: answers/enlighten.sh

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
BASE_DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG="${BASE_DIR}/koan.cfg"

# load color definitions
. ${BASE_DIR}/src/colorize

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

  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    if [ ! -f "${NEO4J_DIR}/neo4j-${i}/run/neo4j.pid" ]; then
      cluster_member="${NEO4J_DIR}/neo4j-${i}/bin/neo4j"
      echo "${GREEN}>>> Starting neo4j-${i}${RESET}"
      $cluster_member start;
    fi
  done
}

stopCluster() {

  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    cluster_member="${NEO4J_DIR}/neo4j-${i}/bin/neo4j"
    echo "${RED}>>> Stopping neo4j-${i}${RESET}"
    $cluster_member stop;
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
