namespace :ray do

  def setup_install
    system "touch config/ray.setup"
    system "git --version" rescue nil
    unless !$?.nil? && $?.success?
      puts "You don't have the `git` utilities installed and/or available in your path."
      puts "I created a `config/ray.setup` file and set your preferred download method."
      puts "For now I'll be using the slower, less efficient HTTP fetch method."
      puts "---"
      puts "If you install `git` later simply run `rake ray:setup:install`"
      ray_setup = File.open("config/ray.setup", "w")
      ray_setup.puts "http"
    else
      system "rm config/ray.setup"
      system "touch config/ray.setup"
      ray_setup = File.open("config/ray.setup", "w")
      ray_setup.puts "git"
      puts "I created a `config/ray.setup` file and set your preferred download method to `git`"
    end
    ray_setup.close
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

  def install_extension_http
    name = ENV['name']
    github_name = name.gsub(/\_/, "-")
    vendor_name = name.gsub(/\-/, "_")
    radiant_git = "http://github.com/radiant/"
    if ENV['hub'].nil?
      ext_repo = radiant_git
    else
      ext_repo = "http://github.com/#{ENV['hub']}/"
    end
    mkdir_p "vendor/extensions_tmp"
    system "cd vendor/extensions_tmp; wget #{ext_repo}radiant-#{github_name}-extension/tarball/master; tar xzvf *#{github_name}*.tar.gz; rm *.tar.gz"
    system "mv vendor/extensions_tmp/* vendor/extensions/#{vendor_name}"
    rm_rf "vendor/extensions_tmp"
    post_install_extension
  end
  
  def install_custom_extension_http
    name = ENV['name']
    vendor_name = name.gsub(/\-/, "_")
    ext_repo = "http://github.com/#{ENV['hub']}/"
    mkdir_p "vendor/extensions_tmp"
    system "cd vendor/extensions_tmp; wget #{ext_repo}#{ENV['fullname']}/tarball/master; tar xzvf *#{ENV['fullname']}*.tar.gz; rm *.tar.gz"
    system "mv vendor/extensions_tmp/* vendor/extensions/#{vendor_name}"
    rm_rf "vendor/extensions_tmp"
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
      setup_check = File.new("config/ray.setup", "r") rescue nil
      if setup_check == nil
        setup_install
      end
      
      if ENV['name'].nil?
        puts "You have to tell me which extension to install. Try something like: rake ray:extension:install name=extension_name"
      else
        setup_file = File.new("config/ray.setup", "r")
        ray_setup = setup_file.gets
        setup_file.close
        mkdir_p "vendor/extensions"
        if ray_setup == "git\n"
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
        elsif ray_setup == "http\n"
          case
          when ENV['fullname']
            if ENV['hub'].nil?
              puts "You have to tell me which github user to get the extension from. Try something like: rake ray:extension:install fullname=sweet-sauce-for-radiant hub=bob name=sweet-sauce"
            else
              install_custom_extension_http
              restart_server
            end
          
          when ENV['hub']
            if ENV['fullname'].nil?
              install_extension_http
            else
              install_custom_extension_http
            end
            restart_server

          else
            install_extension_http
            restart_server
          end
        end
        
      end

    end

    desc "enable extensions"
    task :enable do
      if ENV['name'].nil?
        puts "You have to tell me which extension to enable. Try something like: rake ray:extension:enable name=extension_name"
    
      else
        name = ENV['name']
        vendor_name = name.gsub(/\-/, "_")
        mkdir_p "vendor/extensions"
        system "mv vendor/extensions_disabled/#{vendor_name} vendor/extensions/#{vendor_name}"
        puts "The #{ENV['name']} extension has been enabled. Use the :disable command to re-enable it later."
        restart_server
      end
    end

    desc "disable extensions"
    task :disable do
      if ENV['name'].nil?
        puts "You have to tell me which extension to disable. Try something like: rake ray:extension:disable name=extension_name"
    
      else
        name = ENV['name']
        vendor_name = name.gsub(/\-/, "_")
        mkdir_p "vendor/extensions_disabled"
        system "mv vendor/extensions/#{vendor_name} vendor/extensions_disabled/#{vendor_name}"
        puts "The #{ENV['name']} extension has been disabled. Use the :enable command to re-enable it later."
        restart_server
      end
    end

    task :page_attachments do
      if ENV['lib'].nil?
        puts "You didn't specify an image processing library, so I'm assuming you already have one installed and ready to use. If you don't have one installed try: rake ray:extension:page_attachments lib=mini_magick"
      else
        image_lib = ENV['lib']
        if image_lib == "mini_magick"
          system "sudo gem install mini_magick"
        elsif image_lib == "rmagick"
          system "sudo gem install mini_magick"
        else
          puts "I only know how to install mini_magick and rmagick. You'll need to install #{ENV['lib']} manually."
        end
      end
      mkdir_p "vendor/plugins"
      system "git clone git://github.com/technoweenie/attachment_fu.git vendor/plugins/attachment_fu"
      system "git clone git://github.com/radiant/radiant-page-attachments-extension.git vendor/extensions/page_attachments"
      system "rake radiant:extensions:page_attachments:migrate"
      system "rake radiant:extensions:page_attachments:update"
      restart_server
    end

    task :markdown do
      setup_file = File.new("config/ray.setup", "r")
      ray_setup = setup_file.gets
      setup_file.close
      mkdir_p "vendor/extensions"
      system "sudo gem install rdiscount"
      if ray_setup == "git\n"
        system "git clone git://github.com/johnmuhl/radiant-markdown-extension.git vendor/extensions/markdown"
      else
        mkdir_p "vendor/extensions_tmp"
        system "cd vendor/extensions_tmp; wget http://github.com/johnmuhl/radiant-markdown-extension/tarball/master; tar xzvf *markdown*.tar.gz; rm *.tar.gz"
        system "mv vendor/extensions_tmp/* vendor/extensions/markdown_filter"
        rm_rf "vendor/extensions_tmp"
      end
      restart_server
    end

    task :help do
      setup_file = File.new("config/ray.setup", "r")
      ray_setup = setup_file.gets
      setup_file.close
      mkdir_p "vendor/extensions"
      if ray_setup == "git\n"
        system "git clone git://github.com/saturnflyer/radiant-help-extension.git vendor/extensions/help"
      else
        mkdir_p "vendor/extensions_tmp"
        system "cd vendor/extensions_tmp; wget http://github.com/saturnflyer/radiant-help-extension/tarball/master; tar xzvf *help*.tar.gz; rm *.tar.gz"
        system "mv vendor/extensions_tmp/* vendor/extensions/help"
        rm_rf "vendor/extensions_tmp"
      end
      restart_server
    end

  end

end