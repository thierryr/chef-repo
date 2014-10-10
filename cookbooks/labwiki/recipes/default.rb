#
# Cookbook Name:: labwiki
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# Find correct packages & add OML repository to apt
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

  pkg_list += ["oml2-server", "oml2-apps"]

  # Job Service needs these
  pkg_list += ["sqlite3", "libpq-dev", "libsqlite3-dev"]

  # AMQP Server
  pkg_list += ["rabbitmq-server"]

  # PG
  pkg_list += ["postgresql"]

  # Essential tools
  pkg_list += ["git", "curl"]
end

pkg_list.each do |p|
  package p do
    action :install
  end
end

gem_package "rake"
gem_package "bundler"

# Start OML Server
service "oml2-server" do
  action [:enable, :start]
end

# Install LabWiki
user "labwiki" do
  system true
  home "/var/lib/labwiki"
  shell "/bin/bash"
end

directory "/var/lib/labwiki" do
  recursive true
  owner "labwiki"
  group "labwiki"
end

git "/var/lib/labwiki/labwiki" do
  repository "https://github.com/mytestbed/labwiki.git"
  user "labwiki"
  group "labwiki"
end

# LW Plugins
lw_plugins = ["labwiki_experiment_plugin", "labwiki_gimi_plugin", "labwiki_topology_plugin"]

lw_plugins.each do |p|
  git "/var/lib/labwiki/labwiki/plugins/#{p}" do
    repository "https://github.com/mytestbed/#{p}.git"
    user "labwiki"
    group "labwiki"
  end
end

# Install Job Service
git "/var/lib/labwiki/omf_job_service" do
  repository "https://github.com/mytestbed/omf_job_service.git"
  user "labwiki"
  group "labwiki"
end

# Install Slice Service
git "/var/lib/labwiki/omf_slice_service" do
  repository "https://github.com/mytestbed/omf_slice_service.git"
  user "labwiki"
  group "labwiki"
end
