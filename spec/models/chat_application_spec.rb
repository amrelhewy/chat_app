# frozen_string_literal: true

# == Schema Information
#
# Table name: chat_applications
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  token      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_chat_applications_on_token  (token) UNIQUE
#
require 'rails_helper'

RSpec.describe ChatApplication, type: :model do
  subject { build(:chat_application) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:token) }
  it { is_expected.to have_many(:chats) }

  it 'has a valid factory' do
    expect(build(:chat_application)).to be_valid
  end
end
