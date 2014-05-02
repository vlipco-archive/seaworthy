require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)
require_relative 'tasks/helpers.rb'
Rake.add_rakelib :tasks

IMAGES=%w(hull deckhouse waypoint harbor ship ferry)

namespace :build do

	IMAGES.each do |img|
		desc "Build vlipco/#{img} and its dependencies"
		task img => ".cache/#{img}.build"
	end

	desc "Build all images in the project"
	task all: IMAGES

	desc "Clear any track of previous build stored in .cache"
	task :clean_cache do
		rm_rf '.cache'
	end

end

CLUSTER_CONTAINERS = %w(admiral waypoint harbor)

namespace :cluster do


	desc "Starts named containers simulation a real cluster"
	task start: ["build:all"] do
		start_ctr :admiral, port: 7649, img: "vlipco/deckhouse", cmd: "/srv/bin/start-serf"
		start_ctr :waypoint, port: 7650, img: "vlipco/waypoint"
		start_ctr :harbor, port: 7651, img: "vlipco/harbor"
	end

	desc "Removed the named containers"
	task :clean do
		CLUSTER_CONTAINERS.each {|ctr| remove_container ctr}
		# TODO add ships
	end

	desc "Clean all container followed by a cluster start"
	task reset: [:clean,:start]

end



namespace :integration do

	desc "Pushes a sample app to the cluster"
	task fake_deploy: ["cluster:build"] do
	end

	desc "Creates a cluster, fakes a deploy and performs some tests"
	task test: [:fake_deploy] do
		# Nugget tests?
	end

end