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
  locations = options.delete(:locations) || ['bld']
  stub_data_bag_item('rally', 'locations').and_return({'known_locations' => locations})

  options.each do |key, value|
    if key.to_s.end_with? *locations
      Chef::DataBagItem.stub(:load).with('rally', key.to_s).and_return(value)
    else
      locations.each do |location|
        if !options.has_key? "#{key}_#{location}"
          Chef::DataBagItem.stub(:load).with('rally', "#{key}_#{location}") { throw Net::HttpServerException }
        end
      end
    end
    Chef::DataBagItem.stub(:load).with('rally', key.to_s).and_return(value)
  end
end
