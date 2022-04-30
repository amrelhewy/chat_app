# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ChatCreationJob, type: :job do
  it 'Successfully persists the chat in the database' do
    chat_application = create(:chat_application)
    job = described_class.new
    expect { job.perform(chat_application.id, 1) }.to change(Chat, :count).by(1)
    persisted_chat = Chat.first
    expect(persisted_chat.number).to eq(1)
    expect(persisted_chat.chat_application_id).to eq(chat_application.id)
  end
end
