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

* chef - for provisioning the instances
* vagrant - for launching VirtualBox instances
* cucumber - for running integration tests

Simulated Deployment with Vagrant
---------------------------------

With Vagrant installed, you can simulate an HA cluster by launching
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

Automated integration tests using Cucumber are under development.

`rake features`

References
----------

* [Chef Systems Integration](http://www.opscode.com/chef)
* [VirtualBox](http://www.virtualbox.org/)
* [rubygems](http://rubygems.org/)
* [rvm](http://rvm.beginrescueend.com/)
* [vagrant](http://vagrantup.com/)

