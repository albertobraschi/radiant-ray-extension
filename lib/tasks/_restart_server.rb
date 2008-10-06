def restart_passenger
  require "#{@task}/_restart_passenger.rb"
end
def restart_mongrel
  require "#{@task}/_restart_mongrel.rb"
end
restart_conf = File.open("#{@conf}/restart.txt", "r") rescue nil
if restart_conf
  restart_pref = restart_conf.gets
  if restart_pref == "passenger\n"
    restart_passenger
  elsif restart_pref == "mongrel\n"
    restart_mongrel
  else
    puts "=============================================================================="
    puts "Your restart preference is broken."
    puts "Please run: rake ray:setup:restart server=passenger"
    puts "Substitute `mongrel` for `passenger` if you use mongrels."
    puts "=============================================================================="
  end
else
  if ENV['restart']
    server = ENV['restart']
    if server == "passenger"
      restart_passenger
    elsif server == "mongrel"
      restart_mongrel
    else
      puts "Sorry, I don't know how to restart #{server}."
      puts "`passenger` and `mongrel` are the only servers I can restart."
      puts "=============================================================================="
    end
  else
    puts "You need to restart your server now."
    puts "Try adding `restart=passenger` or `restart=mongrel` next time."
    puts "Or better yet run: rake ray:setup:restart server=passenger and forget it."
    puts "=============================================================================="
  end
end
