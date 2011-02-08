Given /^a bash compatible shell$/ do
  bash_compatible.should be_true
end

Given /^a working directory at relative path "([^"]*)"$/ do |dir_path|
  popd
  mkdir (dir_path)
  pushd(dir_path)
end


Given /^these command\-line tools:$/ do |table|
  table.hashes.each do |hash|  
    bash("#{hash[:command]} #{hash[:version_switch]}")
    last_stdout.any?{|line| /#{hash[:version]}/ =~ line}.should be_true,
      "#{hash[:command]} version #{hash[:expected_version]} not found"
  end  
end

Given /^environment variable "([^"]*)" set to "([^"]*)"$/ do |env_var, env_value|
  setenv(env_var, env_value)
  getenv(env_var).should match(/#{env_value}/)
end

When /^I run these shell commands:$/ do |script|
  script.each {|line|
    bash(line, :verbose => true)
  }
end


When /^I run these shell commands in "([^"]*)":$/ do |working_dir, script|
  Dir.chdir(working_dir) do
    script.each {|line|
      bash(line, :verbose => true)
    }
  end
end

Then /^"([^"]*)" should be an executable$/ do |expected_executable|
  test_executable(expected_executable).should be_true,
    "neo4j executable not found, or not executable"
end

Then /^"([^"]*)" should exist as a directory$/ do |expected_directory|
  test_directory(expected_directory).should be_true,
    "missing directory #{expected_directory}"
end

Then /^"([^"]*)" should exist as a file$/ do |expected_file|
  test_file(expected_file).should be_true
end

Given /^"([^"]*)" exists as a directory$/ do |expected_directory|
  test_directory(expected_directory).should be_true,
    "missing directory #{expected_directory}"
end

Given /^a file named "([^"]*)" with:$/ do |filename, content|
  create_file(filename, content)
end

Then /^"([^"]*)" should contain "([^"]*)"$/ do |filename, pattern|
  file_contains(filename, Regexp.escape(pattern)).should be_true
end




