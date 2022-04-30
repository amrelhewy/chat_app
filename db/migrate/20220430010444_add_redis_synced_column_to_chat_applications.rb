# frozen_string_literal: true

class AddRedisSyncedColumnToChatApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_applications, :redis_synced, :boolean, default: true
  end
end
