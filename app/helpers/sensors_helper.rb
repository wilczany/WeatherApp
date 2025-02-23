module SensorsHelper
  def latest_weather(sensor)
    sensor.weather_data.order(created_at: :desc).first
  end
end
