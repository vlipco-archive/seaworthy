def info(msg)
	puts "\n---> #{msg}\n".colorize :green
end

def log(msg)
	puts "     #{msg}"
end

#def error(msg)
#	puts "\n---> #{msg}\n".colorize :red
#end

def debug(msg)
  puts "\n---> #{msg}\n".colorize :magenta
end

