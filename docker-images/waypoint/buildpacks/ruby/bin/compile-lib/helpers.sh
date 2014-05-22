#!/bin/bash
set -eo pipefail

say() {
    echo "-----> $*"
}

error() {
    echo >&2 " !     $*"
    exit 1
}

group_output() {
    sed -u 's/^/│ /'
}

cache_load() {
    if [ -e "$cache_dir/$1" ]; then
        mkdir -p "$1"
        cp -a "$cache_dir/$1/." "$1"
    fi
}

cache_store() {
    if [ -e "$1" ]; then
        rm -rf "$cache_dir/$1"
        mkdir -p "$cache_dir/$1"
        cp -a "$1/." "$cache_dir/$1"
    fi
}

path_precede() {
    export PATH="$1:$PATH"
}