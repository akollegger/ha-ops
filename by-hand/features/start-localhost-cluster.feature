Feature: Start a Neo4j HA Server cluster running on localhost
In order to run a Neo4j-based application that scales and has high availability
An Ops
Should use standard unix utilities
To start both a Neo4j-HA Data cluster and a Neo4j Coordinator cluster

  Background:
    Given a bash compatible shell
    And Java 1.7
    And a working directory at relative path "./installation"
    And these shell exports:
    """
    export NEO4J_COORDINATOR_INSTANCE_DIR=./coord-instances
    export NEO4J_COORDINATOR_INSTANCE_COUNT=3
    export NEO4J_DATA_INSTANCE_DIR=./neo4j-instances
    export NEO4J_DATA_INSTANCE_COUNT=3
    """

  @start-coordinator-cluster
  Scenario: Start a Neo4j Coordinator cluster in local processes
    When I run these shell commands and wait 2 seconds:
    """
    for (( i=1; i<=${NEO4J_COORDINATOR_INSTANCE_COUNT}; i++ )); do if [ ! -f $NEO4J_COORDINATOR_INSTANCE_DIR/data/neo4j-coordinator.pid ]; then pushd $NEO4J_COORDINATOR_INSTANCE_DIR/coord-${i}; ./bin/neo4j-coordinator start; popd; fi ; done
    """
    Then port 2181 on localhost should be open
    And port 2182 on localhost should be open
    And port 2183 on localhost should be open
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-1/data/neo4j-coord.pid" should exist as a file
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-2/data/neo4j-coord.pid" should exist as a file
    And "$NEO4J_COORDINATOR_INSTANCE_DIR/coord-3/data/neo4j-coord.pid" should exist as a file

  @start-data-cluster
  Scenario: Start a Neo4j HA data cluster in local processes
    Given Neo4j Coordinator at address localhost:2181
    Given Neo4j Coordinator at address localhost:2182
    Given Neo4j Coordinator at address localhost:2183
    When I run these shell commands:
    """
    for (( i=1; i<=${NEO4J_DATA_INSTANCE_COUNT}; i++ )); do if [ ! -f $NEO4J_DATA_INSTANCE_DIR/neo4j-$i/data/neo4j-server.pid ]; then pushd $NEO4J_DATA_INSTANCE_DIR/neo4j-${i}; ./bin/neo4j start; popd; fi ; done
    """
    Then port 7474 on localhost should be open
    And port 7475 on localhost should be open
    And port 7476 on localhost should be open

  @exercise-ha-cluster
  Scenario: Writing and reading data with a Neo4j HA cluster
    Given a Neo4j Data instance at address localhost:7474
    And a Neo4j Data instance at address localhost:7475
    And a Neo4j Data instance at address localhost:7476
    When I run these shell commands and wait 2 seconds:
    """
    # create a node, writing to the first instance
    curl -H Accept:application/json -X POST http://localhost:7474/db/data/node
    """
    Then these commands should succeed:
    """
    # read node 1, or fail if not found, from the other instances
    # ha.pull_interval was set to 1 second, the data should have propagated
    curl --fail -H Accept:application/json http://localhost:7475/db/data/node/1
    curl --fail -H Accept:application/json http://localhost:7476/db/data/node/1
    """

