if File.exist?(".git/HEAD")
  config = File.open(".git/config", "r")
  while (line = config.gets)
    forked = line.include? "\[remote\ \"fork\"\]"
    break if forked
  end
  config.close
  if not forked
    puts "=============================================================================="
    system "git remote add fork git://github.com/#{@fork}"
    puts "#{@fork} has been added as git remote named 'fork'."
    puts "=============================================================================="
  end
end