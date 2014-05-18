cache_load .bundle
cache_load vendor

mkdir -p vendor/buildpack

ruby_version_file="vendor/buildpack/ruby_version"
buildpack_revision_file="vendor/buildpack/buildpack_revision"

rename_previous() {
    rm $1.previous &> /dev/null || true
	mv $1.{current,previous} &> /dev/null || true
}

# Rename previous run info if it exists
rename_previous $ruby_version_file
rename_previous $buildpack_revision_file

# Saved this run's info
ruby -v > "$ruby_version_file.current"
echo $buildpack_revision > "$buildpack_revision_file.current"

check_ruby_version() {
    # See if the ruby version has changed, clear the bundle if so
    if ! cmp --quiet $ruby_version_file.{current,previous}; then
        echo "ruby version change detected, clearing cached bundle"
        echo "old: $(< $ruby_version_file.previous)"
        echo "new: $(< $ruby_version_file.current)"
        rm -rf vendor/bundle
        return 1 # used to prevent buildpack's rev check (nothing to delete!)
    fi
}

check_buildpack_revision() {
    # See if buildpack_revision has changed, clear the bundle if so
    if ! cmp --quiet $buildpack_revision_file.{current,previous}; then
        echo "buildpack revision change detected, clearing cached bundle"
        echo "old: $(< $buildpack_revision_file.previous)"
        echo "new: $(< $buildpack_revision_file.current)"
        rm -rf vendor/bundle
    fi
}

if [[ -e "$ruby_version_file.previous" ]]; then
    # This isn't the first run, check if bundle must be cleared
    check_ruby_version && check_buildpack_revision   
fi