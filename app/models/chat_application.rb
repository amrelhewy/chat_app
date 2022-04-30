# frozen_string_literal: true

# == Schema Information
#
# Table name: chat_applications
#
#  id               :bigint           not null, primary key
#  chats_count      :integer          default(0), not null
#  chats_updated_at :date
#  name             :string(255)      not null
#  redis_synced     :boolean          default(TRUE)
#  token            :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_chat_applications_on_token  (token) UNIQUE
#
class ChatApplication < ApplicationRecord
  has_secure_token

  # Associations
  has_many :chats, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :token, uniqueness: true

  # Instance Methods
  def calculate_chats_count
    chats.count
  end
end
