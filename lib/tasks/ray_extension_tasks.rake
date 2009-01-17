namespace :ray do

  # shortcuts to commonly referred to internal paths
  @ray  = 'vendor/extensions/ray'
  @conf = "#{ @ray }/config"

  # @path can be overridden to enable installing extensions wherever
  # on the command line: path=/somewhere/else
  # from extensions.yml: @path = "/somewhere/else"
  @path = 'vendor/extensions' unless ENV[ 'path' ]

  # extension management tasks
  # @message and @error are passed to the complain_about_command_input method
  # when the validate_command_input decides the user input is bad
  # refer to individual methods for details
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
      pull_extension_remote
    end
    task :remote do
      @message = "You have to give me more information about the remote you want to add.\nThis command requires the name and remote options, try something like:"
      @example = "rake ray:extension:remote name=extension_name remote=user_name"
      validate_command_input
      add_extension_remote
    end
    task :bundle do
      extension_bundle_install
    end
    task :all do
      @show = true
      search_extensions
    end
  end

  # ray setup and configuration tasks
  namespace :setup do
    task :restart do
      @message = "You have to tell me what kind of server you're running"
      @example = 'rake ray:setup:restart server=[mongrel|passenger]'
      validate_command_input
      set_restart_preference
    end
    task :download do
      set_download_preference
    end
  end

  # shortcuts to the most common commands
  # namely these are what show up in rake -T ray
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
  desc 'Install a bundle of extensions.'
  task :bundle => ['extension:bundle']

end

# check validity of user input
def validate_command_input

  # unless we have one of these the command is DOA
  complain_about_command_input unless ENV[ 'term' ] or ENV[ 'name' ] or ENV[ 'server' ] or ENV[ 'remote' ]

  # with the remote option make sure there was an extension named
  if ENV[ 'remote' ]
    @remote = ENV[ 'remote' ]
    complain_about_command_input unless ENV[ 'name' ]
  end

  # setup variables for ray:search, ray:setup:restart and ray:ext input
  if ENV[ 'term' ]
    @term = ENV[ 'term' ]
  elsif ENV[ 'server' ]
    @pref = ENV[ 'server' ]
  else
    @term = ENV[ 'name' ]
    @name = @term.gsub( /_/, '-' )
    @dir  = @name.gsub( /-/, '_' )
  end

  # catch the url=public switch
  @public = true if ENV[ 'url' ]

end

# run when validate_command_input decides user input is bad
def complain_about_command_input

  # uses @message and @error defined in the task to help the user get it right
  puts '=============================================================================='
  print "#{ @message }\n#{ @example }\n"
  puts '=============================================================================='

  exit

end

# check that we have a download preference
def check_download_preference

  # if we don't have a preference, set it
  set_download_preference unless File.exist?( "#{ @conf }/download.txt" )

  # if we do have a preference, get it
  get_download_preference

end

# writes a new download preference file
def set_download_preference

  # run git_check to determine the preference
  git_check

  # here we just write the results returned from git_check
  require 'ftools'

  File.makedirs( "#{ @conf }" )
  File.open( "#{ @conf }/download.txt", 'w' ) { |preference| preference.puts @download }

  puts '=============================================================================='
  puts "Your download preference has been set to #{ @download }"

end

# determine the user's download preference
def git_check

  # a simple check to determine if git is available
  if system 'git --version'
    @download = 'git'
  else
    @download = 'http'
  end

end

# use check_download_preference if you want a valid download preference to use
def get_download_preference

  # read the contents of the download preference
  File.open( "#{ @conf }/download.txt", 'r' ) { |preference| @download = preference.gets }

end

# refer to the individual methods for more information
def prep_extension_install

  search_extensions
  determine_extension_to_install
  install_extension

end

# look in a local search file for extensions matching @name or @term
def search_extensions

  # if we don't have a local search file get one
  # TODO: implement get_search_cache method
  #       waiting on a GitHub API update
  puts "NOT IMPLEMENTED: get_search_cache" unless File.exist?( "#{ @ray }/search.yml" )

  cached_search

  # pass in the @show = true option to force search results
  # useful if you have an exact match but still want to see the results
  # internally @show is used to return a list of all available extensions
  if @show
    show_search_results
  end

end

# use search.yml to find extensions to manage
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
        extension = repository[ 'repositories' ][ i ][ 'name' ]
        # return a list of extensions
        if @name or @term # a filtered list
          extension_description = repository[ 'repositories' ][ i ][ 'description' ]
          unless @name; @name = @term; @show = true; end
          if extension.include?( @term ) or extension.include?( @name ) or extension_description.include?( @term ) or extension_description.include?( @name )
            @extension << extension
            source = repository[ 'repositories' ][ i ][ 'owner' ]
            @source << source
            http_url = repository[ 'repositories' ][ i ][ 'url' ]
            @http_url << http_url
            description = repository[ 'repositories' ][ i ][ 'description' ]
            @description << description
          end
        else # a complete list
          extension = repository[ 'repositories' ][ i ][ 'name' ]
          @extension << extension
          source = repository[ 'repositories' ][ i ][ 'owner' ]
          @source << source
          http_url = repository[ 'repositories' ][ i ][ 'url' ]
          @http_url << http_url
          description = repository[ 'repositories' ][ i ][ 'description' ]
          @description << description
        end
      end
    end
  end

end

# show the results of cached_search in a nice list
# note, you exit immediately after showing search results
def show_search_results

  puts '=============================================================================='

  # show a message when we can't find anything
  if @extension.length == 0
    puts "Your search term '#{ @term }' did not match any extensions."
    puts '=============================================================================='
    exit
  end

  # show a nicely formatted list of the extensions we can find
  i = 0
  while i < @extension.length
    ext_name = @extension[ i ].gsub( /radiant-/, '' ).gsub( /-extension/, '' )
    ext_desc = @description[ i ]
    ext_desc = ext_desc[ 0..61 ] + "..." if ext_desc.length > 64
    puts '  extension: ' + ext_name
    puts '     author: ' + @source[ i ]
    puts 'description: ' + ext_desc
    puts "    command: rake ray:ext name=#{ ext_name }"
    puts '=============================================================================='
    i += 1
  end

  exit

end

# uses the results of cached_search to decide which extension to install
def determine_extension_to_install

  # if there is only one extension to choose, choose it
  # returns with the @url variable so installation can proceed
  if @extension.length == 1
    @url = @http_url[ 0 ]
    return
  end

  # look for an exact in many near matches
  if @extension.include?( @name ) or @extension.include?( "radiant-#{ @name }-extension") # choose the exact match
    @extension.each do |e|
      ext_name = e.gsub( /radiant[-|_]/, '' ).gsub( /[-|_]extension/, '' )
      @url = @http_url[ @extension.index( e ) ]
      break if ext_name == @name
    end
  else # show a nicely formatted list of the extensions we can find
    puts '=============================================================================='
    puts "I couldn't find an extension named '#{ @name }'."
    puts "The following is a list of extensions that might be related."
    puts 'Use the command listed to install the appropriate extension.'
    show_search_results
  end

end

# decide which installation method to use
def install_extension

  if @download == "git\n"
    install_extension_with_git
  elsif @download == "http\n"
    install_extension_with_http
  else # whatever we found wasn't git or http
    fix_download_preference
  end

end

# install an extension with git
def install_extension_with_git

  # fix up the url we get back from the search
  @url.gsub!( /http/, 'git' )

  if ENV[ 'hub' ]
    @hub = ENV[ 'hub' ]
    @url.gsub!( /(.*github\.com[:|\/]).*(\/.*)/, "\\1#{ @hub }\\2" )
  end

  # unless the user specifically request the public clone url
  # compare the user = user in ~/.gitconfig to the clone url
  unless @public
    path = `echo ~`.gsub!( "\n", '' )
    if File.exist?( "#{ path }/.gitconfig" )
      File.readlines( "#{ path }/.gitconfig" ).map do |l|
        line = l.rstrip
        if line.include? 'user = '
          me = line.gsub(/\tuser\ =\ /, '')
          origin = @url.gsub(/git:\/\/github.com\/(.*)\/.*/, "\\1")
          @url.gsub!(/git:\/\/github.com\/(.*\/.*)/, "git@github.com:\\1") if me == origin
        end
      end
    end
  end

  # checkout the requested repository
  if File.exist?( '.git/HEAD' )
    system "git submodule -q add #{ @url }.git #{ @path }/#{ @dir }"
  else
    system "git clone -q #{ @url }.git #{ @path }/#{ @dir }"
  end

end

# install extensions with http when git is unavailable
def install_extension_with_http

  require 'net/http'

  # download a tarball
  @url = URI.parse( "#{ @url }/tarball/master" )

  found = false
  until found
    host, port = @url.host, @url.port if @url.host && @url.port
    github_request = Net::HTTP::Get.new( @url.path )
    github_response = Net::HTTP.start( host, port ) { |http| http.request( github_request ) }
    github_response.header[ 'location' ] ? @url = URI.parse( github_response.header[ 'location' ] ) :
    found = true
  end

  # write the tarball to a temp file
  open( "#{ @ray }/tmp/#{ @dir }.tar.gz", "wb") { |f| f.write( github_response.body ) }

  # expand and remove the tarball
  Dir.chdir( "#{ @ray }/tmp" ) do
    system "tar xzvf #{ @dir }.tar.gz"
    system "rm *.tar.gz"
  end

  # install the extension from the expanded tarball
  system "mv #{ @ray }/tmp/* #{ @path }/#{ @dir }"

end

# fix up a broken download preference file
def fix_download_preference

  require 'ftools'

  # delete the offending file immediately
  File.delete( "#{ @conf }/download.txt" )

  puts '=============================================================================='
  puts 'Your download preference is broken.'
  puts 'The broken preference file has been deleted.'

  set_download_preference
  get_download_preference
  prep_extension_install

end

# refer to individual methods for more information
def post_extension_install

  validate_extension_directory

  # if 'remote' is used with ray:ext add and pull the requested remote
  # do it first in case the remote changed submodules, dependencies or tasks
  if ENV[ 'remote' ]
    @remote = ENV[ 'remote' ]
    add_extension_remote
    pull_extension_remote
  end

  check_extension_submodules
  check_extension_dependencies
  check_extension_tasks
  attempt_server_restart

end

# check the source for the extensions definitive name and
# relocate_extension_to_proper_dir if it's not in the definitive directory
def validate_extension_directory

  # a simple way to check if an extension is in the proper directory
  unless File.exist?( "#{ @path }/#{ @dir }/#{ @dir }_extension.rb" )
    path = Regexp.escape( @path )
    @vendor_name = `ls #{ @path }/#{ @dir }/*_extension.rb`.gsub( /#{ path }\/#{ @dir }\//, "").gsub( /_extension.rb/, "").gsub( /\n/, "")
    relocate_extension_to_proper_dir
  end

  @vendor_name = @dir

end

# moves an extension and deals with moved submodules if needed
def relocate_extension_to_proper_dir

  # move an extension into it's definitely named directory
  move( "#{ @path }/#{ @dir }", "#{ @path }/#{ @vendor_name }" )

  # reset_git_submodule does the dirty work
  if File.exist?( '.gitmodules' )
    reset_git_submodule
  end

  @dir = @vendor_name

end

# reset and re-add a submodule after relocating it
def reset_git_submodule

  # re-write where git wants an extension to be
  File.open( ".gitmodules", "r+" ) do |f|
    dir = f.read.gsub( "#{ @path }/#{ @dir }", "#{ @path }/#{ @vendor_name }" )
    f.rewind
    f.puts( dir )
  end

  # force the index to be re-written
  system "git reset HEAD #{ @path }/#{ @dir }"
  system "git add #{ @path }/#{ @vendor_name }"

end

# check an extension for any included submodules
def check_extension_submodules

  if File.exist?( "#{ @path }/#{ @vendor_name }/.gitmodules" )
    get_extension_submodules
    install_extension_submodule
  end

end

# read submodules from extension_name/.gitmodules
def get_extension_submodules

  @module_name = []
  @module_path = []

  # builds an array of names and an array of paths
  File.readlines( "#{ @path }/#{ @vendor_name }/.gitmodules" ).map do |l|
    line = l.rstrip
    if line.include? 'url'
      module_name = line.gsub(/\turl\ =\ /, '')
      @module_name << module_name
    end
    if line.include? 'path'
      module_path = line.gsub(/\tpath\ =\ /, '')
      @module_path << module_path
    end
  end

end

# uses the arrays from get_extension_submodules
def install_extension_submodule

  # install submodules
  i = 0
  while i < @module_name.length
    if File.exist?( '.gitmodules' )
      system "git submodule add #{ @module_name[ i ] } #{ @module_path[ i ] }"
    else
      system "git clone #{ @module_name[ i ] } #{ @module_path[ i ] }"
    end
    i += 1
  end

end

# check an extension for any included dependencies
def check_extension_dependencies

  if File.exist?( "#{ @path }/#{ @vendor_name }/dependency.yml" )
    get_extension_dependencies
    install_extension_dependency
  end

end

# read dependencies from extension_name/dependency.yml
def get_extension_dependencies

  # builds an array of extension and gem dependencies
  # and plugins but that gets replaced by a "not support" message
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

# uses the arrays from get_extension_dependencies
def install_extension_dependency

  # call installers for the necessary dependencies
  install_extension_extension_dependency if @depend_ext.length > 0
  install_extension_gem_dependency if @depend_gem.length > 0
  install_extension_plugin_dependency if @depend_plug.length > 0

end

# install extension dependencies
def install_extension_extension_dependency

  # just passes the requested extensions back through ray
  @depend_ext.each { |e| system "rake ray:ext name=#{ e }" }

end

# install gem dependencies
def install_extension_gem_dependency

  puts '=============================================================================='
  puts "The #{ @vendor_name } extension requires one or more gems."
  puts 'YOU MAY BE PROMPTED FOR YOU SYSTEM ADMINISTRATOR PASSWORD!'

  @depend_gem.each do |g|
    system "sudo gem install #{ g }"
  end

end

# not supported
def install_extension_plugin_dependency

  puts '=============================================================================='
  puts 'Plugin dependencies are not yet supported by Ray.'
  puts 'Consider adding plugins as git submodules, which are supported by Ray.'
  puts "If you're not the extension author consider contacting them about this issue."

  @depend_plug.each do |p|
    puts "The #{ @vendor_name } extension requires the #{ p } plugin,"
    puts "but I don't support plugin dependencies."
    puts "Please install the #{ p } plugin manually."
  end

end

# figure out which extension rake task(s) to run
def check_extension_tasks

  rake_file = `ls #{ @path }/#{ @vendor_name }/lib/tasks/*_tasks.rake`.gsub( /\n/, '' )

  if rake_file
    @rake_tasks = []
    File.readlines( "#{ rake_file }" ).map do |l|
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

# run the methods appropriate for the extension rake tasks
# the uninstall_extension method uses the @uninstall instance variable
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

# use an extension install rake task to install the extension
def run_extension_install_task

  system "rake radiant:extensions:#{ @vendor_name }:install"

end

# run an extension migrate rake task
def run_extension_migrate_task

  system "rake radiant:extensions:#{ @vendor_name }:migrate"

end

# run an extension update rake task
def run_extension_update_task

  system "rake radiant:extensions:#{ @vendor_name }:update"

end

# check if there is any server to try restarting
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

# figure out what kind of server we're restarting
# or complain about not knowing how to restart
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

# restart a mongrel cluster
# TODO: restart single mongrels or a cluster
#       low priority, just use passenger or a mongrel_cluster
def restart_mongrel

  system 'mongrel_rails cluster::restart'
  puts 'Mongrel cluster has been restarted.'
  puts '=============================================================================='

end

# restart passenger
def restart_passenger

  tmp = Dir.open( 'tmp' ) rescue nil

  Dir.new( 'tmp' ) unless tmp
  File.new( 'tmp/restart.txt', 'w' )

  puts 'Passenger has been restarted.'
  puts '=============================================================================='

end

# move an extension into the disabled_extensions directory
def disable_extension

  unless File.exist?( "#{ @path }/#{ @dir }" )
    puts '=============================================================================='
    puts "The #{ @dir } extension does not appear to be installed."
    puts '=============================================================================='
    exit
  end

  Dir.mkdir( "#{ @ray }/disabled_extensions" ) unless File.exist?( "#{ @ray }/disabled_extensions" )

  system "mv #{ @path }/#{ @dir } #{ @ray }/disabled_extensions/#{ @dir }"

  puts '=============================================================================='
  puts "The #{ @dir } extension has been disabled. You can enable it by running"
  puts "rake ray:en name=#{ @dir }"
  puts '=============================================================================='

  attempt_server_restart

end

# move an extension from the disabled_extensions directory back into use
def extension_enable

  unless File.exist?( "#{ @ray }/disabled_extensions/#{ @dir }" )
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

# completely uninstall and remove an extension
# TODO: what to do with plugins added by the extension being uninstalled?
def uninstall_extension

  unless File.exist?( "#{ @path }/#{ @dir }" )
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

# someday maybe authors will include uninstall tasks
def run_extension_uninstall_task

  system "rake radiant:extensions:#{ @dir }:uninstall"

end

# reverse extension migrations
def run_extension_unmigrate_task

  system "rake radiant:extensions:#{ @dir }:migrate VERSION=0"

end

# look in an extension's public directory and try to
# match those files to ones in public/* – matches are deleted
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

# create a restart preference
def set_restart_preference

  require 'ftools'

  unless @pref == 'mongrel' or @pref == 'passenger'
    puts '=============================================================================='
    puts "I don't know how to restart #{ @pref }."
    puts 'Your preference has not been saved.'
    puts "'mongrel' and 'passenger' are the only kinds of servers I can restart."
    puts '=============================================================================='
    exit
  end

  Dir.mkdir( "#{ @conf }" ) unless File.exist?( "#{ @conf }" )

  File.open( "#{ @conf }/restart.txt", 'w' ) { |p| p.puts @pref }

  puts '=============================================================================='
  puts "Your restart preference has been set to #{ @pref }"
  puts '=============================================================================='

end

# add a remote to an installed extension
def add_extension_remote

  search_extensions
  determine_extension_to_install

  @url.gsub!( /http/, 'git' ).gsub!( /(git:\/\/github.com\/).*(\/.*)/, '\1' + @remote + '\2' )

  Dir.chdir( "#{ @path }/#{ @dir }" ) do
    system "git remote add #{ @remote } #{ @url }.git"
    system "git fetch #{ @remote }"
    branches = `git branch -a`.split("\n")
    @new_branch = []
    branches.each do |branch|
      branch.strip!
      @new_branch << branch if branch.include?( @remote )
      @current_branch = branch.gsub!( /\*\ /, '' ) if branch.include?( '* ' )
    end
    @new_branch.each do |branch|
      system "git checkout -b #{ branch } #{ branch }"
    end
    system "git checkout #{ @current_branch }"
  end

  puts '=============================================================================='
  puts "All of #{ @remote }'s branches have been pulled into local branches."
  puts 'Use your normal git workflow to inspect and merge these branches.'
  puts '=============================================================================='

end

# pull remotes on an extension
def pull_extension_remote

  @name = ENV[ 'name' ] if ENV[ 'name' ]

  if @name
    @pull_branch = []
    Dir.chdir( "#{ @path }/#{ @name }" ) do
      branches = `git branch`.split( "\n" )
      branches.each do |branch|
        branch.strip!
        @pull_branch << branch if branch.include?( '/' )
        @current_branch = branch.gsub!( /\*\ /, '' ) if branch.include?( '* ' )
      end
      @pull_branch.each do |branch|
        system "git checkout #{ branch }"
        system "git pull #{ branch.gsub( /(.*)\/.*/, "\\1") } #{ branch.gsub( /.*\/(.*)/, "\\1") }"
      end
      system "git checkout #{ @current_branch }"
    end
    puts '=============================================================================='
    puts "Updated all remote branches of the #{ @name } extension."
    puts 'Use your normal git workflow to inspect and merge these branches.'
    puts '=============================================================================='
  else
    extensions = @name ? @name.gsub( /\-/, '_' ) : Dir.entries( @path ) - [ '.', '..' ]
    extensions.each do |extension|
      Dir.chdir( "#{ @path }/#{ extension }" ) do
        @pull_branch = []
        branches = `git branch`.split( "\n" )
        branches.each do |branch|
          branch.strip!
          @pull_branch << branch if branch.include?( '/' )
          @current_branch = branch.gsub!( /\*\ /, '' ) if branch.include?( '* ' )
        end
        unless @pull_branch.length == 0
          @pull_branch.each do |branch|
            system "git checkout #{ branch }"
            system "git pull #{ branch.gsub( /(.*)\/.*/, "\\1") } #{ branch.gsub( /.*\/(.*)/, "\\1") }"
            system "git checkout #{ @current_branch }"
          end
        end
      end
    end
  end

end

# uses config/extensions.yml to batch install extensions
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
        name = extension[ i ][ 'name' ]
        options = []
        options << " hub=" + extension[ i ][ 'hub' ] if extension[ i ][ 'hub' ]
        options << " remote=" + extension[ i ][ 'remote' ] if extension[ i ][ 'remote' ]
        options << " lib=" + extension[ i ][ 'lib' ] if extension[ i ][ 'lib' ]
        system "rake ray:ext name=#{ name }#{ options }"
      end
    end
  end

end

# prints friendly messages in place of harmless error messages
namespace :radiant do

  namespace :extensions do
    namespace :ray do
      task :migrate do
        puts "Ray doesn't have any migrations to run."
      end
      task :update do
        puts "Ray doesn't have any static assets to copy."
      end
    end
  end

end
