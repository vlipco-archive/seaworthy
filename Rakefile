require 'rubygems'
require 'bundler/setup'
Bundler.require :default

ROOT_DIR = File.dirname(__FILE__)
TMPDIR = ENV['TMPDIR'] || '/tmp'

require_relative 'dev-tools/rake_helpers.rb'

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

namespace :clean do
  desc "Clear any .build files tracking previous docker builds"
  task :tmp do
    info "Deleting .tmp folder recursively"
    rm_rf '.tmp', verbose: false
  end
  desc "Kill all running docker containers"
  task :docker do
    info "Killin all running docker containers"
    sh "docker stop -t 1 $(docker ps -a -q)"
    #sh "docker rm $(docker ps -a -q)"
  end
end

namespace :push do
  desc "Pushes a sample-app/ruby to the cluster as ruby1"
  task :ruby1 do
    push_app "sample-apps/ruby", "ruby1"
  end

  desc "Pushes a sample-app/ruby to the cluster as ruby2"
  task :ruby2 do
    push_app "sample-apps/ruby", "ruby2"
  end

  desc "Pushes a sample-app/static to the cluster as static1"
  task :static1 do
    push_app "sample-apps/static", "static1"
  end
end
