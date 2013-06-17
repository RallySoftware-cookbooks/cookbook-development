require 'chefspec'
require 'pathname'

# Since we have moved our specs into the test directory the default_cookbook_path defined
# in chefspec is not correct. Fix that here.
module ChefSpec
  class ChefRunner
    def default_cookbook_path
      Pathname.new(File.join(caller(2).first.split(':').slice(0..-3).join(':'), '..', '..', '..', '..')).cleanpath.to_s
    end
  end
end
