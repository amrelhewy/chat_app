# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      resources :chat_applications, param: :token, except: %i[destroy] do
        resources :chats, param: :number, except: %i[destroy update show]
      end
    end
  end
end
