if File.exist?("#{@conf}/download.txt")
  download_conf = File.open("#{@conf}/download.txt", "r")
  download_pref = download_conf.gets
  download_conf.close
  if download_pref == "git\n"
    puts "=============================================================================="
    begin
      Dir.open("vendor/radiant")
      system "cd vendor/radiant; git remote update"
    rescue
      if File.exist?(".git/HEAD")
        system "git submodule add git://github.com/radiant/radiant.git vendor/radiant"
      else
        system "git clone git://github.com/radiant/radiant.git vendor/radiant"
      end
    end
    puts "Radiant has been updated to the latest edge version."
    puts "=============================================================================="
  elsif download_pref == "http\n"
    puts "=============================================================================="
    system "mkdir -p #{@ray}/tmp"
    if File.exist?("vendor/radiant/LICENSE")
      system "rm -r vendor/radiant"
    end
    github_url = URI.parse("http://github.com/radiant/radiant/tarball/master")
    found = false
    until found
      host, port = github_url.host, github_url.port if github_url.host && github_url.port
      github_request = Net::HTTP::Get.new(github_url.path)
      github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
      github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
    found = true
    end
    open("#{@ray}/tmp/radiant.tar.gz", "wb") { |file|
      file.write(github_response.body)
    }
    system "cd #{@ray}/tmp; tar xzvf radiant.tar.gz; rm *.tar.gz"
    system "mv #{@ray}/tmp/* vendor/radiant"
    system "rm -r #{@ray}/tmp"
    puts "Radiant has been updated to the latest edge version."
    puts "=============================================================================="
  else
    puts "=============================================================================="
    puts "Your download preference is broken."
    puts "Please run: rake ray:git"
    puts "=============================================================================="
  end
else
  puts "=============================================================================="
  puts "Looks like you haven't setup your preferred download method."
  puts "Let's get that setup now..."
  require "#{@task}/_setup_download_preference.rb"
  puts "With that out of the way try that command again."
  puts "=============================================================================="
end
