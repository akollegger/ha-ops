Feature: Manage a Neo4j HA Server cluster
In order to run a Neo4j-based application that scales and has high availability
An Ops
Should use standard unix utilities
To manage both a Zookeeper and Neo4j-HA cluster

  Background:
    Given a bash compatible shell
    And a working directory at relative path "./installation"
    And environment variable "ZOOKEEPER_VERSION" set to "3.3.2"
    And environment variable "ZOOKEEPER_HOME" set to "./zookeeper-3.3.2"
    And environment variable "ZOOKEEPER_INSTANCE_DIR" set to "./zoo-instances"
    And environment variable "ZOOKEEPER_INSTANCE_COUNT" set to "3"
    And environment variable "NEO4J_VERSION" set to "1.3.M01"
    And environment variable "NEO4J_HOME" set to "./neo4j-1.3.M01"
    And environment variable "NEO4J_INSTANCE_DIR" set to "./neo4j-instances"
    And environment variable "NEO4J_INSTANCE_COUNT" set to "3"

  @install-zookeeper
  Scenario: Install Zookeeper locally
    Given these command-line tools:
      | command | version_switch | expected_version |
      | curl    | --version      | curl 7           |
      | tar     | --version      | bsdtar 2.6.2     |
    When I run these shell commands:
      """
      if [[ ! -e zookeeper.tar.gz ]]; then curl http://www.apache.org/dist//hadoop/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz --output zookeeper.tar.gz; fi
      tar xzf zookeeper.tar.gz
      """
    Then "$ZOOKEEPER_HOME" should exist as a directory
    And "$ZOOKEEPER_HOME/zookeeper-${ZOOKEEPER_VERSION}.jar" should exist as a file

  @zookeeper-cluster
  Scenario: Create multiple local instances of Zookeeper to form a cluster
    Given a file named "zoo.cfg" with:
    """
    tickTime=2000
    initLimit=10
    syncLimit=5
 
    server.1=localhost:2888:3888
    server.2=localhost:2889:3889
    server.3=localhost:2890:3890

    """
    When I run these shell commands:
      """
      rm -rf $ZOOKEEPER_INSTANCE_DIR
      for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do mkdir -p $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/data 2>&1; done
      for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do cp zoo.cfg $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/ 2>&1; done
      for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do echo ${i} > $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/data/myid; done
      for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do echo dataDir=$ZOOKEEPER_INSTANCE_DIR/zoo-${i}/data/ >> $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/zoo.cfg; done
      for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do echo clientPort=218${i} >> $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/zoo.cfg; done
      """
    Then "zoo-instances/zoo-1/zoo.cfg" should contain "dataDir=./zoo-instances/zoo-1/data"
    And "zoo-instances/zoo-1/zoo.cfg" should contain "clientPort=2181"
    And "zoo-instances/zoo-2/zoo.cfg" should contain "dataDir=./zoo-instances/zoo-2/data"
    And "zoo-instances/zoo-2/zoo.cfg" should contain "clientPort=2182"
    And "zoo-instances/zoo-3/zoo.cfg" should contain "dataDir=./zoo-instances/zoo-3/data"
    And "zoo-instances/zoo-3/zoo.cfg" should contain "clientPort=2183"

  @install-neo4j
  Scenario: Install Neo4j locally
    Given these command-line tools:
      | command | version_switch | expected_version |
      | curl    | --version      | curl 7           |
      | tar     | --version      | bsdtar 2.6.2     |
    When I run these shell commands in "./":
      """
      if [[ ! -e neo4j.tar.gz ]]; then curl http://dist.neo4j.org/neo4j-${NEO4J_VERSION}-unix.tar.gz --output neo4j.tar.gz; fi
      tar xzf neo4j.tar.gz
      """
    Then "$NEO4J_HOME" should exist as a directory
    And "$NEO4J_HOME/bin/neo4j" should be an executable

  @neo4j-cluster
  Scenario: Create multiple local instances of Neo4j to form a cluster
    Given "$NEO4J_HOME" exists as a directory
    And environment variable "ZOOKEEPER_SERVERS" set to "localhost:2181,localhost:2182,localhost:2183"
    When I run these shell commands:
      """
      if [ ! "$(ls -A $NEO4J_HOME/data/graph.db)" ]; then ${NEO4J_HOME}/bin/neo4j start; sleep 10; ${NEO4J_HOME}/bin/neo4j stop ; fi
      rm -rf $NEO4J_INSTANCE_DIR
      mkdir $NEO4J_INSTANCE_DIR
      for (( i=1; i<=${NEO4J_INSTANCE_COUNT}; i++ )); do cp -r $NEO4J_HOME $NEO4J_INSTANCE_DIR/neo4j-${i} 2>&1; done
      for (( i=1; i<=${NEO4J_INSTANCE_COUNT}; i++ )); do echo org.neo4j.server.database.mode=ha >> $NEO4J_INSTANCE_DIR/neo4j-${i}/conf/neo4j-server.properties; done
      for (( i=1; i<=${NEO4J_INSTANCE_COUNT}; i++ )); do echo ha.machine_id = ${i} >> $NEO4J_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      for (( i=1; i<=${NEO4J_INSTANCE_COUNT}; i++ )); do echo ha.server = localhost:600${i} >> $NEO4J_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      for (( i=1; i<=${NEO4J_INSTANCE_COUNT}; i++ )); do echo ha.zookeeper_servers = ${ZOOKEEPER_SERVERS} >> $NEO4J_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      """
    Then "neo4j-instances/neo4j-1/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.machine_id = 1"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.server = localhost:6001"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.zookeeper_servers = localhost:2181,localhost:2182,localhost:2183"
    And "neo4j-instances/neo4j-2/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.machine_id = 2"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.server = localhost:6002"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.zookeeper_servers = localhost:2181,localhost:2182,localhost:2183"
    And "neo4j-instances/neo4j-3/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.machine_id = 3"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.server = localhost:6003"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.zookeeper_servers = localhost:2181,localhost:2182,localhost:2183"

  @start-zookeeper-cluster
  Scenario: Start a zookeeper cluster hosted locally 
    When I run these shell commands:
    """
    for (( i=1; i<=${ZOOKEEPER_INSTANCE_COUNT}; i++ )); do { java -cp $ZOOKEEPER_HOME/lib/log4j-1.2.15.jar:$ZOOKEEPER_HOME/zookeeper-${ZOOKEEPER_VERSION}.jar org.apache.zookeeper.server.quorum.QuorumPeerMain $ZOOKEEPER_INSTANCE_DIR/zoo-${i}/zoo.cfg } & ; done
    """

