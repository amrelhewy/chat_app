# frozen_string_literal: true

class IndexerJob
  include Sidekiq::Job
  sidekiq_options queue: :elasticsearch, retry: false

  Client = Elasticsearch::Client.new host: 'elasticsearch'

  def perform(operation, record_id)
    case operation.to_s
    when /index/
      record = Message.find(record_id)
      Client.index index: "messages-#{Rails.env}", id: record_id, body: record.__elasticsearch__.as_indexed_json
    when /delete/
      Client.delete index: "messages-#{Rails.env}", id: record_id
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
