
# WARN: don't print anything here, it's against the protocol
function btask.waypoint.receive.run {
	export RECEIVE_USER=$2
    export RECEIVE_FINGERPRINT=$3
    
    _netlog $SSH_ORIGINAL_COMMAND
    # ssh provides the original requested command in $SSH_ORIGINAL_COMMAND
    # from that comman we obtain the name of the repo that's being pushed
    # a sample value of that var would be: git-receive-pack 'external/ruby2'
    export RECEIVE_REPO="$(echo $SSH_ORIGINAL_COMMAND| awk '{print $2}'| perl -pe 's/(?<!\\)'\''//g'| sed 's/\\'\''/'\''/g')"

    _netlog $RECEIVE_REPO
    
    REPO_PATH="$GIT_HOME/$RECEIVE_REPO"

    if [[ ! -d $REPO_PATH ]]; then
      mkdir -p $REPO_PATH
      cd $REPO_PATH
      git init --bare > /dev/null
    fi

    cd $GIT_HOME
    PRERECEIVE_HOOK="$REPO_PATH/hooks/pre-receive"
    
    cat > $PRERECEIVE_HOOK <<-EOF
		#!/bin/bash
		cat | swrth waypoint process
	EOF

    _netlog $PRERECEIVE_HOOK
    _netlog "$(cat $PRERECEIVE_HOOK)"
    
    chmod +x $PRERECEIVE_HOOK
    git-shell -c "$SSH_ORIGINAL_COMMAND"
}