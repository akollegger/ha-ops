# Steps for working with vagrant to simulate a cluster deployment

Before do
  @vagrant_file = "Vagrantfile"
end

After do
end

Given /^a Vagrantfile$/ do 
  raise "Vagrantfile is missing" if !FileTest.exists?(@vagrant_file)
end

Given /^a cluster with (\d+) management machines?$/ do |expected_zookeepers|
  specified_zookeepers = "n/a"
  File.open( @vagrant_file ) do |f|
    f.grep( /zookeeper_instance_count = \d+/ ) do |line|
      specified_zookeepers = (/= (\d+)$/.match line)[1]
    end
  end
   raise "Expected zookeepers (#{expected_zookeepers}) dont match count specified in Vagrantfile (#{specified_zookeepers})" if (specified_zookeepers != expected_zookeepers)
  @zookeeper_instance_count = specified_zookeepers.to_i
end

Given /^(\d+) neo4j server$/ do |expected_neo4j|
  specified_neo4j = "n/a"
  File.open( @vagrant_file ) do |f|
    f.grep( /neo4j_instance_count = \d+/ ) do |line|
      specified_neo4j = (/= (\d+)$/.match line)[1]
    end
  end
   raise "Expected neo4j servers (#{expected_neo4j}) dont match count specified in Vagrantfile (#{specified_neo4j})" if (specified_neo4j != expected_neo4j)
  @neo4j_instance_count = specified_neo4j.to_i
end

When /^I launch the simulation$/ do
  puts "launching vagrant"
end

Then /^I should have (\d+) Neo4j instances?$/ do |expected_neo4j|
  vagrant_status = `vagrant status`
  
  vagrant_status.each {|line| puts "foo #{line}" }
  #if !(vagrant_status.count {|line| /^neo4j.*running$/ =~ line } == expected_neo4j) then
  #if !(vagrant_status.count{|line| true } == expected_neo4j) then
  #  raise "not all neo4j instances are running. check 'vagrant status' for details"
  #end
end

Then /^(\d+) [Zz]ookeeper instances?$/ do |expected_zookeepers|
  pending
end

