# Ideas and code for releasing a cookbook heavily borrowed from bundler https://github.com/bundler/bundler
module CookbookDevelopment
  class ReleaseTasks < Rake::TaskLib
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
      desc 'Does a berks upload --except :test'
      task :upload do |task|
        Berkshelf::Berksfile.from_file(berks_file).upload(:path => cookbooks_dir, :except => :test)
      end

      desc 'Runs the full test suite and then does a berks upload'
      task :release do
        release_cookbook
      end

      desc 'Does not run the full test suite and then does a berks upload'
      task :notest_release do
        release_cookbook('skip_test')
      end

    end

    def release_cookbook(skip_test = false)
      release_version = version
      release_tag = version_tag(release_version)

      raise "Tag #{release_tag} has already been created." if already_tagged?(release_tag)
      raise 'You have uncommitted changes.' unless clean? && committed?
      raise 'You have unpushed commits.' if unpushed?

      Rake::Task[:test].invoke unless skip_test

      tag_version(release_version, release_tag) do
        berks_upload
        Rake::Task['version:bump:patch'].invoke
        git_pull
        git_push
      end
    end

    def berks_upload
      puts 'Running berks upload...'
      Rake::Task[:upload].invoke
    end

    def git_pull
      cmd = 'git pull --rebase'
      out, code = sh_with_code(cmd)
      raise "Couldn't git pull. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
    end

    def git_push
      puts 'Pushing git changes...'
      perform_git_push 'origin --tags :'
      puts 'Pushed git commits and tags.'
    end

    def perform_git_push(options = '')
      cmd = "git push #{options}"
      out, code = sh_with_code(cmd)
      raise "Couldn't git push. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
    end

    def clean?
      sh_with_code('git diff --exit-code')[1] == 0
    end

    def committed?
      sh_with_code('git diff-index --quiet --cached HEAD')[1] == 0
    end

    def unpushed?
      sh_with_code('git cherry')[0] != ''
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
      alt_version_file = VersionFile::ALT_VERSION_FILE

      if File.exist?(version_file)
        Version.current(version_file)
      elsif File.exist?(alt_version_file)
        Version.current(alt_version_file)
      else
        raise <<-MSG
        The versioning/release process relies on having a VERSION file in the root of
        your cookbook as well as the version attribute in metadata.rb reading
        from said VERSION file. Until https://github.com/opscode/test-kitchen/pull/212
        is resolved we need to put the cookbooks in a place that test-kitchen
        will copy to the VM. That place is in recipes/VERSION. Neither #{version_file}
        nor #{alt_version_file} were found in your cookbook.
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
