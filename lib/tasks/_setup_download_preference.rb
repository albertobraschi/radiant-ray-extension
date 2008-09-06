check = File.new("vendor/extensions/ray/config/download.txt", "r") rescue nil
if check != nil
  system "rm vendor/extensions/ray/config/download.txt"
else
  mkdir_p "vendor/extensions/ray/config"
  system "touch vendor/extensions/ray/config/download.txt"
end

system "git --version" rescue nil

unless !$?.nil? && $?.success?
  ray_setup = File.open("vendor/extensions/ray/config/download.txt", "w")
  ray_setup.puts "http"
  ray_setup.close
  puts ""
  puts "I can't seem to locate the `git` utilities."
  puts "So, I've set your preference to HTTP in"
  puts "${RAILS_ROOT}/vendor/extensions/ray/config/download.txt"
  puts ""
  puts "If you install `git` later simply run `rake ray:setup:install`"
  puts "and I'll update your preference file."
  puts ""

else
  ray_setup = File.open("vendor/extensions/ray/config/download.txt", "w")
  ray_setup.puts "git"
  ray_setup.close
  puts ""
  puts "I found git on your system and set it as your preference in"
  puts "${RAILS_ROOT}/vendor/extensions/ray/config/download.txt"
  puts ""
end
