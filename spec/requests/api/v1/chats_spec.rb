# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1/:chat_application_token/chats', type: :request do
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

          it 'returns a bad request if an invalid chat app token was provided' do
            get api_v1_chat_application_chats_path('invalid_token'), as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq("Chat Application doesn't exist")
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
            latest_chat_number = REDIS.get("chat_app_#{chat_application.id}")
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
              expect(REDIS.get("chat_app_#{chat_application.id}")).to eq((i + 1).to_s)
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

        context 'when reids is down Fallback to database happens' do
          before do
            allow_any_instance_of(RedisHelper).to receive(:redis_running?).and_return false
            allow_any_instance_of(CreationService).to receive(:latest_chat_number).and_raise(SocketError)
          end

          it "Successfully creates a chat whilst redis isn't operating" do
            3.times do |n|
              post api_v1_chat_application_chats_path(chat_application.token)
              expect(chat_application.chats.count).to eq(n + 1)
            end
          end

          it 'Successfully syncs with redis and creates a chat' do
            post api_v1_chat_application_chats_path(chat_application.token)
            expect(chat_application.chats.count).to eq(1)
            allow_any_instance_of(RedisHelper).to receive(:redis_running?).and_return true
            allow_any_instance_of(CreationService).to receive(:latest_chat_number).and_call_original
            post api_v1_chat_application_chats_path(chat_application.token)
            expect(REDIS.get("chat_app_#{chat_application.id}")).to eq('2')
          end
        end
      end
    end
    context 'when creating a chat chats_count updates regularly' do
      it 'Successfully updates chats_count after creating a chat - deferred mode' do
        Sidekiq::Testing.inline! do
          chat_application = create(:chat_application)
          post api_v1_chat_application_chats_path(chat_application.token)
          chat_application.reload
          expect(chat_application.chats_count).to eq(1)
        end
      end
    end
  end
end
