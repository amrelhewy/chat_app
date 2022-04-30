# frozen_string_literal: true

class ChatCreationJob
  include Sidekiq::Job
  sidekiq_options queue: :chat_creation_queue

  def perform(chat_app_id, chat_number)
    ChatCreationService.new(chat_app_id, chat_number).call
  end
end
