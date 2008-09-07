namespace :ray do
  require 'vendor/extensions/ray/lib/tasks/_shorthand.rb'
  namespace :extension do
    task :install do
      require 'vendor/extensions/ray/lib/tasks/_extension_install.rb'
    end
    task :remove do
      require 'vendor/extensions/ray/lib/tasks/_extension_remove.rb'
    end
    task :disable do
      require 'vendor/extensions/ray/lib/tasks/_extension_disable.rb'
    end
    task :enable do
      require 'vendor/extensions/ray/lib/tasks/_extension_enable.rb'
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
    task :update do
      require 'vendor/extensions/ray/lib/tasks/_setup_update.rb'
    end
    task :download do
      require 'vendor/extensions/ray/lib/tasks/_setup_download_preference.rb'
    end
    task :restart do
      require 'vendor/extensions/ray/lib/tasks/_setup_restart_preference.rb'
    end
  end
end
