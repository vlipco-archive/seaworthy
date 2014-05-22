Ruby buildpack, heavily based on https://github.com/dpiddy/heroku-buildpack-ruby-minimal

#BUILDPACK_REVISION is used to clear the bundle when something about how we manage
# the bundle changes. 
# Revisions:
#
#   1: Implied as part of initial release
#   2: Change in `bundle install` environment to help nokogiri know to not compile
#      its own libxml and libxslt
#      ref https://github.com/heroku/heroku-buildpack-ruby/pull/124
#   3: Undo cleaning of `ext` directories because gems such as oj expect `ext` to
#      be usable as part of the require path.
# 4: Vlipco mods