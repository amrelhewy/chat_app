# frozen_string_literal: true

class ChatCreationService
  def initialize(chat_application_id, chat_number = nil)
    @chat_application_id = chat_application_id
    @chat_number = chat_number
  end

  def call
    Chat.create!(chat_application_id: @chat_application_id, number: @chat_number)
  end

  # Each token is a key with a chat number as a value in redis that increments on every creation
  def latest_chat_number
    # Incr is concurrent safe since redis is single threaded and provides serialization and atmoicity
    # That is indeed if multiple rails servers access this one redis instance
    REDIS.incr("chat_app_#{@chat_application_id}")
  end
end
