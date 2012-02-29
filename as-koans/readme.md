Neo4j Ops Koans
===============

Deploying Neo4j into a production any production environment requries a
common set of configuration operations. These koans lead through the steps
of configuring and deploying a local HA cluster of Neo4j.

Environment
-----------

These koans are GNU bash based scripts, assuming:

* GNU bash 3.2-ish
* /bin/sh

Koans
-----

The koans should be approached in order, repeating this sequence:

* run the koan `sh koans/koan_01.sh`
* observe the failures of the koans
* write a bash script to fulfill the expectations

Enlightenment
-------------

For the impatient student, answers are provided as a reference. 

Satisfy koan workspace installation:

    export KOAN_CONFIG=`sh answers/enlighten.sh`

Control the enlightened cluster:

  sh answers/cluster [start|stop|restart]


