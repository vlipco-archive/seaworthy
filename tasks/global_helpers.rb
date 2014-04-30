#puts ROOT_DIR
def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def error(msg)
	puts "\n---> #{msg}\n".colorize :red
end

def folder_for(img)
  return File.expand_path "docker-images/#{img}", ROOT_DIR
end

def dockerfile_for(img)
  return "#{folder_for(img)}/Dockerfile"
end

