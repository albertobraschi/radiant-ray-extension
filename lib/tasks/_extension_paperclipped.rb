download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
ray_download = download_preference.gets
download_preference.close
mkdir_p "vendor/extensions"
if ray_download == "git\n"
  git_check = File.new(".git/HEAD", "r") rescue nil
  if git_check == nil
    system "git clone git://github.com/kbingman/paperclipped.git vendor/extensions/paperclipped"
  else
    system "git submodule add git://github.com/kbingman/paperclipped.git vendor/extensions/paperclipped"
    git_check.close
  end
else
  mkdir_p "vendor/extensions/ray/tmp"
  @ext_repo = "http://github.com/kbingman/"
  @repo_name = "paperclipped"
  require 'vendor/extensions/ray/lib/tasks/_extension_install_http_special.rb'
end
system "rake radiant:extensions:paperclipped:migrate"
system "rake radiant:extensions:paperclipped:update"
require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
