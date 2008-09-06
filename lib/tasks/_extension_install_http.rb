require 'net/http'
name = ENV['name']
github_name = name.gsub(/\_/, "-")
vendor_name = name.gsub(/\-/, "_")
radiant_git = "http://github.com/radiant/"
mkdir_p "vendor/extensions/ray/tmp"
if ENV['hub'].nil?
  ext_repo = radiant_git
else
  ext_repo = "http://github.com/#{ENV['hub']}/"
end
if ENV['fullname'].nil?
  repo_name = "radiant-#{github_name}-extension"
else
  repo_name = ENV['fullname']
end
github_url = URI.parse("#{ext_repo}#{repo_name}/tarball/master")
found = false
until found
  host, port = github_url.host, github_url.port if github_url.host && github_url.port
  github_request = Net::HTTP::Get.new(github_url.path)
  github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
  github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
found = true
end
open("vendor/extensions/ray/tmp/#{vendor_name}.tar.gz", "wb") { |file|
  file.write(github_response.body)
}
system "cd vendor/extensions/ray/tmp; tar xzvf #{vendor_name}.tar.gz; rm *.tar.gz"
system "mv vendor/extensions/ray/tmp/* vendor/extensions/#{vendor_name}"
rm_rf "vendor/extensions/ray/tmp"
require 'vendor/extensions/ray/lib/tasks/_extension_post_install.rb'