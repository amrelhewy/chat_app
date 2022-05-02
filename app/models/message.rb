# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  body       :text(65535)
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chat_id    :bigint
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#
class Message < ApplicationRecord
  include Counter::Cache
  extend RedisHelper

  # Associations
  belongs_to :chat

  # Counter Cache
  counter_cache_on column: :messages_count,
                   relation: :chat,
                   relation_class_name: 'Chat',
                   method: :calculate_messages_count,
                   touch_column: :messages_updated_at,
                   wait: 10.seconds, # updates redis every 5 minutes with the current count. lock to prevent unneeded jobs
                   # recalculates from database every hour
                   recalculation: true,
                   if: proc { redis_running? }

  # Validations
  validates :body, :number, presence: true

  # Instance methods
  def calculate_messages_count
    messages.count
  end
end
