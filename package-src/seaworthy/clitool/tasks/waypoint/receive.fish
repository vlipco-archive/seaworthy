
# WARN: don't print anything here, it's against the protocol
function task.waypoint.receive.run
    
    log.debug "Original command $SSH_ORIGINAL_COMMAND"

	set RECEIVE_USER  $argv[2]
    set RECEIVE_FINGERPRINT  $argv[3]
    
    # ssh provides the original requested command in $SSH_ORIGINAL_COMMAND
    # from that comman we obtain the name of the repo that's being pushed
    # a sample value of that var would be: git-receive-pack 'external/ruby2'
    #set RECEIVE_REPO  (echo $SSH_ORIGINAL_COMMAND| awk '{print $argv[2]}'| perl -pe 's/(?<!\\)'\''//g'| sed 's/\\'\''/'\''/g')

    # potential security hole?
    set RECEIVE_REPO (echo $SSH_ORIGINAL_COMMAND| awk '{print $2}'| sed "s|'||g")
        
    set REPO_PATH "$GIT_HOME/$RECEIVE_REPO"
    log.debug "Using repo path $REPO_PATH"

    if [ ! -d $REPO_PATH ]
      mkdir -p $REPO_PATH
      cd $REPO_PATH
      git init --bare > /dev/null
    end

    cd $GIT_HOME
    
    set PRERECEIVE_HOOK "$REPO_PATH/hooks/pre-receive"

    # no heredocs, hence the complicated echo!   
    echo "#!/bin/bash" > $PRERECEIVE_HOOK
    echo "cat | swrth waypoint process" >> $PRERECEIVE_HOOK
    
    log.debug "Changing permissions of $PRERECEIVE_HOOK"
    chmod +x $PRERECEIVE_HOOK
    git-shell -c "$SSH_ORIGINAL_COMMAND"
end