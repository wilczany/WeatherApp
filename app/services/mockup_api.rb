
#rubocop:disable all
require 'sinatra'
require 'json'

get '/' do
  content_type :json
  { temperature: rand(10.0..12.0).round(2),
    humidity: rand(30..60).round(2),
    pressure: rand(990..1010)
  }.to_json
  # { :temperatue => 10.22 }.to_json
end
