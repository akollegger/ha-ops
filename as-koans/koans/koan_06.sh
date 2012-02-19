#! /bin/sh
# file: koans/koan_06.sh

# unset vars are an error
set -u

BASE_DIR=${BASE_DIR:-"`dirname $0`/.."}
LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG=${KOAN_CONFIG:-"${BASE_DIR}/koan.cfg"}

echo "Koan 6 - Stop the HA Cluster"
echo "----------------------------"

testNeo4jCluster()
{
  checkNeo4jNotRunning 1 7474
  checkNeo4jNotRunning 2 7475
  checkNeo4jNotRunning 3 7476
}

checkNeo4jNotRunning()
{
  local neo4j_number=$1
  local neo4j_port=$2
  local port_check="`nmap -p ${neo4j_port} localhost -oG - | grep ${neo4j_port}/closed`"
  assertTrue "neo4j ${neo4j_number} does appear to be running (port ${neo4j_port} open)" \
    "[ -n '${port_check}' ]"  
  assertFalse "neo4j ${neo4j_number} pid file exists" \
    "[ -f ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid ]"
  if [ -f ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid ]; then
    local pid_check=`cat ${NEO4J_DIR}/neo4j-${neo4j_number}/data/neo4j-service.pid`
    assertNotNull "neo4j ${neo4j_number} does appear to be running (process with pid ${pid_check})" \
      "`kill -0 ${pid_check} 2> /dev/null`"
  fi

}

testCoordinatorCluster()
{
  checkZookeeperNotRunning 1 2181
  checkZookeeperNotRunning 2 2182
  checkZookeeperNotRunning 3 2183
}

checkZookeeperNotRunning()
{
  local coord_number=$1
  local coord_port=$2
  local port_check="`nmap -p ${coord_port} localhost -oG - | grep ${coord_port}/closed`"
  assertTrue "coordinator ${coord_number} does appear to be running (port ${coord_port} open)" \
    "[ -n '${port_check}' ]"  
  assertFalse "coordinator ${coord_number} pid file exists" \
    "[ -f ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid ]"
  if [ -f ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid ]; then
    local pid_check=`cat ${COORDINATOR_DIR}/coord-${coord_number}/data/neo4j-coord.pid`
    assertNotNull "coordinator ${coord_number} does not appear to be running (no running process with pid ${pid_check})" \
    "`kill -0 ${pid_check} 2> /dev/null`"
  fi

}


oneTimeSetUp()
{
  # load include to test
  . "${KOAN_CONFIG}"
}

# load shunit2
. ${BASE_DIR}/src/shunit2
