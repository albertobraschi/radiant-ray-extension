namespace :ray do
  require 'ftools'
  require 'yaml'
  @path = "vendor/extensions"
  @ray  = "#{@path}/ray"
  @conf = "#{@ray}/config"
  namespace :extension do
    task :install do
      message = 'The install command requires an extension name.'
      example = 'rake ray:extension:install name=extension_name'
      required_options = [ENV['name']]
      validate_command(message, example, required_options)
      install_extension
    end
    task :search do
      message = 'The search command requires a search term.'
      example = 'rake ray:extension:search term=search_term'
      required_options = [ENV['term']]
      validate_command(message, example, required_options)
      search_extensions
      search_results
    end
    task :disable do
      message = 'The disable command requires an extension name.'
      example = 'rake ray:extension:disable name=extension_name'
      required_options = [ENV['name']]
      validate_command(message, example, required_options)
      disable_extension
    end
    task :enable do
      message = 'The enable command requires an extension name.'
      example = 'rake ray:extension:enable name=extension_name'
      required_options = [ENV['name']]
      validate_command(message, example, required_options)
      enable_extension
    end
    task :uninstall do
      message = 'The remove command requires an extension name.'
      example = 'rake ray:extension:remove name=extension_name'
      required_options = [ENV['name']]
      validate_command(message, example, required_options)
      uninstall_extension
    end
    task :pull do
      require_git
      pull_remote
    end
    task :remote do
      require_git
      message = 'The remote command requires an extension name and a GitHub username.'
      example = 'rake ray:extension:remote name=extension_name remote=user_name'
      required_options = [ENV['name'], ENV['remote']]
      validate_command(message, example, required_options)
      add_remote
    end
    task :bundle do
      install_extension_bundle
    end
    task :all do
      search_extensions
      search_results
    end
    task :update do
      update_extension
    end
  end
  namespace :setup do
    task :restart do
      message = "I need to know the type of server you'd like auto-restarted."
      example = "rake ray:setup:restart server=mongrel\nrake ray:setup:restart server=passenger"
      required_options = [ENV['server']]
      validate_command(message, example, required_options)
      set_restart_preference
    end
    task :download do
      set_download_preference
    end
  end
end
def validate_command(message, example, required_options)
  required_options.each do |option|
    unless option
      output(message, example)
      exit
    end
  end
end
def output(message, example)
  puts('================================================================================')
  print "#{message}\n#{example}\n"
  puts('================================================================================')
end
def install_extension
  @name = ENV['name']
  get_download_preference
  search_extensions
  choose_extension_to_install
  git_extension_install if @download == "git"
  http_extension_install if @download == "http"
  set_download_preference if @download != "git" and @download != "http"
  validate_extension_location
  check_rake_tasks
  message = "The #{@name} extension has been installed successfully."
  example = "Disable it with: rake ray:dis name=#{@name}"
  output(message, example)
  restart_server
end
def get_download_preference
  begin
    File.open("#{@conf}/download.txt", 'r') {|f| @download = f.gets.strip!}
  rescue
    set_download_preference
  end
end
def search_extensions
  @name = ENV['name'] if ENV['name']
  @term = ENV['term'] if ENV['term']
  @extension = []
  @source = []
  @http_url = []
  @description = []
  if File.exist?("#{@ray}/search.yml")
    cached_search
  else
    online_search
  end
end
def cached_search
  File.open("#{@ray}/search.yml") do |repositories|
    YAML.load_documents(repositories) do |repository|
      for i in 0...repository['repositories'].length
        extension = repository['repositories'][i]['name']
        if @name or @term
          extension_description = repository['repositories'][i]['description']
          if @name
            @term = @name
          elsif @term
            @name = @term
          end
          if extension.include?(@term) or extension.include?(@name) or extension_description.include?(@term) or extension_description.include?(@name)
            @extension << extension
            @source << repository['repositories'][i]['owner']
            @http_url << repository['repositories'][i]['url']
            @description << extension_description
          end
        else
          @extension << extension
          @source << repository['repositories'][i]['owner']
          @http_url << repository['repositories'][i]['url']
          @description << repository['repositories'][i]['description']
        end
      end
    end
  end
end
def choose_extension_to_install
  if @extension.length == 1
    @url = @http_url[0]
    return
  end
  if @extension.include?(@name) or @extension.include?("radiant-#{@name}-extension")
    @extension.each do |e|
      ext_name = e.gsub(/radiant[-|_]/, '').gsub(/[-|_]extension/, '')
      @url = @http_url[@extension.index(e)]
      break if ext_name == @name
    end
  else
    message = "I couldn't find an extension named '#{@name}'."
    example = "The following is a list of extensions that might be related.\nUse the command listed to install the appropriate extension."
    output(message, example)
    search_results
  end
end
def git_extension_install
  @url.gsub!(/http/, 'git')
  if ENV['hub']
    @hub = ENV['hub']
    @url.gsub!(/(.*github\.com[:|\/]).*(\/.*)/, "\\1#{ @hub }\\2")
  end
  # check if the user is cloning their own repo and switch to ssh
  unless ENV['public']
    path = `echo ~`.gsub!("\n", '')
    if File.exist?("#{path}/.gitconfig")
      File.readlines("#{path}/.gitconfig").map do |f|
        line = f.rstrip
        if line.include? 'user = '
          me = line.gsub(/\tuser\ =\ /, '')
          origin = @url.gsub(/git:\/\/github.com\/(.*)\/.*/, "\\1")
          @url.gsub!(/git:\/\/github.com\/(.*\/.*)/, "git@github.com:\\1") if me == origin
        end
      end
    end
  end
  if File.exist?('.git/HEAD')
    sh("git submodule add #{@url}.git #{@path}/#{@name}")
  else
    sh("git clone #{@url}.git #{@path}/#{@name}")
  end
  check_submodules
  check_dependencies
end
def http_extension_install
  require 'net/http'
  @url = URI.parse("#{@url}/tarball/master")
  found = false
  until found
    host, port = @url.host, @url.port if @url.host && @url.port
    github_request = Net::HTTP::Get.new(@url.path)
    github_response = Net::HTTP.start(host, port) {|http| http.request(github_request)}
    github_response.header['location'] ? @url = URI.parse(github_response.header['location']) :
    found = true
  end
  File.makedirs("#{@ray}/tmp")
  open("#{@ray}/tmp/#{@name}.tar.gz", "wb") {|f| f.write(github_response.body)}
  Dir.chdir("#{@ray}/tmp") do
    begin
      sh("tar xzvf #{@name}.tar.gz")
    rescue Exception
      rm("#{@name}.tar.gz")
      message = "The #{@name} extension archive is not decompressing properly."
      example = 'You can usually fix this by simply running the command again.'
      output(message, example)
      exit
    end
    rm("#{@name}.tar.gz")
  end
  # puts "mv #{@ray}/tmp/* #{@path}/#{@name}"; exit
  sh("mv #{@ray}/tmp/* #{@path}/#{@name}")
  check_submodules
  check_dependencies
end
def check_submodules
  if File.exist?("#{@path}/#{@name}/.gitmodules")
    submodules = []
    File.readlines("#{@path}/#{@name}/.gitmodules").map do |f|
      line = f.rstrip
      submodules << line.gsub(/\turl\ =\ /, '') if line.include? 'url = '
    end
    install_submodules(submodules)
  end
end
def check_dependencies
  if File.exist?("#{@path}/#{@name}/dependency.yml")
    File.open("#{@path}/#{@name}/dependency.yml" ) do |dependence|
      YAML.load_documents(dependence) do |dependency|
        total = dependency.length - 1
        @extensions = []
        @gems = []
        @plugins = []
        for i in 0..total do
          @extensions << dependency[i]['extension'] if dependency[i].include?('extension')
          @gems << dependency[i]['gem'] if dependency[i].include?('gem')
          @plugins << dependency[ i ][ 'plugin' ] if dependency[ i ].include?( 'plugin' )
        end
      end
    end
    install_dependencies
  end
end
def install_dependencies
  if @extensions.length > 0
    @extensions.each {|e| system "rake ray:extension:install name=#{e}"}
  end
  if @gems.length > 0
    message = "The #{@name} extension requires one or more gems."
    example = 'YOU MAY BE PROMPTED FOR YOU SYSTEM ADMINISTRATOR PASSWORD!'
    output(message, example)
    @gems.each do |g|
      sh("sudo gem install #{g}")
    end
  end
  if @plugins.length > 0
    message = "Plugin dependencies are not yet supported by Ray.\nConsider adding plugins as git submodules, which are supported by Ray."
    example = "If you're not the extension author consider contacting them about this issue."
    output(message, example)
    @plugins.each do |p|
      message = "The #{@name} extension requires the #{p} plugin,\nbut I don't support plugin dependencies."
      example = "Please install the #{p} plugin manually."
      output(message, example)
    end
  end
end
def install_submodules(submodules)
  get_download_preference
  if @download == "git"
    if File.exist?('.git/HEAD')
      submodules.each do |submodule|
        sh("git submodule add #{submodule} vendor/plugins/#{submodule.gsub!(/(git:\/\/github.com\/.*\/)(.*)(.git)/, "\\2")}")
      end
    else
      submodules.each do |submodule|
        sh("git clone #{submodule} vendor/plugins/#{submodule.gsub!(/(git:\/\/github.com\/.*\/)(.*)(.git)/, "\\2")}")
      end
    end
  elsif @download == "http"
    submodules.each do |submodule|
      submodule.gsub!(/(git:)(\/\/github.com\/.*\/.*)(.git)/, "http:\\2/tarball/master")
      url = URI.parse("#{submodule}")
      found = false
      until found
        host, port = url.host, url.port if url.host && url.port
        github_request = Net::HTTP::Get.new(url.path)
        github_response = Net::HTTP.start(host, port) {|http| http.request(github_request)}
        github_response.header['location'] ? url = URI.parse(github_response.header['location']) :
        found = true
      end
      File.makedirs("#{@ray}/tmp")
      submodule.gsub!(/http:\/\/github.com\/.*\/(.*)\/tarball\/master/, "\\1")
      open("#{@ray}/tmp/#{submodule}.tar.gz", "wb") {|f| f.write(github_response.body)}
      Dir.chdir("#{@ray}/tmp") do
        begin
          sh("tar xzvf #{submodule}.tar.gz")
        rescue Exception
          rm("#{submodule}.tar.gz")
          message = "The #{submodule} extension archive is not decompressing properly."
          example = 'You can usually fix this by simply running the command again.'
          output(message, example)
          exit
        end
        rm("#{submodule}.tar.gz")
      end
      sh("mv #{@ray}/tmp/* vendor/plugins/#{submodule}")
    end
  else
    message = 'Your download preference is broken.'
    example = 'Please run, `rake ray:setup:download` to repair it.'
    output(message, example)
  end
end
def validate_extension_location
  @extension = @extension[0].to_s
  @extension.gsub!(/(radiant-)(.*)(-extension)/, "\\2")
  unless File.exist?("#{@path}/#{@extension}/#{@extension}_extension.rb")
    path = Regexp.escape(@path)
    @name = `ls #{@path}/#{@extension}/*_extension.rb`.gsub(/#{path}\/#{@extension}\//, "").gsub(/_extension.rb/, "").gsub(/\n/, "") rescue nil
    move_extension
  end
end
def check_rake_tasks
  rake_file = `ls #{@path}/#{@name}/lib/tasks/*_tasks.rake`.gsub(/\n/, '')
  if rake_file
    @rake_tasks = []
    File.readlines("#{rake_file}").map do |f|
      line = f.rstrip
      @rake_tasks << 'install' if line.include? 'task :install =>'
      @rake_tasks << 'migrate' if line.include? 'task :migrate =>'
      @rake_tasks << 'update' if line.include? 'task :update =>'
      @rake_tasks << 'uninstall' if line.include? 'task :uninstall =>'
    end
    if @uninstall
      run_uninstall_tasks
    else
      run_rake_tasks
    end
  else
    puts("The #{@name} extension has no task file.")
  end
end
def run_rake_tasks
  if @rake_tasks.empty?
    puts("The #{@name} extension has no tasks to run.")
  else
    if @rake_tasks.include?('install')
      begin
        sh("rake #{RAILS_ENV} radiant:extensions:#{@name}:install")
        puts('Install task ran successfully.')
      rescue Exception => err
        cause = 'install'
        quarantine_extension(cause, err)
      end
    else
      if @rake_tasks.include?('migrate')
        begin
          sh("rake #{RAILS_ENV} radiant:extensions:#{@name}:migrate")
          puts('Migrate task ran successfully.')
        rescue Exception => err
          cause = 'migrate'
          quarantine_extension(cause, err)
        end
      end
      if @rake_tasks.include?('update')
        begin
          sh("rake #{RAILS_ENV} radiant:extensions:#{@name}:update")
          puts('Update task ran successfully.')
        rescue Exception => err
          cause = 'update'
          quarantine_extension(cause, err)
        end
      end
    end
  end
end
def run_uninstall_tasks
  if @rake_tasks.empty?
    puts("The #{@name} extension has no tasks to run.")
  else
    if @rake_tasks.include?('uninstall')
      begin
        sh("rake #{RAILS_ENV} radiant:extensions:#{@name}:uninstall")
        puts('Uninstall task ran successfully.')
      rescue Exception
        message = "The #{@name} extension failed to uninstall properly.\nPlease uninstall the extension manually."
        example = "rake radiant:extensions:#{@name}:migrate VERSION=0\nThen remove any associated files and directories."
        output(message, example)
        exit
      end
    else
      if @rake_tasks.include?('migrate')
        begin
          sh("rake #{RAILS_ENV} radiant:extensions:#{@name}:migrate VERSION=0")
          puts('Migrated to VERSION=0 successfully.')
        rescue Exception
          message = "The #{@name} extension failed to uninstall properly.\nPlease uninstall the extension manually."
          example = "rake radiant:extensions:#{@name}:migrate VERSION=0\nThen remove any associated files and directories."
          output(message, example)
          exit
        end
      end
      # do a simple search to find files to remove, misses are frequent
      if @rake_tasks.include?('update')
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
        message = "I tried to delete assets associated with the #{@name} extension,\nbut may have missed some while trying not to delete anything accidentally."
        example = "You may want manually clean up your public directory after an uninstall."
        output(message, example)
      end
    end
  end
end
def restart_server
  begin
    File.open("#{@conf}/restart.txt", 'r') {|f| @server = f.gets.strip!}
  rescue
    message = 'You need to restart your server or set a restart preference.'
    example = "rake ray:setup:restart server=mongrel\nrake ray:setup:restart server=passenger"
    output(message, example)
    exit
  end
  if @server == "passenger"
    File.makedirs('tmp')
    File.open('tmp/restart.txt', 'w') {|f|}
    puts('Passenger restarted.')
  elsif @server == "mongrel"
    sh('mongrel_rails cluster::restart')
    puts('Mongrel cluster restarted.')
  else
    message = 'Your restart preference is broken. Use the appropriate command to repair it.'
    example = "rake ray:setup:restart server=mongrel\nrake ray:setup:restart server=passenger"
    output(message, example)
  end
end
def move_extension
  move("#{@path}/#{@extension}", "#{@path}/#{@name}")
end
def quarantine_extension(cause, err)
  File.makedirs("#{@ray}/disabled_extensions")
  rm_r("#{@ray}/disabled_extensions/#{@name}") rescue nil
  move("#{@path}/#{@name}", "#{@ray}/disabled_extensions/#{@name}")
  message = "The #{@name} extension failed to install properly.\nAs a result I have canceled the installation and placed the extension in:\n#{@ray}/disabled_extensions/#{@name}"
  example = "For more detailed error output try the command:\nrake radiant:extensions:#{@name}:#{cause} --trace"
  output(message, example)
  print "\nERROR:\n#{err}\n"
  exit
end
def disable_extension
  extension = ENV['name']
  unless File.exist?("#{@path}/#{extension}")
    message = "The #{extension} extension does not appear to be installed."
    example = "You can try installing it with: rake ray:ext name=#{extension}"
    output(message, example)
    exit
  end
  File.makedirs("#{@ray}/disabled_extensions")
  rm_r("#{@ray}/disabled_extensions/#{extension}") rescue nil
  move( "#{@path}/#{extension}", "#{@ray}/disabled_extensions/#{extension}")
  message = "The #{extension} extension has been disabled."
  example = "To enable it run, rake ray:en name=#{extension}"
  output(message, example)
  restart_server
end
def enable_extension
  extension = ENV[ 'name' ]
  unless File.exist?("#{@ray}/disabled_extensions/#{extension}")
    message = "The #{extension} extension was not disabled by Ray."
    example = "You can try installing it with: rake ray:ext name=#{extension}"
    output(message, example)
    exit
  end
  move("#{@ray}/disabled_extensions/#{extension}", "#{@path}/#{extension}")
  message = "The #{extension} extension has been enabled."
  example = "To disable it run, rake ray:dis name=#{extension}"
  output(message, example)
  restart_server
end
def search_results
  puts('================================================================================')
  if @extension.length == 0
    puts("Your search term '#{@term}' did not match any extensions.")
    puts('================================================================================')
    exit
  end
  for i in 0...@extension.length
    name = @extension[i].gsub(/radiant-/, '').gsub(/-extension/, '')
    description = @description[i]
    description = description[0..63] + "..." if description.length >= 63
    puts('  extension: ' + name)
    puts('     author: ' + @source[i])
    puts('description: ' + description)
    puts("    command: rake ray:ext name=#{name}")
    puts('================================================================================')
  end
  exit
end
def set_download_preference
  File.makedirs("#{@conf}")
  begin
    sh("git --version")
    @download = "git"
  rescue
    @download = "http"
  end
  File.open("#{@conf}/download.txt", 'w') {|f| f.puts(@download)}
  puts("Your download preference has been set to #{@download}.")
end
def set_restart_preference
  File.makedirs("#{@conf}")
  preference = ENV['server']
  if preference == 'mongrel' or preference == 'passenger'
    File.open("#{@conf}/restart.txt", 'w') {|f| f.puts(preference)}
    message = "Your restart preference has been set to #{preference}."
    example = "Now I'll auto-restart your server whenever necessary."
    output(message, example)
  else
    message = "I don't know how to restart #{ preference }.\nOnly Mongrel clusters and Phusion Passenger are currently supported.\nRun one of the following commands:"
    example = "rake ray:setup:restart server=mongrel\nrake ray:setup:restart server=passenger"
    output(message, example)
  end
end
def uninstall_extension
  @uninstall = true
  @name = ENV['name']
  check_rake_tasks
  message = "The #{@name} extension has been uninstalled. To install it run:"
  example = "rake ray:ext name=#{@name}"
  output(message, example)
end
def add_remote
  # get an @url to work with
  search_extensions
  choose_extension_to_install
  # fix up the @url for the requested user
  @url.gsub!(/http/, 'git').gsub!(/(git:\/\/github.com\/).*(\/.*)/, "\\1" + @remote + "\\2")
  Dir.chdir("#{@path}/#{@name}") do
    sh("git remote add #{@remote} #{@url}.git")
    sh("git fetch #{@remote}")
    # find new user's branches
    branches = `git branch -a`.split("\n")
    @new_branch = []
    branches.each do |branch|
      branch.strip!
      @new_branch << branch if branch.include?(@remote)
      # store the current branch so we can return to it later
      @current_branch = branch.gsub!(/\*\ /, '') if branch.include?('* ')
    end
    # checkout user's branches
    @new_branch.each do |branch|
      sh("git checkout -b #{branch} #{branch}")
      # return to the branch we started on
      sh("git checkout #{@current_branch}")
    end
  end
  message = "All of #{@remote}'s branches have been pulled into local branches."
  example = 'Use your normal git workflow to inspect and merge these branches.'
  output(message, example)
end
def pull_remote
  @name = ENV['name'] if ENV[ 'name' ]
  # pull remotes on a single extension
  if @name
    @pull_branch = []
    Dir.chdir("#{@path}/#{@name}") do
      branches = `git branch`.split("\n")
      branches.each do |branch|
        branch.strip!
        @pull_branch << branch if branch.include?('/')
        @current_branch = branch.gsub!(/\*\ /, '') if branch.include?('* ')
      end
      @pull_branch.each do |branch|
        sh("git checkout #{branch}")
        sh("git pull #{branch.gsub(/(.*)\/.*/, "\\1")} #{branch.gsub(/.*\/(.*)/, "\\1")}")
      end
      sh("git checkout #{@current_branch}")
    end
    message = "Updated all remote branches of the #{@name} extension."
    example = 'Use your normal git workflow to inspect and merge these branches.'
    output(message, example)
  # pull remotes on all extensions with remotes
  else
    extensions = @name ? @name.gsub(/\-/, '_') : Dir.entries(@path) - ['.', '.DS_Store', '..']
    extensions.each do |extension|
      Dir.chdir("#{@path}/#{extension}") do
        @pull_branch = []
        branches = `git branch`.split("\n")
        branches.each do |branch|
          branch.strip!
          @pull_branch << branch if branch.include?('/')
          @current_branch = branch.gsub!(/\*\ /, '') if branch.include?('* ')
        end
        unless @pull_branch.length == 0
          @pull_branch.each do |branch|
            sh("git checkout #{branch}")
            sh("git pull #{branch.gsub(/(.*)\/.*/, "\\1")} #{branch.gsub(/.*\/(.*)/, "\\1")}")
            sh("git checkout #{@current_branch}")
          end
        end
      end
    end
    message = "Updated all remote branches of all extensions with remote branches."
    example = 'Use your normal git workflow to inspect and merge these branches.'
    output(message, example)
  end
end
def require_git
  get_download_preference
  unless @download == "git"
    message = "This commands requires git."
    example = "Refer to http://git-scm.com/ for installation instructions."
    output(message, example)
    exit
  end
end
def install_extension_bundle
  unless File.exist?('config/extensions.yml')
    message = "You don't seem to have a bundle file available.\nRefer to the documentation for more information on extension bundles."
    example = 'http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-bundle'
    output(message, example)
    exit
  end
  File.open('config/extensions.yml') do |bundle|
    # load up a yaml file and send the contents back into ray for installation
    YAML.load_documents(bundle) do |extension|
      total = extension.length - 1
      for i in 0..total do
        name = extension[i]['name']
        options = []
        options << " hub=" + extension[i]['hub'] if extension[i]['hub']
        options << " remote=" + extension[i]['remote'] if extension[i]['remote']
        options << " lib=" + extension[i]['lib'] if extension[i]['lib']
        sh("rake ray:extension:install name=#{name}#{options}")
      end
    end
  end
end
def update_extension
  @name = ENV['name'] if ENV['name']
  # update all extensions, except ray
  if @name == 'all'
    get_download_preference
    # update extensions with git
    if @download == "git"
      extensions = Dir.entries(@path) - ['.', '.DS_Store', 'ray', '..']
      extensions.each do |extension|
        Dir.chdir("#{@path}/#{extension}") do
          sh("git pull origin master")
          puts("#{extension} extension updated.")
        end
      end
    # update extensions with http
    elsif
      extensions = Dir.entries(@path) - ['.', '.DS_Store', 'ray', '..']
      extensions.each do |extension|
        Dir.chdir("#{@path}/#{extension}") do
          sh("rake ray:extension:disable name=#{extension}")
          sh("rake ray:extension:install name=#{extension}")
          puts("#{extension} extension updated.")
        end
      end
    else
      message = 'Your download preference is broken.'
      example = 'Please run, `rake ray:setup:download` to repair it.'
      output(message, example)
    end
  # update a single extension
  elsif @name
    get_download_preference
    # update extension with git
    if @download == "git"
      sh("cd #{@path}/#{@name}; git pull origin master; cd ../../..")
      puts("#{@name} extension updated.")
    # update extension with http
    elsif @download == "http"
      sh("rake ray:extension:disable name=#{@name}")
      sh("rake ray:extension:install name=#{@name}")
      puts("#{@name} extension updated.")
    else
      message = 'Your download preference is broken.'
      example = 'Please run, `rake ray:setup:download` to repair it.'
      output(message, example)
    end
  # update ray
  else
    get_download_preference
    # update ray with git
    if @download == "git"
      sh("cd #{@path}/ray; git pull origin master; cd ../../..")
      puts("Ray extension updated.")
    # can't update ray with http since scripts would get moved while running
    elsif @download == "http\n"
      puts("Ray can only update itself with git.")
    else
      message = 'Your download preference is broken.'
      example = 'Please run, `rake ray:setup:download` to repair it.'
      output(message, example)
    end
  end
end
def online_search
  puts("Online searching is not implemented.") # TODO: implement online_search
end
namespace :radiant do
  namespace :extensions do
    namespace :ray do
      task :migrate do
        puts("Ray doesn't have any migrate tasks to run.")
      end
      task :update do
        puts("Ray doesn't have any static assets to copy.")
      end
    end
  end
end
