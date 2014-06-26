
# WARN: don't print anything here, it's against the protocol
function task.waypoint.receive.run -a rcv_x rcv_user 
    
    #log.debug "Original command $SSH_ORIGINAL_COMMAND"

    # ssh provides the original requested command in $SSH_ORIGINAL_COMMAND
    # from that comman we obtain the name of the repo that's being pushed
    # a sample value of that var would be: git-receive-pack 'external/ruby2'
    #set REPO  (echo $SSH_ORIGINAL_COMMAND| awk '{print $argv[2]}'| perl -pe 's/(?<!\\)'\''//g'| sed 's/\\'\''/'\''/g')

    # potential security hole?
    set -gx REPO (echo $SSH_ORIGINAL_COMMAND| awk '{print $2}'| sed "s|'||g")
        
    set repo_path "$GIT_HOME/$REPO"
    #log.debug "Using repo path $repo_path"

    if [ ! -d $repo_path ]
      mkdir -p $repo_path
      cd $repo_path
      git init --bare > /dev/null
    end
    
    set prcv_hook "$repo_path/hooks/pre-receive"

    begin
        echo '#!/usr/bin/env fish'
        echo 'swrth waypoint deploy "$REPO"'
    end > $prcv_hook
    
    #log.debug "Changing permissions of $prcv_hook"
    chmod +x $prcv_hook

    git-shell -c "$SSH_ORIGINAL_COMMAND"
end