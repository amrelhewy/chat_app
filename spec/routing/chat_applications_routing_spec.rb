# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ChatApplicationsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/chat_applications').to route_to('api/v1/chat_applications#index')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/chat_applications/1').to route_to('api/v1/chat_applications#show', token: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/chat_applications').to route_to('api/v1/chat_applications#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/chat_applications/1').to route_to('api/v1/chat_applications#update', token: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/chat_applications/1').to route_to('api/v1/chat_applications#update', token: '1')
    end
  end
end
