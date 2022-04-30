# frozen_string_literal: true

# == Schema Information
#
# Table name: chats
#
#  id                  :bigint           not null, primary key
#  number              :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_application_id :bigint           not null
#
# Indexes
#
#  index_chats_on_chat_application_id             (chat_application_id)
#  index_chats_on_chat_application_id_and_number  (chat_application_id,number) UNIQUE
#
class Chat < ApplicationRecord
  include Counter::Cache

  # Associations
  belongs_to :chat_application

  # Counter Cache
  # counter_cache_on column: :chats_count,
  #                  relation: :chat_application,
  #                  relation_class_name: "ChatApplication",
  #                  relation_id: :chat_application_token,
  #                  method: :calculate_chats_count,
  #                  touch_column: :chats_updated_at,
  #                  recalculation: true,
  # Validations
  validates :number, presence: true
  validates :number, uniqueness: { scope: :chat_application_id }
end
