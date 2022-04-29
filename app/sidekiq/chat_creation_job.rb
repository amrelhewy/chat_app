# frozen_string_literal: true

class ChatCreationJob
  include Sidekiq::Job
  sidekiq_options queue: :chat_creation_queue

  def perform(token, chat_number)
    ChatCreationService.new(token, chat_number).call
  end
end
