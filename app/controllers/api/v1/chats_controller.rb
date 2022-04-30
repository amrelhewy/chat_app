# frozen_string_literal: true

module Api
  module V1
    class ChatsController < ApplicationController
      include RedisHelper
      before_action :find_chat_application, only: %i[create index]
      before_action :check_sync_status, only: :create
      rescue_from SocketError, with: :fallback_to_database # If redis went down

      # GET /api/v1/chat_applications/:chat_application_token/chats
      def index
        render json: ChatBlueprint.render(@chat_application.chats), status: :ok
      end

      # POST /api/v1/chat_applications/:chat_application_token/chats
      def create
        chat_number = ChatCreationService.new(@chat_application.id).latest_chat_number

        ChatCreationJob.perform_async(@chat_application.id, chat_number)

        @chat = @chat_application.chats.new(number: chat_number)

        render json: ChatBlueprint.render(@chat), status: :created
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

      def check_sync_status
        # Check if the chat application redis synced flag is true or false
        if !@chat_application.redis_synced? && redis_running? # if redis is back on and we're out of sync
          # Sync the redis token key with the updated value from the database and set redis sync to true again
          # this is a one time operation after redis recovers
          FallbackService.new(@chat_application.id).sync_redis_chat_number
        end
      end

      def fallback_to_database
        # if Redis is down, we need to get the count from the db. This guarantees reliabillity
        # if we entered here, that means the redis synced of the application has to be set to false
        if @chat_application.redis_synced? # if it's true we set it to false
          @chat_application.redis_synced = false
          @chat_application.save
        end

        chat = FallbackService.new(@chat_application.id).fallback_to_database_and_create_chat

        render json: ChatBlueprint.render(chat), status: :created
      end
    end
  end
end
