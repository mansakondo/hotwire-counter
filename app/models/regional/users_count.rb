module Regional
  class UsersCount
    include KredisCountable

    def redis_key
      "#{region}:users:count"
    end

    def broadcast_update
      UsersCountChannel.broadcast_update_to "#{region}:users",
        target: "#{region}-users-count",
        content: count.value
    end
  end
end
