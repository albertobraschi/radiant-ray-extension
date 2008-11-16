@ray  = "vendor/extensions/ray"
@task = "#{@ray}/lib/tasks"
@conf = "#{@ray}/config"
@path = "vendor/extensions"

desc "Install an extension from GitHub."
task :ext => ["extension:install"]

desc "Delete an extension and remove migrations."
task :rm => ["extension:remove"]

desc "Disable an extension."
task :dis => ["extension:disable"]

desc "Enable an extension."
task :en => ["extension:enable"]

desc "Merge all remotes of an extension."
task :pull => ["extension:pull"]

desc "Install the Page Attachments extension."
task :attachments => ["extension:page_attachments"]

desc "Install the Help documentation extension."
task :help => ["extension:help"]

desc "Install the RDiscount Markdown filter."
task :markdown => ["extension:markdown"]

desc "Run Ray's initial setup tasks."
task :setup => ["setup:initial"]

desc "Update to Ray 1.1"
task :update => ["setup:update"]

desc "Have Ray set your download preference (HTTP/GIT)."
task :git => ["setup:download"]

desc "Install the latest Edge Radiant."
task :edge => ["radiant:edge"]

desc "Revert from Edge Radiant to your latest gem version."
task :instance => ["radiant:instance"]

desc "Install an extension bundle."
task :bundle => ["extension:bundle_install"]

desc "Search extensions by keyword."
task :search => ["extension:search"]

desc "Restart your server."
task :restart do
  require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
end
