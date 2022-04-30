# frozen_string_literal: true

Counter::Cache.configure do |c|
  c.default_worker_adapter = ChatCounterJob
  c.recalculation_delay    = 1.hour
  c.redis_pool             = Redis.new(host: ENV.fetch('REDIS_HOST', nil),
                                       port: ENV.fetch('REDIS_PORT', nil),
                                       db: ENV.fetch('REDIS_COUNTER_CACHE_DB', nil))
end
