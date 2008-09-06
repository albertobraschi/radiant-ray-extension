check = File.new("vendor/extensions/ray/config/restart.txt", "r") rescue nil
if check != nil
  system "rm vendor/extensions/ray/config/restart.txt"
else
  mkdir_p "vendor/extensions/ray/config"
  system "touch vendor/extensions/ray/config/restart.txt"
end
def set_server_preference
  ray_restart = File.open("vendor/extensions/ray/config/restart.txt", "w")
  ray_restart.puts server
  ray_restart.close
  puts "==="
  puts "I've set your preferred server to #{server} in"
  puts "${RAILS_ROOT}/vendor/extensions/ray/config/restart.txt"
  puts "This means that anytime you ask Ray to do something that requires"
  puts "a restart. He'll just go ahead and restart things for you."
  puts "==="
end
server = ENV['server'] rescue nil
if server
  if server == "passenger\n"
    set_server_preference
  elsif server == "mongrel\n"
    set_server_preference
  else
    puts "==="
    puts "I don't know how to restart #{server}."
    puts "So I didn't bother writing that to your preference file."
    puts "==="
  end
else
  puts "==="
  puts "You have to tell me what kind of server to restart."
  puts "For Mongrel (or mongrel_cluster): rake ray:setup:restart server=mongrel"
  puts "For Passenger: rake ray:setup:restart server=passenger"
  puts "==="
end
