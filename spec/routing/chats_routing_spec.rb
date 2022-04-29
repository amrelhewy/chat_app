# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ChatsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/chat_applications/1/chats').to route_to('api/v1/chats#index', chat_application_token: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/chat_applications/1/chats').to route_to('api/v1/chats#create', chat_application_token: '1')
    end
  end
end
