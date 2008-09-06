name = ENV['name']
github_name = name.gsub(/\_/, "-")
vendor_name = name.gsub(/\-/, "_")
radiant_git = "git://github.com/radiant/"
if ENV['hub'].nil?
  ext_repo = radiant_git
else
  ext_repo = "git://github.com/#{ENV['hub']}/"
end
git_check = File.new(".git/HEAD", "r") rescue nil
if git_check == nil
  system "git clone #{ext_repo}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
else
  system "git submodule add #{ext_repo}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
  git_check.close
end
require 'vendor/extensions/ray/lib/tasks/_extension_post_install.rb'
