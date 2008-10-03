unless @plugin_path
  @plugin_path = @plugin
end
if File.exist?(".git/HEAD")
  system "git submodule add git://github.com/#{@plugin_repository}/#{@plugin}.git vendor/plugins/#{@plugin_path}"
else
  system "git clone git://github.com/#{@plugin_repository}/#{@plugin}.git vendor/plugins/#{@plugin_path}"
end