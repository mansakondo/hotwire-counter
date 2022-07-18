class CounterController < ApplicationController
  def show
    render :show, locals: {
      count: count.value,
      regions: regions_with_counts
    }
  end

  def increment
    count.increment

    current_region_count.increment

    broadcast

    redirect_to root_url
  end

  def decrement
    count.decrement

    current_region_count.decrement

    broadcast

    redirect_to root_url
  end

  private
    def count
      Kredis.counter "counter:count"
    end

    def current_region_count
      Kredis.counter "#{current_region}:counter:count"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_later_to "counter",
        target: "counter-count",
        content: count.value

      Turbo::StreamsChannel.broadcast_update_later_to "#{current_region}:counter",
        target: "#{current_region}-counter-count",
        content: current_region_count.value
    end

    def regions_with_counts
      regions_with_counts = regions.dup

      regions_with_counts.each do |region|
        code            = region["Code"]
        region["Count"] = find_region_count_by(code).value
      end

      regions_with_counts
    end

    def find_region_count_by(code)
      Kredis.counter "#{code}:counter:count"
    end
end
