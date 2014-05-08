def folder_for(img)
  return File.expand_path "docker-images/#{img}", ROOT_DIR
end

def image_dependencies(img)
  case img.to_sym
    when :hull then []
    when :deckhouse then [:hull]
    when :waypoint then [:hull, :deckhouse]
    when :harbor then [:hull, :deckhouse]
    when :ship then [:hull]
    when :ferry then [:hull, :deckhouse]
    else raise "Unknown image: #{image_name}"
  end
end

def files_in(folder_path)
  glob = "#{folder_path}/**/*"
  Rake::FileList[glob]
end

def cache_buster_dependencies(cache_file)
  img = cache_file.pathmap('%n').to_sym
  dependencies = image_dependencies(img).map {|d| cache_buster_file(d)}
  image_files = files_in folder_for(img)
  dependencies.push image_files
  return dependencies
end

def cache_buster_file(img)
  ".tmp/#{img}.build"
end

rule( /\.tmp\/.*\.build/ => ->(f){cache_buster_dependencies(f)}) do |t|
  image_name = t.name.pathmap '%n'
  image_folder = folder_for image_name
  info "Building #{image_name}"
  cmd="docker build -t vlipco/#{image_name} --rm #{image_folder}"
  mkdir_p '.tmp', verbose: false
  # start writing before creating the image
  # so that changes to files during creationg result in run next time
  File.open( t.name, 'w+') {|f| f.write Time.now }
  sh cmd, verbose: true do |ok,res|
    if !ok
      rm t.name
      error "Docker build failed"
    end
  end 
end
