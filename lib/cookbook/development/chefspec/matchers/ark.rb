module ChefSpec

  module Matchers
    def self.ark_assert(package_name, scope)
      scope.match do |chef_run|
        chef_run.resources.any? do |resource|
          resource_type(resource) == 'ark' && resource.name == package_name &&
            yield(resource)
        end
      end
    end

    RSpec::Matchers.define :install_ark do |package_name, path|
      ChefSpec::Matchers.ark_assert(package_name, self) do |resource|
        resource.path == path
      end
    end

    RSpec::Matchers.define :owner_group_ark do |package_name, owner, group|
      ChefSpec::Matchers.ark_assert(package_name, self) do |resource|
        resource.owner == owner && resource.group == group
      end
    end

    RSpec::Matchers.define :url_ark do |package_name, url|
      ChefSpec::Matchers.ark_assert(package_name, self) do |resource|
        resource.url == url
      end
    end

    # Due to flakyness with how 'resource.mode' is stored at times in chef_run,
    # we are testing 'resource.mode' here against the passed in 'mode' as
    # either in decimal or octal numeric representation.
    RSpec::Matchers.define :mode_ark do |package_name, mode|
      ChefSpec::Matchers.ark_assert(package_name, self) do |resource|
        (resource.mode == mode || resource.mode == "#{mode}".oct)
      end
    end
  end
end
