def install_extension
  require 'vendor/extensions/ray/lib/tasks/_extension_install_default.rb'
end
def install_extension_http
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http.rb'
end
def install_custom_extension
  require 'vendor/extensions/ray/lib/tasks/_extension_install_custom.rb'
end
def restart
  require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
end

name = ENV['name']
if ENV['name'].nil?
  puts "==="
  puts "You have to tell me which extension to install."
  puts "Try something like: rake ray:ext name=extension_name"
  puts "==="
else
  mkdir_p "vendor/extensions"
  download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
  ray_download = download_preference.gets
  download_preference.close
  if ray_download == "git\n"
    case
    when ENV['fullname']
      if ENV['hub'].nil?
        puts "==="
        puts "You have to tell me which github user to get the extension from."
        puts "Try something like: rake ray:ext fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
        puts "==="
      else
        install_custom_extension
        restart
      end
    when ENV['hub']
      if ENV['fullname'].nil?
        install_extension
      else
        install_custom_extension
      end
      restart
    else
      install_extension
      restart
    end
  elsif ray_download == "http\n"
    install_extension_http
    restart
  end
end
