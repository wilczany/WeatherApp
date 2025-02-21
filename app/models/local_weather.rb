class LocalWeather < ApplicationRecord
  belongs_to :sensor

  validates :temperature, numericality: {
    greater_than_or_equal_to: -40,
    less_than_or_equal_to: 85
  }

  validates :humidity, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }
  validates :pressure, numericality: {
    greater_than_or_equal_to: 300,
    less_than_or_equal_to: 1100
  }

  after_create_commit -> { broadcast_weather_update }

  def self.charts_data(sensor_id = nil, start_time = 30.minutes.ago, end_time = Time.now)
    WeatherDataService.charts_data(sensor_id, start_time, end_time)
  end

  private

  def broadcast_weather_update
    broadcast_replace_to "weather_charts_all",
      target: "weather_charts_frame",
      partial: "shared/weather_charts",
      locals: LocalWeather.charts_data
  end
end
