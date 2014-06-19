#!/usr/bin/env fish

function atn.shift
	set -l length (count $argv)
	if [ $length > 1 ]
		echo $$argv[1][1]
		set $argv[1] $$argv[1][2..-1]
		return 0
	else if [ $length == 1 ]
		echo $$argv[1][1]
		return 0
	else
		return 1
	end
end

echo $argv
set -e argv[1]
echo $argv