# frozen_string_literal: true

module Api
  module V1
    class ChatApplicationsController < ApplicationController
      before_action :set_chat_application, only: %i[show update]

      # GET /chat_applications
      def index
        @chat_applications = ChatApplication.all

        render json: ChatApplicationBlueprint.render(@chat_applications), status: :ok
      end

      # GET /chat_applications/1
      def show
        render json: ChatApplicationBlueprint.render(@chat_application), status: :ok
      end

      # POST /chat_applications
      def create
        @chat_application = ChatApplication.new(chat_application_params)

        if @chat_application.save
          render json: ChatApplicationBlueprint.render(@chat_application), status: :created
        else
          render json: @chat_application.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /chat_applications/1
      def update
        if @chat_application.update(chat_application_params)
          render json: ChatApplicationBlueprint.render(@chat_application), status: :ok
        else
          render json: @chat_application.errors, status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_chat_application
        @chat_application = ChatApplication.find(params[:token])
      end

      # Only allow a trusted parameter "white list" through.
      def chat_application_params
        params.require(:chat_application).permit(:name)
      end
    end
  end
end
