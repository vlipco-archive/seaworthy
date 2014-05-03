def cache_file_for(img)
  return ".cache/#{img}.build"
end

def dependencies_for(cache_file)
  image_name = cache_file.pathmap '%n'
  dependencies = case image_name.to_sym
    when :hull then []
    when :deckhouse then [:hull]
    when :waypoint then [:hull, :deckhouse]
    when :harbor then [:hull, :deckhouse]
    when :ship then [:hull]
    when :ferry then [:hull, :deckhouse]
    else raise "Unknown image: #{image_name}"
  end.map {|d| cache_file_for(d)}
  #dependencies = dependencies_names
  dependencies.unshift '.cache' # cache dir dependency
  # Each build also depends on it's own folder!
  dependencies.push folder_for(image_name)
  debug "DEPENDENCIES FOR #{cache_file}: #{dependencies}"
  return dependencies
end

directory '.cache'

rule( /\.cache\/.*/ => ->(f){dependencies_for(f)}) do |t|
	image_name = t.name.pathmap '%n'
	image_folder = folder_for image_name
	info "Building #{image_name}"
	cmd="sudo docker build -t vlipco/#{image_name} --rm #{image_folder}"
	# start writing before creating the image
	# so that changes to files during creationg result in run next time
	dockerfile = dockerfile_for(image_name)
	digest = Digest::MD5.hexdigest File.read(dockerfile)
	File.open( t.name, 'w+') {|f| f.write digest }
	sh cmd do |ok,res|
		if !ok
			rm t.name
			error "Docker build failed"
		end
	end	
end