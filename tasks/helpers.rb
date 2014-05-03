#puts ROOT_DIR
def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def error(msg)
	puts "\n---> #{msg}\n".colorize :red
end

def folder_for(img)
  return File.expand_path "docker-images/#{img}", ROOT_DIR
end

def dockerfile_for(img)
  return "#{folder_for(img)}/Dockerfile"
end

def remove_container(ctr)
  # TODO gracefully handle errors
  sh "sudo docker stop -t 1 #{ctr.to_s}"
  sh "sudo docker rm #{ctr.to_s}"
end

def gear_volumes_options
  opts = []
  #dbus_socket
  opts << "-v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket"
  #geard_data
  opts << "-v /var/lib/containers:/var/lib/containers"
  #systemd_target
  opts << "-v /etc/systemd/system/container-active.target.wants:/etc/systemd/system/"
  opts.join " "
end

def serf_ports_options_for(port)
  "-p #{port}:#{port} -p #{port}:#{port}/udp"
end

def serf_env_for(name: nil, role: nil, port: nil)
  opts = []
  opts << "-e SERF_ROUTABLE_IP=172.17.42.1"
  opts << "-e SERF_NODE_NAME=#{name.to_s}"
  opts << "-e SERF_BIND_PORT=#{port}"
  opts << "-e SERF_JOIN_NODE=172.17.42.1:7649"
  role ||= name
  opts << "-e SERF_ROLE=#{role.to_s}"
  opts.join " "
end

def start_ctr(name, port: nil, cmd: nil, img: nil, role: nil, options: nil)
  parts = ["sudo docker run --name #{name} -d -i -t"]
  parts << serf_ports_options_for(port)
  parts << serf_env_for(name: name, port: port, role: role)
  parts << options if options
  parts << img
  parts << cmd if cmd
  sh parts.join(" ")
end