module StubHelpers

  def stub_include_recipe
    # Don't worry about external cookbook dependencies
    Chef::Cookbook::Metadata.any_instance.stub(:depends)

    # Test each recipe in isolation, regardless of includes
    @included_recipes = []
    Chef::RunContext.any_instance.stub(:loaded_recipe?).and_return(false)
    Chef::Recipe.any_instance.stub(:include_recipe) do |i|
      Chef::RunContext.any_instance.stub(:loaded_recipe?).with(i).and_return(true)
      @included_recipes << i
    end
    Chef::RunContext.any_instance.stub(:loaded_recipes).and_return(@included_recipes)
  end
end

def stub_locations(options)
  type = options.delete(:type) || :plain

  case type
  when :plain
    stub_databag_type(Chef::DataBagItem, options)
  when :encrypted_data_bag
    stub_databag_type(Chef::EncryptedDataBagItem, options)
  when :chef_vault
    stub_databag_type(ChefVault::Item, options)
  else
    raise "Data bag type #{type} unknown"
  end
end

def stub_databag_type(type, options)
  locations = options.delete(:locations) || ['bld']
  stub_data_bag_item('rally', 'locations').and_return({'known_locations' => locations})

  options.each do |key, value|
    unless key.to_s.end_with? *locations
      locations.each do |location|
        unless options.has_key? "#{key}_#{location}"
          type.stub(:load).with('rally', "#{key}_#{location}") { throw Net::HttpServerException }
        end
      end
    end
    type.stub(:load).with('rally', key.to_s).and_return(value)
  end
end
