name = ENV['name']
path = 'vendor/extensions'
if ENV['path']
  path = ENV['path']
end
vendor_name = name.gsub(/\-/, "_")
system "mv #{@ray}/disabled_extensions/#{vendor_name} #{path}/#{vendor_name}"
puts "=============================================================================="
puts "The #{vendor_name} extension has been enabled."
puts "To disable it use: rake ray:dis name=#{vendor_name}"
puts "=============================================================================="
require "#{@task}/_restart_server.rb"
