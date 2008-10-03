if @fullname
  vendor_name = @fullname
else
  vendor_name = @name.gsub(/\-/, "_")
end
vendor_path = @name.gsub(/\-/, "_")
# determine what tasks need to be run
if tasks = File.open("#{@path}/#{vendor_path}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
  counter = 1
  # check for install task
  while (line = tasks.gets)
    install_task = line.include? ":install"
    break if install_task
    counter = counter + 1
  end
  tasks.close
  # just run the install task if it's there
  if install_task
    system "rake radiant:extensions:#{vendor_name}:install"
  else
    tasks = File.open("#{@path}/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r")
    counter = 1
    # check for migrate and update tasks
    while (line = tasks.gets)
      migrate_task = line.include? ":migrate"
      update_task = line.include? ":update"
      # run the migrate task
      if migrate_task
        system "rake radiant:extensions:#{vendor_name}:migrate"
      end
      # run the update task
      if update_task
        system "rake radiant:extensions:#{vendor_name}:update"
      end
      counter = counter + 1
    end
    tasks.close
  end
  puts "=============================================================================="
  puts "The #{vendor_name} extension has been installed."
  puts "To disable it run: rake ray:dis name=#{vendor_name}"
  puts "=============================================================================="
  require "#{@task}/_restart_server.rb"
else
  puts "=============================================================================="
  puts "I couldn't find a tasks file for the #{vendor_name} extension."
  puts "Please manually verify the installation and restart the server."
  puts "=============================================================================="
  exit
end
