require 'net/http'
unless @plugin_path
  @plugin_path = @plugin
end
github_url = URI.parse("http://github.com/#{@plugin_repository}/#{@plugin}/tarball/master")
found = false
until found
  host, port = github_url.host, github_url.port if github_url.host && github_url.port
  github_request = Net::HTTP::Get.new(github_url.path)
  github_response = Net::HTTP.start(host, port) {|http|  http.request(github_request) }
  github_response.header['location'] ? github_url = URI.parse(github_response.header['location']) :
found = true
end
open("#{@ray}/tmp/#{@plugin}.tar.gz", "wb") { |file|
  file.write(github_response.body)
}
system "cd #{@ray}/tmp; tar xzvf #{@plugin}.tar.gz; rm *.tar.gz"
system "mv #{@ray}/tmp/* vendor/plugins/#{@plugin_path}"
