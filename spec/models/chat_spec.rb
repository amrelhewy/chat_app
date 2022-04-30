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
require 'rails_helper'

RSpec.describe Chat, type: :model do
  subject { build(:chat) }

  it { is_expected.to belong_to(:chat_application) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_uniqueness_of(:number).scoped_to(:chat_application_id) }

  it 'has a valid factory' do
    expect(build(:chat)).to be_valid
  end
end
