#! /bin/sh
# file: koans/koan_02.sh

# unset vars are an error
set -u

BASE_DIR=${BASE_DIR:-"`dirname $0`/.."}
LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG=${KOAN_CONFIG:-"${BASE_DIR}/koan.cfg"}


# load color definitions
. ${BASE_DIR}/src/colorize

  # load configuration to test
  . "${KOAN_CONFIG}"

oneTimeSetUp() {
  echo "Koan 2 - Create Coordinator Cluster"
  echo "${GREEN}-----------------------------------${RESET}"
}

testThereAreNoCoordinators() {
    assertTrue "Coordinators are not needed for core-edge, so shouldn't be set up" "false"
}

testThreeCoordinatorsExists()
{
  COORD_1_DIR="${COORDINATOR_DIR}/coord-1"
  COORD_2_DIR="${COORDINATOR_DIR}/coord-2"
  COORD_3_DIR="${COORDINATOR_DIR}/coord-3"

  assertTrue "coordinator 1 directory missing, expected at ${COORD_1_DIR}" "[ -d '${COORD_1_DIR}' ]"
  assertTrue "coordinator 2 directory missing, expected at ${COORD_2_DIR}" "[ -d '${COORD_2_DIR}' ]"
  assertTrue "coordinator 3 directory missing, expected at ${COORD_3_DIR}" "[ -d '${COORD_3_DIR}' ]"

  assertTrue "${COORD_1_DIR} is missing bin/neo4j-coordinator script" "[ -x '${COORD_1_DIR}/bin/neo4j-coordinator' ]"
  assertTrue "${COORD_2_DIR} is missing bin/neo4j-coordinator script" "[ -x '${COORD_2_DIR}/bin/neo4j-coordinator' ]"
  assertTrue "${COORD_3_DIR} is missing bin/neo4j-coordinator script" "[ -x '${COORD_3_DIR}/bin/neo4j-coordinator' ]"
}

testAllCoordinatorsConfiguredCorrectly()
{
  local coord_cfg_check=""

  coord_cfg_check="`find ${COORDINATOR_DIR} -name coord.cfg | xargs grep -L -e '^server.1=localhost:2888:3888'`"
  assertTrue "server.1 is not configured correctly in these files... \n${coord_cfg_check}" \
    "[ -z '${coord_cfg_check}' ]"
  coord_cfg_check="`find ${COORDINATOR_DIR} -name coord.cfg | xargs grep -L -e '^server.2=localhost:2889:3889'`"
  assertTrue "server.2 is not configured correctly in these files... \n${coord_cfg_check}" \
    "[ -z '${coord_cfg_check}' ]"
  coord_cfg_check="`find ${COORDINATOR_DIR} -name coord.cfg | xargs grep -L -e '^server.3=localhost:2890:3890'`"
  assertTrue "server.3 is not configured correctly in these files... \n${coord_cfg_check}" \
    "[ -z '${coord_cfg_check}' ]"

  coord_cfg_check="`grep -L -e '^clientPort=2181' ${COORDINATOR_DIR}/coord-1/conf/coord.cfg`"
  assertTrue "clientPort set incorrectly in ${coord_cfg_check}" "[ -z '${coord_cfg_check}' ]"
  coord_cfg_check="`grep -L -e '^clientPort=2182' ${COORDINATOR_DIR}/coord-2/conf/coord.cfg`"
  assertTrue "clientPort set incorrectly in ${coord_cfg_check}" "[ -z '${coord_cfg_check}' ]"
  coord_cfg_check="`grep -L -e '^clientPort=2183' ${COORDINATOR_DIR}/coord-3/conf/coord.cfg`"
  assertTrue "clientPort set incorrectly in ${coord_cfg_check}" "[ -z '${coord_cfg_check}' ]"

  assertEquals "coordinator 1 id is wrong" \
    "1" "`cat ${COORDINATOR_DIR}/coord-1/data/coordinator/myid`"

  assertEquals "coordinator 2 id is wrong" \
    "2" "`cat ${COORDINATOR_DIR}/coord-2/data/coordinator/myid`"

  assertEquals "coordinator 3 id is wrong" \
    "3" "`cat ${COORDINATOR_DIR}/coord-3/data/coordinator/myid`"
}

oneTimeTearDown()
{
  echo "${RESET}"
  echo "${YELLOW}-------------------------------------------------${RESET}"
  echo "When resolved, proceed with 'sh koans/koan_02.sh'"
}

# load shunit2
. ${BASE_DIR}/src/shunit2
