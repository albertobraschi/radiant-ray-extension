mkdir_p "vendor/extensions/ray/disabled_extensions"
system "mv vendor/extensions/#{vendor_name} vendor/extensions/ray/disabled_extensions/#{vendor_name}"
puts "The #{vendor_name} extension has been disabled."
puts "To re-enable it use: rake ray:enable name=#{vendor_name}"