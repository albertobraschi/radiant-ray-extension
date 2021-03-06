github_name = @name.gsub(/\_/, "-")
if @vendor
  @vendor_name = @vendor
else
  @vendor_name = @name.gsub(/\-/, "_")
end
master_repo = "git://github.com/radiant"
if @hub
  repository = "git://github.com/#{@hub}"
else
  repository = master_repo
end
if @remote
  repository.gsub!('git://github.com/', 'git@github.com:')
end
if @fullname
  extension = @fullname
else
  extension = "radiant-#{github_name}-extension"
end
if @path != "vendor/extensions"
  if File.exist?("#{@path}/.git/HEAD")
    system "git submodule add #{repository}/#{extension}.git #{@path}/#{@vendor_name}"
  else
    system "git clone #{repository}/#{extension}.git #{@path}/#{@vendor_name}"
  end
elsif File.exist?(".git/HEAD")
  system "git submodule add #{repository}/#{extension}.git #{@path}/#{@vendor_name}"
else
  system "git clone #{repository}/#{extension}.git #{@path}/#{@vendor_name}"
end
if @plugin
  require "#{@task}/_plugin_install_git.rb"
end
if @lib
  require "#{@task}/_library_install.rb"
end
if @remote
  require "#{@task}/_extension_remote.rb"
end
require "#{@task}/_extension_post_install.rb"
