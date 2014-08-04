function task.harbor.balance.run
	log.info "Balancing local harbor" (date)

	for ctr in (ctr.mine)
		set ctr_role (echo "$ctr" | awk -F'/' '{print $1}' )
		set harbor_role (swrth config harbor.role)

		if [ "$ctr_role" != "$harbor_role" ]
			echo "ERROR: Role mismatch $ctr doesn't belong to $harbor_role role"
		else
			set ctr_name (echo "$ctr" | awk -F'/' '{print $2}' )

			set -l ctr_app (echo "$ctr_name" | awk -F'.' '{print $1}')
			set -l ctr_tag (echo "$ctr_name" | awk -F'.' '{print $2}')
			set prefix (docker.registry_prefix)
			set -l image_name "$prefix/$ctr_app:$ctr_tag"

			if not docker.tcp ps | grep -q -G "$ctr"
				log.info "Pulling $image_name"
				docker.tcp pull "$image_name" 1> /dev/null
				log.info "Running $ctr"
				docker.tcp rm "$ctr" ^&- ; or true
				set role (swrth config harbor.role)
				set consul_env (ctr.env "$role/$ctr_app")
				eval docker.tcp run -dt --name "$ctr_name" -P \
				  -e CONSUL_NAME="$ctr_app" -e CONSUL_TAGS="$ctr_tag" $consul_env \
				  "$image_name"
			else
				log.info "$ctr is already running"
			end
		end

	end

	# todo handle container removal

	for ctr in (docker.tcp ps -q)
		set name (_container_name $ctr)
		# check if format is xxx.yyy.d, e.g: ruby.4eef16f.1
		if echo $name | grep -qE '^[^.]*\.[^.]*\.[0-9]+'
			# stop this container unless an offer for it exists
			if not ctr.mine | grep -qG $name
				echo "Container $name must be stopped"
				docker.tcp stop $ctr
				docker.tcp rm -f $ctr
			end
		end
	end

	atn.done "Harbor has been balanced"

end