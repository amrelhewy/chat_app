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
FactoryBot.define do
  factory :chat_application do
    sequence(:name) { |n| "chat_application_#{n}" }
  end
end
