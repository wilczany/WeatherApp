require "net/http"

class PagesController < ApplicationController
  def home
    # @local_weathers = LocalWeather.order(created_at: :desc).first(18).group_by(&:sensor_id)
    @time = params[:minutes_ago]&.to_i|| 10
    minutes_ago = @time.minutes.ago
    @local_weathers = LocalWeather.where("created_at >= ?", minutes_ago).order(created_at: :desc).group_by(&:sensor_id)
    unless @local_weathers.empty?
      map_data(:temperature)
      set_min_max(:temperature)

      map_data(:humidity)
      set_min_max(:humidity)

      map_data(:pressure)
      set_min_max(:pressure)
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

  def update_charts
    minutes_ago = 5.minutes.ago
    @local_weathers = LocalWeather.where("created_at >= ?", minutes_ago).order(created_at: :desc).group_by(&:sensor_id)

    map_data(:temperature)
    set_min_max(:temperature)

    map_data(:humidity)
    set_min_max(:humidity)

    map_data(:pressure)
    set_min_max(:pressure)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def map_data(data_type)
    self.instance_variable_set(
      "@#{data_type}_data",
      @local_weathers.map { |sensor_id, readings|
      {
        name: "#{Sensor.find(sensor_id).name}",
        data: readings.map { |reading| [ reading.created_at, reading.send(data_type) ] }
      } }
    )
  end

  def set_min_max(data_type)
    diff = 2
    global = @local_weathers.values.flatten.map(&data_type).compact
    self.instance_variable_set(
      "@#{data_type}_min",
      global.min - diff
    )
    self.instance_variable_set(
      "@#{data_type}_max",
      global.max + diff
    )
  end
end
