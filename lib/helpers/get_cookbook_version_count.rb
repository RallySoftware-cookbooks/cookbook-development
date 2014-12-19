require 'ridley'

# Hide warnings from celluloid v0.16.0 (https://github.com/RiotGames/ridley/issues/220)
Ridley::Logging.logger.level = Logger.const_get 'ERROR'

ridley = Ridley.new(
  server_url: 'https://api.opscode.com/organizations/rally',
  client_name: 'chefbuild',
  client_key: '~/.chef/chefbuild.pem'
)

puts "Number of cookbook versions: #{ridley.cookbook.all.count}"
