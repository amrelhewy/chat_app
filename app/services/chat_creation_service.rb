# frozen_string_literal: true

class ChatCreationService
  def initialize(token, chat_number = nil)
    @token = token
    @chat_number = chat_number
  end

  def call
    Chat.create(chat_application_token: @token, number: @chat_number)
  end

  # Each token is a key with a chat number as a value in redis that increments on every creation
  def latest_chat_number
    # Incr is concurrent safe since redis is single threaded and provides serialization and atmoicity
    REDIS.incr(@token)
  end
end
