# frozen_string_literal: true

# == Schema Information
#
# Table name: chat_applications
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ChatApplication < ApplicationRecord
  validates :name, presence: true
end
