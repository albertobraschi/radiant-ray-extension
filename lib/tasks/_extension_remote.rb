if File.exist?("#{@path}/#{@vendor_name}/.git/HEAD")
  config = File.open("#{@path}/#{@vendor_name}/.git/config", "r")
  remote_hub = @remote.split("/").first
  while (line = config.gets)
    already_added = line.include? "\[remote\ \"#{remote_hub}\"\]"
    break if already_added
  end
  config.close
  @remote += ".git" unless @remote =~ /\.git$/
  if not already_added
    puts "=============================================================================="
    Dir.chdir("#{@path}/#{@vendor_name}") do
      system "git remote add #{remote_hub} git://github.com/#{@remote}"
    end
    puts "The repository 'git://github.com/#{@remote}'"
    puts "has been added to the submodule '#{@vendor_name}' as remote '#{remote_hub}'."
    puts "=============================================================================="
  end
end