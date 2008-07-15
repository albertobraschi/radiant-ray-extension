namespace :ray do

  desc "Install extensions from github. NAME=extension_name is required. You can also specify HUB=github_user_name in order to install extensions outside the Radiant repository."
  task :install do
      if ENV['NAME'].nil?
        puts "You have to tell me which extension to install. Try something like: rake ray:install NAME=extension_name"

      else
        $verbose = false
        `git --version` rescue nil
        unless !$?.nil? && $?.success?
          # TODO Make sure these are actual commands
          $stderr.puts "ERROR: Must have git available in the PATH to install extensions from github.\nSome common commands for instaling git are:\n`aptitude install git-core`\n`port install git-core`\n`yum install git-core`\n`emerge git-core`"
          exit 1
        end

        name = ENV['NAME']
        github_name = name.gsub(/\_/, "-")
        vendor_name = name.gsub(/\-/, "_")
        radiant_git = "git://github.com/radiant/"

        mkdir_p "vendor/extensions"

        case
        when ENV['HUB']
          puts "user specific install"
          system "git clone git://github.com/#{ENV['HUB']}/radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
          system "rake radiant:extensions:#{vendor_name}:migrate"
          system "rake radiant:extensions:#{vendor_name}:update"
          puts "The #{ENV['NAME']} extension has been installed. Use the :disable command to disable it later."
          if ENV['RESTART'].nil?
            puts "You should restart your server now. Try adding RESTART=mongrel_cluster or RESTART=passenger next time."
          else
            server = ENV['RESTART']
            if server == "mongrel_cluster"
              system "mongrel_rails cluster::restart"
              puts "Your mongrel_cluster has been restarted."
            elsif server == "passenger"
              system "touch tmp/restart.txt"
              puts "Your passengers have been restarted."
            else
              puts "I don't know how to restart #{ENV['RESTART']}. You'll need to restart your server manually."
            end
          end

        else
          puts "normal install"
          system "git clone #{radiant_git}radiant-#{github_name}-extension.git vendor/extensions/#{vendor_name}"
          system "rake radiant:extensions:#{vendor_name}:migrate"
          system "rake radiant:extensions:#{vendor_name}:update"
          puts "The #{ENV['NAME']} extension has been installed. Use the :disable command to disable it later."
          if ENV['RESTART'].nil?
            puts "You should restart your server now. Try adding RESTART=mongrel_cluster or RESTART=passenger next time."
          else
            server = ENV['RESTART']
            if server == "mongrel_cluster"
              system "mongrel_rails cluster::restart"
              puts "Your mongrel_cluster has been restarted."
            elsif server == "passenger"
              system "touch tmp/restart.txt"
              puts "Your passengers have been restarted."
            else
              puts "I don't know how to restart #{ENV['RESTART']}. You'll need to restart your server manually."
            end
          end

        end

      end
  end

  desc "enable extensions"
  task :enable do
    if ENV['NAME'].nil?
      puts "You have to tell me which extension to enable. Try something like: rake ray:enable NAME=extension_name"

    else
      name = ENV['NAME']
      vendor_name = name.gsub(/\-/, "_")
      mkdir_p "vendor/extensions"
      system "mv vendor/extensions_disabled/#{vendor_name} vendor/extensions/#{vendor_name}"
      puts "The #{ENV['NAME']} extension has been enabled. Use the :disable command to re-enable it later."
      puts "You should restart your server now. Try adding RESTART=mongrel_cluster or RESTART=passenger next time."
    end
  end

  desc "disable extensions"
  task :disable do
    if ENV['NAME'].nil?
      puts "You have to tell me which extension to disable. Try something like: rake ray:disable NAME=extension_name"

    else
      name = ENV['NAME']
      vendor_name = name.gsub(/\-/, "_")
      mkdir_p "vendor/extensions_disabled"
      system "mv vendor/extensions/#{vendor_name} vendor/extensions_disabled/#{vendor_name}"
      puts "The #{ENV['NAME']} extension has been disabled. Use the :enable command to re-enable it later."
      puts "You should restart your server now. Try adding RESTART=mongrel_cluster or RESTART=passenger next time."
    end
  end

end