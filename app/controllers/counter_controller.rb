class CounterController < ApplicationController
  def show
    render :show, locals: { count: count.value }
  end

  def increment
    count.increment

    broadcast

    redirect_to root_url
  end

  def decrement
    count.decrement

    broadcast

    redirect_to root_url
  end

  private
    def count
      Kredis.counter "global:counter:count"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_later_to "global:counter",
        target: "global-count",
        content: count.value
    end
end
