..Forego has been compiled from this one:

https://github.com/davidpelaez/forego

There was a bug in the port numbers, waiting until new official binary is released.

# Source docker env inside a container
$(cat .dockerenv | ruby -ne 'eval($_).each {|x| puts "export #{x}"}')