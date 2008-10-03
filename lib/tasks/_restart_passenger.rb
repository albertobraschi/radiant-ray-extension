begin
  Dir.open("tmp")
rescue
  mkdir_p "tmp"
end
system "touch tmp/restart.txt"
puts "Your passengers have been restarted."
puts "=============================================================================="
