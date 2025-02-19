require "net/http"

class PagesController < ApplicationController
  def home
    # @local_weathers = LocalWeather.order(created_at: :desc).first(18).group_by(&:sensor_id)
    @time = params[:minutes_ago]&.to_i|| 30
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
    require 'i18n'
    city = !params[:city].nil? ? I18n.transliterate(params[:city]) : "Bialystok"
    # city = "Bialystok"
    puts "City: #{city}"
    api_key = Rails.application.credentials.user.weather_api_key
    # Change days parameter to 7
    uri = URI("http://api.weatherapi.com/v1/forecast.json?key=#{api_key}&q=#{city}&days=7&aqi=no&alerts=no")

    response = Net::HTTP.get_response(uri)
    body = JSON.parse(response.body)
    puts "Response code: #{response.code}"
    if response.code != "200"
      redirect_to forecast_path, notice: "City not found"
      return
    end
    @location = body["location"]["name"]
    @today = body["current"]["last_updated"].to_time
    current = body["current"]
    @current_weather = {
      temp_c: current["temp_c"],
      condition: current["condition"]["text"],
      icon: current["condition"]["icon"],
      feels_like: current["feelslike_c"],
      wind_kph: current["wind_kph"],
      wind_dir: current["wind_dir"],
      humidity: current["humidity"],
      pressure_mb: current["pressure_mb"],
      last_updated: current["last_updated"].to_time.strftime("%H:%M")

    }

    # Get 3-day forecast data
    @forecasts = body["forecast"]["forecastday"].map do |day|
      {
        date: day["date"].to_date,
        max_temp: day["day"]["maxtemp_c"],
        min_temp: day["day"]["mintemp_c"],
        avg_temp: day["day"]["avgtemp_c"],
        condition: day["day"]["condition"]["text"],
        icon: day["day"]["condition"]["icon"],
        max_wind: day["day"]["maxwind_kph"],
        chance_of_rain: day["day"]["daily_chance_of_rain"],
        humidity: day["day"]["avghumidity"]
      }
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
  private
  
end
