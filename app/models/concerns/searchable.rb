# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name "messages-#{Rails.env}"

    # Hooks
    after_destroy { IndexerJob.perform_async(:delete, id) } # just for rails console debugging i left this

    settings analysis: { analyzer: { custom_analyzer: { type: 'standard', stopwords: '_english_' } } },
             index: { number_of_shards: 1 } do
      mapping dynamic: 'false' do
        indexes :body, type: 'text', analyzer: 'custom_analyzer'
        indexes :chat_id, type: 'keyword'
        indexes :number, type: 'keyword', index: false
      end
    end
    # did the custom analyzer for two reasons. 1- just learned it, 2- english only analyzer would support english messages only
    # this supports more than one language as per documentation and also has stopwords for english added

    def as_indexed_json(_options = {})
      as_json(only: %i[body chat_id number])
    end

    def self.search(query, chat_id)
      __elasticsearch__.search(
        query: {
          bool: {
            filter: {
              term: {
                chat_id: chat_id
              }
            },
            must: {
              match_phrase: {
                body: {
                  query: query
                }
              }
            }
          }
        },
        _source: %w[body number]
      )
    end
  end
end
