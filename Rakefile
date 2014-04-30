require 'rubygems'
require 'bundler/setup'
Bundler.require :default

#Rake.add_rakelib 'tasks'
#dockerfiles = 

def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def error(msg)
	puts "\n---> #{msg}\n".colorize :red
end

def folder_for(img)
	path = "../docker-images/#{img}"
	return File.expand_path path, __FILE__
end

def cache_file(img)
	return ".cache/#{img}.build"
end

def dependencies_for(cache_file)
	image_name = cache_file.pathmap '%n'
	dependencies = case image_name.to_sym
		when :hull 		then []
		when :deckhouse then [cache_file(:hull)]
		when :waypoint 	then [cache_file(:hull), cache_file(:deckhouse)]
		when :harbor  	then [cache_file(:hull), cache_file(:deckhouse)]
		when :ship 		then [cache_file(:hull)]
		when :ferry  	then [cache_file(:hull), cache_file(:deckhouse)]
		else 			raise "Unknown image: #{image_name}"
	end
	#puts "DEPS #{cache_file} => #{dependencies}"
	return dependencies.unshift '.cache' # dir dependency
end

directory '.cache'

rule( /\.cache\/.*/ => ->(f){dependencies_for(f)}) do |t|
	image_name = t.name.pathmap '%n'
	image_folder = folder_for image_name
	info "Building #{image_name} #{t.sources} => #{t.name}"
	cmd="docker build -t vlipco/#{image_name} --rm #{image_folder} | bin/indent"
	sh cmd do |ok,res|
		if ok
			dockerfile = "#{image_folder}/Dockerfile"
			puts "DCOKERFILE: #{dockerfile}"
			digest = Digest::MD5.hexdigest File.read(dockerfile)
			#File.open( t.name, 'w+') {|f| f.write digest }
		else
			error "Docker build failed"
		end
	end	
end

namespace :build do

end