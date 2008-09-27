submodule_check = File.new(".gitmodules", "r") rescue nil
if submodule_check
  counter = 1
  while (line = submodule_check.gets)
    radiant_search = line.include? "\[submodule\ \"vendor\/radiant\"\]"
    break if radiant_search
    counter = counter + 1
  end
  submodule_check.close
  if radiant_search
    system "git rm --cached vendor/radiant"
    puts "==="
    puts "Radiant has been locked to your latest Radiant gem version."
    puts "Don't forget to run"
    puts "git commit -am 'lock to latest Radiant gem version'"
    puts "to make sure this is reflected in your Git index."
    puts "==="
  else
    rm_r "vendor/radiant"
    puts "==="
    puts "Radiant has been locked to your latest Radiant gem version."
    puts "==="
  end
else
  rm_r "vendor/radiant"
  puts "==="
  puts "Radiant has been locked to your latest Radiant gem version."
  puts "==="
end
