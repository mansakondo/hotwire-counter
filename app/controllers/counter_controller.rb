class CounterController < ApplicationController
  def show
    render :show, locals: {
      total_counter_count: total_counter_count.value,
      total_users_count: total_users_count.value,
      regions: regions_with_counts
    }
  end

  def increment
    total_counter_count.increment

    current_region_count.increment

    respond_to do |format|
      format.turbo_stream do
        render partial: "counter/update", locals: {
          total_counter_count: total_counter_count.value,
          current_region_count: current_region_count.value
        }

        broadcast
      end

      format.html { redirect_to root_url }
    end
  end

  def decrement
    total_counter_count.decrement

    current_region_count.decrement

    respond_to do |format|
      format.turbo_stream do
        render partial: "counter/update", locals: {
          total_counter_count: total_counter_count.value,
          current_region_count: current_region_count.value
        }

        broadcast
      end

      format.html { redirect_to root_url }
    end
  end

  private
    def total_counter_count
      Kredis.counter "counter:count"
    end

    def total_users_count
      Kredis.counter "users:count"
    end

    def current_region_count
      Kredis.counter "#{current_region}:counter:count"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_later_to "counter",
        targets: ".counter-count",
        content: total_counter_count.value

      Turbo::StreamsChannel.broadcast_update_later_to "#{current_region}:counter",
        target: "#{current_region}-counter-count",
        content: current_region_count.value
    end

    def regions_with_counts
      regions_with_counts = []

      regions.each do |region|
        code, name = region["Code"], region["Name"]

        regions_with_counts << {
          name: name,
          code: code,
          counter_count: find_region_count_by(code).value,
          users_count: find_region_users_count_by(code).value
        }
      end

      regions_with_counts
    end

    def find_region_count_by(code)
      Kredis.counter "#{code}:counter:count"
    end

    def find_region_users_count_by(code)
      Kredis.counter "#{code}:users:count"
    end
end
