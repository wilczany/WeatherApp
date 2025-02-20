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
    city = params[:city]
    forecast_data = Forecast.fetch(city)
    if forecast_data.nil?
      redirect_to forecast_path, notice: "City not found"
      return
    end

    @location = forecast_data[:location]
    @today = forecast_data[:today]
    @current_weather = forecast_data[:current_weather]
    @forecasts = forecast_data[:forecasts]
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
