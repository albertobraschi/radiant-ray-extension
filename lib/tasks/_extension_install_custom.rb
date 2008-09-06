name = ENV['name']
vendor_name = name.gsub(/\-/, "_")
ext_repo = "git://github.com/#{ENV['hub']}/"
git_check = File.new(".git/HEAD", "r") rescue nil
if git_check == nil
  system "git clone #{ext_repo}#{ENV['fullname']}.git vendor/extensions/#{vendor_name}"
else
  system "git submodule add #{ext_repo}#{ENV['fullname']}.git vendor/extensions/#{vendor_name}"
  git_check.close
end
require 'vendor/extensions/ray/lib/tasks/_extension_post_install.rb'
