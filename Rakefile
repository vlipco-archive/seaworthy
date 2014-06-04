require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)
TMPDIR = ENV['TMPDIR'] || '/tmp'

require_relative 'misc/dev-tools/rake_helpers.rb'

IMAGES=%w(waypoint harbor ship ferry)

task :pry do
  binding.pry
end

namespace :build do

  IMAGES.each do |img|
    img_name = img.split('_')[-1]
    desc "Build vlipco/#{img_name}"
    task img_name => cache_buster_file(img)
  end

end

namespace :push do
  desc "Pushes a sample-app/ruby to the cluster as ruby1"
  task :ruby1 do
    push_app "external/docker-images/sti-ruby", "ruby1"
  end

  desc "Pushes a sample-app/ruby to the cluster as ruby2"
  task :ruby2 do
    push_app "external/docker-images/sti-ruby", "ruby2"
  end

  desc "Pushes a sample-app/static to the cluster as static1"
  task :static1 do
    push_app "external/docker-images/sti-static", "static1"
  end
end
