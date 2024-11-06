require "net/http"
require "json"

class LocalWeatherService
  @@uri = URI("http://localhost:4567")

  def initialize
  end

  def self.get_weather
    begin
      res = Net::HTTP.get_response(@@uri)
    rescue Errno::ECONNREFUSED => _
      # puts "#{e.class.name}"
      puts "error connecting to sensor"
      Sensor.update_all(state: :off)

      return
    end

    data = JSON.parse(res.body)
    sensors_data = data["sensors"]

    Sensor.all.each do |sensor|
      w_data = sensors_data.values.find { |s| s["name"] == sensor.name }
      puts "w_data: #{w_data}"
      if w_data.nil?
        sensor.update(state: :off)
        puts "No data for sensor: #{sensor.name}, setting state to off"
        next
      end

      puts "sensor: #{sensor.inspect}"

      w = LocalWeather.new(
        temperature: w_data["temp"].to_f,
        humidity: w_data["humid"].to_f,
        pressure: w_data["pressure"].to_i,
        sensor: sensor,
        created_at: Time.now.change(sec: 0)
      )
      # Save the LocalWeather record
      if w.save!
        sensor.update(state: :on)
      else
        puts "there was an error saving the weather data"
      end
    end

    puts "end of file local_weather_services"
  end
end
