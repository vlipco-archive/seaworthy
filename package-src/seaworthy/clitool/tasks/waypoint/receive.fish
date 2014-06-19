
# WARN: don't print anything here, it's against the protocol
function task.waypoint.receive.run
	set RECEIVE_USER  $argv[2]
    set RECEIVE_FINGERPRINT  $argv[3]
    
    # ssh provides the original requested command in $SSH_ORIGINAL_COMMAND
    # from that comman we obtain the name of the repo that's being pushed
    # a sample value of that var would be: git-receive-pack 'external/ruby2'
    set RECEIVE_REPO  (echo $SSH_ORIGINAL_COMMAND| awk '{print $argv[2]}'| perl -pe 's/(?<!\\)'\''//g'| sed 's/\\'\''/'\''/g')

        
    set REPO_PATH "$GIT_HOME/$RECEIVE_REPO"

    if [ ! -d $REPO_PATH ]
      mkdir -p $REPO_PATH
      cd $REPO_PATH
      git init --bare > /dev/null
    end

    cd $GIT_HOME
    set PRERECEIVE_HOOK "$REPO_PATH/hooks/pre-receive"
    
    cat > $PRERECEIVE_HOOK <<-EOF
		#!/bin/bash
		cat | swrth waypoint process
	EOF

    
    chmod +x $PRERECEIVE_HOOK
    git-shell -c "$SSH_ORIGINAL_COMMAND"
end