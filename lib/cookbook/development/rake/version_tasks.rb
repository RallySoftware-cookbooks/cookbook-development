require 'version'
require 'rake/tasklib'

module CookbookDevelopment

  class VersionFile
    VERSION_FILE = File.join(Dir.pwd, 'VERSION')
    ALT_VERSION_FILE = File.join(Dir.pwd, 'recipes', 'VERSION')

    class << self
      def in_dir(dir = Dir.pwd)
        metadata_file = File.join(Dir.pwd, 'metadata.rb')

        if File.exist? VERSION_FILE
          VersionFile.new(VERSION_FILE)
        elsif File.exist? ALT_VERSION_FILE
          # The release process relies on having a VERSION file in the root of
          # your cookbook as well as the version attribute in metadata.rb reading
          # from said VERSION file. Until https://github.com/opscode/test-kitchen/pull/212
          # is resolved we need to put the cookbooks in a place that test-kitchen
          # will copy to the VM.
          VersionFile.new(ALT_VERSION_FILE)
        elsif File.exist? metadata_file
          MetadataVersion.new(metadata_file)
        else
          raise 'I could not find a VERSION file or a metadata.rb'
        end
      end
    end

    attr_reader :version
    attr_reader :path
    def initialize(path)
      @path = Pathname.new(path)
      @version = @path.read
    end

    def bump(level)
      @version.to_version.bump!(level).to_s
    end

    def bump!(level)
      @version = bump(level)
      save
      @version
    end

    def to_s
      @version
    end

    def save
      @path.open('w') do |io|
        io << self
      end
    end
  end

  class MetadataVersion < VersionFile
    def initialize(path)
      @path = Pathname.new(path)
      @metadata = @path.read
      @metadata =~ /version\s+'(\d+\.\d+\.\d+)'/
      @version = $1
    end

    def to_s
      @metadata.sub(/(^version\s+')(\d+\.\d+\.\d+)(')/, "\\1#{@version}\\3" )
    end
  end

  class VersionTasks < Rake::TaskLib
    def initialize
      @version_file = VersionFile.in_dir(Dir.pwd)
      yield(self) if block_given?
      define
    end

    def define
      namespace :version do
        namespace :bump do
          desc "Bump to #{@version_file.bump(:major)}"
          task :major do
            bump_version!(:major)
          end

          desc "Bump to #{@version_file.bump(:minor)}"
          task :minor do
            bump_version!(:minor)
          end

          desc "Bump to #{@version_file.bump(:revision)}"
          task :patch do
            bump_version!(:revision)
          end
        end
      end
    end

    private

    def bump_version!(level)
      new_version = @version_file.bump!(level)
      puts "Version bumped to #{new_version}"
      git_commit(new_version)
    end

    def system(*args)
      abort unless Kernel.system(*args)
    end

    def git_commit(version)
      puts "Committing #{@version_file.path}..."
      system("git add #{@version_file.path}")
      system("git commit -m 'Version bump to #{version}'")
    end
  end
end
