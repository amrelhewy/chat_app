# frozen_string_literal: true

module Api
  module V1
    class ChatsController < ApplicationController
      before_action :validate_chat_application, only: :create
      # GET /api/v1/chat_applications/:chat_application_token/chats
      def index
        @chats = Chat.where(chat_application_token: params[:chat_application_token])

        render json: ChatBlueprint.render(@chats)
      end

      # POST /api/v1/chat_applications/:chat_application_token/chats
      def create
        chat_number = ChatCreationService.new(params[:chat_application_token]).latest_chat_number

        # queue sidekiq job
        ChatCreationJob.perform_async(params[:chat_application_token], chat_number)

        @chat = Chat.new(number: chat_number, chat_application_token: params[:chat_application_token])
        render json: ChatBlueprint.render(@chat, view: :create), status: :created
      end

      private

      def validate_chat_application
        # Check if application token is valid
        unless ChatApplication.exists?(token: params[:chat_application_token])
          render json: { message: "Chat Application doesn't exist" },
                 status: :bad_request
        end
      end
    end
  end
end
