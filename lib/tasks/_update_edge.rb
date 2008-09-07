edge_check = File.new("vendor/radiant/.git/HEAD", "r") rescue nil
if edge_check
  puts "==="
  system "cd vendor/radiant; git pull origin master"
  puts "==="
else
  puts "==="
  puts "This command is only for updating an existing frozen edge."
  puts "Try rake radiant:freeze:edge first, then later use this command."
  puts "==="
end