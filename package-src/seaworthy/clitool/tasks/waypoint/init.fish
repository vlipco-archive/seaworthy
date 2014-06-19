function task.waypoint.init.run
	useradd -d $GIT_HOME git ; or true
    #cat > $GIT_HOME/receiver <<-EOF
	#	#!/bin/bash
	#	exec /usr/bin/slug-receiver \$argv
	#EOF
    #chmod +x $GIT_HOME/receiver
    chown -R git $GIT_HOME
    #echo "Created receiver script in $GIT_HOME for user 'git'."
end