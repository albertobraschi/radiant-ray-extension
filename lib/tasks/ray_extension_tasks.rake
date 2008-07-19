namespace :ray do

  def setup_install
    system "rm config/ray.setup"
    mkdir_p "vendor/extensions/ray/config"
    system "touch vendor/extensions/ray/config/setup.txt"
    system "git --version" rescue nil
    unless !$?.nil? && $?.success?
      puts "You don't have the `git` utilities installed and/or available in your path."
      puts "I created a `vendor/extensions/ray/config/setup.txt` file and set your preferred download method."
      puts "For now I'll be using the slower, less efficient HTTP fetch method."
      puts "---"
      puts "If you install `git` later simply run `rake ray:setup:install`"
      ray_setup = File.open("vendor/extensions/ray/config/setup.txt", "w")
      ray_setup.puts "http"
    else
      system "rm vendor/extensions/ray/config/setup.txt"
      system "touch vendor/extensions/ray/config/setup.txt"
      ray_setup = File.open("vendor/extensions/ray/config/setup.txt", "w")
      ray_setup.puts "git"
      puts "I created a `vendor/extensions/ray/config/setup.txt` file and set your preferred download method to `git`"
    end
    ray_setup.close
  end

  def restart_server
    if ENV['restart'].nil?
      puts "You should restart your server now. Try adding restart=mongrel_cluster or restart=passenger next time."
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
    system "git clone #{ext_repo}#{ENV['fullname']}.git vendor/extensions/#{vendor_name}"
    post_install_extension
  end

  def install_extension_http
    require 'net/http'
    
    name = ENV['name']
    github_name = name.gsub(/\_/, "-")
    vendor_name = name.gsub(/\-/, "_")
    radiant_git = "http://github.com/radiant/"

    mkdir_p "vendor/extensions/ray/tmp"

    if ENV['hub'].nil?
      ext_repo = radiant_git
    else
      ext_repo = "http://github.com/#{ENV['hub']}/"
    end
    if ENV['fullname'].nil?
      repo_name = "radiant-#{github_name}-extension"
    else
      repo_name = ENV['fullname']
    end

    github_url = URI.parse("#{ext_repo}#{repo_name}/tarball/master")
    found = false
    until found
      host, port = github_url.host, github_url.port if github_url.host && github_url.port
      github_request = Net::HTTP::Get.new(github_url.path)
      github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
      github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
    found = true
    end
    open("vendor/extensions/ray/tmp/#{vendor_name}.tar.gz", "wb") { |file|
      file.write(github_response.body)
    }

    system "cd vendor/extensions/ray/tmp; tar xzvf #{vendor_name}.tar.gz; rm *.tar.gz"
    system "mv vendor/extensions/ray/tmp/* vendor/extensions/#{vendor_name}"

    rm_rf "vendor/extensions/ray/tmp"
    post_install_extension
  end

  def post_install_extension
    name = ENV['name']
    vendor_name = name.gsub(/\-/, "_")
    task_check = File.new("vendor/extensions/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
    if task_check != nil
      counter = 1
      while (line = task_check.gets)
        migrate_search = line.include? ":migrate"
        update_search = line.include? ":update"
        if migrate_search
          system "rake radiant:extensions:#{vendor_name}:migrate"
        end
        if update_search
          system "rake radiant:extensions:#{vendor_name}:update"
        end
        counter = counter + 1
      end
      task_check.close
    end
    puts "The #{vendor_name} extension has been installed or updated. Use the :disable command to disable it later."
  end

  namespace :setup do

    task :install do
      setup_install
    end

  end

  namespace :extension do

    desc "Search available extensions."
    task  :search do
      if ENV['name'].nil?
        puts "You have to tell me which extension to search for. Try something like: rake ray:extension:search name=link"
    
      else
        name = ENV['name']
        puts "Not implemented."
      end
    end

    desc "Install an extension from GitHub. `name=extension_name` is required; if you specify `fullname` you must also specify `hub=github_user_name`. You can also use `hub=user` with the `name` option to install from outside the Radiant repository."
    task :install do
      setup_check = File.new("vendor/extensions/ray/config/setup.txt", "r") rescue nil
      if setup_check == nil
        setup_install
      end
      
      if ENV['name'].nil?
        puts "You have to tell me which extension to install. Try something like: rake ray:extension:install name=extension_name"
      else
        setup_file = File.new("vendor/extensions/ray/config/setup.txt", "r")
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
              install_extension_http
              restart_server
            end
          
          when ENV['hub']
            if ENV['fullname'].nil?
              install_extension_http
            else
              install_extension_http
            end
            restart_server

          else
            install_extension_http
            restart_server
          end
        end
        
      end

    end

    desc "Enable extensions."
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

    desc "Disable extensions."
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

    desc "Install Page Attachments extension."
    task :page_attachments do
      if ENV['lib'].nil?
        puts "You didn't specify an image processing library, so I'm assuming you already have one installed and ready to use. If you don't have one installed try: rake ray:extension:page_attachments lib=mini_magick"
      else
        if image_lib == "mini_magick"
          system "sudo gem install mini_magick"
        elsif image_lib == "rmagick"
          system "sudo gem install mini_magick"
        else
          puts "I only know how to install mini_magick and rmagick. You'll need to install #{ENV['lib']} manually."
        end
      end
      setup_file = File.new("vendor/extensions/ray/config/setup.txt", "r")
      ray_setup = setup_file.gets
      setup_file.close
      mkdir_p "vendor/plugins"
      mkdir_p "vendor/extensions"
      image_lib = ENV['lib']
      if ray_setup == "git\n"
        system "git clone git://github.com/technoweenie/attachment_fu.git vendor/plugins/attachment_fu"
        system "git clone git://github.com/radiant/radiant-page-attachments-extension.git vendor/extensions/page_attachments"
      else
        mkdir_p "vendor/extensions_tmp"
        system "cd vendor/extensions_tmp; wget http://github.com/technoweenie/attachment_fu/tarball/master; tar xzvf *attachment_fu*.tar.gz; rm *.tar.gz"
        system "mv vendor/extensions_tmp/* vendor/plugins/attachment_fu"
        system "cd vendor/extensions_tmp; wget http://github.com/radiant/radiant-page-attachments-extension/tarball/master; tar xzvf *page-attachments*.tar.gz; rm *.tar.gz"
        system "mv vendor/extensions_tmp/* vendor/extensions/page_attachments"
        rm_rf "vendor/extensions_tmp"
      end
      system "rake radiant:extensions:page_attachments:migrate"
      system "rake radiant:extensions:page_attachments:update"
      restart_server
    end

    desc "Install RDiscount Markdown filter."
    task :markdown do
      setup_file = File.new("vendor/extensions/ray/config/setup.txt", "r")
      ray_setup = setup_file.gets
      setup_file.close
      mkdir_p "vendor/extensions"
      puts "About to install the RDiscount gem you will need to enter you system administrator password."
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

    desc "Install the Help extension."
    task :help do
      setup_file = File.new("vendor/extensions/ray/config/setup.txt", "r")
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