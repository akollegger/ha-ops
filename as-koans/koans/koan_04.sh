#! /bin/sh
# file: koans/koan_04.sh

# unset vars are an error
set -u

BASE_DIR=${BASE_DIR:-"`dirname $0`/.."}
LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG=${KOAN_CONFIG:-"${BASE_DIR}/koan.cfg"}

echo "Koan 4 - Start the HA Cluster"
echo "-----------------------------"

testCoordinatorCluster()
{
  checkZookperRunning 1 2181
  checkZookperRunning 2 2182
  checkZookperRunning 3 2183
}

checkZookperRunning()
{
  local coord_number=$1
  local coord_port=$2
  local port_check="`nmap -p ${coord_port} localhost -oG - | grep ${coord_port}/open`"
  assertTrue "coordinator ${coord_number} does not appear to be running (port ${coord_port} not open)" \
    "[ -n '${port_check}' ]"  
  assertTrue "coordinator ${coord_number} pid file is missing" \
    "[ -f ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid ]"
  if [ -f ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid ]; then
    local pid_check=`cat ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid`
    assertNull "coordinator ${coord_number} does not appear to be running (no running process with pid ${pid_check})" \
    "`kill -0 ${pid_check} 2> /dev/null`"
  fi

}

testNeo4jCluster()
{
  checkNeo4jRunning 1 7474
  checkNeo4jRunning 2 7475
  checkNeo4jRunning 3 7476
}

checkNeo4jRunning()
{
  local neo4j_number=$1
  local neo4j_port=$2
  local port_check="`nmap -p ${neo4j_port} localhost -oG - | grep ${neo4j_port}/open`"
  assertTrue "neo4j ${neo4j_number} does not appear to be running (port ${neo4j_port} not open)" \
    "[ -n '${port_check}' ]"  
  assertTrue "neo4j ${neo4j_number} pid file is missing" \
    "[ -f ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid ]"
  if [ -f ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid ]; then
    local pid_check=`cat ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid`
    assertNull "neo4j ${neo4j_number} does not appear to be running (no running process with pid ${pid_check})" \
    "`kill -0 ${pid_check} > /dev/null 2>&1`"
  fi

}
oneTimeSetUp()
{
  # load include to test
  . "${KOAN_CONFIG}"
}

# load shunit2
. ${BASE_DIR}/src/shunit2
