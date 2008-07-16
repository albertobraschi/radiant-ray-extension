namespace :ray do

  def setup_install
    system "touch config/ray.setup"
    system "git --version" rescue nil
    unless !$?.nil? && $?.success?
      puts "You don't have the `git` utilities installed and/or available in your path."
      puts "If you install `git` later simply run `rake ray:setup:install` again."
      puts "For now I'll be using the slower, less efficient HTTP fetch method."
      ray_setup = File.open("config/ray.setup", "w")
      ray_setup.puts "http"
    else
      system "rm config/ray.setup"
      system "touch config/ray.setup"
      ray_setup = File.open("config/ray.setup", "w")
      ray_setup.puts "git"
    end
    puts "I created a `config/ray.setup` file and set your preferred download method."
    puts "If you want to update it you can just run `rake ray:setup:install` again."
  end

  def restart_server
    if ENV['restart'].nil?
      puts "You should restart your server now. Try adding RESTART=mongrel_cluster or RESTART=passenger next time."
    else
      server = ENV['restart']
      if server == "mongrel_cluster"
        system "mongrel_rails cluster::restart"
        puts "Your mongrel_cluster has been restarted."
      elsif server == "passenger"
        system "touch tmp/restart.txt"
        puts "Your passengers have been restarted."
      else
        puts "I don't know how to restart #{ENV['restart']}. You'll need to restart your server manually."
      end
    end
  end

  def install_extension
    name = ENV['name']
    github_name = name.gsub(/\_/, "-")
    vendor_name = name.gsub(/\-/, "_")
    radiant_git = "git://github.com/radiant/"
    if ENV['hub'].nil?
      ext_repo = radiant_git
    else
      ext_repo = "git://github.com/#{ENV['hub']}/"
    end
    system "git clone #{ext_repo}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
    post_install_extension
  end

  def install_custom_extension
    name = ENV['name']
    vendor_name = name.gsub(/\-/, "_")
    ext_repo = "git://github.com/#{ENV['hub']}/"
    system "git clone #{ext_repo}/#{ENV['fullname']}.git vendor/extensions/#{vendor_name}"
    post_install_extension
  end

  def post_install_extension
    name = ENV['name']
    vendor_name = name.gsub(/\-/, "_")
    system "rake radiant:extensions:#{vendor_name}:migrate"
    system "rake radiant:extensions:#{vendor_name}:update"
    puts "The #{vendor_name} extension has been installed. Use the :disable command to disable it later."
  end

  namespace :setup do

    task :install do
      setup_install
    end

  end

  namespace :extension do

    desc "Install extensions from github. `name=extension_name` is required; if you specify `fullname` you must also specify `hub=github_user_name`. You can also use `hub=user` with the `name` option to install from outside the Radiant repository."
    task :install do
      setup_file = File.new("config/ray.setup", "r") rescue nil
      
      unless !$?.nil? && $?.success?
        setup_install
      end
      
      if ENV['name'].nil?
        puts "You have to tell me which extension to install. Try something like: rake ray:extension:install name=extension_name"
      else
        mkdir_p "vendor/extensions"
        ray_setup = setup_file.gets
        setup_file.close
        if ray_setup = "git"
          case
          when ENV['fullname']
            if ENV['hub'].nil?
              puts "You have to tell me which github user to get the extension from. Try something like: rake ray:extension:install fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
            else
              install_custom_extension
              restart_server
            end

          when ENV['hub']
            if ENV['fullname'].nil?
              install_extension
            else
              install_custom_extension
            end
            restart_server

          else
            install_extension
            restart_server
          end
        else
          puts "sad ol'http"
        end
      end

    end
    
  end

end