if File.exist?("config/ray.setup")
  system "mv config/ray.setup #{@conf}/download.txt"
end
if File.exist?("#{@conf}/setup.txt")
  system "mv #{@conf}/setup.txt #{@conf}/download.txt"
end
puts "=============================================================================="
puts "Ray is up to date."
puts "=============================================================================="
