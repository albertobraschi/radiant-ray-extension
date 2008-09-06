download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
ray_download = download_preference.gets
download_preference.close
mkdir_p "vendor/extensions"
puts "==="
puts "About to install the RDiscount gem."
puts "You will need to enter you system administrator password."
puts "==="
system "sudo gem install rdiscount"
if ray_download == "git\n"
  git_check = File.new(".git/HEAD", "r") rescue nil
  if git_check == nil
    system "git clone git://github.com/johnmuhl/radiant-markdown-extension.git vendor/extensions/markdown"
  else
    system "git submodule add git://github.com/johnmuhl/radiant-markdown-extension.git vendor/extensions/markdown"
    git_check.close
  end
else
  mkdir_p "vendor/extensions/ray/tmp"
  @ext_repo = "http://github.com/johnmuhl/"
  @repo_name = "markdown"
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http_special.rb'
end
system "mv vendor/extensions/markdown vendor/extensions/markdown_filter"
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
