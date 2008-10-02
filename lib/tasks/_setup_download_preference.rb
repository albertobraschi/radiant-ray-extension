# make sure we have a config directory
begin
  Dir.open(@conf)
rescue
  mkdir_p "#{@conf}"
end
# remove any existing download preference file
if File.exist?("#{@conf}/download.txt")
  rm "#{@conf}/download.txt"
end
# create a new download preference file
system "touch #{@conf}/download.txt"
# determine download preference
system "git --version" rescue nil
# if we can't get the git version set the preference to HTTP
unless !$?.nil? && $?.success?
  download_conf = File.open("#{@conf}/download.txt", "w")
  download_conf.puts "http"
  download_conf.close
  puts "=============================================================================="
  puts "HTTP has been set as your preferred download method."
  puts "If you install Git and would like to update your preferences run:"
  puts "rake ray:git"
  puts "=============================================================================="
# if we find git set it as the preferred method
else
  download_conf = File.open("#{@conf}/download.txt", "w")
  download_conf.puts "git"
  download_conf.close
  puts "=============================================================================="
  puts "Git has been set as your preferred download method."
  puts "=============================================================================="
end
