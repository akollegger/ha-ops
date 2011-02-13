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

Reading through the [manage-ha-cluster.feature](features/manage-ha-cluster.feature)


References
----------

* [HA-Ops By Hand](https://github.com/akollegger/ha-ops/wiki/By-hand)

* [Cucumber BDD](http://cukes.info)

