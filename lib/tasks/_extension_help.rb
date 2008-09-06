download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
ray_download = download_preference.gets
download_preference.close
mkdir_p "vendor/extensions"
if ray_download == "git\n"
  git_check = File.new(".git/HEAD", "r") rescue nil
  if git_check == nil
    system "git clone git://github.com/saturnflyer/radiant-help-extension.git vendor/extensions/help"
  else
    system "git submodule add git://github.com/saturnflyer/radiant-help-extension.git vendor/extensions/help"
    git_check.close
  end
else
  mkdir_p "vendor/extensions/ray/tmp"
  @ext_repo = "http://github.com/saturnflyer/"
  @repo_name = "help"
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http_special.rb'
end
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
