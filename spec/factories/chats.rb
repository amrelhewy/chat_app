# frozen_string_literal: true

# == Schema Information
#
# Table name: chats
#
#  id                     :bigint           not null, primary key
#  chat_application_token :string(255)      not null
#  number                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_chats_on_chat_application_token             (chat_application_token)
#  index_chats_on_chat_application_token_and_number  (chat_application_token,number) UNIQUE
#
FactoryBot.define do
  factory :chat do
    sequence(:number) { |n| n }
    association :chat_application
  end
end
