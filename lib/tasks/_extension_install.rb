def install_extension_git
  require "#{@task}/_extension_install_git.rb"
end
def install_extension_http
  require "#{@task}/_extension_install_http.rb"
end

if ENV['path']
  @path = ENV['path']
end

if @name.nil? && ENV['name'].nil?
  puts "=============================================================================="
  puts "You have to tell me which extension to install."
  puts "Try something like: rake ray:ext name=extension_name"
  puts "=============================================================================="
else
  if ENV['name']
    @name = ENV['name']
  end
  begin
    Dir.open(@path)
  rescue
    puts "=============================================================================="
    puts "For some reason you don't have a #{@path} directory."
    puts "I'm going to make it for you so we can get on with installing extensions."
    mkdir_p @path
    puts "=============================================================================="
  end
  if File.exists?("#{@conf}/download.txt") == false
    puts "=============================================================================="
    puts "Looks like you haven't setup your preferred download method."
    puts "Let's get that setup now..."
    require "#{@task}/_setup_download_preference.rb"
    puts "With that out of the way try that command again."
    puts "=============================================================================="
  else
    download_conf = File.open("#{@conf}/download.txt", "r")
    download_pref = download_conf.gets
    download_conf.close
    if download_pref == "git\n"
      case
      when ENV['fullname']
        @fullname = ENV['fullname']
        if ENV['hub']
          @hub = ENV['hub']
          install_extension_git
        else
          puts "=============================================================================="
          puts "You have to tell which GitHub user has the extension you want to install."
          puts "Try something like: rake ray:ext name=nice-ext hub=bob fullname=bo-bo"
          puts "=============================================================================="
        end
      when ENV['hub']
        @hub = ENV['hub']
        if ENV['fullname']
          @fullname = ENV['fullname']
          install_extension_git
        else
          install_extension_git
        end
      else
        install_extension_git
      end
    elsif download_pref == "http\n"
      install_extension_http
      restart
    else
      puts "=============================================================================="
      puts "Your download preference is broken."
      puts "Please run: rake ray:git"
      puts "=============================================================================="
    end
  end
end
