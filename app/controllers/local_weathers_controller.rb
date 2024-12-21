class LocalWeathersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @local_weather = LocalWeather.all
    render json: @local_weather
  end


  def create
    # Accept an array of local_weathers
    local_weathers = params[:local_weathers]

    # if last_post_recently?
    #   render json: {
    #     error: "Last post was less than 1 minute ago"
    #   }, status: :unprocessable_entity
    #   return
    # end
    # 
    Sensor.update_all(state: :off)

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


    # # v2
    # puts " HEJ SAKU TU SIE ZACZYNA POST"
    # local_weathers = params[:local_weathers]
  
    # # if last_post_recently?(local_weathers["sensor"])
    # #   render json: {
    # #     error: "Last post was less than 1 minute ago"
    # #   }, status: :unprocessable_entity
    # #   return
    # # end

    # begin
    #   if local_weathers["pressure"].to_i == 0
    #     return
    #   end
    #   LocalWeather.create!(
    #     temperature: local_weathers["temperature"].to_f,
    #     humidity: local_weathers["humidity"].to_f,
    #     pressure: local_weathers["pressure"].to_i,
    #     sensor_id: local_weathers["sensor"].to_i,
    #     created_at: Time.now.change(usec: 0)
    #   )

    # rescue ActiveRecord::RecordInvalid => e
    #   render json: {
    #     error: "Validation failed",
    #     details: e.message
    #   }, status: :unprocessable_entity
    # end

    #  Sensor.find(local_weathers["sensor"].to_i).update(state: :on)
    # puts local_weathers["sensor"]
    # puts "#\n#\n#\n#"
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

  def last_post_recently?(sensor_id)
    puts "sensor_id: #{sensor_id}"
    last_record = LocalWeather.where("sensor_id='#{sensor_id}'").last
    return false if last_record.nil?
    last_time = last_record.created_at
    last_time > 1.minute.ago
  end
end
