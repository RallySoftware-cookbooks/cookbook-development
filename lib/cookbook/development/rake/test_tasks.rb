require 'rspec/core/rake_task'
require 'kitchen/rake_tasks'
require 'foodcritic'
require 'berkshelf'

module CookbookDevelopment
  class TestTasks < Rake::TaskLib
    attr_reader :project_dir

    def initialize
      @project_dir   = Dir.pwd
      yield(self) if block_given?
      define
    end

    def define
      kitchen_config = Kitchen::Config.new
      Kitchen.logger = Kitchen.default_file_logger

      namespace "kitchen" do
        kitchen_config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task instance.name do
            destroy = (ENV['KITCHEN_DESTROY'] || 'passing').to_sym
            instance.test(destroy)
          end
        end

        desc "Run all test instances"
        task :all do
          destroy = ENV['KITCHEN_DESTROY'] || 'passing'
          concurrency = ENV['KITCHEN_CONCURRENCY'] || '1'
          require 'kitchen/cli'
          Kitchen::CLI.new([], {concurrency: concurrency.to_i, destroy: destroy}).test()
        end
      end

      desc 'Runs Foodcritic linting'
      FoodCritic::Rake::LintTask.new do |task|
        task.options = {
          :search_gems => true,
          :fail_tags => ['any'],
          :tags => ['~FC003', '~FC015', '~FC059', '~FC064', '~FC065', '~FC066', '~FC067'],
          :exclude_paths => ['vendor/**/*']
        }
      end

      desc 'Runs unit tests'
      RSpec::Core::RakeTask.new(:unit) do |task|
        task.pattern = FileList[File.join(project_dir, 'test', 'unit', '**/*_spec.rb')]
      end

      desc 'Runs integration tests'
      task :integration do
        Rake::Task['kitchen:all'].invoke
      end

      desc 'Run all tests and linting'
      task :test do
        Rake::Task['foodcritic'].invoke
        Rake::Task['unit'].invoke
        Rake::Task['integration'].invoke
      end

      task :unit_test_header do
        puts "-----> Running unit tests with chefspec".cyan
      end
      task :unit => :unit_test_header

      task :foodcritic_header do
        puts "-----> Linting with foodcritic".cyan
      end
      task :foodcritic => :foodcritic_header

      task :integration_header do
        puts "-----> Running integration tests with test-kitchen".cyan
      end
      task :integration => :integration_header
    end
  end
end