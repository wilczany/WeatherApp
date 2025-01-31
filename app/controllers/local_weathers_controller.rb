class LocalWeathersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @local_weather = LocalWeather.all
    render json: @local_weather
  end

  def create
    # @local_weather = LocalWeather.new(local_weather_params)
    # if @local_weather.save
    #   local_weathers = params[:local_weathers]

    #   Sensor.update_all(state: :off)

    #   begin
    #     local_weathers.each do |w_data|
    #       puts "w_data: #{w_data}"
    #       if w_data["pressure"].to_i == 0
    #         next
    #       end
    #       LocalWeather.create!(
    #         temperature: w_data["temperature"].to_f,
    #         humidity: w_data["humidity"].to_f,
    #         pressure: w_data["pressure"].to_i,
    #         sensor_id: w_data["sensor"].to_i,
    #         created_at: Time.now.change(usec: 0)
    #       )
    #       Sensor.find(w_data["sensor"].to_i).update(state: :on)
    #     end
    #   rescue ActiveRecord::RecordInvalid => e
    #     render json: {
    #       error: "Validation failed",
    #       details: e.message
    #     }, status: :unprocessable_entity
    #   end

    #   respond_to do |format|
    #     format.html { redirect_to @local_weather }
    #     format.json { render :show, status: :created, location: @local_weather }
    #     format.turbo_stream
    #   end
    # else
    #   render json: {
    #     error: "Validation failed"
    #   }, status: :unprocessable_entity
    # end
    sensor_id = local_weather_params[:sensor_id]
    if last_post_recently?(sensor_id)
      render json: { error: "Last measurement was less than 1 minute ago" }, status: :unprocessable_entity
      return
    end
    @weather = LocalWeather.new(local_weather_params.merge(created_at: Time.now.change(usec: 0)))

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
