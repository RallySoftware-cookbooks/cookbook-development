require 'version'
require 'rake/tasklib'

module CookbookDevelopment
  class MetadataVersionTask < Rake::TaskLib
    attr_reader :path

    def initialize(path = File.join(Dir.pwd, 'metadata.rb'))
      @path = Pathname.new(path)

      yield(self) if block_given?

      define
    end

    def metadata
      @metadata ||= path.read
    end

    def define
      namespace :version do
        namespace :bump do
          desc "Bump to #{current_version.bump!(:major)}"
          task :major do
            bump_version(:major)
          end

          desc "Bump to #{current_version.bump!(:minor)}"
          task :minor do
            bump_version(:minor)
          end

          desc "Bump to #{current_version.bump!(:revision)}"
          task :patch do
            bump_version(:revision)
          end
        end
      end
    end

    private 

    def system(*args)
      abort unless Kernel.system(*args)
    end

    def current_version
      metadata =~ /version\s+'(\d+\.\d+\.\d+)'/
      $1.to_version
    end

    def bump_version(level)
      new_version = current_version.bump!(level)
      save(metadata.sub(/(^version\s+')(\d+\.\d+\.\d+)(')/, "\\1#{new_version}\\3" ))

      git_commit(new_version)
      git_tag(new_version)

      puts "Version bumped to #{new_version}"
      new_version
    end

    def save(metadata)
      path.open('w') do |io|
        io << metadata
      end
    end

    def git_commit(version)
      system("git add #{path}")
      system("git commit -m 'Version bump to #{version}'")
    end

    def git_tag(version)
      system("git tag #{version}")
    end
  end
end
