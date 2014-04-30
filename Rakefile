require 'rubygems'
require 'bundler/setup'
Bundler.require :default

IMAGES=%w(hull deckhouse waypoint harbor ship ferry)

def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def error(msg)
	puts "\n---> #{msg}\n".colorize :red
end

def folder_for(img)
	return File.expand_path "../docker-images/#{img}", __FILE__
end

def dockerfile_for(img)
	return "#{folder_for(img)}/Dockerfile"
end

def cache_file_for(img)
	return ".cache/#{img}.build"
end

def dependencies_for(cache_file)
	image_name = cache_file.pathmap '%n'
	dependencies = case image_name.to_sym
		when :hull 		then []
		when :deckhouse then [cache_file_for(:hull)]
		when :waypoint 	then [cache_file_for(:hull), cache_file_for(:deckhouse)]
		when :harbor  	then [cache_file_for(:hull), cache_file_for(:deckhouse)]
		when :ship 		then [cache_file_for(:hull)]
		when :ferry  	then [cache_file_for(:hull), cache_file_for(:deckhouse)]
		else 			raise "Unknown image: #{image_name}"
	end
	dependencies.unshift '.cache' # cache dir dependency
	# Each build also depends on it's own dockerfile!
	dependencies.push dockerfile_for(image_name)
	return dependencies
end

directory '.cache'

rule( /\.cache\/.*/ => ->(f){dependencies_for(f)}) do |t|
	image_name = t.name.pathmap '%n'
	image_folder = folder_for image_name
	info "Building #{image_name}"
	cmd="docker build -t vlipco/#{image_name} --rm #{image_folder} | bin/indent"
	sh cmd do |ok,res|
		if ok
			dockerfile = dockerfile_for(image_name)
			digest = Digest::MD5.hexdigest File.read(dockerfile)
			File.open( t.name, 'w+') {|f| f.write digest }
		else
			error "Docker build failed"
		end
	end	
end

namespace :build do

	IMAGES.each do |img|
		desc "Build vlipco/#{img} and its dependencies"
		task img => ".cache/#{img}.build"
	end

	desc "All images in the project"
	task all: IMAGES

end