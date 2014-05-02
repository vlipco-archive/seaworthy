def cache_file_for(img)
  return ".cache/#{img}.build"
end

def dependencies_for(cache_file)
  image_name = cache_file.pathmap '%n'
  dependencies = case image_name.to_sym
    when :hull    then []
    when :deckhouse then [cache_file_for(:hull)]
    when :waypoint  then [cache_file_for(:hull), cache_file_for(:deckhouse)]
    when :harbor    then [cache_file_for(:hull), cache_file_for(:deckhouse)]
    when :ship    then [cache_file_for(:hull)]
    when :ferry   then [cache_file_for(:hull), cache_file_for(:deckhouse)]
    else      raise "Unknown image: #{image_name}"
  end
  dependencies.unshift '.cache' # cache dir dependency
  # Each build also depends on it's own dockerfile!
  dependencies.push dockerfile_for(image_name)
  #puts "DEPS #{cache_file} = #{dependencies}"
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