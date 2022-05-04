# frozen_string_literal: true

module RedisRecoverable
  include RedisHelper
  extend ActiveSupport::Concern

  private

  def check_redis_sync_status(association, redis_key, extras = {})
    # Check if the chat application redis synced flag is true or false
    # if redis is back on and we're out of sync
    # Sync the redis token key with the updated value from the database and set redis sync to true again
    # this is a one time operation after redis recovers
    if !association.redis_synced? && redis_running?
      FallbackService.new(association.class.name, association.id, extras)
                     .send("sync_redis_#{controller_name.classify.underscore}_number", redis_key)
    end
  end

  def fallback_to_database(association, extras = {})
    # if Redis is down, we need to get the count from the db. This guarantees reliabillity
    # if we entered here, that means the redis synced of the application has to be set to false
    # if it's true we set it to false
    # entity is either a chat object or a chat application object
    entity_to_be_created = controller_name.classify # Get either a chat or a message

    association.update(redis_synced: false) if association.redis_synced? # update their parent association
    # either chat app or chat

    created_entity = FallbackService.new(association.class.name, association.id, extras)
                                    .send("fallback_to_database_and_create_#{entity_to_be_created.downcase}")

    render json: "#{entity_to_be_created}_blueprint".classify.constantize.render(created_entity), status: :created
  end
end
