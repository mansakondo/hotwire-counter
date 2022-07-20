class UsersCount
  include KredisCountable

  def redis_key
    "users:count"
  end

  def broadcast_update
    UsersCountChannel.broadcast_update_to "users",
      targets: ".users-count",
      content: count.value
  end
end
