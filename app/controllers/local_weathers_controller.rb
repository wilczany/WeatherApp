class LocalWeathersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @data = LocalWeather.charts_data
  end

  def create
    sensor_id = local_weather_params[:sensor_id]
    if last_post_recently?(sensor_id)
      render json: { error: "Last measurement was less than 1 minute ago" }, status: :unprocessable_entity
      return
    end
    @weather = LocalWeather.new(local_weather_params)
    sensor = Sensor.find(local_weather_params[:sensor_id])
    sensor.update(state: :on)

    if @weather.save
      render json: @weather, status: :created
    else
      render json: @weather.errors, status: :unprocessable_entity
    end
  end

  def last_post_recently?(sensor_id)
    last_record = LocalWeather.where("sensor_id='#{sensor_id}'").last
    return false if last_record.nil?
    last_time = last_record.created_at
    last_time > 1.minute.ago
  end

  private

  def local_weather_params
    params.require(:local_weather).permit(:temperature, :humidity, :pressure, :sensor_id)
  end
end
