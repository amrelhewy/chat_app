#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
if [ -f /chat_app/tmp/pids/server.pid ]; then
  rm /chat_app/tmp/pids/server.pid
fi

gem install bundler
bundle install
bundle exec rails db:migrate
exec "$@"
