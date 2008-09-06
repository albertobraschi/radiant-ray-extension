def passenger
  require 'vendor/extensions/ray/lib/tasks/_restart_passenger.rb'
end
def mongrel
  require 'vendor/extensions/ray/lib/tasks/_restart_mongrel.rb'
end
restart_preference = File.new("vendor/extensions/ray/config/restart.txt", "r") rescue nil
if restart_preference
  ray_restart = restart_preference.gets
  restart_preference.close
  if ray_restart == "passenger\n"
    passenger
  elsif ray_restart == "mongrel\n"
    mongrel
  else
    puts "==="
    puts "I don't know how to restart #{ray_restart}"
    puts "I only know how to restart 'passenger' or 'mongrel'"
    puts "==="
  end
else
  if ENV['restart'].nil?
    puts "You should restart your server now."
    puts "Try adding restart=mongrel or restart=passenger next time."
  else
    server = ENV['restart']
    if server == "mongrel"
      mongrel
    elsif server == "passenger"
      passenger
    else
      puts "==="
      puts "I don't know how to restart #{ENV['restart']}"
      puts "I only know how to restart 'passenger' or 'mongrel'"
      puts ""
      puts "You should restart your server now."
      puts "Try adding restart=mongrel or restart=passenger next time."
      puts "==="
    end
  end
end
