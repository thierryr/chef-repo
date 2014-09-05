#
# Cookbook Name:: omf
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
%w(ruby ruby-dev build-essential libssl-dev).each do |p|
  package p do
    action :upgrade
  end
end

gem_package "omf_rc" do
  action :upgrade
end

bash "install_omf_rc_start_script" do
  code "install_omf_rc -i"
end

directory "/etc/omf_rc"

template "/etc/omf_rc/config.yml" do
  source "config.yml"
end

service "omf_rc" do
  provider Chef::Provider::Service::Upstart if platform?('ubuntu')
  action [:start, :enable]
end
