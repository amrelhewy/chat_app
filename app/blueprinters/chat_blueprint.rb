# frozen_string_literal: true

class ChatBlueprint < Blueprinter::Base
  fields :number

  view :create do
    fields :chat_application_token
  end
end
