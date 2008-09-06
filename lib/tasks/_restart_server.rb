if ENV['restart'].nil?
  puts "You should restart your server now."
  puts "Try adding restart=mongrel or restart=passenger next time."
else
  server = ENV['restart']
  if server == "mongrel"
    system "mongrel_rails cluster::restart"
  elsif server == "passenger"
    system "touch tmp/restart.txt"
    puts "Your passengers have been restarted."
  else
    puts "I don't know how to restart #{ENV['restart']}."
    puts "You'll need to restart your server manually."
  end
end