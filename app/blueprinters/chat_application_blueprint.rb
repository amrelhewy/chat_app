# frozen_string_literal: true

class ChatApplicationBlueprint < Blueprinter::Base
  identifier :id, name: :token
  fields :name
end
