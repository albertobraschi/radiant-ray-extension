download_preference = File.new("vendor/extensions/ray/config/download.txt", "r")
ray_download = download_preference.gets
download_preference.close
if ray_download == "git\n"
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
      system "cd vendor/radiant; git remote update"
    else
      system "git submodule add git://github.com/radiant/radiant.git vendor/radiant"
    end
    puts "==="
    puts "Radiant has been updated to the latest edge version."
    puts "==="
  end
elsif ray_download == "http\n"
  mkdir_p "vendor/extensions/ray/tmp"
  rm_r "vendor/radiant"
  github_url = URI.parse("http://github.com/radiant/radiant/tarball/master")
  found = false
  until found
    host, port = github_url.host, github_url.port if github_url.host && github_url.port
    github_request = Net::HTTP::Get.new(github_url.path)
    github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
    github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
  found = true
  end
  open("vendor/extensions/ray/tmp/radiant.tar.gz", "wb") { |file|
    file.write(github_response.body)
  }
  system "cd vendor/extensions/ray/tmp; tar xzvf radiant.tar.gz; rm *.tar.gz"
  system "mv vendor/extensions/ray/tmp/* vendor/radiant"
  rm_rf "vendor/extensions/ray/tmp"
  puts "==="
  puts "Radiant has been updated to the latest edge version."
  puts "==="
end
