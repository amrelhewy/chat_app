# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :number
      # Index is for selecting all chats belonging to one app
      t.references :chat_application, null: false, index: true
      t.timestamps
    end
    add_index :chats, %i[chat_application_id number], unique: true
  end
end
