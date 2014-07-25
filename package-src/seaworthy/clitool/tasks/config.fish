function task.config.run -a key value
	if [ -z "$key" ]
		for file in (find /etc/swrth -type f)
			echo (_to_key $file)" = "(cat $file)
		end
		exit 0		
	end

	if [ -z "$value" ]
		echo (cat (_to_path $key))
	else
		echo $value > (_to_path $key)
		echo "$key = $value"
	end
end

function _to_path -a key
	set relativePath (echo $key | sed 's/\./\//g')
	echo "/etc/swrth/$relativePath"
end

function _to_key -a path
	echo $path | sed 's|/etc/swrth/||g' | sed 's|/|.|g'
end