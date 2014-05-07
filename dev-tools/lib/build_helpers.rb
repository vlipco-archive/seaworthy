def folder_for(img)
  return File.expand_path "docker-images/#{img}", ROOT_DIR
end

def dependencies_for(img)
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

def cache_buster_file(img)
  ".tmp/#{img}.last-deps"
end

def cache_buster_val(img)
  result = dependencies_for(img).push(img).map do |f| 
    timestamp = %x(date -r #{folder_for(f)} +'%s')
    "#{f} #{timestamp}"
  end.join ""
end

def build_image(img)
  cache_buster = cache_buster_file img
      expected_val = cache_buster_val img

      should_build = true

      if File.exists? cache_buster
        should_build = ( File.read(cache_buster) != expected_val )
      end

      if should_build
        info "Building #{img}"
        cmd="docker build -t vlipco/#{img} #{folder_for(img)}"
        mkdir_p '.tmp', verbose: false
        File.open(cache_buster, 'w+') {|f| f.write expected_val}
        sh cmd, verbose: false do |ok,res|
          if !ok
            rm cache_buster
            error "Docker build of #{img} failed"
          end
        end
      end
end