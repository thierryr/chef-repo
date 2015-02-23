#
# Cookbook Name:: omf
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
case node["platform_family"]
when "debian"
  include_recipe "apt"

  pkg_list = %w(build-essential libssl-dev)

  case node["platform"]
  when "debian"
    o_k = "http://download.opensuse.org/repositories/home:cdwertmann:oml/Debian_#{node["platform_version"].to_i}.0/Release.key"
    o_u = "http://download.opensuse.org/repositories/home:/cdwertmann:/oml/Debian_#{node["platform_version"].to_i}.0/"
    v_check = "7"
  when "ubuntu"
    o_k = "http://download.opensuse.org/repositories/home:cdwertmann:oml/xUbuntu_#{node["platform_version"]}/Release.key"
    o_u = "http://download.opensuse.org/repositories/home:/cdwertmann:/oml/xUbuntu_#{node["platform_version"]}/"
    v_check = "13.04"
  end

  pkg_list += node["platform_version"] < v_check ? %w(ruby1.9.1 ruby1.9.1-dev) : %w(ruby ruby-dev)

  apt_repository 'oml' do
    key o_k
    uri o_u
    components ['/']
  end
when "fedora"
  magic_shell_environment "PATH" do
    value "$PATH:/usr/local/bin"
  end
  pkg_list = %w(ruby ruby-devel make gcc gpp gcc-c++ openssl-devel)

  unless node["platform_version"].to_i < 17
    o_url = "http://download.opensuse.org/repositories/home:cdwertmann:oml/Fedora_#{node["platform_version"]}/"
  else
    oml2_not_found = true
  end

  unless oml2_not_found
    yum_repository 'oml' do
      description "OML packages"
      baseurl o_url
      gpgcheck false
      action :create
    end
  end
when "rhel"
  # FIXME Failed in CentOS 6.5
  pkg_list = %w(centos-release-SCL ruby193 ruby193-ruby-devel make gcc gcc-c++ openssl-devel)
end

pkg_list << "oml2-apps" unless oml2_not_found

pkg_list.each do |p|
  package p do
    action :install
    options "--force-yes"
  end
end

# FIXME Failed in CentOS 6.5
execute "ruby_on_centos" do
  command "source /opt/rh/ruby193/enable && echo \"source /opt/rh/ruby193/enable\" | sudo tee -a /etc/profile.d/ruby193.sh"
  only_if { platform?("centos") }
end

gem_package "omf_rc" do
  action [:remove, :install]
end

bash "install_omf_rc_start_script" do
  code "install_omf_rc -i"
end

directory "/etc/omf_rc"

template "/etc/omf_rc/topology" do
  source "topology"
end

template "/etc/omf_rc/config.yml" do
  source "config.yml"
end

service "omf_rc" do
  provider Chef::Provider::Service::Upstart if platform?("ubuntu")
  action [:stop, :start]
end

# Install the Ruby-based web redirector
# Note: this could be done in a separate recipe to the cookbook, for demo
# purpose we will add that install as part of the OMF recipe for now.
#
execute "install_web_redirector" do
  cmds =  [
    "gem install rack --no-ri --no-rdoc",
    "mkdir /root/web-redirector",
    "wget https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec22_demo/web_redirector/config.ru --no-check-certificate -O /root/web-redirector/config.ru",
    "wget https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec22_demo/web_redirector/redirector.rb --no-check-certificate -O /root/web-redirector/redirector.rb",
    "wget https://raw.githubusercontent.com/mytestbed/gec_demos_tutorial/master/gec22_demo/web_redirector/config.yaml --no-check-certificate -O /root/web-redirector/config.yaml"
  ]
  command "#{cmds.join(';')}"
end
