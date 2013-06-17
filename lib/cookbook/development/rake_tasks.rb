require 'foodcritic'
require 'berkshelf'

desc "All tests using Strainer and Test Kitchen"
task :test do
  Rake::Task['strainer'].invoke
  Rake::Task['kitchen'].invoke
end

desc "Test cookbook using strainer"
task :strainer => :berks_install do
  puts "--> Running Strainer..."
  sh "bundle exec strainer test"
end

desc "Run integration tests using Test Kitchen"
task :kitchen do
  if File.exists?(File.join(Dir.pwd, '.kitchen.yml'))
    begin
      require 'kitchen/rake_tasks'
      Kitchen::RakeTasks.new

      puts "--> Running Test Kitchen..."
      Rake::Task["kitchen:all"].invoke
    rescue LoadError
      puts "Kitchen yml file found but unable to load test-kitchen"
    end
  end
end

task :berks_install do
  Berkshelf::Berksfile.from_file(File.join(Dir.pwd, 'Berksfile')).install
end

