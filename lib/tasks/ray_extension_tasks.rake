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
      validate_command_input
      check_download_preference
      prep_extension_install
      post_extension_install
    end
    task :search do
      @message = 'You have to give me a term to search for, e.g.'
      @example = 'rake ray:search term=xyz'
      validate_command_input
      search_extensions
    end
    task :disable do
      @message = 'You have to tell me which extension to disable, e.g.'
      @example = 'rake ray:dis name=extension_name'
      validate_command_input
      disable_extension
    end
    task :enable do
      @message = 'You have to tell me which extension to enable, e.g.'
      @example = 'rake ray:en name=extension_name'
      validate_command_input
      extension_enable
    end
    task :remove do
      @message = 'You have to tell me which extension to uninstall, e.g.'
      @example = 'rake ray:rm name=extension_name'
      validate_command_input
      validate_extension_directory
      uninstall_extension
    end
    task :pull do
      @message = 'You have to tell me which extension to pull, e.g.'
      @example = 'rake ray:pull name=extension_name'
      validate_command_input
      extension_pull
    end
    task :bundle do
      extension_bundle_install
    end
    task :all do
      show_all_extensions
    end
  end

  namespace :setup do
    task :restart do
      restart_preference_setup
    end
    task :download do
      set_download_preference
    end
  end

  desc 'Install an extension.'
  task :ext => ['extension:install']

  desc 'Search available extensions.'
  task :search => ['extension:search']

  desc 'Disable an extension.'
  task :dis => ['extension:disable']

  desc 'Enable an extension.'
  task :en => ['extension:enable']

  desc 'Uninstall an extension.'
  task :rm => ['extension:remove']

  desc 'Merge all remotes of an extension.'
  task :pull => ['extension:pull']

  desc 'Install a bundle of extensions.'
  task :bundle => ['extension:bundle']
end

def validate_command_input
  unless ENV[ 'term' ] or ENV[ 'name' ]
    complain_about_command_input
    exit
  end
  if ENV[ 'term' ]
    @term = ENV[ 'term' ]
  else
    @term = ENV[ 'name' ]
    @name = @term.gsub( /_/, '-' )
    @dir  = @name.gsub( /-/, '_' )
  end
end
def complain_about_command_input
  puts '=============================================================================='
  print "#{ @message }\n#{ @example }\n"
  puts '=============================================================================='
  exit
end
def check_download_preference
  unless File.exist?( "#{ @conf }/download.txt" )
    set_download_preference
  end
  get_download_preference
end
def set_download_preference
  git_check
  require 'ftools'
  File.makedirs( "#{ @conf }" )
  File.open( "#{ @conf }/download.txt", 'w' ) { |d| d.puts @download }
  puts '=============================================================================='
  puts "Your download preference has been set to #{ @download }"
end
def git_check
  if system 'git --version'
    @download = 'git'
  else
    @download = 'http'
  end
end
def get_download_preference
  File.open( "#{ @conf }/download.txt", 'r' ) { |d| @download = d.gets }
end
def prep_extension_install
  search_extensions
  determine_extension_to_install
  install_extension
end
def search_extensions
  unless File.exist?( "#{ @ray }/search.yml" )
    get_search_cache
  end
  cached_search
  if @show
    show_search_results
  end
end
def cached_search
  require 'yaml'
  @extension = []
  @source = []
  @http_url = []
  @description = []
  File.open( "#{ @ray }/search.yml" ) do |repositories|
    YAML.load_documents( repositories ) do |repository|
      total = repository[ 'repositories' ].length
      for i in 0...total
        extension = repository[ 'repositories' ][i][ 'name' ]
        if @name or @term
          # return filtered results
          extension_description = repository[ 'repositories' ][i][ 'description' ]
          unless @name; @name = @term; @show = true; end
          if extension.include?( @term ) or extension.include?( @name ) or extension_description.include?( @term ) or extension_description.include?( @name )
            @extension << extension
            source = repository[ 'repositories' ][i][ 'owner' ]
            @source << source
            http_url = repository[ 'repositories' ][i][ 'url' ]
            @http_url << http_url
            description = repository[ 'repositories' ][i][ 'description' ]
            @description << description
          end
        else
          # return all results
          extension = repository[ 'repositories' ][i][ 'name' ]
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
def show_search_results
  puts '=============================================================================='
  if @extension.length == 0
    puts "Your search term '#{ @term }' did not match any extensions."
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
def determine_extension_to_install
  # only one extension to choose from
  if @extension.length == 1
    @url = @http_url[0]
    return
  end
  # choose an exact match from multiple options
  if @extension.include?( @name ) or @extension.include?( "radiant-#{ @name }-extension")
    @extension.each do |e|
      ext_name = e.gsub( /radiant[-|_]/, '' ).gsub( /[-|_]extension/, '' )
      @url = @http_url[ @extension.index( e ) ]
      break if ext_name == @name
    end
  else
    puts '=============================================================================='
    puts "I couldn't find an extension named '#{ @name }'."
    puts "The following is a list of extensions that might be related."
    puts 'Use the command listed to install the appropriate extension.'
    show_search_results
  end
end
def install_extension
  if @download == "git\n"
    install_extension_with_git
  elsif @download == "http\n"
    install_extension_with_http
  else
    fix_download_preference
  end
end
def install_extension_with_git
  @url = @url.gsub( /http/, 'git' )
  if File.exist?( '.git/HEAD' )
    system "git submodule -q add #{ @url }.git #{ @path }/#{ @dir }"
  else
    system "git clone -q #{ @url }.git #{ @path }/#{ @dir }"
  end
end
def install_extension_with_http
  puts 'TODO: HTTP extension installation method is not yet implemented.'
end
def fix_download_preference
  require 'ftools'
  File.delete( "#{ @conf }/download.txt" )
  puts '=============================================================================='
  puts 'Your download preference is broken.'
  puts 'The broken preference file has been deleted.'
  set_download_preference
  get_download_preference
  prep_extension_install
end
def post_extension_install
  validate_extension_directory
  check_extension_submodules
  check_extension_dependencies
  check_extension_tasks
  attempt_server_restart
end
def validate_extension_directory
  unless File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
    path = Regexp.escape( @path )
    @vendor_name = `ls #{ @path }/#{ @dir }/*_extension.rb`.gsub( /#{ path }\/#{ @dir }\//, "").gsub( /_extension.rb/, "").gsub( /\n/, "")
    relocate_extension_to_proper_dir
  end
  @vendor_name = @dir
end
def relocate_extension_to_proper_dir
  move( "#{ @path }/#{ @dir }", "#{ @path }/#{ @vendor_name }" )
  if File.exist?( '.gitmodules' )
    reset_git_submodule
  end
  @dir = @vendor_name
end
def reset_git_submodule
  File.open( ".gitmodules", "r+" ) do |f|
    dir = f.read.gsub( "#{ @path }/#{ @dir }", "#{ @path }/#{ @vendor_name }" )
    f.rewind
    f.puts( dir )
  end
  system "git reset HEAD #{ @path }/#{ @dir }"
  system "git add #{ @path }/#{ @vendor_name }"
end
def check_extension_submodules
  if File.exist?( "#{ @path }/#{ @vendor_name }/.gitmodules" )
    get_extension_submodules
    install_extension_submodule
  end
end
def get_extension_submodules
  @module_name = []
  @module_path = []
  f = File.readlines( "#{ @path }/#{ @vendor_name }/.gitmodules" ).map do |l|
    line = l.rstrip
    if line.include? 'url'
      mn = line.gsub(/\turl\ =\ /, '')
      @module_name << mn
    end
    if line.include? 'path'
      mp = line.gsub(/\tpath\ =\ /, '')
      @module_path << mp
    end
  end  
end
def install_extension_submodule
  i = 0
  while i < @module_name.length
    if File.exist?( '.gitmodules' )
      system "git submodule add #{ @module_name[ i ] } #{ @module_path[ i ] }"
    else
      system "git clone #{ @module_name[ i ] } #{ @module_path[ i ] }"
    end
    i =+ 1
  end
end
def check_extension_dependencies
  if File.exist?( "#{ @path }/#{ @vendor_name }/dependency.yml" )
    get_extension_dependencies
    install_extension_dependency
  end
end
def get_extension_dependencies
  File.open( "#{ @path }/#{ @vendor_name }/dependency.yml" ) do |dependence|
    YAML.load_documents( dependence ) do |dependency|
      total = dependency.length - 1
      @depend_ext  = []
      @depend_gem  = []
      @depend_plug = []
      for i in 0..total do
        if dependency[ i ].include?( 'extension' )
          @depend_ext << dependency[ i ][ 'extension' ]
        end
        if dependency[ i ].include?( 'gem' )
          @depend_gem << dependency[ i ][ 'gem' ]
        end
        if dependency[ i ].include?( 'plugin' )
          @depend_plug << dependency[ i ][ 'plugin' ]
        end
      end
    end
  end
end
def install_extension_dependency
  if @depend_ext.length > 0
    install_extension_extension_dependency
  end
  if @depend_gem.length > 0
    install_extension_gem_dependency
  end
  if @depend_plug.length > 0
    install_extension_plugin_dependency
  end
end
def install_extension_extension_dependency
  @depend_ext.each { |e| system "rake ray:ext name=#{ e }" }
end
def install_extension_gem_dependency
  puts '=============================================================================='
  puts "The #{ @vendor_name } extension requires one or more gems."
  puts 'YOU MAY BE PROMPTED FOR YOU SYSTEM ADMINISTRATOR PASSWORD!'
  @depend_gem.each do |g|
    system "sudo gem install #{ g }"
  end
end
def install_extension_plugin_dependency
  puts '=============================================================================='
  puts 'Plugin dependencies are not yet supported by Ray.'
  puts 'Consider adding plugins as git submodules, which are supported by Ray.'
  @depend_plug.each do |p|
    puts "The #{ @vendor_name } extension requires the #{ p } plugin,"
    puts "but I don't really support plugin dependencies."
    puts "Please install the #{ p } plugin manually."
  end
end
def check_extension_tasks
  rake_file = `ls #{ @path }/#{ @vendor_name }/lib/tasks/*_tasks.rake`.gsub( /\n/, '' )
  if rake_file
    @rake_tasks = []
    f = File.readlines( "#{ rake_file }" ).map do |l|
      line = l.rstrip
      if @uninstall
        if line.include? 'task :uninstall =>'
          @rake_tasks << 'uninstall'
        end
      else
        if line.include? 'task :install =>'
          @rake_tasks << 'install'
        end
      end
      if line.include? 'task :migrate =>'
        @rake_tasks << 'migrate'
      end
      if line.include? 'task :update =>'
        @rake_tasks << 'update'
      end
    end
    run_extension_task
  end
end
def run_extension_task
  if @rake_tasks.empty?
    if @uninstall
      puts '=============================================================================='
      puts "The #{ @vendor_name } extension has been uninstalled successfully."
      puts "However, I can't tell from it's rake file what tasks I'm supposed to undo."
      puts "This could mean the extension doesn't have any tasks to undo,"
      puts "or that I'm just not smart enough to figure out what they are."
      puts 'Please manually verify the uninstallation and restart the server.'
      puts '=============================================================================='
      exit
    else
      puts '=============================================================================='
      puts "The #{ @vendor_name } extension has been installed successfully."
      puts "However, I can't tell from it's rake file what tasks I'm supposed to run."
      puts "This could mean the extension doesn't have any tasks to run,"
      puts "or that I'm just not smart enough to figure out what they are."
      puts 'Please manually verify the installation and restart the server.'
      puts '=============================================================================='
      exit
    end
  else
    if @uninstall
      if @rake_tasks.include?( 'uninstall' )
        run_extension_uninstall_task
      else
        if @rake_tasks.include?( 'migrate' )
          run_extension_unmigrate_task
        end
        if @rake_tasks.include?( 'update' )
          run_extension_unupdate_task
        end
      end
      puts '=============================================================================='
      puts "The #{ @vendor_name } extension has been uninstalled."
      puts "I tried to delete assets associated with the #{ @vendor_name } extension,"
      puts 'but may have missed some while trying not to delete anything accidentally.'
      puts 'You may want manually clean up your public directory after an uninstall.'
      puts '=============================================================================='
    else
      if @rake_tasks.include?( 'install' )
        run_extension_install_task
      else
        if @rake_tasks.include?( 'migrate' )
          run_extension_migrate_task
        end
        if @rake_tasks.include?( 'update' )
          run_extension_update_task
        end
      end
      puts '=============================================================================='
      puts "The #{ @vendor_name } extension has been installed successfully."
      puts "To disable it run: rake ray:dis name=#{ @vendor_name }"
      puts '=============================================================================='
    end
  end
end
def run_extension_install_task
  system "rake radiant:extensions:#{ @vendor_name }:install"
end
def run_extension_migrate_task
  system "rake radiant:extensions:#{ @vendor_name }:migrate"
end
def run_extension_update_task
  system "rake radiant:extensions:#{ @vendor_name }:update"
end
def attempt_server_restart
  unless File.exist?( "#{ @conf }/restart.txt" )
    puts 'You need to restart your server.'
    puts "Tell me what kind of server you have I'll auto-restart it for you."
    puts 'Use the appropriate command to setup auto-restart.'
    puts 'rake ray:setup:restart server=passenger'
    puts 'rake ray:setup:restart server=mongrel'
    puts '=============================================================================='
    exit
  end
  get_restart_preference
end
def get_restart_preference
  File.open( "#{ @conf }/restart.txt", 'r' ) { |r| @restart = r.gets }
  if @restart == "mongrel\n"
    restart_mongrel
  elsif @restart == "passenger\n"
    restart_passenger
  else
    puts "I don't know how to restart #{ @restart }."
    puts "You'll have to restart it manually."
    puts '=============================================================================='
  end
end
def restart_mongrel
  system 'mongrel_rails cluster::restart'
  puts 'Mongrel cluster has been restarted.'
  puts '=============================================================================='
end
def restart_passenger
  tmp = Dir.open( 'tmp' ) rescue nil
  unless tmp
    Dir.new( 'tmp' )
  end
  File.new( 'tmp/restart.txt' )
  puts 'Passenger has been restarted.'
  puts '=============================================================================='
end
def disable_extension
  unless Dir.open( "#{ @path }/#{ @dir }" )
    puts '=============================================================================='
    puts "The #{ @dir } extension does not appear to be installed."
    puts '=============================================================================='
    exit
  end
  unless File.exist?( "#{ @ray }/disabled_extensions" )
    Dir.mkdir( "#{ @ray }/disabled_extensions" )
  end
  system "mv #{ @path }/#{ @dir } #{ @ray }/disabled_extensions/#{ @dir }"
  puts '=============================================================================='
  puts "The #{ @dir } extension has been disabled. You can enable it by running"
  puts "rake ray:en name=#{ @dir }"
  puts '=============================================================================='
  attempt_server_restart
end
def extension_enable
  unless Dir.open( "#{ @ray }/disabled_extensions/#{ @dir }" )
    puts '=============================================================================='
    puts "I've never disabled the #{ @dir } extension."
    puts "If you'd like to install it use the following command,"
    puts "rake ray:ext name=#{ @dir }"
    puts '=============================================================================='
    exit
  end
  system "mv #{ @ray }/disabled_extensions/#{ @dir } #{ @path }/#{ @dir }"
  puts '=============================================================================='
  puts "The #{ @dir } extension has been enabled. You can disable it by running"
  puts "rake ray:dis name=#{ @dir }"
  puts '=============================================================================='
  attempt_server_restart
end
def uninstall_extension
  unless Dir.open( "#{ @path }/#{ @dir }" )
    puts '=============================================================================='
    puts "The #{ @dir } extension does not appear to be installed."
    puts '=============================================================================='
    exit
  end
  unless File.exist?( "#{ @ray }/removed_extensions" )
    Dir.mkdir( "#{ @ray }/removed_extensions" )
  end
  @uninstall = true
  check_extension_tasks
  system "mv #{ @path }/#{ @dir } #{ @ray }/removed_extensions/#{ @dir }"
  rm_r "#{ @ray }/removed_extensions/#{ @dir }"
  attempt_server_restart
end
def run_extension_uninstall_task
  system "rake radiant:extensions:#{ @dir }:uninstall"
end
def run_extension_unmigrate_task
  system "rake radiant:extensions:#{ @dir }:migrate VERSION=0"
end
def run_extension_unupdate_task
  require 'find'
  files = []
  Find.find( "#{ @path }/#{ @dir }/public" ) { |file| files << file }
  files.each do |f|
    if f.include?( '.' )
      unless f.include?( '.DS_Store' )
        file = f.gsub( /#{ @path }\/#{ @dir }\/public/, 'public' )
        File.delete( "#{ file }" ) rescue nil
      end
    end
  end
end


def extension_pull
  Dir.chdir( "#{ @path }/#{ @proper_dir }" ) do
    config = File.open( '.git/config', 'r' )
    while ( line = config.gets )
      if line =~ /remote \"([a-zA-Z0-9]+)\"/
        unless $1 == 'origin'
          system 'git checkout master'
          system "git pull #{ $1 } master"
          puts '=============================================================================='
          puts "The changes from hub #{ $1 } have been pulled into the #{ vendor_name } extension"
          puts '=============================================================================='
        end
      end
    end
  end
end
def extension_bundle_install
  require 'yaml'
  unless File.exist?( 'config/extensions.yml' )
    puts '=============================================================================='
    puts "You don't seem to have a bundle file available."
    puts 'Refer to the documentation for more information on extension bundles.'
    puts 'http://johnmuhl.com/workbook/ray#bundle'
    puts '=============================================================================='
    exit
  end
  system "mkdir -p #{ @ray }/tmp"
  File.open( 'config/extensions.yml' ) do |bundle|
    YAML.load_documents( bundle ) do |extension|
      total = extension.length - 1
      for i in 0..total do
        
      end
      # for count in 0..total do
      #   name = extension[ count ][ 'name' ]
      #   installer = File.open( "#{ @ray }/tmp/#{ name }_extension_install.rb", 'a' )
      #   installer.puts "\@name\ \=\ \"#{ name }\""
      #   if extension[ count ][ 'fullname' ]
      #     fullname = extension[ count ][ 'fullname' ]
      #     installer.puts "\@fullname\ \=\ \"#{ fullname }\""
      #   end
      #   if extension[ count ][ 'hub' ]
      #     hub = extension[ count ][ 'hub' ]
      #     installer.puts "\@hub\ \=\ \"#{ hub }\""
      #   end
      #   if extension[ count ][ 'lib' ]
      #     lib = extension[ count ][ 'lib' ]
      #     installer.puts "\@lib\ \=\ \"#{ lib }\""
      #   end
      #   if extension[ count ][ 'remote' ]
      #     remote = extension[ count ][ 'remote' ]
      #     installer.puts "\@remote\ \=\ \"#{ remote }\""
      #   end
      #   if extension[ count ][ 'plugin' ]
      #     plugin = extension[ count ][ 'plugin' ]
      #     installer.puts "\@plugin\ \=\ \"#{ plugin }\""
      #   end
      #   if extension[ count ][ 'plugin_path' ]
      #     plugin_path = extension[ count ][ 'plugin_path' ]
      #     installer.puts "\@plugin_path\ \=\ \"#{ plugin_path }\""
      #   end
      #   if extension[ count ][ 'plugin_repository' ]
      #     plugin_repository = extension[ count][ 'plugin_repository' ]
      #     installer.puts "\@plugin_repository\ \=\ \"#{ plugin_repository }\""
      #   end
      #   if extension[ count ][ 'rake' ]
      #     rake = extension[ count ][ 'rake' ]
      #     installer.puts "\@rake\ \=\ \"#{ rake }\""
      #   end
      #   if extension[ count ][ 'vendor' ]
      #     vendor = extension[ count ][ 'vendor' ]
      #     installer.puts "\@vendor\ \=\ \"#{ vendor }\""
      #   end
      #   if extension[ count ][ 'path' ]
      #     path = extension[ count ][ 'path' ]
      #     installer.puts "\@path\ \=\ \"#{ path }\""
      #   else
      #     installer.puts "\@path\ \=\ \"vendor\/extensions\""
      #   end
      #   installer.puts "\@ray\ \=\ \"vendor\/extensions\/ray\""
      #   installer.puts "\@task\ \=\ \"\#\{ \@ray \}\/lib\/tasks\""
      #   installer.puts "\@conf\ \=\ \"\#\{ \@ray \}\/config\""
        # generic_install = File.read("#{@task}/_extension_install.rb")
        # installer.puts generic_install
        # installer.close
        # system "ruby #{@ray}/tmp/#{name}_extension_install.rb && rm #{@ray}/tmp/#{name}_extension_install.rb"
      # end
    end
    # system "rm -r #{@ray}/tmp"
  end
end


def restart_preference_setup
  require 'ftools'
  if ENV[ 'server' ]
    pref = ENV[ 'server' ]
    File.makedirs( "#{ @conf }" )
    File.open( "#{ @conf }/restart.txt", 'w' ) do |p|
      p.puts pref
    end
    puts '=============================================================================='
    puts "Your restart preference has been set to #{ pref }"
    puts '=============================================================================='
  else
    puts '=============================================================================='
    puts "You have to tell what kind of server you'd like to restart, e.g."
    puts 'rake ray:setup:restart server=mongrel'
    puts 'rake ray:setup:restart server=passenger'
    puts '=============================================================================='
    exit
  end
end

# supress faulty error messages
namespace :radiant do
  namespace :extensions do
    namespace :ray do
      task :migrate do
        puts 'No migrations necessary.'
      end
      task :update do
        puts 'No static assets to copy.'
      end
    end
  end
end
