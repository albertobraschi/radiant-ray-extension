require "yaml"

File.open("config/extensions.yml") do |bundle|
  YAML.load_documents(bundle) do |extension|
    total = extension.length - 1
    system "mkdir -p #{@ray}/tmp"
    for count in 0..total do
      name = extension[count]['name']
      installer = File.open("#{@ray}/tmp/#{name}_extension_install.rb", "a")
      installer.puts "\@name\ \=\ \"#{name}\""
      if extension[count]['fullname']
        fullname = extension[count]['fullname']
        installer.puts "\@fullname\ \=\ \"#{fullname}\""
      end
      if extension[count]['hub']
        hub = extension[count]['hub']
        installer.puts "\@hub\ \=\ \"#{hub}\""
      end
      if extension[count]['lib']
        lib = extension[count]['lib']
        installer.puts "\@lib\ \=\ \"#{lib}\""
      end
      if extension[count]['remote']
        remote = extension[count]['remote']
        installer.puts "\remote\ \=\ \"#{remote}\""
      end
      if extension[count]['plugin']
        plugin = extension[count]['plugin']
        installer.puts "\@plugin\ \=\ \"#{plugin}\""
      end
      if extension[count]['plugin_path']
        plugin_path = extension[count]['plugin_path']
        installer.puts "\@plugin_path\ \=\ \"#{plugin_path}\""
      end
      if extension[count]['plugin_repository']
        plugin_repository = extension[count]['plugin_repository']
        installer.puts "\@plugin_repository\ \=\ \"#{plugin_repository}\""
      end
      if extension[count]['rake']
        rake = extension[count]['rake']
        installer.puts "\@rake\ \=\ \"#{rake}\""
      end
      if extension[count]['vendor']
        vendor = extension[count]['vendor']
        installer.puts "\@vendor\ \=\ \"#{vendor}\""
      end
      if extension[count]['path']
        path = extension[count]['path']
        installer.puts "\@path\ \=\ \"#{path}\""
      else
        installer.puts "\@path\ \=\ \"vendor\/extensions\""
      end
      installer.puts "\@ray\ \=\ \"vendor\/extensions\/ray\""
      installer.puts "\@task\ \=\ \"\#\{\@ray\}\/lib\/tasks\""
      installer.puts "\@conf\ \=\ \"\#\{\@ray\}\/config\""
      generic_install = File.read("#{@task}/_extension_install.rb")
      installer.puts generic_install
      installer.close
      system "ruby #{@ray}/tmp/#{name}_extension_install.rb && rm #{@ray}/tmp/#{name}_extension_install.rb"
    end
  end
  system "rm -r #{@ray}/tmp"
end
