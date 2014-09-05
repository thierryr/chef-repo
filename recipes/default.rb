#
# Cookbook Name:: omf
# Recipe:: default
#
# Copyright 2014, NICTA
#
# All rights reserved
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

service "omf_rc" do
  action [:start, :enable]
end
