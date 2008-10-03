if File.exist?("vendor/extensions/ray/config/download.txt")
  system "rm vendor/extensions/ray/config/download.txt"
end
if File.exist?("vendor/extensions/ray/config/restart.txt")
  system "rm vendor/extensions/ray/config/restart.txt"
end
