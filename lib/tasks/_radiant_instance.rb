if File.exist?(".gitmodules")
  submodules = File.open(".gitmodules", "r")
  counter = 1
  while (line = submodules.gets)
    radiant_submodule = line.include? "\[submodule\ \"vendor\/radiant\"\]"
    break if radiant_submodule
    counter = counter + 1
  end
  submodules.close
  if radiant_submodule
    puts "=============================================================================="
    system "git rm --cached vendor/radiant"
    puts "Radiant has been locked to your latest Radiant gem version."
    puts "Your previous Radiant submodule has been staged for deletion"
    puts "=============================================================================="
  else
    puts "=============================================================================="
    system "rm -r vendor/radiant"
    puts "Radiant has been locked to your latest Radiant gem version."
    puts "=============================================================================="
  end
else
  puts "=============================================================================="
  system "rm -r vendor/radiant"
  puts "Radiant has been locked to your latest Radiant gem version."
  puts "=============================================================================="
end
