github_name = @name.gsub(/\_/, "-")
if @vendor
  vendor_name = @vendor
else
  vendor_name = @name.gsub(/\-/, "_")
end
master_repo = "git://github.com/radiant"
if @hub
  repository = "git://github.com/#{@hub}"
else
  repository = master_repo
end
if @fullname
  extension = @fullname
else
  extension = "radiant-#{github_name}-extension"
end
if File.exist?(".git/HEAD")
  system "git submodule add #{repository}/#{extension}.git #{@path}/#{vendor_name}"
else
  system "git clone #{repository}/#{extension}.git #{@path}/#{vendor_name}"
end
require "#{@task}/_extension_post_install.rb"
