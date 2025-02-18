class LocalWeather < ApplicationRecord
  belongs_to :sensor
  attr_accessor :time

  after_create_commit -> { broadcast_weather_update }

  def self.charts_data(time = 10, sensor_id = nil)
    query = LocalWeather.where("created_at >= ?", time.minutes.ago)

    query = query.where(sensor_id: sensor_id) if sensor_id
    local_weathers = query.order(created_at: :desc)
                         .group_by(&:sensor_id)

    return {local_weathers: nil} if local_weathers.empty?

    {
      local_weathers: local_weathers,
      temperature_data: map_data(local_weathers, :temperature),
      humidity_data: map_data(local_weathers, :humidity),
      pressure_data: map_data(local_weathers, :pressure),
      temperature_min_max: calculate_min_max(:temperature, local_weathers),
      humidity_min_max: calculate_min_max(:humidity, local_weathers),
      pressure_min_max: calculate_min_max(:pressure, local_weathers)
    }
  end

  private

  def broadcast_weather_update
    broadcast_replace_to "weather_charts_all",
      target: "weather_charts_frame",
      partial: "shared/weather_charts",
      locals: LocalWeather.charts_data
  end

  def self.map_data(grouped_reading, data_type)
    grouped_reading.map do |sensor_id, readings|
      {
        name: "#{Sensor.find(sensor_id).name}",
        data: readings.map { |reading| [ reading.created_at, reading.send(data_type) ] }
      }
    end
  end

  def self.calculate_min_max(data_type, grouped_reading, diff = 2)
    global = grouped_reading.values.flatten.map(&data_type).compact
    [ global.min - diff, global.max + diff ]
  end
end
