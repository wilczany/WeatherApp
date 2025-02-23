
require "json"
require "rufus-scheduler"
require "net/http"

scheduler = Rufus::Scheduler.new


scheduler.every "2m" do
  sleep 1
  uri = URI("http://localhost:3000/local_weathers")
  http = Net::HTTP.new(uri.host, uri.port)

  [ 1, 2, 3 ].each do |sensor|
    data = {
      local_weather: {
        temperature: rand(15..25), humidity: rand(40..80), pressure: rand(980..1020), sensor_id: sensor }
    }.to_json

    request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    request.body = data

    response = http.request(request)
    puts "Sensor #{sensor}: #{response.body}"
  end
end
scheduler.join
