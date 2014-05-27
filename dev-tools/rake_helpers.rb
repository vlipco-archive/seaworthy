def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def log(msg)
	puts "     #{msg}"
end

#def error(msg)
#	puts "\n---> #{msg}\n".colorize :red
#end

def debug(msg)
  puts "\n---> #{msg}\n".colorize :magenta
end

def remove_container(ctr)
  # TODO gracefully handle errors
  sh "sudo docker stop -t 1 #{ctr.to_s} &> /dev/null", verbose: false
  sh "sudo docker rm #{ctr.to_s} &> /dev/null", verbose: false
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

def push_app(app, as_name)
  info "Pushing #{app} as #{as_name}"
  exec "dev-tools/fake-release #{app} #{as_name}"#, verbose: false
end

def folder_for(img)
  return File.expand_path "docker-images/#{img.to_s.split('_').join('/')}", ROOT_DIR
end

#def image_dependencies(img)
#  []
#end

def files_in(folder_path)
  glob = "#{folder_path}/**/*"
  Rake::FileList[glob]
end

def cache_buster_dependencies(cache_file)
  img = cache_file.pathmap('%n').to_sym
  #dependencies = image_dependencies(img).map {|d| cache_buster_file(d)}
  image_files = files_in folder_for(img)
  #dependencies.push *image_files
  return image_files #dependencies
end

def cache_buster_file(img)
  # a tempo dir outside the repository is used
  # because every vm must have it's own track of
  # previous builds
  "#{TMPDIR}/#{img}.build"
end

rule( /#{TMPDIR}\/.*\.build/ => ->(f){cache_buster_dependencies(f)}) do |t|
  image_name = t.name.pathmap '%n'
  image_folder = folder_for image_name
  # we remove the directory part of the image name
  image_name = image_name.split('_')[-1]
  info "Building #{image_name}"
  cmd="docker build -t vlipco/#{image_name} --rm #{image_folder}"
  mkdir_p '.tmp', verbose: false
  # start writing before creating the image
  # so that changes to files during creationg result in run next time
  File.open( t.name, 'w+') {|f| f.write Time.now }
  sh cmd, verbose: false do |ok,res|
    if !ok
      rm t.name
      raise "Docker build failed"
    end
  end 
end
