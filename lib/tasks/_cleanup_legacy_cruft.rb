if File.exist?("config/ray.setup")
  system "rm config/ray.setup"
end

if File.exist?("vendor/extensions/ray/config/setup.txt")
  system "rm vendor/extensions/ray/config/setup.txt"
end
