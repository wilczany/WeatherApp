
require "net/http"
require "json"
class LocalWeatherService
  @@uri = URI("http://localhost:4567")

  def initialize
  end

  def self.get_weather
    begin
      res = Net::HTTP.get_response(@@uri)
    rescue Errno::ECONNREFUSED => e
      puts "#{e.class.name}"
      puts "error connecting to sensor"
      return
    end

    data = JSON.parse(res.body)

    data["sensors"].each do |sensor_id, sensor_data|
      sensor = Sensor.find_by(id: sensor_id)

      puts sensor.inspect
      w =LocalWeather.new(
        temperature: sensor_data["temp"].to_f,
        humidity: sensor_data["humid"].to_f,
        pressure: sensor_data["pressure"].to_i,
        sensor: sensor
      )



      # Save the LocalWeather record
      unless w.save!
        puts "there was an error saving the weather data"
      end
      puts "end of file local_weather_services"
    end
  end
end
