
#rubocop:disable all
require 'sinatra'
require 'json'
require 'rufus-scheduler'
require "net/http"

scheduler = Rufus::Scheduler.new


scheduler.every '5s' do
  uri = URI('http://localhost:3000/local_weathers')
  http = Net::HTTP.new(uri.host, uri.port)
  
  data = {
    local_weathers: [
      { temperature: 20.0, humidity: 50.0, pressure: 1000, sensor: 1 },
      { temperature: 18.0, humidity: 70.0, pressure: 1010, sensor: 2 }
    ]
  }.to_json

  request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  request.body = data
  
  response = http.request(request)

  puts response.body
end

scheduler.join
