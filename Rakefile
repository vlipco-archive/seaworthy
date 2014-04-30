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

	desc "All images in the project"
	task all: IMAGES

end