# frozen_string_literal: true

module Api
  module V1
    class ChatsController < ApplicationController
      before_action :find_chat_application
      include RedisRecoverable

      # GET /api/v1/chat_applications/:chat_application_token/chats
      def index
        render json: ChatBlueprint.render(@chat_application.chats), status: :ok
      end

      # POST /api/v1/chat_applications/:chat_application_token/chats
      def create
        check_redis_sync_status @chat_application, "chat_app_#{@chat_application.id}"

        chat_number = CreationService.new(:chat).latest_chat_number("chat_app_#{@chat_application.id}")

        ChatCreationJob.perform_async(@chat_application.id, chat_number)

        @chat = @chat_application.chats.new(number: chat_number)

        render json: ChatBlueprint.render(@chat), status: :created
      rescue Redis::CannotConnectError, SocketError
        # There might be other errors like a timeout, etc. i just did this one for simplicity and easieness of testing
        # If redis went down, down the redis container to test, already covered in specs anyway
        fallback_to_database @chat_application
      end

      private

      def find_chat_application
        # Check if application token is valid and get it
        @chat_application = ChatApplication.find_by(token: params[:chat_application_token])
        if @chat_application.blank?
          render json: { message: "Chat Application doesn't exist" },
                 status: :bad_request
        end
      end
    end
  end
end
