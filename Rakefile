require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)

def folder_for(img)
  return File.expand_path "docker-images/#{img}", ROOT_DIR
end

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

def buildfiles_pattern
	/.*\.build/
end

def buildfile_for(img)
  return "#{folder_for(img)}/.build"
end

def image_from_buildfile(buildfile)
	buildfile.pathmap('%d').pathmap('%n')
end

def dependencies_for(buildfile)
	#debug buildfile
  image_name = image_from_buildfile buildfile
  dependencies = case image_name.to_sym
    when :hull then []
    when :deckhouse then [:hull]
    when :waypoint then [:hull, :deckhouse]
    when :harbor then [:hull, :deckhouse]
    when :ship then [:hull]
    when :ferry then [:hull, :deckhouse]
    else raise "Unknown image: #{image_name}"
  end.map {|d| buildfile_for(d) }
  # Each build also depends on it's own buildfile!
  img_files = Rake::FileList.new "#{folder_for(image_name)}/**/*"
  #img_files.exclude '.build'
  dependencies.concat img_files
  #debug "DEPENDENCIES FOR #{buildfile}: #{dependencies}"
  return dependencies
end

#directory '.cache'

rule buildfiles_pattern => ->(f){ dependencies_for(f) } do |t|
	#Rake::Task[".cache"].invoke
	image_name = image_from_buildfile t.name
	image_folder = folder_for image_name
	info "Building #{image_name} from #{image_folder}"
	cmd="sudo docker build -t vlipco/#{image_name} --rm #{image_folder}"
	# start writing before creating the image so that changes during
	# the task execution make future calls of the same task result in a run
	File.open( t.name, 'w+') {|f| f.write Time.now }
	begin
		log "Running: #{cmd}"
		out = `#{cmd} 2> /dev/null` # %x(#{cmd})
		log "Writing command output to #{t.name}"
		File.open( t.name, 'w+') {|f| f.write out }
	rescue
		#log "---"
		error "Docker build failed."
		rm t.name
		#log "---"

	end
	#sh cmd do |ok,res|
	#	binding.pry
	#	if !ok
	#		rm t.name
	#		
	#	end
	#end	
end

IMAGES=%w(hull deckhouse waypoint harbor ship ferry)

namespace :build do

	IMAGES.each do |img|
		desc "Build vlipco/#{img} and its dependencies"
		task img => buildfile_for(img)
	end

	desc "Build all images in the project"
	task all: IMAGES

end

namespace :clean do
	desc "Clear any .build files tracking previous docker builds"
	task :buildfiles do
		buildfiles = Rake::FileList.new('docker-images/**/.build')
		buildfiles.each { |f| rm f }
	end
end