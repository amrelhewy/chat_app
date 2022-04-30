# frozen_string_literal: true

class FallbackService
  def initialize(chat_application_id)
    @chat_application_id = chat_application_id
  end

  def fallback_to_database_and_create_chat
    @latest_chat = ChatApplication.find_by(id: @chat_application_id).chats.last
    latest_chat_number = @latest_chat.present? ? @latest_chat.number : 0 # First chat in this application
    # Create the chat -- this is obviously much slower than redis and sidekiq
    # but this guarantees reliabillity in case redis went down.
    Chat.create!(number: latest_chat_number + 1, chat_application_id: @chat_application_id)
  rescue ActiveRecord::RecordNotUnique
    retry # since there is a unique index on chat number and token. retry the process if any race conditions occur
  end

  def sync_redis_chat_number
    @latest_chat = ChatApplication.find_by(id: @chat_application_id).chats.last
    REDIS.set("chat_app_#{@chat_application_id}", @latest_chat.number)
    @latest_chat.chat_application.redis_synced = true
    @latest_chat.chat_application.save
  end
end
