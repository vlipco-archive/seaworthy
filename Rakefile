require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)
Rake.add_rakelib :tasks
require_relative 'tasks/global_helpers.rb'

IMAGES=%w(hull deckhouse waypoint harbor ship ferry)

namespace :build do

	IMAGES.each do |img|
		desc "Build vlipco/#{img} and its dependencies"
		task img => ".cache/#{img}.build"
	end

	desc "Build all images in the project"
	task all: IMAGES

end

desc "Clear any track of previous build stored in .cache"
task :clean_cache do
	rm_rf '.cache'
end

# TODO create cluster?
# TODO clean cluster
# TODO serf events
# TODO make fake release

# TODO full integration test