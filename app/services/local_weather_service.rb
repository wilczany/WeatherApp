
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
      puts 'error connecting to sensor'
      return
    end
      
    json_data = JSON.parse(res.body)

    
    w = LocalWeather.new(temperature: json_data["temperature"],
        humidity: json_data["humidity"],
        pressure: json_data["pressure"]
        )
    
    unless w.save
      puts 'there was an error saving the weather data'
    end
    puts 'end of file local_weather_services'
  end
end
