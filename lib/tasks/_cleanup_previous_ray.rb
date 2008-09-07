check = File.new("vendor/extensions/ray/config/download.txt", "r") rescue nil
if check != nil
  system "rm vendor/extensions/ray/config/download.txt"
end
check = File.new("vendor/extensions/ray/config/restart.txt", "r") rescue nil
if check != nil
  system "rm vendor/extensions/ray/config/restart.txt"
end
