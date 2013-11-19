module ChefSpec::API

  module ArkMatchers

    def put_ark(resource_name)
      ChefSpec::Matchers::ResourceMatcher.new(:ark, :put, resource_name)
    end

    def install_ark(resource_name)
      ChefSpec::Matchers::ResourceMatcher.new(:ark, :install, resource_name)
    end

  end
end
