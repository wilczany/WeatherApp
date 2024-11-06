require "net/http"

class PagesController < ApplicationController
  def home
    @local_weathers = LocalWeather.order(created_at: :desc).group_by(&:sensor_id).transform_values { |records| records.first(10) }
    
    @temperature_data = @local_weathers.map { |sensor_id, readings|
    {
      name: "#{Sensor.find(sensor_id).name}",
      data: readings.map { |reading| [ reading.created_at, reading.temperature ] }
    }
  }
  @humidity_data = @local_weathers.map { |sensor_id, readings|
    {
      name: "#{Sensor.find(sensor_id).name}",
      data: readings.map { |reading| [ reading.created_at, reading.humidity ] }
    }
  }
  @pressure_data = @local_weathers.map { |sensor_id, readings|
    {
      name: "#{Sensor.find(sensor_id).name}",
      data: readings.map { |reading| [ reading.created_at, reading.pressure ] }
    }
  }
  end

  def forecast
    api_key = Rails.application.credentials.user.weather_api_key
    uri = URI("http://api.weatherapi.com/v1/forecast.json?key=#{api_key}&q=Bialystok&days=1&aqi=no&alerts=no")

    response = Net::HTTP.get_response(uri)
    body = JSON.parse(response.body)

    data = body["forecast"]["forecastday"][0]["hour"]
    @location = body["location"]["name"]
    @today = body["current"]["last_updated"].to_time

    @forecasts = []

    data.each do |d|
      f = Forecast.new(d["time"].to_time, d["temp_c"], d["condition"]["icon"])
      if f.time > Time.now.strftime("%H:%M")
        @forecasts << f
      end
    end
  end
end
