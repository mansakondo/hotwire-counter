class UsersCountChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    if stream_name = verified_stream_name_from_params
      stream_from stream_name

      users_count.increment
    else
      reject
    end
  end

  def unsubscribed
    users_count.decrement

    stop_all_streams
  end

  private
    def users_count
      UsersCount.count
    end
end
