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
        render_partial_update
      end

      format.html { redirect_to root_url }
    end
  end

  def decrement
    total_counter_count.decrement

    current_region_count.decrement

    respond_to do |format|
      format.turbo_stream do
        render_partial_update
      end

      format.html { redirect_to root_url }
    end
  end

  private
    def total_counter_count
      Counter.count
    end

    def total_users_count
      UsersCount.count
    end

    def current_region_count
      Regional::Counter.count_for region: current_region
    end

    def regions_with_counts
      regions_with_counts = []

      regions.each do |region|
        code, name = region["Code"], region["Name"]

        regions_with_counts << {
          name: name,
          code: code,
          counter_count: Regional::Counter.value_for(region: code),
          users_count: Regional::UsersCount.value_for(region: code)
        }
      end

      regions_with_counts
    end

    def render_partial_update
      render partial: "counter/update", locals: {
        total_counter_count: total_counter_count.value,
        current_region_count: current_region_count.value
      }
    end
end
