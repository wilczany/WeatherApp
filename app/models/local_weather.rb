class LocalWeather < ApplicationRecord
  belongs_to :sensor

  after_create_commit -> { broadcast_weather_update }

  

  private

  def broadcast_weather_update
    time = 10.minutes.ago
    local_weathers = LocalWeather.where("created_at >= ?", time).
                                  order(created_at: :desc)
                                  .group_by(&:sensor_id)

    return if local_weathers.empty?

    broadcast_replace_to "weather_charts",
      target: "weather_charts_frame",
      partial: "pages/weather_charts",
      locals: {
        local_weathers: local_weathers,
        temperature_data: map_data(local_weathers, :temperature),
        humidity_data: map_data(local_weathers, :humidity),
        pressure_data: map_data(local_weathers, :pressure),
        temperature_min: calculate_min(:temperature, local_weathers),
        temperature_max: calculate_max(:temperature, local_weathers),
        humidity_min: calculate_min(:humidity, local_weathers),
        humidity_max: calculate_max(:humidity, local_weathers),
        pressure_min: calculate_min(:pressure, local_weathers),
        pressure_max: calculate_max(:pressure, local_weathers)
      }
  end

  def map_data(grouped_reading, data_type)
    grouped_reading.map do |sensor_id, readings|
      {
        name: "#{Sensor.find(sensor_id).name}",
        data: readings.map { |reading| [ reading.created_at, reading.send(data_type) ] }
      }
    end
  end

  def calculate_min(data_type, grouped_reading, diff = 2)
    global_values = grouped_reading.values.flatten.map(&data_type).compact
    global_values.min - diff
  end

  def calculate_max(data_type, grouped_reading, diff = 2)
    global_values = grouped_reading.values.flatten.map(&data_type).compact
    global_values.max + diff
  end
end
