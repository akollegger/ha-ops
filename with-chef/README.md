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

Vagrant 
-------

With vagrant installed, you can run the Vagrantfile like this:

1. Add a "box" to use for creating VM instances
  * `vagrant box add lucid32 http://files.vagrantup.com/lucid32.box`
2. Edit the `Vagrantfile` to match the install directory and instance counts
  * look for comments in the file
3. Launch the VMs
  * `vagrant up`

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

