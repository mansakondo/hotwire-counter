class Counter
  include KredisCountable

  def redis_key
    "counter:count"
  end

  def broadcast_update
    Turbo::StreamsChannel.broadcast_update_to "counter",
      targets: ".counter-count",
      content: count.value
  end
end
