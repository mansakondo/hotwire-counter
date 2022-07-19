class UsersCountChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    if stream_name = verified_stream_name_from_params
      stream_from stream_name

      users_count.increment

      broadcast
    else
      reject
    end
  end

  def unsubscribed
    users_count.decrement

    broadcast

    stop_all_streams
  end

  def broadcast
    self.class.broadcast_update_later_to "users",
      targets: ".users-count",
      content: users_count.value
  end

  private
    def users_count
      Kredis.counter "users:count"
    end
end
