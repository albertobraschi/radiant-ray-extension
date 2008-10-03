name = ENV['name']
path = 'vendor/extensions'
if ENV['path']
  path = ENV['path']
end
vendor_name = name.gsub(/\-/, "_")
system "mkdir -p #{@ray}/disabled_extensions"
system "mv #{path}/#{vendor_name} #{@ray}/disabled_extensions/#{vendor_name}"
puts "=============================================================================="
puts "The #{vendor_name} extension has been disabled."
puts "To enable it use: rake ray:en name=#{vendor_name}"
puts "=============================================================================="
require "#{@task}/_restart_server.rb"
