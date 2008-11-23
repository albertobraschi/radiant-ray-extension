namespace :ray do
  @ray  = "vendor/extensions/ray"
  @conf = "#{ @ray }/config"
  @path = "vendor/extensions"

  namespace :extension do
    task :install do
      check_download_preference
      pre_extension_installation
      extension_installation
      post_extension_installation
    end
  end

  namespace :setup do
    task :restart do
      setup_restart_preference
    end
    task :download do
      setup_download_preference
    end
  end

  def check_download_preference
    if File.exist?( "#{ @conf }/download.txt" )
      get_download_preference
    else
      setup_download_preference
    end
  end

  def pre_extension_installation
    if ENV[ "name" ]
      @name = ENV[ "name" ].gsub( /_/, "-" )
      @dir = @name.gsub( /-/, "_" )
    else
      puts "=============================================================================="
      puts "You have to tell me which extension you want to install."
      puts "Try: rake ray:ext name=extension_name"
      puts "=============================================================================="
      exit
    end
  end

  def extension_installation
    if @download_preference == "git\n"
      git_extension_installation
    elsif @download_preference == "http\n"
      http_extension_installation
    else
      fix_download_preference
      puts "I'm trying that installation again..."
      puts "=============================================================================="
      extension_installation
    end
    check_extension_for_submodules
    check_extension_for_dependencies
  end

  def post_extension_installation
    run_rake_tasks
    restart_server
  end

  def get_download_preference
    File.open( "#{ @conf }/download.txt", "r" ) do |preference_file|
      @download_preference = preference_file.gets
    end
  end

  def setup_download_preference
    require "ftools"
    puts "=============================================================================="
    git = system "git --version"
    if git
      download_preference = "git"
    else
      download_preference = "http"
    end
    File.makedirs( "#{ @conf }" )
    File.open( "#{ @conf }/download.txt", "w" ) do |preference_file|
      preference_file.puts download_preference
    end
    puts "Your download preference has been set to #{ download_preference }"
    puts "=============================================================================="
    get_download_preference
  end

  def get_restart_preference
    File.open( "#{ @conf }/restart.txt", "r" ) do |preference_file|
      @restart_preference = preference_file.gets
    end
  end

  def setup_restart_preference
    require "ftools"
    if ENV[ "server" ]
      restart_preference = ENV[ "server" ]
      File.makedirs( "#{ @conf }" )
      File.open( "#{ @conf }/restart.txt", "w" ) do |preference_file|
        preference_file.puts restart_preference
      end
      puts "=============================================================================="
      puts "Your restart preference has been set to #{ restart_preference }"
      puts "=============================================================================="
      get_download_preference
    else
      puts "=============================================================================="
      puts "You have to tell what kind of server you'd like to restart, e.g."
      puts "rake ray:setup:restart server=mongrel"
      puts "rake ray:setup:restart server=passenger"
      puts "=============================================================================="
      exit
    end
  end

  def fix_download_preference
    puts "=============================================================================="
    puts "Your download preference is broken."
    system "rm #{ @conf }/download.txt"
    puts "The broken preference file has been removed."
    setup_download_preference
  end

  def cached_search
    @extension = []
    @source = []
    @http_url = []
    File.open( "#{ @ray }/search.yml" ) do |repositories|
      YAML.load_documents( repositories ) do |repository|
        total = repository[ 'repositories' ].length
        for i in 0...total
          found = false
          repo = repository[ 'repositories' ][ i ][ 'name' ]
          if repo.include?( @term )
            @extension << repo
            owner = repository[ 'repositories' ][ i ][ 'owner' ]
            @source << owner
            location = repository[ 'repositories' ][ i ][ 'url' ].gsub( /http/, "git" )
            @http_url << location
          end
        end
      end
    end
  end

  def find_the_extension_to_install
    if @extension.length == 0
      puts "=============================================================================="
      puts "I couldn't find any extension matching '#{ @name }'"
      puts "=============================================================================="
      exit
    elsif @extension.length == 1
      @url = @http_url[ 0 ]
    elsif @extension.include?( "radiant-#{ @name }-extension" )
      for j in 0...@extension.length
        @url = @http_url[ j ]
        nice_name = @extension[ j ].gsub( /radiant[-|_]/, "" ).gsub( /[-|_]extension/, "" )
        break if nice_name == @name
      end
    else
      puts "=============================================================================="
      puts "There are more than one extensions that match #{ @name }"
      puts "Run the command appropriate to the extension you want to install."
      for j in 0...@extension.length
        nice_name = @extension[ j ].gsub( /radiant[-|_]/, "" ).gsub( /[-|_]extension/, "" )
        puts "rake ray:ext name=" + nice_name
      end
      exit
    end
  end

  def extension_installation_setup
    require "yaml"
    if ENV[ 'term' ]
      @term = ENV[ 'term' ].downcase
      cached_search
      show_search_results
    else
      @term = @name
      cached_search
      find_the_extension_to_install
    end
  end

  def ensure_proper_directory
    unless File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
      @proper_dir = `ls #{ @path }/#{ @dir }/*_extension.rb`.gsub( /vendor\/extensions\/#{ @dir }\//, "").gsub( /_extension.rb/, "").gsub( /\n/, "")
      system "mv #{ @path }/#{ @dir } #{ @path }/#{ @proper_dir }"
      if File.exist?( ".gitmodules" )
        File.open( ".gitmodules", "r+" ) do |f|
          dir = f.read.gsub( "#{ @path }/#{ @dir }", "#{ @path }/#{ @proper_dir }" )
          f.rewind
          f.puts( dir )
        end
        system "git reset HEAD #{ @path }/#{ @dir }"
        system "git add #{ @path }/#{ @proper_dir }"
      end
    end
  end

  def git_extension_installation
    extension_installation_setup
    if File.exist?( ".git/HEAD" )
      system "git submodule add #{ @url }.git #{ @path }/#{ @dir }"
    else
      system "git clone -q #{ @url }.git #{ @path }/#{ @dir }"
    end
    ensure_proper_directory
  end

  def http_extension_installation
    puts "extension_installation_setup"
    puts "http_extension_installation"
    puts @dir
    puts "ensure_proper_directory"
    puts "=============================================================================="
  end

  def check_extension_for_submodules
    if @proper_dir
      ext = @proper_dir
    elsif @dir
      ext = @dir
    end
    if File.exist?( "#{ @path }/#{ ext }/.gitmodules")
      submodules = []
      paths = []
      f = File.readlines( "#{ @path }/#{ ext }/.gitmodules" ).map do |l|
        line = l.rstrip
        if line.include? "url"
          sub_url = line.gsub(/\turl\ =\ /, '')
          submodules << sub_url
        end
        if line.include? "path"
          sub_path = line.gsub(/\tpath\ =\ /, '')
          paths << sub_path
        end
      end
      i = 0
      while i < submodules.length
        if File.exist?( ".gitmodules")
          system "git submodule add #{ submodules[i] } #{ paths[i] }"
        else
          system "git clone #{ submodules[i] } #{ paths[i] }"
        end
        i =+ 1
      end
    end
  end

  def check_extension_for_dependencies
    if @proper_dir
      ext = @proper_dir
    elsif @dir
      ext = @dir
    end
    if File.exist?( "#{ @path }/#{ ext }/dependency.yml")
      p "has dependence"
    end
  end

  def run_rake_tasks
    if @proper_dir
      rake_file = `ls #{ @path }/#{ @proper_dir }/lib/tasks/*_extension_tasks.rake`.gsub( /\n/, "")
      extension = @proper_dir
    else
      rake_file = `ls #{ @path }/#{ @dir }/lib/tasks/*_extension_tasks.rake`.gsub( /\n/, "")
      extension = @dir
    end
    if tasks = File.open( "#{ rake_file }", "r" ) rescue nil
      counter = 1
      while ( line = tasks.gets )
        install_task = line.include? ":install"
        break if install_task
        counter = counter + 1
      end
      tasks.close
      if install_task
        system "rake radiant:extensions:#{ extension }:install"
      else
        tasks = File.open( "#{ rake_file }", "r")
        counter = 1
        while ( line = tasks.gets )
          migrate_task = line.include? ":migrate"
          update_task = line.include? ":update"
          if migrate_task
            system "rake radiant:extensions:#{ extension }:migrate"
            puts "The #{ extension } extension migrations have been applied."
          end
          if update_task
            system "rake radiant:extensions:#{ extension }:update"
            puts "The #{ extension } extension static assets have been updated."
          end
          counter = counter + 1
        end
        tasks.close
      end
      puts "=============================================================================="
      puts "The #{ extension } extension has been installed."
      puts "To disable it run: rake ray:dis name=#{ extension }"
      puts "=============================================================================="
    else
      puts "=============================================================================="
      puts "I couldn't find a tasks file for the #{ extension } extension."
      puts "Please manually verify the installation and restart the server."
      puts "=============================================================================="
      exit
    end
  end

  def restart_server
    if File.exist?( "#{ @conf }/restart.txt" )
      get_restart_preference
    else
      puts "You need to restart your server."
      puts "If you want me to auto-restart the server you need to set your preference."
      puts "Try: rake ray:setup:restart server=passenger"
      puts "Or:  rake ray:setup:restart server=mongrel"
      puts "=============================================================================="
      exit
    end
    if @restart_preference == "passenger\n"
      tmp = Dir.open( "tmp" ) rescue nil
      unless tmp
        system "mkdir tmp"
      end
      system "touch tmp/restart.txt"
    elsif @restart_preference == "mongrel\n"
      puts "mongrel_rails cluster::restart"
    else
      puts "=============================================================================="
      puts "I don't know how to restart #{ @restart_preference }."
      puts "You'll have to restart it manually."
      puts "=============================================================================="
    end
  end

  # shorthand
  desc "Install an extension."
  task :ext => ["extension:install"]

  # namespace :extension do
  #   task :remove do
  #     require "#{@task}/_extension_remove.rb"
  #   end
  #   task :disable do
  #     require "#{@task}/_extension_disable.rb"
  #   end
  #   task :enable do
  #     require "#{@task}/_extension_enable.rb"
  #   end
  #   task :pull do
  #     require "#{@task}/_extension_pull.rb"
  #   end
  #   task :bundle_install do
  #     require "#{@task}/_extension_install_bundle.rb"
  #   end
  #   task :search do
  #     require "#{@task}/_extension_search.rb"
  #   end
  # end
  # namespace :setup do
  #   task :initial do
  #     require "#{@task}/_setup.rb"
  #   end
  #   task :update do
  #     require "#{@task}/_setup_update.rb"
  #   end
  #   task :download do
  #     require "#{@task}/_setup_download_preference.rb"
  #   end
  #   task :restart do
  #     require "#{@task}/_setup_restart_preference.rb"
  #   end
  # end
end

# supress faulty error messages
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
