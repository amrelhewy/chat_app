# frozen_string_literal: true

class ChatCreationJob
  include Sidekiq::Job
  sidekiq_options queue: :chat_creation_queue

  def perform(chat_app_id, chat_number)
    params = { chat_application_id: chat_app_id, number: chat_number }
    CreationService.new(:chat).call(params)
  end
end
