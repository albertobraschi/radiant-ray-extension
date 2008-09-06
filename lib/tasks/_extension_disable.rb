name = ENV['name']
vendor_name = name.gsub(/\-/, "_")
mkdir_p "vendor/extensions/ray/disabled_extensions"
system "mv vendor/extensions/#{vendor_name} vendor/extensions/ray/disabled_extensions/#{vendor_name}"
puts "The #{vendor_name} extension has been disabled."
puts "To enable it use: rake ray:en name=#{vendor_name}"
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb