# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/api/v1/:chat_application_token/chats', type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Chat. As you add validations to Chat, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    path '/api/v1/chat_applications/{chat_application_token}/chats' do
      get 'Retrieves all chats belonging to a specific application' do
        produces 'application/json'
        tags 'Chats'
        parameter name: :chat_application_token, in: :path, type: :string
        response '200', 'Get chats' do
          examples 'application/json' => [{ number: 1 }, { number: 2 }]
          it 'renders a successful response' do
            chat = create(:chat)
            get api_v1_chat_application_chats_path(chat.chat_application.token), as: :json
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.first['number']).to eq(chat.number)
          end

          it 'renders an empty array if token is invalid' do
            get api_v1_chat_application_chats_path('invalid_token'), as: :json
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.size).to eq(0)
          end
        end
      end
    end
  end

  describe 'POST /create' do
    before do
      REDIS.flushdb
      Sidekiq::Worker.clear_all
    end

    path '/api/v1/chat_applications/{chat_application_token}/chats' do
      post 'Creates a new chat' do
        produces 'application/json'
        tags 'Chats'
        parameter name: :chat_application_token, in: :path, type: :string
        let!(:chat_application) { create(:chat_application) }
        response '201', 'Successfully created' do
          it 'Successfully creates a chat corressponding to a certain token' do
            post api_v1_chat_application_chats_path(chat_application.token)
            expect(response).to have_http_status(:created)
            body = response.parsed_body
            expect(body['number']).to eq(1)
          end

          it 'Successfully adds the key value pair to redis where key is token and val is latest chat number' do
            post api_v1_chat_application_chats_path(chat_application.token)
            latest_chat_number = REDIS.get(chat_application.token)
            expect(latest_chat_number).to eq('1')
          end

          it 'Successfully enqueues a chat creation job to sidekiq' do
            expect do
              post api_v1_chat_application_chats_path(chat_application.token)
            end.to change(ChatCreationJob.jobs, :size).by(1)
          end

          it 'Successfully increments the chat number on every new chat per token creation' do
            3.times do |i|
              post api_v1_chat_application_chats_path(chat_application.token)
              expect(REDIS.get(chat_application.token)).to eq((i + 1).to_s)
            end
          end
        end

        response '400', 'Bad Request' do
          it 'Fails to create a chat when the chat application is not found' do
            post api_v1_chat_application_chats_path('invalid_token')
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq("Chat Application doesn't exist")
          end
        end
      end
    end
  end
end
