require 'version'
require 'rake/tasklib'

module CookbookDevelopment

  class VersionFile
    VERSION_FILE = File.join(Dir.pwd, 'VERSION')

    attr_reader :path

    def initialize(path = VERSION_FILE)
      @path = Pathname.new(path)

    end

    def exist?
      @path.exist?
    end

    def version
      @version ||= exist? ? @path.read : nil
    end

    def bump(level)
      version.to_version.bump!(level).to_s
    end

    def bump!(level)
      version = bump(level)
      save
      version
    end

    def to_s
      version
    end

    def save
      @path.open('w') do |io|
        io << self
      end
    end
  end

  class VersionTasks < Rake::TaskLib
    def initialize
      @version_file = VersionFile.new
      yield(self) if block_given?
      define
    end

    def define
      if @version_file.exist?
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
