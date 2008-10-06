require "yaml"

term = ENV['term'].downcase
extension = []
hub = []
description = []

File.open("#{@ray}/lib/search.yml") do |repositories|
  YAML.load_documents(repositories) do |repository|
    total = repository['repositories'].length - 1
    for count in 0..total
      found = false
      ext = repository['repositories'][count]['name']
      extension << ext
      owner = repository['repositories'][count]['owner']
      hub << owner
      desc = repository['repositories'][count]['description']
      description << desc
    end
  end
end

for a in 0..description.length - 1
  if description[a].include?(term)
    name_match = Regexp.new(/radiant\-(.*)\-extension/)
    extension_name = extension[a].gsub(/radiant\-/, "").gsub(/\-extension/, "")
    puts "name: " + extension_name
    unless extension[a] =~ name_match
      puts "fullname: " + extension[a]
    end
    unless hub[a] == "radiant"
      puts "hub: " + hub[a]
    end
    puts description[a]
    puts "=============================================================================="
  end
end
