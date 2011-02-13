HA-Ops By Hand
==============

Installing and managing a Neo4j High-Availability cluster by hand involves 
running a lot of shell commands to get everything configured properly.

The feature descriptions in the `features` subdirectory describe a sequence 
of scenerios for installing, configuring, then running a Neo4j cluster 
using just bash scripts.

Each scenario includes an inline bash script that performs one part of the
process - install, create (instances), start, stop. The scripts are executed
and the results verified when you "run" the feature.

The scenerios explain pre-conditions, run a script, then check for expected 
results.

Running with Cucumber
---------------------

The scenerios can be run using a rake task, or the `cucumber` command that
was installed with the Cucumber Gem. 

* `rake features` - run all scenarios in all features
* `cucumber --dry-run` - to read each scenario without running anything
* `cucumber --tags=@install-neo4j` - to install neo4j into the work directory
* `cucumber --tags=@<name-of-scenario>` - to run any tagged scenario 

Running Literally by Hand
-------------------------

Reading through the [manage-localhost-cluster.feature](by-hand/features/manage-localhost-cluster.feature)
you can see exactly what tools are required and what has to be configured
to set up a cluster on a local machine. 

You'll find a `defaults.cfg` file in this directory that sets up the environment
variables in the same way. You can source that, then copy-and-paste each line of
shell commands to install, configure and manage the localhost cluster.

To work with a group of actual machines (to which you have ssh access), the 
addresses would change from `localhost` to the actual machine addresses. Then, 
each `for` means "do this to each machine" for the appropriate cluster type.

Using the GraphDB Cluster
-------------------------

By default, the script will start three Neo4j GraphDB instances. To use them, you 
can manually run each of the steps up to starting the cluster:

1. `cucumber --tags=@install-neo4j,@create-coordinator-cluster,@create-neo4j-cluster`
2. `cucumber --tags=@start-coordinator-cluster,@start-neo4j-cluster`

Then you'll have Neo4j GraphDBs available at:

* (http://localhost:7474)
* (http://localhost:7475)
* (http://localhost:7476)

To stop the cluster, first stop the GraphDBs, then the Coordinators:

1. `cucumber --tags=@stop-neo4j-cluster,@stop-coordinator-cluster`

References
----------

* [HA-Ops By Hand](https://github.com/akollegger/ha-ops/wiki/By-hand)

* [Cucumber BDD](http://cukes.info)

