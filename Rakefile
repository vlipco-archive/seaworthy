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
CLUSTER_CONTAINERS = %w(admiral waypoint public_harbor internal_harbor)

task :pry do
  binding.pry
end

namespace :build do

  IMAGES.each do |img|
    desc "Build vlipco/#{img}"
    task img => cache_buster_file(img)
  end

  all_cache_busters = IMAGES.map { |img| cache_buster_file(img) }

  desc "Build all images in the project"
  task all: all_cache_busters do
    info "All images up to date"
  end

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
  task launch: ["build:all"] do
    info "Launching cluster's Procfile"
    envfile = "dev-tools/cluster/cluster.env"
    procfile = "dev-tools/cluster/Procfile"
    exec "dev-tools/bin/forego start -e #{envfile} -f #{procfile}"
  end

  desc "Attach to admiral and monitor the cluster"
  task :monitor do
    info "Starting Serf oberserver (ctrl+c to exit)"		
    switchns :admiral, "/srv/bin/serf monitor"
  end

  desc "Attach to admiral and run bash"
  task :shell do
    info "Running bash in the context of the admiral container"
    switchns :admiral, "/bin/bash"
  end

end

namespace :dev do	

  desc "Kill all running docker containers"
  task :clean_docker do
    info "Killin all running docker containers"
    sh "docker stop -t 1 $(docker ps -a -q)"
    #sh "docker rm $(docker ps -a -q)"
  end

  desc "Pushes a sample-app/ruby to the cluster"
  task :fake_deploy do
    info "Pushing sample app to the cluster"
    sh "dev-tools/bin/fake-release sample-apps/ruby", verbose: false
  end

  desc "Creates a cluster, fakes a deploy and performs some tests"
  task :test do
    # Nugget tests?
    info "Performing tests..."
  end

end
