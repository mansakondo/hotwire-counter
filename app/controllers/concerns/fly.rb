module Fly
  extend ActiveSupport::Concern

  included do
    helper_method :current_region, :current_region_name, :regions

    def current_region
      ENV["FLY_REGION"]
    end

    def current_region_name
      region_name = ""

      regions.each do |region|
        code, name  = region["Code"], region["Name"]
        region_name = name if code == current_region
      end

      region_name
    end

    def regions
      JSON
        .parse(`fly regions list -a hotwire-counter -j`)
        .fetch("Regions")
    end
  end
end
