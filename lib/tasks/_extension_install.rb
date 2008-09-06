name = ENV['name']
if ENV['name'].nil?
  puts "You have to tell me which extension to install."
  puts "Try something like: rake ray:ext name=extension_name"
else
  mkdir_p "vendor/extensions"
  download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
  ray_download = download_preference.gets
  download_preference.close
  if ray_download == "git\n"
    case
    when ENV['fullname']
      if ENV['hub'].nil?
        puts "You have to tell me which github user to get the extension from."
        puts "Try something like: rake ray:ext fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
      else
        require 'vendor/extensions/ray/lib/tasks/_extension_install_custom.rb'
        require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
      end
    when ENV['hub']
    else
    end
  elsif ray_download == "http\n"
    case
    when ENV['fullname']
    when ENV['hub']
    else
    end
  end
end

  # 
  # if ray_setup == "git\n"
  #   case
  #   when ENV['fullname']
  #     if ENV['hub'].nil?
  #       puts "You have to tell me which github user to get the extension from. Try something like: rake ray:extension:install fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
  #     else
  #       install_custom_extension
  #       restart_server
  #     end
  #   
  #   when ENV['hub']
  #     if ENV['fullname'].nil?
  #       install_extension
  #     else
  #       install_custom_extension
  #     end
  #     restart_server
  #   
  #   else
  #     install_extension
  #     restart_server
  #   end
  # elsif ray_setup == "http\n"
  #   case
  #   when ENV['fullname']
  #     if ENV['hub'].nil?
  #       puts "You have to tell me which github user to get the extension from. Try something like: rake ray:extension:install fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
  #     else
  #       install_extension_http
  #       restart_server
  #     end
  #   
  #   when ENV['hub']
  #     if ENV['fullname'].nil?
  #       install_extension_http
  #     else
  #       install_extension_http
  #     end
  #     restart_server
  # 
  #   else
  #     install_extension_http
  #     restart_server
  #   end
  # end
# github_name = name.gsub(/\_/, "-")
# vendor_name = name.gsub(/\-/, "_")
# radiant_git = "git://github.com/radiant/"
# if ENV['hub'].nil?
#   ext_repo = radiant_git
# else
#   ext_repo = "git://github.com/#{ENV['hub']}/"
# end
# git_check = File.new(".git/HEAD", "r") rescue nil
# if git_check == nil
#   system "git clone #{ext_repo}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
# else
#   system "git submodule add #{ext_repo}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
#   git_check.close
# end
# post_install_extension