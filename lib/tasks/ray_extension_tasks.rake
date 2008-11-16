namespace :ray do
  require File.expand_path( File.dirname( __FILE__ ) + '/../shorthand' )
  namespace :extension do
    task :install do
      require File.expand_path( File.dirname( __FILE__ ) + '/../install' )
    end
    task :remove do
      require "#{@task}/_extension_remove.rb"
    end
    task :disable do
      require "#{@task}/_extension_disable.rb"
    end
    task :enable do
      require "#{@task}/_extension_enable.rb"
    end
    task :pull do
      require "#{@task}/_extension_pull.rb"
    end
    task :page_attachments do
      require "#{@task}/_extension_page_attachments.rb"
    end
    task :help do
      require "#{@task}/_extension_help.rb"
    end
    task :markdown do
      require "#{@task}/_extension_markdown.rb"
    end
    task :bundle_install do
      require "#{@task}/_extension_install_bundle.rb"
    end
    task :search do
      require "#{@task}/_extension_search.rb"
    end
  end
  namespace :setup do
    task :initial do
      require "#{@task}/_setup.rb"
    end
    task :update do
      require "#{@task}/_setup_update.rb"
    end
    task :download do
      require "#{@task}/_setup_download_preference.rb"
    end
    task :restart do
      require "#{@task}/_setup_restart_preference.rb"
    end
  end
  namespace :radiant do
    task :edge do
      require "#{@task}/_radiant_edge.rb"
    end
    task :instance do
      require "#{@task}/_radiant_instance.rb"
    end
    task :branch do
      puts "==="
      puts "Not implemented."
      puts "==="
    end
    task :tag do
      puts "==="
      puts "Not implemented."
      puts "==="
    end
  end
end

namespace :radiant do
  namespace :extensions do
    namespace :ray do
      task :migrate do
        puts "No migrations necessary."
      end
      task :update do
        puts "No updates necessary."
      end
    end
  end
end
