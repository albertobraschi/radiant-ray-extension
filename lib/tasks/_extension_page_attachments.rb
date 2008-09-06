if ENV['lib'].nil?
  puts "==="
  puts "You didn't specify an image processing library."
  puts "So I guess you either have one installed or don't won't one."
  puts "==="
else
  if image_lib == "mini_magick"
    puts "==="
    puts "I'm about to install the mini_magick gem."
    puts "You'll need to enter your system administrator password."
    puts "==="
    system "sudo gem install mini_magick"
  elsif image_lib == "rmagick"
    puts "==="
    puts "I'm about to install the rmagick gem."
    puts "You'll need to enter your system administrator password."
    puts "==="
    system "sudo gem install rmagick"
  else
    puts "==="
    puts "I only know how to install mini_magick and rmagick."
    puts "You'll need to install #{ENV['lib']} manually."
    puts "==="
  end
end
download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
ray_download = download_preference.gets
download_preference.close
mkdir_p "vendor/plugins"
mkdir_p "vendor/extensions"
if ray_download == "git\n"
  git_check = File.new(".git/HEAD", "r") rescue nil
  if git_check == nil
    system "git clone git://github.com/technoweenie/attachment_fu.git vendor/plugins/attachment_fu"
    system "git clone git://github.com/radiant/radiant-page-attachments-extension.git vendor/extensions/page_attachments"
  else
    system "git submodule add git://github.com/technoweenie/attachment_fu.git vendor/plugins/attachment_fu"
    system "git submodule add git://github.com/radiant/radiant-page-attachments-extension.git vendor/extensions/page_attachments"
  end
  git_check.close
else
  mkdir_p "vendor/extensions/ray/tmp"
  @plugin_name = "attachment_fu"
  @plugin_hub = "technoweenie"
  @ext_repo = "http://github.com/radiant/"
  @repo_name = "page_attachments"
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http_plugin.rb'
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http_special.rb'
end
system "rake radiant:extensions:page_attachments:migrate"
system "rake radiant:extensions:page_attachments:update"
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
