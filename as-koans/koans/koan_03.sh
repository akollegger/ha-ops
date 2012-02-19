#! /bin/sh
# file: koans/koan_03.sh

# unset vars are an error
set -u

BASE_DIR=${BASE_DIR:-"`dirname $0`/.."}
LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG=${KOAN_CONFIG:-"${BASE_DIR}/koan.cfg"}

echo "Koan 3 - Create Neo4j Cluster"
echo "-----------------------------"

testThreeNeo4jServersExist()
{
  NEO4J_1_DIR="${NEO4J_DIR}/neo4j-1"
  NEO4J_2_DIR="${NEO4J_DIR}/neo4j-2"
  NEO4J_3_DIR="${NEO4J_DIR}/neo4j-3"

  assertTrue "neo4j 1 directory missing, expected at ${NEO4J_1_DIR}" "[ -d '${NEO4J_1_DIR}' ]"
  assertTrue "neo4j 2 directory missing, expected at ${NEO4J_2_DIR}" "[ -d '${NEO4J_2_DIR}' ]"
  assertTrue "neo4j 3 directory missing, expected at ${NEO4J_3_DIR}" "[ -d '${NEO4J_3_DIR}' ]"

  assertTrue "${NEO4J_1_DIR} is missing bin/neo4j script" "[ -x '${NEO4J_1_DIR}/bin/neo4j' ]"
  assertTrue "${NEO4J_2_DIR} is missing bin/neo4j script" "[ -x '${NEO4J_2_DIR}/bin/neo4j' ]"
  assertTrue "${NEO4J_3_DIR} is missing bin/neo4j script" "[ -x '${NEO4J_3_DIR}/bin/neo4j' ]"
}

testNeo4jClusterConfiguredCorrectly()
{
  local neo4j_cfg_check=""
  
  # check ha mode
  neo4j_cfg_check="`find ${NEO4J_DIR} -name neo4j-server.properties | xargs grep -L -e '^org\.neo4j\.server\.database\.mode=ha'`"
  assertTrue "org.neo4j.server.database.mode is not configured correctly in these files... \n${neo4j_cfg_check}" \
    "[ -z '${neo4j_cfg_check}' ]"  

  # check webserver ports
  neo4j_cfg_check="`find ${NEO4J_1_DIR} -name neo4j-server.properties | xargs grep -L -e '^org\.neo4j\.server\.webserver\.port=7474'`"
  assertTrue "org.neo4j.server.webserver.port is not configured correctly for neo4j-1." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_2_DIR} -name neo4j-server.properties | xargs grep -L -e '^org\.neo4j\.server\.webserver\.port=7475'`"
  assertTrue "org.neo4j.server.webserver.port is not configured correctly for neo4j-2." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_3_DIR} -name neo4j-server.properties | xargs grep -L -e '^org\.neo4j\.server\.webserver\.port=7476'`"
  assertTrue "org.neo4j.server.webserver.port is not configured correctly for neo4j-3." \
    "[ -z '${neo4j_cfg_check}' ]"  

  # check ha.machine_id
  neo4j_cfg_check="`find ${NEO4J_1_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.machine_id = 1'`"
  assertTrue "ha.machine_id is not configured correctly for neo4j-1." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_2_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.machine_id = 2'`"
  assertTrue "ha.machine_id is not configured correctly for neo4j-2." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_3_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.machine_id = 3'`"
  assertTrue "ha.machine_id is not configured correctly for neo4j-3." \
    "[ -z '${neo4j_cfg_check}' ]"  

  # check for unique ha.server ports
  neo4j_cfg_check="`find ${NEO4J_1_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.server = localhost:6001'`"
  assertTrue "ha.server is not configured correctly for neo4j-1." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_2_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.server = localhost:6002'`"
  assertTrue "ha.server is not configured correctly for neo4j-2." \
    "[ -z '${neo4j_cfg_check}' ]"  

  neo4j_cfg_check="`find ${NEO4J_3_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.server = localhost:6003'`"
  assertTrue "ha.server is not configured correctly for neo4j-3." \
    "[ -z '${neo4j_cfg_check}' ]"  

  # check for zookeeper list
  neo4j_cfg_check="`find ${NEO4J_DIR} -name neo4j.properties | xargs grep -L -e '^ha\.zoo_keeper_servers = localhost:2181,localhost:2182,localhost:2183'`"
  assertTrue "ha.zookeeper_servers not configured correctly in these files... \n${neo4j_cfg_check}" \
    "[ -z '${neo4j_cfg_check}' ]"  
}

oneTimeSetUp()
{
  # load include to test
  . "${KOAN_CONFIG}"
}

# load shunit2
. ${BASE_DIR}/src/shunit2
