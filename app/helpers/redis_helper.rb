# frozen_string_literal: true

module RedisHelper
  def redis_running?
    REDIS.ping
    true
  rescue StandardError
    false
  end
end
