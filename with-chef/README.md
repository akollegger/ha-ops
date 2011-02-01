HA-Ops With Chef
================

Requirements
------------

Full Ruby development environment:
* ruby 1.8.7+
* rubygems 
* rvm (recommended, but optional)

Virtual Box:
* VirtualBox 4.0.2+

Gems:
* cucumber - for running integration tests
* vagrant - for launching VirtualBox instances
* chef - for provisioning the instances

Deploy with Vagrant
-------------------

With vagrant installed, you can run simulate an HA cluster by launching
VirtualBox VMs configured in the Vagrantfile.

Follow these steps:

1. Add a "box" to use for creating VM instances
  * `vagrant box add lucid32 http://files.vagrantup.com/lucid32.box`
2. Edit the `Vagrantfile` to change the VM instance counts
  * `zookeeper_instance_count` for number of Zookeeper VMs
  * `neo4j_instance_count` for number of Neo4j VMs
3. Launch the VMs
  * `vagrant up`
4. Check that Neo4j is runnning


Build & Test
------------

`rake features`

Build & Test With Maven
-----------------------

First time:
`mvn -Dcucumber.installGems=true integration-test`

Then:
`mvn integration-test`

References
----------

* [VirtualBox](http://www.virtualbox.org/)
* [rubygems](http://rubygems.org/)
* [rvm](http://rvm.beginrescueend.com/)
* [vagrant](http://vagrantup.com/)
* [chef](http://www.opscode.com/chef)
* [cuke4duke](https://github.com/aslakhellesoy/cuke4duke/wiki/maven)

