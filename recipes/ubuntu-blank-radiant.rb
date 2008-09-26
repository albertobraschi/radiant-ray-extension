# you need to manually configure these options
set :application, "example"
set :application_url, "example.com"
set :user, "deploy"
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :copy
role :app, "example.com", :primary => true
role :web, "example.com"
role :db,  "example.com"

# below here should run untouched
# unless you want different versions of rubygems or passenger
set :gem_version, "rubygems-1.3.0"
set :gem_url, "http://rubyforge.org/frs/download.php/43985/#{gem_version}.tgz"
set :passenger_version, "passenger-2.0.3"
default_run_options[:pty] = true
set :ubuntu_software, "build-essential apache2-mpm-worker apache2-threaded-dev ruby-full libsqlite3-dev sqlite3 libsqlite3-ruby git-core"
set :ubuntu_gems, "rails passenger radiant sqlite3-ruby aws-s3 rdiscount mini_magick"

# the meat
namespace :setup do

  desc "Setup Ubuntu with Apache2, Passenger and Rails."
  task :ubuntu do
    [
      # install required software
      "sudo aptitude -y install #{ubuntu_software}",
      # install rubygems 1.3.0 from source
      "cd /usr/local/src",
      "wget #{gem_url}",
      "tar xvzf #{gem_version}.tgz",
      "cd #{gem_version}/ && sudo ruby setup.rb",
      "sudo ln -s /usr/bin/gem1.8 /usr/bin/gem",
      # install gems
      "sudo gem install #{ubuntu_gems}",
    ].each {|command| run command}
    # install Passenger Apache module
    input = ''
    run "sudo passenger-install-apache2-module" do |ch,stream,out|
      next if out.chomp == input.chomp || out.chomp == ''
      print out
      ch.send_data(input = $stdin.gets) if out =~ /(Enter|ENTER)/
    end
    # setup Passenger configuration
    passenger_config =<<-EOF
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/#{passenger_version}/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/#{passenger_version}
PassengerRuby /usr/bin/ruby1.8
    EOF
    put passenger_config, "passenger"
    sudo "mv passenger /etc/apache2/conf.d/passenger"
    # setup a blank Radiant instance
    run "wget http://from.johnmuhl.com/blank-production.sqlite3.db"
    run "radiant -d sqlite3 #{application}"
    run "mv blank-production.sqlite3.db #{application}/db/production.sqlite3.db"
    # create a Radiant, Apache, Passenger config
    vhost_config =<<-EOF
<VirtualHost *>
  ServerName #{application_url}
  DocumentRoot #{deploy_to}/public
  ExpiresActive On
  ExpiresDefault "modification plus 1 month"
  ExpiresByType image/* "access plus 10 years"
  ExpiresByType text/* "access plus 3 months"
  FileETag MTime Size
  DeflateCompressionLevel 9
  AddOutputFilterByType DEFLATE text/html text/javascript application/javascript application/x-javascript text/css text/xml
  AddDefaultCharset UTF-8
  AddCharset UTF-8 css
  AddCharset UTF-8 html
  AddCharset UTF-8 js
  AddCharset UTF-8 xml
  <Directory "#{application}/cache">
    Order allow,deny
    Allow from all
  </Directory>
</VirtualHost>
    EOF
    put vhost_config, "#{application}_config"
    sudo "mv #{application}_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
    sudo "a2enmod rewrite"
    sudo "a2enmod deflate"
    sudo "a2enmod expires"
    sudo "/etc/init.d/apache2 restart"
  end

end
