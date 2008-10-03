if File.exist?("vendor/extensions/ray/config/restart.txt")
  system "rm vendor/extensions/ray/config/restart.txt"
else
  # make sure we have a config directory
  begin
    Dir.open(@conf)
  rescue
    mkdir_p "#{@conf}"
  end
  system "touch vendor/extensions/ray/config/restart.txt"
end

def set_server_preference
  restart_conf = File.open("vendor/extensions/ray/config/restart.txt", "w")
  restart_conf.puts @server
  restart_conf.close
  puts "=============================================================================="
  puts "I've set your preferred server to #{@server}"
  puts "So when you do something that requires a restart I'll do it automatically."
  puts "=============================================================================="
end

@server = ENV['server'] rescue nil
if @server
  if @server == "passenger"
    set_server_preference
  elsif @server == "mongrel"
    set_server_preference
  else
    puts "=============================================================================="
    puts "I don't know how to restart #{@server}."
    puts "So it wasn't saved to your preference file."
    puts "=============================================================================="
  end
else
  puts "=============================================================================="
  puts "You didn't tell me what kind of server you'd like to restart."
  puts "For Mongrel: rake ray:setup:restart server=mongrel"
  puts "For Passenger: rake ray:setup:restart server=passenger"
  puts "=============================================================================="
end
