say "Installing dependencies"

bundle_base="vendor/bundle/ruby/2.1.1"
mkdir -p $bundle_base

# Update environment for this run
export GEM_PATH="$build_dir/$bundle_base"

path_precede "$build_dir/vendor/$ruby_version/bin"
path_precede "$build_dir/$bundle_base/bin"
path_precede "$build_dir/vendor/bundle/bin"
path_precede "$build_dir/bin"

# Check previous ruby version, buildpack revision
# and load cached data
import "handle-state"

# Install bundler
bundler_tgz="$buildpack_dir/vendor/bundler-$bundler_version.tgz"
tar -xzf $bundler_tgz -C $bundle_base

export NOKOGIRI_USE_SYSTEM_LIBRARIES=true

bundle "_${bundler_version}_" install --deployment --jobs 4 --clean \
    --without development:test --binstubs vendor/bundle/bin | group_output

say "Removing unwanted files to reduce slug size"

rm -rf "$bundle_base/doc"
rm -rf "$bundle_base/cache"
if [ -d "$bundle_base/bundler/gems" ]; then
    find "$bundle_base/bundler/gems" -type d -name .git -print0 | xargs -0 rm -rf
fi

cache_store .bundle
cache_store vendor/buildpack
cache_store vendor/bundle
