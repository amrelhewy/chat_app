#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

gem install bundler
bundle install
bundle exec overcommit --install
exec "$@"
