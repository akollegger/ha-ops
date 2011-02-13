Feature: Manage a Neo4j HA Server cluster running on localhost
In order to run a Neo4j-based application that scales and has high availability
An Ops
Should use standard unix utilities
To manage both a Neo4j-HA Data cluster and a Neo4j Coordinator cluster

  Background:
    Given a bash compatible shell
    And Java 1.6
    And a working directory at relative path "./installation"
    And environment variable "NEO4J_VERSION" set to "1.3.M02"
    And environment variable "NEO4J_HOME" set to "./neo4j-1.3.M02"
    And environment variable "NEO4J_COORDINATOR_INSTANCE_DIR" set to "./coord-instances"
    And environment variable "NEO4J_COORDINATOR_INSTANCE_COUNT" set to "3"
    And environment variable "NEO4J_COORDINATOR_SERVERS" set to "localhost:2181,localhost:2182,localhost:2183"
    And environment variable "NEO4J_DATA_INSTANCE_DIR" set to "./neo4j-instances"
    And environment variable "NEO4J_DATA_INSTANCE_COUNT" set to "3"

  @install-neo4j
  Scenario: Install Neo4j locally
    Given these command-line tools:
      | command | version_switch | expected_version |
      | curl    | --version      | curl 7           |
      | tar     | --version      | tar              |
    When I run these shell commands in "./":
      """
      # download Neo4j if we haven't already
      if [[ ! -e neo4j.tar.gz ]]; then curl http://dist.neo4j.org/neo4j-${NEO4J_VERSION}-unix.tar.gz --output neo4j.tar.gz; fi
      tar xzf neo4j.tar.gz
      """
    Then "$NEO4J_HOME" should exist as a directory
    And "$NEO4J_HOME/bin/neo4j" should be an executable

  @create-coordinator-cluster
  Scenario: Create multiple local instances of Neo4j Coordinators to form a cluster
    Given a file named "coord.cfg" with:
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
      # clean the coordinator instance directory
      rm -rf $NEO4J_COORDINATOR_INSTANCE_DIR
      # make a directory for each coordinator instance (with a data subdirectory)
      for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do mkdir -p $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/data 2>&1; done
      # copy the base configuration into each coordinator directory
      for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do cp coord.cfg $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/ 2>&1; done
      # set the identity of each coordinator instance
      for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do echo ${i} > $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/data/myid; done
      # specify the configuration file to use for each coordinator instance
      for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do echo dataDir=$NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/data/ >> $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/coord.cfg; done
      # assign an incrementing client port (starting from 2181) for each coordinator instance
      for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do echo clientPort=218${i} >> $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/coord.cfg; done
      """
    Then "coord-instances/coord-1/coord.cfg" should contain "dataDir=./coord-instances/coord-1/data"
    And "coord-instances/coord-1/coord.cfg" should contain "clientPort=2181"
    And "coord-instances/coord-2/coord.cfg" should contain "dataDir=./coord-instances/coord-2/data"
    And "coord-instances/coord-2/coord.cfg" should contain "clientPort=2182"
    And "coord-instances/coord-3/coord.cfg" should contain "dataDir=./coord-instances/coord-3/data"
    And "coord-instances/coord-3/coord.cfg" should contain "clientPort=2183"

  @create-neo4j-cluster
  Scenario: Create multiple local instances of Neo4j to form a data cluster
    Given "$NEO4J_HOME" exists as a directory
    And environment variable "HA_CLUSTER_NAME" set to "hand-built"
    When I run these shell commands:
      """
      # each member of the data cluster needs a copy of the initial data store.
      # run the base install of Neo4j to create a graph database
      if [ ! "$(ls -A $NEO4J_HOME/data/graph.db)" ]; then ${NEO4J_HOME}/bin/neo4j start; sleep 10; ${NEO4J_HOME}/bin/neo4j stop ; fi
      # clear the Neo4j data instance directory
      rm -rf $NEO4J_DATA_INSTANCE_DIR
      mkdir $NEO4J_DATA_INSTANCE_DIR
      # make a complete copy of the base Neo4j install (including the graph data)
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do cp -r $NEO4J_HOME $NEO4J_DATA_INSTANCE_DIR/neo4j-${i} 2>&1; done
      # assign a port to each instance (starting from 7474)
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do sed "s/7474/747$(($i+3))/g" $NEO4J_HOME/conf/neo4j-server.properties > neo4j-instances/neo4j-$i/conf/neo4j-server.properties; done
      # enable High-Availability mode
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do echo org.neo4j.server.database.mode=ha >> $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}/conf/neo4j-server.properties; done
      # set a unique machine id for each instance in the data cluster
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do echo ha.machine_id = ${i} >> $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      # assign ports for intra-cluster communication (starting from 6001)
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do echo ha.server = localhost:600${i} >> $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      # list the address and port of each member of the coordinator cluster
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do echo ha.zoo_keeper_servers = ${NEO4J_COORDINATOR_SERVERS} >> $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      # assign a common name for the cluster
      for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do echo ha.cluster_name = $HA_CLUSTER_NAME >> $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}/conf/neo4j.properties; done
      """
    Then "neo4j-instances/neo4j-1/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.machine_id = 1"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.server = localhost:6001"
    And "neo4j-instances/neo4j-1/conf/neo4j.properties" should contain "ha.zoo_keeper_servers = localhost:2181,localhost:2182,localhost:2183"
    And "neo4j-instances/neo4j-2/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.machine_id = 2"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.server = localhost:6002"
    And "neo4j-instances/neo4j-2/conf/neo4j.properties" should contain "ha.zoo_keeper_servers = localhost:2181,localhost:2182,localhost:2183"
    And "neo4j-instances/neo4j-3/conf/neo4j-server.properties" should contain "org.neo4j.server.database.mode=ha"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.machine_id = 3"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.server = localhost:6003"
    And "neo4j-instances/neo4j-3/conf/neo4j.properties" should contain "ha.zoo_keeper_servers = localhost:2181,localhost:2182,localhost:2183"

  @start-coordinator-cluster
  Scenario: Start a Neo4j Coordinator cluster in local processes
    When I fork this shell command and wait 5 seconds:
    """
    for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do if [ ! -f $NEO4J_COORDINATOR_INSTANCE_DIR/coord-$i/coord.pid ]; then ((java -cp "$NEO4J_HOME/lib/*" org.apache.zookeeper.server.quorum.QuorumPeerMain $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/coord.cfg) & echo $! > $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}/coord.pid &); fi ; done
    """
    Then port 2181 on localhost should be open
    And port 2182 on localhost should be open
    And port 2183 on localhost should be open
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-1/coord.pid" should exist as a file
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-2/coord.pid" should exist as a file
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-3/coord.pid" should exist as a file

  @start-data-cluster
  Scenario: Start a Neo4j HA data cluster in local processes
    Given Neo4j Coordinator cluster is running
    When I run these shell commands:
    """
    for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do if [ ! -f $NEO4J_DATA_INSTANCE_DIR/neo4j-$i/data/neo4j-server.pid ]; then $NEO4J_DATA_INSTANCE_DIR/neo4j-$i/bin/neo4j start; fi ; done
    """
    Then port 7474 on localhost should be open
    And port 7475 on localhost should be open
    And port 7476 on localhost should be open

  @exercise-ha-cluster
  Scenario: Writing and reading data with a Neo4j HA cluster
    Given a Neo4j Data instance at address localhost:7474
    And a Neo4j Data instance at address localhost:7475
    And a Neo4j Data instance at address localhost:7476
    When I run these shell commands:
    """
    # create a node
    curl -H Accept:application/json -X POST http://localhost:7474/db/data/node
    """
    Then these commands should succeed:
    """
    # read node 1, or fail if not found
    curl --fail -H Accept:application/json http://localhost:7474/db/data/node/1
    """

  @stop-neo4j-cluster
  Scenario: Stop local Neo4j processes
    When I run these shell commands:
    """
    for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do $NEO4J_DATA_INSTANCE_DIR/neo4j-$i/bin/neo4j stop ; done
    """
    Then port 7474 on localhost should be closed
    And port 7475 on localhost should be closed
    And port 7476 on localhost should be closed

  @stop-coordinator-cluster
  Scenario: Stop local Neo4j Coordinator processes
    When I fork this shell command and wait 5 seconds:
    """
    for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do if [ -f $NEO4J_COORDINATOR_INSTANCE_DIR/coord-$i/coord.pid ]; then (cat $NEO4J_COORDINATOR_INSTANCE_DIR/coord-$i/coord.pid | xargs kill -9 ); rm $NEO4J_COORDINATOR_INSTANCE_DIR/coord-$i/coord.pid; fi ; done
    """
    Then port 2181 on localhost should be closed
    And port 2182 on localhost should be closed
    And port 2183 on localhost should be closed
    And "$COORDINATOR_INSTANCE_DIR/zoo-1/zoo.pid" should not exist as a file
    And "$COORDINATOR_INSTANCE_DIR/zoo-2/zoo.pid" should not exist as a file
    And "$COORDINATOR_INSTANCE_DIR/zoo-3/zoo.pid" should not exist as a file

