module Regional
  class UsersCountChannel < ApplicationCable::Channel
    extend Turbo::Streams::Broadcasts, Turbo::Streams::StreamName
    include Turbo::Streams::StreamName::ClassMethods

    def subscribed
      if stream_name = verified_stream_name_from_params
        stream_from stream_name

        if current_region?
          region_users_count.increment
        end
      else
        reject
      end
    end

    def unsubscribed
      if current_region?
        region_users_count.decrement
      end

      stop_all_streams
    end

    private
      def current_region?
        params[:region] == params[:current_region]
      end

      def region_users_count
        UsersCount.count_for region: params[:region]
      end
  end
end
