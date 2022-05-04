# frozen_string_literal: true

Elasticsearch::Model.client = Elasticsearch::Client.new log: true, host: 'elastic_search'
