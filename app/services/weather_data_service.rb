class WeatherDataService
  def self.charts_data(sensor_id, start_time, end_time)
    query = LocalWeather.where(created_at: start_time..end_time)
    query = query.where(sensor_id: sensor_id) if sensor_id
    local_weathers = query.order(created_at: :desc).group_by(&:sensor_id)

    return { local_weathers: nil } if local_weathers.empty?

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

  def self.map_data(grouped_reading, data_type)
    grouped_reading.map do |sensor_id, readings|
      {
        name: Sensor.find(sensor_id).name,
        data: readings.pluck(:created_at, data_type)
      }
    end
  end

  def self.calculate_min_max(data_type, grouped_reading, diff = 2)
    global = grouped_reading.values.flatten.map(&data_type).compact
    [ global.min - diff, global.max + diff ]
  end
end
