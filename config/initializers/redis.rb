# frozen_string_literal: true

REDIS_CLIENT = Redis.new(host: ENV.fetch('REDIS_HOST', nil), port: ENV.fetch('REDIS_PORT', nil),
                         db: ENV.fetch('REDIS_DB', nil))

REDIS_TEST_CLIENT = Redis.new(host: ENV.fetch('REDIS_TEST_HOST', nil), port: ENV.fetch('REDIS_PORT', nil),
                              db: ENV.fetch('REDIS_DB', nil))

REDIS = Rails.env.test? ? REDIS_TEST_CLIENT : REDIS_CLIENT
