puts "I'm about to install the #{@lib} gem."
puts "You'll need to enter your system administrator password."
system "sudo gem install #{@lib}"
puts "=============================================================================="
