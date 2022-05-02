# frozen_string_literal: true

class AddRedisSyncedToChats < ActiveRecord::Migration[5.2]
  def change
    add_column :chats, :redis_synced, :boolean, default: true
  end
end
