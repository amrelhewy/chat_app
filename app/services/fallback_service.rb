# frozen_string_literal: true

class FallbackService
  TO_BE_CREATED = %w[chat message].freeze
  def initialize(association, association_id, extras)
    @association = association
    @association_id = association_id
    @extras = extras
  end

  # this is obviously much slower than redis and sidekiq
  # but this guarantees reliabillity in case redis went down.
  # since there is a unique index on chat number and token. retry the process if any race conditions occur
  TO_BE_CREATED.each do |c|
    define_method("fallback_to_database_and_create_#{c}") do
      latest_created = @association.constantize.find_by(id: @association_id).send(c.pluralize).last # last chat or message
      latest_created_number = latest_created.present? ? latest_created.number : 0
      params = { number: latest_created_number + 1 }
      params["#{@association.underscore}_id"] = @association_id # either chat or chat application the foreign key always
      c.classify.constantize.create!(number: latest_created_number + 1, **params.merge!(@extras))
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    define_method("sync_redis_#{c}_number") do |redis_key|
      latest_created = @association.constantize.find_by(id: @association_id).send(c.pluralize).last
      REDIS.set(redis_key, latest_created.number)
      latest_created.send(@association.underscore).redis_synced = true
      latest_created.send(@association.underscore).save
    end
  end
end
