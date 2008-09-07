legacy_check = File.new("config/ray.setup", "r") rescue nil
if legacy_check
  mkdir_p "vendor/extensions/ray/config"
  system "mv config/ray.setup vendor/extensions/ray/config/download.txt"
  puts "==="
  puts "Updated to Ray 1.1"
  puts "==="
else
  upgrade = File.new("vendor/extensions/ray/config/download.txt", "r") rescue nil
  if upgrade
    puts "==="
    puts "Already up to date."
    puts "==="
  else
    legacy_check = File.new("vendor/extensions/ray/config/setup.txt", "r") rescue nil
    if legacy_check
      system "mv vendor/extensions/ray/config/setup.txt vendor/extensions/ray/config/download.txt"
    end
  end
end
