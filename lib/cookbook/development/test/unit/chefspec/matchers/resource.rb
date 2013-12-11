module ChefSpec
  module Matchers

    RSpec::Matchers.define :ready_resource_with_attribute do |resource_type, resource_name, attributes|
      match do |chef_run|
        found_resource = chef_run.find_resource(resource_type, resource_name)
        found_resource.nil? == false && \
          found_resource.action == [:nothing] && \
          attributes.any? { |attribute, value| found_resource.send(attribute) == value }
      end

      failure_message_for_should do |chef_run|
        "Expected #{resource_type}[#{resource_name}] with action [:nothing] && #{attributes} to be in Chef run. Other #{resource_type} resources:" \
          "\n\n  " + inspect_other_resources(chef_run, resource_type, attributes).join("\n  ") + "\n "
      end

      failure_message_for_should_not do |chef_run|
        "Should not have found execute[#{resource_name}] with action [:nothing] && #{attributes}"
      end

      def inspect_other_resources(chef_run, resource_type, attributes)
        parameter, param_value = nil, nil
        attributes.each_pair { |key, value| parameter, param_value = key, value }
        resources = []
        chef_run.find_resources(resource_type).each do |resource|
          resources << "#{resource_type}[#{resource.name}] has:\n\t\taction: #{resource.action.inspect}\n\t\t#{parameter}: `#{resource.send(parameter).to_s}`"
        end
        resources
      end
    end
  end
end
