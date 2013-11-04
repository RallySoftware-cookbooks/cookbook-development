require 'rspec/core/rake_task'
require 'kitchen/rake_tasks'
require 'foodcritic'
require 'berkshelf'

module CookbookDevelopment
  class TestTasks < Rake::TaskLib
    attr_reader :project_dir
    attr_reader :chef_dir
    attr_reader :knife_cfg
    attr_reader :vendor_dir
    attr_reader :cookbooks_dir
    attr_reader :berks_file

    def initialize
      @project_dir   = Dir.pwd
      @chef_dir      = File.join(project_dir, 'test', '.chef')
      @knife_cfg     = File.join(chef_dir, 'knife.rb')
      @vendor_dir    = File.join(project_dir, 'vendor')
      @cookbooks_dir = File.join(vendor_dir, 'cookbooks')
      @berks_file    = File.join(project_dir, 'Berksfile')

      yield(self) if block_given?
      define
    end

    def define

      kitchen_config = Kitchen::Config.new
      kitchen_config.supervised = false
      Kitchen.logger = Kitchen.default_file_logger

      namespace "kitchen" do
        kitchen_config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task instance.name do
            instance.test(:passing)
          end
        end

        desc "Run all test instances"
        task "all" => kitchen_config.instances.map { |i| i.name }
      end

      desc 'Runs knife cookbook test'
      task :knife_test => [knife_cfg, :berks_install] do |task|
        cookbook_name = File.basename(project_dir)
        Dir.chdir(File.join(project_dir, '..')) do
          sh "bundle exec knife cookbook test #{cookbook_name} --config #{knife_cfg}"
        end
      end

      desc 'Runs Foodcritic linting'
      FoodCritic::Rake::LintTask.new do |task|
        task.options = {:search_gems => true, :fail_tags => ['any'], :tags => ['~FC003', '~FC015'], :exclude_paths => ['vendor/cookbooks/**/*']}
      end

      desc 'Runs unit tests'
      RSpec::Core::RakeTask.new(:unit) do |task|
        task.pattern = FileList[File.join(project_dir, 'test', 'unit', '**/*_spec.rb')]
      end
      task :unit => :berks_install

      desc 'Runs integration tests'
      task :integration do
        Rake::Task['kitchen:all'].invoke
      end

      desc 'Run all tests and linting'
      task :test do
        Rake::Task['knife_test'].invoke
        Rake::Task['foodcritic'].invoke
        Rake::Task['unit'].invoke
        Rake::Task['integration'].invoke
      end

      task :berks_install do |task|
        FileUtils.rm_rf vendor_dir
        Berkshelf::Berksfile.from_file(berks_file).install(:path => cookbooks_dir)
      end

      directory chef_dir

      file knife_cfg => chef_dir do |task|
        File.open(task.name, 'w+') do |file|
          file.write <<-EOF.gsub(/^\s+/, "")
          cache_type 'BasicFile'
          cache_options(:path => "\#{ENV['HOME']}/.chef/checksums")
          cookbook_path '#{cookbooks_dir}'
          EOF
        end
      end

    end
  end
end
