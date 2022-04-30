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
FactoryBot.define do
  factory :chat do
    sequence(:number) { |n| n }
    association :chat_application
  end
end
