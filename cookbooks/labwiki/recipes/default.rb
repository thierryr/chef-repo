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
end

# Install LabWiki
directory "/var/lib/labwiki/labwiki" do
  recursive true
end

pkg_list.each do |p|
  package p do
    action :install
  end
end
