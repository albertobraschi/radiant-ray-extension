namespace :ray do
  @ray  = 'vendor/extensions/ray'
  @conf = "#{ @ray }/config"
  @path = 'vendor/extensions'

  namespace :extension do
    task :install do
      @message = 'You have to tell me which extension to install, e.g.'
      @example = 'rake ray:ext name=extension_name'
      check_command_input
      check_download_preference
      extension_installation
      # post_extension_installation
    end
    task :search do
      @message = 'You have to give me a term to search for, e.g.'
      @example = 'rake ray:search term=xyz'
      check_command_input
      search_extensions
    end
    task :disable do
      @message = 'You have to tell me which extension to disable, e.g.'
      @example = 'rake ray:dis name=extension_name'
      check_command_input
      disable_extension
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

  def check_command_input
    if ENV[ 'term' ]
      @term = ENV[ 'term' ]
    elsif ENV[ 'name' ]
      @term = ENV[ 'name' ]
      @name = @term.gsub( /_/, '-' )
      @dir  = @name.gsub( /-/, '_' )
    else
      puts '=============================================================================='
      print "#{ @message }\n#{ @example }\n"
      puts '=============================================================================='
      exit
    end
  end
  def check_download_preference
    if File.exist?( "#{ @conf }/download.txt" )
      download_preference_read
    else
      download_preference_setup
    end
  end
  def check_extension_directory
    unless File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
      @path_regexp = Regexp.escape( @path )
      @proper_dir = `ls #{ @path }/#{ @dir }/*_extension.rb`.gsub( /#{ @path_regexp }\/#{ @dir }\//, "").gsub( /_extension.rb/, "").gsub( /\n/, "")
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
  def check_extension_submodules
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
        if line.include? 'url'
          sub_url = line.gsub(/\turl\ =\ /, '')
          submodules << sub_url
        end
        if line.include? 'path'
          sub_path = line.gsub(/\tpath\ =\ /, '')
          paths << sub_path
        end
      end
      i = 0
      while i < submodules.length
        if File.exist?( '.gitmodules' )
          system "git submodule add #{ submodules[i] } #{ paths[i] }"
        else
          system "git clone #{ submodules[i] } #{ paths[i] }"
        end
        i =+ 1
      end
    end
  end
  def check_extension_dependencies
    if @proper_dir
      ext = @proper_dir
    elsif @dir
      ext = @dir
    end
    if File.exist?( "#{ @path }/#{ ext }/dependency.yml")
      puts "not yet implemented."
    end
  end

  def download_preference_read
    File.open( "#{ @conf }/download.txt", 'r' ) do |p|
      @download = p.gets
    end
  end
  def download_preference_setup
    require 'ftools'
    puts '=============================================================================='
    git = system 'git --version'
    if git
      pref = 'git'
    else
      pref = 'http'
    end
    File.makedirs( "#{ @conf }" )
    File.open( "#{ @conf }/download.txt", 'w' ) do |p|
      p.puts pref
    end
    puts "Your download preference has been set to #{ pref }"
    puts '=============================================================================='
    download_preference_read
  end
  def download_preference_repair
    puts '=============================================================================='
    puts 'Your download preference is broken.'
    system "rm #{ @conf }/download.txt"
    puts 'The broken preference file has been deleted.'
    download_preference_setup
  end

  def extension_installation
    if @download == "git\n"
      extension_install_git
    elsif @download == "http\n"
      extension_install_http
    else
      download_preference_repair
      puts 'Automatically retrying that installation again...'
      puts '=============================================================================='
      extension_installation
    end
    check_extension_submodules
    check_extension_dependencies
  end
  def extension_install_git
    search_extensions
    extension_install_setup
    @url = @url.gsub( /http/, 'git' )
    if File.exist?( '.git/HEAD' )
      system "git submodule -q add #{ @url }.git #{ @path }/#{ @dir }"
    else
      system "git clone -q #{ @url }.git #{ @path }/#{ @dir }"
    end
    check_extension_directory
  end
  def extension_install_http
    # extension_install_setup
    puts 'not yet implemented, http_extension_installation'
    # check_extension_directory
  end
  def extension_install_setup
    if @extension.length == 1
      @url = @http_url[0]
    else
      puts '=============================================================================='
      puts "No extension exactly matched - #{ @name } - be more specific."
      puts "Use the command listed to install the extension you want."
      search_results
    end
  end

  def search_extensions
    if File.exist?( "#{ @ray }/search.yml" )
      if ENV[ 'term' ]
        @term = ENV[ 'term' ].downcase
        search_cache
        search_results
      else
        search_cache
      end
    else
      search_online
    end
  end
  def search_cache
    require 'yaml'
    @extension = []
    @source = []
    @http_url = []
    @description = []
    File.open( "#{ @ray }/search.yml" ) do |repositories|
      YAML.load_documents( repositories ) do |repository|
        total = repository[ 'repositories' ].length
        for i in 0...total
          found = false
          extension = repository[ 'repositories' ][i][ 'name' ]
          if extension.include?( @term )
            @extension << extension
            source = repository[ 'repositories' ][i][ 'owner' ]
            @source << source
            http_url = repository[ 'repositories' ][i][ 'url' ]
            @http_url << http_url
            description = repository[ 'repositories' ][i][ 'description' ]
            @description << description
          end
        end
      end
    end
  end
  def search_online
    puts '=============================================================================='
    puts "Online searching is not yet implemented."
    puts "It's waiting on GitHub to have a useful (search) API."
    puts '=============================================================================='
  end
  def search_results
    puts '=============================================================================='
    if @extension.length == 0
      puts "Your search - #{ @term } - did not match any extensions."
      puts '=============================================================================='
      exit
    end
    i = 0
    while i < @extension.length
      ext_name = @extension[i].gsub(/radiant-/, '').gsub(/-extension/, '')
      puts "  extension: #{ ext_name }"
      puts 'description: ' + @description[i]
      puts "    install: rake ray:ext name=#{ ext_name }"
      puts '=============================================================================='
      i += 1
    end
  end

  def disable_extension
    puts "disable"
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
    puts '=============================================================================='
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
    puts '=============================================================================='
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
      puts '=============================================================================='
      puts "Your restart preference has been set to #{ restart_preference }"
      puts '=============================================================================='
      get_download_preference
    else
      puts '=============================================================================='
      puts "You have to tell what kind of server you'd like to restart, e.g."
      puts "rake ray:setup:restart server=mongrel"
      puts "rake ray:setup:restart server=passenger"
      puts '=============================================================================='
      exit
    end
  end

  def find_the_extension_to_install
    if @extension.length == 0
      puts '=============================================================================='
      puts "I couldn't find any extension matching '#{ @name }'"
      puts '=============================================================================='
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
      puts '=============================================================================='
      puts "There are more than one extensions that match #{ @name }"
      puts "Run the command appropriate to the extension you want to install."
      for j in 0...@extension.length
        nice_name = @extension[ j ].gsub( /radiant[-|_]/, "" ).gsub( /[-|_]extension/, "" )
        puts "rake ray:ext name=" + nice_name
      end
      exit
    end
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
      puts '=============================================================================='
      puts "The #{ extension } extension has been installed."
      puts "To disable it run: rake ray:dis name=#{ extension }"
      puts '=============================================================================='
    else
      puts '=============================================================================='
      puts "I couldn't find a tasks file for the #{ extension } extension."
      puts "Please manually verify the installation and restart the server."
      puts '=============================================================================='
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
      puts '=============================================================================='
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
      puts '=============================================================================='
      puts "I don't know how to restart #{ @restart_preference }."
      puts "You'll have to restart it manually."
      puts '=============================================================================='
    end
  end

  # shorthand
  desc "Install an extension."
  task :ext => ["extension:install"]

  desc "Search available extensions."
  task :search => ["extension:search"]

  desc "Disable an extension."
  task :dis => ["extension:disable"]
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
  # end
  # namespace :setup do
  #   task :initial do
  #     require "#{@task}/_setup.rb"
  #   end
  #   task :update do
  #     require "#{@task}/_setup_update.rb"
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
