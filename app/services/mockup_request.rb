
require 'json'
require 'rufus-scheduler'
require "net/http"

scheduler = Rufus::Scheduler.new


scheduler.every '5s' do
  uri = URI('http://localhost:3000/local_weathers')
  http = Net::HTTP.new(uri.host, uri.port)
  data = {
    local_weathers: [
      { temperature: rand(15..25), humidity: rand(40..80), pressure: rand(980..1020), sensor: 1 },
      { temperature: rand(15..25), humidity: rand(40..80), pressure: rand(980..1020), sensor: 2 },
      { temperature: rand(15..25), humidity: rand(40..80), pressure: rand(980..1020), sensor: 3 }
    ]
  }.to_json

  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = data
  
  response = http.request(request)

  puts response.body
end

scheduler.join
