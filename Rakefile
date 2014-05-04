require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)

[

	'dev-tools/lib/logging_helpers.rb', 
	'dev-tools/lib/build_helpers.rb',
	'dev-tools/lib/cluster_helpers.rb'

].each {|x| require_relative x }

IMAGES=%w(hull deckhouse waypoint harbor ship ferry)
CLUSTER_CONTAINERS = %w(admiral waypoint harbor)

namespace :build do

	IMAGES.each do |img|
		desc "Build vlipco/#{img}"
		task img => dependencies_for(img) do
			# TODO support force option
			build_image img
		end
	end

	desc "Build all images in the project"
	task all: IMAGES

end

namespace :clean do
	desc "Clear any .build files tracking previous docker builds"
	task :tmp do	
		info "Deleting .tmp folder recursively"	
		rm_rf '.tmp', verbose: false
	end
end


namespace :cluster do

	desc "Starts named containers simulation a real cluster"
	task start: ["build:all"] do
		info "Launching cluster containers"
		start_ctr :admiral, port: 7649, img: "vlipco/deckhouse", 
			cmd: "/srv/bin/start-serf"

		start_ctr :waypoint, port: 7650, img: "vlipco/waypoint", 
			options: "-p 5000:5000 -p 5100:5100"

		start_ctr :harbor, port: 7651, img: "vlipco/harbor"
	end

	desc "Removed the named containers"
	task :clean do
		info "Removing cluster's containers"
		CLUSTER_CONTAINERS.each do |ctr|
			log "- #{ctr}"
			remove_container ctr
		end
		# TODO add ships to the list of coantiners to remove
	end

	desc "Clean all container followed by a cluster start"
	task reset: [:clean,:start]

end

namespace :integration do

	desc "Pushes a sample-app/ruby to the cluster"
	task :fake_deploy do
		info "Pushing sample app to the cluster"
		sh "dev-tools/bin/fake-release sample-apps/ruby"
	end

	desc "Creates a cluster, fakes a deploy and performs some tests"
	task test: [:fake_deploy] do
		# Nugget tests?
		info "Performing tests..."
	end

end