# frozen_string_literal: true

class MessageCreationJob
  include Sidekiq::Job
  sidekiq_options queue: :message_creation_queue

  def perform(body, message_number, chat_id)
    params = { chat_id: chat_id, number: message_number, body: body }
    CreationService.new(:message).call(params)
  end
end
