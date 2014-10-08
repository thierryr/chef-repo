default['omf']['frcp'] = ENV["FRCP"] && !ENV["FRCP"].empty? ? ENV["FRCP"] : "amqp://srv.mytestbed.net"

default['omf']['uid'] =
  begin
    node_json = JSON.parse(File.read("#{File.expand_path(File.dirname(__FILE__))}/../../../node.json"))
    node_json.values.first["omf_id"]
  rescue
    Socket.gethostname
  end
