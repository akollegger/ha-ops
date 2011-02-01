HA-Ops With Chef
================

Requirements
------------

Gems:
* cucumber - for running integration tests
* vagrant - for launching VirtualBox instances
* chef - for provisioning the instances

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

* [cuke4duke](https://github.com/aslakhellesoy/cuke4duke/wiki/maven)

