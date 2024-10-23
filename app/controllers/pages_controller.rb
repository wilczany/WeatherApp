require "net/http"

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
