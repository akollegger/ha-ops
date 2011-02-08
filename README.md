Neo4j High-Availability Ops
===========================

HA-Ops provides tooling for managing a Neo4j installation, graduating from
a single server into a High Availability cluster.

Ha-Ops Three Ways
-----------------

Installing and managing a cluster of machines is a time-honored task. Usually,
an ops will start with doing everything by hand, then looking for tools to
improve the repetitive tasks, then maybe writing their own customized tool.

So, we'll do that...

1. by-hand - bash scripting for terminal madness
2. with-chef - provisioning with Chef Systems Integration recipes
3. with-hops - Neo4j aware tooling

Each approach is documented and driven by executable features descriptions,
written using Cucumber BDD. Read the READMEs, look for the `*.feature` files,
then try them out (which will require some Ruby tools). 

For more information, refer to the wiki.

Footnotes
---------

* [Cucumber BDD](http://cukes.info)
* [Chef Systems Integration](http://www.opscode.com/)

