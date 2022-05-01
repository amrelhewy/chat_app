# frozen_string_literal: true

# Dynamic creation service for chats and messages
class CreationService
  ENTITIES = %i[chat message].freeze

  def initialize(entity)
    @entity = entity
  end

  def call(entity_params)
    entity_class.create(**entity_params)
  end

  ENTITIES.each do |entity|
    define_method("latest_#{entity}_number") do |redis_key|
      # Incr is concurrent safe since redis is single threaded and provides serialization and atmoicity
      # That is indeed if multiple rails servers access this one redis instance
      REDIS.incr(redis_key)
    end
  end

  private

  def entity_class
    @entity.to_s.camelize.constantize
  end
end
