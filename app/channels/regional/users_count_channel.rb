class Regional::UsersCountChannel < ApplicationCable::Channel
  extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
  include Turbo::Streams::StreamName::ClassMethods

  def subscribed
    if stream_name = verified_stream_name_from_params
      stream_from stream_name

      if current_region?
        region_users_count.increment

        broadcast
      end
    else
      reject
    end
  end

  def unsubscribed
    if current_region?
      region_users_count.decrement

      broadcast
    end

    stop_all_streams
  end

  def broadcast
    self.class.broadcast_update_later_to "#{params[:region]}:users",
      target: "#{params[:region]}-users-count",
      content: region_users_count.value
  end

  private
    def current_region?
      params[:region] == params[:current_region]
    end

    def region_users_count
      Kredis.counter "#{params[:region]}:users:count"
    end
end
