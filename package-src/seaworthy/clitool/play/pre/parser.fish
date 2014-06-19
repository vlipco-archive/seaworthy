#!/usr/bin/env fish

echo "Parsing $argv"

cat $argv[1] | tr -d '?' | source