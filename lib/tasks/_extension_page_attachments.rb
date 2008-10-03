@name = "page_attachments"
@plugin = "attachment_fu"
@plugin_repository = "technoweenie"
if ENV['lib']
  @lib = ENV['lib']
end
require "#{@task}/_extension_install.rb"
