# frozen_string_literal: true

require 'rails_helper'
RSpec.describe MessageCreationJob, type: :job do
  it 'Successfully persists the message in the database' do
    chat = create(:chat)
    job = described_class.new
    expect { job.perform('Message', 1, chat.id) }.to change(Message, :count).by(1)
    persisted_message = Message.first
    expect(persisted_message.number).to eq(1)
    expect(persisted_message.body).to eq('Message')
    expect(persisted_message.chat_id).to eq(chat.id)
  end
end
