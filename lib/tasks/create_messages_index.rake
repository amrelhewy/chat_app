# frozen_string_literal: true

namespace :elastic_search do
  task create_messages_index: :environment do
    Message.__elasticsearch__.create_index!
  end
end
