def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def log(msg)
	puts "     #{msg}"
end

def error(msg)
	puts "\n---> #{msg}\n".colorize :red
end

def debug(msg)
  puts "\n---> #{msg}\n".colorize :magenta
end

def push_app(app, as_name)
  info "Pushing #{app} as #{as_name}"
  exec "misc/dev-tools/fake-release #{app} #{as_name}"#, verbose: false
end

def folder_for(img)
  return File.expand_path "docker-images/#{img.to_s.split('_').join('/')}", ROOT_DIR
end

def files_in(folder_path)
  glob = "#{folder_path}/**/*"
  Rake::FileList[glob]
end

def cache_buster_dependencies(cache_file)
  img = cache_file.pathmap('%n').to_sym
  image_files = files_in folder_for(img)
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
