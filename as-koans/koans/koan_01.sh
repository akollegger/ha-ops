#! /bin/sh
# file: koans/koan_01.sh

# unset vars are an error
#set -u

BASE_DIR=${BASE_DIR:-"`dirname $0`/.."}
LIB_DIR="${BASE_DIR}/lib"
KOAN_CONFIG=${KOAN_CONFIG:-"${BASE_DIR}/koan.cfg"}


# load color definitions
. ${BASE_DIR}/src/colorize

oneTimeSetUp() {
  echo "Koan 1 - Preparations"
  echo "${GREEN}---------------------${RESET}"
}

testKoanConfigExists()
{
  assertFalse "[ -z '${KOAN_CONFIG}' ]"
  assertTrue "koan config file missing, expected ${KOAN_CONFIG}" "[ -f '${KOAN_CONFIG}' ]"
}

testKoanConfigSettings()
{
  . ${KOAN_CONFIG}
  assertFalse "KOAN_WORKSPACE must be set to a working directory" "[ -z '${KOAN_WORKSPACE}' ]"
  assertTrue "koan working directory missing, expected at ${KOAN_WORKSPACE}" "[ -d '${KOAN_WORKSPACE}' ]"

  assertFalse "NEO4J_VERSION must be set [3.1-M0?]" "[ -z '${NEO4J_VERSION}' ]"

  assertFalse "NEO4J_DIR must be set" "[ -z '${NEO4J_DIR}' ]"
  assertTrue "neo4j instances directory missing, expected at ${NEO4J_DIR}" "[ -d '${NEO4J_DIR}' ]"
}

testNeo4jVersionIsAvailable()
{
  NEO4J_ARCHIVE="neo4j-enterprise-${NEO4J_VERSION}-unix.tar.gz"
  assertEquals "Neo4j ${NEO4J_VERSION} does not appear to be available (check network?)" \
    "200" "`curl -sL -w '%{http_code}' --fail -X HEAD http://dist.neo4j.org/${NEO4J_ARCHIVE}`"
}

testNeo4jHasBeenDownloaded()
{
  assertTrue "Neo4j ${NEO4J_VERSION} must be downloaded to '${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}'" \
    "[ -f '${KOAN_WORKSPACE}/${NEO4J_ARCHIVE}' ]"
}

oneTimeTearDown()
{
  echo "${RESET}"
  echo "${YELLOW}-------------------------------------------------${RESET}"
  echo "When resolved, proceed with 'sh koans/koan_02.sh'"
}

# load shunit2
. ${BASE_DIR}/src/shunit2
