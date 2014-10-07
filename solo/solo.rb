ssl_verify_mode :verify_peer
file_cache_path "#{File.expand_path(File.dirname(__FILE__))}/../solo/cache"
cookbook_path "#{File.expand_path(File.dirname(__FILE__))}/../cookbooks"
Ohai::Config[:disabled_plugins] = [:EC2]
