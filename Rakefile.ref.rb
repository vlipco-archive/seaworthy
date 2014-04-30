require 'rake'
require 'docker'

Rake.application.options.trace_rules = true

task :default => :help

Dir.chdir "project"
files = Rake::FileList["**/*.md", "**/*.markdown"]
files.exclude("~*")

task :help do
	puts "OK"
end

image 'repo:tag' do
  image = Docker::Image.create('fromImage' => 'repo', 'tag' => 'old_tag')
  image = Docker::Image.run('rm -rf /etc').commit
  image.tag('repo' => 'repo', 'tag' => 'tag')
end

image 'repo:new_tag' => 'repo:tag' do
  image = Docker::Image.create('fromImage' => 'repo', 'tag' => 'tag')
  image = image.insert_local('localPath' => 'some-file.tar.gz', 'outputPath' => '/')
  image.tag('repo' => 'repo', 'tag' => 'new_tag')
end

#file "??" => each_dockerfile do
# sh .. how to build the image and create ??
#end

rule ".html" => ->(f){source_for_html(f)} do |t|
  sh "pandoc -o #{t.name} #{t.source}"
end

