namespace :ray do

  task :ext   => ["extension:install"]
  task :rm    => ["extension:remove"]
  task :setup => ["setup:initial"]
  task :git   => ["setup:download"]

  namespace :extension do
    task :install do
      require 'vendor/extensions/ray/lib/tasks/_extension_install.rb'
    end
    task :remove do
      require 'vendor/extensions/ray/lib/tasks/_extension_remove.rb'
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