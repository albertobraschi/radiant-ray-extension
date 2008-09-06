namespace :ray do
  desc "Install an extension from GitHub."
  task :ext => ["extension:install"]
  desc "Delete an extension and remove migrations."
  task :rm => ["extension:remove"]
  desc "Disable an extension."
  task :dis => ["extension:disable"]
  desc "Enable an extension."
  task :en => ["extension:enable"]
  desc "Install the Paperclipped Asset Manager."
  task :assets => ["extension:paperclipped"]
  desc "Install the Page Attachments extension."
  task :attachments => ["extension:page_attachments"]
  desc "Install the Help documentation extension."
  task :help => ["extension:help"]
  desc "Install the RDiscount Markdown filter."
  task :markdown => ["extension:markdown"]
  desc "Run Ray's initial setup tasks."
  task :setup => ["setup:initial"]
  desc "Have Ray set your download preference (HTTP/GIT)."
  task :git => ["setup:download"]
  namespace :extension do
    task :install do
      require 'vendor/extensions/ray/lib/tasks/_extension_install.rb'
    end
    task :remove do
      require 'vendor/extensions/ray/lib/tasks/_extension_remove.rb'
    end
    task :paperclipped do
      require 'vendor/extensions/ray/lib/tasks/_extension_paperclipped.rb'
    end
    task :page_attachments do
      require 'vendor/extensions/ray/lib/tasks/_extension_page_attachments.rb'
    end
    task :help do
      require 'vendor/extensions/ray/lib/tasks/_extension_help.rb'
    end
    task :markdown do
      require 'vendor/extensions/ray/lib/tasks/_extension_markdown.rb'
    end
  end
  namespace :setup do
    task :initial do
      require 'vendor/extensions/ray/lib/tasks/_setup.rb'
    end
    task :download do
      require 'vendor/extensions/ray/lib/tasks/_setup_download_preference.rb'
    end
  end
end