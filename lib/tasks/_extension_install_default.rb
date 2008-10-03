github_name = @name.gsub(/\_/, "-")
vendor_name = @name.gsub(/\-/, "_")
master_repo = "git://github.com/radiant"
if @hub
  repository = "git://github.com/#{@hub}"
else
  repository = master_repo
end
if File.exist?(".git/HEAD")
  system "git submodule add #{repository}/radiant-#{github_name}-extension.git #{@path}/#{vendor_name}"
else
  system "git clone #{repository}/radiant-#{github_name}-extension.git #{@path}/#{vendor_name}"
end
require "#{@task}/_extension_post_install.rb"
