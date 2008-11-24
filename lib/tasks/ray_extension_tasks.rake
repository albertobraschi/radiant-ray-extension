namespace :ray do
  @ray  = 'vendor/extensions/ray'
  @conf = "#{ @ray }/config"
  unless ENV[ 'path' ]
    @path = 'vendor/extensions'
  end

  namespace :extension do
    task :install do
      @message = 'You have to tell me which extension to install, e.g.'
      @example = 'rake ray:ext name=extension_name'
      check_command_input
      check_download_preference
      extension_installation
      extension_post_install
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
      extension_disable
    end
    task :enable do
      @message = 'You have to tell me which extension to enable, e.g.'
      @example = 'rake ray:en name=extension_name'
      check_command_input
      extension_enable
    end
    task :remove do
      @message = 'You have to tell me which extension to uninstall, e.g.'
      @example = 'rake ray:rm name=extension_name'
      check_command_input
      extension_uninstall
    end
    task :pull do
      @message = 'You have to tell me which extension to pull, e.g.'
      @example = 'rake ray:pull name=extension_name'
      check_command_input
      extension_pull
    end
    task :bundle do
      puts "Bundle installation not yet implemented."
    end
  end

  namespace :setup do
    task :restart do
      restart_preference_setup
    end
    task :download do
      download_preference_setup
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
    if File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
      @proper_dir = @dir
    else
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
    dependencies = []
    if File.exist?( "#{ @path }/#{ @proper_dir }/dependency.yml" )
      File.open( "#{ @path }/#{ @proper_dir }/dependency.yml" ) do |dependence|
        YAML.load_documents( dependence ) do |dependency|
          total = dependency.length - 1
          for count in 0..total do
            if dependency[count].include? 'extension'
              system "rake ray:ext name=#{ dependency[count]['extension'] }"
            end
            if dependency[count].include? 'gem'
              puts "=============================================================================="
              puts "The #{ @proper_dir } extension requires the #{ dependency[count]['gem'] } gem."
              puts "You may be prompted to enter your system administrator password."
              system "sudo gem install #{ dependency[count]['gem'] }"
            end
            if dependency[count].include? 'plugin'
              system "./script/plugin install #{ dependency[count]['plugin'] }"
            end
          end
        end
      end
    end
    puts dependencies
    exit
  end
  def check_extension_tasks
    if File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
      @proper_dir = @dir
    else
      @path_regexp = Regexp.escape( @path )
      @proper_dir = `ls #{ @path }/#{ @dir }/*_extension.rb`.gsub( /#{ @path_regexp }\/#{ @dir }\//, "").gsub( /_extension.rb/, "").gsub( /\n/, "")
    end
    rake_file = `ls #{ @path }/#{ @proper_dir }/lib/tasks/*_extension_tasks.rake`.gsub( /\n/, "")
    @tasks = []
    f = File.readlines( "#{ rake_file }" ).map do |l|
      line = l.rstrip
      if line.include? ':install'
        @tasks << 'install'
      end
      if line.include? ':uninstall'
        @tasks << 'uninstall'
      end
      if line.include? ':migrate'
        @tasks << 'migrate'
      end
      if line.include? ':update'
        @tasks << 'update'
      end
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
      return
    end
    if @extension.include?( @name ) or @extension.include?( "radiant-#{ @name }-extension")
      @extension.each do |e|
        ext_name = e.gsub( /radiant[-|_]/, '' ).gsub( /[-|_]extension/, '' )
        @url = @http_url[ @extension.index( e ) ]
        break if ext_name == @name
      end
    else
      puts '=============================================================================='
      puts "No extension exactly matched - #{ @name } - be more specific."
      puts "Use the command listed to install the extension you want."
      search_results
    end
  end
  def extension_post_install
    check_extension_tasks
    extension_run_tasks
    restart_server
  end
  def extension_run_tasks
    if @tasks.length == 0
      puts '=============================================================================='
      puts "I couldn't find a tasks file for the #{ extension } extension."
      puts 'Please manually verify the installation and restart the server.'
      puts '=============================================================================='
      exit
    else
      @tasks.each do |task|
        system "rake radiant:extensions:#{ @proper_dir }:#{ task }"
      end
      puts '=============================================================================='
      puts "The #{ @proper_dir } extension has been installed."
      puts "To disable it run: rake ray:dis name=#{ @proper_dir }"
      puts '=============================================================================='
    end
  end
  def extension_run_tasks_uninstall
    if @tasks.length == 0
      puts '=============================================================================='
      puts "I couldn't find a tasks file for the #{ extension } extension."
      puts 'Please manually uninstall the extension and restart the server.'
      puts '=============================================================================='
      exit
    else
      if @tasks.include? 'uninstall'
        system "rake radiant:extensions:#{ @proper_dir }:uninstall"
        return
      end
      if @tasks.include? 'migrate'
        system "rake radiant:extensions:#{ @proper_dir }:migrate VERSION=0"
      end
      if @tasks.include? 'update'
        extension_remove_assets
      end
    end
  end
  def extension_disable
    extension = Dir.open( "#{ @path }/#{ @dir }" ) rescue nil
    unless extension
      puts '=============================================================================='
      puts "The #{ @name } extension does not appear to be installed."
      puts '=============================================================================='
      exit
    end
    disabled = Dir.open( "#{ @ray }/disabled_extensions" ) rescue nil
    unless disabled
      system "mkdir #{ @ray }/disabled_extensions"
    end
    system "mv #{ @path }/#{ @dir } #{ @ray }/disabled_extensions/#{ @dir }"
    puts '=============================================================================='
    puts "The #{ @name } extension has been disabled. You can enable it by running"
    puts "rake ray:en name=#{ @dir }"
    puts '=============================================================================='
    restart_server
  end
  def extension_enable
    extension = Dir.open( "#{ @ray }/disabled_extensions/#{ @dir }" ) rescue nil
    unless extension
      puts '=============================================================================='
      puts "The #{ @name } extension is not available for enabling."
      puts "If you'd like to install it instead, use the following command,"
      puts "rake ray:ext name=#{ @name }"
      puts '=============================================================================='
      exit
    end
    system "mv #{ @ray }/disabled_extensions/#{ @dir } #{ @path }/#{ @dir }"
    puts '=============================================================================='
    puts "The #{ @name } extension has been enabled. You can disable it by running"
    puts "rake ray:dis name=#{ @dir }"
    puts '=============================================================================='
    restart_server
  end
  def extension_uninstall
    extension = Dir.open( "#{ @path }/#{ @dir }" ) rescue nil
    unless extension
      puts '=============================================================================='
      puts "The #{ @name } extension does not appear to be installed."
      puts '=============================================================================='
      exit
    end
    removed = Dir.open( "#{ @ray }/removed_extensions" ) rescue nil
    unless removed
      system "mkdir #{ @ray }/removed_extensions"
    end
    check_extension_tasks
    extension_run_tasks_uninstall
    system "mv #{ @path }/#{ @proper_dir } #{ @ray }/removed_extensions/#{ @proper_dir }"
    rm_r "#{ @ray }/removed_extensions/#{ @proper_dir }"
    puts '=============================================================================='
    puts "The #{ @name } extension has been uninstalled. You can install it by running"
    puts "rake ray:ext name=#{ @proper_dir }"
    puts '=============================================================================='
    restart_server
  end
  def extension_remove_assets
    require 'find'
    files = []
    Find.find( "#{ @path }/#{ @proper_dir }/public" ) { |file| files << file }
    files.each do |f|
      if f.include?( '.' )
        unless f.include?( '.DS_Store' )
          file = f.gsub( /#{ @path }\/#{ @proper_dir }\/public/, 'public' )
          rm "#{ file }" rescue nil
        end
      end
    end
  end
  def extension_pull
    Dir.chdir("#{ @path }/#{ @dir }") do
      config = File.open( '.git/config', 'r' )
      while ( line = config.gets )
        if line =~ /remote \"([a-zA-Z0-9]+)\"/
          unless $1 == 'origin'
            system "git checkout master"
            system "git pull #{ $1 } master"
            puts "=============================================================================="
            puts "The changes from hub #{ $1 } have been pulled into the #{ @dir } extension"
            puts "=============================================================================="
          end
        end
      end
    end
  end
  def extension_bundle_install
    puts "bundle install"
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
          unless @name; @name = @term; end
          if extension.include?( @term ) or extension.include?( @name )
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
      ext_name = @extension[ i ].gsub( /radiant-/, '' ).gsub( /-extension/, '' )
      puts "  extension: #{ ext_name }"
      puts '     author: ' + @source[ i ]
      puts 'description: ' + @description[ i ]
      puts "    command: rake ray:ext name=#{ ext_name }"
      puts '=============================================================================='
      i += 1
    end
    exit
  end

  def restart_server
    if File.exist?( "#{ @conf }/restart.txt" )
      restart_preference_read
    else
      puts "You need to restart your server."
      puts "If you want me to auto-restart the server you need to set your preference."
      puts "Try: rake ray:setup:restart server=passenger"
      puts "Or:  rake ray:setup:restart server=mongrel"
      puts '=============================================================================='
      exit
    end
    if @restart == "passenger\n"
      tmp = Dir.open( "tmp" ) rescue nil
      unless tmp
        system "mkdir tmp"
      end
      system "touch tmp/restart.txt"
      puts "Passenger has been restarted."
      puts '=============================================================================='
    elsif @restart == "mongrel\n"
      system "mongrel_rails cluster::restart"
      puts "Mongrel has been restarted."
      puts '=============================================================================='
    else
      puts '=============================================================================='
      puts "I don't know how to restart #{ @restart }."
      puts "You'll have to restart it manually."
      puts '=============================================================================='
    end    
  end
  def restart_preference_read
    File.open( "#{ @conf }/restart.txt", "r" ) do |p|
      @restart = p.gets
    end
  end
  def restart_preference_setup
    require "ftools"
    if ENV[ "server" ]
      pref = ENV[ "server" ]
      File.makedirs( "#{ @conf }" )
      File.open( "#{ @conf }/restart.txt", "w" ) do |p|
        p.puts pref
      end
      puts '=============================================================================='
      puts "Your restart preference has been set to #{ pref }"
      puts '=============================================================================='
    else
      puts '=============================================================================='
      puts "You have to tell what kind of server you'd like to restart, e.g."
      puts "rake ray:setup:restart server=mongrel"
      puts "rake ray:setup:restart server=passenger"
      puts '=============================================================================='
      exit
    end
  end

  # shorthand
  desc "Install an extension."
  task :ext => ["extension:install"]

  desc "Search available extensions."
  task :search => ["extension:search"]

  desc "Disable an extension."
  task :dis => ["extension:disable"]

  desc "Enable an extension."
  task :en => ["extension:enable"]

  desc "Uninstall an extension."
  task :rm => ["extension:remove"]

  desc "Merge all remotes of an extension."
  task :pull => ["extension:pull"]

  desc "Install a bundle of extensions."
  task :bundle => ["extension:bundle"]
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
