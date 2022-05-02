# frozen_string_literal: true

# == Schema Information
#
# Table name: chats
#
#  id                  :bigint           not null, primary key
#  messages_count      :bigint           default(0), not null
#  messages_updated_at :date
#  number              :integer
#  redis_synced        :boolean          default(TRUE)
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
  extend RedisHelper

  # Associations
  belongs_to :chat_application
  has_many :messages, dependent: :destroy

  # Counter Cache
  counter_cache_on column: :chats_count,
                   relation: :chat_application,
                   relation_class_name: 'ChatApplication',
                   method: :calculate_chats_count,
                   touch_column: :chats_updated_at,
                   wait: 5.minutes, # updates redis every 5 minutes with the current count. redis job once every 5 min
                   # recalculates from database every hour
                   recalculation: true,
                   if: proc { redis_running? }
  # Validations
  validates :number, presence: true
  validates :number, uniqueness: { scope: :chat_application_id }
end
