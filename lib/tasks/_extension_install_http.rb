require 'net/http'
github_name = @name.gsub(/\_/, "-")
vendor_name = @name.gsub(/\-/, "_")
master_repo = "http://github.com/radiant"
system "mkdir -p #{@ray}/tmp"
if @hub
  repository = "http://github.com/#{@hub}"
else
  repository = master_repo
end
if @fullname
  extension = @fullname
else
  extension = "radiant-#{github_name}-extension"
end
github_url = URI.parse("#{repository}/#{extension}/tarball/master")
found = false
until found
  host, port = github_url.host, github_url.port if github_url.host && github_url.port
  github_request = Net::HTTP::Get.new(github_url.path)
  github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
  github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
found = true
end
open("#{@ray}/tmp/#{vendor_name}.tar.gz", "wb") { |file|
  file.write(github_response.body)
}
system "cd #{@ray}/tmp; tar xzvf #{vendor_name}.tar.gz; rm *.tar.gz"
system "mv #{@ray}/tmp/* #{@path}/#{vendor_name}"
rm_rf "#{@ray}/tmp"
require "#{@task}/_extension_post_install.rb"
