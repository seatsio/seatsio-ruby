require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

Rake::TestTask.new(:singletest) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/update_channels_test.rb", "test/**/assign_objects_to_channels_test.rb"]
  t.warning = false
end

task :default => :test
