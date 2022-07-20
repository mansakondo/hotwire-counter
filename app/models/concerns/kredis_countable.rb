module KredisCountable
  extend ActiveSupport::Concern

  included do
    include Kredis::Attributes

    kredis_counter :count,
      key: -> (counter) { counter.redis_key },
      after_change: :broadcast_update
  end

  class_methods do
    def count
      new.count
    end
  end
end
