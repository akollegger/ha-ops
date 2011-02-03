# Steps for working with vagrant to simulate a cluster deployment

Before do
  @vagrant_file = "Vagrantfile"
end

After do
end

Given /^a Vagrantfile specifying$/ do 
  raise "Vagrantfile is missing" if !FileTest.exists?(@vagrant_file)
end

Given /^a cluster with (\d+) management machines?$/ do |expected_zookeepers|
  specified_zookeepers = "n/a"
  File.open( @vagrant_file ) do |f|
    f.grep( /zookeeper_instance_count = \d+/ ) do |line|
      specified_zookeepers = (/= (\d+)$/.match line)[1]
    end
  end
  specified_zookeepers.should eq(expected_zookeepers),
    "Expected zookeepers (#{expected_zookeepers}) dont match count specified in Vagrantfile (#{specified_zookeepers})"
  @zookeeper_instance_count = specified_zookeepers.to_i
end

Given /^(\d+) neo4j server$/ do |expected_neo4j|
  specified_neo4j = "n/a"
  File.open( @vagrant_file ) do |f|
    f.grep( /neo4j_instance_count = \d+/ ) do |line|
      specified_neo4j = (/= (\d+)$/.match line)[1]
    end
  end
  specified_neo4j.should eq(expected_neo4j),
     "Expected neo4j servers (#{expected_neo4j}) dont match count specified in Vagrantfile (#{specified_neo4j})"
  @neo4j_instance_count = specified_neo4j.to_i
end

When /^I launch the simulation$/ do
  puts "launching vagrant (a lie)"
  @vagrant_status = `vagrant status`
end

Then /^I should have (\d+) Neo4j instances?$/ do |expected_neo4j|
  running_instances_of("neo4j_").should == expected_neo4j.to_i
end

Then /^(\d+) [Zz]ookeeper instances?$/ do |expected_zookeepers|
  running_instances_of("zoo_").should == expected_zookeepers.to_i
end

def running_instances_of(type_prefix)
  return @vagrant_status.lines.count {|line| /#{type_prefix}\d+\s+running/ =~ line }
end

