if [ ! -e Gemfile.lock ]; then
    error "No Gemfile.lock. Check it into your repository."
fi

if [ ! -e Procfile ]; then
    error "No Procfile. Check it into your repository."
fi

if [ -e vendor/bundle ]; then
    error "Don't check your vendor/bundle directory into your repository."
fi