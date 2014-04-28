say "Adding $ruby_version"

ruby_tgz="$buildpack_dir/vendor/$ruby_version-p$patch_level.tgz"
ruby_destination="$build_dir/vendor/$ruby_version"

mkdir -p $ruby_destination
tar -xzf $ruby_tgz -C $ruby_destination

ruby="$ruby_destination/bin/ruby"

ruby_profile="$bin_dir/compile-lib/ruby-profile.sh"
cp $ruby_profile $profile_dir/