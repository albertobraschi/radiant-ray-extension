name = ENV['name']
vendor_name = name.gsub(/\-/, "_")
if ENV['name'].nil?
  puts "You have to tell me which extension to remove."
  puts "Try something like: rake ray:rm name=extension_name"
else
  if name == "paperclipped"
    migration_check = File.new("vendor/extensions/#{vendor_name}/lib/tasks/assets_extension_tasks.rake", "r") rescue nil
  else
    migration_check = File.new("vendor/extensions/#{vendor_name}/lib/tasks/#{vendor_name}_extension_tasks.rake", "r") rescue nil
  end
  if migration_check
    counter = 1
    while (line = migration_check.gets)
      migrate_search = line.include? ":migrate"
      if migrate_search
        system "rake radiant:extensions:#{vendor_name}:migrate VERSION=0"
      end
      counter = counter + 1
    end
    migration_check.close
    puts "Migrations added by the #{vendor_name} extension have been removed."
  else
    puts "The #{vendor_name} extension didn't have any migrations to remove."
  end
  mkdir_p "vendor/extensions/ray/removed_extensions"
  system "mv vendor/extensions/#{vendor_name} vendor/extensions/ray/removed_extensions/#{vendor_name}"
  puts "The #{vendor_name} extension has been removed."
  puts ""
  puts "If the #{vendor_name} extension put anything in your /public directory"
  puts "it's been left there and you will need to remove it by hand."
end

git_check = File.new(".git/HEAD", "r") rescue nil
if git_check
  system "git submodule rm --cached vendor/extensions/#{vendor_name}"
  git_check.close
  puts ""
  puts "Staged the #{vendor_name} extension for deletion."
  puts "You'll need to `git commit` before it's actually deleted."
end

require 'vendor/extensions/ray/lib/tasks/_restart_server.rb'
