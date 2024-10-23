class PagesController < ApplicationController
  def home
    @local_weathers = LocalWeather.all.order(created_at: :desc).limit(30)

    @temperature_data = Hash.new
    @humidity_data = Hash.new
    @pressure_data = Hash.new
    # @pressure_min = @local_weathers.minimum(:pressure) - 20
    # @pressure_max = @local_weathers.maximum(:pressure) + 20

    @latest = @local_weathers.first

    @local_weathers.each do |record|
      @temperature_data[record.created_at] = record.temperature
      @humidity_data[record.created_at] = record.humidity
      @pressure_data[record.created_at] = record.pressure
    end
  end

  def forecast
    # @api =
  end
end
