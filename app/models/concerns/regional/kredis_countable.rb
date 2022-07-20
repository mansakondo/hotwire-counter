module Regional::KredisCountable
  extend ActiveSupport::Concern

  included do
    include Kredis::Attributes

    attr_accessor :region

    kredis_counter :count,
      key: -> (counter) { counter.redis_key },
      after_change: :broadcast_update

    def initialize(region:)
      @region = region
    end
  end

  class_methods do
    def count_for(region:)
      new(region: region)
        .count
    end

    def value_for(region:)
      new(region: region)
        .count
        .value
    end
  end
end
