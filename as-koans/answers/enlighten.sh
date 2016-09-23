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
  NEO4J_DIR="${KOAN_WORKSPACE}/cluster"
  NEO4J_COUNT=3

  # create the koan.cfg file
  echo "# Neo4j HA-OPS Enlightened Koan Configuration" > ${KOAN_CONFIG}
  echo "NEO4J_VERSION=\"${NEO4J_VERSION}\"" >> ${KOAN_CONFIG}
  echo "KOAN_WORKSPACE=\"${KOAN_WORKSPACE}\"" >> ${KOAN_CONFIG}
  echo "NEO4J_DIR=\"${NEO4J_DIR}\"" >> ${KOAN_CONFIG}
  echo "NEO4J_COUNT=\"${NEO4J_COUNT}\"" >> ${KOAN_CONFIG}

  # prepare the workspace
  mkdir -p "${KOAN_WORKSPACE}"
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

# create and configure neo4j cluster
enlightenment_02() {
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    cp -rn "${KOAN_WORKSPACE}/neo4j-enterprise-${NEO4J_VERSION}/" "${NEO4J_DIR}/neo4j-${i}" 2>&1;
  done

  # modify neo4j.conf

  # strip existing settings from neo4j.conf
  find "${NEO4J_DIR}" -name neo4j.conf -print | \
    xargs sed \
    -e '/dbms\.connectors\.default_listen_address/d' \
    -e '/dbms\.connectors\.default_advertised_address/d' \
    -e '/dbms\.connector\.bolt\.listen_address/d' \
    -e '/dbms\.connector\.http\.listen_address/d' \
    -e '/dbms\.connector\.https\.listen_address/d' \
    -e '/core_edge\.expected_core_cluster_size/d' \
    -e '/core_edge\.initial_discovery_members/d' \
    -e '/core_edge\.discovery_listen_address/d' \
    -e '/core_edge\.transaction_listen_address/d' \
    -e '/core_edge\.raft_listen_address/d' \
    -e '/dbms\.mode/d' \
    "${dashi[@]}"

  # append a koan-configured section
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "\n\n#********************************************************************\n# Koan Configuration\n#********************************************************************" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # each member will participate in the core group
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.mode=CORE" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # expected member size is ${NEO4J_COUNT}
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "core_edge.expected_core_cluster_size=${NEO4J_COUNT}" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # enable default_listen_address, bound to any and all addresses
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.connectors.default_listen_address=0.0.0.0" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # set default_advertised_address to localhost
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.connectors.default_advertised_address=localhost" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # range of ports for bolt
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.connector.bolt.listen_address=:$((7686 + i))" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # range of ports for http
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.connector.http.listen_address=:$((7473 + i))" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # range of ports for https
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "dbms.connector.https.listen_address=:$((6473 + i))" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done

  # range of ports for core_edge discovery
  # core_edge.initial_discovery_members=localhost:5000,localhost:5001, localhost:5002

  # range of ports for core_edge communication
  discovery_members=()
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    discovery_port=$((4999 + i))
    discovery_members+=("localhost:${discovery_port}")
    echo "core_edge.discovery_listen_address=:${discovery_port}" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done
  discovery_members_string=$( IFS=$','; echo "${discovery_members[*]}" )
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    echo "core_edge.initial_discovery_members=${discovery_members_string}" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    transaction_listen_address=$((5999 + i))
    echo "core_edge.transaction_listen_address=:${transaction_listen_address}" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done
  for (( i=1; i<=${NEO4J_COUNT}; i++ )); do
    raft_listen_address=$((6999 + i))
    echo "core_edge.raft_listen_address=:${raft_listen_address}" >> "${NEO4J_DIR}/neo4j-${i}/conf/neo4j.conf"
  done
}

enlightenment_01 ${1:-"3.1.0-M09"}
enlightenment_02

echo ${KOAN_CONFIG}
