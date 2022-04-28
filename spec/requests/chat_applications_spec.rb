# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe '/api/v1/chat_applications', type: :request do
  let(:valid_attributes) do
    { 'name' => 'test_app_1' }
  end

  let(:invalid_attributes) do
    { 'name' => '' }
  end

  let!(:chat_application) { create(:chat_application) }

  describe 'GET /index' do
    path '/api/v1/chat_applications' do
      get 'Returns all applications' do
        tags 'Chat Applications'
        produces 'application/json'
        response '200', 'Successfull' do
          examples 'application/json' => [{ token: 1, name: 'test_name' }, { token: 2, name: 'test_name_2' }]
          it 'renders a successful response' do
            get api_v1_chat_applications_path, as: :json
            expect(response).to have_http_status(:ok)
            body = response.parsed_body
            expect(body.first['token']).to eq(chat_application.id)
            expect(body.first['name']).to eq(chat_application.name)
          end
        end
      end
    end
  end

  describe 'GET /show' do
    path '/api/v1/chat_applications/{token}' do
      get 'Retreives a chat application' do
        produces 'application/json'
        tags 'Chat Applications'
        parameter name: :token, in: :path, type: :string
        response '200', 'Chat Application Found' do
          examples 'application/json' => { token: 1, name: 'test_name' }
          it 'renders a successful response' do
            get api_v1_chat_application_path(chat_application), as: :json
            expect(response).to be_successful
            body = response.parsed_body
            expect(body['token']).to eq(chat_application.id)
            expect(body['name']).to eq(chat_application.name)
          end
        end
      end
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      path '/api/v1/chat_applications' do
        post 'Creates a chat application' do
          consumes 'application/json'
          produces 'application/json'
          tags 'Chat Applications'
          parameter name: :chat_application, in: :body, schema: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          }
          response '201', 'Chat Application Created' do
            it 'creates a new ChatApplication' do
              expect do
                post api_v1_chat_applications_path,
                     params: { chat_application: valid_attributes }, as: :json
              end.to change(ChatApplication, :count).by(1)
            end

            it 'renders a JSON response with the new chat_application' do
              post api_v1_chat_applications_path,
                   params: { chat_application: valid_attributes }, as: :json
              expect(response).to have_http_status(:created)
              expect(response.content_type).to match(a_string_including('application/json'))
              body = response.parsed_body
              expect(body['name']).to eq(valid_attributes['name'])
            end
          end
        end
      end
    end

    context 'with invalid parameters' do
      path '/api/v1/chat_applications' do
        post 'Creates a Chat Application' do
          consumes 'application/json'
          produces 'application/json'
          tags 'Chat Applications'
          parameter name: :chat_application, in: :body, schema: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          }
          response '401', 'Unprocessable Entity' do
            it 'does not create a new ChatApplication' do
              expect do
                post api_v1_chat_applications_path,
                     params: { chat_application: invalid_attributes }, as: :json
              end.to change(ChatApplication, :count).by(0)
            end

            it 'renders a JSON response with errors for the new chat_application' do
              post api_v1_chat_applications_path,
                   params: { chat_application: invalid_attributes }, as: :json
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.content_type).to eq('application/json')
            end
          end
        end
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        { 'name' => 'new_name' }
      end
      let!(:chat_application) { create(:chat_application) }

      path '/api/v1/chat_applications/{token}' do
        patch 'Updates existing Chat Application' do
          tags 'Chat Applications'
          consumes 'application/json'
          produces 'application/json'
          parameter name: :token, in: :path, type: :string
          parameter name: :chat_application, in: :body, schema: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          }
          response '200', 'Successfully updated' do
            it 'updates the requested chat_application' do
              patch api_v1_chat_application_path(chat_application),
                    params: { chat_application: new_attributes }, as: :json
              chat_application.reload
              expect(chat_application.name).to eq(new_attributes['name'])
            end

            it 'renders a JSON response with the chat_application' do
              patch api_v1_chat_application_path(chat_application),
                    params: { chat_application: new_attributes }, as: :json
              expect(response).to have_http_status(:ok)
              expect(response.content_type).to match(a_string_including('application/json'))
              body = response.parsed_body
              expect(body['name']).to eq(new_attributes['name'])
            end
          end
        end
      end
    end

    context 'with invalid parameters' do
      path '/api/v1/chat_applications/{token}' do
        patch 'Updates existing Chat Application' do
          tags 'Chat Applications'
          consumes 'application/json'
          produces 'application/json'
          parameter name: :token, in: :path, type: :string
          parameter name: :chat_application, in: :body, schema: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          }
          response '400', 'Failed to update' do
            it 'renders a JSON response with errors for the chat_application' do
              patch api_v1_chat_application_path(chat_application),
                    params: { chat_application: invalid_attributes }, as: :json
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.content_type).to eq('application/json')
            end
          end
        end
      end
    end
  end
end
