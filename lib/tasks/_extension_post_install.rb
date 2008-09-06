name = ENV['name']
vendor_name = name.gsub(/\-/, "_")
task_check = File.new("vendor/extensions/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
if task_check != nil
  counter = 1
  while (line = task_check.gets)
    install_search = line.include? ":install"
    break if install_search
    counter = counter + 1
  end
  task_check.close
  if install_search
    system "rake radiant:extensions:#{vendor_name}:install"
  else
    task_check = File.new("vendor/extensions/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
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
end
puts "The #{vendor_name} extension has been installed or updated."
puts "To disable it later Use: rake ray:dis name=#{vendor_name}"