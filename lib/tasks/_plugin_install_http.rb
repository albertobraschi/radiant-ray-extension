require 'net/http'
name = @plugin_name
vendor_name = name.gsub(/\-/, "_")
hub = @plugin_hub
ext_repo = "http://github.com/#{hub}/"
mkdir_p "vendor/extensions/ray/tmp"
github_url = URI.parse("#{ext_repo}#{name}/tarball/master")
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
system "mv vendor/extensions/ray/tmp/* vendor/plugins/#{vendor_name}"
rm_rf "vendor/extensions/ray/tmp"
