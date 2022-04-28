# frozen_string_literal: true

class CreateChatApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_applications do |t|
      t.string :name, null: false
      t.string :token, null: false, index: { unique: true } # handle race conditions via a unique index constraint

      t.timestamps
    end
  end
end
