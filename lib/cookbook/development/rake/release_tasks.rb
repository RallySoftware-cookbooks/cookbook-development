# Ideas and code for releasing a cookbook heavily borrowed from bundler https://github.com/bundler/bundler
module CookbookDevelopment
  class ReleaseTasks < Rake::TaskLib
    attr_reader :project_dir
    attr_reader :chef_dir
    attr_reader :knife_cfg
    attr_reader :vendor_dir
    attr_reader :cookbooks_dir
    attr_reader :berks_file

    TROUBLESHOOTING_MSG = "Refer to https://github.com/RallySoftware-cookbooks/chef-tutorials/blob/master/troubleshooting/ci.md to resolve this issue."

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
      desc 'Does a berks upload --except :test'
      task :upload do |task|
        Berkshelf::Berksfile.from_file(berks_file).upload(:path => cookbooks_dir, :except => :test)
      end

      desc 'Runs the full test suite and then does a berks upload from CI'
      task :ci do
        release_cookbook
      end
    end

    def tag?
      ENV['GIT_TAG'] != 'false'
    end

    def tag_and_upload
      if tag?
        release_version = version
        release_tag = version_tag(release_version)

        raise "Tag #{release_tag} has already been created.\n\nThis may be caused by a failed build. #{TROUBLESHOOTING_MSG}\n\n" if already_tagged?(release_tag)

        tag_version(release_version, release_tag) do
          berks_upload
        end
      else
        berks_upload
      end
    end

    def bump_patch?
      ENV['BUMP_PATCH'] != 'false'
    end

    def bump_and_push
      raise 'You have uncommitted changes.' unless clean? && committed?

      Rake::Task['version:bump:patch'].invoke
      git_pull
      git_push
    end

    def release_cookbook
      start_time = Time.now

      Rake::Task[:test].invoke unless ENV['test'] == 'false'

      tag_and_upload
      bump_and_push if bump_patch?

      elapsed = Time.now - start_time
      puts elapsed
    end

    def berks_upload
      puts 'Running berks upload...'
      Rake::Task[:upload].invoke
    end

    def git_pull(cmd = 'git pull --rebase')
      cmd = 'git pull --rebase'
      out, code = sh_with_code(cmd)
      raise "Couldn't git pull. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
    end

    def git_push
      puts 'Pushing git changes...'
      perform_git_push 'origin --tags :'
      puts 'Pushed git commits and tags.'
    end

    def perform_git_push(options = 'origin master')
      cmd = "git push #{options}"
      out, code = sh_with_code(cmd)
      raise "Couldn't git push. `#{cmd}' failed with the following output:\n\n#{out}\n\nThis could be a result of unmerged commits on master. #{TROUBLESHOOTING_MSG}\n\n" unless code == 0
    end

    def clean?
      sh_with_code('git diff --exit-code')[1] == 0
    end

    def committed?
      sh_with_code('git diff-index --quiet --cached HEAD')[1] == 0
    end

    def sh(cmd, &block)
      out, code = sh_with_code(cmd, &block)
      code == 0 ? out : raise(out.empty? ? "Running `#{cmd}' failed. Run this command directly for more detailed output." : out)
    end

    def already_tagged?(tag)
      sh('git tag').split(/\n/).include?(tag)
    end

    def version_tag(version)
      "v#{version}"
    end

    def version
      version_file = VersionFile::VERSION_FILE

      if File.exist?(version_file)
        Version.current(version_file)
      else
        raise <<-MSG
        The versioning/release process relies on having a VERSION file in the root of
        your cookbook as well as the version attribute in metadata.rb reading
        from said VERSION file.
          MSG
      end
    end

    def tag_version(release, tag)
      sh "git tag -a -m \"Version #{release}\" #{tag}"
      puts "Tagged #{tag}."
      yield if block_given?
    rescue Exception => e
      puts "Untagging #{tag} due to error."
      sh_with_code "git tag -d #{tag}"
      raise e
    end

    def sh_with_code(cmd, &block)
      cmd << " 2>&1"
      outbuf = `#{cmd}`
      if $? == 0
        block.call(outbuf) if block
      end
      [outbuf, $?]
    end
  end
end
