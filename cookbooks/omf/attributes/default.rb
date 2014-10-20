default['omf']['frcp'] = ENV["FRCP"] && !ENV["FRCP"].empty? ? ENV["FRCP"] : "amqp://srv.mytestbed.net"
default['omf']['topo_check_timeout'] = 600
a=('1'..'4').to_a
b=('a'..'c').to_a
c=".#{('a'..'z').to_a[rand(26)]}#{('a'..'z').to_a[rand(26)]}#{rand(100)}.tut"
default['omf']['uids'] = a.map { |i| b.map { |j| j+i+c } }.flatten

default['omf']['uid'] =
  begin
    node_json = JSON.parse(File.read("#{File.expand_path(File.dirname(__FILE__))}/../../../node.json"))
    #node_json.values.first["omf_id"]
    node_json["omf_id"]
  rescue
    Socket.gethostname
  end

#default['omf']['oml_collect_uri'] = "tcp:srv.mytestbed.net:3004"
default['omf']['oml_collect_uri'] = ENV["OML_COLLECT_URI"] && !ENV["OML_COLLECT_URI"].empty? ? ENV["OML_COLLECT_URI"] : "tcp:srv.mytestbed.net:3004"

default['omf']['edges'] =
  begin
    #slice_json = JSON.parse(File.read("#{File.expand_path(File.dirname(__FILE__))}/../../../slice.json"))
    slice_json = JSON.parse(File.read("#{File.expand_path(File.dirname(__FILE__))}/../../../../../slice.json"))
    slice_json.values.map do |n|
      n["interfaces"] && n["interfaces"].values.map do |i|
        i["ip"] && i["ip"].map { |ip| ip["address"] }
      end
    end.flatten.compact
  rescue
    []
  end
