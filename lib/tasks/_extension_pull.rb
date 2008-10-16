name = ENV['name']
path = 'vendor/extensions'
if ENV['path']
  path = ENV['path']
end
vendor_name = name.gsub(/\-/, "_")
Dir.chdir("#{path}/#{vendor_name}") do
  config = File.open(".git/config", "r")
  while (line = config.gets)
    if line =~ /remote \"([a-zA-Z0-9]+)\"/
      unless $1 == 'origin'
        system "git checkout master"
        system "git pull #{$1} master"
        puts "=============================================================================="
        puts "The changes from hub #{$1} have been pulled into the #{vendor_name} extension"
        puts "=============================================================================="
      end
    end
  end
end

