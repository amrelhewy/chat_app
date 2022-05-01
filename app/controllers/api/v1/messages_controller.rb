# frozen_string_literal: true

module Api
  module V1
    class MessagesController < ApplicationController
      before_action :find_chat
      # before_action :check_sync_status, only: :create
      before_action :validate_presence_of_message_body, only: :create
      rescue_from SocketError, with: :fallback_to_database
      # GET /api/v1/chat_applications/:chat_application_token/chats/:chat_number/messages
      def index
        @messages = @chat.messages

        render json: MessageBlueprint.render(@messages)
      end

      # POST /api/v1/chat_applications/:chat_application_token/chats/:chat_number/messages
      def create
        message_number = CreationService.new(:message).latest_message_number("chat_app_#{@chat_application.id}_chat_#{@chat.id}")

        MessageCreationJob.perform_async(message_params[:body], message_number, @chat.id)

        @message = @chat.messages.new(body: message_params[:body], number: message_number)

        render json: MessageBlueprint.render(@message), status: :created
      end

      private

      def message_params
        params.fetch(:message).permit(:body)
      end

      def validate_presence_of_message_body
        render json: { message: 'Message body is empty' }, status: :bad_request if message_params[:body].blank?
      end

      def find_chat
        # Find application id by token --> get its id
        @chat_application = ChatApplication.select(:id).find_by(token: params[:chat_application_token]) # 1 lookup

        # Find chat --> chat number and application id index
        @chat = Chat.find_by(chat_application_id: @chat_application.try(:id), number: params[:chat_number])

        render json: { message: 'Chat not found' }, status: :bad_request if @chat.blank?
      end
    end
  end
end
