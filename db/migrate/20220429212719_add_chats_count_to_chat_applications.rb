# frozen_string_literal: true

class AddChatsCountToChatApplications < ActiveRecord::Migration[5.2]
  def self.up
    add_column :chat_applications, :chats_count, :integer, null: false, default: 0
    add_column :chat_applications, :chats_updated_at, :date
  end

  def self.down
    remove_column :chat_applications, :chats_count
    remove_column :chat_applications, :chats_updated_at
  end
end
