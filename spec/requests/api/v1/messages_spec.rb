# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v1#messages', type: :request do
  describe 'GET /index' do
    let!(:message) { create(:message) }
    let(:valid_params) { { message: { body: 'Just bought a new pair of sneakers' } } }

    before do
      Message.__elasticsearch__.create_index! force: true
    end

    after do
      Message.__elasticsearch__.client.indices.delete index: Message.index_name
    end

    path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}/messages' do
      get 'Retrieves all messages belonging to a specific chat' do
        produces 'application/json'
        tags 'Messages'
        parameter name: :chat_application_token, in: :path, type: :string
        parameter name: :chat_number, in: :path, type: :string
        parameter name: :query, in: :query, type: :string, min_length: 3,
                  description: 'Searching through messages belonging to chat'
        response '200', 'Get messages' do
          examples 'application/json' => [{ number: 1, body: 'Message#1' }, { number: 2, body: 'Message#2' }]
          it 'renders a successful response' do
            get api_v1_chat_application_chat_messages_path(message.chat.chat_application.token, message.chat.number),
                as: :json
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.first['number']).to eq(message.number)
            expect(body.first['body']).to eq(message.body)
          end

          it 'Successfully searches for a created message' do
            message = create(:message)
            message.__elasticsearch__.index_document
            sleep 1
            get api_v1_chat_application_chat_messages_path(message.chat.chat_application.token, message.chat.number),
                params: { query: 'elasticsearch' } # check the message factory
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.first['_source']['body']).to include('elasticsearch')
          end

          it 'Successfully searches messages for a specific chat only' do
            message = create(:message)
            message.__elasticsearch__.index_document
            other_message = create(:message) # same text different chat id
            other_message.__elasticsearch__.index_document
            sleep 1
            get api_v1_chat_application_chat_messages_path(message.chat.chat_application.token, message.chat.number),
                params: { query: 'elasticsearch' } # check the message factory
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.size).to eq(1)
            expect(body.first['_source']['body']).to include('elasticsearch')
          end
        end

        response '400', 'Chat not found' do
          it 'returns a bad request if an invalid chat app token and/or chat number was provided' do
            get api_v1_chat_application_chat_messages_path('invalid_token', message.chat.number), as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq('Chat not found')
            get api_v1_chat_application_chat_messages_path(message.chat.chat_application.token, 'invalid_number'),
                as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq('Chat not found')
          end
        end
      end
    end
  end

  describe 'POST /create' do
    let(:valid_params) { { message: { body: 'Hello World!' } } }
    let(:invalid_params) { { message: { body: '' } } }
    let(:chat) { create(:chat) }

    path '/api/v1/chat_applications/{chat_application_token}/chats/{chat_number}/messages' do
      post 'Creates a new message' do
        consumes 'application/json'
        produces 'application/json'
        tags 'Messages'
        parameter name: :chat_application_token, in: :path, type: :string
        parameter name: :chat_number, in: :path, type: :string
        parameter name: :message, in: :body, schema: {
          type: :object,
          properties: {
            body: { type: :string }
          }
        }
        response '200', 'Message Created' do
          examples 'application/json' => { number: 1, body: 'Message#1' }
          it 'successfully creates a message' do
            3.times do |n|
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
              expect(response).to have_http_status(:created)
              body = response.parsed_body
              expect(body['number']).to eq(n + 1)
              expect(body['body']).to eq(valid_params[:message][:body])
            end
          end

          it 'Successfully adds the key value pair to redis' do
            post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                 params: valid_params, as: :json
            latest_chat_number = REDIS.get("chat_app_#{chat.chat_application.id}_chat_#{chat.id}")
            expect(latest_chat_number).to eq('1')
          end

          it 'Successfully enqueues a message creation job to sidekiq' do
            expect do
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
            end.to change(MessageCreationJob.jobs, :size).by(1)
          end

          it 'Successfully increments the message number on every new message per chat creation' do
            3.times do |i|
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
              expect(REDIS.get("chat_app_#{chat.chat_application.id}_chat_#{chat.id}")).to eq((i + 1).to_s)
            end
          end
        end

        response '400', 'Chat not found' do
          it 'returns a bad request if an invalid chat app token and/or chat number was provided' do
            post api_v1_chat_application_chat_messages_path('invalid_token', chat.number),
                 params: valid_params, as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq('Chat not found')
            post api_v1_chat_application_chat_messages_path(chat.chat_application.token, 'invalid_number'),
                 params: invalid_params, as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq('Chat not found')
          end

          it 'returns a bad request if the message body is empty' do
            post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                 params: invalid_params, as: :json
            expect(response).to have_http_status(:bad_request)
            body = response.parsed_body
            expect(body['message']).to eq('Message body is empty')
          end
        end

        context 'when redis is down Fallback to database happens' do
          before do
            allow_any_instance_of(RedisHelper).to receive(:redis_running?).and_return false
            allow_any_instance_of(CreationService).to receive(:latest_message_number).and_raise(SocketError)
          end

          it "Successfully creates a message whilst redis isn't operating" do
            3.times do |n|
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
              expect(chat.messages.count).to eq(n + 1)
            end
          end

          it 'Successfully syncs with redis and creates a message' do
            3.times do |n|
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
              expect(chat.messages.count).to eq(n + 1)
            end
            allow_any_instance_of(RedisHelper).to receive(:redis_running?).and_return true
            allow_any_instance_of(CreationService).to receive(:latest_message_number).and_call_original
            post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                 params: valid_params, as: :json
            expect(REDIS.get("chat_app_#{chat.chat_application.id}_chat_#{chat.id}")).to eq('4')
          end
        end

        context 'when creating a message messages_count updates regularly' do
          it 'Successfully updates messages_count after creating a message' do
            Sidekiq::Testing.inline! do
              chat = create(:chat)
              post api_v1_chat_application_chat_messages_path(chat.chat_application.token, chat.number),
                   params: valid_params, as: :json
              chat.reload
              expect(chat.messages_count).to eq(1)
            end
          end
        end
      end
    end
  end
end
