module Regional
  class Counter
    include KredisCountable

    def redis_key
      "#{region}:counter:count"
    end

    def broadcast_update
      Turbo::StreamsChannel.broadcast_update_to "#{region}:counter",
        target: "#{region}-counter-count",
        content: count.value
    end
  end
end
