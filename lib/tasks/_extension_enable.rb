name = ENV['name']
vendor_name = name.gsub(/\-/, "_")
system "mv vendor/extensions/ray/disabled_extensions/#{vendor_name} vendor/extensions/#{vendor_name}"
puts "The #{vendor_name} extension has been enabled."
puts "To disable it use: rake ray:dis name=#{vendor_name}"
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb