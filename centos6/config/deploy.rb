set(:host) do
  Capistrano::CLI.ui.ask "Give me a server host(IP or domain): "
end

set(:user) do
  Capistrano::CLI.ui.ask "Give me a ssh user: "
end

set(:password) do
  Capistrano::CLI.password_prompt "Give me a ssh password: "
end

role :target, host

namespace :centos6 do

  task :install_apache2, :roles=>:target do
    set(:use_https) do
      Capistrano::CLI.ui.ask "use https(defaults no): "
    end

    set(:use_http) do
      Capistrano::CLI.ui.ask "use http(defaults yes): "
    end
    
    # install apache2
    run "yum -y install httpd" do |channel, stream, data|
      puts data
    end
    
    if use_http != 'no'
      run "iptables -I INPUT 5 -m state --state NEW -p tcp --dport 80 -j ACCEPT"
    end

    if use_https == 'yes'
      run "yum -y install mod_ssl"
      run "iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT"
    end
    run "iptables -L --line-numbers"
    run "service iptables save"
    run "chkconfig httpd on"
    run "service httpd start"
  end

  task :install_passenger, :roles=>:target do
    set(:rails_version) do
      Capistrano::CLI.ui.ask "rails version (defaults 2.3.2): "
    end

    # install ruby
    run "yum -y install ruby"
    run "yum -y install ruby-devel"
    run "yum -y install rubygems"
        
    # install rails
    run "gem install rails -v=#{rails_version}"
    
    # install passenger
    run "yum -y install gcc make"
    run "gem install passenger"

    # install passenger apache module
    run "yum -y install gcc-c++ httpd-devel openssl-devel readline-devel zlib-devel curl-devel"
    run "passenger-install-apache2-module -a"
  end

end
