Feature: Easily install a Neo4j HA Server cluster
In order to run a client-server application that scales and has high availability
An Ops
Should use chef recipes
To provision zookeeper and Neo4j-HA instances

  Scenario: Prepare a simulated cluster
      Given a Vagrantfile
        And a cluster with 1 management machine
        And 1 neo4j server
       When I launch the simulation
       Then I should have 1 Neo4j instance
        And 1 zookeeper instance

