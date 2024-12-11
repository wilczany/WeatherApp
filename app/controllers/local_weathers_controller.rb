class LocalWeathersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @local_weather = LocalWeather.all
    render json: @local_weather
  end


  def create
    # Accept an array of local_weathers
    local_weathers = params[:local_weathers]

    Sensor.update_all(state: :off)
    # Use .create for skipping invalid records
    begin
      local_weathers.each do |w_data|
        puts "w_data: #{w_data}"
        if w_data["pressure"].to_i == 0
          next
        end
        LocalWeather.create!(
          temperature: w_data["temperature"].to_f,
          humidity: w_data["humidity"].to_f,
          pressure: w_data["pressure"].to_i,
          sensor_id: w_data["sensor"].to_i,
          created_at: Time.now.change(usec: 0)
        )
        Sensor.find(w_data["sensor"].to_i).update(state: :on)
      end

    rescue ActiveRecord::RecordInvalid => e
      render json: {
        error: "Validation failed",
        details: e.message
      }, status: :unprocessable_entity
    end

    # update charts
    #
    # Trigger Turbo update
    # Turbo::StreamsChannel.broadcast_replace_to(
    #   "charts",
    #   target: "charts",
    #   partial: "pages/charts",
    #   locals: { local_weathers: @local_weathers }
    # )
    # # render json for success
    # render json: {
    #   success: true
    # }, status: :ok
  end
end
