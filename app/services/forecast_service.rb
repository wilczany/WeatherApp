class ForecastService
  def self.fetch(city)
    require "i18n"
    require "net/http"
    default_city = "Bialystok"
    city = I18n.transliterate(city.presence || default_city)
    api_key = Rails.application.credentials.user.weather_api_key
    uri = URI(
      "http://api.weatherapi.com/v1/forecast.json?key=\
      #{api_key}&q=#{city}&days=3&aqi=no&alerts=no"
    )

    begin
      response = Net::HTTP.get_response(uri)
      body = JSON.parse(response.body)
      return nil if response.code != "200"

      {
        location: body["location"]["name"],
        today: body["current"]["last_updated"].to_time,
        current_weather: {
          temp_c: body["current"]["temp_c"],
          condition: body["current"]["condition"]["text"],
          icon: body["current"]["condition"]["icon"],
          feels_like: body["current"]["feelslike_c"],
          wind_kph: body["current"]["wind_kph"],
          wind_dir: body["current"]["wind_dir"],
          humidity: body["current"]["humidity"],
          pressure_mb: body["current"]["pressure_mb"],
          last_updated: body["current"]["last_updated"].to_time.strftime("%H:%M")
        },
        forecasts: body["forecast"]["forecastday"].map do |day|
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
      }
    rescue SocketError, Errno::ECONNREFUSED
      { error: "No internet connection. Please try again later." }
    end
  end
end
