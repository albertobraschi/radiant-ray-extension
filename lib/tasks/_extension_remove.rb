name = ENV['name']
path = 'vendor/extensions'
if ENV['path']
  path = ENV['path']
end
vendor_name = name.gsub(/\-/, "_")
if name.nil?
  puts "=============================================================================="
  puts "You have to tell me which extension to remove."
  puts "Try something like: rake ray:rm name=extension_name"
  puts "=============================================================================="
else
  if name == "paperclipped"
    tasks = File.open("#{path}/#{vendor_name}/lib/tasks/assets_extension_tasks.rake", "r") rescue nil
  else
    tasks = File.open("#{path}/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
  end
  if tasks
    counter = 1
    while (line = tasks.gets)
      migrate_task = line.include? ":migrate"
      if migrate_task
        system "rake radiant:extensions:#{vendor_name}:migrate VERSION=0"
      end
      counter = counter + 1
    end
    tasks.close
    puts "=============================================================================="
    puts "Migrations added by the #{vendor_name} extension have been dropped."
  else
    puts "=============================================================================="
    puts "The #{vendor_name} extension didn't have any migrations to remove."
  end
  system "mkdir -p #{@ray}/removed_extensions"
  system "mv #{path}/#{vendor_name} #{@ray}/removed_extensions/#{vendor_name}"
  puts "If the #{vendor_name} extension put anything in your `/public` directory"
  puts "it will still be there. Please remove these files by hand if necessary."
  puts "The #{vendor_name} extension has been removed."
  puts "=============================================================================="
end
if File.exist?(".gitmodules")
  system "git submodule rm --cached #{path}/#{vendor_name}"
  puts "Staged the #{vendor_name} extension for deletion."
  puts "You'll need to `git commit` before it's removed from the index."
  puts "=============================================================================="
end
require "#{@task}/_restart_server.rb"
