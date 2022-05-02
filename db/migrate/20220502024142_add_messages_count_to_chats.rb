# frozen_string_literal: true

class AddMessagesCountToChats < ActiveRecord::Migration[5.2]
  def change
    change_table :chats, bulk: true do |t|
      t.bigint :messages_count, null: false, default: 0
      t.date   :messages_updated_at
    end
  end
end
