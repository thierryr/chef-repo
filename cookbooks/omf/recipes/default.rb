#
# Cookbook Name:: omf
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
case node["platform_family"]
when "debian"
  include_recipe "apt"

  pkg_list = %w(build-essential libssl-dev)

  if (platform?("debian") && node["platform_version"] < "7") || (platform?("ubuntu") && node["platform_version"] < "13.04")
    pkg_list += %w(ruby1.9.1 ruby1.9.1-dev)
  else
    pkg_list += %w(ruby ruby-dev)
  end
when "fedora"
  magic_shell_environment "PATH" do
    value "$PATH:/usr/local/bin"
  end

  pkg_list = %w(ruby ruby-devel make gcc gpp gcc-c++ openssl-devel)
end

pkg_list.each do |p|
  package p do
    action :upgrade
  end
end

gem_package "omf_rc" do
  action [:remove, :install]
end

bash "install_omf_rc_start_script" do
  code "install_omf_rc -i"
end

directory "/etc/omf_rc"

template "/etc/omf_rc/config.yml" do
  source "config.yml"
end

service "omf_rc" do
  provider Chef::Provider::Service::Upstart if platform?("ubuntu")
  action [:stop, :start, :enable]
end
