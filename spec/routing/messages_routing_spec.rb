# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :routing do
  describe 'routing' do
    let(:endpoint) { '/api/v1/chat_applications/1/chats/2/messages' }

    it 'routes to #index' do
      expect(get: endpoint).to route_to('api/v1/messages#index', chat_application_token: '1', chat_number: '2')
    end

    it 'routes to #create' do
      expect(post: endpoint).to route_to('api/v1/messages#create', chat_application_token: '1', chat_number: '2')
    end
  end
end
