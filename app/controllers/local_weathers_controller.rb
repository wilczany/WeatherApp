class LocalWeathersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @data = LocalWeather.charts_data
  end

  def create
    sensor = Sensor.find(local_weather_params[:sensor_id])
    # zabezpieczenie przed masowym wysyłaniem danych
    if last_post_recently?(sensor)
      render json: { error: "Last measurement was less than 1 minute ago" }, status: :unprocessable_entity
      return
    end
    @weather = LocalWeather.new(local_weather_params)

    if @weather.save
      sensor.update!(state: :on)
      render json: @weather, status: :created
    else
      render json: @weather.errors, status: :unprocessable_entity
    end
  end

  private

  def last_post_recently?(sensor)
    last_record = sensor.latest_weather
    return false if last_record.nil?
    last_time = last_record.created_at
    last_time > 1.minute.ago
  end

  def local_weather_params
    params.require(:local_weather).permit(:temperature, :humidity, :pressure, :sensor_id)
  end
end
