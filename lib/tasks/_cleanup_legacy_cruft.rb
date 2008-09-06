legacy_check = File.new("config/ray.setup", "r") rescue nil
if legacy_check != nil
  system "rm config/ray.setup"
end

legacy_check = File.new("vendor/extensions/ray/config/setup.txt", "r") rescue nil
if legacy_check != nil
  system "rm vendor/extensions/ray/config/setup.txt"
end
